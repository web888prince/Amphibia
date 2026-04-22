local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

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
	UpdateInterval = 0.05,
	AutoDetect = false,

	Window = {
		Size = UDim2.new(0, 356, 0, 238),
		Position = UDim2.new(0.5, -178, 0.18, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Title = "Opponent information",
	},

	Auto = {
		BoundsMargin = 18,
		PreferOppositeSpawn = true,
		MaxArenaDistance = math.huge,
	},

	Assets = {
		Folder = "AmphibiaOpponentAssets",
		DownloadImages = true,
	},

	Theme = {
		Background = Color3.fromRGB(15, 15, 15),
		Background2 = Color3.fromRGB(22, 22, 22),
		Stroke = Color3.fromRGB(42, 42, 42),
		StrokeDark = Color3.fromRGB(0, 0, 0),
		Text = Color3.fromRGB(255, 255, 255),
		SubText = Color3.fromRGB(175, 175, 175),
		Muted = Color3.fromRGB(115, 115, 115),
		Accent = Color3.fromRGB(150, 64, 255),
		Accent2 = Color3.fromRGB(238, 48, 255),
		HealthGood = Color3.fromRGB(65, 255, 120),
		HealthBad = Color3.fromRGB(255, 70, 70),
		SlotBg = Color3.fromRGB(20, 20, 20),
		SlotBg2 = Color3.fromRGB(28, 28, 28),
		SlotEquipped = Color3.fromRGB(84, 45, 145),
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
	local t = TweenService:Create(object, info or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
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

local function safeFindChild(parent, name)
	if not parent then
		return nil
	end
	return parent:FindFirstChild(name)
end

local function getRoot(character)
	return character and character:FindFirstChild("HumanoidRootPart") or nil
end

local function getHumanoid(character)
	return character and character:FindFirstChildOfClass("Humanoid") or nil
end

local function isAliveCharacter(character)
	local humanoid = getHumanoid(character)
	local root = getRoot(character)
	return humanoid and humanoid.Health > 0 and root
end

local function splitByDelimiter(text, delimiter)
	local result = {}
	local start = 1

	while true do
		local i, j = string.find(text, delimiter, start, true)
		if not i then
			table.insert(result, string.sub(text, start))
			break
		end

		table.insert(result, string.sub(text, start, i - 1))
		start = j + 1
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
	return (name:gsub("[^%w%-%._ ]", "_"))
end

local function getFileExtensionFromUrl(url)
	local ext = string.match(url, "%.([A-Za-z0-9]+)$")
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
	return lerpColor(theme.HealthBad, theme.HealthGood, percent)
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
	self._arenaCache = {}

	self:_buildGui()
	self:_connectLoop()

	if self.Visible then
		self:Show()
	else
		self:Hide()
	end

	return self
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
	})

	addCorner(self.Root, 6)
	addStroke(self.Root, theme.Stroke, 1, 0)
	addStroke(self.Root, theme.StrokeDark, 1, 0.45)
	addGradient(self.Root, ColorSequence.new({
		ColorSequenceKeypoint.new(0, theme.Background2),
		ColorSequenceKeypoint.new(1, theme.Background),
	}), -90)

	local titleBar = newInstance("Frame", {
		Name = "TitleBar",
		Parent = self.Root,
		BackgroundColor3 = theme.Background2,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 32),
	})

	addCorner(titleBar, 6)
	addStroke(titleBar, theme.StrokeDark, 1, 0.65)

	self.Title = newInstance("TextLabel", {
		Name = "Title",
		Parent = titleBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -20, 1, 0),
		Font = Enum.Font.RobotoMono,
		Text = self.Config.Window.Title,
		TextColor3 = theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local topInfo = newInstance("Frame", {
		Name = "TopInfo",
		Parent = self.Root,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 40),
		Size = UDim2.new(1, -20, 0, 72),
	})

	self.Avatar = newInstance("ImageLabel", {
		Name = "Avatar",
		Parent = topInfo,
		BackgroundColor3 = theme.Background2,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -56, 0, 0),
		Size = UDim2.new(0, 56, 0, 56),
		Image = "",
		BackgroundTransparency = 0,
	})

	addCorner(self.Avatar, 6)
	addStroke(self.Avatar, theme.Stroke, 1, 0)

	self.PlayerName = newInstance("TextLabel", {
		Name = "PlayerName",
		Parent = topInfo,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, -68, 0, 24),
		Font = Enum.Font.RobotoMono,
		Text = "No target",
		TextColor3 = theme.Text,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	self.Status = newInstance("TextLabel", {
		Name = "Status",
		Parent = topInfo,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 24),
		Size = UDim2.new(1, -68, 0, 18),
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
		Position = UDim2.new(0, 0, 0, 42),
		Size = UDim2.new(1, -68, 0, 16),
		Font = Enum.Font.RobotoMono,
		Text = "Arena: -",
		TextColor3 = theme.Muted,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	local healthHolder = newInstance("Frame", {
		Name = "HealthHolder",
		Parent = self.Root,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 114),
		Size = UDim2.new(1, -20, 0, 28),
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

	addCorner(self.HealthBarBg, 99)
	addStroke(self.HealthBarBg, theme.StrokeDark, 1, 0.5)

	self.HealthBar = newInstance("Frame", {
		Name = "HealthBar",
		Parent = self.HealthBarBg,
		BackgroundColor3 = theme.HealthGood,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
	})

	addCorner(self.HealthBar, 99)
	addGradient(self.HealthBar, ColorSequence.new({
		ColorSequenceKeypoint.new(0, theme.Accent),
		ColorSequenceKeypoint.new(1, theme.Accent2),
	}), 0)

	local slotsHolder = newInstance("Frame", {
		Name = "SlotsHolder",
		Parent = self.Root,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 152),
		Size = UDim2.new(1, -20, 1, -162),
	})

	local layout = newInstance("UIGridLayout", {
		Parent = slotsHolder,
		CellPadding = UDim2.new(0, 8, 0, 8),
		CellSize = UDim2.new(0, 164, 0, 72),
		FillDirectionMaxCells = 2,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	self.Slots = {}

	for index, slotName in ipairs(SLOT_ORDER) do
		local card = newInstance("Frame", {
			Name = slotName,
			Parent = slotsHolder,
			BackgroundColor3 = theme.SlotBg,
			BorderSizePixel = 0,
			LayoutOrder = index,
		})

		addCorner(card, 6)
		addStroke(card, theme.Stroke, 1, 0)
		addStroke(card, theme.StrokeDark, 1, 0.5)
		addGradient(card, ColorSequence.new({
			ColorSequenceKeypoint.new(0, theme.SlotBg2),
			ColorSequenceKeypoint.new(1, theme.SlotBg),
		}), -90)

		local image = newInstance("ImageLabel", {
			Name = "Image",
			Parent = card,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 6, 0.5, -26),
			Size = UDim2.new(0, 52, 0, 52),
			Image = "",
			ScaleType = Enum.ScaleType.Crop,
		})

		addCorner(image, 6)

		local slotLabel = newInstance("TextLabel", {
			Name = "SlotLabel",
			Parent = card,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 64, 0, 5),
			Size = UDim2.new(1, -70, 0, 14),
			Font = Enum.Font.RobotoMono,
			Text = slotName,
			TextColor3 = theme.Muted,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
		})

		local weaponLabel = newInstance("TextLabel", {
			Name = "WeaponLabel",
			Parent = card,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 64, 0, 18),
			Size = UDim2.new(1, -70, 0, 20),
			Font = Enum.Font.RobotoMono,
			Text = "Empty",
			TextColor3 = theme.Text,
			TextSize = 13,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})

		local subLabel = newInstance("TextLabel", {
			Name = "SubLabel",
			Parent = card,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 64, 1, -18),
			Size = UDim2.new(1, -70, 0, 14),
			Font = Enum.Font.RobotoMono,
			Text = "-",
			TextColor3 = theme.SubText,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})

		self.Slots[slotName] = {
			Card = card,
			Image = image,
			SlotLabel = slotLabel,
			WeaponLabel = weaponLabel,
			SubLabel = subLabel,
		}
	end
end

function OpponentInfo:_connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(self._connections, connection)
	return connection
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

function OpponentInfo:_disconnectAll()
	for _, connection in ipairs(self._connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	table.clear(self._connections)
end

function OpponentInfo:_getArenaDescriptor(model)
	if not model or not ARENA_NAMES[model.Name] then
		return nil
	end

	local spawns = safeFindChild(model, "Spawns")
	if not spawns then
		return nil
	end

	local side1 = safeFindChild(spawns, "1")
	local side2 = safeFindChild(spawns, "2")
	local part1 = side1 and safeFindChild(side1, "Part") or nil
	local part2 = side2 and safeFindChild(side2, "Part") or nil

	if not part1 or not part2 then
		return nil
	end

	return {
		Model = model,
		Name = model.Name,
		Spawn1 = part1,
		Spawn2 = part2,
	}
end

function OpponentInfo:_getArenaModels()
	local list = {}

	for _, child in ipairs(Workspace:GetChildren()) do
		if child:IsA("Model") and ARENA_NAMES[child.Name] then
			local descriptor = self:_getArenaDescriptor(child)
			if descriptor then
				table.insert(list, descriptor)
			end
		end
	end

	return list
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

	for _, arena in ipairs(self:_getArenaModels()) do
		local d1 = (position - arena.Spawn1.Position).Magnitude
		local d2 = (position - arena.Spawn2.Position).Magnitude
		local minDistance = math.min(d1, d2)
		local nearestSpawnIndex = d1 <= d2 and 1 or 2
		local insideBounds = self:_pointInsideModelBounds(arena.Model, position)

		local candidate = {
			Model = arena.Model,
			Name = arena.Name,
			Spawn1 = arena.Spawn1,
			Spawn2 = arena.Spawn2,
			DistanceToNearestSpawn = minDistance,
			NearestSpawnIndex = nearestSpawnIndex,
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

	return best
end

function OpponentInfo:_getPlayerArenaInfo(player)
	if not player or not player.Character then
		return nil
	end

	local root = getRoot(player.Character)
	if not root then
		return nil
	end

	local arenaInfo = self:_findArenaForPosition(root.Position)
	if not arenaInfo then
		return nil
	end

	if arenaInfo.DistanceToNearestSpawn > (self.Config.Auto.MaxArenaDistance or math.huge) then
		return nil
	end

	return arenaInfo
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
		return
	end

	local ok, content = pcall(function()
		return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)

	if ok then
		self.Avatar.Image = content
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
		self._assetCache[weaponName] = nil
		return nil
	end

	if not (REQUEST_FUNCTION and GET_ASSET_FUNCTION and writefile and isfile) then
		self._assetCache[weaponName] = nil
		return nil
	end

	if not self:_ensureAssetFolder() then
		self._assetCache[weaponName] = nil
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
			self._assetCache[weaponName] = nil
			return nil
		end

		local writeOk = pcall(function()
			writefile(filePath, response.Body)
		end)

		if not writeOk then
			self._assetCache[weaponName] = nil
			return nil
		end
	end

	local ok, assetId = pcall(function()
		return GET_ASSET_FUNCTION(filePath)
	end)

	if not ok then
		self._assetCache[weaponName] = nil
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
		local parsedPlayerName, weaponName, skinName = parseViewModelName(child.Name)
		if parsedPlayerName == playerName and weaponName and WEAPON_SLOT_BY_NAME[weaponName] then
			local slotName = WEAPON_SLOT_BY_NAME[weaponName]

			if not output[slotName] or (inHand and not output[slotName].InHand) then
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
	local loadout = {}

	local workspaceViewModels = safeFindChild(Workspace, "ViewModels")
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
		slot.WeaponLabel.Text = "Empty"
		slot.SubLabel.Text = "-"
		slot.Image.Image = ""
		return
	end

	slot.Card.BackgroundColor3 = weaponData.InHand and theme.SlotEquipped or theme.SlotBg
	slot.WeaponLabel.Text = weaponData.WeaponName or "Unknown"

	if weaponData.SkinName and weaponData.SkinName ~= "" then
		slot.SubLabel.Text = weaponData.InHand and ("In hand • " .. weaponData.SkinName) or weaponData.SkinName
	else
		slot.SubLabel.Text = weaponData.InHand and "In hand" or "Equipped"
	end

	local asset = self:_getWeaponAsset(weaponData.WeaponName)
	if asset then
		slot.Image.Image = asset
	else
		slot.Image.Image = ""
	end
end

function OpponentInfo:_setNoTargetState()
	local theme = self.Config.Theme
	self.PlayerName.Text = "No target"
	self.Status.Text = "Waiting for tracked player"
	self.ArenaText.Text = "Arena: -"
	self.HealthText.Text = "HP: 0 / 0"
	self.Avatar.Image = ""

	tween(self.HealthBar, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = theme.HealthBad,
	})

	for _, slotName in ipairs(SLOT_ORDER) do
		self:_setSlotVisual(slotName, nil)
	end
end

function OpponentInfo:_updateWindowForPlayer(player, character)
	local theme = self.Config.Theme
	local humanoid = getHumanoid(character)
	local root = getRoot(character)

	if not humanoid or not root then
		self:_setNoTargetState()
		return
	end

	self.PlayerName.Text = player.Name

	local arenaInfo = self:_findArenaForPosition(root.Position)
	if arenaInfo then
		self.ArenaText.Text = string.format("Arena: %s | Side: %s", arenaInfo.Name, tostring(arenaInfo.NearestSpawnIndex))
	else
		self.ArenaText.Text = "Arena: -"
	end

	self.Status.Text = character == player.Character and "Tracking live character" or "Tracking"
	self:_setAvatarForPlayer(player)

	local maxHealth = math.max(1, humanoid.MaxHealth)
	local hp = math.max(0, humanoid.Health)
	local percent = math.clamp(hp / maxHealth, 0, 1)

	self.HealthText.Text = string.format("HP: %d / %d", math.floor(hp + 0.5), math.floor(maxHealth + 0.5))

	tween(self.HealthBar, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(percent, 0, 1, 0),
		BackgroundColor3 = getHealthColor(theme, percent),
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

	local character = self._trackedPlayer.Character
	if not character or not isAliveCharacter(character) then
		self:_trackedCharacter = character
		self.PlayerName.Text = self._trackedPlayer.Name
		self.Status.Text = "Target not alive / no character"
		self.ArenaText.Text = "Arena: -"
		self.HealthText.Text = "HP: 0 / 0"
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

	self._trackedCharacter = character
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
	if not player then
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
	local localCharacter = LocalPlayer.Character
	if not localCharacter or not isAliveCharacter(localCharacter) then
		return nil, nil
	end

	local localRoot = getRoot(localCharacter)
	if not localRoot then
		return nil, nil
	end

	local localArenaInfo = self:_findArenaForPosition(localRoot.Position)
	if not localArenaInfo then
		return nil, nil
	end

	local bestPlayer = nil
	local bestMeta = nil
	local bestScore = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and isAliveCharacter(player.Character) then
			local candidateRoot = getRoot(player.Character)
			if candidateRoot then
				local candidateArenaInfo = self:_findArenaForPosition(candidateRoot.Position)

				if candidateArenaInfo and candidateArenaInfo.Model == localArenaInfo.Model then
					local distanceToLocal = (candidateRoot.Position - localRoot.Position).Magnitude
					local sameSidePenalty = 0

					if self.Config.Auto.PreferOppositeSpawn then
						if candidateArenaInfo.NearestSpawnIndex == localArenaInfo.NearestSpawnIndex then
							sameSidePenalty = 500
						end
					end

					local score = distanceToLocal + sameSidePenalty + (candidateArenaInfo.DistanceToNearestSpawn * 0.15)

					if score < bestScore then
						bestScore = score
						bestPlayer = player
						bestMeta = {
							LocalArena = localArenaInfo,
							CandidateArena = candidateArenaInfo,
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

	return nil
end

return OpponentInfo
