--// Amphibia Aimbot Module
--// Player-only aiming module for your own Roblox game.
--// API control only: SetEnabled(true / false).
--// Drawing API is expected to match executor-style Drawing.new("Circle").

local AmphibiaAimbot = {}
AmphibiaAimbot.__index = AmphibiaAimbot

--// Services

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

--// Default Config

local DEFAULT_CONFIG = {
	MainSettings = {
		ScriptName = "Amphibia",
		Debug = true,
	},

	AimbotSetting = {
		Enabled = false,

		TargetingPart = "Head",
		AimOffset = Vector3.new(0, 0, 0),

		Smoothness = 0.05,
		AimStrength = 1,

		MaxDistance = 1000,
		MinDistance = 0,

		FovColor = Color3.fromRGB(255, 255, 255),
		FovRadius = 180,
		FovVisible = true,
		FovPosition = "Center", -- "Center" / "Mouse"

		RequireAlive = true,
		RequireCharacterInWorkspace = true,

		TeamCheck = false,
		TargetSameTeam = false,

		UseScriptableCamera = false,

		AllowUserRetarget = true,
		RetargetEveryFrame = true,
		SwitchMargin = 6,
		LoseTargetOutsideFov = true,

		RenderPriority = 10000,
		RenderName = "AmphibiaAimbotRender",

		UsePlayersService = true,

		WorkspaceScan = {
			Enabled = true,
			DeepScan = true,
			RefreshRate = 0.25,
			MaxScannedInstances = 4000,
		},

		WallCheck = {
			Enabled = true,
			IgnoreTransparent = true,
			TransparencyThreshold = 0.95,
			IgnoreNonCollidable = false,
			MaxPierces = 8,
		},

		Prediction = {
			Enabled = true,

			-- "Fixed" / "DistanceBased"
			Mode = "Fixed",

			-- Good start for hitscan-like guns.
			Time = 0.08,

			-- Used only when Mode = "DistanceBased".
			ProjectileSpeed = 900,

			MaxTime = 0.16,

			-- Smooths predicted point so aim does not shake.
			PositionSmoothing = 0.12,
		},

		LostTarget = {
			Enabled = true,

			-- How long camera keeps aiming at last tracked point.
			HoldTime = 0.35,

			ReturnStrength = 0.85,
			ReturnSmoothness = 0.1,

			ClearAfterHold = true,
		},

		MouseOverride = {
			Enabled = true,
			Threshold = 1.25,
			MinAimStrength = 0.15,
			RecoverySpeed = 9,
			RetargetOnInput = true,
		},
	},

	DrawingSetting = {
		Enabled = true,
		Thickness = 1,
		Transparency = 1,
		NumSides = 100,
		Filled = false,
	},
}

--// Utility

local function deepCopy(tbl)
	local copy = {}

	for key, value in pairs(tbl) do
		if typeof(value) == "table" then
			copy[key] = deepCopy(value)
		else
			copy[key] = value
		end
	end

	return copy
end

local function mergeConfig(base, custom)
	local result = deepCopy(base)

	if typeof(custom) ~= "table" then
		return result
	end

	for key, value in pairs(custom) do
		if typeof(value) == "table" and typeof(result[key]) == "table" then
			result[key] = mergeConfig(result[key], value)
		else
			result[key] = value
		end
	end

	return result
end

local function safeRemoveDrawingObject(object)
	if not object then
		return
	end

	local removed = pcall(function()
		object:Remove()
	end)

	if not removed then
		pcall(function()
			object:Destroy()
		end)
	end
end

local function isInstance(value)
	return typeof(value) == "Instance"
end

local function isPlayer(value)
	return isInstance(value) and value:IsA("Player")
end

local function isModel(value)
	return isInstance(value) and value:IsA("Model")
end

local function isBasePart(value)
	return isInstance(value) and value:IsA("BasePart")
end

local function isHumanoid(value)
	return isInstance(value) and value:IsA("Humanoid")
end

--// Constructor

function AmphibiaAimbot.new(config)
	local self = setmetatable({}, AmphibiaAimbot)

	self.Config = mergeConfig(DEFAULT_CONFIG, config)

	self.Player = Players.LocalPlayer
	self.Camera = Workspace.CurrentCamera

	self.Started = false
	self.Enabled = false

	self.CurrentTargetPlayer = nil
	self.CurrentTargetCharacter = nil
	self.CurrentTargetPart = nil
	self.CurrentTargetPosition = nil

	self.SmoothedAimPosition = nil

	self.LastTrackedPosition = nil
	self.LastTrackedVelocity = Vector3.zero
	self.LastTrackedTime = 0
	self.LostTargetStartedAt = nil

	self.FovCircle = nil
	self.FovConnection = nil

	self.OldCameraType = nil
	self.OldCameraSubject = nil

	self.MouseOverrideAlpha = 0
	self.LastMouseDelta = Vector2.zero

	self.CachedCandidates = {}
	self.LastCandidateRefresh = 0

	return self
end

--// Logger

function AmphibiaAimbot:Log(logType, message)
	if not self.Config.MainSettings.Debug then
		return
	end

	local t = os.date("*t")

	local timestamp = string.format(
		"[%02d.%02d.%04d / %02d:%02d]",
		t.day,
		t.month,
		t.year,
		t.hour,
		t.min
	)

	print(timestamp .. " " .. self.Config.MainSettings.ScriptName .. " " .. logType .. " | " .. message)
end

--// Local Character

function AmphibiaAimbot:GetLocalCharacter()
	if not isPlayer(self.Player) then
		return nil
	end

	local character = self.Player.Character

	if not isModel(character) then
		return nil
	end

	return character
end

function AmphibiaAimbot:GetLocalRoot()
	local character = self:GetLocalCharacter()

	if not character then
		return nil
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if not isBasePart(root) then
		return nil
	end

	return root
end

--// Strict Player / Character Filtering

function AmphibiaAimbot:IsCharacterInWorkspace(character)
	if not isModel(character) then
		return false
	end

	if not self.Config.AimbotSetting.RequireCharacterInWorkspace then
		return true
	end

	return character:IsDescendantOf(Workspace)
end

function AmphibiaAimbot:GetPlayerFromCharacter(character)
	if not isModel(character) then
		return nil
	end

	local player = Players:GetPlayerFromCharacter(character)

	if not isPlayer(player) then
		return nil
	end

	return player
end

function AmphibiaAimbot:IsRealPlayerCharacter(character)
	if not isModel(character) then
		return false
	end

	if not self:IsCharacterInWorkspace(character) then
		return false
	end

	local player = self:GetPlayerFromCharacter(character)

	if not player then
		return false
	end

	return true
end

function AmphibiaAimbot:GetPlayerCharacter(player)
	if not isPlayer(player) then
		return nil
	end

	if player == self.Player then
		return nil
	end

	local character = player.Character

	if not self:IsRealPlayerCharacter(character) then
		return nil
	end

	return character
end

function AmphibiaAimbot:GetHumanoid(character)
	if not isModel(character) then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not isHumanoid(humanoid) then
		return nil
	end

	return humanoid
end

function AmphibiaAimbot:IsCharacterAlive(character)
	if not self.Config.AimbotSetting.RequireAlive then
		return true
	end

	local humanoid = self:GetHumanoid(character)

	if not humanoid then
		return false
	end

	return humanoid.Health > 0
end

function AmphibiaAimbot:GetTargetPartFromCharacter(character)
	if not isModel(character) then
		return nil
	end

	local partName = self.Config.AimbotSetting.TargetingPart
	local part = character:FindFirstChild(partName)

	if isBasePart(part) then
		return part
	end

	local head = character:FindFirstChild("Head")

	if isBasePart(head) then
		return head
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if isBasePart(root) then
		return root
	end

	return nil
end

function AmphibiaAimbot:GetTargetPosition(character, targetPart)
	if not isBasePart(targetPart) then
		return nil
	end

	local basePosition = targetPart.Position

	local offset = self.Config.AimbotSetting.AimOffset
	if typeof(offset) == "Vector3" then
		basePosition += offset
	end

	local prediction = self.Config.AimbotSetting.Prediction

	if not prediction or not prediction.Enabled then
		return basePosition
	end

	local velocity = targetPart.AssemblyLinearVelocity

	if velocity.Magnitude <= 0.05 then
		return basePosition
	end

	local predictionTime = prediction.Time or 0.08

	if prediction.Mode == "DistanceBased" and self.Camera then
		local distance = (basePosition - self.Camera.CFrame.Position).Magnitude
		local projectileSpeed = prediction.ProjectileSpeed or 900

		if projectileSpeed > 0 then
			predictionTime = distance / projectileSpeed
		end
	end

	predictionTime = math.clamp(predictionTime, 0, prediction.MaxTime or 0.16)

	return basePosition + velocity * predictionTime
end

function AmphibiaAimbot:IsTeamAllowed(targetPlayer)
	if not self.Config.AimbotSetting.TeamCheck then
		return true
	end

	if not isPlayer(self.Player) or not isPlayer(targetPlayer) then
		return false
	end

	local localTeam = self.Player.Team
	local targetTeam = targetPlayer.Team

	if localTeam == nil or targetTeam == nil then
		return true
	end

	if self.Config.AimbotSetting.TargetSameTeam then
		return localTeam == targetTeam
	end

	return localTeam ~= targetTeam
end

function AmphibiaAimbot:IsTargetInDistance(targetPart)
	local localRoot = self:GetLocalRoot()

	if not localRoot or not isBasePart(targetPart) then
		return false, nil
	end

	local distance = (localRoot.Position - targetPart.Position).Magnitude
	local minDistance = self.Config.AimbotSetting.MinDistance
	local maxDistance = self.Config.AimbotSetting.MaxDistance

	if distance >= minDistance and distance <= maxDistance then
		return true, distance
	end

	return false, distance
end

--// Candidate Collection

function AmphibiaAimbot:AddCandidate(candidates, usedPlayers, player, character)
	if not isPlayer(player) then
		return
	end

	if player == self.Player then
		return
	end

	if usedPlayers[player] then
		return
	end

	if not isModel(character) then
		return
	end

	if not self:IsRealPlayerCharacter(character) then
		return
	end

	local owner = self:GetPlayerFromCharacter(character)

	if owner ~= player then
		return
	end

	usedPlayers[player] = true

	table.insert(candidates, {
		Player = player,
		Character = character,
	})
end

function AmphibiaAimbot:CollectFromPlayersService(candidates, usedPlayers)
	if not self.Config.AimbotSetting.UsePlayersService then
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if isPlayer(player) then
			self:AddCandidate(candidates, usedPlayers, player, player.Character)
		end
	end
end

function AmphibiaAimbot:CollectFromWorkspaceScan(candidates, usedPlayers)
	local scanSettings = self.Config.AimbotSetting.WorkspaceScan

	if not scanSettings or not scanSettings.Enabled then
		return
	end

	local instances

	if scanSettings.DeepScan then
		instances = Workspace:GetDescendants()
	else
		instances = Workspace:GetChildren()
	end

	local scanned = 0
	local maxScanned = scanSettings.MaxScannedInstances or 4000

	for _, instance in ipairs(instances) do
		scanned += 1

		if scanned > maxScanned then
			break
		end

		if isModel(instance) then
			local player = self:GetPlayerFromCharacter(instance)

			if isPlayer(player) then
				self:AddCandidate(candidates, usedPlayers, player, instance)
			end
		end
	end
end

function AmphibiaAimbot:RefreshCandidates(force)
	local now = os.clock()
	local scanSettings = self.Config.AimbotSetting.WorkspaceScan
	local refreshRate = 0.25

	if scanSettings and scanSettings.RefreshRate then
		refreshRate = scanSettings.RefreshRate
	end

	if not force and now - self.LastCandidateRefresh < refreshRate then
		return
	end

	self.LastCandidateRefresh = now

	local candidates = {}
	local usedPlayers = {}

	self:CollectFromPlayersService(candidates, usedPlayers)
	self:CollectFromWorkspaceScan(candidates, usedPlayers)

	self.CachedCandidates = candidates
end

function AmphibiaAimbot:GetCandidates()
	self:RefreshCandidates(false)
	return self.CachedCandidates
end

--// FOV Drawing

function AmphibiaAimbot:DrawFov()
	if self.FovCircle then
		return self.FovCircle, self.FovConnection
	end

	if not self.Config.DrawingSetting.Enabled then
		return nil, nil
	end

	if not Drawing then
		self:Log("warning", "Drawing API was not found.")
		return nil, nil
	end

	local fov = Drawing.new("Circle")

	fov.Filled = self.Config.DrawingSetting.Filled
	fov.Thickness = self.Config.DrawingSetting.Thickness
	fov.Transparency = self.Config.DrawingSetting.Transparency
	fov.NumSides = self.Config.DrawingSetting.NumSides

	self.FovCircle = fov

	self.FovConnection = RunService.RenderStepped:Connect(function()
		self.Camera = Workspace.CurrentCamera

		if not self.Camera then
			return
		end

		local settings = self.Config.AimbotSetting

		fov.Visible = settings.FovVisible
		fov.Color = settings.FovColor
		fov.Radius = settings.FovRadius

		if settings.FovPosition == "Mouse" then
			fov.Position = UserInputService:GetMouseLocation()
		else
			fov.Position = self.Camera.ViewportSize / 2
		end
	end)

	return self.FovCircle, self.FovConnection
end

function AmphibiaAimbot:RemoveFov()
	if self.FovConnection then
		self.FovConnection:Disconnect()
		self.FovConnection = nil
	end

	if self.FovCircle then
		safeRemoveDrawingObject(self.FovCircle)
		self.FovCircle = nil
	end
end

--// FOV Logic

function AmphibiaAimbot:GetFovCenter()
	if not self.Camera then
		return Vector2.zero
	end

	if self.Config.AimbotSetting.FovPosition == "Mouse" then
		return UserInputService:GetMouseLocation()
	end

	return self.Camera.ViewportSize / 2
end

function AmphibiaAimbot:GetScreenPosition(worldPosition)
	if not self.Camera then
		return nil
	end

	local screenPosition, onScreen = self.Camera:WorldToViewportPoint(worldPosition)

	if not onScreen then
		return nil
	end

	if screenPosition.Z < 0 then
		return nil
	end

	return Vector2.new(screenPosition.X, screenPosition.Y)
end

function AmphibiaAimbot:GetFovDistance(worldPosition)
	local targetScreenPosition = self:GetScreenPosition(worldPosition)

	if not targetScreenPosition then
		return nil
	end

	local fovCenter = self:GetFovCenter()
	local distance = (targetScreenPosition - fovCenter).Magnitude

	return distance
end

function AmphibiaAimbot:IsWorldPositionInsideFov(worldPosition)
	local distance = self:GetFovDistance(worldPosition)

	if not distance then
		return false, nil
	end

	return distance <= self.Config.AimbotSetting.FovRadius, distance
end

--// Wall Check

function AmphibiaAimbot:IsVisible(character, targetPart, targetPosition)
	local wallCheck = self.Config.AimbotSetting.WallCheck

	if not wallCheck or not wallCheck.Enabled then
		return true
	end

	if not self.Camera or not isModel(character) or not isBasePart(targetPart) or typeof(targetPosition) ~= "Vector3" then
		return false
	end

	local origin = self.Camera.CFrame.Position
	local direction = targetPosition - origin

	if direction.Magnitude <= 0.01 then
		return true
	end

	local ignoreList = {}

	local localCharacter = self:GetLocalCharacter()
	if localCharacter then
		table.insert(ignoreList, localCharacter)
	end

	local maxPierces = wallCheck.MaxPierces or 8

	for _ = 1, maxPierces do
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = ignoreList
		params.IgnoreWater = true

		local result = Workspace:Raycast(origin, direction, params)

		if not result then
			return true
		end

		local hit = result.Instance

		if not hit then
			return true
		end

		if hit:IsDescendantOf(character) then
			return true
		end

		local canIgnore = false

		if wallCheck.IgnoreTransparent and isBasePart(hit) then
			if hit.Transparency >= (wallCheck.TransparencyThreshold or 0.95) then
				canIgnore = true
			end
		end

		if wallCheck.IgnoreNonCollidable and isBasePart(hit) then
			if not hit.CanCollide then
				canIgnore = true
			end
		end

		if canIgnore then
			table.insert(ignoreList, hit)
		else
			return false
		end
	end

	return false
end

--// Target Validation

function AmphibiaAimbot:IsValidPlayerTarget(player)
	if not isPlayer(player) then
		return false
	end

	if player == self.Player then
		return false
	end

	if not self:IsTeamAllowed(player) then
		return false
	end

	local character = self:GetPlayerCharacter(player)

	if not character then
		return false
	end

	if character == self:GetLocalCharacter() then
		return false
	end

	if not self:IsCharacterAlive(character) then
		return false
	end

	local targetPart = self:GetTargetPartFromCharacter(character)

	if not targetPart then
		return false
	end

	local targetPosition = self:GetTargetPosition(character, targetPart)

	if not targetPosition then
		return false
	end

	local inDistance = self:IsTargetInDistance(targetPart)

	if not inDistance then
		return false
	end

	local insideFov = self:IsWorldPositionInsideFov(targetPosition)

	if not insideFov then
		return false
	end

	if not self:IsVisible(character, targetPart, targetPosition) then
		return false
	end

	return true
end

function AmphibiaAimbot:GetTargetData(player)
	if not self:IsValidPlayerTarget(player) then
		return nil
	end

	local character = self:GetPlayerCharacter(player)

	if not character then
		return nil
	end

	local targetPart = self:GetTargetPartFromCharacter(character)

	if not targetPart then
		return nil
	end

	local targetPosition = self:GetTargetPosition(character, targetPart)

	if not targetPosition then
		return nil
	end

	local insideFov, fovDistance = self:IsWorldPositionInsideFov(targetPosition)

	if not insideFov or not fovDistance then
		return nil
	end

	local _, worldDistance = self:IsTargetInDistance(targetPart)

	return {
		Player = player,
		Character = character,
		Part = targetPart,
		Position = targetPosition,
		FovDistance = fovDistance,
		WorldDistance = worldDistance or math.huge,
	}
end

--// Target Selection

function AmphibiaAimbot:GetClosestPlayerInFov()
	local closestData = nil
	local closestFovDistance = math.huge

	for _, candidate in ipairs(self:GetCandidates()) do
		local player = candidate.Player

		if isPlayer(player) then
			local data = self:GetTargetData(player)

			if data and data.FovDistance < closestFovDistance then
				closestData = data
				closestFovDistance = data.FovDistance
			end
		end
	end

	if not closestData then
		return nil, nil, nil, nil, nil
	end

	return closestData.Player, closestData.Character, closestData.Part, closestData.Position, closestData.FovDistance
end

function AmphibiaAimbot:GetCurrentTargetData()
	if not self.CurrentTargetPlayer then
		return nil
	end

	return self:GetTargetData(self.CurrentTargetPlayer)
end

function AmphibiaAimbot:SetCurrentTargetFromData(data)
	if not data then
		self:ClearTarget()
		return
	end

	self.CurrentTargetPlayer = data.Player
	self.CurrentTargetCharacter = data.Character
	self.CurrentTargetPart = data.Part
	self.CurrentTargetPosition = data.Position
end

function AmphibiaAimbot:SaveLastTrackedPoint(position, targetPart)
	if typeof(position) ~= "Vector3" then
		return
	end

	self.LastTrackedPosition = position
	self.LastTrackedTime = os.clock()
	self.LostTargetStartedAt = nil

	if isBasePart(targetPart) then
		self.LastTrackedVelocity = targetPart.AssemblyLinearVelocity
	else
		self.LastTrackedVelocity = Vector3.zero
	end
end

function AmphibiaAimbot:EnterLostTargetState()
	local lost = self.Config.AimbotSetting.LostTarget

	if not lost or not lost.Enabled then
		self:ClearTarget()
		self.LastTrackedPosition = nil
		self.LastTrackedVelocity = Vector3.zero
		self.LostTargetStartedAt = nil
		return
	end

	if not self.LastTrackedPosition then
		self:ClearTarget()
		return
	end

	if not self.LostTargetStartedAt then
		self.LostTargetStartedAt = os.clock()
	end

	self.CurrentTargetPlayer = nil
	self.CurrentTargetCharacter = nil
	self.CurrentTargetPart = nil
	self.CurrentTargetPosition = nil
end

function AmphibiaAimbot:GetLastTrackedAimPosition()
	local lost = self.Config.AimbotSetting.LostTarget

	if not lost or not lost.Enabled then
		return nil
	end

	if not self.LastTrackedPosition or not self.LostTargetStartedAt then
		return nil
	end

	local elapsed = os.clock() - self.LostTargetStartedAt
	local holdTime = lost.HoldTime or 0.35

	if elapsed > holdTime then
		if lost.ClearAfterHold then
			self.LastTrackedPosition = nil
			self.LastTrackedVelocity = Vector3.zero
			self.LostTargetStartedAt = nil
			self.SmoothedAimPosition = nil
		end

		return nil
	end

	local projectedPosition = self.LastTrackedPosition + self.LastTrackedVelocity * math.min(elapsed, 0.15)

	return projectedPosition
end

function AmphibiaAimbot:SelectTarget()
	local settings = self.Config.AimbotSetting

	local bestPlayer, bestCharacter, bestPart, bestPosition, bestFovDistance = self:GetClosestPlayerInFov()

	if not bestPlayer then
		self:EnterLostTargetState()
		return
	end

	local currentData = self:GetCurrentTargetData()

	if not currentData then
		self.CurrentTargetPlayer = bestPlayer
		self.CurrentTargetCharacter = bestCharacter
		self.CurrentTargetPart = bestPart
		self.CurrentTargetPosition = bestPosition

		self:SaveLastTrackedPoint(bestPosition, bestPart)

		return
	end

	if currentData.Player == bestPlayer then
		self:SetCurrentTargetFromData(currentData)
		self:SaveLastTrackedPoint(currentData.Position, currentData.Part)
		return
	end

	if not settings.RetargetEveryFrame or not settings.AllowUserRetarget then
		self:SetCurrentTargetFromData(currentData)
		self:SaveLastTrackedPoint(currentData.Position, currentData.Part)
		return
	end

	if settings.LoseTargetOutsideFov then
		local currentInsideFov = self:IsWorldPositionInsideFov(currentData.Position)

		if not currentInsideFov then
			self.CurrentTargetPlayer = bestPlayer
			self.CurrentTargetCharacter = bestCharacter
			self.CurrentTargetPart = bestPart
			self.CurrentTargetPosition = bestPosition

			self:SaveLastTrackedPoint(bestPosition, bestPart)

			return
		end
	end

	local switchMargin = settings.SwitchMargin or 0

	if bestFovDistance + switchMargin < currentData.FovDistance then
		self.CurrentTargetPlayer = bestPlayer
		self.CurrentTargetCharacter = bestCharacter
		self.CurrentTargetPart = bestPart
		self.CurrentTargetPosition = bestPosition

		self:SaveLastTrackedPoint(bestPosition, bestPart)
	else
		self:SetCurrentTargetFromData(currentData)
		self:SaveLastTrackedPoint(currentData.Position, currentData.Part)
	end
end

--// Mouse Override

function AmphibiaAimbot:UpdateMouseOverride(deltaTime)
	local settings = self.Config.AimbotSetting
	local override = settings.MouseOverride

	if not override or not override.Enabled then
		self.MouseOverrideAlpha = 0
		self.LastMouseDelta = Vector2.zero
		return
	end

	local mouseDelta = UserInputService:GetMouseDelta()
	self.LastMouseDelta = mouseDelta

	local mouseSpeed = mouseDelta.Magnitude
	local threshold = override.Threshold or 1.25

	if mouseSpeed > threshold then
		self.MouseOverrideAlpha = 1

		if override.RetargetOnInput then
			self.CurrentTargetPlayer = nil
			self.CurrentTargetCharacter = nil
			self.CurrentTargetPart = nil
			self.CurrentTargetPosition = nil
		end
	else
		local recoverySpeed = override.RecoverySpeed or 9

		self.MouseOverrideAlpha = math.clamp(
			self.MouseOverrideAlpha - deltaTime * recoverySpeed,
			0,
			1
		)
	end
end

--// Aim Logic

function AmphibiaAimbot:GetSmoothedAimPosition(targetPosition, deltaTime)
	if typeof(targetPosition) ~= "Vector3" then
		return nil
	end

	local prediction = self.Config.AimbotSetting.Prediction
	local smoothing = 0

	if prediction and prediction.PositionSmoothing then
		smoothing = prediction.PositionSmoothing
	end

	if not self.SmoothedAimPosition then
		self.SmoothedAimPosition = targetPosition
		return targetPosition
	end

	if smoothing <= 0 then
		self.SmoothedAimPosition = targetPosition
		return targetPosition
	end

	local alpha = 1 - math.exp(-deltaTime / smoothing)
	self.SmoothedAimPosition = self.SmoothedAimPosition:Lerp(targetPosition, math.clamp(alpha, 0, 1))

	return self.SmoothedAimPosition
end

function AmphibiaAimbot:GetAimCFrame(targetPosition)
	if not self.Camera or typeof(targetPosition) ~= "Vector3" then
		return nil
	end

	local cameraPosition = self.Camera.CFrame.Position

	return CFrame.lookAt(cameraPosition, targetPosition)
end

function AmphibiaAimbot:GetAimAlpha(deltaTime)
	local settings = self.Config.AimbotSetting

	local smoothness = settings.Smoothness or 0
	local baseStrength = math.clamp(settings.AimStrength or 1, 0, 1)

	local override = settings.MouseOverride
	local minAimStrength = 0

	if override and override.MinAimStrength ~= nil then
		minAimStrength = math.clamp(override.MinAimStrength, 0, 1)
	end

	local dynamicStrength = baseStrength

	if self.MouseOverrideAlpha and self.MouseOverrideAlpha > 0 then
		dynamicStrength = baseStrength - ((baseStrength - minAimStrength) * self.MouseOverrideAlpha)
	end

	if smoothness <= 0 then
		return dynamicStrength
	end

	local alpha = 1 - math.exp(-deltaTime / smoothness)
	alpha = math.clamp(alpha * dynamicStrength, 0, 1)

	return alpha
end

function AmphibiaAimbot:AimAt(targetPosition, deltaTime, customStrength, customSmoothness)
	if typeof(targetPosition) ~= "Vector3" then
		return
	end

	local smoothedPosition = self:GetSmoothedAimPosition(targetPosition, deltaTime)

	if not smoothedPosition then
		return
	end

	local targetCFrame = self:GetAimCFrame(smoothedPosition)

	if not targetCFrame then
		return
	end

	local alpha

	if customSmoothness ~= nil then
		if customSmoothness <= 0 then
			alpha = customStrength or 1
		else
			alpha = 1 - math.exp(-deltaTime / customSmoothness)
			alpha = math.clamp(alpha * (customStrength or 1), 0, 1)
		end
	else
		alpha = self:GetAimAlpha(deltaTime)
	end

	if alpha <= 0 then
		return
	end

	if alpha >= 1 then
		self.Camera.CFrame = targetCFrame
	else
		self.Camera.CFrame = self.Camera.CFrame:Lerp(targetCFrame, alpha)
	end
end

function AmphibiaAimbot:Update(deltaTime)
	if not self.Enabled then
		return
	end

	self.Camera = Workspace.CurrentCamera

	if not self.Camera then
		return
	end

	self:UpdateMouseOverride(deltaTime)
	self:SelectTarget()

	if self.CurrentTargetPlayer and self.CurrentTargetCharacter and self.CurrentTargetPart and self.CurrentTargetPosition then
		self:AimAt(self.CurrentTargetPosition, deltaTime)
		return
	end

	local lostPosition = self:GetLastTrackedAimPosition()

	if lostPosition then
		local lost = self.Config.AimbotSetting.LostTarget

		self:AimAt(
			lostPosition,
			deltaTime,
			lost.ReturnStrength or 0.85,
			lost.ReturnSmoothness or 0.1
		)
	end
end

--// State API

function AmphibiaAimbot:SetEnabled(state)
	local enabled = state == true

	if self.Enabled == enabled then
		return
	end

	self.Enabled = enabled
	self.Camera = Workspace.CurrentCamera

	if self.Enabled then
		self:RefreshCandidates(true)

		if self.Config.AimbotSetting.UseScriptableCamera and self.Camera then
			self.OldCameraType = self.Camera.CameraType
			self.OldCameraSubject = self.Camera.CameraSubject

			self.Camera.CameraType = Enum.CameraType.Scriptable
		end

		self.MouseOverrideAlpha = 0
		self.LastMouseDelta = Vector2.zero

		self.SmoothedAimPosition = nil
		self.LastTrackedPosition = nil
		self.LastTrackedVelocity = Vector3.zero
		self.LastTrackedTime = 0
		self.LostTargetStartedAt = nil

		self:SelectTarget()
	else
		self:ClearTarget()

		self.MouseOverrideAlpha = 0
		self.LastMouseDelta = Vector2.zero

		self.SmoothedAimPosition = nil
		self.LastTrackedPosition = nil
		self.LastTrackedVelocity = Vector3.zero
		self.LastTrackedTime = 0
		self.LostTargetStartedAt = nil

		if self.Config.AimbotSetting.UseScriptableCamera and self.Camera and self.OldCameraType then
			self.Camera.CameraType = self.OldCameraType
			self.Camera.CameraSubject = self.OldCameraSubject
		end
	end
end

function AmphibiaAimbot:Toggle()
	self:SetEnabled(not self.Enabled)
end

function AmphibiaAimbot:IsEnabled()
	return self.Enabled
end

function AmphibiaAimbot:GetCurrentTarget()
	return self.CurrentTargetPlayer, self.CurrentTargetCharacter, self.CurrentTargetPart
end

function AmphibiaAimbot:ClearTarget()
	self.CurrentTargetPlayer = nil
	self.CurrentTargetCharacter = nil
	self.CurrentTargetPart = nil
	self.CurrentTargetPosition = nil
	self.SmoothedAimPosition = nil
end

--// Config API

function AmphibiaAimbot:SetConfig(newConfig)
	self.Config = mergeConfig(self.Config, newConfig)
	self:ClearTarget()
	self:RefreshCandidates(true)
end

function AmphibiaAimbot:SetTargetingPart(partName)
	self.Config.AimbotSetting.TargetingPart = partName
	self:ClearTarget()
end

function AmphibiaAimbot:SetAimOffset(offset)
	if typeof(offset) == "Vector3" then
		self.Config.AimbotSetting.AimOffset = offset
		self:ClearTarget()
	end
end

function AmphibiaAimbot:SetFovRadius(radius)
	self.Config.AimbotSetting.FovRadius = radius
end

function AmphibiaAimbot:SetFovVisible(visible)
	self.Config.AimbotSetting.FovVisible = visible == true
end

function AmphibiaAimbot:SetFovColor(color)
	self.Config.AimbotSetting.FovColor = color
end

function AmphibiaAimbot:SetFovPosition(position)
	if position == "Center" or position == "Mouse" then
		self.Config.AimbotSetting.FovPosition = position
	end
end

function AmphibiaAimbot:SetSmoothness(smoothness)
	self.Config.AimbotSetting.Smoothness = smoothness
end

function AmphibiaAimbot:SetAimStrength(strength)
	self.Config.AimbotSetting.AimStrength = math.clamp(strength, 0, 1)
end

function AmphibiaAimbot:SetMaxDistance(distance)
	self.Config.AimbotSetting.MaxDistance = distance
end

function AmphibiaAimbot:SetMinDistance(distance)
	self.Config.AimbotSetting.MinDistance = distance
end

function AmphibiaAimbot:SetTeamCheck(enabled)
	self.Config.AimbotSetting.TeamCheck = enabled == true
	self:ClearTarget()
end

function AmphibiaAimbot:SetTargetSameTeam(enabled)
	self.Config.AimbotSetting.TargetSameTeam = enabled == true
	self:ClearTarget()
end

function AmphibiaAimbot:SetSwitchMargin(margin)
	self.Config.AimbotSetting.SwitchMargin = margin
end

function AmphibiaAimbot:SetUserRetarget(enabled)
	self.Config.AimbotSetting.AllowUserRetarget = enabled == true
end

function AmphibiaAimbot:SetWallCheck(enabled)
	self.Config.AimbotSetting.WallCheck.Enabled = enabled == true
	self:ClearTarget()
end

function AmphibiaAimbot:SetPrediction(config)
	local current = self.Config.AimbotSetting.Prediction or {}

	for key, value in pairs(config) do
		current[key] = value
	end

	self.Config.AimbotSetting.Prediction = current
end

function AmphibiaAimbot:SetLostTarget(config)
	local current = self.Config.AimbotSetting.LostTarget or {}

	for key, value in pairs(config) do
		current[key] = value
	end

	self.Config.AimbotSetting.LostTarget = current
end

function AmphibiaAimbot:SetMouseOverride(config)
	local current = self.Config.AimbotSetting.MouseOverride or {}

	for key, value in pairs(config) do
		current[key] = value
	end

	self.Config.AimbotSetting.MouseOverride = current
end

function AmphibiaAimbot:SetWorkspaceScanEnabled(enabled)
	self.Config.AimbotSetting.WorkspaceScan.Enabled = enabled == true
	self:RefreshCandidates(true)
end

function AmphibiaAimbot:SetWorkspaceDeepScan(enabled)
	self.Config.AimbotSetting.WorkspaceScan.DeepScan = enabled == true
	self:RefreshCandidates(true)
end

--// Debug

function AmphibiaAimbot:DebugTargets()
	print("========== Amphibia Aimbot Debug ==========")
	print("Started:", self.Started)
	print("Enabled:", self.Enabled)
	print("LocalPlayer:", self.Player)
	print("LocalCharacter:", self:GetLocalCharacter())
	print("LocalRoot:", self:GetLocalRoot())
	print("Players:", #Players:GetPlayers())
	print("CachedCandidates:", #self.CachedCandidates)

	self:RefreshCandidates(true)

	for _, candidate in ipairs(self.CachedCandidates) do
		local player = candidate.Player
		local character = candidate.Character

		print("------------------------------------------")
		print("Player:", player and player.Name)
		print("Character:", character)
		print("IsCharacterInWorkspace:", character and character:IsDescendantOf(Workspace))

		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		print("Humanoid:", humanoid, humanoid and humanoid.Health)

		local part = character and self:GetTargetPartFromCharacter(character)
		print("TargetPart:", part)

		if part then
			local pos = self:GetTargetPosition(character, part)

			local inDistance, distance = self:IsTargetInDistance(part)
			print("Distance:", distance, "InDistance:", inDistance)

			local insideFov, fovDistance = self:IsWorldPositionInsideFov(pos)
			print("FovDistance:", fovDistance, "InsideFov:", insideFov)

			print("Visible:", self:IsVisible(character, part, pos))
		end

		print("TeamAllowed:", self:IsTeamAllowed(player))
		print("Valid:", self:IsValidPlayerTarget(player))
	end

	print("==========================================")
end

--// Lifecycle

function AmphibiaAimbot:Start()
	if self.Started then
		return
	end

	self.Started = true
	self.Camera = Workspace.CurrentCamera

	self:RefreshCandidates(true)

	if self.Config.DrawingSetting.Enabled then
		self:DrawFov()
	end

	RunService:BindToRenderStep(
		self.Config.AimbotSetting.RenderName,
		self.Config.AimbotSetting.RenderPriority or 10000,
		function(deltaTime)
			self:Update(deltaTime)
		end
	)

	if self.Config.AimbotSetting.Enabled then
		self:SetEnabled(true)
	end

	self:Log("info", "Started.")
end

function AmphibiaAimbot:Stop()
	if not self.Started then
		return
	end

	self.Started = false

	RunService:UnbindFromRenderStep(self.Config.AimbotSetting.RenderName)

	self:SetEnabled(false)
	self:RemoveFov()

	self.CachedCandidates = {}
	self.LastCandidateRefresh = 0

	self:Log("info", "Stopped.")
end

function AmphibiaAimbot:Destroy()
	self:Stop()

	setmetatable(self, nil)

	for key in pairs(self) do
		self[key] = nil
	end
end

return AmphibiaAimbot
