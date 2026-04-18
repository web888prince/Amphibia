--// Amphibia GUI Library
--// One-file ModuleScript
--// Usage example is at the bottom of this file.

local Amphibia = {}
Amphibia.__index = Amphibia
Amphibia.Version = "1.0.4-final-polish-fix-compile1"

--──────────────────────────────────────────────────--
-- Services
--──────────────────────────────────────────────────--

local Services = {
	Players = game:GetService("Players"),
	UserInputService = game:GetService("UserInputService"),
	TweenService = game:GetService("TweenService"),
	RunService = game:GetService("RunService"),
	Debris = game:GetService("Debris"),
	TextService = game:GetService("TextService"),
	SoundService = game:GetService("SoundService")
}

local Player = Services.Players.LocalPlayer
local PlayerGui = Player and Player:WaitForChild("PlayerGui")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")

--──────────────────────────────────────────────────--
-- Theme
--──────────────────────────────────────────────────--

local Theme = {
	Font = Enum.Font.RobotoMono,

	Images = {
		Settings = "rbxassetid://9405931578",
		Search = "rbxassetid://75273157378006",
		Close = "rbxassetid://130334254289066",
		Move = "rbxassetid://87351486351798",
		Random = "rbxassetid://82824171769924",
		Reset = "rbxassetid://438217404",
		Freeze = "rbxassetid://13200344988",
		TripleDot = "rbxassetid://127075876244307",
	},

	Sounds = {
		Notification = "132969094145770",
		Notification_Timing = 1.5
	},

	Colors = {
		Background = Color3.fromRGB(16, 16, 16),
		Background2 = Color3.fromRGB(20, 20, 20),
		Header = Color3.fromRGB(24, 24, 24),
		Section = Color3.fromRGB(20, 20, 20),
		Stroke = Color3.fromRGB(40, 40, 40),
		StrokeDark = Color3.fromRGB(0, 0, 0),
		Text = Color3.fromRGB(255, 255, 255),
		TextDim = Color3.fromRGB(170, 170, 170),
		TextDark = Color3.fromRGB(86, 86, 86),
		Accent = Color3.fromRGB(150, 64, 255),
		Accent2 = Color3.fromRGB(238, 48, 255),
		AccentDark = Color3.fromRGB(80, 33, 152),
		Control = Color3.fromRGB(104, 104, 104),
	},

	Tween = {
		Fast = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
		Normal = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		Spring = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	}
}

Amphibia.Theme = Theme

--──────────────────────────────────────────────────--
-- Utils
--──────────────────────────────────────────────────--

local function New(className, props, children)
	local object = Instance.new(className)

	for prop, value in pairs(props or {}) do
		object[prop] = value
	end

	for _, child in ipairs(children or {}) do
		child.Parent = object
	end

	return object
end

local function Tween(object, info, properties)
	if not object or not object.Parent then
		return nil
	end

	local tween = Services.TweenService:Create(object, info or Theme.Tween.Normal, properties)
	tween:Play()
	return tween
end

local function AddCorner(parent, radius)
	return New("UICorner", {
		Parent = parent,
		CornerRadius = UDim.new(0, radius or 4),
	})
end

local function AddStroke(parent, color, thickness, transparency, zIndex)
	return New("UIStroke", {
		Parent = parent,
		Color = color or Theme.Colors.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ZIndex = zIndex or 1,
		LineJoinMode = Enum.LineJoinMode.Round,
	})
end

local function AddGradient(parent, data)
	local gradient = New("UIGradient", {
		Parent = parent,
		Rotation = data and data.Rotation or 0,
	})

	if data and data.Color then
		gradient.Color = data.Color
	end

	if data and data.Transparency then
		gradient.Transparency = data.Transparency
	end

	if data and data.Offset then
		gradient.Offset = data.Offset
	end

	return gradient
end

local function GenerateRandomName(length)
	length = tonumber(length) or 10
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-/_"
	local result = table.create(length)

	for i = 1, length do
		local randomIndex = math.random(1, #chars)
		result[i] = chars:sub(randomIndex, randomIndex)
	end

	return table.concat(result)
end

local function SafeCallback(callback, ...)
	if typeof(callback) ~= "function" then
		return
	end

	local ok, result = pcall(callback, ...)
	if not ok then
		warn("[Amphibia] Callback error:", result)
	end
end

local function ClampNumber(value, min, max)
	value = tonumber(value) or 0
	return math.clamp(value, min, max)
end

local function RoundToStep(value, step)
	step = tonumber(step) or 1
	if step <= 0 then
		return value
	end
	return math.floor((value / step) + 0.5) * step
end

local function ShortKeyName(keyCode)
	if typeof(keyCode) == "EnumItem" then
		return keyCode.Name
	end
	return tostring(keyCode or "None")
end

local function RemoveGradients(parent)
	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA("UIGradient") then
			child:Destroy()
		end
	end
end

local function CreateAnimatedGradient(parent, color1, color2)
	RemoveGradients(parent)

	local gradient = New("UIGradient", {
		Parent = parent,
		Rotation = 0,
		Offset = Vector2.new(-1, 0),
	})

	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color1),
		ColorSequenceKeypoint.new(0.5, color2),
		ColorSequenceKeypoint.new(1, color1),
	})

	task.spawn(function()
		while gradient.Parent == parent do
			gradient.Offset = Vector2.new(-1, 0)

			local move = Tween(
				gradient,
				TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
				{ Offset = Vector2.new(1, 0) }
			)

			if move then
				move.Completed:Wait()
			else
				break
			end
		end
	end)

	return gradient
end

local function SetTreeTransparency(root, alpha)
	for _, object in ipairs(root:GetDescendants()) do
		if object:IsA("Frame") then
			object.BackgroundTransparency = math.clamp(alpha, object.BackgroundTransparency, 1)
		elseif object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			object.TextTransparency = math.clamp(alpha, object.TextTransparency, 1)
		elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
			object.ImageTransparency = math.clamp(alpha, object.ImageTransparency, 1)
		elseif object:IsA("UIStroke") then
			object.Transparency = math.clamp(alpha, object.Transparency, 1)
		end
	end
end

local function CaptureFadeBase(root)
	local objects = { root }
	for _, object in ipairs(root:GetDescendants()) do
		table.insert(objects, object)
	end

	for _, object in ipairs(objects) do
		if object:IsA("GuiObject") and object:GetAttribute("BaseBackgroundTransparency") == nil then
			object:SetAttribute("BaseBackgroundTransparency", object.BackgroundTransparency)
		end

		if (object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")) and object:GetAttribute("BaseTextTransparency") == nil then
			object:SetAttribute("BaseTextTransparency", object.TextTransparency)
		end

		if (object:IsA("ImageLabel") or object:IsA("ImageButton")) and object:GetAttribute("BaseImageTransparency") == nil then
			object:SetAttribute("BaseImageTransparency", object.ImageTransparency)
		end

		if object:IsA("UIStroke") and object:GetAttribute("BaseTransparency") == nil then
			object:SetAttribute("BaseTransparency", object.Transparency)
		end
	end
end

local function TweenFadeTree(root, visible, info)
	if not root then
		return
	end

	local objects = { root }
	for _, object in ipairs(root:GetDescendants()) do
		table.insert(objects, object)
	end

	for _, object in ipairs(objects) do
		if object:IsA("GuiObject") then
			local targetBackground = visible and (object:GetAttribute("BaseBackgroundTransparency") or object.BackgroundTransparency) or 1
			Tween(object, info or Theme.Tween.Fast, { BackgroundTransparency = targetBackground })
		end

		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			local targetText = visible and (object:GetAttribute("BaseTextTransparency") or 0) or 1
			Tween(object, info or Theme.Tween.Fast, { TextTransparency = targetText })
		elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
			local targetImage = visible and (object:GetAttribute("BaseImageTransparency") or 0) or 1
			Tween(object, info or Theme.Tween.Fast, { ImageTransparency = targetImage })
		elseif object:IsA("UIStroke") then
			local targetStroke = visible and (object:GetAttribute("BaseTransparency") or 0) or 1
			Tween(object, info or Theme.Tween.Fast, { Transparency = targetStroke })
		end
	end
end

local function MakeDraggable(handle, target, options)
	options = options or {}

	if handle and handle:IsA("GuiObject") then
		handle.Active = true
	end

	if target and target:IsA("GuiObject") then
		target.Active = true
	end

	local dragging = false
	local dragStart = nil
	local startPosition = nil
	local connection = nil
	local activeTween = nil

	local function setPosition(position)
		if options.Smooth then
			if activeTween then
				activeTween:Cancel()
			end

			activeTween = Services.TweenService:Create(
				target,
				TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Position = position }
			)
			activeTween:Play()
		else
			target.Position = position
		end
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		dragging = true
		dragStart = input.Position
		startPosition = target.Position

		if connection then
			connection:Disconnect()
		end

		connection = Services.UserInputService.InputChanged:Connect(function(moveInput)
			if not dragging then
				return
			end

			if moveInput.UserInputType ~= Enum.UserInputType.MouseMovement and moveInput.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			local delta = moveInput.Position - dragStart
			setPosition(UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			))
		end)

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				if connection then
					connection:Disconnect()
					connection = nil
				end
			end
		end)
	end)
end

local function CreateBaseControl(section, config, explorerName)
	config = config or {}

	local holder = New("Frame", {
		Parent = section.Holder,
		Name = config.ExplorerName or explorerName or "Control",
		LayoutOrder = config.LayoutOrder or 0,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 265, 0, 29),
		AutomaticSize = Enum.AutomaticSize.None,
		ZIndex = 1,
	})

	local hitbox = New("TextButton", {
		Parent = holder,
		Name = "Hitbox",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 29),
		Text = "",
		TextTransparency = 1,
		TextSize = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		ZIndex = 2,
	})

	local nameText = New("TextLabel", {
		Parent = hitbox,
		Name = "NameText",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Font = Theme.Font,
		BorderSizePixel = 0,
		TextColor3 = Theme.Colors.Text,
		Text = config.Name or "Control",
		TextSize = 14,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 0,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2,
	})

	hitbox.MouseEnter:Connect(function()
		Tween(nameText, Theme.Tween.Fast, { TextColor3 = Color3.fromRGB(179, 179, 179) })
	end)

	hitbox.MouseLeave:Connect(function()
		Tween(nameText, Theme.Tween.Fast, { TextColor3 = Theme.Colors.Text })
	end)

	section.Window:_RegisterSearchable({
		Name = config.Name or explorerName or "Control",
		Object = holder,
		Section = section,
		Tab = section.Tab,
	})

	return holder, hitbox, nameText
end

--──────────────────────────────────────────────────--
-- Window
--──────────────────────────────────────────────────--

local Window = {}
Window.__index = Window

local Category = {}
Category.__index = Category

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

function Amphibia:CreateWindow(config)
	return Amphibia.CreateWindow(config)
end

function Amphibia.CreateWindow(config)
	config = config or {}

	local self = setmetatable({}, Window)

	self.Name = config.Name or "Amphibia'"
	self.Icon = config.Icon or "rbxassetid://76305975133668"
	self.Parent = config.Parent or CoreGui
	self.Size = config.Size or UDim2.new(0, 767, 0, 484)
	self.Position = config.Position or UDim2.new(0.5, 0, 0.5, 0)
	self.Categories = {}
	self.Tabs = {}
	self.Searchables = {}
	self.NotificationStack = {}
	self.ActiveTab = nil
	self.Destroyed = false
	self.Visible = true

	self.Gui = New("ScreenGui", {
		Parent = self.Parent,
		Enabled = true,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = config.DisplayOrder or 0,
		Name = config.GuiName or GenerateRandomName(10),
	})

	self.DarkFrame = New("Frame", {
		Parent = self.Gui,
		Name = "DarkFrame",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.35,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		Visible = config.DarkBackground == true,
		ZIndex = -100,
	})

	self.Main = New("Frame", {
		Parent = self.Gui,
		Name = "MainBg",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = self.Position,
		Size = self.Size,
		BackgroundTransparency = 0,
		BackgroundColor3 = Theme.Colors.Background,
		BorderSizePixel = 0,
		ZIndex = 0,
	})

	AddCorner(self.Main, 4)
	AddGradient(self.Main, {
		Rotation = -90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		})
	})

	self.TabsContentFolder = New("Folder", {
		Parent = self.Main,
		Name = "TabsContentFolder",
	})

	self.HeaderFolder = New("Folder", {
		Parent = self.Main,
		Name = "HeaderContent",
	})

	self.Header = New("Frame", {
		Parent = self.HeaderFolder,
		Name = "HeaderBgFrame",
		BackgroundColor3 = Theme.Colors.Header,
		BackgroundTransparency = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 48),
		ZIndex = 0,
	})

	AddCorner(self.Header, 4)
	AddGradient(self.Header, {
		Rotation = -90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(95, 95, 95)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		})
	})

	local headerStroke = AddStroke(self.Header, Theme.Colors.Accent, 1, 0, 3)
	AddGradient(headerStroke, {
		Rotation = -90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0, 0),
			NumberSequenceKeypoint.new(0.05, 1, 0),
			NumberSequenceKeypoint.new(1, 1, 0),
		})
	})

	self.HeaderGlow = New("Frame", {
		Parent = self.HeaderFolder,
		Name = "HeaderStrokeGlow",
		BackgroundColor3 = Theme.Colors.Accent,
		BackgroundTransparency = 0.25,
		ZIndex = 5,
		Position = UDim2.new(0, 0, 0, 48),
		Size = UDim2.new(0, 767, 0, 17),
	})

	AddGradient(self.HeaderGlow, {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.727, 0),
			NumberSequenceKeypoint.new(1, 1, 0),
		})
	})

	self.ScriptImage = New("ImageLabel", {
		Parent = self.HeaderFolder,
		Name = "ScriptImage",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0.013, 0),
		Size = UDim2.new(0, 38, 0, 38),
		Image = self.Icon,
		ImageTransparency = 0,
		ZIndex = 5,
	})

	self.Title = New("TextLabel", {
		Parent = self.HeaderFolder,
		Name = "ScriptName",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.05, 0, 0.012, 0),
		Size = UDim2.new(0, 145, 0, 34),
		ZIndex = 5,
		Font = Theme.Font,
		Text = self.Name,
		TextSize = 20,
		TextColor3 = Theme.Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local titleStroke = AddStroke(self.Title, Color3.fromRGB(255, 255, 255), 0.4, 0, 1)
	AddGradient(titleStroke, {
		Rotation = -50,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Theme.Colors.Accent),
			ColorSequenceKeypoint.new(1, Theme.Colors.Accent2),
		})
	})

	self.TitleShadow = New("TextLabel", {
		Parent = self.Title,
		Name = "TextShadow",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, -0.1, 0),
		Size = UDim2.new(0, 96, 0, 47),
		ZIndex = 5,
		Font = Theme.Font,
		Text = self.Name,
		TextSize = 20,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	AddGradient(self.TitleShadow, {
		Rotation = -90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0, 0),
			NumberSequenceKeypoint.new(0.5, 0.369, 0),
			NumberSequenceKeypoint.new(1, 0, 0),
		})
	})

	self.SearchFrame = New("Frame", {
		Parent = self.Main,
		Name = "SearchFrame",
		Position = UDim2.new(0.269, 0, 0.017, 0),
		Size = UDim2.new(0, 355, 0, 31),
		ZIndex = 10,
		BackgroundTransparency = 0,
		BackgroundColor3 = Theme.Colors.Text,
		BorderSizePixel = 0,
	})

	AddCorner(self.SearchFrame, 4)
	AddGradient(self.SearchFrame, {
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(27, 27, 27)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(29, 29, 29)),
		})
	})
	AddStroke(self.SearchFrame, Theme.Colors.Stroke, 1, 0, 1)

	self.SearchImage = New("ImageLabel", {
		Parent = self.SearchFrame,
		Name = "SearchImage",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.017, 0, 0.194, 0),
		Size = UDim2.new(0, 20, 0, 20),
		Image = Theme.Images.Search,
		ImageTransparency = 0.6,
		ZIndex = 11,
	})

	self.SearchBox = New("TextBox", {
		Parent = self.SearchFrame,
		Name = "SearchTextBox",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -34, 1, 0),
		Position = UDim2.new(0, 34, 0, 0),
		ZIndex = 11,
		Font = Theme.Font,
		TextColor3 = Theme.Colors.Text,
		PlaceholderColor3 = Color3.fromRGB(155, 155, 155),
		TextSize = 14,
		Text = "",
		PlaceholderText = "Search",
		TextTransparency = 0.15,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		TextWrapped = true,
	})

	self.SettingsButton = New("ImageButton", {
		Parent = self.HeaderFolder,
		Name = "SettingsButton",
		Position = UDim2.new(0.74, 0, 0.024, 0),
		Size = UDim2.new(0, 25, 0, 25),
		BackgroundTransparency = 1,
		Image = Theme.Images.Settings,
		ImageTransparency = 0.84,
		ZIndex = 10,
		AutoButtonColor = false,
	})

	self.CloseButton = New("ImageButton", {
		Parent = self.HeaderFolder,
		Name = "CloseButton",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.944, 0, 0.012, 0),
		Size = UDim2.new(0, 36, 0, 36),
		ZIndex = 10,
		ImageTransparency = 0.84,
		Image = Theme.Images.Close,
		AutoButtonColor = false,
	})

	self.TabsBg = New("Frame", {
		Parent = self.Main,
		Name = "TabsBg",
		Position = UDim2.new(0, 0, 0, 48),
		Size = UDim2.new(0, 185, 0, 436),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		ZIndex = 1,
	})

	AddGradient(self.TabsBg, {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0, 0),
			NumberSequenceKeypoint.new(1, 1, 0),
		})
	})

	New("UIListLayout", {
		Parent = self.TabsBg,
		Padding = UDim.new(0, 15),
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	})

	New("UIPadding", {
		Parent = self.TabsBg,
		PaddingLeft = UDim.new(0, 20),
		PaddingTop = UDim.new(0, 20),
	})

	self.HeaderSplitter = New("Frame", {
		Parent = self.Main,
		Name = "HeaderSplitter",
		BorderSizePixel = 0,
		BackgroundColor3 = Theme.Colors.Accent,
		BackgroundTransparency = 0.2,
		Position = UDim2.new(0, 0, 0, 48),
		Size = UDim2.new(0, 185, 0, 1),
		ZIndex = 4,
	})

	AddGradient(self.HeaderSplitter, {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1, 0),
			NumberSequenceKeypoint.new(1, 0, 0),
		})
	})

	self.TabsSplitter = New("Frame", {
		Parent = self.Main,
		Name = "TabsSplitter",
		Position = UDim2.new(0, 185, 0, 48),
		Size = UDim2.new(0, 1, 0, 434),
		BackgroundColor3 = Color3.fromRGB(85, 85, 85),
		BorderSizePixel = 0,
		ZIndex = 2,
	})

	AddGradient(self.TabsSplitter, {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0, 0),
			NumberSequenceKeypoint.new(1, 1, 0),
		})
	})

	self.NotificationHolder = New("Frame", {
		Parent = self.Gui,
		Name = "NotificationHolder",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -20, 1, -20),
		Size = UDim2.new(0, 280, 1, -40),
		BackgroundTransparency = 1,
		ZIndex = 1000,
	})

	New("UIListLayout", {
		Parent = self.NotificationHolder,
		FillDirection = Enum.FillDirection.Vertical,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
	})

	self:_BuildCloseConfirm()
	self:_BuildColorPicker()

	MakeDraggable(self.Header, self.Main, { Smooth = true })

	self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:_ApplySearch(self.SearchBox.Text)
	end)

	self.SettingsButton.MouseEnter:Connect(function()
		Tween(self.SettingsButton, Theme.Tween.Fast, { ImageTransparency = 0.35 })
	end)

	self.SettingsButton.MouseLeave:Connect(function()
		Tween(self.SettingsButton, Theme.Tween.Fast, { ImageTransparency = 0.84 })
	end)

	self.SettingsButton.MouseButton1Click:Connect(function()
		self:Notify({
			Title = "Settings",
			Description = "Settings panel is reserved for future options.",
			Duration = 3,
		})
	end)

	self.CloseButton.MouseEnter:Connect(function()
		Tween(self.CloseButton, Theme.Tween.Fast, { ImageTransparency = 0.35 })
	end)

	self.CloseButton.MouseLeave:Connect(function()
		Tween(self.CloseButton, Theme.Tween.Fast, { ImageTransparency = 0.84 })
	end)

	self.CloseButton.MouseButton1Click:Connect(function()
		self:_ShowCloseConfirm()
	end)

	Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == (config.ToggleKey or Enum.KeyCode.RightShift) then
			self:SetVisible(not self.Visible)
		end
	end)

	self.Main.Size = UDim2.new(0, 740, 0, 462)
	Tween(self.Main, Theme.Tween.Spring, { Size = self.Size })

	return self
end

function Window:SetVisible(value)
	self.Visible = value and true or false
	self.Gui.Enabled = self.Visible
end

function Window:Destroy()
	self.Destroyed = true
	if self.Gui then
		self.Gui:Destroy()
	end
end

function Window:_RegisterSearchable(data)
	table.insert(self.Searchables, data)
end

function Window:_ApplySearch(query)
	local rawQuery = tostring(query or "")
	local normalizedQuery = string.lower(rawQuery):gsub("^%s+", ""):gsub("%s+$", "")

	local function normalize(text)
		return string.lower(tostring(text or "")):gsub("[_%-%.]", " "):gsub("%s+", " ")
	end

	local function splitTokens(text)
		local tokens = {}
		for token in normalize(text):gmatch("%S+") do
			table.insert(tokens, token)
		end
		return tokens
	end

	local function isSubsequence(needle, haystack)
		needle = normalize(needle):gsub("%s+", "")
		haystack = normalize(haystack):gsub("%s+", "")

		if needle == "" then
			return true
		end

		local index = 1
		for i = 1, #haystack do
			if haystack:sub(i, i) == needle:sub(index, index) then
				index += 1
				if index > #needle then
					return true
				end
			end
		end

		return false
	end

	local function score(data)
		local name = normalize(data.Name)
		local sectionName = data.Section and normalize(data.Section.Name) or ""
		local tabName = data.Tab and normalize(data.Tab.Name) or ""
		local full = table.concat({ name, sectionName, tabName }, " ")

		if normalizedQuery == "" then
			return 1
		end

		if name == normalizedQuery then
			return 100
		end

		if name:find(normalizedQuery, 1, true) then
			return 80
		end

		if full:find(normalizedQuery, 1, true) then
			return 60
		end

		local tokens = splitTokens(normalizedQuery)
		local matchedTokens = 0

		for _, token in ipairs(tokens) do
			if full:find(token, 1, true) or isSubsequence(token, full) then
				matchedTokens += 1
			end
		end

		if #tokens > 0 and matchedTokens == #tokens then
			return 40 + matchedTokens
		end

		if isSubsequence(normalizedQuery, name) then
			return 25
		end

		return 0
	end

	for _, tab in pairs(self.Tabs) do
		tab.SearchMatchCount = 0
		tab.SearchScore = 0
	end

	if normalizedQuery == "" then
		for _, data in ipairs(self.Searchables) do
			if data.Object and data.Object.Parent then
				data.Object.Visible = true
			end
		end

		for _, tab in pairs(self.Tabs) do
			for _, section in ipairs(tab.Sections) do
				section.Frame.Visible = true
			end
		end

		if self.ActiveTab then
			self:SelectTab(self.ActiveTab.Name)
		end

		return
	end

	local bestTab = nil
	local bestScore = 0

	for _, data in ipairs(self.Searchables) do
		local itemScore = score(data)
		local matched = itemScore > 0

		if data.Object and data.Object.Parent then
			data.Object.Visible = matched
		end

		if matched and data.Tab then
			data.Tab.SearchMatchCount = (data.Tab.SearchMatchCount or 0) + 1
			data.Tab.SearchScore = math.max(data.Tab.SearchScore or 0, itemScore)

			if itemScore > bestScore then
				bestScore = itemScore
				bestTab = data.Tab
			end
		end
	end

	for _, tab in pairs(self.Tabs) do
		for _, section in ipairs(tab.Sections) do
			local sectionMatched = score({
				Name = section.Name,
				Section = section,
				Tab = tab,
			}) > 0

			local hasVisible = sectionMatched
			for _, child in ipairs(section.Holder:GetChildren()) do
				if child:IsA("GuiObject") and child.Visible then
					hasVisible = true
					break
				end
			end

			section.Frame.Visible = hasVisible
		end
	end

	if bestTab and self.ActiveTab ~= bestTab then
		self:SelectTab(bestTab.Name)
	end
end

function Window:_BuildCloseConfirm()
	self.ConfirmOverlay = New("Frame", {
		Parent = self.Main,
		Name = "CloseConfirmOverlay",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		ZIndex = 200,
	})

	self.ConfirmBox = New("Frame", {
		Parent = self.ConfirmOverlay,
		Name = "ConfirmBox",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 286, 0, 132),
		BackgroundColor3 = Theme.Colors.Background,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ZIndex = 201,
	})

	AddCorner(self.ConfirmBox, 4)
	AddGradient(self.ConfirmBox, {
		Rotation = -90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		})
	})
	AddStroke(self.ConfirmBox, Color3.fromRGB(47, 47, 47), 2, 0, 1)
	AddStroke(self.ConfirmBox, Color3.fromRGB(0, 0, 0), 1, 0.18, 2)

	local title = New("TextLabel", {
		Parent = self.ConfirmBox,
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 13),
		Size = UDim2.new(1, -28, 0, 25),
		Font = Theme.Font,
		Text = "Close Amphibia'?",
		TextSize = 15,
		TextColor3 = Theme.Colors.Text,
		TextTransparency = 0,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 202,
	})

	local desc = New("TextLabel", {
		Parent = self.ConfirmBox,
		Name = "Description",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 40),
		Size = UDim2.new(1, -28, 0, 28),
		Font = Theme.Font,
		Text = "Are u sure yu want kill Amphibia' ??",
		TextSize = 11,
		TextColor3 = Color3.fromRGB(160, 160, 160),
		TextTransparency = 0,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 202,
	})

	local yes = New("TextButton", {
		Parent = self.ConfirmBox,
		Name = "YesButton",
		Position = UDim2.new(0, 14, 1, -42),
		Size = UDim2.new(0, 112, 0, 28),
		BackgroundColor3 = Color3.fromRGB(26, 26, 26),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Font = Theme.Font,
		Text = "Yeah",
		TextSize = 14,
		TextColor3 = Theme.Colors.Text,
		TextTransparency = 0,
		AutoButtonColor = false,
		ZIndex = 202,
	})
	AddCorner(yes, 4)

	local cancel = New("TextButton", {
		Parent = self.ConfirmBox,
		Name = "CancelButton",
		Position = UDim2.new(1, -126, 1, -42),
		Size = UDim2.new(0, 112, 0, 28),
		BackgroundColor3 = Color3.fromRGB(38, 38, 38),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Font = Theme.Font,
		Text = "no",
		TextSize = 13,
		TextColor3 = Theme.Colors.Text,
		TextTransparency = 0,
		AutoButtonColor = false,
		ZIndex = 202,
	})
	AddCorner(cancel, 4)

	self.ConfirmObjects = {
		self.ConfirmBox,
		title,
		desc,
		yes,
		cancel,
	}

	CaptureFadeBase(self.ConfirmBox)
	TweenFadeTree(self.ConfirmBox, false, TweenInfo.new(0, Enum.EasingStyle.Linear, Enum.EasingDirection.Out))

	yes.MouseButton1Click:Connect(function()
		self:_HideCloseConfirm()
		self:SetVisible(false)
	end)

	cancel.MouseButton1Click:Connect(function()
		self:_HideCloseConfirm()
	end)
end

function Window:_ShowCloseConfirm()
	self.ConfirmOverlay.Visible = true
	self.ConfirmBox.Size = UDim2.new(0, 270, 0, 122)

	Tween(self.ConfirmOverlay, Theme.Tween.Fast, {
		BackgroundTransparency = 0.45,
	})

	Tween(self.ConfirmBox, Theme.Tween.Spring, {
		Size = UDim2.new(0, 286, 0, 132),
	})

	TweenFadeTree(self.ConfirmBox, true, Theme.Tween.Fast)
end

function Window:_HideCloseConfirm()
	Tween(self.ConfirmOverlay, Theme.Tween.Fast, {
		BackgroundTransparency = 1,
	})

	TweenFadeTree(self.ConfirmBox, false, Theme.Tween.Fast)

	task.delay(0.18, function()
		if self.ConfirmOverlay then
			self.ConfirmOverlay.Visible = false
		end
	end)
end

--──────────────────────────────────────────────────--
-- Categories / Tabs / Sections
--──────────────────────────────────────────────────--

function Window:CreateCategory(name)
	local category = setmetatable({}, Category)
	category.Window = self
	category.Name = name or "Category"
	category.Tabs = {}

	category.Frame = New("Frame", {
		Parent = self.TabsBg,
		Name = category.Name,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 100, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 1,
	})

	New("UIListLayout", {
		Parent = category.Frame,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	category.TabsHolder = New("Frame", {
		Parent = category.Frame,
		Name = "TabsHolder",
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		ZIndex = 1,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
	})

	New("UIListLayout", {
		Parent = category.TabsHolder,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	New("UIPadding", {
		Parent = category.TabsHolder,
		PaddingLeft = UDim.new(0, 15),
		PaddingTop = UDim.new(0, 5),
	})

	category.Text = New("TextLabel", {
		Parent = category.Frame,
		Name = "CategoryText",
		BackgroundTransparency = 1,
		TextColor3 = Theme.Colors.Text,
		Size = UDim2.new(0, 84, 0, 10),
		ZIndex = 1,
		Font = Theme.Font,
		Text = category.Name,
		TextSize = 15,
		TextTransparency = 0.7,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 1,
	})

	table.insert(self.Categories, category)
	return category
end

function Category:CreateTab(name)
	local tab = setmetatable({}, Tab)
	tab.Window = self.Window
	tab.Category = self
	tab.Name = name or "Tab"
	tab.Sections = {}
	tab.SearchMatchCount = 0

	tab.Button = New("TextButton", {
		Parent = self.TabsHolder,
		Name = tab.Name,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 111, 0, 22),
		ZIndex = 2,
		Font = Theme.Font,
		Text = tab.Name,
		TextSize = 15,
		TextColor3 = Theme.Colors.Text,
		TextTransparency = 0,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextStrokeTransparency = 1,
		AutoButtonColor = false,
	})

	tab.Content = New("ScrollingFrame", {
		Parent = self.Window.TabsContentFolder,
		Name = tab.Name .. "TabContent",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 185, 0, 48),
		Size = UDim2.new(0, 582, 0, 436),
		ZIndex = 1,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarImageTransparency = 1,
		ScrollBarThickness = 0,
		VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
		Visible = false,
		BorderSizePixel = 0,
	})

	tab.LeftColumn = New("Frame", {
		Parent = tab.Content,
		Name = "LeftColumn",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 285, 0, 0),
		ZIndex = 1,
	})

	tab.RightColumn = New("Frame", {
		Parent = tab.Content,
		Name = "RightColumn",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Position = UDim2.new(0.496, 0, 0, 0),
		Size = UDim2.new(0, 285, 0, 0),
		ZIndex = 1,
	})

	for _, column in ipairs({ tab.LeftColumn, tab.RightColumn }) do
		New("UIListLayout", {
			Parent = column,
			Padding = UDim.new(0, 10),
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
		})

		New("UIPadding", {
			Parent = column,
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 10),
		})
	end

	tab.Button.MouseButton1Click:Connect(function()
		tab.Window:SelectTab(tab.Name)
	end)

	tab.Button.MouseEnter:Connect(function()
		if tab.Window.ActiveTab ~= tab then
			Tween(tab.Button, Theme.Tween.Fast, {
				TextColor3 = Color3.fromRGB(185, 185, 185),
				TextTransparency = 0,
			})
		end
	end)

	tab.Button.MouseLeave:Connect(function()
		if tab.Window.ActiveTab ~= tab then
			Tween(tab.Button, Theme.Tween.Fast, {
				TextColor3 = Theme.Colors.Text,
				TextTransparency = 0,
			})
		end
	end)

	self.Window.Tabs[tab.Name] = tab
	table.insert(self.Tabs, tab)

	if not self.Window.ActiveTab then
		self.Window:SelectTab(tab.Name)
	end

	return tab
end

function Window:SelectTab(name)
	local selected = self.Tabs[name]
	if not selected then
		warn("[Amphibia] Tab not found:", name)
		return
	end

	for _, tab in pairs(self.Tabs) do
		local active = tab == selected
		tab.Content.Visible = active
		tab.Button:SetAttribute("Active", active)
		RemoveGradients(tab.Button)

		if active then
			tab.Button.TextTransparency = 0
			tab.Button.TextColor3 = Theme.Colors.Text
			CreateAnimatedGradient(tab.Button, Color3.fromRGB(165, 121, 218), Color3.fromRGB(137, 69, 221))
		else
			tab.Button.TextTransparency = 0
			tab.Button.TextColor3 = Theme.Colors.Text
		end
	end

	self.ActiveTab = selected
end

function Tab:CreateSection(name, side)
	local section = setmetatable({}, Section)
	section.Tab = self
	section.Window = self.Window
	section.Name = name or "Section"
	section.Side = string.lower(tostring(side or "left"))

	local parentColumn = self.LeftColumn
	if section.Side == "right" or section.Side == "r" then
		parentColumn = self.RightColumn
	end

	section.Frame = New("Frame", {
		Parent = parentColumn,
		Name = section.Name,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0,
		BackgroundColor3 = Theme.Colors.Section,
		Size = UDim2.new(0, 276, 0, 0),
		ZIndex = 1,
		BorderSizePixel = 0,
	})

	AddCorner(section.Frame, 4)
	AddGradient(section.Frame, {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0, 0),
			NumberSequenceKeypoint.new(1, 0.831, 0),
		})
	})

	New("UISizeConstraint", {
		Parent = section.Frame,
		MinSize = Vector2.new(0, 60),
	})

	AddStroke(section.Frame, Color3.fromRGB(0, 0, 0), 1, 0.14, 2)
	local stroke2 = AddStroke(section.Frame, Color3.fromRGB(40, 40, 40), 2, 0, 1)
	AddGradient(stroke2, {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0, 0),
			NumberSequenceKeypoint.new(1, 0.444, 0),
		})
	})

	section.Header = New("Frame", {
		Parent = section.Frame,
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 276, 0, 35),
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex = 1,
	})

	New("UIListLayout", {
		Parent = section.Header,
		Padding = UDim.new(0, 7),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
	})

	New("UIPadding", {
		Parent = section.Header,
		PaddingTop = UDim.new(0, 3),
	})

	section.Title = New("TextLabel", {
		Parent = section.Header,
		Name = "SectionName",
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Size = UDim2.new(0, 215, 0, 25),
		ZIndex = 1,
		Font = Theme.Font,
		Text = section.Name,
		TextColor3 = Theme.Colors.Text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	New("UIPadding", {
		Parent = section.Title,
		PaddingLeft = UDim.new(0, 7),
	})

	section.Line = New("Frame", {
		Parent = section.Header,
		Name = "Line",
		BackgroundColor3 = Color3.fromRGB(100, 100, 100),
		Size = UDim2.new(0, 276, 0, 1),
		ZIndex = 1,
		LayoutOrder = 2,
		BorderSizePixel = 0,
	})

	AddGradient(section.Line, {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1, 0),
			NumberSequenceKeypoint.new(0.1, 0.5, 0),
			NumberSequenceKeypoint.new(0.9, 0.5, 0),
			NumberSequenceKeypoint.new(1, 1, 0),
		})
	})

	section.Holder = New("Frame", {
		Parent = section.Frame,
		Name = "ButtonHolderFrame",
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(0, 276, 0, 0),
		ZIndex = 1,
	})

	New("UIListLayout", {
		Parent = section.Holder,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	New("UIPadding", {
		Parent = section.Holder,
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 43),
	})

	table.insert(self.Sections, section)
	return section
end

--──────────────────────────────────────────────────--
-- Components
--──────────────────────────────────────────────────--

function Section:CreateButton(config)
	if typeof(config) == "string" then
		config = { Name = config }
	end
	config = config or {}

	local holder, hitbox, nameText = CreateBaseControl(self, {
		Name = config.Name or "Button",
		LayoutOrder = config.LayoutOrder,
		ExplorerName = config.ExplorerName,
	}, "Button")

	hitbox.MouseButton1Click:Connect(function()
		SafeCallback(config.Callback)
	end)

	return {
		Instance = holder,
		Button = hitbox,
		SetName = function(_, text)
			nameText.Text = tostring(text)
		end,
		Destroy = function()
			holder:Destroy()
		end,
	}
end

function Section:CreateToggle(config)
	if typeof(config) == "string" then
		config = { Name = config }
	end
	config = config or {}

	local holder, hitbox, nameText = CreateBaseControl(self, {
		Name = config.Name or "Toggle",
		LayoutOrder = config.LayoutOrder,
		ExplorerName = config.ExplorerName,
	}, "Toggle")

	local state = config.Default == true

	local toggleFrame = New("Frame", {
		Parent = hitbox,
		Name = "ToggleFrame",
		BackgroundColor3 = Color3.fromRGB(77, 77, 77),
		BorderSizePixel = 0,
		Position = UDim2.new(0.909, 0, 0.172, 0),
		Size = UDim2.new(0, 18, 0, 18),
		ZIndex = 3,
	})

	AddCorner(toggleFrame, 1)
	AddGradient(toggleFrame, {
		Rotation = -90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(62, 62, 62)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		})
	})
	AddStroke(toggleFrame, Color3.fromRGB(54, 54, 54), 2, 0, 1)
	AddStroke(toggleFrame, Color3.fromRGB(0, 0, 0), 1, 0.29, 2)

	local active = New("Frame", {
		Parent = toggleFrame,
		Name = "Active",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0),
		ZIndex = 4,
		Visible = false,
	})

	AddCorner(active, 1)
	AddGradient(active, {
		Rotation = -90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(111, 59, 185)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(144, 70, 255)),
		})
	})
	AddStroke(active, Color3.fromRGB(0, 0, 0), 1, 0.46, 1)

	local api = {}

	local function render(skipCallback)
		if state then
			active.Visible = true
			Tween(active, Theme.Tween.Spring, { Size = UDim2.new(0, 14, 0, 14) })
			Tween(nameText, Theme.Tween.Fast, { TextColor3 = Color3.fromRGB(153, 70, 255) })
		else
			local hideTween = Tween(active, Theme.Tween.Fast, { Size = UDim2.new(0, 0, 0, 0) })
			if hideTween then
				hideTween.Completed:Once(function()
					if not state and active then
						active.Visible = false
					end
				end)
			else
				active.Visible = false
			end
			Tween(nameText, Theme.Tween.Fast, { TextColor3 = Theme.Colors.Text })
		end

		if not skipCallback then
			SafeCallback(config.Callback, state)
		end
	end

	function api:Set(value)
		state = value and true or false
		render(false)
	end

	function api:Get()
		return state
	end

	function api:Toggle()
		self:Set(not state)
	end

	api.Instance = holder
	api.Button = hitbox
	api.Destroy = function()
		holder:Destroy()
	end

	hitbox.MouseButton1Click:Connect(function()
		api:Toggle()
	end)

	render(true)
	SafeCallback(config.Callback, state)

	return api
end

function Section:CreateDropdown(config)
	if typeof(config) == "string" then
		config = { Name = config }
	end
	config = config or {}

	local options = config.Options or {}
	local multi = config.Multi == true
	local selected = multi and {} or (config.Default or options[1])
	local opened = false

	local holder, hitbox = CreateBaseControl(self, {
		Name = config.Name or "Dropdown",
		LayoutOrder = config.LayoutOrder,
		ExplorerName = config.ExplorerName,
	}, "Dropdown")

	holder.AutomaticSize = Enum.AutomaticSize.Y

	local valueBadge = New("Frame", {
		Parent = hitbox,
		Name = "ValueBadge",
		BackgroundColor3 = Color3.fromRGB(24, 24, 24),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.665, 0, 0.17, 0),
		Size = UDim2.new(0, 62, 0, 18),
		ZIndex = 3,
	})
	local valueText = New("TextLabel", {
		Parent = valueBadge,
		Name = "ValueText",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		Font = Theme.Font,
		Text = "",
		TextSize = 11,
		TextColor3 = Color3.fromRGB(170, 170, 170),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 4,
	})

	local arrow = New("ImageLabel", {
		Parent = hitbox,
		Name = "SettingsImageLabel",
		Image = Theme.Images.TripleDot,
		Position = UDim2.new(0.915, 0, 0.131, 0),
		Size = UDim2.new(0, 18, 0, 18),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ImageTransparency = 0.26,
		ImageColor3 = Theme.Colors.Text,
		ZIndex = 4,
	})

	local listFrame = New("Frame", {
		Parent = holder,
		Name = "DropdownList",
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 31),
		Size = UDim2.new(0, 245, 0, 0),
		Visible = false,
		ClipsDescendants = true,
		ZIndex = 5,
	})

	New("UIListLayout", {
		Parent = listFrame,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
	})

	local api = {}

	local function stringifySelection()
		if multi then
			local list = {}
			for option, enabled in pairs(selected) do
				if enabled then
					table.insert(list, tostring(option))
				end
			end
			table.sort(list)
			return #list > 0 and table.concat(list, ", ") or "None"
		end

		return tostring(selected or "None")
	end

	local function updateValue()
		valueText.Text = stringifySelection()
	end

	local function rebuildOptions()
		for _, child in ipairs(listFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		for index, option in ipairs(options) do
			local optionText = tostring(option)

			local optionButton = New("TextButton", {
				Parent = listFrame,
				Name = optionText,
				LayoutOrder = index,
				BackgroundColor3 = Color3.fromRGB(25, 25, 25),
				BackgroundTransparency = 0.25,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 245, 0, 24),
				Font = Theme.Font,
				Text = "   " .. optionText,
				TextSize = 12,
				TextColor3 = Theme.Colors.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutoButtonColor = false,
				ZIndex = 6,
			})
			AddCorner(optionButton, 3)
			AddStroke(optionButton, Color3.fromRGB(32, 32, 32), 1, 0.25, 1)

			local optionAccent = New("Frame", {
				Parent = optionButton,
				Name = "Accent",
				BackgroundColor3 = Theme.Colors.Accent,
				BackgroundTransparency = 0.15,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0.18, 0),
				Size = UDim2.new(0, 2, 0.64, 0),
				Visible = false,
				ZIndex = 7,
			})
			AddCorner(optionAccent, 99)

			optionButton.MouseEnter:Connect(function()
				Tween(optionButton, Theme.Tween.Fast, { BackgroundTransparency = 0.05 })
			end)

			optionButton.MouseLeave:Connect(function()
				Tween(optionButton, Theme.Tween.Fast, { BackgroundTransparency = 0.25 })
			end)

			optionButton.MouseButton1Click:Connect(function()
				if multi then
					selected[option] = not selected[option]
				else
					selected = option
					api:Close()
				end

				updateValue()
				SafeCallback(config.Callback, selected)
			end)
		end
	end

	function api:Open()
		opened = true
		listFrame.Visible = true
		Tween(arrow, Theme.Tween.Fast, { Rotation = 90 })
		Tween(listFrame, Theme.Tween.Smooth, {
			Size = UDim2.new(0, 245, 0, math.min(#options * 26, 156))
		})
	end

	function api:Close()
		opened = false
		Tween(arrow, Theme.Tween.Fast, { Rotation = 0 })
		local closeTween = Tween(listFrame, Theme.Tween.Fast, {
			Size = UDim2.new(0, 245, 0, 0)
		})
		if closeTween then
			closeTween.Completed:Once(function()
				if not opened and listFrame then
					listFrame.Visible = false
				end
			end)
		end
	end

	function api:Set(value)
		if multi and typeof(value) == "table" then
			selected = value
		else
			selected = value
		end
		updateValue()
		SafeCallback(config.Callback, selected)
	end

	function api:Get()
		return selected
	end

	function api:SetOptions(newOptions)
		options = newOptions or {}
		rebuildOptions()
		updateValue()
	end

	api.Instance = holder
	api.Button = hitbox
	api.Destroy = function()
		holder:Destroy()
	end

	hitbox.MouseButton1Click:Connect(function()
		if opened then
			api:Close()
		else
			api:Open()
		end
	end)

	rebuildOptions()
	updateValue()

	return api
end

function Section:CreateTextbox(config)
	if typeof(config) == "string" then
		config = { Name = config }
	end
	config = config or {}

	local holder, hitbox = CreateBaseControl(self, {
		Name = config.Name or "Textbox",
		LayoutOrder = config.LayoutOrder,
		ExplorerName = config.ExplorerName,
	}, "Textbox")

	local textbox = New("TextBox", {
		Parent = hitbox,
		Name = "TextBox",
		BackgroundColor3 = Theme.Colors.Control,
		BorderSizePixel = 0,
		Position = UDim2.new(0.639, 0, 0.207, 0),
		Size = UDim2.new(0, 90, 0, 17),
		Font = Theme.Font,
		TextColor3 = Theme.Colors.Text,
		PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
		PlaceholderText = config.Placeholder or "",
		Text = tostring(config.Default or ""),
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 0.44,
		TextScaled = true,
		TextWrapped = true,
		ClearTextOnFocus = config.ClearTextOnFocus == true,
		ZIndex = 3,
	})

	AddCorner(textbox, 4)
	AddGradient(textbox, {
		Rotation = -90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 120, 120)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		})
	})
	AddStroke(textbox, Color3.fromRGB(61, 61, 61), 2, 0, 1).ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	AddStroke(textbox, Color3.fromRGB(0, 0, 0), 1, 0.43, 2).ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	textbox.Focused:Connect(function()
		Tween(textbox, Theme.Tween.Fast, { BackgroundColor3 = Color3.fromRGB(125, 125, 125) })
	end)

	textbox.FocusLost:Connect(function(enterPressed)
		Tween(textbox, Theme.Tween.Fast, { BackgroundColor3 = Theme.Colors.Control })
		SafeCallback(config.Callback, textbox.Text, enterPressed)
	end)

	local api = {}
	api.Instance = holder
	api.TextBox = textbox
	function api:Set(text)
		textbox.Text = tostring(text or "")
	end
	function api:Get()
		return textbox.Text
	end
	function api:Destroy()
		holder:Destroy()
	end

	return api
end

function Section:CreateSlider(config)
	if typeof(config) == "string" then
		config = { Name = config }
	end
	config = config or {}

	local min = tonumber(config.Min) or 0
	local max = tonumber(config.Max) or 100
	local step = tonumber(config.Step) or 1
	local value = ClampNumber(config.Default or min, min, max)
	value = RoundToStep(value, step)

	local holder, hitbox = CreateBaseControl(self, {
		Name = config.Name or "Slider",
		LayoutOrder = config.LayoutOrder,
		ExplorerName = config.ExplorerName,
	}, "Slider")

	local sliderLine = New("Frame", {
		Parent = hitbox,
		Name = "SliderLine",
		BackgroundColor3 = Theme.Colors.Text,
		BorderSizePixel = 0,
		Position = UDim2.new(0.209, 0, 0.431, 0),
		Size = UDim2.new(0, 152, 0, 3),
		ZIndex = 3,
	})

	AddCorner(sliderLine, 99)
	AddGradient(sliderLine, {
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(95, 95, 95)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(38, 38, 38)),
		})
	})
	AddStroke(sliderLine, Color3.fromRGB(54, 54, 54), 0.4, 0, 1)

	local fill = New("Frame", {
		Parent = sliderLine,
		Name = "Fill",
		BackgroundColor3 = Theme.Colors.Accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 0, 1, 0),
		ZIndex = 4,
	})
	AddCorner(fill, 99)

	local knob = New("Frame", {
		Parent = sliderLine,
		Name = "SliderKnob",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Colors.Text,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 10, 0, 10),
		BorderSizePixel = 0,
		ZIndex = 5,
	})

	AddCorner(knob, 99)
	AddGradient(knob, {
		Rotation = -45,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(109, 109, 109)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		})
	})

	local valueBox = New("TextBox", {
		Parent = hitbox,
		Name = "ValueTextBox",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.835, 0, 0.225, 0),
		Size = UDim2.new(0, 30, 0, 15),
		Font = Theme.Font,
		PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
		PlaceholderText = tostring(min),
		Text = tostring(value),
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextColor3 = Theme.Colors.Text,
		ClearTextOnFocus = false,
		ZIndex = 3,
	})

	local dragging = false
	local api = {}

	local function valueToAlpha(v)
		if max == min then
			return 0
		end
		return math.clamp((v - min) / (max - min), 0, 1)
	end

	local function render(skipCallback)
		local alpha = valueToAlpha(value)
		Tween(knob, Theme.Tween.Fast, { Position = UDim2.new(alpha, 0, 0.5, 0) })
		Tween(fill, Theme.Tween.Fast, { Size = UDim2.new(alpha, 0, 1, 0) })
		valueBox.Text = tostring(value)

		if not skipCallback then
			SafeCallback(config.Callback, value)
		end
	end

	local function setFromX(x)
		local left = sliderLine.AbsolutePosition.X
		local width = sliderLine.AbsoluteSize.X
		local alpha = math.clamp((x - left) / width, 0, 1)
		local raw = min + ((max - min) * alpha)
		value = ClampNumber(RoundToStep(raw, step), min, max)
		render(false)
	end

	function api:Set(v)
		value = ClampNumber(RoundToStep(v, step), min, max)
		render(false)
	end

	function api:Get()
		return value
	end

	function api:Destroy()
		holder:Destroy()
	end

	api.Instance = holder
	api.TextBox = valueBox

	sliderLine.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromX(input.Position.X)
			Tween(knob, Theme.Tween.Fast, { Size = UDim2.new(0, 13, 0, 13) })
		end
	end)

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			Tween(knob, Theme.Tween.Fast, { Size = UDim2.new(0, 13, 0, 13) })
		end
	end)

	Services.UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setFromX(input.Position.X)
		end
	end)

	Services.UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			Tween(knob, Theme.Tween.Fast, { Size = UDim2.new(0, 10, 0, 10) })
		end
	end)

	valueBox.FocusLost:Connect(function()
		api:Set(tonumber(valueBox.Text) or value)
	end)

	render(true)
	SafeCallback(config.Callback, value)

	return api
end

function Section:CreateKeybind(config)
	if typeof(config) == "string" then
		config = { Name = config }
	end
	config = config or {}

	local currentKey = config.Default or config.Key or Enum.KeyCode.Unknown
	if typeof(currentKey) == "string" then
		currentKey = Enum.KeyCode[currentKey] or Enum.KeyCode.Unknown
	end

	local listening = false
	local ignoreGameProcessed = config.IgnoreGameProcessed ~= false

	local holder, hitbox = CreateBaseControl(self, {
		Name = config.Name or "Keybind",
		LayoutOrder = config.LayoutOrder,
		ExplorerName = config.ExplorerName,
	}, "Keybind")

	local keyFrame = New("Frame", {
		Parent = hitbox,
		Name = "KeybindFrame",
		BackgroundColor3 = Color3.fromRGB(139, 139, 139),
		BorderSizePixel = 0,
		Position = UDim2.new(0.837, 0, 0.165, 0),
		Size = UDim2.new(0, 37, 0, 19),
		ZIndex = 3,
	})

	AddCorner(keyFrame, 4)
	AddGradient(keyFrame, {
		Rotation = -90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(93, 93, 93)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		})
	})
	AddStroke(keyFrame, Color3.fromRGB(61, 61, 61), 2, 0, 1)
	AddStroke(keyFrame, Color3.fromRGB(0, 0, 0), 1, 0.43, 2)

	local keyText = New("TextLabel", {
		Parent = keyFrame,
		Name = "KeybindText",
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Theme.Font,
		Text = ShortKeyName(currentKey),
		TextSize = 17,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 0.5,
		TextColor3 = Color3.fromRGB(211, 211, 211),
		ZIndex = 4,
	})

	local api = {}

	function api:Set(key)
		if typeof(key) == "string" then
			key = Enum.KeyCode[key] or Enum.KeyCode.Unknown
		end
		currentKey = key
		keyText.Text = ShortKeyName(currentKey)
		SafeCallback(config.Changed, currentKey)
	end

	function api:Get()
		return currentKey
	end

	function api:Destroy()
		holder:Destroy()
	end

	api.Instance = holder
	api.Button = hitbox

	hitbox.MouseButton1Click:Connect(function()
		listening = true
		keyText.Text = "..."
		Tween(keyFrame, Theme.Tween.Fast, { BackgroundColor3 = Color3.fromRGB(165, 165, 165) })
	end)

	Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if ignoreGameProcessed and gameProcessed then
			return
		end

		if listening then
			listening = false

			if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
				api:Set(Enum.KeyCode.Unknown)
			else
				api:Set(input.KeyCode)
			end

			Tween(keyFrame, Theme.Tween.Fast, { BackgroundColor3 = Color3.fromRGB(139, 139, 139) })
			return
		end

		if currentKey ~= Enum.KeyCode.Unknown and input.KeyCode == currentKey then
			SafeCallback(config.Callback, currentKey)
		end
	end)

	return api
end

function Section:CreateColorPicker(config)
	if typeof(config) == "string" then
		config = { Name = config }
	end
	config = config or {}

	local defaultColor = config.Default or Color3.fromRGB(255, 255, 255)
	local currentColor = defaultColor

	local holder, hitbox = CreateBaseControl(self, {
		Name = config.Name or "ColorPicker",
		LayoutOrder = config.LayoutOrder,
		ExplorerName = config.ExplorerName,
	}, "ColorPicker")

	local preview = New("Frame", {
		Parent = hitbox,
		Name = "ColorPreview",
		BackgroundColor3 = currentColor,
		BorderSizePixel = 0,
		Position = UDim2.new(0.741, 0, 0.185, 0),
		Size = UDim2.new(0, 62, 0, 17),
		ZIndex = 3,
	})

	AddCorner(preview, 4)
	AddGradient(preview, {
		Rotation = -90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(103, 103, 103)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		})
	})
	AddStroke(preview, Color3.fromRGB(61, 61, 61), 2, 0, 1)
	AddStroke(preview, Color3.fromRGB(0, 0, 0), 1, 0.43, 2)

	local api = {}

	function api:Set(color, skipCallback)
		if typeof(color) ~= "Color3" then
			return
		end

		currentColor = color
		preview.BackgroundColor3 = color

		if not skipCallback then
			SafeCallback(config.Callback, currentColor)
		end
	end

	function api:Get()
		return currentColor
	end

	function api:Open()
		api.Window:_OpenColorPicker({
			Name = config.Name or "ColorPicker",
			Default = defaultColor,
			Color = currentColor,
			Set = function(color)
				api:Set(color, false)
			end,
		})
	end

	function api:Destroy()
		holder:Destroy()
	end

	api.Instance = holder
	api.Button = hitbox
	api.Preview = preview
	api.Window = self.Window

	hitbox.MouseButton1Click:Connect(function()
		api:Open()
	end)

	SafeCallback(config.Callback, currentColor)
	return api
end

--──────────────────────────────────────────────────--
-- Color picker window
--──────────────────────────────────────────────────--

function Window:_BuildColorPicker()
	self.ColorPickerState = {
		Target = nil,
		Hue = 0,
		Saturation = 0,
		Value = 1,
		History = {},
		HistoryIndex = 0,
		Recent = {},
	}

	local picker = New("Frame", {
		Parent = self.Gui,
		Name = "ColorPickerMain",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 608, 0, 417),
		BackgroundColor3 = Theme.Colors.Background,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 500,
		ClipsDescendants = true,
		Active = true,
	})

	self.ColorPickerFrame = picker

	AddCorner(picker, 4)
	AddGradient(picker, {
		Rotation = -90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		})
	})
	AddStroke(picker, Color3.fromRGB(47, 47, 47), 2, 0, 1)
	AddStroke(picker, Color3.fromRGB(0, 0, 0), 1, 0.16, 2)

	local header = New("Frame", {
		Parent = picker,
		Name = "HeaderBg",
		BackgroundColor3 = Theme.Colors.Header,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 50),
		BorderSizePixel = 0,
		ZIndex = 505,
		Active = true,
	})
	self.ColorPickerHeader = header
	AddCorner(header, 4)
	AddGradient(header, {
		Rotation = -90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(95, 95, 95)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		})
	})
	local colorPickerHeaderStroke = AddStroke(header, Theme.Colors.Accent, 1, 0, 3)
	AddGradient(colorPickerHeaderStroke, {
		Rotation = -90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0, 0),
			NumberSequenceKeypoint.new(0.05, 1, 0),
			NumberSequenceKeypoint.new(1, 1, 0),
		})
	})

	local glow = New("Frame", {
		Parent = picker,
		Name = "HeaderBgGlow",
		BackgroundColor3 = Theme.Colors.Accent,
		BackgroundTransparency = 0.5,
		ZIndex = 505,
		Position = UDim2.new(0, 0, 0, 50),
		Size = UDim2.new(1, 0, 0, 17),
	})
	AddGradient(glow, {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.732, 0),
			NumberSequenceKeypoint.new(1, 1, 0),
		})
	})

	self.ColorPickerTitle = New("TextLabel", {
		Parent = picker,
		Name = "WindowName",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.016, 0, 0, 0),
		Size = UDim2.new(0, 180, 0, 32),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = 16,
		Font = Theme.Font,
		Text = "Color picker",
		TextColor3 = Theme.Colors.Text,
		TextTransparency = 0.21,
		ZIndex = 506,
	})

	self.ColorPickerDesc = New("TextLabel", {
		Parent = picker,
		Name = "WindowDesc",
		BackgroundTransparency = 1,
		ZIndex = 506,
		Position = UDim2.new(0.016, 0, 0.042, 0),
		Size = UDim2.new(0, 180, 0, 32),
		Font = Theme.Font,
		Text = "from: nil",
		TextTransparency = 0.65,
		TextSize = 12,
		TextColor3 = Theme.Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local close = New("ImageButton", {
		Parent = picker,
		Name = "CloseButton",
		Image = Theme.Images.Close,
		BackgroundTransparency = 1,
		Position = UDim2.new(0.929, 0, 0.017, 0),
		Size = UDim2.new(0, 36, 0, 36),
		ImageTransparency = 0.84,
		ImageColor3 = Theme.Colors.Text,
		AutoButtonColor = false,
		ZIndex = 506,
	})
	self.ColorPickerCloseButton = close

	close.MouseButton1Click:Connect(function()
		self:_CloseColorPicker()
	end)

	close.MouseEnter:Connect(function()
		Tween(close, Theme.Tween.Fast, { ImageTransparency = 0.35 })
	end)

	close.MouseLeave:Connect(function()
		Tween(close, Theme.Tween.Fast, { ImageTransparency = 0.84 })
	end)

	local main = New("Frame", {
		Parent = picker,
		Name = "ColorPickerMainSquare",
		BackgroundColor3 = Color3.fromHSV(0, 1, 1),
		Position = UDim2.new(0.036, 0, 0.255, 0),
		Size = UDim2.new(0, 219, 0, 219),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 501,
	})
	self.ColorSquare = main
	AddCorner(main, 4)
	AddStroke(main, Color3.fromRGB(65, 65, 65), 2, 0, 1)
	AddStroke(main, Color3.fromRGB(0, 0, 0), 1, 0.57, 2)

	local whiteOverlay = New("Frame", {
		Parent = main,
		Name = "WhiteOverlay",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		ZIndex = 502,
	})
	AddGradient(whiteOverlay, {
		Rotation = 0,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0, 0),
			NumberSequenceKeypoint.new(1, 1, 0),
		})
	})

	local blackOverlay = New("Frame", {
		Parent = main,
		Name = "BlackOverlay",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		ZIndex = 503,
	})
	AddGradient(blackOverlay, {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1, 0),
			NumberSequenceKeypoint.new(1, 0, 0),
		})
	})

	local dot = New("Frame", {
		Parent = main,
		Name = "Dot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 8, 0, 8),
		BackgroundColor3 = Theme.Colors.Text,
		BorderSizePixel = 0,
		ZIndex = 504,
	})
	self.ColorSquareDot = dot
	AddCorner(dot, 99)
	AddStroke(dot, Color3.fromRGB(0, 0, 0), 3, 0.55, 1)
	AddStroke(dot, Color3.fromRGB(255, 255, 255), 1, 0, 2)

	local current = New("Frame", {
		Parent = picker,
		Name = "CurrentColor",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Position = UDim2.new(0.426, 0, 0.385, 0),
		Size = UDim2.new(0, 43, 0, 166),
		ZIndex = 501,
	})
	self.ColorCurrent = current
	AddCorner(current, 4)
	AddStroke(current, Color3.fromRGB(65, 65, 65), 2, 0, 1)
	AddStroke(current, Color3.fromRGB(0, 0, 0), 1, 0.57, 2)

	local hue = New("Frame", {
		Parent = picker,
		Name = "ColorSelector",
		BackgroundColor3 = Color3.fromRGB(209, 209, 209),
		Position = UDim2.new(0.526, 0, 0.255, 0),
		Size = UDim2.new(0, 19, 0, 219),
		BorderSizePixel = 0,
		ZIndex = 501,
	})
	self.HueSelector = hue
	AddCorner(hue, 4)
	AddGradient(hue, {
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		})
	})
	AddStroke(hue, Color3.fromRGB(65, 65, 65), 2, 0, 1)
	AddStroke(hue, Color3.fromRGB(0, 0, 0), 1, 0.57, 2)

	local hueLine = New("Frame", {
		Parent = hue,
		Name = "SelectLine",
		BackgroundColor3 = Color3.fromRGB(65, 65, 65),
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 504,
		BorderSizePixel = 0,
	})
	self.HueLine = hueLine
	AddStroke(hueLine, Color3.fromRGB(0, 0, 0), 1.1, 0.4, 1)

	local recentFolder = New("Folder", { Parent = picker, Name = "LastColor" })
	self.RecentButtons = {}

	New("TextLabel", {
		Parent = recentFolder,
		Name = "RecentText",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.587, 0, 0.175, 0),
		Size = UDim2.new(0, 82, 0, 33),
		Font = Theme.Font,
		Text = "Recent:",
		TextColor3 = Theme.Colors.TextDark,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 501,
	})

	local recentPositions = {
		UDim2.new(0.589, 0, 0.255, 0),
		UDim2.new(0.671, 0, 0.255, 0),
		UDim2.new(0.753, 0, 0.255, 0),
		UDim2.new(0.835, 0, 0.255, 0),
		UDim2.new(0.917, 0, 0.255, 0),
	}

	for index, position in ipairs(recentPositions) do
		local button = New("TextButton", {
			Parent = recentFolder,
			Name = "LastColor_" .. index,
			Position = position,
			Size = UDim2.new(0, 31, 0, 31),
			BackgroundColor3 = Theme.Colors.Text,
			BorderSizePixel = 0,
			Text = "",
			Visible = false,
			AutoButtonColor = false,
			ZIndex = 501,
		})
		AddCorner(button, 4)
		AddStroke(button, Color3.fromRGB(65, 65, 65), 2, 0, 1)
		AddStroke(button, Color3.fromRGB(0, 0, 0), 1, 0.57, 2)

		button.MouseButton1Click:Connect(function()
			self:_SetPickerColor(button.BackgroundColor3, true)
		end)

		self.RecentButtons[index] = button
	end

	local function iconButton(name, image, pos, rotation)
		local btn = New("ImageButton", {
			Parent = picker,
			Name = name,
			BackgroundTransparency = 1,
			Position = pos,
			Size = UDim2.new(0, 20, 0, 20),
			Image = image,
			ImageTransparency = 0.25,
			Rotation = rotation or 0,
			ZIndex = 503,
			AutoButtonColor = false,
		})

		btn.MouseEnter:Connect(function()
			Tween(btn, Theme.Tween.Fast, { ImageTransparency = 0 })
		end)

		btn.MouseLeave:Connect(function()
			Tween(btn, Theme.Tween.Fast, { ImageTransparency = 0.25 })
		end)

		return btn
	end

	local reset = iconButton("ResetToDefaultButton", Theme.Images.Reset, UDim2.new(0.426, 0, 0.255, 0))
	local random = iconButton("RandomColorButton", Theme.Images.Random, UDim2.new(0.464, 0, 0.255, 0))
	local back = iconButton("MoveBackButton", Theme.Images.Move, UDim2.new(0.426, 0, 0.315, 0), 180)
	local forward = iconButton("MoveForwardButton", Theme.Images.Move, UDim2.new(0.464, 0, 0.315, 0))

	reset.MouseButton1Click:Connect(function()
		if self.ColorPickerState.Target then
			self:_SetPickerColor(self.ColorPickerState.Target.Default or Color3.fromRGB(255, 255, 255), true)
		end
	end)

	random.MouseButton1Click:Connect(function()
		self:_SetPickerColor(Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)), true)
	end)

	back.MouseButton1Click:Connect(function()
		self:_MovePickerHistory(-1)
	end)

	forward.MouseButton1Click:Connect(function()
		self:_MovePickerHistory(1)
	end)

	local rgbRow = New("Frame", {
		Parent = picker,
		Name = "RGBRow",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.587, 0, 0.39, 0),
		Size = UDim2.new(0, 245, 0, 24),
		ZIndex = 501,
	})
	self.ColorRGBText = rgbRow

	local function makeRGBBox(labelText, x)
		local label = New("TextLabel", {
			Parent = rgbRow,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, x, 0, 0),
			Size = UDim2.new(0, 18, 1, 0),
			Font = Theme.Font,
			Text = labelText .. ":",
			TextColor3 = Theme.Colors.TextDark,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 502,
		})

		local box = New("TextBox", {
			Parent = rgbRow,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, x + 16, 0, 0),
			Size = UDim2.new(0, 34, 1, 0),
			Font = Theme.Font,
			TextColor3 = Theme.Colors.TextDark,
			PlaceholderColor3 = Theme.Colors.TextDark,
			TextSize = 12,
			Text = "255",
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			ZIndex = 502,
		})

		return box, label
	end

	self.ColorRBox = makeRGBBox("R", 0)
	self.ColorGBox = makeRGBBox("G", 72)
	self.ColorBBox = makeRGBBox("B", 144)

	local function applyRGBBoxes()
		local r = math.clamp(tonumber(self.ColorRBox.Text) or 0, 0, 255)
		local g = math.clamp(tonumber(self.ColorGBox.Text) or 0, 0, 255)
		local b = math.clamp(tonumber(self.ColorBBox.Text) or 0, 0, 255)

		self.ColorRBox.Text = tostring(math.floor(r + 0.5))
		self.ColorGBox.Text = tostring(math.floor(g + 0.5))
		self.ColorBBox.Text = tostring(math.floor(b + 0.5))

		self:_SetPickerColor(Color3.fromRGB(r, g, b), true)
	end

	self.ColorRBox.FocusLost:Connect(applyRGBBoxes)
	self.ColorGBox.FocusLost:Connect(applyRGBBoxes)
	self.ColorBBox.FocusLost:Connect(applyRGBBoxes)

	MakeDraggable(header, picker, { Smooth = true })

	local draggingSquare = false
	local draggingHue = false

	local function updateSquareFromInput(input)
		local pos = main.AbsolutePosition
		local size = main.AbsoluteSize
		local x = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
		local y = math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
		self.ColorPickerState.Saturation = x
		self.ColorPickerState.Value = 1 - y
		self:_RenderPicker(true)
	end

	local function updateHueFromInput(input)
		local pos = hue.AbsolutePosition
		local size = hue.AbsoluteSize
		local y = math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
		self.ColorPickerState.Hue = y
		self:_RenderPicker(true)
	end

	main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSquare = true
			updateSquareFromInput(input)
		end
	end)

	hue.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingHue = true
			updateHueFromInput(input)
		end
	end)

	Services.UserInputService.InputChanged:Connect(function(input)
		if draggingSquare and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSquareFromInput(input)
		elseif draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateHueFromInput(input)
		end
	end)

	Services.UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if draggingSquare or draggingHue then
				local pickedColor = self:_GetPickerColor()
				self:_PushPickerHistory(pickedColor)
				self:_AddRecentColor(pickedColor)
			end
			draggingSquare = false
			draggingHue = false
		end
	end)
end

function Window:_GetPickerColor()
	local state = self.ColorPickerState
	return Color3.fromHSV(state.Hue, state.Saturation, state.Value)
end

function Window:_PushPickerHistory(color)
	local state = self.ColorPickerState
	if typeof(color) ~= "Color3" then
		return
	end

	if state.HistoryIndex < #state.History then
		for i = #state.History, state.HistoryIndex + 1, -1 do
			table.remove(state.History, i)
		end
	end

	table.insert(state.History, color)
	state.HistoryIndex = #state.History
end

function Window:_MovePickerHistory(direction)
	local state = self.ColorPickerState
	if #state.History == 0 then
		return
	end

	state.HistoryIndex = math.clamp(state.HistoryIndex + direction, 1, #state.History)
	self:_SetPickerColor(state.History[state.HistoryIndex], false)
end

function Window:_AddRecentColor(color)
	local state = self.ColorPickerState
	if typeof(color) ~= "Color3" then
		return
	end

	for i = #state.Recent, 1, -1 do
		if state.Recent[i] == color then
			table.remove(state.Recent, i)
		end
	end

	table.insert(state.Recent, 1, color)

	while #state.Recent > 5 do
		table.remove(state.Recent)
	end

	for index, button in ipairs(self.RecentButtons) do
		local recentColor = state.Recent[index]
		button.Visible = recentColor ~= nil
		if recentColor then
			button.BackgroundColor3 = recentColor
		end
	end
end

function Window:_RenderPicker(sendCallback)
	local state = self.ColorPickerState
	local color = self:_GetPickerColor()

	Tween(self.ColorSquare, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundColor3 = Color3.fromHSV(state.Hue, 1, 1),
	})
	Tween(self.ColorSquareDot, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(state.Saturation, 0, 1 - state.Value, 0),
	})
	Tween(self.HueLine, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, state.Hue, 0),
	})
	Tween(self.ColorCurrent, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundColor3 = color,
	})

	local r = math.floor(color.R * 255 + 0.5)
	local g = math.floor(color.G * 255 + 0.5)
	local b = math.floor(color.B * 255 + 0.5)
	self.ColorRBox.Text = tostring(r)
	self.ColorGBox.Text = tostring(g)
	self.ColorBBox.Text = tostring(b)

	if sendCallback and state.Target and state.Target.Set then
		state.Target.Set(color)
	end
end

function Window:_SetPickerColor(color, pushHistory)
	if typeof(color) ~= "Color3" then
		return
	end

	local h, s, v = color:ToHSV()
	self.ColorPickerState.Hue = h
	self.ColorPickerState.Saturation = s
	self.ColorPickerState.Value = v
	self:_RenderPicker(true)

	if pushHistory then
		self:_PushPickerHistory(color)
		self:_AddRecentColor(color)
	end
end

function Window:_OpenColorPicker(target)
	self.ColorPickerState.Target = target
	self.ColorPickerState.History = {}
	self.ColorPickerState.HistoryIndex = 0

	self.ColorPickerTitle.Text = "Color picker"
	self.ColorPickerDesc.Text = "from: " .. tostring(target.Name or "nil")

	local startColor = target.Color or Color3.fromRGB(255, 255, 255)
	self:_SetPickerColor(startColor, true)
	self:_AddRecentColor(startColor)

	self.ColorPickerFrame.Visible = true
	self.ColorPickerFrame.Size = UDim2.new(0, 570, 0, 390)
	Tween(self.ColorPickerFrame, Theme.Tween.Spring, { Size = UDim2.new(0, 608, 0, 417) })
end

function Window:_CloseColorPicker()
	local color = self:_GetPickerColor()
	self:_AddRecentColor(color)

	local closeTween = Tween(self.ColorPickerFrame, Theme.Tween.Fast, { Size = UDim2.new(0, 570, 0, 390) })
	if closeTween then
		closeTween.Completed:Once(function()
			if self.ColorPickerFrame then
				self.ColorPickerFrame.Visible = false
				self.ColorPickerFrame.Size = UDim2.new(0, 608, 0, 417)
			end
		end)
	else
		self.ColorPickerFrame.Visible = false
	end
end

--──────────────────────────────────────────────────--
-- Notifications
--──────────────────────────────────────────────────--

function Window:_ReflowNotifications()
	for i = #self.NotificationStack, 1, -1 do
		local data = self.NotificationStack[i]
		if not data.Frame or not data.Frame.Parent or data.Closed then
			table.remove(self.NotificationStack, i)
		end
	end

	local visualIndex = 0

	for i = 1, #self.NotificationStack do
		local data = self.NotificationStack[i]

		if data and data.Frame and data.Frame.Parent and not data.Manual then
			Tween(data.Frame, Theme.Tween.Smooth, {
				Position = UDim2.new(1, -20, 1, -20 - (visualIndex * 80))
			})
			visualIndex += 1
		end
	end
end

function Window:_CreateNotificationUI(config)
	local ui = {}

	ui.Frame = New("Frame", {
		Parent = self.Gui,
		Name = "NotificationBackground",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 300, 1, -20),
		BackgroundColor3 = Theme.Colors.Header,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 285, 0, 72),
		ZIndex = 1001,
		BorderSizePixel = 0,
	})
	AddCorner(ui.Frame, 4)
	AddGradient(ui.Frame, {
		Rotation = -90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(95, 95, 95)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		})
	})
	AddStroke(ui.Frame, Color3.fromRGB(56, 56, 56), 2, 1, 1)
	AddStroke(ui.Frame, Color3.fromRGB(0, 0, 0), 1, 1, 2)

	ui.DragLine = New("Frame", {
		Parent = ui.Frame,
		Name = "DragLine",
		Position = UDim2.new(0.022, 0, 0.16, 0),
		Size = UDim2.new(0, 5, 0, 49),
		ZIndex = 1003,
		BackgroundColor3 = Theme.Colors.Text,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})
	AddCorner(ui.DragLine, 20)
	AddGradient(ui.DragLine, {
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(146, 74, 255)),
			ColorSequenceKeypoint.new(1, Theme.Colors.AccentDark),
		})
	})
	AddStroke(ui.DragLine, Color3.fromRGB(0, 0, 0), 1, 1, 1)

	ui.TimeLineGlow = New("Frame", {
		Parent = ui.Frame,
		Name = "TimeLineGlow",
		BackgroundColor3 = Theme.Colors.Accent,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0.72, 0),
		Size = UDim2.new(1, 0, 0, 18),
		BorderSizePixel = 0,
		ZIndex = 1002,
	})
	AddGradient(ui.TimeLineGlow, {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1, 0),
			NumberSequenceKeypoint.new(1, 0.86, 0),
		})
	})

	ui.TimeLine = New("Frame", {
		Parent = ui.Frame,
		Name = "TimeLine",
		BackgroundColor3 = Theme.Colors.Accent,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0.975, 0),
		Size = UDim2.new(1, 0, 0, 2),
		ZIndex = 1003,
		BorderSizePixel = 0,
	})
	AddCorner(ui.TimeLine, 80)
	AddGradient(ui.TimeLine, {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(137, 98, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		})
	})

	ui.Close = New("ImageButton", {
		Parent = ui.Frame,
		Name = "CloseButton",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.905, 0, 0.02, 0),
		Size = UDim2.new(0, 23, 0, 23),
		ImageTransparency = 1,
		Image = Theme.Images.Close,
		AutoButtonColor = false,
		ZIndex = 1004,
	})

	ui.Freeze = New("ImageButton", {
		Parent = ui.Frame,
		Name = "FreezeButton",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.825, 0, 0.02, 0),
		Size = UDim2.new(0, 23, 0, 23),
		ImageTransparency = 1,
		AutoButtonColor = false,
		ZIndex = 1004,
	})

	ui.FreezeIcon = New("ImageLabel", {
		Parent = ui.Freeze,
		Name = "FreezeButtonIcon",
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 13, 0, 13),
		Image = Theme.Images.Freeze,
		ImageTransparency = 1,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 1005,
	})

	ui.TimeLeft = New("TextLabel", {
		Parent = ui.Frame,
		Name = "TimeLeft",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.86, 0, 0.64, 0),
		Size = UDim2.new(0, 32, 0, 20),
		ZIndex = 1004,
		Text = tostring(config.Duration or 3) .. "s",
		Font = Theme.Font,
		TextColor3 = Color3.fromRGB(80, 80, 80),
		TextTransparency = 1,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Right,
	})

	ui.Title = New("TextLabel", {
		Parent = ui.Frame,
		Name = "NotificationName",
		BackgroundTransparency = 1,
		ZIndex = 1004,
		Position = UDim2.new(0.075, 0, 0.08, 0),
		Size = UDim2.new(0, 195, 0, 20),
		Font = Theme.Font,
		Text = config.Title or "Notification",
		TextSize = 13,
		TextColor3 = Theme.Colors.Text,
		TextTransparency = 1,
		TextStrokeTransparency = 0.42,
		TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	ui.Description = New("TextLabel", {
		Parent = ui.Frame,
		Name = "NotificationDescription",
		BackgroundTransparency = 1,
		ZIndex = 1004,
		Position = UDim2.new(0.075, 0, 0.39, 0),
		Size = UDim2.new(0, 205, 0, 31),
		Font = Theme.Font,
		Text = config.Description or "",
		TextColor3 = Color3.fromRGB(155, 155, 155),
		TextTransparency = 1,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
	})

	local notificationSound = Instance.new("Sound")
	notificationSound.Parent = Services.SoundService
	notificationSound.SoundId = Theme.Sounds.Notification
	notificationSound:Play()
	Services.Debris:AddItem(notificationSound, Theme.Sounds.Notification_Timing)

	return ui
end

function Window:_FadeNotificationUI(ui, visible)
	local textAlpha = visible and 0 or 1
	local imageAlpha = visible and 0.84 or 1

	Tween(ui.Frame, Theme.Tween.Fast, { BackgroundTransparency = visible and 0 or 1 })
	Tween(ui.DragLine, Theme.Tween.Fast, { BackgroundTransparency = visible and 0 or 1 })
	Tween(ui.TimeLineGlow, Theme.Tween.Fast, { BackgroundTransparency = visible and 0.3 or 1 })
	Tween(ui.TimeLine, Theme.Tween.Fast, { BackgroundTransparency = visible and 0.45 or 1 })
	Tween(ui.Close, Theme.Tween.Fast, { ImageTransparency = imageAlpha })
	Tween(ui.FreezeIcon, Theme.Tween.Fast, { ImageTransparency = imageAlpha })
	Tween(ui.TimeLeft, Theme.Tween.Fast, { TextTransparency = textAlpha })
	Tween(ui.Title, Theme.Tween.Fast, { TextTransparency = textAlpha })
	Tween(ui.Description, Theme.Tween.Fast, { TextTransparency = textAlpha })
end

function Window:Notify(config)
	if typeof(config) == "string" then
		config = { Title = config }
	end
	config = config or {}

	local duration = tonumber(config.Duration) or 3
	local ui = self:_CreateNotificationUI({
		Title = config.Title,
		Description = config.Description,
		Duration = duration,
	})

	local state = {
		Frame = ui.Frame,
		Manual = false,
		Closed = false,
		Frozen = false,
	}

	table.insert(self.NotificationStack, state)

	local zBoost = (#self.NotificationStack - 1) * 10
	ui.Frame.ZIndex = ui.Frame.ZIndex + zBoost
	for _, obj in ipairs(ui.Frame:GetDescendants()) do
		if obj:IsA("GuiObject") or obj:IsA("UIStroke") then
			obj.ZIndex = obj.ZIndex + zBoost
		end
	end

	local yOffset = (#self.NotificationStack - 1) * 80
	ui.Frame.Position = UDim2.new(1, 300, 1, -20 - yOffset)

	MakeDraggable(ui.DragLine, ui.Frame, { Smooth = true })

	ui.DragLine.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			state.Manual = true
		end
	end)

	local function closeNotification()
		if state.Closed then
			return
		end

		state.Closed = true

		for i = #self.NotificationStack, 1, -1 do
			if self.NotificationStack[i] == state then
				table.remove(self.NotificationStack, i)
				break
			end
		end

		Tween(ui.Frame, Theme.Tween.Fast, {
			BackgroundTransparency = 1,
			Position = ui.Frame.Position + UDim2.new(0, 35, 0, 0),
		})
		self:_FadeNotificationUI(ui, false)

		task.delay(0.22, function()
			if ui.Frame then
				ui.Frame:Destroy()
			end
			self:_ReflowNotifications()
		end)
	end

	ui.Close.MouseButton1Click:Connect(closeNotification)

	ui.Freeze.MouseButton1Click:Connect(function()
		state.Frozen = not state.Frozen
		Tween(ui.FreezeIcon, Theme.Tween.Fast, {
			ImageTransparency = state.Frozen and 0.22 or 0.84,
		})
	end)

	ui.Close.MouseEnter:Connect(function()
		Tween(ui.Close, Theme.Tween.Fast, { ImageTransparency = 0.35 })
	end)

	ui.Close.MouseLeave:Connect(function()
		Tween(ui.Close, Theme.Tween.Fast, { ImageTransparency = 0.84 })
	end)

	ui.Freeze.MouseEnter:Connect(function()
		Tween(ui.FreezeIcon, Theme.Tween.Fast, {
			ImageTransparency = state.Frozen and 0.22 or 0.55
		})
	end)

	ui.Freeze.MouseLeave:Connect(function()
		Tween(ui.FreezeIcon, Theme.Tween.Fast, {
			ImageTransparency = state.Frozen and 0.22 or 0.84
		})
	end)

	self:_FadeNotificationUI(ui, true)
	self:_ReflowNotifications()

	task.spawn(function()
		local remaining = duration
		local last = os.clock()

		while remaining > 0 and not state.Closed do
			Services.RunService.Heartbeat:Wait()

			local now = os.clock()
			local delta = now - last
			last = now

			if not state.Frozen then
				remaining -= delta
				ui.TimeLine.Size = UDim2.new(math.clamp(remaining / duration, 0, 1), 0, 0, 2)
				ui.TimeLeft.Text = tostring(math.max(0, math.ceil(remaining))) .. "s"
			end
		end

		closeNotification()
	end)

	return {
		Instance = ui.Frame,
		Close = closeNotification,
	}
end

--──────────────────────────────────────────────────--
-- Compatibility shortcuts
--──────────────────────────────────────────────────--

Amphibia.New = New
Amphibia.Tween = Tween
Amphibia.AddCorner = AddCorner
Amphibia.AddStroke = AddStroke
Amphibia.AddGradient = AddGradient

--[[
USAGE EXAMPLE:

local Amphibia = require(path.to.Amphibia_Library_Module)

local Window = Amphibia.CreateWindow({
	Name = "Amphibia'",
	Icon = "rbxassetid://76305975133668",
	ToggleKey = Enum.KeyCode.RightShift,
})

local MainCategory = Window:CreateCategory("Main")
local PlayerTab = MainCategory:CreateTab("Player")
local WorldTab = MainCategory:CreateTab("World")

local MainSection = PlayerTab:CreateSection("Main", "Left")
local PlayerSection = PlayerTab:CreateSection("Player", "Right")

MainSection:CreateButton({
	Name = "Button",
	Callback = function()
		print("pressed")
		Window:Notify({ Title = "Button", Description = "Button pressed", Duration = 3 })
	end,
})

MainSection:CreateDropdown({
	Name = "Dropdown",
	Options = { "Option 1", "Option 2", "Option 3" },
	Default = "Option 1",
	Callback = function(value)
		print("dropdown:", value)
	end,
})

MainSection:CreateToggle({
	Name = "Toggle",
	Default = false,
	Callback = function(value)
		print("toggle:", value)
	end,
})

MainSection:CreateColorPicker({
	Name = "Color picker",
	Default = Color3.fromRGB(150, 64, 255),
	Callback = function(color)
		print("color:", color)
	end,
})

PlayerSection:CreateTextbox({
	Name = "Textbox",
	Placeholder = "Text",
	Callback = function(text, enterPressed)
		print("textbox:", text, enterPressed)
	end,
})

PlayerSection:CreateSlider({
	Name = "Slider",
	Min = 0,
	Max = 100,
	Default = 25,
	Step = 1,
	Callback = function(value)
		print("slider:", value)
	end,
})

PlayerSection:CreateKeybind({
	Name = "Keybind",
	Default = Enum.KeyCode.H,
	Callback = function(key)
		print("key pressed:", key)
	end,
})

local WorldSection = WorldTab:CreateSection("World", "Left")
WorldSection:CreateButton({
	Name = "World button",
	Callback = function()
		print("world")
	end,
})

Window:SelectTab("Player")
]]

return Amphibia
