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

		Smoothness = 0.12,

		MaxDistance = 1000,
		MinDistance = 0.1,

		FovColor = Color3.fromRGB(255, 255, 255),
		FovRadius = 120,
		FovVisible = true,
		FovPosition = "Center", -- "Center" / "Mouse"

		LockMode = "Hold", -- "Hold" / "Toggle" / "Always" / "Manual"
		LockKey = Enum.KeyCode.E,

		RequireAlive = true,
		RequireCharacterInWorkspace = true,

		TeamCheck = false,
		TargetSameTeam = false,

		UseScriptableCamera = true,

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

	local ok = pcall(function()
		object:Remove()
	end)

	if not ok then
		pcall(function()
			object:Destroy()
		end)
	end
end

--// Constructor

function AmphibiaAimbot.new(config)
	local self = setmetatable({}, AmphibiaAimbot)

	self.Config = mergeConfig(DEFAULT_CONFIG, config)

	self.Player = Players.LocalPlayer
	self.Camera = Workspace.CurrentCamera

	self.Started = false
	self.Enabled = self.Config.AimbotSetting.Enabled

	self.CurrentTargetPlayer = nil
	self.CurrentTargetCharacter = nil
	self.CurrentTargetPart = nil

	self.FovCircle = nil
	self.FovConnection = nil

	self.InputBeganConnection = nil
	self.InputEndedConnection = nil

	self.OldCameraType = nil
	self.OldCameraSubject = nil

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
	if not self.Player then
		return nil
	end

	return self.Player.Character
end

function AmphibiaAimbot:GetLocalRoot()
	local character = self:GetLocalCharacter()

	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

--// Player Target Helpers

function AmphibiaAimbot:IsCharacterInWorkspace(character)
	if not character then
		return false
	end

	if not self.Config.AimbotSetting.RequireCharacterInWorkspace then
		return true
	end

	return character:IsDescendantOf(Workspace)
end

function AmphibiaAimbot:GetPlayerCharacter(player)
	if not player then
		return nil
	end

	local character = player.Character

	if not character then
		return nil
	end

	if not self:IsCharacterInWorkspace(character) then
		return nil
	end

	return character
end

function AmphibiaAimbot:GetHumanoid(character)
	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
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
	if not character then
		return nil
	end

	local partName = self.Config.AimbotSetting.TargetingPart
	local part = character:FindFirstChild(partName)

	if part and part:IsA("BasePart") then
		return part
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if root and root:IsA("BasePart") then
		return root
	end

	return nil
end

function AmphibiaAimbot:IsTeamAllowed(targetPlayer)
	if not self.Config.AimbotSetting.TeamCheck then
		return true
	end

	if not self.Player or not targetPlayer then
		return false
	end

	if self.Config.AimbotSetting.TargetSameTeam then
		return self.Player.Team == targetPlayer.Team
	end

	return self.Player.Team ~= targetPlayer.Team
end

function AmphibiaAimbot:IsTargetInDistance(targetPart)
	local localRoot = self:GetLocalRoot()

	if not localRoot or not targetPart then
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

function AmphibiaAimbot:IsValidPlayerTarget(player)
	if not player then
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

--// Target Selection

function AmphibiaAimbot:GetPlayerTargets()
	local targets = {}

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= self.Player then
			local character = self:GetPlayerCharacter(player)

			if character then
				table.insert(targets, player)
			end
		end
	end

	return targets
end

function AmphibiaAimbot:GetClosestPlayerInFov()
	local closestPlayer = nil
	local closestCharacter = nil
	local closestPart = nil
	local closestFovDistance = math.huge

	for _, player in ipairs(self:GetPlayerTargets()) do
		if self:IsValidPlayerTarget(player) then
			local character = self:GetPlayerCharacter(player)
			local targetPart = self:GetTargetPartFromCharacter(character)

			if targetPart then
				local insideFov, fovDistance = self:IsWorldPositionInsideFov(targetPart.Position)

				if insideFov and fovDistance and fovDistance < closestFovDistance then
					closestFovDistance = fovDistance
					closestPlayer = player
					closestCharacter = character
					closestPart = targetPart
				end
			end
		end
	end

	return closestPlayer, closestCharacter, closestPart, closestFovDistance
end

--// Aim Logic

function AmphibiaAimbot:GetAimCFrame(targetPart)
	if not self.Camera or not targetPart then
		return nil
	end

	local cameraPosition = self.Camera.CFrame.Position
	local targetPosition = targetPart.Position

	return CFrame.lookAt(cameraPosition, targetPosition)
end

function AmphibiaAimbot:AimAt(targetPart, deltaTime)
	if not targetPart then
		return
	end

	local targetCFrame = self:GetAimCFrame(targetPart)

	if not targetCFrame then
		return
	end

	local smoothness = self.Config.AimbotSetting.Smoothness

	if smoothness and smoothness > 0 then
		local alpha = math.clamp(deltaTime / smoothness, 0, 1)
		self.Camera.CFrame = self.Camera.CFrame:Lerp(targetCFrame, alpha)
	else
		self.Camera.CFrame = targetCFrame
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

	if not self.CurrentTargetPlayer or not self:IsValidPlayerTarget(self.CurrentTargetPlayer) then
		local player, character, part = self:GetClosestPlayerInFov()

		self.CurrentTargetPlayer = player
		self.CurrentTargetCharacter = character
		self.CurrentTargetPart = part
	end

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

	if self.Enabled then
		self.Camera = Workspace.CurrentCamera

		if self.Config.AimbotSetting.UseScriptableCamera and self.Camera then
			self.OldCameraType = self.Camera.CameraType
			self.OldCameraSubject = self.Camera.CameraSubject

			self.Camera.CameraType = Enum.CameraType.Scriptable
		end

		local player, character, part = self:GetClosestPlayerInFov()

		self.CurrentTargetPlayer = player
		self.CurrentTargetCharacter = character
		self.CurrentTargetPart = part
	else
		self.CurrentTargetPlayer = nil
		self.CurrentTargetCharacter = nil
		self.CurrentTargetPart = nil

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

--// Lifecycle

function AmphibiaAimbot:Start()
	if self.Started then
		return
	end

	self.Started = true
	self.Camera = Workspace.CurrentCamera

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

	self.InputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		local settings = self.Config.AimbotSetting

		if input.KeyCode ~= settings.LockKey then
			return
		end

		if settings.LockMode == "Toggle" then
			self:Toggle()
		elseif settings.LockMode == "Hold" then
			self:SetEnabled(true)
		end
	end)

	self.InputEndedConnection = UserInputService.InputEnded:Connect(function(input)
		local settings = self.Config.AimbotSetting

		if input.KeyCode ~= settings.LockKey then
			return
		end

		if settings.LockMode == "Hold" then
			self:SetEnabled(false)
		end
	end)

	if self.Config.AimbotSetting.LockMode == "Always" then
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

	if self.InputBeganConnection then
		self.InputBeganConnection:Disconnect()
		self.InputBeganConnection = nil
	end

	if self.InputEndedConnection then
		self.InputEndedConnection:Disconnect()
		self.InputEndedConnection = nil
	end

	self:SetEnabled(false)
	self:RemoveFov()

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
