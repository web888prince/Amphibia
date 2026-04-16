--──────────────────────────────────────────────────--
--──────────────────|> Locals
--──────────────────────────────────────────────────--

--  Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

--  Main
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

--  Interface
local PlayerGui = Player:WaitForChild("PlayerGui")
local Default_Parent = PlayerGui

--  Menu settings
local _scriptName = "Amphibia'"
local _scriptIcon = "rbxassetid://76305975133668"

--  Images
local _settingsImageId = "rbxassetid://9405931578"
local _searchImageId = "rbxassetid://75273157378006"
local _closeImageId = "rbxassetid://130334254289066"
local _moveImageId = "rbxassetid://87351486351798"
local _randomImageId = "rbxassetid://82824171769924"
local _resetImageId = "rbxassetid://438217404"
local _freezeImageId = "rbxassetid://13200344988"
local _tripleDotImageId = "rbxassetid://127075876244307"

-- Tweens
local DefTweenInfo = TweenInfo.new(0.36, Enum.EasingStyle.Back, Enum.EasingDirection.In)

--──────────────────────────────────────────────────--
--──────────────────|> Functions
--──────────────────────────────────────────────────--

local function tween(instance,info,ptable)
	return TweenService:Create(instance, info, ptable):Play()
end
qq
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

local function CreateLastColor(number, position, parent)
	local inst = Instance.new("Frame")
	inst.Parent = parent
	inst.Name = "LastColor_" .. number
	inst.Size = UDim2.new(0,31,0,31)
	inst.Position = position
	inst.BackgroundColor3 = Color3.fromRGB(255,255,255)
	inst.Visible = false

	local corner = Instance.new("UICorner")
	corner.Parent = inst
	corner.CornerRadius = UDim.new(0,4)

	local gradient = Instance.new("UIGradient")
	gradient.Parent = inst
	gradient.Rotation = -90
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0,Color3.fromRGB(180,180,180)),
		ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))
	}

	local stroke = Instance.new("UIStroke")
	stroke.Parent = inst
	stroke.Color = Color3.fromRGB(65,65,65)
	stroke.Thickness = 2
	stroke.ZIndex = 1

	local stroke2 = Instance.new("UIStroke")
	stroke2.Parent = inst
	stroke2.Color = Color3.fromRGB(0,0,0)
	stroke2.Thickness = 1
	stroke2.Transparency = 0.57
	stroke2.ZIndex = 2

	return inst
end

local function createTabCategory(name, CategoryParent)
	local category = Instance.new("Frame")
	category.Parent = CategoryParent
	category.Name = name
	category.BackgroundTransparency = 1
	category.Size = UDim2.new(0,100,0,0)
	category.ZIndex = 1
	category.AutomaticSize = Enum.AutomaticSize.Y

	local categoryList = Instance.new("UIListLayout")
	categoryList.Parent = category
	categoryList.SortOrder = Enum.SortOrder.LayoutOrder

	local tabsHolderFrame = Instance.new("Frame")
	tabsHolderFrame.Parent = category
	tabsHolderFrame.AutomaticSize = Enum.AutomaticSize.Y
	tabsHolderFrame.Size = UDim2.new(1,0,0,0)
	tabsHolderFrame.ZIndex = 1
	tabsHolderFrame.BackgroundTransparency = 1
	tabsHolderFrame.Name = "TabsHolder"
	tabsHolderFrame.LayoutOrder = 2

	local tabsHolderFrameList = Instance.new("UIListLayout")
	tabsHolderFrameList.Parent = tabsHolderFrame

	local tabsHolderFramePadding = Instance.new("UIPadding")
	tabsHolderFramePadding.Parent = tabsHolderFrame
	tabsHolderFramePadding.PaddingLeft = UDim.new(0,15)
	tabsHolderFramePadding.PaddingTop = UDim.new(0,5)

	local categoryText = Instance.new("TextLabel")
	categoryText.Parent = category
	categoryText.BackgroundTransparency = 1
	categoryText.TextColor3 = Color3.fromRGB(255,255,255)
	categoryText.Size = UDim2.new(0,84,0,10)
	categoryText.ZIndex = 1
	categoryText.Font = Enum.Font.RobotoMono
	categoryText.Text = name
	categoryText.TextSize = 15
	categoryText.TextTransparency = 0.7
	categoryText.TextXAlignment = Enum.TextXAlignment.Left
	categoryText.LayoutOrder = 1

	return category, tabsHolderFrame
end

local function createTab(name, category, ScrollingFrameParent)
	local tabButton = Instance.new("TextButton")
	tabButton.Parent = category
	tabButton.Name = name
	tabButton.BackgroundTransparency = 1
	tabButton.Size = UDim2.new(0,111,0,22)
	tabButton.ZIndex = 2
	tabButton.Font = Enum.Font.RobotoMono
	tabButton.Text = name
	tabButton.TextSize = 15
	tabButton.TextColor3 = Color3.fromRGB(255,255,255)
	tabButton.TextXAlignment = Enum.TextXAlignment.Left

	local scrolling = Instance.new("ScrollingFrame")
	scrolling.Parent = ScrollingFrameParent
	scrolling.BackgroundTransparency = 1
	scrolling.Position = UDim2.new(0.241,0,0.101,0)
	scrolling.Size = UDim2.new(0,581,0,435)
	scrolling.ZIndex = 1
	scrolling.Name = name .. "TabContent"
	scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrolling.CanvasSize = UDim2.new(0,0,0,0)
	scrolling.ScrollBarImageTransparency = 1
	scrolling.ScrollBarThickness = 0
	scrolling.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
	scrolling.Visible = false

	local leftColumn = Instance.new("Frame")
	leftColumn.Parent = scrolling
	leftColumn.Name = "LeftColumn"
	leftColumn.AutomaticSize = Enum.AutomaticSize.Y
	leftColumn.BackgroundTransparency = 1
	leftColumn.Position = UDim2.new(0,0,0,0)
	leftColumn.Size = UDim2.new(0,285,0,0)
	leftColumn.ZIndex = 1

	local rightColumn = Instance.new("Frame")
	rightColumn.Parent = scrolling
	rightColumn.Name = "RightColumn"
	rightColumn.AutomaticSize = Enum.AutomaticSize.Y
	rightColumn.BackgroundTransparency = 1
	rightColumn.Position = UDim2.new(0.496,0,0,0)
	rightColumn.Size = UDim2.new(0,285,0,0)
	rightColumn.ZIndex = 1

	local leftColumnList = Instance.new("UIListLayout")
	leftColumnList.Parent = leftColumn
	leftColumnList.Padding = UDim.new(0,10)
	leftColumnList.FillDirection = Enum.FillDirection.Vertical
	leftColumnList.SortOrder = Enum.SortOrder.LayoutOrder

	local rightColumnList = Instance.new("UIListLayout")
	rightColumnList.Parent = rightColumn
	rightColumnList.Padding = UDim.new(0,10)
	rightColumnList.FillDirection = Enum.FillDirection.Vertical
	rightColumnList.SortOrder = Enum.SortOrder.LayoutOrder

	local leftColumnPadding = Instance.new("UIPadding")
	leftColumnPadding.Parent = leftColumn
	leftColumnPadding.PaddingBottom = UDim.new(0,10)
	leftColumnPadding.PaddingLeft = UDim.new(0,10)
	leftColumnPadding.PaddingTop = UDim.new(0,10)

	local rightColumnPadding = Instance.new("UIPadding")
	rightColumnPadding.Parent = rightColumn
	rightColumnPadding.PaddingBottom = UDim.new(0,10)
	rightColumnPadding.PaddingLeft = UDim.new(0,10)
	rightColumnPadding.PaddingTop = UDim.new(0,10)

	return tabButton, scrolling
end

local function createSection(name, scrolling, columnSide)
	if name == nil then warn("name (1) is nil") end
	if scrolling == nil then warn("scrolling (2) is nil") end
	if columnSide == nil then warn("columnSide (3) is nil") end

	local section = Instance.new("Frame")
	if columnSide == "Left" or columnSide == "left" or columnSide == "l" then
		section.Parent = scrolling:WaitForChild("LeftColumn")
	elseif columnSide == "Right" or columnSide == "right" or columnSide == "r" then
		section.Parent = scrolling:WaitForChild("RightColumn")
	end	
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundTransparency = 0
	section.BackgroundColor3 = Color3.fromRGB(20,20,20)
	section.Size = UDim2.new(0,276,0,0)
	section.ZIndex = 1
	section.Name = name

	local sectionCorner = Instance.new("UICorner")
	sectionCorner.Parent = section
	sectionCorner.CornerRadius = UDim.new(0,4)

	local sectionGradient = Instance.new("UIGradient")
	sectionGradient.Parent = section
	sectionGradient.Rotation = 90
	sectionGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,0,0),
		NumberSequenceKeypoint.new(1,0.831,0)
	})

	local sectionSizeCon = Instance.new("UISizeConstraint")
	sectionSizeCon.Parent = section
	sectionSizeCon.MinSize = Vector2.new(0,60)

	local sectionStroke1 = Instance.new("UIStroke")
	sectionStroke1.Parent = section
	sectionStroke1.Color = Color3.fromRGB(0,0,0)
	sectionStroke1.Thickness = 1
	sectionStroke1.Transparency = 0.14
	sectionStroke1.ZIndex = 2

	local sectionStroke2 = Instance.new("UIStroke")
	sectionStroke2.Parent = section
	sectionStroke2.Color = Color3.fromRGB(40,40,40)
	sectionStroke2.Thickness = 2
	sectionStroke2.ZIndex = 1

	local sectionStroke2Gradient = Instance.new("UIGradient")
	sectionStroke2Gradient.Parent = sectionStroke2
	sectionStroke2Gradient.Rotation = 90
	sectionStroke2Gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,0,0),
		NumberSequenceKeypoint.new(1,0.444,0)
	})

	local sectionHeaderFrame = Instance.new("Frame")
	sectionHeaderFrame.Parent = section
	sectionHeaderFrame.Name = "Header"
	sectionHeaderFrame.BackgroundTransparency = 1
	sectionHeaderFrame.Size = UDim2.new(0,276,0,35)
	sectionHeaderFrame.Position = UDim2.new(0,0,0,0)
	sectionHeaderFrame.ZIndex = 1

	local sectionHeaderFrameList = Instance.new("UIListLayout")
	sectionHeaderFrameList.Parent = sectionHeaderFrame
	sectionHeaderFrameList.Padding = UDim.new(0,7)
	sectionHeaderFrameList.SortOrder = Enum.SortOrder.LayoutOrder
	sectionHeaderFrameList.HorizontalFlex = Enum.UIFlexAlignment.Fill

	local sectionHeaderFramePadding = Instance.new("UIPadding")
	sectionHeaderFramePadding.Parent = sectionHeaderFrame
	sectionHeaderFramePadding.PaddingTop = UDim.new(0,3)

	local sectionHeaderFrameLine = Instance.new("Frame")
	sectionHeaderFrameLine.Parent = sectionHeaderFrame
	sectionHeaderFrameLine.Name = "Line"
	sectionHeaderFrameLine.BackgroundColor3 = Color3.fromRGB(100,100,100)
	sectionHeaderFrameLine.Size = UDim2.new(0,276,0,1)
	sectionHeaderFrameLine.ZIndex = 1
	sectionHeaderFrameLine.LayoutOrder = 2

	local sectionHeaderFrameLineGradient = Instance.new("UIGradient")
	sectionHeaderFrameLineGradient.Parent = sectionHeaderFrameLine
	sectionHeaderFrameLineGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,1,0),
		NumberSequenceKeypoint.new(0.1,0.5,0),
		NumberSequenceKeypoint.new(0.9,0.5,0),
		NumberSequenceKeypoint.new(1,1,0)
	})

	local sectionHeaderFrameNameText = Instance.new("TextLabel")
	sectionHeaderFrameNameText.Parent = sectionHeaderFrame
	sectionHeaderFrameNameText.Name = "SectionName"
	sectionHeaderFrameNameText.BackgroundTransparency = 1
	sectionHeaderFrameNameText.LayoutOrder = 1
	sectionHeaderFrameNameText.Size = UDim2.new(0,215,0,25)
	sectionHeaderFrameNameText.ZIndex = 1
	sectionHeaderFrameNameText.Font = Enum.Font.RobotoMono
	sectionHeaderFrameNameText.Text = name
	sectionHeaderFrameNameText.TextColor3 = Color3.fromRGB(255,255,255)
	sectionHeaderFrameNameText.TextSize = 15
	sectionHeaderFrameNameText.TextXAlignment = Enum.TextXAlignment.Left

	local sectionHeaderFrameNameTextPadding = Instance.new("UIPadding")
	sectionHeaderFrameNameTextPadding.Parent = sectionHeaderFrameNameText
	sectionHeaderFrameNameTextPadding.PaddingLeft = UDim.new(0,7)

	local sectionHeaderFrameButtonHolder = Instance.new("Frame")
	sectionHeaderFrameButtonHolder.Parent = section
	sectionHeaderFrameButtonHolder.Name = "ButtonHolderFrame"
	sectionHeaderFrameButtonHolder.BackgroundTransparency = 1
	sectionHeaderFrameButtonHolder.AutomaticSize = Enum.AutomaticSize.Y
	sectionHeaderFrameButtonHolder.Size = UDim2.new(0,276,0,0)
	sectionHeaderFrameButtonHolder.ZIndex = 1

	local sectionHeaderFrameButtonHolderList = Instance.new("UIListLayout")
	sectionHeaderFrameButtonHolderList.Parent = sectionHeaderFrameButtonHolder
	sectionHeaderFrameButtonHolderList.SortOrder = Enum.SortOrder.LayoutOrder

	local sectionHeaderFrameButtonHolderPadding = Instance.new("UIPadding")
	sectionHeaderFrameButtonHolderPadding.Parent = sectionHeaderFrameButtonHolder
	sectionHeaderFrameButtonHolderPadding.PaddingBottom = UDim.new(0,8)
	sectionHeaderFrameButtonHolderPadding.PaddingLeft = UDim.new(0,10)
	sectionHeaderFrameButtonHolderPadding.PaddingTop = UDim.new(0,43)

	return section
end

---------------------------------------------------------------------------------------------------
--                                                                              CONTROLS CODING  --
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
--                                                                           CONTROLS FUNCTIONS  --
---------------------------------------------------------------------------------------------------

local function connectButton(button)
	local nameText = button:WaitForChild("NameText")

	button.MouseEnter:Connect(function()
		tween(nameText, DefTweenInfo, {TextColor3 = Color3.fromRGB(210,210,210)})
	end)

	button.MouseLeave:Connect(function()
		tween(nameText, DefTweenInfo, {TextColor3 = Color3.fromRGB(255,255,255)})
	end)
end

local function createButton(name, section, func, layoutOrder, ExplorerName)
	layoutOrder = layoutOrder or 0
	ExplorerName = ExplorerName or "Button"
	func = func or function() end

	local button = Instance.new("TextButton")
	button.Parent = section:WaitForChild("ButtonHolderFrame")
	button.Name = ExplorerName
	button.LayoutOrder = layoutOrder
	button.BackgroundTransparency = 1
	button.Size = UDim2.new(0,265,0,29)
	button.ZIndex = 1
	button.Text = ""
	button.TextTransparency = 1
	button.TextSize = 1

	local nameText = Instance.new("TextLabel")
	nameText.Parent = button
	nameText.Name = "NameText"
	nameText.Size = UDim2.new(1,0,1,0)
	nameText.BackgroundTransparency = 1
	nameText.ZIndex = 1
	nameText.Font = Enum.Font.RobotoMono
	nameText.BorderSizePixel = 0
	nameText.TextColor3 = Color3.fromRGB(255,255,255)
	nameText.Text = name
	nameText.TextSize = 14
	nameText.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	nameText.TextStrokeTransparency = 0
	nameText.TextXAlignment = Enum.TextXAlignment.Left

	connectButton(button)

	button.MouseButton1Click:Connect(func)

	return button
end

local function createDropdown(name, section, layoutOrder, ExplorerName)
	layoutOrder = layoutOrder or 0
	ExplorerName = ExplorerName or "Dropdown"

	local dropdownButton = Instance.new("TextButton")
	dropdownButton.Parent = section:WaitForChild("ButtonHolderFrame")
	dropdownButton.Name = ExplorerName
	dropdownButton.LayoutOrder = layoutOrder
	dropdownButton.BackgroundTransparency = 1
	dropdownButton.Size = UDim2.new(0,265,0,29)
	dropdownButton.ZIndex = 1
	dropdownButton.Text = ""
	dropdownButton.TextTransparency = 1
	dropdownButton.TextSize = 1

	local settingsImage = Instance.new("ImageLabel")
	settingsImage.Parent = dropdownButton
	settingsImage.Name = "SettingsImageLabel"
	settingsImage.Image = _tripleDotImageId
	settingsImage.Position = UDim2.new(0.905,0,0.131,0)
	settingsImage.Size = UDim2.new(0,20,0,20)
	settingsImage.BackgroundTransparency = 1
	settingsImage.BorderSizePixel = 0
	settingsImage.ImageTransparency = 0.26
	settingsImage.ImageColor3 = Color3.fromRGB(255,255,255)

	local nameText = Instance.new("TextLabel")
	nameText.Parent = dropdownButton
	nameText.Name = "NameText"
	nameText.Size = UDim2.new(1,0,1,0)
	nameText.BackgroundTransparency = 1
	nameText.ZIndex = 1
	nameText.Font = Enum.Font.RobotoMono
	nameText.BorderSizePixel = 0
	nameText.TextColor3 = Color3.fromRGB(255,255,255)
	nameText.Text = name
	nameText.TextSize = 14
	nameText.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	nameText.TextStrokeTransparency = 0
	nameText.TextXAlignment = Enum.TextXAlignment.Left

	return dropdownButton
end

local function createToggle(name, section, layoutOrder, ExplorerName)
	layoutOrder = layoutOrder or 0
	ExplorerName = ExplorerName or "Toggle"

	local toggleButton = Instance.new("TextButton")
	toggleButton.Parent = section:WaitForChild("ButtonHolderFrame")
	toggleButton.BackgroundTransparency = 1
	toggleButton.BorderSizePixel = 0
	toggleButton.Text = ""
	toggleButton.TextTransparency = 0
	toggleButton.LayoutOrder = layoutOrder
	toggleButton.TextSize = 1
	toggleButton.Size = UDim2.new(0,265,0,29)
	toggleButton.Name = ExplorerName

	local toggleButtonFrame = Instance.new("Frame")
	toggleButtonFrame.Parent = toggleButton
	toggleButtonFrame.BackgroundColor3 = Color3.fromRGB(77,77,77)
	toggleButtonFrame.BorderSizePixel = 0
	toggleButtonFrame.Name = "ToggleFrame"
	toggleButtonFrame.Position = UDim2.new(0.909,0,0.172,0)
	toggleButtonFrame.Size = UDim2.new(0,18,0,18)
	toggleButtonFrame.ZIndex = 1

	local toggleButtonFrameCorner = Instance.new("UICorner")
	toggleButtonFrameCorner.Parent = toggleButtonFrame
	toggleButtonFrameCorner.CornerRadius = UDim.new(0,1)

	local toggleButtonFrameGradient = Instance.new("UIGradient")
	toggleButtonFrameGradient.Parent = toggleButtonFrame
	toggleButtonFrameGradient.Rotation = -90
	toggleButtonFrameGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(62,62,62)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
	})

	local toggleButtonFrameStroke1 = Instance.new("UIStroke")
	toggleButtonFrameStroke1.Parent = toggleButtonFrame
	toggleButtonFrameStroke1.Color = Color3.fromRGB(54,54,54)
	toggleButtonFrameStroke1.Thickness = 2
	toggleButtonFrameStroke1.ZIndex = 1

	local toggleButtonFrameStroke2 = Instance.new("UIStroke")
	toggleButtonFrameStroke2.Parent = toggleButtonFrame
	toggleButtonFrameStroke2.Color = Color3.fromRGB(0,0,0)
	toggleButtonFrameStroke2.Thickness = 1
	toggleButtonFrameStroke2.Transparency = 0.29
	toggleButtonFrameStroke2.ZIndex = 2

	local toggleButtonFrameActive = Instance.new("Frame")
	toggleButtonFrameActive.Parent = toggleButtonFrame
	toggleButtonFrameActive.BackgroundColor3 = Color3.fromRGB(255,255,255)
	toggleButtonFrameActive.BorderSizePixel = 0
	toggleButtonFrameActive.AnchorPoint = Vector2.new(.5,.5)
	toggleButtonFrameActive.Position = UDim2.new(0.5,0,0.5,0)
	toggleButtonFrameActive.Size = UDim2.new(0,14,0,14)
	toggleButtonFrameActive.ZIndex = 1
	toggleButtonFrameActive.Name = "Active"
	toggleButtonFrameActive.Visible = false

	local toggleButtonFrameActiveCorner = Instance.new("UICorner")
	toggleButtonFrameActiveCorner.Parent = toggleButtonFrameActive
	toggleButtonFrameActiveCorner.CornerRadius = UDim.new(0,1)

	local toggleButtonFrameActiveGradient = Instance.new("UIGradient")
	toggleButtonFrameActiveGradient.Parent = toggleButtonFrameActive
	toggleButtonFrameActiveGradient.Rotation = -90
	toggleButtonFrameActiveGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(111,59,185)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(144,70,255))
	})

	local toggleButtonFrameActiveStroke = Instance.new("UIStroke")
	toggleButtonFrameActiveStroke.Parent = toggleButtonFrameActive
	toggleButtonFrameActiveStroke.Color = Color3.fromRGB(0,0,0)
	toggleButtonFrameActiveStroke.Thickness = 1
	toggleButtonFrameActiveStroke.Transparency = 0.46
	toggleButtonFrameActiveStroke.ZIndex = 1

	local nameText = Instance.new("TextLabel")
	nameText.Parent = toggleButton
	nameText.Name = "NameText"
	nameText.Size = UDim2.new(1,0,1,0)
	nameText.BackgroundTransparency = 1
	nameText.ZIndex = 1
	nameText.Font = Enum.Font.RobotoMono
	nameText.BorderSizePixel = 0
	nameText.TextColor3 = Color3.fromRGB(255,255,255) -- if active then Color3.fromRGB(153,70,255)
	nameText.Text = name
	nameText.TextSize = 14
	nameText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameText.TextStrokeTransparency = 0
	nameText.TextXAlignment = Enum.TextXAlignment.Left

	return toggleButton
end

local function createColorPicker(name, section, layoutOrder, ExplorerName)
	layoutOrder = layoutOrder or 0
	ExplorerName = ExplorerName or "ColorPicker"

	local colorPickerButton = Instance.new("TextButton")
	colorPickerButton.Parent = section:WaitForChild("ButtonHolderFrame")
	colorPickerButton.BackgroundTransparency = 1
	colorPickerButton.Name = ExplorerName
	colorPickerButton.LayoutOrder = layoutOrder
	colorPickerButton.Size = UDim2.new(0,265,0,29)
	colorPickerButton.ZIndex = 1
	colorPickerButton.TextSize = 1
	colorPickerButton.Text = ""
	colorPickerButton.TextTransparency = 1
	colorPickerButton.BorderSizePixel = 0

	local colorPreviewFrame = Instance.new("Frame")
	colorPreviewFrame.Parent = colorPickerButton
	colorPreviewFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
	colorPreviewFrame.BorderSizePixel = 0
	colorPreviewFrame.Position = UDim2.new(0.741,0,0.185,0)
	colorPreviewFrame.Size = UDim2.new(0,62,0,17)
	colorPreviewFrame.ZIndex = 1
	colorPreviewFrame.Name = "ColorPreview"

	local colorPreviewFrameCorner = Instance.new("UICorner")
	colorPreviewFrameCorner.Parent = colorPreviewFrame
	colorPreviewFrameCorner.CornerRadius = UDim.new(0,4)

	local colorPreviewFrameGradient = Instance.new("UIGradient")
	colorPreviewFrameGradient.Parent = colorPreviewFrame
	colorPreviewFrameGradient.Rotation = -90
	colorPreviewFrameGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(103,103,103)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
	})

	local colorPreviewFrameStroke1 = Instance.new("UIStroke")
	colorPreviewFrameStroke1.Parent = colorPreviewFrame
	colorPreviewFrameStroke1.Color = Color3.fromRGB(61,61,61)
	colorPreviewFrameStroke1.Thickness = 2
	colorPreviewFrameStroke1.Transparency = 0
	colorPreviewFrameStroke1.ZIndex = 1

	local colorPreviewFrameStroke2 = Instance.new("UIStroke")
	colorPreviewFrameStroke2.Parent = colorPreviewFrame
	colorPreviewFrameStroke2.Color = Color3.fromRGB(0,0,0)
	colorPreviewFrameStroke2.Thickness = 1
	colorPreviewFrameStroke2.Transparency = 0.43
	colorPreviewFrameStroke2.ZIndex = 2

	local nameText = Instance.new("TextLabel")
	nameText.Parent = colorPickerButton
	nameText.Name = "NameText"
	nameText.Size = UDim2.new(1,0,1,0)
	nameText.BackgroundTransparency = 1
	nameText.ZIndex = 1
	nameText.Font = Enum.Font.RobotoMono
	nameText.BorderSizePixel = 0
	nameText.TextColor3 = Color3.fromRGB(255,255,255)
	nameText.Text = name
	nameText.TextSize = 14
	nameText.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	nameText.TextStrokeTransparency = 0
	nameText.TextXAlignment = Enum.TextXAlignment.Left

	return colorPickerButton
end

local function createTextbox(name, section, layoutOrder, ExplorerName)
	layoutOrder = layoutOrder or 0
	ExplorerName = ExplorerName or "Textbox"

	local textboxButton = Instance.new("TextButton")
	textboxButton.Parent = section:WaitForChild("ButtonHolderFrame")
	textboxButton.BackgroundTransparency = 1
	textboxButton.Name = ExplorerName
	textboxButton.LayoutOrder = layoutOrder
	textboxButton.Size = UDim2.new(0,265,0,29)
	textboxButton.ZIndex = 1
	textboxButton.TextSize = 1
	textboxButton.Text = ""
	textboxButton.TextTransparency = 1
	textboxButton.BorderSizePixel = 0

	local textbox = Instance.new("TextBox")
	textbox.Parent = textboxButton
	textbox.BackgroundColor3 = Color3.fromRGB(104,104,104)
	textbox.BorderSizePixel = 0
	textbox.Position = UDim2.new(0.639,0,0.207,0)
	textbox.Size = UDim2.new(0,90,0,17)
	textbox.Font = Enum.Font.RobotoMono
	textbox.TextColor3 = Color3.fromRGB(255,255,255)
	textbox.PlaceholderColor3 = Color3.fromRGB(178,178,178)
	textbox.Text = ""
	textbox.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	textbox.TextStrokeTransparency = 0.44
	textbox.TextScaled = true
	textbox.TextWrapped = true

	local textboxCorner = Instance.new("UICorner")
	textboxCorner.Parent = textbox
	textboxCorner.CornerRadius = UDim.new(0,4)

	local textboxGradient = Instance.new("UIGradient")
	textboxGradient.Parent = textbox
	textboxGradient.Rotation = -90
	textboxGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 120, 120)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
	})

	local textboxStroke1 = Instance.new("UIStroke")
	textboxStroke1.Parent = textbox
	textboxStroke1.Color = Color3.fromRGB(61,61,61)
	textboxStroke1.Thickness = 2
	textboxStroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	textboxStroke1.ZIndex = 1

	local textboxStroke2 = Instance.new("UIStroke")
	textboxStroke2.Parent = textbox
	textboxStroke2.Color = Color3.fromRGB(0,0,0)
	textboxStroke2.Thickness = 1
	textboxStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	textboxStroke2.Transparency = 0.43
	textboxStroke2.ZIndex = 2

	local nameText = Instance.new("TextLabel")
	nameText.Parent = textboxButton
	nameText.Name = "NameText"
	nameText.Size = UDim2.new(1,0,1,0)
	nameText.BackgroundTransparency = 1
	nameText.ZIndex = 1
	nameText.Font = Enum.Font.RobotoMono
	nameText.BorderSizePixel = 0
	nameText.TextColor3 = Color3.fromRGB(255,255,255)
	nameText.Text = name
	nameText.TextSize = 14
	nameText.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	nameText.TextStrokeTransparency = 0
	nameText.TextXAlignment = Enum.TextXAlignment.Left

	return textboxButton
end

local function createSlider(name, section, layoutOrder, ExplorerName)
	layoutOrder = layoutOrder or 0
	ExplorerName = ExplorerName or "Slider"

	local sliderButton = Instance.new("TextButton")
	sliderButton.Parent = section:WaitForChild("ButtonHolderFrame")
	sliderButton.BackgroundTransparency = 1
	sliderButton.Name = ExplorerName
	sliderButton.LayoutOrder = layoutOrder
	sliderButton.Size = UDim2.new(0,265,0,29)
	sliderButton.ZIndex = 1
	sliderButton.TextSize = 1
	sliderButton.Text = ""
	sliderButton.TextTransparency = 1
	sliderButton.BorderSizePixel = 0
	sliderButton.Interactable = false

	local sliderLine = Instance.new("Frame")
	sliderLine.Parent = sliderButton
	sliderLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
	sliderLine.BorderSizePixel = 0
	sliderLine.Position = UDim2.new(0.209,0,0.431,0)
	sliderLine.Size = UDim2.new(0,181,0,3)
	sliderLine.ZIndex = 1
	sliderLine.Name = "SliderLine"

	local sliderLineCorner = Instance.new("UICorner")
	sliderLineCorner.Parent = sliderLine
	sliderLineCorner.CornerRadius = UDim.new(1,0)

	local sliderLineGradient = Instance.new("UIGradient")
	sliderLineGradient.Parent = sliderLine
	sliderLineGradient.Rotation = 90
	sliderLineGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(95,95,95)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(38,38,38))
	})

	local sliderLineStroke = Instance.new("UIStroke")
	sliderLineStroke.Parent = sliderLine
	sliderLineStroke.Color = Color3.fromRGB(54,54,54)
	sliderLineStroke.Thickness = 0.4
	sliderLineStroke.ZIndex = 1

	local sliderKnob = Instance.new("Frame")
	sliderKnob.Parent = sliderLine
	sliderKnob.Name = "SliderKnob"
	sliderKnob.AnchorPoint = Vector2.new(0.5,0.5)
	sliderKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
	sliderKnob.Position = UDim2.new(0.027,0,0.333,0)
	sliderKnob.Size = UDim2.new(0,10,0,10)
	sliderKnob.BorderSizePixel = 0
	sliderKnob.ZIndex = 1

	local sliderKnobCorner = Instance.new("UICorner")
	sliderKnobCorner.Parent = sliderKnob
	sliderKnobCorner.CornerRadius = UDim.new(1,0)

	local sliderKnobGradient = Instance.new("UIGradient")
	sliderKnobGradient.Parent = sliderKnob
	sliderKnobGradient.Rotation = -45
	sliderKnobGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(109,109,109)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
	})

	local sliderValueTextbox = Instance.new("TextBox")
	sliderValueTextbox.Parent = sliderButton
	sliderValueTextbox.BackgroundTransparency = 1
	sliderValueTextbox.BorderSizePixel = 0
	sliderValueTextbox.Position = UDim2.new(0.915,0,0.335,0)
	sliderValueTextbox.Size = UDim2.new(0,18,0,6)
	sliderValueTextbox.Font = Enum.Font.RobotoMono
	sliderValueTextbox.PlaceholderColor3 = Color3.fromRGB(178,178,178)
	sliderValueTextbox.PlaceholderText = "0" -- this text is a indicator of current value and can contains only numbers. Also make that in script coder can select max and min value for slider.
	sliderValueTextbox.Text = "0"
	sliderValueTextbox.TextSize = 10
	sliderValueTextbox.TextXAlignment = Enum.TextXAlignment.Left
	sliderValueTextbox.TextColor3 = Color3.fromRGB(255,255,255)

	local nameText = Instance.new("TextLabel")
	nameText.Parent = sliderButton
	nameText.Name = "NameText"
	nameText.Size = UDim2.new(1,0,1,0)
	nameText.BackgroundTransparency = 1
	nameText.ZIndex = 1
	nameText.Font = Enum.Font.RobotoMono
	nameText.BorderSizePixel = 0
	nameText.TextColor3 = Color3.fromRGB(255,255,255)
	nameText.Text = name
	nameText.TextSize = 14
	nameText.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	nameText.TextStrokeTransparency = 0
	nameText.TextXAlignment = Enum.TextXAlignment.Left

	return sliderButton
end

local function createKeybind(name, section, defKeybindValue, layoutOrder, ExplorerName)
	layoutOrder = layoutOrder or 0
	ExplorerName = ExplorerName or "Slider"
	defKeybindValue = defKeybindValue or ""

	local keybindButton = Instance.new("TextButton")
	keybindButton.Parent = section:WaitForChild("ButtonHolderFrame")
	keybindButton.BackgroundTransparency = 1
	keybindButton.Name = ExplorerName
	keybindButton.LayoutOrder = layoutOrder
	keybindButton.Size = UDim2.new(0,265,0,29)
	keybindButton.ZIndex = 1
	keybindButton.TextSize = 1
	keybindButton.Text = ""
	keybindButton.TextTransparency = 1
	keybindButton.BorderSizePixel = 0
	keybindButton.Interactable = false

	local keybindFrame = Instance.new("Frame")
	keybindFrame.Parent = keybindButton
	keybindFrame.Name = "KeybindFrame"
	keybindFrame.BackgroundColor3 = Color3.fromRGB(139,139,139)
	keybindFrame.BorderSizePixel = 0
	keybindFrame.Position = UDim2.new(0.837,0,0.165,0)
	keybindFrame.Size = UDim2.new(0,37,0,19)
	keybindFrame.ZIndex = 1

	local keybindFrameCorner = Instance.new("UICorner")
	keybindFrameCorner.Parent = keybindFrame
	keybindFrameCorner.CornerRadius = UDim.new(0,4)

	local keybindFrameGradient = Instance.new("UIGradient")
	keybindFrameGradient.Parent = keybindFrame
	keybindFrameGradient.Rotation = -90
	keybindFrameGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(93, 93, 93)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
	})

	local keybindFrameStroke1 = Instance.new("UIStroke")
	keybindFrameStroke1.Parent = keybindFrame
	keybindFrameStroke1.Color = Color3.fromRGB(61,61,61)
	keybindFrameStroke1.Thickness = 2
	keybindFrameStroke1.ZIndex = 1

	local keybindFrameStroke2 = Instance.new("UIStroke")
	keybindFrameStroke2.Parent = keybindFrame
	keybindFrameStroke2.Color = Color3.fromRGB(0,0,0)
	keybindFrameStroke2.Thickness = 1
	keybindFrameStroke2.Transparency = 0.43
	keybindFrameStroke2.ZIndex = 2

	local keybindText = Instance.new("TextLabel")
	keybindText.Parent = keybindFrame
	keybindText.Name = "KeybindText"
	keybindText.BorderSizePixel = 0
	keybindText.BackgroundTransparency = 1
	keybindText.Size = UDim2.new(1,0,1,0)
	keybindText.Position = UDim2.new(0,0,0,0)
	keybindText.Font = Enum.Font.RobotoMono
	keybindText.Text = defKeybindValue
	keybindText.TextSize = 17
	keybindText.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	keybindText.TextStrokeTransparency = 0.5
	keybindText.TextColor3 = Color3.fromRGB(211, 211, 211)

	local nameText = Instance.new("TextLabel")
	nameText.Parent = keybindButton
	nameText.Name = "NameText"
	nameText.Size = UDim2.new(1,0,1,0)
	nameText.BackgroundTransparency = 1
	nameText.ZIndex = 1
	nameText.Font = Enum.Font.RobotoMono
	nameText.BorderSizePixel = 0
	nameText.TextColor3 = Color3.fromRGB(255,255,255)
	nameText.Text = name
	nameText.TextSize = 14
	nameText.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	nameText.TextStrokeTransparency = 0
	nameText.TextXAlignment = Enum.TextXAlignment.Left

	return keybindButton
end


--──────────────────────────────────────────────────--
--──────────────────|> Build core ui
--──────────────────────────────────────────────────--

local MainGui = Instance.new("ScreenGui")
MainGui.Parent = Default_Parent
MainGui.Enabled = true
MainGui.IgnoreGuiInset = true
MainGui.ResetOnSpawn = false
MainGui.DisplayOrder = 0
MainGui.Name = GenerateRandomName(10)

local ColorPickerGui = Instance.new("ScreenGui")
ColorPickerGui.Parent = MainGui
ColorPickerGui.Enabled = false 
ColorPickerGui.IgnoreGuiInset = true
ColorPickerGui.ResetOnSpawn = false
ColorPickerGui.DisplayOrder = 1
ColorPickerGui.Name = "ColorPickerGui"

local NotificationsGui = Instance.new("ScreenGui")
NotificationsGui.Parent = MainGui
NotificationsGui.Enabled = true
NotificationsGui.IgnoreGuiInset = true
NotificationsGui.ResetOnSpawn = false
NotificationsGui.DisplayOrder = 100
NotificationsGui.Name = "NotificationsGui"

------------------------------------------------
--                                         Main
------------------------------------------------

local MAIN_MainBgFrame = Instance.new("Frame")
MAIN_MainBgFrame.Parent = MainGui
MAIN_MainBgFrame.AnchorPoint = Vector2.new(0.5,0.5)
MAIN_MainBgFrame.Position = UDim2.new(0.5,0,0.5,0)
MAIN_MainBgFrame.Size = UDim2.new(0,767,0,484)
MAIN_MainBgFrame.ZIndex = 0
MAIN_MainBgFrame.BackgroundTransparency = 0
MAIN_MainBgFrame.BackgroundColor3 = Color3.fromRGB(16,16,16)
MAIN_MainBgFrame.Name = "MainBg"

local MAIN_TabsContentFolder = Instance.new("Folder")
MAIN_TabsContentFolder.Parent =  MAIN_MainBgFrame
MAIN_TabsContentFolder.Name = "TabsContentFolder"

local MAIN_MainDarkFrame = Instance.new("Frame")
MAIN_MainDarkFrame.Parent = MainGui
MAIN_MainDarkFrame.BackgroundTransparency = 0.35
MAIN_MainDarkFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
MAIN_MainDarkFrame.ZIndex = -10000
MAIN_MainDarkFrame.Position = UDim2.new(0,0,0,0)
MAIN_MainDarkFrame.Size = UDim2.new(1,0,1,0)
MAIN_MainDarkFrame.Interactable = true

local MAIN_MainBgFrameCorner = Instance.new("UICorner")
MAIN_MainBgFrameCorner.Parent = MAIN_MainBgFrame
MAIN_MainBgFrameCorner.CornerRadius = UDim.new(0,4)

local MAIN_MainBgFrameGraident = Instance.new("UIGradient")
MAIN_MainBgFrameGraident.Parent = MAIN_MainBgFrame
MAIN_MainBgFrameGraident.Rotation = -90
MAIN_MainBgFrameGraident.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))
}

local MAIN_HeaderContentFolder = Instance.new("Folder")
MAIN_HeaderContentFolder.Parent = MAIN_MainBgFrame
MAIN_HeaderContentFolder.Name = "HeaderContent"

local MAIN_SearchFrame = Instance.new("Frame")
MAIN_SearchFrame.Parent = MAIN_MainBgFrame
MAIN_SearchFrame.Position = UDim2.new(0.269,0,0.017,0)
MAIN_SearchFrame.Size = UDim2.new(0,355,0,31)
MAIN_SearchFrame.ZIndex = 1
MAIN_SearchFrame.BackgroundTransparency = 0
MAIN_SearchFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
MAIN_SearchFrame.Name = "SearchFrame"

local MAIN_SearchFrameCorner = Instance.new("UICorner")
MAIN_SearchFrameCorner.Parent = MAIN_SearchFrame
MAIN_SearchFrameCorner.CornerRadius = UDim.new(0,4)

local MAIN_SearchFrameGradient = Instance.new("UIGradient")
MAIN_SearchFrameGradient.Parent = MAIN_SearchFrame
MAIN_SearchFrameGradient.Rotation = 90
MAIN_SearchFrameGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0,Color3.fromRGB(27,27,27)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(29,29,29))
}

local MAIN_SearchFrameStroke = Instance.new("UIStroke")
MAIN_SearchFrameStroke.Parent = MAIN_SearchFrame
MAIN_SearchFrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
MAIN_SearchFrameStroke.Color = Color3.fromRGB(40,40,40)
MAIN_SearchFrameStroke.Thickness = 1
MAIN_SearchFrameStroke.Transparency = 0
MAIN_SearchFrameStroke.ZIndex = 1
MAIN_SearchFrameStroke.LineJoinMode = Enum.LineJoinMode.Round

local MAIN_SearchFrameSearchImage = Instance.new("ImageLabel")
MAIN_SearchFrameSearchImage.Parent = MAIN_SearchFrame
MAIN_SearchFrameSearchImage.BackgroundTransparency = 1
MAIN_SearchFrameSearchImage.Position = UDim2.new(0.017,0,0.194,0)
MAIN_SearchFrameSearchImage.Size = UDim2.new(0,20,0,20)
MAIN_SearchFrameSearchImage.Image = _searchImageId
MAIN_SearchFrameSearchImage.ImageTransparency = 0.6
MAIN_SearchFrameSearchImage.Name = "SearchImage"

local MAIN_SearchFrameTextBox = Instance.new("TextBox")
MAIN_SearchFrameTextBox.Parent = MAIN_SearchFrame
MAIN_SearchFrameTextBox.BackgroundTransparency = 1
MAIN_SearchFrameTextBox.Size = UDim2.new(1,0,1,0)
MAIN_SearchFrameTextBox.Position = UDim2.new(0,0,0,0)
MAIN_SearchFrameTextBox.ZIndex = 1
MAIN_SearchFrameTextBox.Font = Enum.Font.RobotoMono
MAIN_SearchFrameTextBox.TextColor3 = Color3.fromRGB(255,255,255)
MAIN_SearchFrameTextBox.TextSize = 14
MAIN_SearchFrameTextBox.Text = ""
MAIN_SearchFrameTextBox.PlaceholderText = "Search"
MAIN_SearchFrameTextBox.Name = "SearchTextBox"
MAIN_SearchFrameTextBox.TextTransparency = 0.75

local MAIN_SearchFrameTextBoxStroke = Instance.new("UIStroke")
MAIN_SearchFrameTextBoxStroke.Parent = MAIN_SearchFrameTextBox
MAIN_SearchFrameTextBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
MAIN_SearchFrameTextBoxStroke.Thickness = 1
MAIN_SearchFrameTextBoxStroke.LineJoinMode = Enum.LineJoinMode.Round
MAIN_SearchFrameTextBoxStroke.Color = Color3.fromRGB(33,33,33)

local MAIN_HeaderBgFrame = Instance.new("Frame")
MAIN_HeaderBgFrame.Parent = MAIN_HeaderContentFolder
MAIN_HeaderBgFrame.BackgroundColor3 = Color3.fromRGB(24,24,24)
MAIN_HeaderBgFrame.BackgroundTransparency = 0
MAIN_HeaderBgFrame.Position = UDim2.new(0,0,0,0)
MAIN_HeaderBgFrame.Size = UDim2.new(0,767,0,48)
MAIN_HeaderBgFrame.ZIndex = 0
MAIN_HeaderBgFrame.Name = "HeaderBgFrame"

local MAIN_HeaderBgFrameCorner = Instance.new("UICorner")
MAIN_HeaderBgFrameCorner.Parent = MAIN_HeaderBgFrame
MAIN_HeaderBgFrameCorner.CornerRadius = UDim.new(0,4)

local MAIN_HeaderBgFrameGradient = Instance.new("UIGradient")
MAIN_HeaderBgFrameGradient.Parent = MAIN_HeaderBgFrame
MAIN_HeaderBgFrameGradient.Rotation = -90
MAIN_HeaderBgFrameGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0,Color3.fromRGB(95,95,95)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))
}

local MAIN_HeaderBgFrameStroke = Instance.new("UIStroke")
MAIN_HeaderBgFrameStroke.Parent = MAIN_HeaderBgFrame
MAIN_HeaderBgFrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
MAIN_HeaderBgFrameStroke.Color = Color3.fromRGB(150,64,255)
MAIN_HeaderBgFrameStroke.LineJoinMode = Enum.LineJoinMode.Round
MAIN_HeaderBgFrameStroke.Thickness = 1
MAIN_HeaderBgFrameStroke.ZIndex = 3

local MAIN_HeaderBgFrameStrokeGradient = Instance.new("UIGradient")
MAIN_HeaderBgFrameStrokeGradient.Parent = MAIN_HeaderBgFrameStroke
MAIN_HeaderBgFrameStrokeGradient.Rotation = -90
MAIN_HeaderBgFrameStrokeGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0,0,0),
	NumberSequenceKeypoint.new(0.05,1,0),
	NumberSequenceKeypoint.new(1,1,0)
}

local MAIN_CloseButton = Instance.new("ImageButton")
MAIN_CloseButton.Parent = MAIN_HeaderContentFolder
MAIN_CloseButton.BackgroundTransparency = 1
MAIN_CloseButton.Position = UDim2.new(0.944,0,0.012,0)
MAIN_CloseButton.Size = UDim2.new(0,36,0,36)
MAIN_CloseButton.ZIndex = 1
MAIN_CloseButton.ImageTransparency = 0.84
MAIN_CloseButton.Name = "CloseButton"
MAIN_CloseButton.Image = _closeImageId

local MAIN_ScriptImage = Instance.new("ImageLabel")
MAIN_ScriptImage.Parent = MAIN_HeaderContentFolder
MAIN_ScriptImage.BackgroundTransparency = 1
MAIN_ScriptImage.Position = UDim2.new(0,0,0.013,0)
MAIN_ScriptImage.Size = UDim2.new(0,38,0,38)
MAIN_ScriptImage.Image = _scriptIcon
MAIN_ScriptImage.Name = "ScriptImage"
MAIN_ScriptImage.ImageTransparency = 0
MAIN_ScriptImage.ZIndex = 5

local MAIN_ScriptName = Instance.new("TextLabel")
MAIN_ScriptName.Parent = MAIN_HeaderContentFolder
MAIN_ScriptName.BackgroundTransparency = 1
MAIN_ScriptName.Position = UDim2.new(0.05,0,0.012,0)
MAIN_ScriptName.Size = UDim2.new(0,97,0,34)
MAIN_ScriptName.ZIndex = 5
MAIN_ScriptName.Font = Enum.Font.RobotoMono
MAIN_ScriptName.Text = _scriptName
MAIN_ScriptName.TextSize = 20
MAIN_ScriptName.TextColor3 = Color3.fromRGB(255,255,255)
MAIN_ScriptName.TextXAlignment = Enum.TextXAlignment.Left
MAIN_ScriptName.Name = "ScriptName"

local MAIN_ScriptNameStroke = Instance.new("UIStroke")
MAIN_ScriptNameStroke.Parent = MAIN_ScriptName
MAIN_ScriptNameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
MAIN_ScriptNameStroke.Thickness = 0.4
MAIN_ScriptNameStroke.Color = Color3.fromRGB(255,255,255)
MAIN_ScriptNameStroke.LineJoinMode = Enum.LineJoinMode.Round

local MAIN_ScriptNameStrokeGradient = Instance.new("UIGradient")
MAIN_ScriptNameStrokeGradient.Parent = MAIN_ScriptNameStroke
MAIN_ScriptNameStrokeGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0,Color3.fromRGB(150,64,255)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(238,48,255))
}
MAIN_ScriptNameStrokeGradient.Rotation = -50

local MAIN_ScriptNameShadow = Instance.new("TextLabel")
MAIN_ScriptNameShadow.Parent = MAIN_ScriptName
MAIN_ScriptNameShadow.BackgroundTransparency = 1
MAIN_ScriptNameShadow.Position = UDim2.new(0,0,-0.1,0)
MAIN_ScriptNameShadow.Size = UDim2.new(0,96,0,47)
MAIN_ScriptNameShadow.ZIndex = 5
MAIN_ScriptNameShadow.Font = Enum.Font.RobotoMono
MAIN_ScriptNameShadow.Text = _scriptName
MAIN_ScriptNameShadow.TextSize = 20
MAIN_ScriptNameShadow.TextColor3 = Color3.fromRGB(0,0,0)
MAIN_ScriptNameShadow.TextXAlignment = Enum.TextXAlignment.Left
MAIN_ScriptNameShadow.Name = "TextShadow"

local MAIN_ScriptNameShadowGradient = Instance.new("UIGradient")
MAIN_ScriptNameShadowGradient.Parent = MAIN_ScriptNameShadow
MAIN_ScriptNameShadowGradient.Rotation = -90
MAIN_ScriptNameShadowGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0,0,0),
	NumberSequenceKeypoint.new(0.5,0.369,0),
	NumberSequenceKeypoint.new(1,0,0)
}

local MAIN_SettingsButton = Instance.new("ImageButton")
MAIN_SettingsButton.Parent = MAIN_HeaderContentFolder
MAIN_SettingsButton.Position = UDim2.new(0.74,0,0.024,0)
MAIN_SettingsButton.Size = UDim2.new(0,25,0,25)
MAIN_SettingsButton.BackgroundTransparency = 1
MAIN_SettingsButton.Image = _settingsImageId
MAIN_SettingsButton.Name = "SettingsButton"
MAIN_SettingsButton.ImageTransparency = 0.84

local MAIN_HeaderFrameStrokeGlow = Instance.new("Frame")
MAIN_HeaderFrameStrokeGlow.Parent = MAIN_HeaderContentFolder
MAIN_HeaderFrameStrokeGlow.Name = "HeaderStrokeGlow"
MAIN_HeaderFrameStrokeGlow.BackgroundColor3 = Color3.fromRGB(150,64,255)
MAIN_HeaderFrameStrokeGlow.BackgroundTransparency = 0.25
MAIN_HeaderFrameStrokeGlow.ZIndex = 5
MAIN_HeaderFrameStrokeGlow.Position = UDim2.new(0,0,0.1,0)
MAIN_HeaderFrameStrokeGlow.Size = UDim2.new(0,767,0,17)

local MAIN_HeaderFrameStrokeGlowGradient = Instance.new("UIGradient")
MAIN_HeaderFrameStrokeGlowGradient.Parent = MAIN_HeaderFrameStrokeGlow
MAIN_HeaderFrameStrokeGlowGradient.Rotation = 90
MAIN_HeaderFrameStrokeGlowGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0,0.727,0),
	NumberSequenceKeypoint.new(1,1,0)
}

------------------------------------------------
--                                         Tabs
------------------------------------------------

local TABS_TabsBg = Instance.new("Frame")
TABS_TabsBg.Parent = MAIN_MainBgFrame
TABS_TabsBg.Position = UDim2.new(0,0,0.097,0)
TABS_TabsBg.Size = UDim2.new(0,185,0,436)
TABS_TabsBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
TABS_TabsBg.Name = "TabsBg"
TABS_TabsBg.BorderSizePixel = 0

local TABS_TabsBgGradient = Instance.new("UIGradient")
TABS_TabsBgGradient.Parent = TABS_TabsBg
TABS_TabsBgGradient.Rotation = 90
TABS_TabsBgGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0,0,0),
	NumberSequenceKeypoint.new(1,1,0)
}

local TABS_TabsBgListLayout = Instance.new("UIListLayout")
TABS_TabsBgListLayout.Parent = TABS_TabsBg
TABS_TabsBgListLayout.Padding = UDim.new(0,15)
TABS_TabsBgListLayout.FillDirection = Enum.FillDirection.Vertical
TABS_TabsBgListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TABS_TabsBgListLayout.Wraps = false
TABS_TabsBgListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TABS_TabsBgListLayout.ItemLineAlignment = Enum.ItemLineAlignment.Automatic
TABS_TabsBgListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local TABS_TabsBgPadding = Instance.new("UIPadding")
TABS_TabsBgPadding.Parent = TABS_TabsBg
TABS_TabsBgPadding.PaddingBottom = UDim.new(0,0)
TABS_TabsBgPadding.PaddingLeft = UDim.new(0,20)
TABS_TabsBgPadding.PaddingRight = UDim.new(0,0)
TABS_TabsBgPadding.PaddingTop = UDim.new(0,20)

local TABS_HeaderSplitterLine = Instance.new("Frame")
TABS_HeaderSplitterLine.Parent = MAIN_MainBgFrame
TABS_HeaderSplitterLine.Name = "HeaderSplitter"
TABS_HeaderSplitterLine.BorderSizePixel = 0
TABS_HeaderSplitterLine.BackgroundColor3 = Color3.fromRGB(150,64,255)
TABS_HeaderSplitterLine.BackgroundTransparency = 0.2
TABS_HeaderSplitterLine.Position = UDim2.new(0,0,0.102,0)
TABS_HeaderSplitterLine.Size = UDim2.new(0,185,0,-1)
TABS_HeaderSplitterLine.ZIndex = 4

local TABS_HeaderSplitterLineGradient = Instance.new("UIGradient")
TABS_HeaderSplitterLineGradient.Parent = TABS_HeaderSplitterLine
TABS_HeaderSplitterLineGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0,1,0),
	NumberSequenceKeypoint.new(1,0,0)
}

local TABS_TabsSplitterLine = Instance.new("Frame")
TABS_TabsSplitterLine.Parent = MAIN_MainBgFrame
TABS_TabsSplitterLine.Position = UDim2.new(0.24,0,0.101,0)
TABS_TabsSplitterLine.Size = UDim2.new(0,1,0,434)
TABS_TabsSplitterLine.BackgroundColor3 = Color3.fromRGB(85,85,85)
TABS_TabsSplitterLine.BackgroundTransparency = 0
TABS_TabsSplitterLine.BorderSizePixel = 0
TABS_TabsSplitterLine.ZIndex = 2
TABS_TabsSplitterLine.Name = "TabsSplitter"


local TABS_TabsSplitterLineGradient = Instance.new("UIGradient")
TABS_TabsSplitterLineGradient.Parent = TABS_TabsSplitterLine
TABS_TabsSplitterLineGradient.Rotation = 90
TABS_TabsSplitterLineGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0,0,0),
	NumberSequenceKeypoint.new(1,1,0)
}

------------------------------------------------
--                                  Color picker
------------------------------------------------

local COLORPICKER_MainFrame = Instance.new("Frame")
COLORPICKER_MainFrame.Parent = ColorPickerGui
COLORPICKER_MainFrame.Name = "MainBg"
COLORPICKER_MainFrame.Position = UDim2.new(0.5,0,0.5,0)
COLORPICKER_MainFrame.Size = UDim2.new(0,608,0,417)
COLORPICKER_MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
COLORPICKER_MainFrame.BackgroundColor3 = Color3.fromRGB(16,16,16)

local COLORPICKER_MainFrameCorner = Instance.new("UICorner")
COLORPICKER_MainFrameCorner.Parent = COLORPICKER_MainFrame
COLORPICKER_MainFrameCorner.CornerRadius = UDim.new(0,4)

local COLORPICKER_MainFrameGradient = Instance.new("UIGradient")
COLORPICKER_MainFrameGradient.Parent = COLORPICKER_MainFrame
COLORPICKER_MainFrameGradient.Rotation = -90
COLORPICKER_MainFrameGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
}

local COLORPICKER_MainFrameStroke1 = Instance.new("UIStroke")
COLORPICKER_MainFrameStroke1.Parent = COLORPICKER_MainFrame
COLORPICKER_MainFrameStroke1.Color = Color3.fromRGB(47,47,47)
COLORPICKER_MainFrameStroke1.LineJoinMode = Enum.LineJoinMode.Round
COLORPICKER_MainFrameStroke1.Thickness = 2
COLORPICKER_MainFrameStroke1.ZIndex = 1

local COLORPICKER_MainFrameStroke2 = Instance.new("UIStroke")
COLORPICKER_MainFrameStroke2.Parent = COLORPICKER_MainFrame
COLORPICKER_MainFrameStroke2.Color = Color3.fromRGB(0,0,0)
COLORPICKER_MainFrameStroke2.LineJoinMode = Enum.LineJoinMode.Round
COLORPICKER_MainFrameStroke2.Thickness = 1
COLORPICKER_MainFrameStroke2.ZIndex = 2
COLORPICKER_MainFrameStroke2.Transparency = 0.16

local COLORPICKER_MainFrameLastColorFolder = Instance.new("Folder")
COLORPICKER_MainFrameLastColorFolder.Parent = COLORPICKER_MainFrame
COLORPICKER_MainFrameLastColorFolder.Name = "LastColor"

local COLORPICKER_ColorPickerMainFrame = Instance.new("Frame")
COLORPICKER_ColorPickerMainFrame.Parent = COLORPICKER_MainFrame
COLORPICKER_ColorPickerMainFrame.Name = "ColorPickerMain"
COLORPICKER_ColorPickerMainFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
COLORPICKER_ColorPickerMainFrame.Position = UDim2.new(0.036,0,0.201,0)
COLORPICKER_ColorPickerMainFrame.Size = UDim2.new(0,219,0,219)
COLORPICKER_ColorPickerMainFrame.ZIndex = 1

local COLORPICKER_ColorPickerMainFrameCorner = Instance.new("UICorner")
COLORPICKER_ColorPickerMainFrameCorner.Parent = COLORPICKER_ColorPickerMainFrame
COLORPICKER_ColorPickerMainFrameCorner.CornerRadius = UDim.new(0,4)

local COLORPICKER_ColorPickerMainFrameStroke1 = Instance.new("UIStroke")
COLORPICKER_ColorPickerMainFrameStroke1.Parent = COLORPICKER_ColorPickerMainFrame
COLORPICKER_ColorPickerMainFrameStroke1.Color = Color3.fromRGB(65,65,65)
COLORPICKER_ColorPickerMainFrameStroke1.Thickness = 2
COLORPICKER_ColorPickerMainFrameStroke1.ZIndex = 1

local COLORPICKER_ColorPickerMainFrameStroke2 = Instance.new("UIStroke")
COLORPICKER_ColorPickerMainFrameStroke2.Parent = COLORPICKER_ColorPickerMainFrame
COLORPICKER_ColorPickerMainFrameStroke2.Color = Color3.fromRGB(0,0,0)
COLORPICKER_ColorPickerMainFrameStroke2.Thickness = 1
COLORPICKER_ColorPickerMainFrameStroke2.Transparency = 0.57
COLORPICKER_ColorPickerMainFrameStroke2.ZIndex = 2

local COLORPICKER_ColorPickerMainFrameDot = Instance.new("Frame")
COLORPICKER_ColorPickerMainFrameDot.Parent = COLORPICKER_ColorPickerMainFrame
COLORPICKER_ColorPickerMainFrameDot.Name = "Dot"
COLORPICKER_ColorPickerMainFrameDot.Position = UDim2.new(0.187,0,0.269,0)
COLORPICKER_ColorPickerMainFrameDot.Size = UDim2.new(0,8,0,8)

local COLORPICKER_ColorPickerMainFrameDotCorner = Instance.new("UICorner")
COLORPICKER_ColorPickerMainFrameDotCorner.Parent = COLORPICKER_ColorPickerMainFrameDot
COLORPICKER_ColorPickerMainFrameDotCorner.CornerRadius = UDim.new(1,0)

local COLORPICKER_ColorPickerMainFrameDotGradient = Instance.new("UIGradient")
COLORPICKER_ColorPickerMainFrameDotGradient.Parent = COLORPICKER_ColorPickerMainFrameDot
COLORPICKER_ColorPickerMainFrameDotGradient.Rotation = 90
COLORPICKER_ColorPickerMainFrameDotGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(176,176,176))
}

local COLORPICKER_ColorPickerMainFrameDotStroke1 = Instance.new("UIStroke")
COLORPICKER_ColorPickerMainFrameDotStroke1.Parent = COLORPICKER_ColorPickerMainFrameDot
COLORPICKER_ColorPickerMainFrameDotStroke1.Color = Color3.fromRGB(0,0,0)
COLORPICKER_ColorPickerMainFrameDotStroke1.Thickness = 3
COLORPICKER_ColorPickerMainFrameDotStroke1.ZIndex = 1
COLORPICKER_ColorPickerMainFrameDotStroke1.Transparency = 0.88

local COLORPICKER_ColorPickerMainFrameDotStroke2 = Instance.new("UIStroke")
COLORPICKER_ColorPickerMainFrameDotStroke2.Parent = COLORPICKER_ColorPickerMainFrameDot
COLORPICKER_ColorPickerMainFrameDotStroke2.Color = Color3.fromRGB(0,0,0)
COLORPICKER_ColorPickerMainFrameDotStroke2.Thickness = 1
COLORPICKER_ColorPickerMainFrameDotStroke2.Transparency = 0.53
COLORPICKER_ColorPickerMainFrameDotStroke2.ZIndex = 2

local COLORPICKER_LastColorSplitterLine = Instance.new("Frame")
COLORPICKER_LastColorSplitterLine.Parent = COLORPICKER_MainFrameLastColorFolder
COLORPICKER_LastColorSplitterLine.Name = "LastColorSplitterLine"
COLORPICKER_LastColorSplitterLine.BackgroundTransparency = 0.65
COLORPICKER_LastColorSplitterLine.Position = UDim2.new(0.558,0,0.307,0)
COLORPICKER_LastColorSplitterLine.Size = UDim2.new(0,268,0,1)
COLORPICKER_LastColorSplitterLine.ZIndex = 1

local COLORPICKER_LastColorSplitterLineGradient = Instance.new("UIGradient")
COLORPICKER_LastColorSplitterLineGradient.Parent = COLORPICKER_LastColorSplitterLine
COLORPICKER_LastColorSplitterLineGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0,1,0),
	NumberSequenceKeypoint.new(0.5,0.45,0),
	NumberSequenceKeypoint.new(1,1,0)
}

local COLORPICKER_LastColorUpperGlow = Instance.new("Frame")
COLORPICKER_LastColorUpperGlow.Parent = COLORPICKER_LastColorSplitterLine
COLORPICKER_LastColorUpperGlow.Name = "UpperGlow"
COLORPICKER_LastColorUpperGlow.BackgroundTransparency = 0.85
COLORPICKER_LastColorUpperGlow.BackgroundColor3 = Color3.fromRGB(52,52,52)
COLORPICKER_LastColorUpperGlow.Position = UDim2.new(0,0,-44,0)
COLORPICKER_LastColorUpperGlow.Size = UDim2.new(0,269,0,44)
COLORPICKER_LastColorUpperGlow.ZIndex = 1

local COLORPICKER_LastColorUpperGlowGradient = Instance.new("UIGradient")
COLORPICKER_LastColorUpperGlowGradient.Parent = COLORPICKER_LastColorUpperGlow
COLORPICKER_LastColorUpperGlowGradient.Rotation = -90
COLORPICKER_LastColorUpperGlowGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0,0,0),
	NumberSequenceKeypoint.new(1,1,0)
}

local COLORPICKER_LastColorLowerGlow = Instance.new("Frame")
COLORPICKER_LastColorLowerGlow.Parent = COLORPICKER_LastColorSplitterLine
COLORPICKER_LastColorLowerGlow.Name = "LowerGlow"
COLORPICKER_LastColorLowerGlow.BackgroundTransparency = 0.9
COLORPICKER_LastColorLowerGlow.BackgroundColor3 = Color3.fromRGB(52,52,52)
COLORPICKER_LastColorLowerGlow.Position = UDim2.new(0,0,1,0)
COLORPICKER_LastColorLowerGlow.Size = UDim2.new(0,269,0,44)
COLORPICKER_LastColorLowerGlow.ZIndex = 1

local COLORPICKER_LastColorLowerGlowGradient = Instance.new("UIGradient")
COLORPICKER_LastColorLowerGlowGradient.Parent = COLORPICKER_LastColorLowerGlow
COLORPICKER_LastColorLowerGlowGradient.Rotation = 90
COLORPICKER_LastColorLowerGlowGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0,0.5,0),
	NumberSequenceKeypoint.new(1,1,0)
}

local COLORPICKER_LastColorRecentText = Instance.new("TextLabel")
COLORPICKER_LastColorRecentText.Parent = COLORPICKER_MainFrameLastColorFolder
COLORPICKER_LastColorRecentText.Name = "RecentText"
COLORPICKER_LastColorRecentText.BackgroundTransparency = 1
COLORPICKER_LastColorRecentText.Position = UDim2.new(0.587,0,0.12,0)
COLORPICKER_LastColorRecentText.Size = UDim2.new(0,82,0,33)
COLORPICKER_LastColorRecentText.Font = Enum.Font.RobotoMono
COLORPICKER_LastColorRecentText.Text = "Recent:"
COLORPICKER_LastColorRecentText.TextColor3 = Color3.fromRGB(86,86,86)
COLORPICKER_LastColorRecentText.TextSize = 12
COLORPICKER_LastColorRecentText.TextStrokeTransparency = 1
COLORPICKER_LastColorRecentText.TextXAlignment = Enum.TextXAlignment.Left

local COLORPICKER_LastColorLastColor1 = CreateLastColor(1, UDim2.new(0.589,0,0.201,0), COLORPICKER_MainFrameLastColorFolder)
local COLORPICKER_LastColorLastColor2 = CreateLastColor(2, UDim2.new(0.671,0,0.201,0), COLORPICKER_MainFrameLastColorFolder)
local COLORPICKER_LastColorLastColor3 = CreateLastColor(3, UDim2.new(0.753,0,0.201,0), COLORPICKER_MainFrameLastColorFolder)
local COLORPICKER_LastColorLastColor4 = CreateLastColor(4, UDim2.new(0.835,0,0.201,0), COLORPICKER_MainFrameLastColorFolder)
local COLORPICKER_LastColorLastColor5 = CreateLastColor(5, UDim2.new(0.917,0,0.201,0), COLORPICKER_MainFrameLastColorFolder)

local COLORPICKER_CurrentColorFrame = Instance.new("Frame")
COLORPICKER_CurrentColorFrame.Parent = COLORPICKER_MainFrame
COLORPICKER_CurrentColorFrame.Name = "CurrentColor"
COLORPICKER_CurrentColorFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
COLORPICKER_CurrentColorFrame.BorderSizePixel = 0
COLORPICKER_CurrentColorFrame.Position = UDim2.new(0.426,0,0.329,0)
COLORPICKER_CurrentColorFrame.Size = UDim2.new(0,43,0,166)
COLORPICKER_CurrentColorFrame.ZIndex = 1

local COLORPICKER_CurrentColorFrameCorner = Instance.new("UICorner")
COLORPICKER_CurrentColorFrameCorner.Parent = COLORPICKER_CurrentColorFrame
COLORPICKER_CurrentColorFrameCorner.CornerRadius = UDim.new(0,4)

local COLORPICKER_CurrentColorFrameStroke1 = Instance.new("UIStroke")
COLORPICKER_CurrentColorFrameStroke1.Parent = COLORPICKER_CurrentColorFrame
COLORPICKER_CurrentColorFrameStroke1.Color = Color3.fromRGB(65,65,65)
COLORPICKER_CurrentColorFrameStroke1.Thickness = 2
COLORPICKER_CurrentColorFrameStroke1.ZIndex = 1

local COLORPICKER_CurrentColorFrameStroke2 = Instance.new("UIStroke")
COLORPICKER_CurrentColorFrameStroke2.Parent = COLORPICKER_CurrentColorFrame
COLORPICKER_CurrentColorFrameStroke2.Color = Color3.fromRGB(0,0,0)
COLORPICKER_CurrentColorFrameStroke2.Thickness = 1
COLORPICKER_CurrentColorFrameStroke2.Transparency = 0.57
COLORPICKER_CurrentColorFrameStroke2.ZIndex = 2

local COLORPICKER_ColorSelectorFrame = Instance.new("Frame")
COLORPICKER_ColorSelectorFrame.Parent = COLORPICKER_MainFrame
COLORPICKER_ColorSelectorFrame.Name = "ColorSelector"
COLORPICKER_ColorSelectorFrame.BackgroundColor3 = Color3.fromRGB(209,209,209)
COLORPICKER_ColorSelectorFrame.Position = UDim2.new(0.526,0,0.199,0)
COLORPICKER_ColorSelectorFrame.Size = UDim2.new(0,19,0,219)
COLORPICKER_ColorSelectorFrame.ZIndex = 1

local COLORPICKER_ColorSelectorFrameCorner = Instance.new("UICorner")
COLORPICKER_ColorSelectorFrameCorner.Parent = COLORPICKER_ColorSelectorFrame
COLORPICKER_ColorSelectorFrameCorner.CornerRadius = UDim.new(0,4)

local COLORPICKER_ColorSelectorFrameGradient = Instance.new("UIGradient")
COLORPICKER_ColorSelectorFrameGradient.Parent = COLORPICKER_ColorSelectorFrame
COLORPICKER_ColorSelectorFrameGradient.Rotation = 90
-- There all colors gradient

local COLORPICKER_ColorSelectorFrameStroke1 = Instance.new("UIStroke")
COLORPICKER_ColorSelectorFrameStroke1.Parent = COLORPICKER_ColorSelectorFrame
COLORPICKER_ColorSelectorFrameStroke1.Color	= Color3.fromRGB(65,65,65)
COLORPICKER_ColorSelectorFrameStroke1.Thickness = 2
COLORPICKER_ColorSelectorFrameStroke1.ZIndex = 1

local COLORPICKER_ColorSelectorFrameStroke2 = Instance.new("UIStroke")
COLORPICKER_ColorSelectorFrameStroke2.Parent = COLORPICKER_ColorSelectorFrame
COLORPICKER_ColorSelectorFrameStroke2.Color	= Color3.fromRGB(0,0,0)
COLORPICKER_ColorSelectorFrameStroke2.Thickness = 1
COLORPICKER_ColorSelectorFrameStroke2.Transparency = 0.57
COLORPICKER_ColorSelectorFrameStroke2.ZIndex = 2

local COLORPICKER_ColorSelectorFrameSelectLine = Instance.new("Frame")
COLORPICKER_ColorSelectorFrameSelectLine.Parent = COLORPICKER_ColorSelectorFrame
COLORPICKER_ColorSelectorFrameSelectLine.Name = "SelectLine"
COLORPICKER_ColorSelectorFrameSelectLine.BackgroundColor3 = Color3.fromRGB(65,65,65)
COLORPICKER_ColorSelectorFrameSelectLine.Position = UDim2.new(0,0,0.74,0)
COLORPICKER_ColorSelectorFrameSelectLine.Size = UDim2.new(0,19,0,1)
COLORPICKER_ColorSelectorFrameSelectLine.ZIndex = 1

local COLORPICKER_ColorSelectorFrameSelectLineStroke = Instance.new("UIStroke")
COLORPICKER_ColorSelectorFrameSelectLineStroke.Parent = COLORPICKER_ColorSelectorFrameSelectLine
COLORPICKER_ColorSelectorFrameSelectLineStroke.Color = Color3.fromRGB(0,0,0)
COLORPICKER_ColorSelectorFrameSelectLineStroke.Thickness = 1.1
COLORPICKER_ColorSelectorFrameSelectLineStroke.Transparency = 0.4
COLORPICKER_ColorSelectorFrameSelectLineStroke.ZIndex = 1

local COLORPICKER_HeaderBgFrame = Instance.new("Frame")
COLORPICKER_HeaderBgFrame.Parent = COLORPICKER_MainFrame
COLORPICKER_HeaderBgFrame.Name = "HeaderBg"
COLORPICKER_HeaderBgFrame.BackgroundColor3 = Color3.fromRGB(24,24,24)
COLORPICKER_HeaderBgFrame.Position = UDim2.new(0,0,0,0)
COLORPICKER_HeaderBgFrame.Size = UDim2.new(0,608,0,50)
COLORPICKER_HeaderBgFrame.ZIndex = 5

local COLORPICKER_HeaderBgFrameCorner = Instance.new("UICorner")
COLORPICKER_HeaderBgFrameCorner.Parent = COLORPICKER_HeaderBgFrame
COLORPICKER_HeaderBgFrameCorner.CornerRadius = UDim.new(0,4)

local COLORPICKER_HeaderBgFrameGradient = Instance.new("UIGradient")
COLORPICKER_HeaderBgFrameGradient.Parent = COLORPICKER_HeaderBgFrame
COLORPICKER_HeaderBgFrameGradient.Rotation = -90
COLORPICKER_HeaderBgFrameGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(95,95,95)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
}

local COLORPICKER_HeaderBgFrameStroke = Instance.new("UIStroke")
COLORPICKER_HeaderBgFrameStroke.Parent = COLORPICKER_HeaderBgFrame
COLORPICKER_HeaderBgFrameStroke.Color = Color3.fromRGB(150,64,255)
COLORPICKER_HeaderBgFrameStroke.Thickness = 1
COLORPICKER_HeaderBgFrameStroke.ZIndex = 3

local COLORPICKER_HeaderBgFrameStrokeGradient = Instance.new("UIGradient")
COLORPICKER_HeaderBgFrameStrokeGradient.Parent = COLORPICKER_HeaderBgFrameStroke
COLORPICKER_HeaderBgFrameStrokeGradient.Rotation = -90
COLORPICKER_HeaderBgFrameStrokeGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0,0,0),
	NumberSequenceKeypoint.new(0.05,1,0),
	NumberSequenceKeypoint.new(1,1,0)
}

local COLORPICKER_HeaderBgFrameBgGlow = Instance.new("Frame")
COLORPICKER_HeaderBgFrameBgGlow.Parent = COLORPICKER_MainFrame
COLORPICKER_HeaderBgFrameBgGlow.BackgroundColor3 = Color3.fromRGB(150,64,255)
COLORPICKER_HeaderBgFrameBgGlow.BackgroundTransparency = 0.5
COLORPICKER_HeaderBgFrameBgGlow.ZIndex = 5
COLORPICKER_HeaderBgFrameBgGlow.Position = UDim2.new(0,0,0.119,0)
COLORPICKER_HeaderBgFrameBgGlow.Size = UDim2.new(0,608,0,17)
COLORPICKER_HeaderBgFrameBgGlow.Name = "HederBgGlow"

local COLORPICKER_HeaderBgFrameBgGlowGradient = Instance.new("UIGradient")
COLORPICKER_HeaderBgFrameBgGlowGradient.Parent = COLORPICKER_HeaderBgFrameBgGlow
COLORPICKER_HeaderBgFrameBgGlowGradient.Rotation = 90
COLORPICKER_HeaderBgFrameBgGlowGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0,0.732,0),
	NumberSequenceKeypoint.new(1,1,0)
}

local COLORPICKER_CloseButton = Instance.new("ImageButton")
COLORPICKER_CloseButton.Parent = COLORPICKER_MainFrame
COLORPICKER_CloseButton.Name = "CloseButton"
COLORPICKER_CloseButton.Image = _closeImageId
COLORPICKER_CloseButton.BackgroundTransparency = 1
COLORPICKER_CloseButton.Position = UDim2.new(0.929,0,0.017,0)
COLORPICKER_CloseButton.Size = UDim2.new(0,36,0,36)
COLORPICKER_CloseButton.ImageTransparency = 0.84
COLORPICKER_CloseButton.ImageColor3 = Color3.fromRGB(255,255,255)

local COLORPICKER_MoveBackButton = Instance.new("ImageButton")
COLORPICKER_MoveBackButton.Parent = COLORPICKER_MainFrame
COLORPICKER_MoveBackButton.Name = "MoveBackButton"
COLORPICKER_MoveBackButton.Position = UDim2.new(0.426,0,0.261,0)
COLORPICKER_MoveBackButton.Size = UDim2.new(0,20,0,20)
COLORPICKER_MoveBackButton.Image = _moveImageId
COLORPICKER_MoveBackButton.Rotation = 180
COLORPICKER_MoveBackButton.ImageTransparency = 0.25
COLORPICKER_MoveBackButton.ZIndex = 1
COLORPICKER_MoveBackButton.BackgroundTransparency = 1

local COLORPICKER_MoveForwardButton = Instance.new("ImageButton")
COLORPICKER_MoveForwardButton.Parent = COLORPICKER_MainFrame
COLORPICKER_MoveForwardButton.Name = "MoveForwardButton"
COLORPICKER_MoveForwardButton.Position = UDim2.new(0.464,0,0.261,0)
COLORPICKER_MoveForwardButton.Size = UDim2.new(0,20,0,20)
COLORPICKER_MoveForwardButton.Image = _moveImageId
COLORPICKER_MoveForwardButton.Rotation = 0
COLORPICKER_MoveForwardButton.ImageTransparency = 0.25
COLORPICKER_MoveForwardButton.ZIndex = 1
COLORPICKER_MoveForwardButton.BackgroundTransparency = 1

local COLORPICKER_RandomColor = Instance.new("ImageButton")
COLORPICKER_RandomColor.Parent = COLORPICKER_MainFrame
COLORPICKER_RandomColor.Name = "RandomColorButton"
COLORPICKER_RandomColor.BackgroundTransparency = 1
COLORPICKER_RandomColor.Position = UDim2.new(0.464,0,0.201,0)
COLORPICKER_RandomColor.Size = UDim2.new(0,20,0,20)
COLORPICKER_RandomColor.ImageTransparency = 0.25
COLORPICKER_RandomColor.Image = _randomImageId

local COLORPICKER_ResetToDefault = Instance.new("ImageButton")
COLORPICKER_ResetToDefault.Parent = COLORPICKER_MainFrame
COLORPICKER_ResetToDefault.Name = "ResetToDefaultButton"
COLORPICKER_ResetToDefault.BackgroundTransparency = 1
COLORPICKER_ResetToDefault.Position = UDim2.new(0.426,0,0.201,0)
COLORPICKER_ResetToDefault.Size = UDim2.new(0,20,0,20)
COLORPICKER_ResetToDefault.ZIndex = 1
COLORPICKER_ResetToDefault.ImageTransparency = 0.25
COLORPICKER_ResetToDefault.Image = _resetImageId

local COLORPICKER_WindowDesc = Instance.new("TextLabel")
COLORPICKER_WindowDesc.Parent = COLORPICKER_MainFrame
COLORPICKER_WindowDesc.BackgroundTransparency = 1
COLORPICKER_WindowDesc.ZIndex = 5
COLORPICKER_WindowDesc.Position = UDim2.new(0.016,0,0.042,0)
COLORPICKER_WindowDesc.Size = UDim2.new(0,97,0,32)
COLORPICKER_WindowDesc.Name = "WindowDesc"
COLORPICKER_WindowDesc.Font = Enum.Font.RobotoMono
COLORPICKER_WindowDesc.Text = "from: nil"
COLORPICKER_WindowDesc.TextTransparency = 0.65
COLORPICKER_WindowDesc.TextSize = 12
COLORPICKER_WindowDesc.TextColor3 = Color3.fromRGB(255,255,255)
COLORPICKER_WindowDesc.TextXAlignment = Enum.TextXAlignment.Left

local COLORPICKER_WindowName = Instance.new("TextLabel")
COLORPICKER_WindowName.Parent = COLORPICKER_MainFrame
COLORPICKER_WindowName.Name = "WindowName"
COLORPICKER_WindowName.BackgroundTransparency = 1
COLORPICKER_WindowName.Position = UDim2.new(0.016,0,0)
COLORPICKER_WindowName.Size = UDim2.new(0,97,0,32)
COLORPICKER_WindowName.TextXAlignment = Enum.TextXAlignment.Left
COLORPICKER_WindowName.TextSize = 16
COLORPICKER_WindowName.Font = Enum.Font.RobotoMono
COLORPICKER_WindowName.Text = "Color picker"
COLORPICKER_WindowName.TextColor3 = Color3.fromRGB(255,255,255)
COLORPICKER_WindowName.TextTransparency = 0.21
COLORPICKER_WindowName.ZIndex = 5

local COLORPCIKER_OtherText = Instance.new("TextLabel")
COLORPCIKER_OtherText.Parent = COLORPICKER_MainFrame
COLORPCIKER_OtherText.Name = "OtherText"
COLORPCIKER_OtherText.BackgroundTransparency = 1
COLORPCIKER_OtherText.Position = UDim2.new(0.587,0,0.312,0)
COLORPCIKER_OtherText.Size = UDim2.new(0,82,0,30)
COLORPCIKER_OtherText.ZIndex = 5
COLORPCIKER_OtherText.Font = Enum.Font.RobotoMono
COLORPCIKER_OtherText.TextColor3 = Color3.fromRGB(86,86,86)
COLORPCIKER_OtherText.TextSize = 12
COLORPCIKER_OtherText.Text = "Other: [no data, under development]"
COLORPCIKER_OtherText.TextXAlignment = Enum.TextXAlignment.Left

------------------------------------------------
--                                 Notifications
------------------------------------------------

local NOTIFICATIONS_MainFrame = Instance.new("Frame")
NOTIFICATIONS_MainFrame.Parent = NotificationsGui
NOTIFICATIONS_MainFrame.Name = "NotificationBackground"
NOTIFICATIONS_MainFrame.BackgroundColor3 = Color3.fromRGB(24,24,24)
NOTIFICATIONS_MainFrame.Position = UDim2.new(0.615,0,0.902,0)
NOTIFICATIONS_MainFrame.Size = UDim2.new(0,253,0,65)
NOTIFICATIONS_MainFrame.ZIndex = 1

local NOTIFICATIONS_MainFrameCorner = Instance.new("UICorner")
NOTIFICATIONS_MainFrameCorner.Parent = NOTIFICATIONS_MainFrame
NOTIFICATIONS_MainFrameCorner.CornerRadius = UDim.new(0,4)

local NOTIFICATIONS_MainFrameGradient = Instance.new("UIGradient")
NOTIFICATIONS_MainFrameGradient.Parent = NOTIFICATIONS_MainFrame
NOTIFICATIONS_MainFrameGradient.Rotation = -90
NOTIFICATIONS_MainFrameGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0,Color3.fromRGB(95,95,95)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))
}

local NOTIFICATIONS_MainFrameStroke1 = Instance.new("UIStroke")
NOTIFICATIONS_MainFrameStroke1.Parent = NOTIFICATIONS_MainFrame
NOTIFICATIONS_MainFrameStroke1.Color = Color3.fromRGB(56,56,56)
NOTIFICATIONS_MainFrameStroke1.Thickness = 2
NOTIFICATIONS_MainFrame.ZIndex = 0

local NOTIFICATIONS_MainFrameStroke2 = Instance.new("UIStroke")
NOTIFICATIONS_MainFrameStroke2.Parent = NOTIFICATIONS_MainFrame
NOTIFICATIONS_MainFrameStroke2.Color = Color3.fromRGB(0,0,0)
NOTIFICATIONS_MainFrameStroke2.Thickness = 1
NOTIFICATIONS_MainFrameStroke2.Transparency = 0.31
NOTIFICATIONS_MainFrameStroke2.ZIndex = 2

local NOTIFICATIONS_DragLine = Instance.new("Frame")
NOTIFICATIONS_DragLine.Parent = NOTIFICATIONS_MainFrame
NOTIFICATIONS_DragLine.Name = "DragLine"
NOTIFICATIONS_DragLine.Position = UDim2.new(0.024,0,0.169,0)
NOTIFICATIONS_DragLine.Size = UDim2.new(0,5,0,43)
NOTIFICATIONS_DragLine.ZIndex = 1
NOTIFICATIONS_DragLine.BackgroundColor3 = Color3.fromRGB(255,255,255)

local NOTIFICATIONS_DragLineCorner = Instance.new("UICorner")
NOTIFICATIONS_DragLineCorner.Parent = NOTIFICATIONS_DragLine
NOTIFICATIONS_DragLineCorner.CornerRadius = UDim.new(0,20)

local NOTIFICATIONS_DragLineGradient = Instance.new("UIGradient")
NOTIFICATIONS_DragLineGradient.Parent = NOTIFICATIONS_DragLine
NOTIFICATIONS_DragLineGradient.Rotation = 90
NOTIFICATIONS_DragLineGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0,Color3.fromRGB(146,74,255)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(80,33,152))
}

local NOTIFICATIONS_DragLineStroke = Instance.new("UIStroke")
NOTIFICATIONS_DragLineStroke.Parent = NOTIFICATIONS_DragLine
NOTIFICATIONS_DragLineStroke.Color = Color3.fromRGB(0,0,0)
NOTIFICATIONS_DragLineStroke.Thickness = 1
NOTIFICATIONS_DragLineStroke.Transparency = 0.72
NOTIFICATIONS_DragLineStroke.ZIndex = 1

local NOTIFICATIONS_TimeLine = Instance.new("Frame")
NOTIFICATIONS_TimeLine.Parent = NOTIFICATIONS_MainFrame
NOTIFICATIONS_TimeLine.Name = "TimeLine"
NOTIFICATIONS_TimeLine.BackgroundColor3 = Color3.fromRGB(150,64,255)
NOTIFICATIONS_TimeLine.BackgroundTransparency = 0.45
NOTIFICATIONS_TimeLine.Position = UDim2.new(0,0,0.975,0)
NOTIFICATIONS_TimeLine.Size = UDim2.new(0,253,0,2)
NOTIFICATIONS_TimeLine.ZIndex = 1

local NOTIFICATIONS_TimeLineCorner = Instance.new("UICorner")
NOTIFICATIONS_TimeLineCorner.Parent = NOTIFICATIONS_TimeLine
NOTIFICATIONS_TimeLineCorner.CornerRadius = UDim.new(0,80)

local NOTIFICATIONS_TimeLineGradient = Instance.new("UIGradient")
NOTIFICATIONS_TimeLineGradient.Parent = NOTIFICATIONS_TimeLine
NOTIFICATIONS_TimeLineGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0,Color3.fromRGB(137,98,255)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))
}

local NOTIFICATIONS_TimeLineGlow = Instance.new("Frame")
NOTIFICATIONS_TimeLineGlow.Parent = NOTIFICATIONS_MainFrame
NOTIFICATIONS_TimeLineGlow.Name = "TimeLineGlow"
NOTIFICATIONS_TimeLineGlow.BackgroundColor3 = Color3.fromRGB(150,64,255)
NOTIFICATIONS_TimeLineGlow.ZIndex = 5
NOTIFICATIONS_TimeLineGlow.Position = UDim2.new(0,0,0.728,0)
NOTIFICATIONS_TimeLineGlow.Size = UDim2.new(0,253,0,17)

local NOTIFICATIONS_TimeLineGlowGradient = Instance.new("UIGradient")
NOTIFICATIONS_TimeLineGlowGradient.Parent = NOTIFICATIONS_TimeLineGlow
NOTIFICATIONS_TimeLineGlowGradient.Rotation = 90
NOTIFICATIONS_TimeLineGlowGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0,1,0),
	NumberSequenceKeypoint.new(1,0.88,0)
}

local NOTIFICATIONS_CloseButton = Instance.new("ImageButton")
NOTIFICATIONS_CloseButton.Parent = NOTIFICATIONS_MainFrame
NOTIFICATIONS_CloseButton.Name = "CloseButton"
NOTIFICATIONS_CloseButton.BackgroundTransparency = 1
NOTIFICATIONS_CloseButton.Position = UDim2.new(0.91,0,0,0)
NOTIFICATIONS_CloseButton.Size = UDim2.new(0,22,0,22)
NOTIFICATIONS_CloseButton.ImageTransparency = 0.84
NOTIFICATIONS_CloseButton.Image = _closeImageId

local NOTIFICATIONS_FreezeButton = Instance.new("ImageButton")
NOTIFICATIONS_FreezeButton.Parent = NOTIFICATIONS_MainFrame
NOTIFICATIONS_FreezeButton.Name = "FreezeButton"
NOTIFICATIONS_FreezeButton.BackgroundTransparency = 1
NOTIFICATIONS_FreezeButton.Position = UDim2.new(0.822,0,0,0)
NOTIFICATIONS_FreezeButton.Size = UDim2.new(0,22,0,22)
NOTIFICATIONS_FreezeButton.ImageTransparency = 1

local NOTIFICATIONS_FreezeButtonIcon = Instance.new("ImageLabel")
NOTIFICATIONS_FreezeButtonIcon.Parent = NOTIFICATIONS_FreezeButton
NOTIFICATIONS_FreezeButtonIcon.Name = "FreezeButtonIcon"
NOTIFICATIONS_FreezeButtonIcon.Position = UDim2.new(0.5,0,0.5,0)
NOTIFICATIONS_FreezeButtonIcon.Size = UDim2.new(0,13,0,13)
NOTIFICATIONS_FreezeButtonIcon.Image = _freezeImageId
NOTIFICATIONS_FreezeButtonIcon.ImageTransparency = 0.84
NOTIFICATIONS_FreezeButtonIcon.BackgroundTransparency = 1
NOTIFICATIONS_FreezeButtonIcon.AnchorPoint = Vector2.new(.5,.5)

local NOTIFICATIONS_TimeLeft = Instance.new("TextLabel")
NOTIFICATIONS_TimeLeft.Parent = NOTIFICATIONS_MainFrame
NOTIFICATIONS_TimeLeft.Name = "TimeLeft"
NOTIFICATIONS_TimeLeft.BackgroundTransparency = 1
NOTIFICATIONS_TimeLeft.Position = UDim2.new(0.834,0,0.646,0)
NOTIFICATIONS_TimeLeft.Size = UDim2.new(0,35,0,23)
NOTIFICATIONS_TimeLeft.ZIndex = 1
NOTIFICATIONS_TimeLeft.Text = "3s"
NOTIFICATIONS_TimeLeft.Font = Enum.Font.RobotoMono
NOTIFICATIONS_TimeLeft.TextColor3 = Color3.fromRGB(63,63,63)
NOTIFICATIONS_TimeLeft.TextSize = 11
NOTIFICATIONS_TimeLeft.TextXAlignment = Enum.TextXAlignment.Right

local NOTIFICATIONS_NotificationName = Instance.new("TextLabel")
NOTIFICATIONS_NotificationName.Parent = NOTIFICATIONS_MainFrame
NOTIFICATIONS_NotificationName.Name = "NotificationName"
NOTIFICATIONS_NotificationName.BackgroundTransparency = 1
NOTIFICATIONS_NotificationName.ZIndex = 1
NOTIFICATIONS_NotificationName.Position = UDim2.new(0.075,0,0.031,0)
NOTIFICATIONS_NotificationName.Size = UDim2.new(0,72,0,23)
NOTIFICATIONS_NotificationName.Font = Enum.Font.RobotoMono
NOTIFICATIONS_NotificationName.Text = "Notification name"
NOTIFICATIONS_NotificationName.TextSize = 14
NOTIFICATIONS_NotificationName.TextColor3 = Color3.fromRGB(255,255,255)
NOTIFICATIONS_NotificationName.TextStrokeTransparency = 0.42
NOTIFICATIONS_NotificationName.TextStrokeColor3 = Color3.fromRGB(0,0,0)
NOTIFICATIONS_NotificationName.TextXAlignment = Enum.TextXAlignment.Left

local NOTIFICATIONS_NotificationDescription = Instance.new("TextLabel")
NOTIFICATIONS_NotificationDescription.Parent = NOTIFICATIONS_MainFrame
NOTIFICATIONS_NotificationDescription.Name = "NotificationDescription"
NOTIFICATIONS_NotificationDescription.BackgroundTransparency = 1
NOTIFICATIONS_NotificationDescription.ZIndex = 1
NOTIFICATIONS_NotificationDescription.Position = UDim2.new(0.075,0,0.262,0)
NOTIFICATIONS_NotificationDescription.Size = UDim2.new(0,182,0,37)
NOTIFICATIONS_NotificationDescription.Font = Enum.Font.RobotoMono
NOTIFICATIONS_NotificationDescription.Text = "Notification description"
NOTIFICATIONS_NotificationDescription.TextColor3 = Color3.fromRGB(161,161,161)
NOTIFICATIONS_NotificationDescription.TextSize = 12
NOTIFICATIONS_NotificationDescription.TextXAlignment = Enum.TextXAlignment.Left

local Category1, c1TabsHolderFrame = createTabCategory("Main", TABS_TabsBg)
local Tab1, tab1Scrolling = createTab("Player", c1TabsHolderFrame, MAIN_TabsContentFolder)
local Tab2, tab2Scrolling = createTab("World", c1TabsHolderFrame, MAIN_TabsContentFolder)
local section = createSection("Main", tab1Scrolling, "left")
local button = createButton("button", section, function()
	print("pressed")
end)
local dropdown = createDropdown("dropdown", section, -1)
local toggle = createToggle("toggle", section)
local colorPicker = createColorPicker("color picker", section)
local section2 = createSection("Player", tab1Scrolling, "right")
local textbox = createTextbox("textbox", section2)
local slider = createSlider("slider", section2)
local keybind = createKeybind("keybind", section2, "H")

tab1Scrolling.Visible = true
