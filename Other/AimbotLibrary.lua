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

		Smoothness = 0,
		AimStrength = 1,

		MaxDistance = 99999,
		MinDistance = 0,

		FovColor = Color3.fromRGB(255, 255, 255),
		FovRadius = 260,
		FovVisible = true,
		FovPosition = "Center", -- "Center" / "Mouse"

		RequireAlive = true,
		RequireCharacterInWorkspace = true,

		TeamCheck = false,
		TargetSameTeam = false,

		-- false = не трогает твою систему камеры.
		UseScriptableCamera = false,

		AllowUserRetarget = true,
		RetargetEveryFrame = true,
		SwitchMargin = 6,

		-- false = FOV только для первого захвата.
		-- true = если цель вышла из FOV, аим перейдёт в LastKnownPoint.
		LoseTargetOutsideFov = false,

		RenderPriority = 999999,
		RenderName = "AmphibiaAimbotRender",

		UsePlayersService = true,

		WorkspaceScan = {
			Enabled = true,
			DeepScan = true,
			RefreshRate = 0.35,
			MaxScannedInstances = 4000,
		},

		WallCheck = {
			Enabled = false,
			IgnoreTransparent = true,
			TransparencyThreshold = 0.95,
			IgnoreNonCollidable = true,
			MaxPierces = 8,
		},

		Prediction = {
			Enabled = false,
			Mode = "Fixed",
			Time = 0.04,
			ProjectileSpeed = 900,
			MaxTime = 0.1,
			PositionSmoothing = 0,
		},

		-- Теперь это отвечает за последнюю точку после смерти/исчезновения цели.
		LostTarget = {
			Enabled = true,

			-- Сколько камера держит последнюю точку.
			HoldTime = 0.35,

			-- 1 + 0 = моментально в последнюю точку.
			ReturnStrength = 1,
			ReturnSmoothness = 0,

			ClearAfterHold = true,

			-- Если true, после потери текущей цели сначала держит last point,
			-- а не сразу перескакивает на другую цель.
			PreferLastPointBeforeNewTarget = true,
		},

		MouseOverride = {
			Enabled = false,
			Threshold = 999,
			MinAimStrength = 1,
			RecoverySpeed = 0,
			RetargetOnInput = false,
		},

		ManualRetarget = {
			Enabled = true,

			-- Чем меньше, тем легче сорвать цель мышкой.
			Threshold = 0.025,

			-- Почти мгновенно возвращается после остановки мышки.
			StopGrace = 0.01,

			ClearCurrentTarget = true,
			ClearLastTracked = true,
			ReacquireImmediately = true,
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
	self.LostTargetSourcePlayer = nil

	self.FovCircle = nil
	self.FovConnection = nil

	self.OldCameraType = nil
	self.OldCameraSubject = nil

	self.MouseOverrideAlpha = 0
	self.LastMouseDelta = Vector2.zero

	self.ManualRetargetActive = false
	self.ManualRetargetLastInput = 0
	self.IgnoreManualRetargetUntil = 0
	self.ForceAcquireNextFrame = false

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

function AmphibiaAimbot:GetRawTargetPosition(targetPart)
	if not isBasePart(targetPart) then
		return nil
	end

	local position = targetPart.Position
	local offset = self.Config.AimbotSetting.AimOffset

	if typeof(offset) == "Vector3" then
		position += offset
	end

	return position
end

function AmphibiaAimbot:GetTargetPosition(character, targetPart)
	if not isBasePart(targetPart) then
		return nil
	end

	local basePosition = self:GetRawTargetPosition(targetPart)

	if not basePosition then
		return nil
	end

	local prediction = self.Config.AimbotSetting.Prediction

	if not prediction or not prediction.Enabled then
		return basePosition
	end

	local velocity = targetPart.AssemblyLinearVelocity

	if velocity.Magnitude <= 0.05 then
		return basePosition
	end

	local predictionTime = prediction.Time or 0.04

	if prediction.Mode == "DistanceBased" and self.Camera then
		local distance = (basePosition - self.Camera.CFrame.Position).Magnitude
		local projectileSpeed = prediction.ProjectileSpeed or 900

		if projectileSpeed > 0 then
			predictionTime = distance / projectileSpeed
		end
	end

	predictionTime = math.clamp(predictionTime, 0, prediction.MaxTime or 0.1)

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
	local refreshRate = 0.35

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

function AmphibiaAimbot:IsValidPlayerTarget(player, options)
	options = options or {}

	local ignoreFov = options.IgnoreFov == true
	local ignoreAlive = options.IgnoreAlive == true

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

	if not ignoreAlive then
		if not self:IsCharacterAlive(character) then
			return false
		end
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

	if not ignoreFov then
		local insideFov = self:IsWorldPositionInsideFov(targetPosition)

		if not insideFov then
			return false
		end
	end

	if not self:IsVisible(character, targetPart, targetPosition) then
		return false
	end

	return true
end

function AmphibiaAimbot:GetTargetData(player, options)
	options = options or {}

	local ignoreFov = options.IgnoreFov == true
	local ignoreAlive = options.IgnoreAlive == true

	if not self:IsValidPlayerTarget(player, {
		IgnoreFov = ignoreFov,
		IgnoreAlive = ignoreAlive,
	}) then
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

	local fovDistance = self:GetFovDistance(targetPosition)
	local insideFov = false

	if fovDistance then
		insideFov = fovDistance <= self.Config.AimbotSetting.FovRadius
	end

	if not ignoreFov and not insideFov then
		return nil
	end

	local _, worldDistance = self:IsTargetInDistance(targetPart)

	return {
		Player = player,
		Character = character,
		Part = targetPart,
		Position = targetPosition,
		FovDistance = fovDistance or math.huge,
		WorldDistance = worldDistance or math.huge,
		InsideFov = insideFov,
	}
end

function AmphibiaAimbot:CaptureCurrentTargetLastPoint()
	if not self.CurrentTargetPlayer then
		return false
	end

	local character = self:GetPlayerCharacter(self.CurrentTargetPlayer)

	if not character then
		return false
	end

	local targetPart = self.CurrentTargetPart

	if not isBasePart(targetPart) or not targetPart:IsDescendantOf(character) then
		targetPart = self:GetTargetPartFromCharacter(character)
	end

	if not isBasePart(targetPart) then
		return false
	end

	local rawPosition = self:GetRawTargetPosition(targetPart)

	if not rawPosition then
		return false
	end

	self:SaveLastTrackedPoint(rawPosition, targetPart, self.CurrentTargetPlayer)

	return true
end

--// Target Selection

function AmphibiaAimbot:GetClosestPlayerInFov()
	local closestData = nil
	local closestFovDistance = math.huge

	for _, candidate in ipairs(self:GetCandidates()) do
		local player = candidate.Player

		if isPlayer(player) then
			local data = self:GetTargetData(player, {
				IgnoreFov = false,
				IgnoreAlive = false,
			})

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

	local ignoreFov = self.Config.AimbotSetting.LoseTargetOutsideFov == false

	return self:GetTargetData(self.CurrentTargetPlayer, {
		IgnoreFov = ignoreFov,
		IgnoreAlive = false,
	})
end

function AmphibiaAimbot:SetCurrentTargetFromData(data)
	if not data then
		self:ClearTarget(false)
		return
	end

	self.CurrentTargetPlayer = data.Player
	self.CurrentTargetCharacter = data.Character
	self.CurrentTargetPart = data.Part
	self.CurrentTargetPosition = data.Position
end

function AmphibiaAimbot:SaveLastTrackedPoint(position, targetPart, sourcePlayer)
	if typeof(position) ~= "Vector3" then
		return
	end

	self.LastTrackedPosition = position
	self.LastTrackedTime = os.clock()
	self.LostTargetStartedAt = nil
	self.LostTargetSourcePlayer = sourcePlayer or self.CurrentTargetPlayer

	if isBasePart(targetPart) then
		self.LastTrackedVelocity = targetPart.AssemblyLinearVelocity
	else
		self.LastTrackedVelocity = Vector3.zero
	end
end

function AmphibiaAimbot:ClearLastTracked()
	self.LastTrackedPosition = nil
	self.LastTrackedVelocity = Vector3.zero
	self.LastTrackedTime = 0
	self.LostTargetStartedAt = nil
	self.LostTargetSourcePlayer = nil
end

function AmphibiaAimbot:IsLostTargetActive()
	local lost = self.Config.AimbotSetting.LostTarget

	if not lost or not lost.Enabled then
		return false
	end

	if not self.LastTrackedPosition or not self.LostTargetStartedAt then
		return false
	end

	local elapsed = os.clock() - self.LostTargetStartedAt
	local holdTime = lost.HoldTime or 0.35

	return elapsed <= holdTime
end

function AmphibiaAimbot:EnterLostTargetState()
	local lost = self.Config.AimbotSetting.LostTarget

	if not lost or not lost.Enabled then
		self:ClearTarget(false)
		self:ClearLastTracked()
		return
	end

	if not self.LastTrackedPosition then
		self:ClearTarget(false)
		return
	end

	if not self.LostTargetStartedAt then
		self.LostTargetStartedAt = os.clock()
	end

	self.CurrentTargetPlayer = nil
	self.CurrentTargetCharacter = nil
	self.CurrentTargetPart = nil
	self.CurrentTargetPosition = nil
	self.SmoothedAimPosition = nil
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
			self:ClearLastTracked()
			self.SmoothedAimPosition = nil
		end

		return nil
	end

	-- ВАЖНО:
	-- Камера держит именно последнюю точку отслеживания.
	-- Не возвращается к точке первого захвата.
	return self.LastTrackedPosition
end

function AmphibiaAimbot:SelectTarget()
	local settings = self.Config.AimbotSetting
	local lost = settings.LostTarget

	-- Если мы уже в состоянии LostTarget, не перескакиваем сразу на новую цель.
	if self:IsLostTargetActive() then
		return
	end

	-- До любой валидации сохраняем сырую последнюю позицию текущей цели.
	-- Это фиксит баг, когда цель умерла/пропала, и позиция больше не обновилась.
	if self.CurrentTargetPlayer then
		self:CaptureCurrentTargetLastPoint()
	end

	local currentData = self:GetCurrentTargetData()

	-- Если была текущая цель, но она стала невалидной,
	-- держим именно последнюю точку перед потерей.
	if self.CurrentTargetPlayer and not currentData then
		self:EnterLostTargetState()
		return
	end

	if currentData and settings.LoseTargetOutsideFov == false then
		local bestPlayer, bestCharacter, bestPart, bestPosition, bestFovDistance = self:GetClosestPlayerInFov()

		if not settings.RetargetEveryFrame or not settings.AllowUserRetarget then
			self:SetCurrentTargetFromData(currentData)
			self:SaveLastTrackedPoint(currentData.Position, currentData.Part, currentData.Player)
			return
		end

		if bestPlayer and bestPlayer ~= currentData.Player then
			local switchMargin = settings.SwitchMargin or 0

			if bestFovDistance and bestFovDistance + switchMargin < currentData.FovDistance then
				self.CurrentTargetPlayer = bestPlayer
				self.CurrentTargetCharacter = bestCharacter
				self.CurrentTargetPart = bestPart
				self.CurrentTargetPosition = bestPosition

				self:SaveLastTrackedPoint(bestPosition, bestPart, bestPlayer)
				return
			end
		end

		self:SetCurrentTargetFromData(currentData)
		self:SaveLastTrackedPoint(currentData.Position, currentData.Part, currentData.Player)
		return
	end

	local bestPlayer, bestCharacter, bestPart, bestPosition, bestFovDistance = self:GetClosestPlayerInFov()

	if not bestPlayer then
		self:EnterLostTargetState()
		return
	end

	if not currentData then
		self.CurrentTargetPlayer = bestPlayer
		self.CurrentTargetCharacter = bestCharacter
		self.CurrentTargetPart = bestPart
		self.CurrentTargetPosition = bestPosition

		self:SaveLastTrackedPoint(bestPosition, bestPart, bestPlayer)
		return
	end

	if currentData.Player == bestPlayer then
		self:SetCurrentTargetFromData(currentData)
		self:SaveLastTrackedPoint(currentData.Position, currentData.Part, currentData.Player)
		return
	end

	if not settings.RetargetEveryFrame or not settings.AllowUserRetarget then
		self:SetCurrentTargetFromData(currentData)
		self:SaveLastTrackedPoint(currentData.Position, currentData.Part, currentData.Player)
		return
	end

	if settings.LoseTargetOutsideFov then
		local currentInsideFov = self:IsWorldPositionInsideFov(currentData.Position)

		if not currentInsideFov then
			self:EnterLostTargetState()
			return
		end
	end

	local switchMargin = settings.SwitchMargin or 0

	if bestFovDistance + switchMargin < currentData.FovDistance then
		self.CurrentTargetPlayer = bestPlayer
		self.CurrentTargetCharacter = bestCharacter
		self.CurrentTargetPart = bestPart
		self.CurrentTargetPosition = bestPosition

		self:SaveLastTrackedPoint(bestPosition, bestPart, bestPlayer)
	else
		self:SetCurrentTargetFromData(currentData)
		self:SaveLastTrackedPoint(currentData.Position, currentData.Part, currentData.Player)
	end
end

--// Manual Retarget

function AmphibiaAimbot:IsManualRetargetActive()
	return self.ManualRetargetActive == true
end

function AmphibiaAimbot:UpdateManualRetarget()
	local retarget = self.Config.AimbotSetting.ManualRetarget

	if not retarget or not retarget.Enabled then
		self.ManualRetargetActive = false
		self.ManualRetargetLastInput = 0
		return false
	end

	local now = os.clock()

	if now < self.IgnoreManualRetargetUntil then
		self.ManualRetargetActive = false
		return false
	end

	local mouseDelta = UserInputService:GetMouseDelta()
	local threshold = retarget.Threshold or 0.025
	local stopGrace = retarget.StopGrace or 0.01

	if mouseDelta.Magnitude > threshold then
		self.ManualRetargetLastInput = now

		if not self.ManualRetargetActive then
			self.ManualRetargetActive = true

			if retarget.ClearCurrentTarget ~= false then
				self:ClearTarget(retarget.ClearLastTracked == true)
			end
		end

		return true
	end

	if self.ManualRetargetActive then
		local timeSinceInput = now - self.ManualRetargetLastInput

		if timeSinceInput <= stopGrace then
			return true
		end

		self.ManualRetargetActive = false

		if retarget.ReacquireImmediately ~= false then
			self:ClearTarget(retarget.ClearLastTracked == true)
			self:RefreshCandidates(true)
			self:SelectTarget()
		end

		return false
	end

	return false
end

--// Old Mouse Override

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
	local threshold = override.Threshold or 999

	if mouseSpeed > threshold then
		self.MouseOverrideAlpha = 1

		if override.RetargetOnInput then
			self:ClearTarget(false)
		end
	else
		local recoverySpeed = override.RecoverySpeed or 0

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

	if self.ForceAcquireNextFrame then
		self.ForceAcquireNextFrame = false
		self:ClearTarget(true)
		self:RefreshCandidates(true)
		self:SelectTarget()
	end

	local manualRetargetActive = self:UpdateManualRetarget()

	if manualRetargetActive then
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
			lost.ReturnStrength or 1,
			lost.ReturnSmoothness or 0
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
		else
			self.OldCameraType = nil
			self.OldCameraSubject = nil
		end

		self.MouseOverrideAlpha = 0
		self.LastMouseDelta = Vector2.zero

		self.ManualRetargetActive = false
		self.ManualRetargetLastInput = 0

		self.IgnoreManualRetargetUntil = os.clock() + 0.05
		self.ForceAcquireNextFrame = true

		self.SmoothedAimPosition = nil
		self:ClearLastTracked()
		self:ClearTarget(true)

		self:SelectTarget()
	else
		self:ClearTarget(true)

		self.MouseOverrideAlpha = 0
		self.LastMouseDelta = Vector2.zero

		self.ManualRetargetActive = false
		self.ManualRetargetLastInput = 0
		self.IgnoreManualRetargetUntil = 0
		self.ForceAcquireNextFrame = false

		self.SmoothedAimPosition = nil
		self:ClearLastTracked()

		if self.Camera and self.OldCameraType then
			self.Camera.CameraType = self.OldCameraType
			self.Camera.CameraSubject = self.OldCameraSubject
		end

		self.OldCameraType = nil
		self.OldCameraSubject = nil
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

function AmphibiaAimbot:ClearTarget(clearLastTracked)
	self.CurrentTargetPlayer = nil
	self.CurrentTargetCharacter = nil
	self.CurrentTargetPart = nil
	self.CurrentTargetPosition = nil
	self.SmoothedAimPosition = nil

	if clearLastTracked then
		self:ClearLastTracked()
	end
end

--// Config API

function AmphibiaAimbot:SetConfig(newConfig)
	self.Config = mergeConfig(self.Config, newConfig)
	self:ClearTarget(true)
	self:RefreshCandidates(true)
end

function AmphibiaAimbot:SetTargetingPart(partName)
	self.Config.AimbotSetting.TargetingPart = partName
	self:ClearTarget(false)
end

function AmphibiaAimbot:SetAimOffset(offset)
	if typeof(offset) == "Vector3" then
		self.Config.AimbotSetting.AimOffset = offset
		self:ClearTarget(false)
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
	self:ClearTarget(false)
end

function AmphibiaAimbot:SetTargetSameTeam(enabled)
	self.Config.AimbotSetting.TargetSameTeam = enabled == true
	self:ClearTarget(false)
end

function AmphibiaAimbot:SetSwitchMargin(margin)
	self.Config.AimbotSetting.SwitchMargin = margin
end

function AmphibiaAimbot:SetUserRetarget(enabled)
	self.Config.AimbotSetting.AllowUserRetarget = enabled == true
end

function AmphibiaAimbot:SetWallCheck(enabled)
	self.Config.AimbotSetting.WallCheck.Enabled = enabled == true
	self:ClearTarget(false)
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

function AmphibiaAimbot:SetManualRetarget(config)
	local current = self.Config.AimbotSetting.ManualRetarget or {}

	for key, value in pairs(config) do
		current[key] = value
	end

	self.Config.AimbotSetting.ManualRetarget = current
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
	print("ManualRetargetActive:", self:IsManualRetargetActive())
	print("LostTargetActive:", self:IsLostTargetActive())
	print("LastTrackedPosition:", self.LastTrackedPosition)

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
		print("Valid as acquisition:", self:IsValidPlayerTarget(player, { IgnoreFov = false }))
		print("Valid as current lock:", self:IsValidPlayerTarget(player, { IgnoreFov = true }))
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
		self.Config.AimbotSetting.RenderPriority or 999999,
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
