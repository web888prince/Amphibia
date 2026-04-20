local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.__index = ESP

local VALID_SNAPLINE_MODES = {
	Bottom = true,
	Center = true,
	Top = true,
	Mouse = true,
}

local DEFAULT_CONFIG = {
	Enabled = true,

	Checks = {
		Team = true,
		Visible = false,
		MaxDistance = math.huge,
	},

	Features = {
		Box = true,
		BoxOutline = true,
		Fill = true,
		HealthBar = true,
		Tracer = true,
		Name = true,
		Info = true,
		Tool = true,
		Arrows = true,
		Skeleton = true,
		Chams = false,
	},

	Colors = {
		Box = Color3.fromRGB(255, 255, 255),
		Fill = Color3.fromRGB(255, 255, 255),
		Outline = Color3.fromRGB(0, 0, 0),

		Tracer = Color3.fromRGB(255, 255, 255),
		TracerOutline = Color3.fromRGB(0, 0, 0),

		Text = Color3.fromRGB(255, 255, 255),

		Arrow = Color3.fromRGB(255, 255, 255),
		ArrowOutline = Color3.fromRGB(0, 0, 0),

		Skeleton = Color3.fromRGB(255, 255, 255),

		Chams = Color3.fromRGB(255, 255, 255),
	},

	Thickness = {
		Box = 2,
		Outline = 4,
		Tracer = 2,
		Skeleton = 2,
		Arrow = 2,
		ArrowOutline = 5,
	},

	Transparency = {
		Fill = 0.08,
		Text = 1,
		HealthBar = 1,
		Tracer = 1,
		Arrow = 1,
		Skeleton = 1,
		ChamsFill = 0.8,
		ChamsOutline = 0.15,
	},

	Text = {
		Size = 13,
	},

	Sizing = {
		PaddingX = 14,
		PaddingY = 10,
		MinBoxWidth = 30,
		MinBoxHeight = 44,

		ArrowSize = 20,
		ArrowRadius = 175,
	},

	Snapline = {
		Mode = "Bottom",
	},

	Throttle = {
		Visibility = 0.12,
		Info = 0.08,
		Tool = 0.15,
		Skeleton = 0,
		Chams = 0.10,
	},
}

local R6_POINTS = {
	"Head",
	"Torso",
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg",
}

local R15_POINTS = {
	"Head",
	"UpperTorso",
	"LowerTorso",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot",
}

local R6_SKELETON = {
	{"Head", "Torso"},
	{"Torso", "Left Arm"},
	{"Torso", "Right Arm"},
	{"Torso", "Left Leg"},
	{"Torso", "Right Leg"},
}

local R15_SKELETON = {
	{"Head", "UpperTorso"},
	{"UpperTorso", "LowerTorso"},
	{"UpperTorso", "LeftUpperArm"},
	{"LeftUpperArm", "LeftLowerArm"},
	{"LeftLowerArm", "LeftHand"},
	{"UpperTorso", "RightUpperArm"},
	{"RightUpperArm", "RightLowerArm"},
	{"RightLowerArm", "RightHand"},
	{"LowerTorso", "LeftUpperLeg"},
	{"LeftUpperLeg", "LeftLowerLeg"},
	{"LeftLowerLeg", "LeftFoot"},
	{"LowerTorso", "RightUpperLeg"},
	{"RightUpperLeg", "RightLowerLeg"},
	{"RightLowerLeg", "RightFoot"},
}

local function deepCopy(value)
	if type(value) ~= "table" then
		return value
	end

	local result = {}
	for k, v in pairs(value) do
		result[k] = deepCopy(v)
	end
	return result
end

local function deepMerge(target, patch)
	for k, v in pairs(patch) do
		if type(v) == "table" and type(target[k]) == "table" then
			deepMerge(target[k], v)
		else
			target[k] = deepCopy(v)
		end
	end
	return target
end

local function splitPath(path)
	local result = {}
	for part in string.gmatch(path, "[^%.]+") do
		table.insert(result, part)
	end
	return result
end

local function getByPath(tbl, path)
	local current = tbl
	for _, key in ipairs(splitPath(path)) do
		if type(current) ~= "table" then
			return nil
		end
		current = current[key]
		if current == nil then
			return nil
		end
	end
	return current
end

local function setByPath(tbl, path, value)
	local parts = splitPath(path)
	local current = tbl

	for i = 1, #parts - 1 do
		local key = parts[i]
		if type(current[key]) ~= "table" then
			current[key] = {}
		end
		current = current[key]
	end

	current[parts[#parts]] = value
end

local function normalizeBooleanLike(value)
	if type(value) == "boolean" then
		return value
	end

	if type(value) ~= "string" then
		return nil
	end

	local lowered = string.lower(value)

	if lowered == "enabled" or lowered == "e" or lowered == "true" then
		return true
	end

	if lowered == "disabled" or lowered == "d" or lowered == "false" then
		return false
	end

	return nil
end

local function normalizeBooleanLikeDeep(value)
	local normalized = normalizeBooleanLike(value)
	if normalized ~= nil then
		return normalized
	end

	if type(value) ~= "table" then
		return value
	end

	local result = {}
	for k, v in pairs(value) do
		result[k] = normalizeBooleanLikeDeep(v)
	end
	return result
end

local function createLine(z)
	local obj = Drawing.new("Line")
	obj.Visible = false
	obj.ZIndex = z or 1
	return obj
end

local function createSquare(z, filled)
	local obj = Drawing.new("Square")
	obj.Visible = false
	obj.Filled = filled or false
	obj.ZIndex = z or 1
	return obj
end

local function createText(z)
	local obj = Drawing.new("Text")
	obj.Visible = false
	obj.Center = true
	obj.Outline = false
	obj.ZIndex = z or 1
	return obj
end

local function safeRemove(obj)
	if obj then
		pcall(function()
			obj:Remove()
		end)
	end
end

local function hideLines(lines)
	for _, line in ipairs(lines) do
		line.Visible = false
	end
end

local function removeLines(lines)
	for _, line in ipairs(lines) do
		safeRemove(line)
	end
end

local function hideArrow(arrow)
	for _, line in ipairs(arrow.Outline) do
		line.Visible = false
	end
	for _, line in ipairs(arrow.Main) do
		line.Visible = false
	end
end

local function healthToColor(percent)
	percent = math.clamp(percent, 0, 1)
	return Color3.fromRGB(
		math.floor(255 * (1 - percent)),
		math.floor(255 * percent),
		0
	)
end

local function isPointInsideViewport(vp, viewport)
	return vp.Z > 0
		and vp.X >= 0
		and vp.X <= viewport.X
		and vp.Y >= 0
		and vp.Y <= viewport.Y
end

function ESP.new(config)
	local self = setmetatable({}, ESP)

	self.Config = deepCopy(DEFAULT_CONFIG)
	if type(config) == "table" then
		deepMerge(self.Config, normalizeBooleanLikeDeep(config))
	end

	self._entries = {}
	self._connections = {}
	self._started = false
	self._drawingAvailable = not not (Drawing and Drawing.new)

	return self
end

function ESP:GetConfig()
	return deepCopy(self.Config)
end

function ESP:Get(path)
	if not path then
		return self:GetConfig()
	end

	local value = getByPath(self.Config, path)
	return deepCopy(value)
end

function ESP:Set(path, value)
	if type(path) ~= "string" then
		return self
	end

	local normalized = normalizeBooleanLike(value)
	if normalized ~= nil then
		value = normalized
	end

	if path == "Snapline.Mode" and not VALID_SNAPLINE_MODES[value] then
		warn("[ESP] Invalid Snapline.Mode:", value)
		return self
	end

	setByPath(self.Config, path, value)
	return self
end

function ESP:UpdateConfig(patch)
	if type(patch) ~= "table" then
		return self
	end

	patch = normalizeBooleanLikeDeep(patch)

	if patch.Snapline and patch.Snapline.Mode and not VALID_SNAPLINE_MODES[patch.Snapline.Mode] then
		warn("[ESP] Invalid Snapline.Mode:", patch.Snapline.Mode)
		patch = deepCopy(patch)
		patch.Snapline.Mode = nil
	end

	deepMerge(self.Config, patch)
	return self
end

function ESP:SetEnabled(enabled)
	local normalized = normalizeBooleanLike(enabled)
	self.Config.Enabled = normalized ~= nil and normalized or (enabled and true or false)

	if not self.Config.Enabled then
		for _, entry in pairs(self._entries) do
			self:_hideEntry(entry)
		end
	end

	return self
end

function ESP:SetFeature(name, value)
	if type(name) ~= "string" then
		return self
	end

	local normalized = normalizeBooleanLike(value)
	self.Config.Features[name] = normalized ~= nil and normalized or (value and true or false)
	return self
end

function ESP:SetColor(name, color)
	if type(name) ~= "string" then
		return self
	end

	self.Config.Colors[name] = color
	return self
end

function ESP:SetThrottle(name, value)
	if type(name) ~= "string" then
		return self
	end

	self.Config.Throttle[name] = tonumber(value) or 0
	return self
end

function ESP:SetSnaplineMode(mode)
	if not VALID_SNAPLINE_MODES[mode] then
		warn("[ESP] Invalid snapline mode:", mode)
		return self
	end

	self.Config.Snapline.Mode = mode
	return self
end

function ESP:_connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(self._connections, connection)
	return connection
end

function ESP:_disconnectAll()
	for _, connection in ipairs(self._connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	table.clear(self._connections)
end

function ESP:_getCamera()
	return Workspace.CurrentCamera
end

function ESP:_isTeammate(player)
	if not self.Config.Checks.Team then
		return false
	end

	if not LocalPlayer.Team or not player.Team then
		return false
	end

	local localNeutral = false
	local targetNeutral = false

	pcall(function()
		localNeutral = LocalPlayer.Neutral
	end)

	pcall(function()
		targetNeutral = player.Neutral
	end)

	if localNeutral or targetNeutral then
		return false
	end

	return LocalPlayer.Team == player.Team
end

function ESP:_isVisible(character, position, camera)
	if not self.Config.Checks.Visible then
		return true
	end

	if not camera then
		return false
	end

	local params = RaycastParams.new()
	params.IgnoreWater = true
	params.FilterDescendantsInstances = {LocalPlayer.Character}

	pcall(function()
		params.FilterType = Enum.RaycastFilterType.Exclude
	end)

	local origin = camera.CFrame.Position
	local direction = position - origin

	local ok, result = pcall(function()
		return Workspace:Raycast(origin, direction, params)
	end)

	if not ok then
		return true
	end

	if not result then
		return true
	end

	return result.Instance and result.Instance:IsDescendantOf(character)
end

function ESP:_getCharacterData(player)
	local character = player.Character
	if not character then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	local head = character:FindFirstChild("Head")

	if not humanoid or not root or not head or humanoid.Health <= 0 then
		return nil
	end

	return character, humanoid, root, head
end

function ESP:_getRigPointNames(character)
	if character:FindFirstChild("UpperTorso") then
		return R15_POINTS
	end
	return R6_POINTS
end

function ESP:_getSkeletonConnections(character)
	if character:FindFirstChild("UpperTorso") then
		return R15_SKELETON
	end
	return R6_SKELETON
end

function ESP:_getToolName(character)
	local tool = character:FindFirstChildOfClass("Tool")
	return tool and tool.Name or nil
end

function ESP:_worldToScreen(camera, position)
	local vp, onScreen = camera:WorldToViewportPoint(position)
	return Vector2.new(vp.X, vp.Y), onScreen, vp.Z
end

function ESP:_getBoxFromBodyParts(camera, character)
	local pointNames = self:_getRigPointNames(character)

	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local anyFront = false
	local anyOnScreen = false

	for _, name in ipairs(pointNames) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			local screenPos, onScreen, z = self:_worldToScreen(camera, part.Position)

			if z > 0 then
				anyFront = true
				if onScreen then
					anyOnScreen = true
				end

				if screenPos.X < minX then minX = screenPos.X end
				if screenPos.Y < minY then minY = screenPos.Y end
				if screenPos.X > maxX then maxX = screenPos.X end
				if screenPos.Y > maxY then maxY = screenPos.Y end
			end
		end
	end

	if not anyFront then
		return nil
	end

	minX -= self.Config.Sizing.PaddingX
	minY -= self.Config.Sizing.PaddingY
	maxX += self.Config.Sizing.PaddingX
	maxY += self.Config.Sizing.PaddingY

	local width = maxX - minX
	local height = maxY - minY

	if width < self.Config.Sizing.MinBoxWidth then
		local add = (self.Config.Sizing.MinBoxWidth - width) * 0.5
		minX -= add
		maxX += add
		width = self.Config.Sizing.MinBoxWidth
	end

	if height < self.Config.Sizing.MinBoxHeight then
		local add = (self.Config.Sizing.MinBoxHeight - height) * 0.5
		minY -= add
		maxY += add
		height = self.Config.Sizing.MinBoxHeight
	end

	return {
		X = minX,
		Y = minY,
		Width = width,
		Height = height,
		CenterX = minX + width * 0.5,
		OnScreen = anyOnScreen,
	}
end

function ESP:_getSnaplineOrigin(camera)
	local viewport = camera.ViewportSize
	local mode = self.Config.Snapline.Mode

	if mode == "Top" then
		return Vector2.new(viewport.X * 0.5, 2)
	elseif mode == "Center" then
		return Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
	elseif mode == "Mouse" then
		local mousePos = UserInputService:GetMouseLocation()
		return Vector2.new(mousePos.X, mousePos.Y)
	else
		return Vector2.new(viewport.X * 0.5, viewport.Y - 2)
	end
end

function ESP:_updateArrowLine(line, fromPos, toPos, color, thickness)
	line.From = fromPos
	line.To = toPos
	line.Color = color
	line.Thickness = thickness
	line.Transparency = self.Config.Transparency.Arrow
	line.Visible = true
end

function ESP:_updateArrow(camera, arrow, worldPosition)
	local viewport = camera.ViewportSize
	local center = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)

	local vp = camera:WorldToViewportPoint(worldPosition)
	local dir = Vector2.new(vp.X - center.X, vp.Y - center.Y)

	if vp.Z <= 0 then
		dir = -dir
	end

	if dir.Magnitude < 0.001 then
		dir = Vector2.new(0, -1)
	else
		dir = dir.Unit
	end

	local base = center + dir * self.Config.Sizing.ArrowRadius
	local angle = math.atan2(dir.Y, dir.X)
	local size = self.Config.Sizing.ArrowSize

	local tip = base + dir * size
	local left = base + Vector2.new(
		math.cos(angle + math.rad(140)),
		math.sin(angle + math.rad(140))
	) * size
	local right = base + Vector2.new(
		math.cos(angle - math.rad(140)),
		math.sin(angle - math.rad(140))
	) * size

	self:_updateArrowLine(arrow.Outline[1], tip, left, self.Config.Colors.ArrowOutline, self.Config.Thickness.ArrowOutline)
	self:_updateArrowLine(arrow.Outline[2], tip, right, self.Config.Colors.ArrowOutline, self.Config.Thickness.ArrowOutline)
	self:_updateArrowLine(arrow.Outline[3], left, right, self.Config.Colors.ArrowOutline, self.Config.Thickness.ArrowOutline)

	self:_updateArrowLine(arrow.Main[1], tip, left, self.Config.Colors.Arrow, self.Config.Thickness.Arrow)
	self:_updateArrowLine(arrow.Main[2], tip, right, self.Config.Colors.Arrow, self.Config.Thickness.Arrow)
	self:_updateArrowLine(arrow.Main[3], left, right, self.Config.Colors.Arrow, self.Config.Thickness.Arrow)
end

function ESP:_hideEntry(entry)
	entry.Box.Visible = false
	entry.BoxOutline.Visible = false
	entry.Fill.Visible = false
	entry.HealthBar.Visible = false
	entry.HealthBarOutline.Visible = false
	entry.Tracer.Visible = false
	entry.TracerOutline.Visible = false
	entry.Name.Visible = false
	entry.Info.Visible = false
	entry.Tool.Visible = false

	hideLines(entry.Skeleton)
	hideArrow(entry.Arrows)

	if entry.Chams then
		entry.Chams.Enabled = false
		entry.Chams.Adornee = nil
	end
end

function ESP:_removeEntry(player)
	local entry = self._entries[player]
	if not entry then
		return
	end

	safeRemove(entry.Box)
	safeRemove(entry.BoxOutline)
	safeRemove(entry.Fill)
	safeRemove(entry.HealthBar)
	safeRemove(entry.HealthBarOutline)
	safeRemove(entry.Tracer)
	safeRemove(entry.TracerOutline)
	safeRemove(entry.Name)
	safeRemove(entry.Info)
	safeRemove(entry.Tool)

	removeLines(entry.Skeleton)
	removeLines(entry.Arrows.Outline)
	removeLines(entry.Arrows.Main)

	if entry.Chams then
		pcall(function()
			entry.Chams:Destroy()
		end)
	end

	self._entries[player] = nil
end

function ESP:_createEntry(player)
	if player == LocalPlayer or self._entries[player] then
		return
	end

	local skeletonLines = {}
	for i = 1, #R15_SKELETON do
		skeletonLines[i] = createLine(4)
	end

	local arrows = {
		Outline = {
			createLine(4),
			createLine(4),
			createLine(4),
		},
		Main = {
			createLine(5),
			createLine(5),
			createLine(5),
		}
	}

	local chams = Instance.new("Highlight")
	chams.Name = "ESPHighlight"
	chams.Enabled = false
	chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	chams.FillColor = self.Config.Colors.Chams
	chams.OutlineColor = self.Config.Colors.Chams
	chams.FillTransparency = self.Config.Transparency.ChamsFill
	chams.OutlineTransparency = self.Config.Transparency.ChamsOutline
	chams.Parent = Workspace

	self._entries[player] = {
		BoxOutline = createSquare(1, false),
		Box = createSquare(3, false),
		Fill = createSquare(2, true),

		HealthBarOutline = createSquare(1, true),
		HealthBar = createSquare(2, true),

		TracerOutline = createLine(1),
		Tracer = createLine(2),

		Name = createText(6),
		Info = createText(6),
		Tool = createText(6),

		Skeleton = skeletonLines,
		Arrows = arrows,
		Chams = chams,

		Cache = {
			Visible = true,
			Distance = 0,
			ToolName = nil,
			InfoText = "",
			LastVisibility = 0,
			LastInfo = 0,
			LastTool = 0,
			LastSkeleton = 0,
			LastChams = 0,
		}
	}
end

function ESP:_updateSkeleton(camera, entry, character, now)
	if not self.Config.Features.Skeleton then
		hideLines(entry.Skeleton)
		return
	end

	local throttle = self.Config.Throttle.Skeleton or 0
	if throttle > 0 and now - entry.Cache.LastSkeleton < throttle then
		return
	end

	entry.Cache.LastSkeleton = now

	local connections = self:_getSkeletonConnections(character)

	for i = 1, #entry.Skeleton do
		local line = entry.Skeleton[i]
		local pair = connections[i]

		if not pair then
			line.Visible = false
		else
			local p1 = character:FindFirstChild(pair[1])
			local p2 = character:FindFirstChild(pair[2])

			if p1 and p2 then
				local s1, on1, z1 = self:_worldToScreen(camera, p1.Position)
				local s2, on2, z2 = self:_worldToScreen(camera, p2.Position)

				if on1 and on2 and z1 > 0 and z2 > 0 then
					line.From = s1
					line.To = s2
					line.Color = self.Config.Colors.Skeleton
					line.Thickness = self.Config.Thickness.Skeleton
					line.Transparency = self.Config.Transparency.Skeleton
					line.Visible = true
				else
					line.Visible = false
				end
			else
				line.Visible = false
			end
		end
	end
end

function ESP:_updatePlayer(player, entry)
	if not self.Config.Enabled then
		self:_hideEntry(entry)
		return
	end

	if self:_isTeammate(player) then
		self:_hideEntry(entry)
		return
	end

	local character, humanoid, root, head = self:_getCharacterData(player)
	if not character then
		self:_hideEntry(entry)
		return
	end

	local camera = self:_getCamera()
	if not camera then
		self:_hideEntry(entry)
		return
	end

	local now = os.clock()

	entry.Cache.Distance = (camera.CFrame.Position - root.Position).Magnitude
	if entry.Cache.Distance > self.Config.Checks.MaxDistance then
		self:_hideEntry(entry)
		return
	end

	if self.Config.Checks.Visible then
		if now - entry.Cache.LastVisibility >= (self.Config.Throttle.Visibility or 0) then
			entry.Cache.LastVisibility = now
			entry.Cache.Visible = self:_isVisible(character, head.Position, camera)
		end

		if not entry.Cache.Visible then
			self:_hideEntry(entry)
			return
		end
	else
		entry.Cache.Visible = true
	end

	if now - entry.Cache.LastInfo >= (self.Config.Throttle.Info or 0) then
		entry.Cache.LastInfo = now
		entry.Cache.InfoText = string.format("%d HP | %d studs", math.floor(humanoid.Health), math.floor(entry.Cache.Distance))
	end

	if now - entry.Cache.LastTool >= (self.Config.Throttle.Tool or 0) then
		entry.Cache.LastTool = now
		entry.Cache.ToolName = self:_getToolName(character)
	end

	self:_updateSkeleton(camera, entry, character, now)

	if self.Config.Features.Chams then
		if now - entry.Cache.LastChams >= (self.Config.Throttle.Chams or 0) then
			entry.Cache.LastChams = now
			entry.Chams.FillColor = self.Config.Colors.Chams
			entry.Chams.OutlineColor = self.Config.Colors.Chams
			entry.Chams.FillTransparency = self.Config.Transparency.ChamsFill
			entry.Chams.OutlineTransparency = self.Config.Transparency.ChamsOutline
			entry.Chams.Adornee = character
			entry.Chams.Enabled = true
		end
	else
		entry.Chams.Enabled = false
		entry.Chams.Adornee = nil
	end

	local bounds = self:_getBoxFromBodyParts(camera, character)
	local rootViewport = camera:WorldToViewportPoint(root.Position)
	local shouldShowArrow = self.Config.Features.Arrows and not isPointInsideViewport(rootViewport, camera.ViewportSize)

	if bounds and bounds.OnScreen then
		hideArrow(entry.Arrows)

		local x = bounds.X
		local y = bounds.Y
		local width = bounds.Width
		local height = bounds.Height
		local centerX = bounds.CenterX

		if self.Config.Features.BoxOutline then
			entry.BoxOutline.Size = Vector2.new(width, height)
			entry.BoxOutline.Position = Vector2.new(x, y)
			entry.BoxOutline.Color = self.Config.Colors.Outline
			entry.BoxOutline.Thickness = self.Config.Thickness.Outline
			entry.BoxOutline.Visible = true
		else
			entry.BoxOutline.Visible = false
		end

		if self.Config.Features.Fill then
			entry.Fill.Size = Vector2.new(width, height)
			entry.Fill.Position = Vector2.new(x, y)
			entry.Fill.Color = self.Config.Colors.Fill
			entry.Fill.Transparency = self.Config.Transparency.Fill
			entry.Fill.Visible = true
		else
			entry.Fill.Visible = false
		end

		if self.Config.Features.Box then
			entry.Box.Size = Vector2.new(width, height)
			entry.Box.Position = Vector2.new(x, y)
			entry.Box.Color = self.Config.Colors.Box
			entry.Box.Thickness = self.Config.Thickness.Box
			entry.Box.Visible = true
		else
			entry.Box.Visible = false
		end

		if self.Config.Features.HealthBar then
			local barWidth = 3
			local barHeight = math.floor(height)
			local barX = x - 6
			local barY = y
			local hp = humanoid.Health / math.max(humanoid.MaxHealth, 1)
			local currentHeight = math.clamp(math.floor(barHeight * hp), 0, barHeight)

			entry.HealthBarOutline.Size = Vector2.new(barWidth + 2, barHeight + 2)
			entry.HealthBarOutline.Position = Vector2.new(barX - 1, barY - 1)
			entry.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
			entry.HealthBarOutline.Visible = true

			entry.HealthBar.Size = Vector2.new(barWidth, currentHeight)
			entry.HealthBar.Position = Vector2.new(barX, barY + (barHeight - currentHeight))
			entry.HealthBar.Color = healthToColor(hp)
			entry.HealthBar.Transparency = self.Config.Transparency.HealthBar
			entry.HealthBar.Visible = currentHeight > 0
		else
			entry.HealthBar.Visible = false
			entry.HealthBarOutline.Visible = false
		end

		if self.Config.Features.Tracer then
			local from = self:_getSnaplineOrigin(camera)
			local to = Vector2.new(centerX, y + height)

			entry.TracerOutline.From = from
			entry.TracerOutline.To = to
			entry.TracerOutline.Color = self.Config.Colors.TracerOutline
			entry.TracerOutline.Thickness = self.Config.Thickness.Tracer + 2
			entry.TracerOutline.Transparency = self.Config.Transparency.Tracer
			entry.TracerOutline.Visible = true

			entry.Tracer.From = from
			entry.Tracer.To = to
			entry.Tracer.Color = self.Config.Colors.Tracer
			entry.Tracer.Thickness = self.Config.Thickness.Tracer
			entry.Tracer.Transparency = self.Config.Transparency.Tracer
			entry.Tracer.Visible = true
		else
			entry.Tracer.Visible = false
			entry.TracerOutline.Visible = false
		end

		if self.Config.Features.Name then
			entry.Name.Text = player.Name
			entry.Name.Size = self.Config.Text.Size
			entry.Name.Color = self.Config.Colors.Text
			entry.Name.Transparency = self.Config.Transparency.Text
			entry.Name.Position = Vector2.new(centerX, y - 16)
			entry.Name.Visible = true
		else
			entry.Name.Visible = false
		end

		if self.Config.Features.Info then
			entry.Info.Text = entry.Cache.InfoText
			entry.Info.Size = self.Config.Text.Size
			entry.Info.Color = self.Config.Colors.Text
			entry.Info.Transparency = self.Config.Transparency.Text
			entry.Info.Position = Vector2.new(centerX, y + height + 2)
			entry.Info.Visible = true
		else
			entry.Info.Visible = false
		end

		if self.Config.Features.Tool and entry.Cache.ToolName then
			entry.Tool.Text = entry.Cache.ToolName
			entry.Tool.Size = self.Config.Text.Size
			entry.Tool.Color = self.Config.Colors.Text
			entry.Tool.Transparency = self.Config.Transparency.Text
			entry.Tool.Position = Vector2.new(centerX, y + height + 18)
			entry.Tool.Visible = true
		else
			entry.Tool.Visible = false
		end
	else
		entry.Box.Visible = false
		entry.BoxOutline.Visible = false
		entry.Fill.Visible = false
		entry.HealthBar.Visible = false
		entry.HealthBarOutline.Visible = false
		entry.Tracer.Visible = false
		entry.TracerOutline.Visible = false
		entry.Name.Visible = false
		entry.Info.Visible = false
		entry.Tool.Visible = false
		hideLines(entry.Skeleton)

		if shouldShowArrow then
			self:_updateArrow(camera, entry.Arrows, root.Position)
		else
			hideArrow(entry.Arrows)
		end
	end
end

function ESP:_onRenderStep()
	for player, entry in pairs(self._entries) do
		if player.Parent ~= Players then
			self:_removeEntry(player)
		else
			local ok, err = pcall(function()
				self:_updatePlayer(player, entry)
			end)

			if not ok then
				warn("[ESP] Update error for", player.Name, err)
				self:_hideEntry(entry)
			end
		end
	end
end

function ESP:Start()
	if self._started then
		return self
	end

	if not self._drawingAvailable then
		warn("[ESP] Drawing API not found")
		return self
	end

	self._started = true

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			self:_createEntry(player)
		end
	end

	self:_connect(Players.PlayerAdded, function(player)
		if player ~= LocalPlayer then
			self:_createEntry(player)
		end
	end)

	self:_connect(Players.PlayerRemoving, function(player)
		self:_removeEntry(player)
	end)

	self:_connect(RunService.RenderStepped, function()
		self:_onRenderStep()
	end)

	return self
end

function ESP:Stop()
	if not self._started then
		return self
	end

	self._started = false
	self:_disconnectAll()

	for _, entry in pairs(self._entries) do
		self:_hideEntry(entry)
	end

	return self
end

function ESP:Destroy()
	self:Stop()

	for player in pairs(self._entries) do
		self:_removeEntry(player)
	end

	table.clear(self._entries)
	return nil
end

return ESP
