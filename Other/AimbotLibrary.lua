--// Amphibia Aimbot Module Recode v4
--// Player-only aiming module for your own Roblox game.
--// API control: SetEnabled(true / false) + optional Keybind.
--// Drawing API is expected to match executor-style Drawing.new("Circle") / Drawing.new("Line").

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

		UseScriptableCamera = false,

		RenderPriority = 999999,
		RenderName = "AmphibiaAimbotRender",

		RequireAlive = true,
		RequireCharacterInWorkspace = true,

		TeamCheck = false,
		TargetSameTeam = false,

		UsePlayersService = true,

		Keybind = {
			Enabled = false,

			-- "Toggle" / "Hold"
			Mode = "Toggle",

			-- Можно ставить KeyCode и UserInputType:
			-- Enum.KeyCode.E
			-- Enum.UserInputType.MouseButton2
			-- Enum.KeyCode.ButtonL2
			Inputs = {
				Enum.KeyCode.E,
			},

			-- true = если игрок пишет в TextBox или UI забрал ввод, keybind не сработает.
			RespectGameProcessed = true,
		},

		WorkspaceScan = {
			Enabled = true,
			DeepScan = true,
			RefreshRate = 0.35,
			MaxScannedInstances = 4000,
		},

		Fov = {
			Enabled = true,

			-- Если Enabled = false, захват идёт по всему экрану.
			Radius = 260,
			Position = "Center", -- "Center" / "Mouse"

			Visible = true,
			Color = Color3.fromRGB(255, 255, 255),

			-- false = FOV проверяется по реальной позиции.
			-- true = FOV проверяется по predicted position.
			UsePredictedPosition = false,

			-- "Auto" / "Circle" / "ClampedLines"
			-- Auto = если круг помещается на экран, Drawing Circle.
			-- Если выходит за экран, рисуется сжатая форма линиями.
			RenderMode = "Auto",

			ClampToScreen = true,
			ClampPadding = 1,

			-- Чем больше, тем круг плавнее, но дороже.
			Segments = 96,
		},

		-- false = FOV только зона первого захвата.
		-- true = если цель вышла из FOV, переходит в LostTarget.
		LoseTargetOutsideFov = false,

		Selection = {
			-- "ClosestToCenter" / "ClosestDistance" / "Hybrid" / "LowestHealth"
			Mode = "ClosestToCenter",

			HybridFovWeight = 1,
			HybridDistanceWeight = 0.015,
			HybridHealthWeight = 0,
		},

		Retarget = {
			Enabled = true,

			-- Чем меньше, тем легче авто-переключение.
			SwitchMargin = 6,

			-- Если true, после ручного отвода мышкой сразу ищет новую цель.
			ReacquireAfterManualInput = true,
		},

		ManualRetarget = {
			Enabled = true,

			-- "Release" = полностью отпускает аим, пока двигаешь мышкой.
			-- "Soft" = не полностью отпускает, а только ослабляет.
			Mode = "Release",

			Threshold = 0.025,
			StopGrace = 0.01,

			ClearCurrentTarget = true,
			ClearLastTracked = true,
			ReacquireImmediately = true,

			EnableIgnoreTime = 0.05,

			-- Только для Mode = "Soft"
			SoftAimStrength = 0.15,
		},

		MouseOverride = {
			Enabled = false,
			Threshold = 999,
			MinAimStrength = 1,
			RecoverySpeed = 0,
			RetargetOnInput = false,
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
			Mode = "Fixed", -- "Fixed" / "DistanceBased"
			Time = 0.04,
			ProjectileSpeed = 900,
			MaxTime = 0.1,
			PositionSmoothing = 0,
		},

		LostTarget = {
			Enabled = true,

			-- Сколько камера смотрит в последнюю точку после потери цели.
			HoldTime = 0.35,

			ReturnStrength = 1,
			ReturnSmoothness = 0,

			ClearAfterHold = true,

			-- Если true, не перескакивает сразу на новую цель, пока держит last point.
			PreferLastPointBeforeNewTarget = true,
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

local function clampVector2ToViewport(point, viewportSize, padding)
	padding = padding or 0

	return Vector2.new(
		math.clamp(point.X, padding, math.max(padding, viewportSize.X - padding)),
		math.clamp(point.Y, padding, math.max(padding, viewportSize.Y - padding))
	)
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
	self.CurrentTargetRawPosition = nil

	self.SmoothedAimPosition = nil

	self.LastTrackedPosition = nil
	self.LastTrackedRawPosition = nil
	self.LastTrackedVelocity = Vector3.zero
	self.LastTrackedTime = 0
	self.LostTargetStartedAt = nil
	self.LostTargetSourcePlayer = nil

	self.FovCircle = nil
	self.FovLines = {}
	self.FovConnection = nil

	self.InputBeganConnection = nil
	self.InputEndedConnection = nil

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

	self:NormalizeConfig()

	return self
end

--// Config compatibility

function AmphibiaAimbot:NormalizeConfig()
	local settings = self.Config.AimbotSetting
	settings.Fov = settings.Fov or {}

	if settings.FovRadius ~= nil then
		settings.Fov.Radius = settings.FovRadius
	end

	if settings.FovVisible ~= nil then
		settings.Fov.Visible = settings.FovVisible
	end

	if settings.FovColor ~= nil then
		settings.Fov.Color = settings.FovColor
	end

	if settings.FovPosition ~= nil then
		settings.Fov.Position = settings.FovPosition
	end

	settings.Retarget = settings.Retarget or {}

	if settings.SwitchMargin ~= nil and settings.Retarget.SwitchMargin == nil then
		settings.Retarget.SwitchMargin = settings.SwitchMargin
	end
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

	print(timestamp .. " " .. self.Config.MainSettings.ScriptName .. " " .. logType .. " | " .. tostring(message))
end

--// Config helpers

function AmphibiaAimbot:GetAimbotSettings()
	return self.Config.AimbotSetting
end

function AmphibiaAimbot:GetFovSettings()
	return self.Config.AimbotSetting.Fov
end

--// Input helpers

function AmphibiaAimbot:InputMatchesBind(input, bind)
	if typeof(bind) == "EnumItem" then
		return input.KeyCode == bind or input.UserInputType == bind
	end

	if typeof(bind) == "string" then
		if input.KeyCode and input.KeyCode.Name == bind then
			return true
		end

		if input.UserInputType and input.UserInputType.Name == bind then
			return true
		end
	end

	return false
end

function AmphibiaAimbot:InputMatchesKeybind(input)
	local keybind = self.Config.AimbotSetting.Keybind

	if not keybind or not keybind.Enabled then
		return false
	end

	local inputs = keybind.Inputs

	if typeof(inputs) ~= "table" then
		return self:InputMatchesBind(input, inputs)
	end

	for _, bind in ipairs(inputs) do
		if self:InputMatchesBind(input, bind) then
			return true
		end
	end

	return false
end

function AmphibiaAimbot:BindInputs()
	if self.InputBeganConnection then
		self.InputBeganConnection:Disconnect()
		self.InputBeganConnection = nil
	end

	if self.InputEndedConnection then
		self.InputEndedConnection:Disconnect()
		self.InputEndedConnection = nil
	end

	self.InputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		local keybind = self.Config.AimbotSetting.Keybind

		if not keybind or not keybind.Enabled then
			return
		end

		if keybind.RespectGameProcessed and gameProcessed then
			return
		end

		if not self:InputMatchesKeybind(input) then
			return
		end

		if keybind.Mode == "Hold" then
			self:SetEnabled(true)
		else
			self:Toggle()
		end
	end)

	self.InputEndedConnection = UserInputService.InputEnded:Connect(function(input, gameProcessed)
		local keybind = self.Config.AimbotSetting.Keybind

		if not keybind or not keybind.Enabled then
			return
		end

		if keybind.RespectGameProcessed and gameProcessed then
			return
		end

		if keybind.Mode ~= "Hold" then
			return
		end

		if not self:InputMatchesKeybind(input) then
			return
		end

		self:SetEnabled(false)
	end)
end

function AmphibiaAimbot:UnbindInputs()
	if self.InputBeganConnection then
		self.InputBeganConnection:Disconnect()
		self.InputBeganConnection = nil
	end

	if self.InputEndedConnection then
		self.InputEndedConnection:Disconnect()
		self.InputEndedConnection = nil
	end
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

	if not isPlayer(player) then
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

function AmphibiaAimbot:GetPredictedTargetPosition(rawPosition, targetPart)
	if typeof(rawPosition) ~= "Vector3" or not isBasePart(targetPart) then
		return nil
	end

	local prediction = self.Config.AimbotSetting.Prediction

	if not prediction or not prediction.Enabled then
		return rawPosition
	end

	local velocity = targetPart.AssemblyLinearVelocity

	if velocity.Magnitude <= 0.05 then
		return rawPosition
	end

	local predictionTime = prediction.Time or 0.04

	if prediction.Mode == "DistanceBased" and self.Camera then
		local distance = (rawPosition - self.Camera.CFrame.Position).Magnitude
		local projectileSpeed = prediction.ProjectileSpeed or 900

		if projectileSpeed > 0 then
			predictionTime = distance / projectileSpeed
		end
	end

	predictionTime = math.clamp(predictionTime, 0, prediction.MaxTime or 0.1)

	return rawPosition + velocity * predictionTime
end

function AmphibiaAimbot:GetTargetPosition(character, targetPart)
	local rawPosition = self:GetRawTargetPosition(targetPart)

	if not rawPosition then
		return nil, nil
	end

	local predictedPosition = self:GetPredictedTargetPosition(rawPosition, targetPart)

	return predictedPosition or rawPosition, rawPosition
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

function AmphibiaAimbot:HideFovLines()
	for _, line in ipairs(self.FovLines) do
		line.Visible = false
	end
end

function AmphibiaAimbot:EnsureFovLines(count)
	for i = #self.FovLines + 1, count do
		local line = Drawing.new("Line")
		line.Visible = false
		line.Color = self:GetFovSettings().Color
		line.Thickness = self.Config.DrawingSetting.Thickness
		line.Transparency = self.Config.DrawingSetting.Transparency
		self.FovLines[i] = line
	end

	for i = count + 1, #self.FovLines do
		self.FovLines[i].Visible = false
	end
end

function AmphibiaAimbot:IsCircleFullyOnScreen(center, radius, viewportSize)
	return center.X - radius >= 0
		and center.Y - radius >= 0
		and center.X + radius <= viewportSize.X
		and center.Y + radius <= viewportSize.Y
end

function AmphibiaAimbot:RenderFovAsCircle(center, radius, color)
	if not self.FovCircle then
		return
	end

	self:HideFovLines()

	self.FovCircle.Visible = true
	self.FovCircle.Position = center
	self.FovCircle.Radius = radius
	self.FovCircle.Color = color
	self.FovCircle.Thickness = self.Config.DrawingSetting.Thickness
	self.FovCircle.Transparency = self.Config.DrawingSetting.Transparency
	self.FovCircle.Filled = self.Config.DrawingSetting.Filled
	self.FovCircle.NumSides = self.Config.DrawingSetting.NumSides
end

function AmphibiaAimbot:RenderFovAsClampedLines(center, radius, color)
	if self.FovCircle then
		self.FovCircle.Visible = false
	end

	if not self.Camera then
		self:HideFovLines()
		return
	end

	local fovSettings = self:GetFovSettings()
	local viewportSize = self.Camera.ViewportSize
	local segments = math.max(12, fovSettings.Segments or 96)
	local padding = fovSettings.ClampPadding or 1

	self:EnsureFovLines(segments)

	for i = 1, segments do
		local a1 = (math.pi * 2) * ((i - 1) / segments)
		local a2 = (math.pi * 2) * (i / segments)

		local p1 = Vector2.new(
			center.X + math.cos(a1) * radius,
			center.Y + math.sin(a1) * radius
		)

		local p2 = Vector2.new(
			center.X + math.cos(a2) * radius,
			center.Y + math.sin(a2) * radius
		)

		p1 = clampVector2ToViewport(p1, viewportSize, padding)
		p2 = clampVector2ToViewport(p2, viewportSize, padding)

		local line = self.FovLines[i]
		line.From = p1
		line.To = p2
		line.Color = color
		line.Thickness = self.Config.DrawingSetting.Thickness
		line.Transparency = self.Config.DrawingSetting.Transparency
		line.Visible = true
	end
end

function AmphibiaAimbot:RenderFov()
	local fovSettings = self:GetFovSettings()

	if not self.Camera or not fovSettings.Visible or not fovSettings.Enabled then
		if self.FovCircle then
			self.FovCircle.Visible = false
		end

		self:HideFovLines()
		return
	end

	local center = self:GetFovCenter()
	local radius = fovSettings.Radius or 260
	local color = fovSettings.Color or Color3.fromRGB(255, 255, 255)
	local viewportSize = self.Camera.ViewportSize

	local renderMode = fovSettings.RenderMode or "Auto"
	local clampToScreen = fovSettings.ClampToScreen == true
	local fullyOnScreen = self:IsCircleFullyOnScreen(center, radius, viewportSize)

	if renderMode == "Circle" then
		self:RenderFovAsCircle(center, radius, color)
	elseif renderMode == "ClampedLines" then
		self:RenderFovAsClampedLines(center, radius, color)
	else
		if clampToScreen and not fullyOnScreen then
			self:RenderFovAsClampedLines(center, radius, color)
		else
			self:RenderFovAsCircle(center, radius, color)
		end
	end
end

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
		self:RenderFov()
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

	for _, line in ipairs(self.FovLines) do
		safeRemoveDrawingObject(line)
	end

	self.FovLines = {}
end

--// FOV Logic

function AmphibiaAimbot:GetFovCenter()
	if not self.Camera then
		return Vector2.zero
	end

	local fovSettings = self:GetFovSettings()

	if fovSettings.Position == "Mouse" then
		return UserInputService:GetMouseLocation()
	end

	return self.Camera.ViewportSize / 2
end

function AmphibiaAimbot:GetScreenPosition(worldPosition)
	if not self.Camera then
		return nil
	end

	if typeof(worldPosition) ~= "Vector3" then
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

	return (targetScreenPosition - fovCenter).Magnitude
end

function AmphibiaAimbot:IsWorldPositionInsideFov(worldPosition)
	local distance = self:GetFovDistance(worldPosition)

	if not distance then
		return false, nil
	end

	local fovSettings = self:GetFovSettings()

	-- ВАЖНО:
	-- если Fov.Enabled = false, тогда захватывается весь экран.
	if not fovSettings.Enabled then
		return true, distance
	end

	return distance <= fovSettings.Radius, distance
end

--// Visibility

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

--// Target Data

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

	if not ignoreAlive and not self:IsCharacterAlive(character) then
		return false
	end

	local targetPart = self:GetTargetPartFromCharacter(character)

	if not targetPart then
		return false
	end

	local aimPosition, rawPosition = self:GetTargetPosition(character, targetPart)

	if not aimPosition or not rawPosition then
		return false
	end

	local inDistance = self:IsTargetInDistance(targetPart)

	if not inDistance then
		return false
	end

	if not ignoreFov then
		local fovSettings = self:GetFovSettings()
		local fovPosition = fovSettings.UsePredictedPosition and aimPosition or rawPosition

		local insideFov = self:IsWorldPositionInsideFov(fovPosition)

		if not insideFov then
			return false
		end
	end

	if not self:IsVisible(character, targetPart, rawPosition) then
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

	local aimPosition, rawPosition = self:GetTargetPosition(character, targetPart)

	if not aimPosition or not rawPosition then
		return nil
	end

	local fovSettings = self:GetFovSettings()
	local fovPosition = fovSettings.UsePredictedPosition and aimPosition or rawPosition
	local fovDistance = self:GetFovDistance(fovPosition)

	local insideFov = false
	if fovDistance then
		if fovSettings.Enabled then
			insideFov = fovDistance <= fovSettings.Radius
		else
			insideFov = true
		end
	end

	if not ignoreFov and not insideFov then
		return nil
	end

	local _, worldDistance = self:IsTargetInDistance(targetPart)

	local humanoid = self:GetHumanoid(character)
	local health = humanoid and humanoid.Health or math.huge

	return {
		Player = player,
		Character = character,
		Part = targetPart,

		Position = aimPosition,
		RawPosition = rawPosition,

		FovDistance = fovDistance or math.huge,
		WorldDistance = worldDistance or math.huge,
		InsideFov = insideFov,

		Health = health,
		Velocity = targetPart.AssemblyLinearVelocity,
	}
end

function AmphibiaAimbot:GetTargetScore(data)
	local selection = self.Config.AimbotSetting.Selection

	if not selection then
		return data.FovDistance
	end

	local mode = selection.Mode or "ClosestToCenter"

	if mode == "ClosestDistance" then
		return data.WorldDistance
	elseif mode == "LowestHealth" then
		return data.Health
	elseif mode == "Hybrid" then
		local fovWeight = selection.HybridFovWeight or 1
		local distanceWeight = selection.HybridDistanceWeight or 0.015
		local healthWeight = selection.HybridHealthWeight or 0

		return (data.FovDistance * fovWeight)
			+ (data.WorldDistance * distanceWeight)
			+ (data.Health * healthWeight)
	end

	return data.FovDistance
end

--// Last tracked point

function AmphibiaAimbot:SaveLastTrackedPoint(position, rawPosition, targetPart, sourcePlayer)
	if typeof(position) ~= "Vector3" then
		return
	end

	self.LastTrackedPosition = position
	self.LastTrackedRawPosition = rawPosition or position
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
	self.LastTrackedRawPosition = nil
	self.LastTrackedVelocity = Vector3.zero
	self.LastTrackedTime = 0
	self.LostTargetStartedAt = nil
	self.LostTargetSourcePlayer = nil
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

	local aimPosition, rawPosition = self:GetTargetPosition(character, targetPart)

	if not aimPosition or not rawPosition then
		return false
	end

	self:SaveLastTrackedPoint(aimPosition, rawPosition, targetPart, self.CurrentTargetPlayer)

	return true
end

--// Lost target

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
	self.CurrentTargetRawPosition = nil
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

	return self.LastTrackedPosition
end

--// Target selection

function AmphibiaAimbot:GetBestPlayerInFov()
	local bestData = nil
	local bestScore = math.huge

	for _, candidate in ipairs(self:GetCandidates()) do
		local player = candidate.Player

		if isPlayer(player) then
			local data = self:GetTargetData(player, {
				IgnoreFov = false,
				IgnoreAlive = false,
			})

			if data then
				local score = self:GetTargetScore(data)

				if score < bestScore then
					bestScore = score
					bestData = data
				end
			end
		end
	end

	return bestData
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
	self.CurrentTargetRawPosition = data.RawPosition
end

function AmphibiaAimbot:SelectTarget()
	local settings = self.Config.AimbotSetting
	local retarget = settings.Retarget
	local lost = settings.LostTarget

	if self:IsLostTargetActive() and lost and lost.PreferLastPointBeforeNewTarget then
		return
	end

	if self.CurrentTargetPlayer then
		self:CaptureCurrentTargetLastPoint()
	end

	local currentData = self:GetCurrentTargetData()

	if self.CurrentTargetPlayer and not currentData then
		self:EnterLostTargetState()
		return
	end

	if currentData and settings.LoseTargetOutsideFov == false then
		local bestData = self:GetBestPlayerInFov()

		if not retarget or not retarget.Enabled then
			self:SetCurrentTargetFromData(currentData)
			self:SaveLastTrackedPoint(currentData.Position, currentData.RawPosition, currentData.Part, currentData.Player)
			return
		end

		if bestData and bestData.Player ~= currentData.Player then
			local switchMargin = retarget.SwitchMargin or settings.SwitchMargin or 0

			if bestData.FovDistance + switchMargin < currentData.FovDistance then
				self:SetCurrentTargetFromData(bestData)
				self:SaveLastTrackedPoint(bestData.Position, bestData.RawPosition, bestData.Part, bestData.Player)
				return
			end
		end

		self:SetCurrentTargetFromData(currentData)
		self:SaveLastTrackedPoint(currentData.Position, currentData.RawPosition, currentData.Part, currentData.Player)
		return
	end

	local bestData = self:GetBestPlayerInFov()

	if not bestData then
		self:EnterLostTargetState()
		return
	end

	if not currentData then
		self:SetCurrentTargetFromData(bestData)
		self:SaveLastTrackedPoint(bestData.Position, bestData.RawPosition, bestData.Part, bestData.Player)
		return
	end

	if currentData.Player == bestData.Player then
		self:SetCurrentTargetFromData(currentData)
		self:SaveLastTrackedPoint(currentData.Position, currentData.RawPosition, currentData.Part, currentData.Player)
		return
	end

	if not retarget or not retarget.Enabled then
		self:SetCurrentTargetFromData(currentData)
		self:SaveLastTrackedPoint(currentData.Position, currentData.RawPosition, currentData.Part, currentData.Player)
		return
	end

	if settings.LoseTargetOutsideFov then
		local insideFov = self:IsWorldPositionInsideFov(currentData.RawPosition)

		if not insideFov then
			self:EnterLostTargetState()
			return
		end
	end

	local switchMargin = retarget.SwitchMargin or settings.SwitchMargin or 0

	if bestData.FovDistance + switchMargin < currentData.FovDistance then
		self:SetCurrentTargetFromData(bestData)
		self:SaveLastTrackedPoint(bestData.Position, bestData.RawPosition, bestData.Part, bestData.Player)
	else
		self:SetCurrentTargetFromData(currentData)
		self:SaveLastTrackedPoint(currentData.Position, currentData.RawPosition, currentData.Part, currentData.Player)
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

--// Mouse Override

function AmphibiaAimbot:UpdateMouseOverride(deltaTime)
	local override = self.Config.AimbotSetting.MouseOverride

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

	local manual = settings.ManualRetarget

	if manual and manual.Mode == "Soft" and self.ManualRetargetActive then
		baseStrength = math.clamp(manual.SoftAimStrength or 0.15, 0, 1)
	end

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
	local manual = self.Config.AimbotSetting.ManualRetarget

	if manualRetargetActive and manual and manual.Mode == "Release" then
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

		local manual = self.Config.AimbotSetting.ManualRetarget
		local ignoreTime = 0.05

		if manual and manual.EnableIgnoreTime ~= nil then
			ignoreTime = manual.EnableIgnoreTime
		end

		self.IgnoreManualRetargetUntil = os.clock() + ignoreTime
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

function AmphibiaAimbot:ForceReacquire()
	self:ClearTarget(true)
	self:RefreshCandidates(true)
	self:SelectTarget()
end

function AmphibiaAimbot:ClearTarget(clearLastTracked)
	self.CurrentTargetPlayer = nil
	self.CurrentTargetCharacter = nil
	self.CurrentTargetPart = nil
	self.CurrentTargetPosition = nil
	self.CurrentTargetRawPosition = nil
	self.SmoothedAimPosition = nil

	if clearLastTracked then
		self:ClearLastTracked()
	end
end

--// Config API

function AmphibiaAimbot:SetConfig(newConfig)
	self.Config = mergeConfig(self.Config, newConfig)
	self:NormalizeConfig()
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

function AmphibiaAimbot:SetLoseTargetOutsideFov(enabled)
	self.Config.AimbotSetting.LoseTargetOutsideFov = enabled == true
end

function AmphibiaAimbot:SetFovRadius(radius)
	self.Config.AimbotSetting.Fov.Radius = radius
end

function AmphibiaAimbot:SetFovEnabled(enabled)
	self.Config.AimbotSetting.Fov.Enabled = enabled == true
end

function AmphibiaAimbot:SetFovVisible(visible)
	self.Config.AimbotSetting.Fov.Visible = visible == true
end

function AmphibiaAimbot:SetFovColor(color)
	self.Config.AimbotSetting.Fov.Color = color
end

function AmphibiaAimbot:SetFovPosition(position)
	if position == "Center" or position == "Mouse" then
		self.Config.AimbotSetting.Fov.Position = position
	end
end

function AmphibiaAimbot:SetFovClamp(enabled)
	self.Config.AimbotSetting.Fov.ClampToScreen = enabled == true
end

function AmphibiaAimbot:SetFovRenderMode(mode)
	if mode == "Auto" or mode == "Circle" or mode == "ClampedLines" then
		self.Config.AimbotSetting.Fov.RenderMode = mode
	end
end

function AmphibiaAimbot:SetKeybind(config)
	local current = self.Config.AimbotSetting.Keybind or {}

	for key, value in pairs(config) do
		current[key] = value
	end

	self.Config.AimbotSetting.Keybind = current
end

function AmphibiaAimbot:SetRetarget(config)
	local current = self.Config.AimbotSetting.Retarget or {}

	for key, value in pairs(config) do
		current[key] = value
	end

	self.Config.AimbotSetting.Retarget = current
end

function AmphibiaAimbot:SetSelection(config)
	local current = self.Config.AimbotSetting.Selection or {}

	for key, value in pairs(config) do
		current[key] = value
	end

	self.Config.AimbotSetting.Selection = current
end

function AmphibiaAimbot:SetManualRetarget(config)
	local current = self.Config.AimbotSetting.ManualRetarget or {}

	for key, value in pairs(config) do
		current[key] = value
	end

	self.Config.AimbotSetting.ManualRetarget = current
end

function AmphibiaAimbot:SetWallCheck(configOrEnabled)
	if typeof(configOrEnabled) == "boolean" then
		self.Config.AimbotSetting.WallCheck.Enabled = configOrEnabled
	else
		local current = self.Config.AimbotSetting.WallCheck or {}

		for key, value in pairs(configOrEnabled) do
			current[key] = value
		end

		self.Config.AimbotSetting.WallCheck = current
	end

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
	print("CurrentTarget:", self.CurrentTargetPlayer and self.CurrentTargetPlayer.Name)

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
			local aimPos, rawPos = self:GetTargetPosition(character, part)

			local inDistance, distance = self:IsTargetInDistance(part)
			print("Distance:", distance, "InDistance:", inDistance)

			local insideFov, fovDistance = self:IsWorldPositionInsideFov(rawPos)
			print("FovDistance:", fovDistance, "InsideFov:", insideFov)

			print("Visible:", self:IsVisible(character, part, rawPos))
			print("AimPos:", aimPos)
			print("RawPos:", rawPos)
		end

		print("TeamAllowed:", self:IsTeamAllowed(player))
		print("Valid acquisition:", self:IsValidPlayerTarget(player, { IgnoreFov = false }))
		print("Valid lock:", self:IsValidPlayerTarget(player, { IgnoreFov = true }))
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
	self:BindInputs()

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
	self:UnbindInputs()

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
