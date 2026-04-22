--// Amphibia Opponent Info Library
--// One-file ModuleScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local OpponentInfo = {}
OpponentInfo.__index = OpponentInfo

local REQUEST_FUNCTION =
	request
	or http_request
	or (syn and syn.request)
	or (fluxus and fluxus.request)
	or (http and http.request)

local GET_ASSET_FUNCTION =
	getcustomasset
	or getsynasset

local DEFAULT_CONFIG = {
	Parent = nil,
	Visible = true,
	UpdateInterval = 0.06,
	AutoDetect = false,

	Window = {
		Size = UDim2.new(0, 432, 0, 320),
		Position = UDim2.new(0.5, -216, 0.16, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Title = "Opponent information",
	},

	Tracking = {
		ClearInvalidTarget = false,
	},

	Auto = {
		BoundsMargin = 18,
		SpawnAttachDistance = 95,
		PreferOppositeSpawn = true,
		MaxArenaDistance = math.huge,
	},

	Assets = {
		Folder = "AmphibiaOpponentAssets",
		DownloadImages = true,
	},

	Theme = {
		Background = Color3.fromRGB(10, 10, 10),
		Background2 = Color3.fromRGB(18, 18, 18),
		Stroke = Color3.fromRGB(42, 42, 42),
		StrokeDark = Color3.fromRGB(0, 0, 0),
		Text = Color3.fromRGB(255, 255, 255),
		SubText = Color3.fromRGB(180, 180, 180),
		Muted = Color3.fromRGB(120, 120, 120),
		Accent = Color3.fromRGB(150, 64, 255),
		Accent2 = Color3.fromRGB(238, 48, 255),
		HealthGood = Color3.fromRGB(92, 255, 120),
		HealthMid = Color3.fromRGB(255, 214, 92),
		HealthBad = Color3.fromRGB(255, 86, 86),
		SlotBg = Color3.fromRGB(9, 9, 9),
		SlotBg2 = Color3.fromRGB(15, 15, 15),
		SlotEquipped = Color3.fromRGB(64, 33, 114),
	},
}

local ARENA_NAMES = {
	Arena = true,
	BigArena = true,
	Backrooms = true,
	BigBackrooms = true,
	Battleground = true,
	Bridge = true,
	Chess = true,
	Crossroads = true,
	BigCrossroads = true,
	Construction = true,
	Dimension = true,
	Docks = true,
	Factory = true,
	Graveyard = true,
	BigGraveyard = true,
	Iceberg = true,
	Onyx = true,
	BigOnyx = true,
	Playground = true,
	Sandbox = true,
	Splash = true,
	BigSplash = true,
	Station = true,
	BigStation = true,
	Village = true,
}

local WEAPON_DATA = {
	Primary = {
		["Distortion"] = "https://i.imgur.com/Deo13m0.jpeg",
		["Permafrost"] = "https://i.imgur.com/MQUXLK6.jpeg",
		["Energy Rifle"] = "https://i.imgur.com/Xj1byQu.jpeg",
		["Flamethrower"] = "https://i.imgur.com/oNqnTbp.jpeg",
		["Grenade Launcher"] = "https://i.imgur.com/31zwvBU.jpeg",
		["Minigun"] = "https://i.imgur.com/hIVvub0.jpeg",
		["Paintball Gun"] = "https://i.imgur.com/NQJirRb.jpeg",
		["Assault Rifle"] = "https://i.imgur.com/VutCeLA.jpeg",
		["Bow"] = "https://i.imgur.com/EbfJrEM.jpeg",
		["Burst Rifle"] = "https://i.imgur.com/9i8o3Kx.jpeg",
		["Crossbow"] = "https://i.imgur.com/voY2veS.jpeg",
		["Gunblade"] = "https://i.imgur.com/kACWF5O.jpeg",
		["RPG"] = "https://i.imgur.com/UJ8zHiM.jpeg",
		["Shotgun"] = "https://i.imgur.com/2NU4B2W.jpeg",
		["Sniper"] = "https://i.imgur.com/5T7ys2E.jpeg",
		["Scepter"] = "https://i.imgur.com/aleJhtc.jpeg",
	},

	Secondary = {
		["Warper"] = "https://i.imgur.com/Ef11X8s.jpeg",
		["Energy Pistols"] = "https://i.imgur.com/KGrmCcC.jpeg",
		["Exogun"] = "https://i.imgur.com/1QjRVQo.jpeg",
		["Slingshot"] = "https://i.imgur.com/ExrSr9P.jpeg",
		["Daggers"] = "https://i.imgur.com/N7HXCBU.jpeg",
		["Flare Gun"] = "https://i.imgur.com/obGwT6C.jpeg",
		["Handgun"] = "https://i.imgur.com/ugICL91.jpeg",
		["Revolver"] = "https://i.imgur.com/CtaRZrJ.jpeg",
		["Shorty"] = "https://i.imgur.com/en3VVDo.jpeg",
		["Spray"] = "https://i.imgur.com/5OEIbcO.jpeg",
		["Uzi"] = "https://i.imgur.com/SW1adkh.jpeg",
		["Glass Cannon"] = "https://i.imgur.com/ZnozsTM.jpeg",
	},

	Melee = {
		["Maul"] = "https://i.imgur.com/dlbBw54.jpeg",
		["Trowel"] = "https://i.imgur.com/hzulHNt.jpeg",
		["Battle Axe"] = "https://i.imgur.com/rQE4d2s.jpeg",
		["Chainsaw"] = "https://i.imgur.com/9BusXQE.jpeg",
		["Fists"] = "https://i.imgur.com/kCSj2d0.jpeg",
		["Katana"] = "https://i.imgur.com/zecMdwH.jpeg",
		["Knife"] = "https://i.imgur.com/5q9XaOE.jpeg",
		["Riot Shield"] = "https://i.imgur.com/3LSxw9X.jpeg",
		["Scythe"] = "https://i.imgur.com/RreliD2.jpeg",
		["Spear"] = "https://i.imgur.com/rbvCqxM.png",
		["Glast Shard"] = "https://i.imgur.com/Bk81IYL.jpeg",
	},

	Utility = {
		["Medkit"] = "https://i.imgur.com/tAdb772.jpeg",
		["Subspace Tripmine"] = "https://i.imgur.com/8Fe0B6E.jpeg",
		["Warpstone"] = "https://i.imgur.com/W8CrA54.jpeg",
		["Flashbang"] = "https://i.imgur.com/GGV7TEO.jpeg",
		["Freeze Ray"] = "https://i.imgur.com/7gFxRAU.jpeg",
		["Grenade"] = "https://i.imgur.com/2BT21WY.jpeg",
		["Jump Pad"] = "https://i.imgur.com/rShPmak.jpeg",
		["Molotov"] = "https://i.imgur.com/Vvfp8mr.jpeg",
		["Satchel"] = "https://i.imgur.com/2180LQB.jpeg",
		["Smoke Grenade"] = "https://i.imgur.com/qyuVZt5.jpeg",
		["War Horn"] = "https://i.imgur.com/qx5aPt6.jpeg",
		["Elixir"] = "https://i.imgur.com/jRq4Vkc.jpeg",
		["RNG Dice"] = "https://i.imgur.com/2hJOmQc.jpeg",
	},
}

local WEAPON_SLOT_BY_NAME = {}
local WEAPON_URL_BY_NAME = {}

for slotName, weapons in pairs(WEAPON_DATA) do
	for weaponName, url in pairs(weapons) do
		WEAPON_SLOT_BY_NAME[weaponName] = slotName
		WEAPON_URL_BY_NAME[weaponName] = url
	end
end

local SLOT_ORDER = { "Primary", "Secondary", "Melee", "Utility" }

local function cloneTable(tbl)
	local result = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			result[k] = cloneTable(v)
		else
			result[k] = v
		end
	end
	return result
end

local function mergeDeep(target, patch)
	for k, v in pairs(patch) do
		if type(v) == "table" and type(target[k]) == "table" then
			mergeDeep(target[k], v)
		else
			target[k] = v
		end
	end
	return target
end

local function newInstance(className, props)
	local object = Instance.new(className)
	for prop, value in pairs(props or {}) do
		object[prop] = value
	end
	return object
end

local function tween(object, info, properties)
	if not object or not object.Parent then
		return nil
	end

	local t = TweenService:Create(
		object,
		info or TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		properties
	)
	t:Play()
	return t
end

local function addCorner(parent, radius)
	return newInstance("UICorner", {
		Parent = parent,
		CornerRadius = UDim.new(0, radius or 4),
	})
end

local function addStroke(parent, color, thickness, transparency)
	return newInstance("UIStroke", {
		Parent = parent,
		Color = color,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		LineJoinMode = Enum.LineJoinMode.Round,
	})
end

local function addGradient(parent, colorSequence, rotation)
	return newInstance("UIGradient", {
		Parent = parent,
		Color = colorSequence,
		Rotation = rotation or 0,
	})
end

local function getRoot(character)
	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("Torso")
		or character.PrimaryPart
end

local function getHumanoid(character)
	return character and character:FindFirstChildOfClass("Humanoid") or nil
end

local function isAliveCharacter(character)
	local hum = getHumanoid(character)
	local root = getRoot(character)
	return hum and hum.Health > 0 and root ~= nil
end

local function splitByDelimiter(text, delimiter)
	local result = {}
	local startIndex = 1

	while true do
		local i, j = string.find(text, delimiter, startIndex, true)
		if not i then
			table.insert(result, string.sub(text, startIndex))
			break
		end

		table.insert(result, string.sub(text, startIndex, i - 1))
		startIndex = j + 1
	end

	return result
end

local function parseViewModelName(name)
	local parts = splitByDelimiter(name, " - ")
	local playerName = parts[1]
	local weaponName = parts[2]
	local skinName = nil

	if #parts >= 3 then
		skinName = table.concat(parts, " - ", 3)
	end

	return playerName, weaponName, skinName
end

local function sanitizeFileName(name)
	return (tostring(name):gsub("[^%w%-%._ ]", "_"))
end

local function getFileExtensionFromUrl(url)
	local clean = tostring(url):match("^[^%?]+") or tostring(url)
	local ext = clean:match("%.([A-Za-z0-9]+)$")
	if not ext then
		return ".png"
	end
	return "." .. string.lower(ext)
end

local function getParentGui(customParent)
	if customParent then
		return customParent
	end

	if gethui then
		return gethui()
	end

	return game:GetService("CoreGui")
end

local function lerpColor(a, b, t)
	return Color3.new(
		a.R + (b.R - a.R) * t,
		a.G + (b.G - a.G) * t,
		a.B + (b.B - a.B) * t
	)
end

local function getHealthColor(theme, percent)
	percent = math.clamp(percent, 0, 1)

	if percent > 0.6 then
		return lerpColor(theme.HealthMid, theme.HealthGood, (percent - 0.6) / 0.4)
	elseif percent > 0.3 then
		return lerpColor(theme.HealthBad, theme.HealthMid, (percent - 0.3) / 0.3)
	else
		return theme.HealthBad
	end
end

local function makeDraggableSmooth(handle, target)
	if not handle or not target then
		return
	end

	handle.Active = true
	target.Active = true

	local dragging = false
	local dragStart
	local startPosition
	local dragInput
	local currentTween

	local function update(input)
		local delta = input.Position - dragStart
		local goal = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)

		if currentTween then
			currentTween:Cancel()
		end

		currentTween = TweenService:Create(
			target,
			TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = goal }
		)
		currentTween:Play()
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = target.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			update(input)
		end
	end)
end

function OpponentInfo.new(config)
	local self = setmetatable({}, OpponentInfo)

	self.Config = cloneTable(DEFAULT_CONFIG)
	if type(config) == "table" then
		mergeDeep(self.Config, config)
	end

	self.Parent = getParentGui(self.Config.Parent)
	self.Gui = nil
	self.Root = nil
	self.Visible = self.Config.Visible == true

	self._trackedPlayer = nil
	self._trackedCharacter = nil
	self._trackedName = nil
	self._lastUpdate = 0
	self._connections = {}
	self._assetCache = {}
	self._avatarUserId = nil

	self:_buildGui()
	self:_connectLoop()

	if self.Visible then
		self:Show()
	else
		self:Hide()
	end

	return self
end

function OpponentInfo:_connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(self._connections, connection)
	return connection
end

function OpponentInfo:_disconnectAll()
	for _, connection in ipairs(self._connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	table.clear(self._connections)
end

function OpponentInfo:_buildGui()
	local theme = self.Config.Theme

	self.Gui = newInstance("ScreenGui", {
		Name = "AmphibiaOpponentInfo",
		Parent = self.Parent,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		Enabled = true,
		DisplayOrder = 999999,
	})

	self.Root = newInstance("Frame", {
		Name = "Root",
		Parent = self.Gui,
		AnchorPoint = self.Config.Window.AnchorPoint,
		Position = self.Config.Window.Position,
		Size = self.Config.Window.Size,
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		Visible = true,
		ClipsDescendants = true,
	})

	addCorner(self.Root, 8)
	addStroke(self.Root, theme.Stroke, 1, 0)
	addStroke(self.Root, theme.StrokeDark, 1, 0.4)
	addGradient(self.Root, ColorSequence.new({
		ColorSequenceKeypoint.new(0, theme.Background2),
		ColorSequenceKeypoint.new(1, theme.Background),
	}), -90)

	self.Header = newInstance("Frame", {
		Name = "Header",
		Parent = self.Root,
		BackgroundColor3 = theme.Background2,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 40),
	})

	addCorner(self.Header, 8)
	addStroke(self.Header, theme.StrokeDark, 1, 0.55)

	self.Title = newInstance("TextLabel", {
		Name = "Title",
		Parent = self.Header,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -24, 1, 0),
		Font = Enum.Font.RobotoMono,
		Text = self.Config.Window.Title,
		TextColor3 = theme.Text,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local topInfo = newInstance("Frame", {
		Name = "TopInfo",
		Parent = self.Root,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 50),
		Size = UDim2.new(1, -24, 0, 78),
	})

	self.PlayerName = newInstance("TextLabel", {
		Name = "PlayerName",
		Parent = topInfo,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, -74, 0, 24),
		Font = Enum.Font.RobotoMono,
		Text = "No target",
		TextColor3 = theme.Text,
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	self.Status = newInstance("TextLabel", {
		Name = "Status",
		Parent = topInfo,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 25),
		Size = UDim2.new(1, -74, 0, 18),
		Font = Enum.Font.RobotoMono,
		Text = "Waiting for tracked player",
		TextColor3 = theme.SubText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	self.ArenaText = newInstance("TextLabel", {
		Name = "ArenaText",
		Parent = topInfo,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 45),
		Size = UDim2.new(1, -74, 0, 16),
		Font = Enum.Font.RobotoMono,
		Text = "Arena: -",
		TextColor3 = theme.Muted,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	self.Avatar = newInstance("ImageLabel", {
		Name = "Avatar",
		Parent = topInfo,
		BackgroundColor3 = theme.Background2,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -62, 0, 0),
		Size = UDim2.new(0, 62, 0, 62),
		Image = "",
		BackgroundTransparency = 0,
	})

	addCorner(self.Avatar, 8)
	addStroke(self.Avatar, theme.Stroke, 1, 0)
	addStroke(self.Avatar, theme.StrokeDark, 1, 0.45)

	local healthHolder = newInstance("Frame", {
		Name = "HealthHolder",
		Parent = self.Root,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 128),
		Size = UDim2.new(1, -24, 0, 28),
	})

	self.HealthText = newInstance("TextLabel", {
		Name = "HealthText",
		Parent = healthHolder,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 12),
		Font = Enum.Font.RobotoMono,
		Text = "HP: 0 / 0",
		TextColor3 = theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	self.HealthBarBg = newInstance("Frame", {
		Name = "HealthBarBg",
		Parent = healthHolder,
		BackgroundColor3 = theme.Background2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 16),
		Size = UDim2.new(1, 0, 0, 10),
	})

	addCorner(self.HealthBarBg, 999)
	addStroke(self.HealthBarBg, theme.StrokeDark, 1, 0.45)

	self.HealthBar = newInstance("Frame", {
		Name = "HealthBar",
		Parent = self.HealthBarBg,
		BackgroundColor3 = theme.HealthBad,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 0, 1, 0),
	})

	addCorner(self.HealthBar, 999)

	self.SlotsHolder = newInstance("Frame", {
		Name = "SlotsHolder",
		Parent = self.Root,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 168),
		Size = UDim2.new(1, -24, 0, 140),
	})

	local slotsGrid = newInstance("UIGridLayout", {
		Parent = self.SlotsHolder,
		FillDirection = Enum.FillDirection.Horizontal,
		FillDirectionMaxCells = 2,
		CellPadding = UDim2.new(0, 8, 0, 8),
		CellSize = UDim2.new(0.5, -4, 0, 66),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	self.Slots = {}

	local function createWeaponSlot(parent, order, title)
		local slot = newInstance("Frame", {
			Name = title,
			Parent = parent,
			LayoutOrder = order,
			BackgroundColor3 = theme.SlotBg,
			BorderSizePixel = 0,
		})

		addCorner(slot, 8)
		addStroke(slot, theme.Stroke, 1, 0.1)
		addStroke(slot, theme.StrokeDark, 1, 0.45)
		addGradient(slot, ColorSequence.new({
			ColorSequenceKeypoint.new(0, theme.SlotBg2),
			ColorSequenceKeypoint.new(1, theme.SlotBg),
		}), -90)

		local icon = newInstance("ImageLabel", {
			Name = "Icon",
			Parent = slot,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 8, 0.5, -20),
			Size = UDim2.new(0, 40, 0, 40),
			Image = "",
			ScaleType = Enum.ScaleType.Crop,
		})

		addCorner(icon, 6)

		local slotLabel = newInstance("TextLabel", {
			Name = "SlotLabel",
			Parent = slot,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 56, 0, 6),
			Size = UDim2.new(1, -64, 0, 12),
			Font = Enum.Font.RobotoMono,
			Text = title,
			TextColor3 = theme.Muted,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})

		local weaponName = newInstance("TextLabel", {
			Name = "WeaponName",
			Parent = slot,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 56, 0, 18),
			Size = UDim2.new(1, -64, 0, 18),
			Font = Enum.Font.RobotoMono,
			Text = "Empty",
			TextColor3 = theme.Text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})

		local sub = newInstance("TextLabel", {
			Name = "Sub",
			Parent = slot,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 56, 1, -18),
			Size = UDim2.new(1, -64, 0, 12),
			Font = Enum.Font.RobotoMono,
			Text = "-",
			TextColor3 = theme.SubText,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})

		return {
			Card = slot,
			Icon = icon,
			SlotLabel = slotLabel,
			WeaponName = weaponName,
			Sub = sub,
		}
	end

	self.Slots.Primary = createWeaponSlot(self.SlotsHolder, 1, "Primary")
	self.Slots.Secondary = createWeaponSlot(self.SlotsHolder, 2, "Secondary")
	self.Slots.Melee = createWeaponSlot(self.SlotsHolder, 3, "Melee")
	self.Slots.Utility = createWeaponSlot(self.SlotsHolder, 4, "Utility")

	makeDraggableSmooth(self.Header, self.Root)
end

function OpponentInfo:_connectLoop()
	self:_connect(RunService.Heartbeat, function()
		if not self.Visible then
			return
		end

		local now = os.clock()
		if now - self._lastUpdate < self.Config.UpdateInterval then
			return
		end

		self._lastUpdate = now
		self:_update()
	end)
end

function OpponentInfo:_getArenaDescriptor(model)
	if not model or not model:IsA("Model") or not ARENA_NAMES[model.Name] then
		return nil
	end

	local spawns = model:FindFirstChild("Spawns")
	if not spawns then
		return nil
	end

	local side1 = spawns:FindFirstChild("1")
	local side2 = spawns:FindFirstChild("2")
	local part1 = side1 and side1:FindFirstChild("Part")
	local part2 = side2 and side2:FindFirstChild("Part")

	if not (part1 and part2 and part1:IsA("BasePart") and part2:IsA("BasePart")) then
		return nil
	end

	return {
		Model = model,
		Name = model.Name,
		Spawn1 = part1,
		Spawn2 = part2,
	}
end

function OpponentInfo:_getAllArenaDescriptors()
	local result = {}

	for _, child in ipairs(Workspace:GetChildren()) do
		local descriptor = self:_getArenaDescriptor(child)
		if descriptor then
			table.insert(result, descriptor)
		end
	end

	return result
end

function OpponentInfo:_pointInsideModelBounds(model, position)
	local ok, cf, size = pcall(function()
		return model:GetBoundingBox()
	end)

	if not ok or not cf or not size then
		return false
	end

	local margin = self.Config.Auto.BoundsMargin or 0
	local localPos = cf:PointToObjectSpace(position)

	return math.abs(localPos.X) <= (size.X * 0.5 + margin)
		and math.abs(localPos.Y) <= (size.Y * 0.5 + margin)
		and math.abs(localPos.Z) <= (size.Z * 0.5 + margin)
end

function OpponentInfo:_findArenaForPosition(position)
	local best = nil
	local spawnAttachDistance = self.Config.Auto.SpawnAttachDistance or 95

	for _, arena in ipairs(self:_getAllArenaDescriptors()) do
		local d1 = (position - arena.Spawn1.Position).Magnitude
		local d2 = (position - arena.Spawn2.Position).Magnitude
		local minDistance = math.min(d1, d2)
		local nearestSide = d1 <= d2 and 1 or 2
		local insideBounds = self:_pointInsideModelBounds(arena.Model, position)

		if insideBounds or minDistance <= spawnAttachDistance then
			local candidate = {
				Model = arena.Model,
				Name = arena.Name,
				Spawn1 = arena.Spawn1,
				Spawn2 = arena.Spawn2,
				Spawn1Distance = d1,
				Spawn2Distance = d2,
				DistanceToNearestSpawn = minDistance,
				NearestSpawnIndex = nearestSide,
				InsideBounds = insideBounds,
			}

			if not best then
				best = candidate
			else
				if candidate.InsideBounds and not best.InsideBounds then
					best = candidate
				elseif candidate.InsideBounds == best.InsideBounds and candidate.DistanceToNearestSpawn < best.DistanceToNearestSpawn then
					best = candidate
				end
			end
		end
	end

	if best and best.DistanceToNearestSpawn <= (self.Config.Auto.MaxArenaDistance or math.huge) then
		return best
	end

	return nil
end

function OpponentInfo:_resolvePlayer(target)
	if typeof(target) == "Instance" then
		if target:IsA("Player") then
			return target
		end

		if target:IsA("Model") then
			return Players:GetPlayerFromCharacter(target)
		end
	end

	if type(target) == "string" then
		for _, player in ipairs(Players:GetPlayers()) do
			if string.lower(player.Name) == string.lower(target) then
				return player
			end
		end
	end

	return nil
end

function OpponentInfo:_setAvatarForPlayer(player)
	if not player or not player.UserId then
		self.Avatar.Image = ""
		self._avatarUserId = nil
		return
	end

	if self._avatarUserId == player.UserId then
		return
	end

	self._avatarUserId = player.UserId

	local ok, content = pcall(function()
		return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)

	if ok then
		self.Avatar.Image = content
	else
		self.Avatar.Image = ""
	end
end

function OpponentInfo:_ensureAssetFolder()
	if not self.Config.Assets.DownloadImages then
		return false
	end

	if not makefolder or not isfolder then
		return false
	end

	local folder = self.Config.Assets.Folder
	if not isfolder(folder) then
		makefolder(folder)
	end

	return true
end

function OpponentInfo:_getWeaponAsset(weaponName)
	if self._assetCache[weaponName] ~= nil then
		return self._assetCache[weaponName]
	end

	local url = WEAPON_URL_BY_NAME[weaponName]
	if not url then
		self._assetCache[weaponName] = false
		return nil
	end

	if not (REQUEST_FUNCTION and GET_ASSET_FUNCTION and writefile and isfile) then
		self._assetCache[weaponName] = false
		return nil
	end

	if not self:_ensureAssetFolder() then
		self._assetCache[weaponName] = false
		return nil
	end

	local extension = getFileExtensionFromUrl(url)
	local filePath = self.Config.Assets.Folder .. "/" .. sanitizeFileName(weaponName) .. extension

	if not isfile(filePath) then
		local ok, response = pcall(function()
			return REQUEST_FUNCTION({
				Url = url,
				Method = "GET",
			})
		end)

		if not ok or not response or not response.Body then
			self._assetCache[weaponName] = false
			return nil
		end

		local writeOk = pcall(function()
			writefile(filePath, response.Body)
		end)

		if not writeOk then
			self._assetCache[weaponName] = false
			return nil
		end
	end

	local ok, assetId = pcall(function()
		return GET_ASSET_FUNCTION(filePath)
	end)

	if not ok then
		self._assetCache[weaponName] = false
		return nil
	end

	self._assetCache[weaponName] = assetId
	return assetId
end

function OpponentInfo:_collectWeaponModelsFromContainer(container, playerName, inHand, output)
	if not container then
		return
	end

	for _, child in ipairs(container:GetChildren()) do
		local modelPlayerName, weaponName, skinName = parseViewModelName(child.Name)
		if modelPlayerName == playerName and weaponName and WEAPON_SLOT_BY_NAME[weaponName] then
			local slotName = WEAPON_SLOT_BY_NAME[weaponName]
			local existing = output[slotName]

			if not existing or (inHand and not existing.InHand) then
				output[slotName] = {
					WeaponName = weaponName,
					SkinName = skinName,
					SlotName = slotName,
					InHand = inHand == true,
					Source = child,
				}
			end
		end
	end
end

function OpponentInfo:_resolveLoadoutForPlayer(playerName)
	local loadout = {
		Primary = nil,
		Secondary = nil,
		Melee = nil,
		Utility = nil,
	}

	if not self._trackedPlayer then
		return loadout
	end

	local valid = self:IsTrackedPlayerInCurrentMatch()
	if not valid then
		return loadout
	end

	local workspaceViewModels = Workspace:FindFirstChild("ViewModels")
	self:_collectWeaponModelsFromContainer(workspaceViewModels, playerName, true, loadout)

	local tempRoot = ReplicatedStorage:FindFirstChild("Assets")
	tempRoot = tempRoot and tempRoot:FindFirstChild("Temp") or nil
	tempRoot = tempRoot and tempRoot:FindFirstChild("ViewModels") or nil
	self:_collectWeaponModelsFromContainer(tempRoot, playerName, false, loadout)

	return loadout
end

function OpponentInfo:_setSlotVisual(slotName, weaponData)
	local slot = self.Slots[slotName]
	local theme = self.Config.Theme

	if not slot then
		return
	end

	if not weaponData then
		slot.Card.BackgroundColor3 = theme.SlotBg
		slot.WeaponName.Text = "Empty"
		slot.Sub.Text = "-"
		slot.Icon.Image = ""
		return
	end

	slot.Card.BackgroundColor3 = weaponData.InHand and theme.SlotEquipped or theme.SlotBg
	slot.WeaponName.Text = weaponData.WeaponName or "Unknown"

	if weaponData.SkinName and weaponData.SkinName ~= "" then
		slot.Sub.Text = weaponData.InHand and ("In hand • " .. weaponData.SkinName) or weaponData.SkinName
	else
		slot.Sub.Text = weaponData.InHand and "In hand" or "Equipped"
	end

	local asset = self:_getWeaponAsset(weaponData.WeaponName)
	if asset then
		slot.Icon.Image = asset
	else
		slot.Icon.Image = ""
	end
end

function OpponentInfo:_setNoTargetState(message)
	self.PlayerName.Text = "No target"
	self.Status.Text = message or "Waiting for tracked player"
	self.ArenaText.Text = "Arena: -"
	self.HealthText.Text = "HP: 0 / 0"
	self.Avatar.Image = ""
	self._avatarUserId = nil

	tween(self.HealthBar, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = self.Config.Theme.HealthBad,
	})

	for _, slotName in ipairs(SLOT_ORDER) do
		self:_setSlotVisual(slotName, nil)
	end
end

function OpponentInfo:GetLocalArenaInfo()
	local localCharacter = LocalPlayer and LocalPlayer.Character
	if not localCharacter or not isAliveCharacter(localCharacter) then
		return nil
	end

	local root = getRoot(localCharacter)
	if not root then
		return nil
	end

	return self:_findArenaForPosition(root.Position)
end

function OpponentInfo:GetPlayerArenaInfo(player)
	if not player or not player.Character or not isAliveCharacter(player.Character) then
		return nil
	end

	local root = getRoot(player.Character)
	if not root then
		return nil
	end

	return self:_findArenaForPosition(root.Position)
end

function OpponentInfo:IsTrackedPlayerInCurrentMatch()
	if not self._trackedPlayer or self._trackedPlayer == LocalPlayer then
		return false
	end

	local localArena = self:GetLocalArenaInfo()
	local targetArena = self:GetPlayerArenaInfo(self._trackedPlayer)

	if not localArena or not targetArena then
		return false
	end

	if localArena.Model ~= targetArena.Model then
		return false
	end

	if self.Config.Auto.PreferOppositeSpawn and localArena.NearestSpawnIndex == targetArena.NearestSpawnIndex then
		return false
	end

	return true, localArena, targetArena
end

function OpponentInfo:_updateWindowForPlayer(player, character)
	local humanoid = getHumanoid(character)
	local root = getRoot(character)

	if not humanoid or not root then
		self:_setNoTargetState("Target not alive / no character")
		return
	end

	self.PlayerName.Text = player.Name
	self.Status.Text = "Tracking target"

	local trackedArena = self:_findArenaForPosition(root.Position)
	if trackedArena then
		self.ArenaText.Text = string.format("Arena: %s | Side: %s", trackedArena.Name, tostring(trackedArena.NearestSpawnIndex))
	else
		self.ArenaText.Text = "Arena: -"
	end

	self:_setAvatarForPlayer(player)

	local maxHealth = math.max(humanoid.MaxHealth, 1)
	local hp = math.max(humanoid.Health, 0)
	local alpha = math.clamp(hp / maxHealth, 0, 1)

	self.HealthText.Text = string.format("HP: %d / %d", math.floor(hp + 0.5), math.floor(maxHealth + 0.5))

	tween(self.HealthBar, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(alpha, 0, 1, 0),
		BackgroundColor3 = getHealthColor(self.Config.Theme, alpha),
	})

	local loadout = self:_resolveLoadoutForPlayer(player.Name)
	for _, slotName in ipairs(SLOT_ORDER) do
		self:_setSlotVisual(slotName, loadout[slotName])
	end
end

function OpponentInfo:_update()
	if self.Config.AutoDetect and not self._trackedPlayer then
		self:TrackAutoOpponent()
	end

	if not self._trackedPlayer then
		self:_setNoTargetState()
		return
	end

	if self._trackedPlayer.Parent ~= Players then
		self:ClearTrackedPlayer()
		self:_setNoTargetState()
		return
	end

	local validMatch = self:IsTrackedPlayerInCurrentMatch()
	if not validMatch then
		self._trackedCharacter = nil

		if self.Config.Tracking.ClearInvalidTarget then
			self:ClearTrackedPlayer()
		end

		self:_setNoTargetState("Tracked player is not in your current match")
		return
	end

	local character = self._trackedPlayer.Character
	self._trackedCharacter = character

	if not character or not isAliveCharacter(character) then
		self.PlayerName.Text = self._trackedPlayer.Name
		self.Status.Text = "Target not alive / no character"

		local targetArena = self:GetPlayerArenaInfo(self._trackedPlayer)
		if targetArena then
			self.ArenaText.Text = string.format("Arena: %s | Side: %s", targetArena.Name, tostring(targetArena.NearestSpawnIndex))
		else
			self.ArenaText.Text = "Arena: -"
		end

		self.HealthText.Text = "HP: 0 / 0"
		self:_setAvatarForPlayer(self._trackedPlayer)

		tween(self.HealthBar, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = self.Config.Theme.HealthBad,
		})

		local loadout = self:_resolveLoadoutForPlayer(self._trackedPlayer.Name)
		for _, slotName in ipairs(SLOT_ORDER) do
			self:_setSlotVisual(slotName, loadout[slotName])
		end

		return
	end

	self:_updateWindowForPlayer(self._trackedPlayer, character)
end

function OpponentInfo:Show()
	self.Visible = true
	if self.Root then
		self.Root.Visible = true
	end
	return self
end

function OpponentInfo:Hide()
	self.Visible = false
	if self.Root then
		self.Root.Visible = false
	end
	return self
end

function OpponentInfo:Toggle()
	if self.Visible then
		return self:Hide()
	else
		return self:Show()
	end
end

function OpponentInfo:SetEnabled(value)
	if value then
		self:Show()
	else
		self:Hide()
	end
	return self
end

function OpponentInfo:UpdateConfig(config)
	if type(config) == "table" then
		mergeDeep(self.Config, config)
	end
	return self
end

function OpponentInfo:TrackPlayer(target)
	local player = self:_resolvePlayer(target)
	if not player or player == LocalPlayer then
		return nil
	end

	self._trackedPlayer = player
	self._trackedCharacter = player.Character
	self._trackedName = player.Name
	self:_setAvatarForPlayer(player)
	self:_update()

	return player
end

function OpponentInfo:TrackCharacter(character)
	local player = self:_resolvePlayer(character)
	if not player then
		return nil
	end
	return self:TrackPlayer(player)
end

function OpponentInfo:TrackByName(name)
	return self:TrackPlayer(name)
end

function OpponentInfo:ClearTrackedPlayer()
	self._trackedPlayer = nil
	self._trackedCharacter = nil
	self._trackedName = nil
	self:_setNoTargetState()
	return self
end

function OpponentInfo:GetTrackedPlayer()
	return self._trackedPlayer
end

function OpponentInfo:GetTrackedCharacter()
	return self._trackedCharacter
end

function OpponentInfo:PreloadWeaponImages()
	for weaponName in pairs(WEAPON_URL_BY_NAME) do
		self:_getWeaponAsset(weaponName)
	end
	return self
end

function OpponentInfo:Refresh()
	self:_update()
	return self
end

function OpponentInfo:FindOpponentCandidate()
	local localCharacter = LocalPlayer and LocalPlayer.Character
	if not localCharacter or not isAliveCharacter(localCharacter) then
		return nil, nil
	end

	local localRoot = getRoot(localCharacter)
	if not localRoot then
		return nil, nil
	end

	local localArena = self:GetLocalArenaInfo()
	if not localArena then
		return nil, nil
	end

	local bestPlayer = nil
	local bestMeta = nil
	local bestScore = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and isAliveCharacter(player.Character) then
			local playerRoot = getRoot(player.Character)
			if playerRoot then
				local candidateArena = self:GetPlayerArenaInfo(player)
				if candidateArena and candidateArena.Model == localArena.Model then
					local sameSidePenalty = 0
					if self.Config.Auto.PreferOppositeSpawn and candidateArena.NearestSpawnIndex == localArena.NearestSpawnIndex then
						sameSidePenalty = 500
					end

					local distanceToLocal = (playerRoot.Position - localRoot.Position).Magnitude
					local score = distanceToLocal + sameSidePenalty + (candidateArena.DistanceToNearestSpawn * 0.15)

					if score < bestScore then
						bestScore = score
						bestPlayer = player
						bestMeta = {
							LocalArena = localArena,
							CandidateArena = candidateArena,
							Distance = distanceToLocal,
							Score = score,
						}
					end
				end
			end
		end
	end

	return bestPlayer, bestMeta
end

function OpponentInfo:TrackAutoOpponent()
	local player = self:FindOpponentCandidate()
	if player then
		self:TrackPlayer(player)
	end
	return player
end

function OpponentInfo:Destroy()
	self:_disconnectAll()

	if self.Gui then
		self.Gui:Destroy()
	end

	self.Gui = nil
	self.Root = nil
	self._trackedPlayer = nil
	self._trackedCharacter = nil
	self._trackedName = nil
	self._avatarUserId = nil

	return nil
end

return OpponentInfo
