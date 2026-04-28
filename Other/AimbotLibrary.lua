--// Amphibia Aimbot Module
--// Player-only aiming module for your own Roblox game.
--// Control only through API: SetEnabled(true / false).
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

		Smoothness = 0.16,
		AimStrength = 0.75,

		MaxDistance = 1000,
		MinDistance = 0.1,

		FovColor = Color3.fromRGB(255, 255, 255),
		FovRadius = 140,
		FovVisible = true,
		FovPosition = "Center", -- "Center" / "Mouse"

		RequireAlive = true,
		RequireCharacterInWorkspace = true,

		TeamCheck = false,
		TargetSameTeam = false,

		UseScriptableCamera = false,

		AllowUserRetarget = true,
		RetargetEveryFrame = true,
		SwitchMargin = 12,
		LoseTargetOutsideFov = true,

		MouseOverride = {
			Enabled = true,
			Threshold = 0.4,
			MinAimStrength = 0,
			RecoverySpeed = 7,
			RetargetOnInput = true,
		},

		-- Main target source. This is the safest way.
		UsePlayersService = true,

		-- Extra fallback if characters are placed weirdly/nested in workspace.
		-- It still only accepts models that belong to real Roblox Players.
		WorkspaceScan = {
			Enabled = true,
			DeepScan = true,
			RefreshRate = 0.25,
			MaxScannedInstances = 2500,
		},

		RenderName = "AmphibiaAimbotRender",
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

local function isRealInstance(value)
	return typeof(value) == "Instance"
end

local function isRealPlayer(value)
	return isRealInstance(value) and value:IsA("Player")
end

local function isRealModel(value)
	return isRealInstance(value) and value:IsA("Model")
end

local function isRealBasePart(value)
	return isRealInstance(value) and value:IsA("BasePart")
end

local function isValidHumanoid(value)
	return isRealInstance(value) and value:IsA("Humanoid")
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
	if not isRealPlayer(self.Player) then
		return nil
	end

	local character = self.Player.Character

	if not isRealModel(character) then
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

	if not isRealBasePart(root) then
		return nil
	end

	return root
end

--// Strict Player / Character Filtering

function AmphibiaAimbot:IsCharacterInWorkspace(character)
	if not isRealModel(character) then
		return false
	end

	if not self.Config.AimbotSetting.RequireCharacterInWorkspace then
		return true
	end

	return character:IsDescendantOf(Workspace)
end

function AmphibiaAimbot:GetPlayerFromCharacter(character)
	if not isRealModel(character) then
		return nil
	end

	local player = Players:GetPlayerFromCharacter(character)

	if not isRealPlayer(player) then
		return nil
	end

	return player
end

function AmphibiaAimbot:IsRealPlayerCharacter(character)
	if not isRealModel(character) then
		return false
	end

	if not self:IsCharacterInWorkspace(character) then
		return false
	end

	local owner = self:GetPlayerFromCharacter(character)

	if not owner then
		return false
	end

	return true
end

function AmphibiaAimbot:GetPlayerCharacter(player)
	if not isRealPlayer(player) then
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
	if not isRealModel(character) then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not isValidHumanoid(humanoid) then
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
	if not isRealModel(character) then
		return nil
	end

	local partName = self.Config.AimbotSetting.TargetingPart
	local part = character:FindFirstChild(partName)

	if isRealBasePart(part) then
		return part
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if isRealBasePart(root) then
		return root
	end

	local head = character:FindFirstChild("Head")

	if isRealBasePart(head) then
		return head
	end

	return nil
end

function AmphibiaAimbot:IsTeamAllowed(targetPlayer)
	if not self.Config.AimbotSetting.TeamCheck then
		return true
	end

	if not isRealPlayer(self.Player) or not isRealPlayer(targetPlayer) then
		return false
	end

	if self.Config.AimbotSetting.TargetSameTeam then
		return self.Player.Team == targetPlayer.Team
	end

	return self.Player.Team ~= targetPlayer.Team
end

function AmphibiaAimbot:IsTargetInDistance(targetPart)
	local localRoot = self:GetLocalRoot()

	if not localRoot or not isRealBasePart(targetPart) then
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
	if not isRealPlayer(player) then
		return
	end

	if player == self.Player then
		return
	end

	if usedPlayers[player] then
		return
	end

	if not isRealModel(character) then
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
		if isRealPlayer(player) then
			local character = player.Character
			self:AddCandidate(candidates, usedPlayers, player, character)
		end
	end
end

function AmphibiaAimbot:CollectFromWorkspaceScan(candidates, usedPlayers)
	local scanSettings = self.Config.AimbotSetting.WorkspaceScan

	if not scanSettings or not scanSettings.Enabled then
		return
	end

	local scanned = 0
	local instances

	if scanSettings.DeepScan then
		instances = Workspace:GetDescendants()
	else
		instances = Workspace:GetChildren()
	end

	for _, instance in ipairs(instances) do
		scanned += 1

		if scanned > (scanSettings.MaxScannedInstances or 2500) then
			break
		end

		if isRealModel(instance) then
			local player = self:GetPlayerFromCharacter(instance)

			if isRealPlayer(player) then
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

--// Drawing FOV

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

	if distance <= self.Config.AimbotSetting.FovRadius then
		return true, distance
	end

	return false, distance
end

--// Target Validation

function AmphibiaAimbot:IsValidPlayerTarget(player)
	if not isRealPlayer(player) then
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

	local inDistance = self:IsTargetInDistance(targetPart)

	if not inDistance then
		return false
	end

	local insideFov = self:IsWorldPositionInsideFov(targetPart.Position)

	if not insideFov then
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

	local insideFov, fovDistance = self:IsWorldPositionInsideFov(targetPart.Position)

	if not insideFov or not fovDistance then
		return nil
	end

	local _, worldDistance = self:IsTargetInDistance(targetPart)

	return {
		Player = player,
		Character = character,
		Part = targetPart,
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

		if isRealPlayer(player) then
			local data = self:GetTargetData(player)

			if data and data.FovDistance < closestFovDistance then
				closestData = data
				closestFovDistance = data.FovDistance
			end
		end
	end

	if not closestData then
		return nil, nil, nil, nil
	end

	return closestData.Player, closestData.Character, closestData.Part, closestData.FovDistance
end

function AmphibiaAimbot:GetCurrentTargetData()
	if not self.CurrentTargetPlayer then
		return nil
	end

	return self:GetTargetData(self.CurrentTargetPlayer)
end

function AmphibiaAimbot:SelectTarget()
	local settings = self.Config.AimbotSetting

	local bestPlayer, bestCharacter, bestPart, bestFovDistance = self:GetClosestPlayerInFov()

	if not bestPlayer then
		self:ClearTarget()
		return
	end

	local currentData = self:GetCurrentTargetData()

	if not currentData then
		self.CurrentTargetPlayer = bestPlayer
		self.CurrentTargetCharacter = bestCharacter
		self.CurrentTargetPart = bestPart
		return
	end

	if currentData.Player == bestPlayer then
		self.CurrentTargetPlayer = currentData.Player
		self.CurrentTargetCharacter = currentData.Character
		self.CurrentTargetPart = currentData.Part
		return
	end

	if not settings.RetargetEveryFrame then
		self.CurrentTargetPlayer = currentData.Player
		self.CurrentTargetCharacter = currentData.Character
		self.CurrentTargetPart = currentData.Part
		return
	end

	if not settings.AllowUserRetarget then
		self.CurrentTargetPlayer = currentData.Player
		self.CurrentTargetCharacter = currentData.Character
		self.CurrentTargetPart = currentData.Part
		return
	end

	if settings.LoseTargetOutsideFov then
		local currentInsideFov = self:IsWorldPositionInsideFov(currentData.Part.Position)

		if not currentInsideFov then
			self.CurrentTargetPlayer = bestPlayer
			self.CurrentTargetCharacter = bestCharacter
			self.CurrentTargetPart = bestPart
			return
		end
	end

	local switchMargin = settings.SwitchMargin or 0

	if bestFovDistance + switchMargin < currentData.FovDistance then
		self.CurrentTargetPlayer = bestPlayer
		self.CurrentTargetCharacter = bestCharacter
		self.CurrentTargetPart = bestPart
	else
		self.CurrentTargetPlayer = currentData.Player
		self.CurrentTargetCharacter = currentData.Character
		self.CurrentTargetPart = currentData.Part
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
	local threshold = override.Threshold or 0.4

	if mouseSpeed > threshold then
		self.MouseOverrideAlpha = 1

		if override.RetargetOnInput then
			self:ClearTarget()
		end
	else
		local recoverySpeed = override.RecoverySpeed or 7

		self.MouseOverrideAlpha = math.clamp(
			self.MouseOverrideAlpha - deltaTime * recoverySpeed,
			0,
			1
		)
	end
end

--// Aim Logic

function AmphibiaAimbot:GetAimCFrame(targetPart)
	if not self.Camera or not isRealBasePart(targetPart) then
		return nil
	end

	local cameraPosition = self.Camera.CFrame.Position
	local targetPosition = targetPart.Position

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

function AmphibiaAimbot:AimAt(targetPart, deltaTime)
	if not isRealBasePart(targetPart) then
		return
	end

	local targetCFrame = self:GetAimCFrame(targetPart)

	if not targetCFrame then
		return
	end

	local alpha = self:GetAimAlpha(deltaTime)

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

	if not self.CurrentTargetPlayer or not self.CurrentTargetCharacter or not self.CurrentTargetPart then
		return
	end

	self:AimAt(self.CurrentTargetPart, deltaTime)
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

		self:SelectTarget()
	else
		self:ClearTarget()

		self.MouseOverrideAlpha = 0
		self.LastMouseDelta = Vector2.zero

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
		Enum.RenderPriority.Camera.Value + 1,
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
