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

--  Main
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

--  Interface
local PlayerGui = Player:WaitForChild("PlayerGui")
local Default_Parent = CoreGui

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

--──────────────────────────────────────────────────--
--──────────────────|> Functions
--──────────────────────────────────────────────────--

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

local function createButton(name, section, layoutOrder, ExplorerName)
	layoutOrder = layoutOrder or 0
	ExplorerName = ExplorerName or "Button"
	
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
	toggleButton.TextTransparency = 1
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
	nameText.TextColor3 = Color3.fromRGB(255,255,255)
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
	sliderButton.Size = UDim2.new(0,265,0,38)
	sliderButton.ZIndex = 1
	sliderButton.TextSize = 1
	sliderButton.Text = ""
	sliderButton.TextTransparency = 1
	sliderButton.BorderSizePixel = 0
	sliderButton.Interactable = false

	local nameText = Instance.new("TextLabel")
	nameText.Parent = sliderButton
	nameText.Name = "NameText"
	nameText.Size = UDim2.new(0,140,0,15)
	nameText.Position = UDim2.new(0,0,0,1)
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

	local sliderValueFrame = Instance.new("Frame")
	sliderValueFrame.Parent = sliderButton
	sliderValueFrame.Name = "SliderValueFrame"
	sliderValueFrame.BackgroundColor3 = Color3.fromRGB(104,104,104)
	sliderValueFrame.BorderSizePixel = 0
	sliderValueFrame.Position = UDim2.new(0.8,0,0,0)
	sliderValueFrame.Size = UDim2.new(0,53,0,18)
	sliderValueFrame.ZIndex = 1

	local sliderValueFrameCorner = Instance.new("UICorner")
	sliderValueFrameCorner.Parent = sliderValueFrame
	sliderValueFrameCorner.CornerRadius = UDim.new(0,4)

	local sliderValueFrameGradient = Instance.new("UIGradient")
	sliderValueFrameGradient.Parent = sliderValueFrame
	sliderValueFrameGradient.Rotation = -90
	sliderValueFrameGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(120,120,120)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
	})

	local sliderValueFrameStroke1 = Instance.new("UIStroke")
	sliderValueFrameStroke1.Parent = sliderValueFrame
	sliderValueFrameStroke1.Color = Color3.fromRGB(61,61,61)
	sliderValueFrameStroke1.Thickness = 2
	sliderValueFrameStroke1.ZIndex = 1

	local sliderValueFrameStroke2 = Instance.new("UIStroke")
	sliderValueFrameStroke2.Parent = sliderValueFrame
	sliderValueFrameStroke2.Color = Color3.fromRGB(0,0,0)
	sliderValueFrameStroke2.Thickness = 1
	sliderValueFrameStroke2.Transparency = 0.43
	sliderValueFrameStroke2.ZIndex = 2

	local sliderValueTextbox = Instance.new("TextBox")
	sliderValueTextbox.Parent = sliderValueFrame
	sliderValueTextbox.BackgroundTransparency = 1
	sliderValueTextbox.BorderSizePixel = 0
	sliderValueTextbox.Position = UDim2.new(0,0,0,0)
	sliderValueTextbox.Size = UDim2.new(1,0,1,0)
	sliderValueTextbox.Font = Enum.Font.RobotoMono
	sliderValueTextbox.PlaceholderColor3 = Color3.fromRGB(178,178,178)
	sliderValueTextbox.PlaceholderText = "0"
	sliderValueTextbox.Text = "0"
	sliderValueTextbox.TextSize = 12
	sliderValueTextbox.TextXAlignment = Enum.TextXAlignment.Center
	sliderValueTextbox.TextColor3 = Color3.fromRGB(255,255,255)
	sliderValueTextbox.ClearTextOnFocus = false
	sliderValueTextbox.ZIndex = 2

	local sliderLine = Instance.new("Frame")
	sliderLine.Parent = sliderButton
	sliderLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
	sliderLine.BorderSizePixel = 0
	sliderLine.Position = UDim2.new(0.209,0,0.71,0)
	sliderLine.Size = UDim2.new(0,181,0,5)
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
	sliderLineStroke.Thickness = 0.6
	sliderLineStroke.ZIndex = 1

	local sliderFill = Instance.new("Frame")
	sliderFill.Parent = sliderLine
	sliderFill.Name = "SliderFill"
	sliderFill.BackgroundColor3 = Color3.fromRGB(255,255,255)
	sliderFill.BorderSizePixel = 0
	sliderFill.Size = UDim2.new(0,0,1,0)
	sliderFill.ZIndex = 2

	local sliderFillCorner = Instance.new("UICorner")
	sliderFillCorner.Parent = sliderFill
	sliderFillCorner.CornerRadius = UDim.new(1,0)

	local sliderFillGradient = Instance.new("UIGradient")
	sliderFillGradient.Parent = sliderFill
	sliderFillGradient.Rotation = 0
	sliderFillGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(111,59,185)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(144,70,255))
	})

	local sliderFillStroke = Instance.new("UIStroke")
	sliderFillStroke.Parent = sliderFill
	sliderFillStroke.Color = Color3.fromRGB(0,0,0)
	sliderFillStroke.Thickness = 1
	sliderFillStroke.Transparency = 0.55
	sliderFillStroke.ZIndex = 3

	local sliderKnob = Instance.new("Frame")
	sliderKnob.Parent = sliderLine
	sliderKnob.Name = "SliderKnob"
	sliderKnob.AnchorPoint = Vector2.new(0.5,0.5)
	sliderKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
	sliderKnob.Position = UDim2.new(0.027,0,0.5,0)
	sliderKnob.Size = UDim2.new(0,12,0,12)
	sliderKnob.BorderSizePixel = 0
	sliderKnob.ZIndex = 4

	local sliderKnobCorner = Instance.new("UICorner")
	sliderKnobCorner.Parent = sliderKnob
	sliderKnobCorner.CornerRadius = UDim.new(1,0)

	local sliderKnobGradient = Instance.new("UIGradient")
	sliderKnobGradient.Parent = sliderKnob
	sliderKnobGradient.Rotation = -45
	sliderKnobGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(162,124,255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
	})

	local sliderKnobStroke1 = Instance.new("UIStroke")
	sliderKnobStroke1.Parent = sliderKnob
	sliderKnobStroke1.Color = Color3.fromRGB(61,61,61)
	sliderKnobStroke1.Thickness = 2
	sliderKnobStroke1.ZIndex = 4

	local sliderKnobStroke2 = Instance.new("UIStroke")
	sliderKnobStroke2.Parent = sliderKnob
	sliderKnobStroke2.Color = Color3.fromRGB(0,0,0)
	sliderKnobStroke2.Thickness = 1
	sliderKnobStroke2.Transparency = 0.43
	sliderKnobStroke2.ZIndex = 5

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
--──────────────────────────────────────────────────--
--──────────────────|> Build core ui
--──────────────────────────────────────────────────--

local function buildRootGuis()
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
    ColorPickerGui.Parent = Default_Parent
    ColorPickerGui.Enabled = false 
    ColorPickerGui.IgnoreGuiInset = true
    ColorPickerGui.ResetOnSpawn = false
    ColorPickerGui.DisplayOrder = 1
    ColorPickerGui.Name = "ColorPickerGui"

    local NotificationsGui = Instance.new("ScreenGui")
    NotificationsGui.Parent = Default_Parent
    NotificationsGui.Enabled = true
    NotificationsGui.IgnoreGuiInset = true
    NotificationsGui.ResetOnSpawn = false
    NotificationsGui.DisplayOrder = 100
    NotificationsGui.Name = "NotificationsGui"

    return {
        MainGui = MainGui,
        ColorPickerGui = ColorPickerGui,
        NotificationsGui = NotificationsGui,
    }
end

local function buildMainWindow(MainGui)
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

    return {
        MAIN_MainBgFrame = MAIN_MainBgFrame,
        MAIN_TabsContentFolder = MAIN_TabsContentFolder,
        MAIN_MainDarkFrame = MAIN_MainDarkFrame,
        MAIN_SearchFrame = MAIN_SearchFrame,
        MAIN_SearchFrameSearchImage = MAIN_SearchFrameSearchImage,
        MAIN_SearchFrameTextBox = MAIN_SearchFrameTextBox,
        MAIN_HeaderBgFrame = MAIN_HeaderBgFrame,
        MAIN_CloseButton = MAIN_CloseButton,
        MAIN_SettingsButton = MAIN_SettingsButton,
        TABS_TabsBg = TABS_TabsBg,
    }
end

local function buildColorPickerWindow(ColorPickerGui)
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
    COLORPICKER_ColorPickerMainFrameDot.Size = UDim2.new(0,12,0,12)
    COLORPICKER_ColorPickerMainFrameDot.AnchorPoint = Vector2.new(0.5,0.5)

    local COLORPICKER_ColorPickerMainFrameDotCorner = Instance.new("UICorner")
    COLORPICKER_ColorPickerMainFrameDotCorner.Parent = COLORPICKER_ColorPickerMainFrameDot
    COLORPICKER_ColorPickerMainFrameDotCorner.CornerRadius = UDim.new(1,0)

    local COLORPICKER_ColorPickerMainFrameDotGradient = Instance.new("UIGradient")
    COLORPICKER_ColorPickerMainFrameDotGradient.Parent = COLORPICKER_ColorPickerMainFrameDot
    COLORPICKER_ColorPickerMainFrameDotGradient.Rotation = 90
    COLORPICKER_ColorPickerMainFrameDotGradient.Color = ColorSequence.new{
    	ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
    	ColorSequenceKeypoint.new(1,Color3.fromRGB(220,220,220))
    }

    local COLORPICKER_ColorPickerMainFrameDotStroke1 = Instance.new("UIStroke")
    COLORPICKER_ColorPickerMainFrameDotStroke1.Parent = COLORPICKER_ColorPickerMainFrameDot
    COLORPICKER_ColorPickerMainFrameDotStroke1.Color = Color3.fromRGB(0,0,0)
    COLORPICKER_ColorPickerMainFrameDotStroke1.Thickness = 3
    COLORPICKER_ColorPickerMainFrameDotStroke1.ZIndex = 1
    COLORPICKER_ColorPickerMainFrameDotStroke1.Transparency = 0.72

    local COLORPICKER_ColorPickerMainFrameDotStroke2 = Instance.new("UIStroke")
    COLORPICKER_ColorPickerMainFrameDotStroke2.Parent = COLORPICKER_ColorPickerMainFrameDot
    COLORPICKER_ColorPickerMainFrameDotStroke2.Color = Color3.fromRGB(0,0,0)
    COLORPICKER_ColorPickerMainFrameDotStroke2.Thickness = 1
    COLORPICKER_ColorPickerMainFrameDotStroke2.Transparency = 0.22
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
    COLORPICKER_CloseButton.ZIndex = 7

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

local COLORPICKER_ValuesText = Instance.new("TextLabel")
COLORPICKER_ValuesText.Parent = COLORPICKER_MainFrame
COLORPICKER_ValuesText.Name = "ValuesText"
COLORPICKER_ValuesText.BackgroundTransparency = 1
COLORPICKER_ValuesText.Position = UDim2.new(0.587,0,0.312,0)
COLORPICKER_ValuesText.Size = UDim2.new(0,120,0,18)
COLORPICKER_ValuesText.ZIndex = 5
COLORPICKER_ValuesText.Font = Enum.Font.RobotoMono
COLORPICKER_ValuesText.TextColor3 = Color3.fromRGB(86,86,86)
COLORPICKER_ValuesText.TextSize = 12
COLORPICKER_ValuesText.Text = "Values:"
COLORPICKER_ValuesText.TextXAlignment = Enum.TextXAlignment.Left

local function createColorValueEntry(labelText, name, position)
    local holder = Instance.new("Frame")
    holder.Parent = COLORPICKER_MainFrame
    holder.Name = name .. "Holder"
    holder.BackgroundTransparency = 1
    holder.Position = position
    holder.Size = UDim2.new(0, 121, 0, 24)
    holder.ZIndex = 5

    local prefix = Instance.new("TextButton")
    prefix.Parent = holder
    prefix.Name = name .. "Prefix"
    prefix.AutoButtonColor = false
    prefix.BackgroundTransparency = 1
    prefix.Position = UDim2.new(0,0,0,0)
    prefix.Size = UDim2.new(0,24,1,0)
    prefix.Text = labelText
    prefix.Font = Enum.Font.RobotoMono
    prefix.TextColor3 = Color3.fromRGB(180,180,180)
    prefix.TextSize = 12
    prefix.TextXAlignment = Enum.TextXAlignment.Left
    prefix.ZIndex = 6

    local boxFrame = Instance.new("Frame")
    boxFrame.Parent = holder
    boxFrame.Name = name .. "Frame"
    boxFrame.BackgroundColor3 = Color3.fromRGB(104,104,104)
    boxFrame.BorderSizePixel = 0
    boxFrame.Position = UDim2.new(0,24,0,2)
    boxFrame.Size = UDim2.new(0,88,0,18)
    boxFrame.ZIndex = 5

    local boxFrameCorner = Instance.new("UICorner")
    boxFrameCorner.Parent = boxFrame
    boxFrameCorner.CornerRadius = UDim.new(0,4)

    local boxFrameGradient = Instance.new("UIGradient")
    boxFrameGradient.Parent = boxFrame
    boxFrameGradient.Rotation = -90
    boxFrameGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120,120,120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
    })

    local boxFrameStroke1 = Instance.new("UIStroke")
    boxFrameStroke1.Parent = boxFrame
    boxFrameStroke1.Color = Color3.fromRGB(61,61,61)
    boxFrameStroke1.Thickness = 2
    boxFrameStroke1.ZIndex = 5

    local boxFrameStroke2 = Instance.new("UIStroke")
    boxFrameStroke2.Parent = boxFrame
    boxFrameStroke2.Color = Color3.fromRGB(0,0,0)
    boxFrameStroke2.Thickness = 1
    boxFrameStroke2.Transparency = 0.43
    boxFrameStroke2.ZIndex = 6

    local box = Instance.new("TextBox")
    box.Parent = boxFrame
    box.Name = name
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Size = UDim2.new(1,0,1,0)
    box.Font = Enum.Font.RobotoMono
    box.Text = "0"
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.TextSize = 12
    box.ClearTextOnFocus = false
    box.ZIndex = 7

    return prefix, box
end

local COLORPICKER_RPrefix, COLORPICKER_RBox = createColorValueEntry("R:", "RBox", UDim2.new(0.587,0,0.382,0))
local COLORPICKER_GPrefix, COLORPICKER_GBox = createColorValueEntry("G:", "GBox", UDim2.new(0.765,0,0.382,0))
local COLORPICKER_BPrefix, COLORPICKER_BBox = createColorValueEntry("B:", "BBox", UDim2.new(0.587,0,0.448,0))
local COLORPICKER_HPrefix, COLORPICKER_HBox = createColorValueEntry("H:", "HBox", UDim2.new(0.765,0,0.448,0))
local COLORPICKER_SPrefix, COLORPICKER_SBox = createColorValueEntry("S:", "SBox", UDim2.new(0.587,0,0.514,0))
local COLORPICKER_VPrefix, COLORPICKER_VBox = createColorValueEntry("V:", "VBox", UDim2.new(0.765,0,0.514,0))

return {
        COLORPICKER_MainFrame = COLORPICKER_MainFrame,
        COLORPICKER_ColorPickerMainFrame = COLORPICKER_ColorPickerMainFrame,
        COLORPICKER_ColorPickerMainFrameDot = COLORPICKER_ColorPickerMainFrameDot,
        COLORPICKER_LastColorLastColor1 = COLORPICKER_LastColorLastColor1,
        COLORPICKER_LastColorLastColor2 = COLORPICKER_LastColorLastColor2,
        COLORPICKER_LastColorLastColor3 = COLORPICKER_LastColorLastColor3,
        COLORPICKER_LastColorLastColor4 = COLORPICKER_LastColorLastColor4,
        COLORPICKER_LastColorLastColor5 = COLORPICKER_LastColorLastColor5,
        COLORPICKER_CurrentColorFrame = COLORPICKER_CurrentColorFrame,
        COLORPICKER_ColorSelectorFrame = COLORPICKER_ColorSelectorFrame,
        COLORPICKER_ColorSelectorFrameGradient = COLORPICKER_ColorSelectorFrameGradient,
        COLORPICKER_ColorSelectorFrameSelectLine = COLORPICKER_ColorSelectorFrameSelectLine,
        COLORPICKER_HeaderBgFrame = COLORPICKER_HeaderBgFrame,
        COLORPICKER_CloseButton = COLORPICKER_CloseButton,
        COLORPICKER_MoveBackButton = COLORPICKER_MoveBackButton,
        COLORPICKER_MoveForwardButton = COLORPICKER_MoveForwardButton,
        COLORPICKER_RandomColor = COLORPICKER_RandomColor,
        COLORPICKER_ResetToDefault = COLORPICKER_ResetToDefault,
        COLORPICKER_WindowDesc = COLORPICKER_WindowDesc,
        COLORPICKER_RBox = COLORPICKER_RBox,
        COLORPICKER_GBox = COLORPICKER_GBox,
        COLORPICKER_BBox = COLORPICKER_BBox,
        COLORPICKER_HBox = COLORPICKER_HBox,
        COLORPICKER_SBox = COLORPICKER_SBox,
        COLORPICKER_VBox = COLORPICKER_VBox,
    }
end

local function buildNotificationsAndDemo(NotificationsGui, TABS_TabsBg, MAIN_TabsContentFolder)
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
    NOTIFICATIONS_NotificationDescription.TextWrapped = true
    NOTIFICATIONS_NotificationDescription.TextYAlignment = Enum.TextYAlignment.Top
    NOTIFICATIONS_NotificationDescription.TextXAlignment = Enum.TextXAlignment.Left

    local Category1, c1TabsHolderFrame = createTabCategory("Main", TABS_TabsBg)
    local Tab1, tab1Scrolling = createTab("Player", c1TabsHolderFrame, MAIN_TabsContentFolder)
    local Tab2, tab2Scrolling = createTab("World", c1TabsHolderFrame, MAIN_TabsContentFolder)
    local section = createSection("Main", tab1Scrolling, "left")
    local button = createButton("button", section)
    local dropdown = createDropdown("dropdown", section, -1)
    local toggle = createToggle("toggle", section)
    local colorPicker = createColorPicker("color picker", section)
    local section2 = createSection("Player", tab1Scrolling, "right")
    local textbox = createTextbox("textbox", section2)
    local slider = createSlider("slider", section2)
    local keybind = createKeybind("keybind", section2, "H")

    tab1Scrolling.Visible = true

    --──────────────────────────────────────────────────--

    return {
        NOTIFICATIONS_MainFrame = NOTIFICATIONS_MainFrame,
        button = button,
        dropdown = dropdown,
        toggle = toggle,
        colorPicker = colorPicker,
        textbox = textbox,
        slider = slider,
        keybind = keybind,
    }
end

local function createAmphibia()
local _rootRefs = buildRootGuis()
local MainGui = _rootRefs.MainGui
local ColorPickerGui = _rootRefs.ColorPickerGui
local NotificationsGui = _rootRefs.NotificationsGui

local _mainRefs = buildMainWindow(MainGui)
local MAIN_MainBgFrame = _mainRefs.MAIN_MainBgFrame
local MAIN_TabsContentFolder = _mainRefs.MAIN_TabsContentFolder
local MAIN_MainDarkFrame = _mainRefs.MAIN_MainDarkFrame
local MAIN_SearchFrame = _mainRefs.MAIN_SearchFrame
local MAIN_SearchFrameSearchImage = _mainRefs.MAIN_SearchFrameSearchImage
local MAIN_SearchFrameTextBox = _mainRefs.MAIN_SearchFrameTextBox
local MAIN_HeaderBgFrame = _mainRefs.MAIN_HeaderBgFrame
local MAIN_CloseButton = _mainRefs.MAIN_CloseButton
local MAIN_SettingsButton = _mainRefs.MAIN_SettingsButton
local TABS_TabsBg = _mainRefs.TABS_TabsBg

local _colorRefs = buildColorPickerWindow(ColorPickerGui)
local COLORPICKER_MainFrame = _colorRefs.COLORPICKER_MainFrame
local COLORPICKER_ColorPickerMainFrame = _colorRefs.COLORPICKER_ColorPickerMainFrame
local COLORPICKER_ColorPickerMainFrameDot = _colorRefs.COLORPICKER_ColorPickerMainFrameDot
local COLORPICKER_LastColorLastColor1 = _colorRefs.COLORPICKER_LastColorLastColor1
local COLORPICKER_LastColorLastColor2 = _colorRefs.COLORPICKER_LastColorLastColor2
local COLORPICKER_LastColorLastColor3 = _colorRefs.COLORPICKER_LastColorLastColor3
local COLORPICKER_LastColorLastColor4 = _colorRefs.COLORPICKER_LastColorLastColor4
local COLORPICKER_LastColorLastColor5 = _colorRefs.COLORPICKER_LastColorLastColor5
local COLORPICKER_CurrentColorFrame = _colorRefs.COLORPICKER_CurrentColorFrame
local COLORPICKER_ColorSelectorFrame = _colorRefs.COLORPICKER_ColorSelectorFrame
local COLORPICKER_ColorSelectorFrameGradient = _colorRefs.COLORPICKER_ColorSelectorFrameGradient
local COLORPICKER_ColorSelectorFrameSelectLine = _colorRefs.COLORPICKER_ColorSelectorFrameSelectLine
local COLORPICKER_HeaderBgFrame = _colorRefs.COLORPICKER_HeaderBgFrame
local COLORPICKER_CloseButton = _colorRefs.COLORPICKER_CloseButton
local COLORPICKER_MoveBackButton = _colorRefs.COLORPICKER_MoveBackButton
local COLORPICKER_MoveForwardButton = _colorRefs.COLORPICKER_MoveForwardButton
local COLORPICKER_RandomColor = _colorRefs.COLORPICKER_RandomColor
local COLORPICKER_ResetToDefault = _colorRefs.COLORPICKER_ResetToDefault
local COLORPICKER_WindowDesc = _colorRefs.COLORPICKER_WindowDesc
local COLORPICKER_RBox = _colorRefs.COLORPICKER_RBox
local COLORPICKER_GBox = _colorRefs.COLORPICKER_GBox
local COLORPICKER_BBox = _colorRefs.COLORPICKER_BBox
local COLORPICKER_HBox = _colorRefs.COLORPICKER_HBox
local COLORPICKER_SBox = _colorRefs.COLORPICKER_SBox
local COLORPICKER_VBox = _colorRefs.COLORPICKER_VBox

local _notificationRefs = buildNotificationsAndDemo(NotificationsGui, TABS_TabsBg, MAIN_TabsContentFolder)
local NOTIFICATIONS_MainFrame = _notificationRefs.NOTIFICATIONS_MainFrame
local button = _notificationRefs.button
local dropdown = _notificationRefs.dropdown
local toggle = _notificationRefs.toggle
local colorPicker = _notificationRefs.colorPicker
local textbox = _notificationRefs.textbox
local slider = _notificationRefs.slider
local keybind = _notificationRefs.keybind
--───────────────|> Functional layer
--──────────────────────────────────────────────────--

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TextService = game:GetService("TextService")

MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ColorPickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotificationsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Amphibia = {}

local function safeGetEnv()
	local ok, env = pcall(function()
		return getgenv and getgenv()
	end)

	if ok and type(env) == "table" then
		return env
	end

	return nil
end

local globalEnv = safeGetEnv()
if globalEnv then
	globalEnv.Amphibia = Amphibia
end

local DEFAULT_TWEEN = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SOFT_TWEEN = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local OPEN_TWEEN = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local CLOSE_TWEEN = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local function tween(obj, info, props)
	if not obj then
		return nil
	end

	local tw = TweenService:Create(obj, info or DEFAULT_TWEEN, props)
	tw:Play()
	return tw
end

local function clamp(n, a, b)
	return math.clamp(n, a, b)
end

local function roundToStep(value, step)
	step = tonumber(step) or 1
	if step <= 0 then
		return value
	end
	return math.floor((value / step) + 0.5) * step
end

local function formatNumber(value, decimals)
	decimals = decimals or 0
	if decimals <= 0 then
		return tostring(math.floor(value + 0.5))
	end
	return string.format("%." .. tostring(decimals) .. "f", value)
end

local function darkenColor3(color, factor)
	factor = factor or 0.92
	return Color3.new(color.R * factor, color.G * factor, color.B * factor)
end

local function lightenColor3(color, factor)
	factor = factor or 1.08
	return Color3.new(math.clamp(color.R * factor, 0, 1), math.clamp(color.G * factor, 0, 1), math.clamp(color.B * factor, 0, 1))
end

local function createScale(parent, value)
	local scale = Instance.new("UIScale")
	scale.Scale = value or 1
	scale.Parent = parent
	return scale
end

local function getViewportSize()
	local camera = Workspace.CurrentCamera
	if camera then
		return camera.ViewportSize
	end
	return Vector2.new(1920, 1080)
end

local function getMousePosition()
	return UIS:GetMouseLocation()
end

local function pointInGui(point, gui)
	if not gui or not gui.AbsolutePosition then
		return false
	end
	local pos = gui.AbsolutePosition
	local size = gui.AbsoluteSize
	return point.X >= pos.X and point.X <= pos.X + size.X and point.Y >= pos.Y and point.Y <= pos.Y + size.Y
end

local function setFrameTopLeft(frame, topLeft)
	if not frame then
		return
	end
	local size = frame.AbsoluteSize
	local anchor = frame.AnchorPoint
	frame.Position = UDim2.fromOffset(
		topLeft.X + (size.X * anchor.X),
		topLeft.Y + (size.Y * anchor.Y)
	)
end

local function toOffsetWindow(frame)
	task.defer(function()
		if not frame or not frame.Parent then
			return
		end
		RunService.Heartbeat:Wait()
		setFrameTopLeft(frame, frame.AbsolutePosition)
	end)
end

local function fadeGuiObjectTree(root, timeInfo)
	if not root then
		return
	end
	timeInfo = timeInfo or CLOSE_TWEEN
	for _, obj in ipairs(root:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			tween(obj, timeInfo, {TextTransparency = 1, TextStrokeTransparency = 1, BackgroundTransparency = 1})
		elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
			tween(obj, timeInfo, {ImageTransparency = 1, BackgroundTransparency = 1})
		elseif obj:IsA("Frame") then
			tween(obj, timeInfo, {BackgroundTransparency = 1})
		elseif obj:IsA("UIStroke") then
			tween(obj, timeInfo, {Transparency = 1})
		end
	end
end

local dragRegistry = {}

RunService.RenderStepped:Connect(function(dt)
	for _, data in pairs(dragRegistry) do
		if data.Frame and data.Frame.Parent and data.Target then
			if not data.Current then
				data.Current = Vector2.new(data.Target.X, data.Target.Y)
			end

			local alpha = data.Dragging and 1 or math.clamp(dt * 18, 0, 1)
			data.Current = Vector2.new(
				data.Current.X + (data.Target.X - data.Current.X) * alpha,
				data.Current.Y + (data.Target.Y - data.Current.Y) * alpha
			)

			if (data.Target - data.Current).Magnitude <= 0.05 then
				data.Current = Vector2.new(data.Target.X, data.Target.Y)
			end

			setFrameTopLeft(data.Frame, data.Current)
		end
	end
end)

local function makeDraggable(handle, frame)
	if not handle or not frame then
		return
	end

	handle.Active = true
	handle.Selectable = false

	local id = tostring(frame)
	dragRegistry[id] = dragRegistry[id] or {
		Frame = frame,
		Dragging = false,
		DragOffset = Vector2.zero,
		Target = nil,
		Current = nil,
	}

	task.defer(function()
		if not frame or not frame.Parent then
			return
		end
		RunService.Heartbeat:Wait()
		local pos = frame.AbsolutePosition
		local data = dragRegistry[id]
		if data then
			data.Target = Vector2.new(pos.X, pos.Y)
			data.Current = Vector2.new(pos.X, pos.Y)
			setFrameTopLeft(frame, data.Current)
		end
	end)

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		local data = dragRegistry[id]
		if not data then
			return
		end

		local mousePos = getMousePosition()
		local frameTopLeft = data.Current or frame.AbsolutePosition
		data.Dragging = true
		data.DragOffset = mousePos - frameTopLeft
		data.Target = Vector2.new(frameTopLeft.X, frameTopLeft.Y)
		data.Current = Vector2.new(frameTopLeft.X, frameTopLeft.Y)

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				data.Dragging = false
			end
		end)
	end)

	UIS.InputChanged:Connect(function(input)
		local data = dragRegistry[id]
		if not data or not data.Dragging then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end

		local mousePos = getMousePosition()
		data.Target = mousePos - data.DragOffset
		data.Current = Vector2.new(data.Target.X, data.Target.Y)
		setFrameTopLeft(frame, data.Current)
	end)
end

local function addRowHover(button)
	if not button or button:FindFirstChild("__HoverOverlay") then
		return button and button:FindFirstChild("__HoverOverlay")
	end

	if button:IsA("TextButton") or button:IsA("ImageButton") then
		button.AutoButtonColor = false
	end

	local overlay = Instance.new("Frame")
	overlay.Name = "__HoverOverlay"
	overlay.Parent = button
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.ZIndex = 0

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = overlay

	local function show(alpha)
		tween(overlay, DEFAULT_TWEEN, {BackgroundTransparency = alpha})
	end

	button.MouseEnter:Connect(function()
		show(0.93)
	end)

	button.MouseLeave:Connect(function()
		show(1)
	end)

	if button:IsA("TextButton") or button:IsA("ImageButton") then
		button.MouseButton1Down:Connect(function()
			show(0.89)
		end)
		button.MouseButton1Up:Connect(function()
			show(0.93)
		end)
	end

	return overlay
end

local function animateIconButton(button, baseTransparency, hoverTransparency)
	if not button then
		return
	end
	baseTransparency = baseTransparency or button.ImageTransparency
	hoverTransparency = hoverTransparency or math.max(baseTransparency - 0.18, 0)
	button.AutoButtonColor = false
	button.ImageTransparency = baseTransparency
	button.MouseEnter:Connect(function()
		tween(button, DEFAULT_TWEEN, {ImageTransparency = hoverTransparency})
	end)
	button.MouseLeave:Connect(function()
		tween(button, DEFAULT_TWEEN, {ImageTransparency = baseTransparency})
	end)
end

local function animateLabelButton(button, baseColor, hoverColor)
	if not button then
		return
	end
	baseColor = baseColor or button.TextColor3
	hoverColor = hoverColor or lightenColor3(baseColor, 1.12)
	button.AutoButtonColor = false
	button.MouseEnter:Connect(function()
		tween(button, DEFAULT_TWEEN, {TextColor3 = hoverColor})
	end)
	button.MouseLeave:Connect(function()
		tween(button, DEFAULT_TWEEN, {TextColor3 = baseColor})
	end)
end

local mainScale = createScale(MAIN_MainBgFrame, 0.97)
local pickerScale = createScale(COLORPICKER_MainFrame, 0.97)

MAIN_MainBgFrame.BackgroundTransparency = 1
COLORPICKER_MainFrame.BackgroundTransparency = 1
MAIN_MainDarkFrame.BackgroundTransparency = 1
ColorPickerGui.Enabled = false

animateIconButton(MAIN_CloseButton, 0.84, 0.58)
animateIconButton(MAIN_SettingsButton, 0.84, 0.58)
animateIconButton(COLORPICKER_CloseButton, 0.84, 0.58)
animateIconButton(COLORPICKER_MoveBackButton, 0.25, 0.05)
animateIconButton(COLORPICKER_MoveForwardButton, 0.25, 0.05)
animateIconButton(COLORPICKER_RandomColor, 0.25, 0.05)
animateIconButton(COLORPICKER_ResetToDefault, 0.25, 0.05)

local MAIN_HeaderDragHitbox = Instance.new("Frame")
MAIN_HeaderDragHitbox.Name = "HeaderDragHitbox"
MAIN_HeaderDragHitbox.Parent = MAIN_HeaderBgFrame
MAIN_HeaderDragHitbox.BackgroundTransparency = 1
MAIN_HeaderDragHitbox.Size = UDim2.fromScale(1, 1)
MAIN_HeaderDragHitbox.ZIndex = 0

local COLORPICKER_HeaderDragHitbox = Instance.new("Frame")
COLORPICKER_HeaderDragHitbox.Name = "HeaderDragHitbox"
COLORPICKER_HeaderDragHitbox.Parent = COLORPICKER_HeaderBgFrame
COLORPICKER_HeaderDragHitbox.BackgroundTransparency = 1
COLORPICKER_HeaderDragHitbox.Size = UDim2.fromScale(1, 1)
COLORPICKER_HeaderDragHitbox.ZIndex = 5

makeDraggable(MAIN_HeaderDragHitbox, MAIN_MainBgFrame)
makeDraggable(COLORPICKER_HeaderDragHitbox, COLORPICKER_MainFrame)

local function openMainMenuInstant()
	MainGui.Enabled = true
	MAIN_MainDarkFrame.BackgroundTransparency = 1
	MAIN_MainBgFrame.BackgroundTransparency = 1
	mainScale.Scale = 0.97
	tween(MAIN_MainDarkFrame, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.35})
	tween(MAIN_MainBgFrame, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
	tween(mainScale, OPEN_TWEEN, {Scale = 1})
end

openMainMenuInstant()

local ConfirmRoot = Instance.new("Frame")
ConfirmRoot.Name = "ConfirmRoot"
ConfirmRoot.Parent = MainGui
ConfirmRoot.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ConfirmRoot.BackgroundTransparency = 1
ConfirmRoot.BorderSizePixel = 0
ConfirmRoot.Size = UDim2.fromScale(1, 1)
ConfirmRoot.Visible = false
ConfirmRoot.ZIndex = 400

local ConfirmFrame = Instance.new("Frame")
ConfirmFrame.Name = "ConfirmFrame"
ConfirmFrame.Parent = ConfirmRoot
ConfirmFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
ConfirmFrame.AnchorPoint = Vector2.new(0.5, 0.5)
ConfirmFrame.Size = UDim2.fromOffset(335, 150)
ConfirmFrame.ZIndex = 401

local ConfirmFrameCorner = Instance.new("UICorner")
ConfirmFrameCorner.CornerRadius = UDim.new(0, 4)
ConfirmFrameCorner.Parent = ConfirmFrame

local ConfirmFrameGradient = Instance.new("UIGradient")
ConfirmFrameGradient.Rotation = -90
ConfirmFrameGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
}
ConfirmFrameGradient.Parent = ConfirmFrame

local ConfirmFrameStroke1 = Instance.new("UIStroke")
ConfirmFrameStroke1.Color = Color3.fromRGB(47, 47, 47)
ConfirmFrameStroke1.Thickness = 2
ConfirmFrameStroke1.Parent = ConfirmFrame

local ConfirmFrameStroke2 = Instance.new("UIStroke")
ConfirmFrameStroke2.Color = Color3.fromRGB(0, 0, 0)
ConfirmFrameStroke2.Thickness = 1
ConfirmFrameStroke2.Transparency = 0.16
ConfirmFrameStroke2.Parent = ConfirmFrame

local ConfirmHeader = Instance.new("Frame")
ConfirmHeader.Name = "Header"
ConfirmHeader.Parent = ConfirmFrame
ConfirmHeader.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
ConfirmHeader.Size = UDim2.new(1, 0, 0, 42)
ConfirmHeader.ZIndex = 402

local ConfirmHeaderCorner = Instance.new("UICorner")
ConfirmHeaderCorner.CornerRadius = UDim.new(0, 4)
ConfirmHeaderCorner.Parent = ConfirmHeader

local ConfirmHeaderGradient = Instance.new("UIGradient")
ConfirmHeaderGradient.Rotation = -90
ConfirmHeaderGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(95,95,95)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
}
ConfirmHeaderGradient.Parent = ConfirmHeader

local ConfirmHeaderStroke = Instance.new("UIStroke")
ConfirmHeaderStroke.Color = Color3.fromRGB(150,64,255)
ConfirmHeaderStroke.Thickness = 1
ConfirmHeaderStroke.Parent = ConfirmHeader

local ConfirmHeaderStrokeGradient = Instance.new("UIGradient")
ConfirmHeaderStrokeGradient.Rotation = -90
ConfirmHeaderStrokeGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0,0,0),
	NumberSequenceKeypoint.new(0.05,1,0),
	NumberSequenceKeypoint.new(1,1,0)
}
ConfirmHeaderStrokeGradient.Parent = ConfirmHeaderStroke

local ConfirmTitle = Instance.new("TextLabel")
ConfirmTitle.Parent = ConfirmHeader
ConfirmTitle.BackgroundTransparency = 1
ConfirmTitle.Position = UDim2.new(0.03, 0, 0, 0)
ConfirmTitle.Size = UDim2.new(0.7, 0, 1, 0)
ConfirmTitle.Font = Enum.Font.RobotoMono
ConfirmTitle.Text = "Close menu"
ConfirmTitle.TextColor3 = Color3.fromRGB(255,255,255)
ConfirmTitle.TextSize = 16
ConfirmTitle.TextXAlignment = Enum.TextXAlignment.Left
ConfirmTitle.ZIndex = 403

local ConfirmDesc = Instance.new("TextLabel")
ConfirmDesc.Parent = ConfirmFrame
ConfirmDesc.BackgroundTransparency = 1
ConfirmDesc.Position = UDim2.new(0.04, 0, 0.38, 0)
ConfirmDesc.Size = UDim2.new(0.92, 0, 0.22, 0)
ConfirmDesc.Font = Enum.Font.RobotoMono
ConfirmDesc.Text = "Are you sure you want to close the menu?"
ConfirmDesc.TextColor3 = Color3.fromRGB(186, 186, 186)
ConfirmDesc.TextSize = 13
ConfirmDesc.TextWrapped = true
ConfirmDesc.TextXAlignment = Enum.TextXAlignment.Left
ConfirmDesc.TextYAlignment = Enum.TextYAlignment.Top
ConfirmDesc.ZIndex = 403

local function createConfirmActionButton(text, position)
	local button = Instance.new("TextButton")
	button.Parent = ConfirmFrame
	button.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
	button.BorderSizePixel = 0
	button.Position = position
	button.Size = UDim2.fromOffset(138, 31)
	button.Text = ""
	button.ZIndex = 403

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = button

	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0, 0),
		NumberSequenceKeypoint.new(1, 0.86, 0)
	}
	gradient.Parent = button

	local stroke1 = Instance.new("UIStroke")
	stroke1.Color = Color3.fromRGB(40, 40, 40)
	stroke1.Thickness = 2
	stroke1.Parent = button

	local stroke2 = Instance.new("UIStroke")
	stroke2.Color = Color3.fromRGB(0, 0, 0)
	stroke2.Thickness = 1
	stroke2.Transparency = 0.38
	stroke2.Parent = button

	local label = Instance.new("TextLabel")
	label.Parent = button
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.RobotoMono
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.TextSize = 14
	label.ZIndex = 404

	addRowHover(button)
	return button
end

local ConfirmYes = createConfirmActionButton("Yes", UDim2.new(0.042, 0, 0.73, 0))
local ConfirmNo = createConfirmActionButton("No", UDim2.new(0.542, 0, 0.73, 0))

local confirmScale = createScale(ConfirmFrame, 0.97)
makeDraggable(ConfirmHeader, ConfirmFrame)

local confirmBusy = false
local function hideConfirm()
	if confirmBusy or not ConfirmRoot.Visible then
		return
	end
	confirmBusy = true
	tween(ConfirmRoot, CLOSE_TWEEN, {BackgroundTransparency = 1})
	tween(ConfirmFrame, CLOSE_TWEEN, {BackgroundTransparency = 1})
	tween(confirmScale, CLOSE_TWEEN, {Scale = 0.97})
	task.delay(0.22, function()
		ConfirmRoot.Visible = false
		ConfirmFrame.BackgroundTransparency = 0
		confirmBusy = false
	end)
end

local function showConfirm()
	if confirmBusy then
		return
	end
	confirmBusy = true
	ConfirmRoot.Visible = true
	ConfirmRoot.BackgroundTransparency = 1
	ConfirmFrame.BackgroundTransparency = 1
	confirmScale.Scale = 0.97
	RunService.Heartbeat:Wait()
	local viewport = getViewportSize()
	ConfirmFrame.Position = UDim2.fromOffset(math.floor(viewport.X * 0.5), math.floor(viewport.Y * 0.5))
	tween(ConfirmRoot, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.32})
	tween(ConfirmFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
	tween(confirmScale, OPEN_TWEEN, {Scale = 1})
	task.delay(0.23, function()
		confirmBusy = false
	end)
end

ConfirmNo.MouseButton1Click:Connect(hideConfirm)
ConfirmYes.MouseButton1Click:Connect(function()
	hideConfirm()
	ColorPickerGui.Enabled = false
	tween(MAIN_MainDarkFrame, CLOSE_TWEEN, {BackgroundTransparency = 1})
	tween(MAIN_MainBgFrame, CLOSE_TWEEN, {BackgroundTransparency = 1})
	tween(mainScale, CLOSE_TWEEN, {Scale = 0.97})
	task.delay(0.22, function()
		MainGui.Enabled = false
	end)
end)
MAIN_CloseButton.MouseButton1Click:Connect(showConfirm)

local DropdownRoot = Instance.new("Frame")
DropdownRoot.Name = "DropdownRoot"
DropdownRoot.Parent = MainGui
DropdownRoot.BackgroundTransparency = 1
DropdownRoot.Size = UDim2.fromScale(1, 1)
DropdownRoot.ZIndex = 250

local DropdownWindow = Instance.new("Frame")
DropdownWindow.Name = "DropdownWindow"
DropdownWindow.Parent = DropdownRoot
DropdownWindow.BackgroundColor3 = Color3.fromRGB(16,16,16)
DropdownWindow.BorderSizePixel = 0
DropdownWindow.ClipsDescendants = true
DropdownWindow.Size = UDim2.fromOffset(240, 0)
DropdownWindow.Visible = false
DropdownWindow.ZIndex = 251

local DropdownWindowCorner = Instance.new("UICorner")
DropdownWindowCorner.CornerRadius = UDim.new(0, 4)
DropdownWindowCorner.Parent = DropdownWindow

local DropdownWindowGradient = Instance.new("UIGradient")
DropdownWindowGradient.Rotation = -90
DropdownWindowGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
}
DropdownWindowGradient.Parent = DropdownWindow

local DropdownWindowStroke1 = Instance.new("UIStroke")
DropdownWindowStroke1.Color = Color3.fromRGB(47,47,47)
DropdownWindowStroke1.Thickness = 2
DropdownWindowStroke1.Parent = DropdownWindow

local DropdownWindowStroke2 = Instance.new("UIStroke")
DropdownWindowStroke2.Color = Color3.fromRGB(0,0,0)
DropdownWindowStroke2.Thickness = 1
DropdownWindowStroke2.Transparency = 0.5
DropdownWindowStroke2.ZIndex = 2
DropdownWindowStroke2.Parent = DropdownWindow

local DropdownHeader = Instance.new("Frame")
DropdownHeader.Name = "Header"
DropdownHeader.Parent = DropdownWindow
DropdownHeader.BackgroundColor3 = Color3.fromRGB(24,24,24)
DropdownHeader.Size = UDim2.new(1, 0, 0, 36)
DropdownHeader.ZIndex = 252

local DropdownHeaderCorner = Instance.new("UICorner")
DropdownHeaderCorner.CornerRadius = UDim.new(0, 4)
DropdownHeaderCorner.Parent = DropdownHeader

local DropdownHeaderGradient = Instance.new("UIGradient")
DropdownHeaderGradient.Rotation = -90
DropdownHeaderGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(95,95,95)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
}
DropdownHeaderGradient.Parent = DropdownHeader

local DropdownHeaderStroke = Instance.new("UIStroke")
DropdownHeaderStroke.Color = Color3.fromRGB(150,64,255)
DropdownHeaderStroke.Thickness = 1
DropdownHeaderStroke.Parent = DropdownHeader

local DropdownHeaderStrokeGradient = Instance.new("UIGradient")
DropdownHeaderStrokeGradient.Rotation = -90
DropdownHeaderStrokeGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0,0,0),
	NumberSequenceKeypoint.new(0.05,1,0),
	NumberSequenceKeypoint.new(1,1,0)
}
DropdownHeaderStrokeGradient.Parent = DropdownHeaderStroke

local DropdownTitle = Instance.new("TextLabel")
DropdownTitle.Name = "Title"
DropdownTitle.Parent = DropdownHeader
DropdownTitle.BackgroundTransparency = 1
DropdownTitle.Position = UDim2.new(0.04, 0, 0, 0)
DropdownTitle.Size = UDim2.new(0.92, 0, 1, 0)
DropdownTitle.Font = Enum.Font.RobotoMono
DropdownTitle.Text = "Picker"
DropdownTitle.TextColor3 = Color3.fromRGB(255,255,255)
DropdownTitle.TextSize = 14
DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
DropdownTitle.ZIndex = 253

local DropdownItems = Instance.new("ScrollingFrame")
DropdownItems.Name = "Items"
DropdownItems.Parent = DropdownWindow
DropdownItems.BackgroundTransparency = 1
DropdownItems.BorderSizePixel = 0
DropdownItems.Position = UDim2.new(0, 0, 0, 38)
DropdownItems.Size = UDim2.new(1, 0, 1, -40)
DropdownItems.AutomaticCanvasSize = Enum.AutomaticSize.Y
DropdownItems.CanvasSize = UDim2.new()
DropdownItems.ScrollBarImageTransparency = 1
DropdownItems.ScrollBarThickness = 0
DropdownItems.ZIndex = 252

local DropdownItemsLayout = Instance.new("UIListLayout")
DropdownItemsLayout.Padding = UDim.new(0, 4)
DropdownItemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
DropdownItemsLayout.Parent = DropdownItems

local DropdownItemsPadding = Instance.new("UIPadding")
DropdownItemsPadding.PaddingLeft = UDim.new(0, 6)
DropdownItemsPadding.PaddingRight = UDim.new(0, 6)
DropdownItemsPadding.PaddingTop = UDim.new(0, 6)
DropdownItemsPadding.PaddingBottom = UDim.new(0, 6)
DropdownItemsPadding.Parent = DropdownItems

local activeDropdown = nil
local dropdownBindings = setmetatable({}, {__mode = "k"})

local function closeDropdown()
	if not activeDropdown then
		return
	end
	local closing = activeDropdown
	activeDropdown = nil
	local h = DropdownWindow.AbsoluteSize.Y > 0 and DropdownWindow.AbsoluteSize.Y or DropdownWindow.Size.Y.Offset
	tween(DropdownWindow, CLOSE_TWEEN, {Size = UDim2.fromOffset(DropdownWindow.Size.X.Offset, 0), Position = UDim2.fromOffset(DropdownWindow.Position.X.Offset, DropdownWindow.Position.Y.Offset + 6)})
	task.delay(0.22, function()
		if not activeDropdown and closing then
			DropdownWindow.Visible = false
			DropdownWindow.Size = UDim2.fromOffset(DropdownWindow.Size.X.Offset, h)
		end
	end)
end

local function createDropdownItem(binding, item)
	local button = Instance.new("TextButton")
	button.Name = tostring(item.Text or item.Value or "Option")
	button.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	button.BorderSizePixel = 0
	button.Size = UDim2.new(1, 0, 0, 28)
	button.Text = ""
	button.ZIndex = 253
	button.Parent = DropdownItems

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = button

	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0, 0),
		NumberSequenceKeypoint.new(1, 0.88, 0)
	}
	gradient.Parent = button

	local stroke1 = Instance.new("UIStroke")
	stroke1.Color = Color3.fromRGB(39, 39, 39)
	stroke1.Thickness = 2
	stroke1.Parent = button

	local stroke2 = Instance.new("UIStroke")
	stroke2.Color = Color3.fromRGB(0,0,0)
	stroke2.Thickness = 1
	stroke2.Transparency = 0.4
	stroke2.Parent = button

	local label = Instance.new("TextLabel")
	label.Name = "ItemText"
	label.Parent = button
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0.04, 0, 0, 0)
	label.Size = UDim2.new(0.82, 0, 1, 0)
	label.Font = Enum.Font.RobotoMono
	label.Text = tostring(item.Text or item.Value or "Option")
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 254

	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Parent = button
	indicator.AnchorPoint = Vector2.new(0.5, 0.5)
	indicator.Position = UDim2.new(0.94, 0, 0.5, 0)
	indicator.Size = UDim2.fromOffset(12, 12)
	indicator.BackgroundColor3 = Color3.fromRGB(255,255,255)
	indicator.BorderSizePixel = 0
	indicator.Visible = false
	indicator.ZIndex = 254

	local indCorner = Instance.new("UICorner")
	indCorner.CornerRadius = UDim.new(1, 0)
	indCorner.Parent = indicator

	local indGradient = Instance.new("UIGradient")
	indGradient.Rotation = -90
	indGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(111,59,185)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(144,70,255))
	}
	indGradient.Parent = indicator

	local indStroke = Instance.new("UIStroke")
	indStroke.Color = Color3.fromRGB(0,0,0)
	indStroke.Thickness = 1
	indStroke.Transparency = 0.45
	indStroke.Parent = indicator

	addRowHover(button)

	local function refreshIndicator()
		if binding.Multi then
			indicator.Visible = binding.Selected[tostring(item.Value)] == true
		else
			indicator.Visible = binding.Selected == item.Value
		end
	end

	refreshIndicator()

	button.MouseButton1Click:Connect(function()
		if binding.Multi then
			local key = tostring(item.Value)
			binding.Selected[key] = not binding.Selected[key]
			refreshIndicator()
			if binding.Callback then
				binding.Callback(binding.Selected)
			end
		else
			binding.Selected = item.Value
			if binding.Callback then
				binding.Callback(item.Value, item)
			end
			if item.Callback then
				item.Callback(item.Value, item)
			end
		end

		if binding.Multi and item.Callback then
			item.Callback(binding.Selected)
		end
	end)
end

local function rebuildDropdown(binding)
	for _, child in ipairs(DropdownItems:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	for _, item in ipairs(binding.Items) do
		createDropdownItem(binding, item)
	end
end

local function openDropdown(binding)
	if not binding or not binding.Button or not binding.Button.Parent then
		return
	end

	if activeDropdown == binding then
		closeDropdown()
		return
	end

	activeDropdown = binding
	DropdownTitle.Text = binding.Title or binding.Button:FindFirstChild("NameText") and binding.Button.NameText.Text or "Picker"
	rebuildDropdown(binding)

	local contentHeight = 12 + (#binding.Items * 32)
	local targetHeight = math.clamp(contentHeight + 40, 74, binding.MaxHeight or 220)
	local buttonPos = binding.Button.AbsolutePosition
	local mousePos = getMousePosition()
	local viewport = getViewportSize()
	local targetX = mousePos.X + 12
	local targetY = buttonPos.Y

	if targetX + 240 > viewport.X - 10 then
		targetX = math.max(10, mousePos.X - 252)
	end
	if targetY + targetHeight > viewport.Y - 10 then
		targetY = math.max(10, viewport.Y - targetHeight - 10)
	end

	DropdownWindow.Visible = true
	DropdownWindow.Position = UDim2.fromOffset(targetX, targetY)
	DropdownWindow.Size = UDim2.fromOffset(240, 0)
	tween(DropdownWindow, OPEN_TWEEN, {Size = UDim2.fromOffset(240, targetHeight)})
end

function Amphibia.BindDropdown(dropdownButton, config)
	config = config or {}
	local binding = dropdownBindings[dropdownButton]
	if binding then
		return binding.API
	end

	binding = {
		Button = dropdownButton,
		Items = {},
		Selected = config.Multi and {} or config.Default,
		Multi = config.Multi == true,
		Title = config.Title,
		MaxHeight = config.MaxHeight or 220,
		Callback = config.Callback,
		API = nil
	}
	addRowHover(dropdownButton)
	local dots = dropdownButton:FindFirstChild("SettingsImageLabel")
	if dots and dots:IsA("ImageLabel") then
		dropdownButton.MouseEnter:Connect(function()
			tween(dots, DEFAULT_TWEEN, {ImageTransparency = 0.08})
		end)
		dropdownButton.MouseLeave:Connect(function()
			tween(dots, DEFAULT_TWEEN, {ImageTransparency = 0.26})
		end)
	end
	for _, item in ipairs(config.Items or {}) do
		table.insert(binding.Items, {
			Text = item.Text or tostring(item),
			Value = item.Value ~= nil and item.Value or item,
			Callback = item.Callback
		})
	end

	dropdownButton.MouseButton1Click:Connect(function()
		openDropdown(binding)
	end)

	local api = {}
	function api:AddOption(text, value, callback)
		table.insert(binding.Items, {
			Text = text,
			Value = value ~= nil and value or text,
			Callback = callback
		})
		if activeDropdown == binding then
			rebuildDropdown(binding)
		end
		return api
	end
	function api:AddButton(text, callback)
		return api:AddOption(text, text, callback)
	end
	function api:Clear()
		table.clear(binding.Items)
		if binding.Multi then
			table.clear(binding.Selected)
		else
			binding.Selected = nil
		end
		if activeDropdown == binding then
			rebuildDropdown(binding)
		end
		return api
	end
	function api:Open()
		openDropdown(binding)
		return api
	end
	function api:Close()
		if activeDropdown == binding then
			closeDropdown()
		end
		return api
	end
	function api:GetSelected()
		return binding.Selected
	end
	function api:SetCallback(callback)
		binding.Callback = callback
		return api
	end

	binding.API = api
	dropdownBindings[dropdownButton] = binding
	return api
end

UIS.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end
	if activeDropdown and not pointInGui(getMousePosition(), DropdownWindow) and not pointInGui(getMousePosition(), activeDropdown.Button) then
		closeDropdown()
	end
end)

local colorSelectorRainbow = ColorSequence.new{
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
}
COLORPICKER_ColorSelectorFrameGradient.Color = colorSelectorRainbow
COLORPICKER_ColorPickerMainFrame.ClipsDescendants = true
COLORPICKER_ColorPickerMainFrame.Active = true
COLORPICKER_ColorSelectorFrame.Active = true

local CP_SatOverlay = Instance.new("Frame")
CP_SatOverlay.Name = "SatOverlay"
CP_SatOverlay.Parent = COLORPICKER_ColorPickerMainFrame
CP_SatOverlay.BackgroundColor3 = Color3.fromRGB(255,255,255)
CP_SatOverlay.BorderSizePixel = 0
CP_SatOverlay.Size = UDim2.fromScale(1, 1)
CP_SatOverlay.ZIndex = 0

local CP_SatGradient = Instance.new("UIGradient")
CP_SatGradient.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1))
CP_SatGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(1, 1)
}
CP_SatGradient.Parent = CP_SatOverlay

local CP_ValueOverlay = Instance.new("Frame")
CP_ValueOverlay.Name = "ValueOverlay"
CP_ValueOverlay.Parent = COLORPICKER_ColorPickerMainFrame
CP_ValueOverlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
CP_ValueOverlay.BorderSizePixel = 0
CP_ValueOverlay.Size = UDim2.fromScale(1, 1)
CP_ValueOverlay.ZIndex = 0

local CP_ValueGradient = Instance.new("UIGradient")
CP_ValueGradient.Rotation = 90
CP_ValueGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(1, 0)
}
CP_ValueGradient.Parent = CP_ValueOverlay

local colorPickerBindings = setmetatable({}, {__mode = "k"})
local colorPickerActiveBinding = nil
local colorPickerState = {
	Hue = 0,
	Sat = 1,
	Val = 1,
	Recent = {},
	DraggingSquare = false,
	DraggingHue = false
}

local function recolorLastColorFrames()
	local frames = {
		COLORPICKER_LastColorLastColor1,
		COLORPICKER_LastColorLastColor2,
		COLORPICKER_LastColorLastColor3,
		COLORPICKER_LastColorLastColor4,
		COLORPICKER_LastColorLastColor5,
	}

	for index, frame in ipairs(frames) do
		local color = colorPickerState.Recent[index]
		if color then
			frame.Visible = true
			frame.BackgroundColor3 = color
		else
			frame.Visible = false
		end
	end
end

local function pushRecentColor(color)
	if not color then
		return
	end
	for i = #colorPickerState.Recent, 1, -1 do
		local c = colorPickerState.Recent[i]
		if c and math.abs(c.R - color.R) < 0.001 and math.abs(c.G - color.G) < 0.001 and math.abs(c.B - color.B) < 0.001 then
			table.remove(colorPickerState.Recent, i)
		end
	end
	table.insert(colorPickerState.Recent, 1, color)
	while #colorPickerState.Recent > 5 do
		table.remove(colorPickerState.Recent, #colorPickerState.Recent)
	end
	recolorLastColorFrames()
end

local function refreshColorPickerValueBoxes()
	local currentColor = Color3.fromHSV(colorPickerState.Hue, colorPickerState.Sat, colorPickerState.Val)
	if COLORPICKER_RBox then COLORPICKER_RBox.Text = tostring(math.floor(currentColor.R * 255 + 0.5)) end
	if COLORPICKER_GBox then COLORPICKER_GBox.Text = tostring(math.floor(currentColor.G * 255 + 0.5)) end
	if COLORPICKER_BBox then COLORPICKER_BBox.Text = tostring(math.floor(currentColor.B * 255 + 0.5)) end
	if COLORPICKER_HBox then COLORPICKER_HBox.Text = tostring(math.floor(colorPickerState.Hue * 360 + 0.5)) end
	if COLORPICKER_SBox then COLORPICKER_SBox.Text = tostring(math.floor(colorPickerState.Sat * 100 + 0.5)) end
	if COLORPICKER_VBox then COLORPICKER_VBox.Text = tostring(math.floor(colorPickerState.Val * 100 + 0.5)) end
end

local function updateColorPickerVisuals()
	local hueColor = Color3.fromHSV(colorPickerState.Hue, 1, 1)
	local currentColor = Color3.fromHSV(colorPickerState.Hue, colorPickerState.Sat, colorPickerState.Val)
	COLORPICKER_ColorPickerMainFrame.BackgroundColor3 = hueColor
	COLORPICKER_CurrentColorFrame.BackgroundColor3 = currentColor
	tween(COLORPICKER_ColorPickerMainFrameDot, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(colorPickerState.Sat, 0, 1 - colorPickerState.Val, 0)
	})
	tween(COLORPICKER_ColorSelectorFrameSelectLine, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, colorPickerState.Hue, 0)
	})
	refreshColorPickerValueBoxes()
end

local function pushColorHistory(binding, color)
	if not binding or not color then
		return
	end
	binding.History = binding.History or {}
	binding.HistoryIndex = binding.HistoryIndex or 0
	if binding.HistoryIndex > 0 and binding.History[binding.HistoryIndex] then
		local current = binding.History[binding.HistoryIndex]
		if math.abs(current.R - color.R) < 0.001 and math.abs(current.G - color.G) < 0.001 and math.abs(current.B - color.B) < 0.001 then
			return
		end
	end
	for i = #binding.History, binding.HistoryIndex + 1, -1 do
		table.remove(binding.History, i)
	end
	table.insert(binding.History, color)
	binding.HistoryIndex = #binding.History
end

local function applyColorToBinding(binding, color, pushHistory)
	if not binding then
		return
	end
	binding.Value = color
	local preview = binding.Button and binding.Button:FindFirstChild("ColorPreview")
	if preview then
		preview.BackgroundColor3 = color
	end
	COLORPICKER_CurrentColorFrame.BackgroundColor3 = color
	if pushHistory then
		pushColorHistory(binding, color)
		pushRecentColor(color)
	end
	if binding.Callback then
		binding.Callback(color)
	end
end

local function syncColorPickerFromColor(color)
	local h, s, v = color:ToHSV()
	colorPickerState.Hue = h
	colorPickerState.Sat = s
	colorPickerState.Val = v
	updateColorPickerVisuals()
end

local function setActivePicker(binding)
	colorPickerActiveBinding = binding
	if not binding then
		return
	end
	COLORPICKER_WindowDesc.Text = "from: " .. ((binding.Button and binding.Button:FindFirstChild("NameText") and binding.Button.NameText.Text) or "nil")
	syncColorPickerFromColor(binding.Value or Color3.new(1,1,1))
	updateColorPickerVisuals()
end

local function openColorPicker(binding)
	if not binding then
		return
	end
	setActivePicker(binding)
	ColorPickerGui.Enabled = true
	COLORPICKER_MainFrame.BackgroundTransparency = 1
	pickerScale.Scale = 0.97
	tween(COLORPICKER_MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
	tween(pickerScale, OPEN_TWEEN, {Scale = 1})
end

local function closeColorPicker()
	if not ColorPickerGui.Enabled then
		return
	end
	if colorPickerActiveBinding then
		pushRecentColor(colorPickerActiveBinding.Value)
	end
	tween(COLORPICKER_MainFrame, CLOSE_TWEEN, {BackgroundTransparency = 1})
	tween(pickerScale, CLOSE_TWEEN, {Scale = 0.97})
	task.delay(0.22, function()
		ColorPickerGui.Enabled = false
	end)
end

local function colorFromState()
	return Color3.fromHSV(colorPickerState.Hue, colorPickerState.Sat, colorPickerState.Val)
end

local function commitCurrentColor(pushHistory)
	if not colorPickerActiveBinding then
		return
	end
	applyColorToBinding(colorPickerActiveBinding, colorFromState(), pushHistory)
end

local function updateSquareFromMouse(mousePosition)
	local pos = COLORPICKER_ColorPickerMainFrame.AbsolutePosition
	local size = COLORPICKER_ColorPickerMainFrame.AbsoluteSize
	colorPickerState.Sat = clamp((mousePosition.X - pos.X) / size.X, 0, 1)
	colorPickerState.Val = 1 - clamp((mousePosition.Y - pos.Y) / size.Y, 0, 1)
	updateColorPickerVisuals()
	commitCurrentColor(false)
end

local function updateHueFromMouse(mousePosition)
	local pos = COLORPICKER_ColorSelectorFrame.AbsolutePosition
	local size = COLORPICKER_ColorSelectorFrame.AbsoluteSize
	colorPickerState.Hue = clamp((mousePosition.Y - pos.Y) / size.Y, 0, 1)
	updateColorPickerVisuals()
	commitCurrentColor(false)
end

COLORPICKER_ColorPickerMainFrame.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end
	colorPickerState.DraggingSquare = true
	updateSquareFromMouse(getMousePosition())
end)

COLORPICKER_ColorSelectorFrame.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end
	colorPickerState.DraggingHue = true
	updateHueFromMouse(getMousePosition())
end)

UIS.InputChanged:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end
	local mousePos = getMousePosition()
	if colorPickerState.DraggingSquare then
		updateSquareFromMouse(mousePos)
	elseif colorPickerState.DraggingHue then
		updateHueFromMouse(mousePos)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end
	if colorPickerState.DraggingSquare or colorPickerState.DraggingHue then
		colorPickerState.DraggingSquare = false
		colorPickerState.DraggingHue = false
		commitCurrentColor(true)
	end
end)

for _, frame in ipairs({COLORPICKER_LastColorLastColor1, COLORPICKER_LastColorLastColor2, COLORPICKER_LastColorLastColor3, COLORPICKER_LastColorLastColor4, COLORPICKER_LastColorLastColor5}) do
	frame.Active = true
	frame.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		if not colorPickerActiveBinding then
			return
		end
		syncColorPickerFromColor(frame.BackgroundColor3)
		commitCurrentColor(true)
	end)
end

COLORPICKER_CloseButton.MouseButton1Click:Connect(closeColorPicker)
COLORPICKER_ResetToDefault.MouseButton1Click:Connect(function()
	if not colorPickerActiveBinding then
		return
	end
	syncColorPickerFromColor(colorPickerActiveBinding.Default or Color3.new(1,1,1))
	commitCurrentColor(true)
end)
COLORPICKER_RandomColor.MouseButton1Click:Connect(function()
	local color = Color3.fromHSV(math.random(), 0.75 + math.random() * 0.25, 0.75 + math.random() * 0.25)
	syncColorPickerFromColor(color)
	commitCurrentColor(true)
end)
COLORPICKER_MoveBackButton.MouseButton1Click:Connect(function()
	local binding = colorPickerActiveBinding
	if not binding or not binding.History or (binding.HistoryIndex or 0) <= 1 then
		return
	end
	binding.HistoryIndex -= 1
	local color = binding.History[binding.HistoryIndex]
	if color then
		syncColorPickerFromColor(color)
		applyColorToBinding(binding, color, false)
	end
end)
COLORPICKER_MoveForwardButton.MouseButton1Click:Connect(function()
	local binding = colorPickerActiveBinding
	if not binding or not binding.History or (binding.HistoryIndex or 0) >= #binding.History then
		return
	end
	binding.HistoryIndex += 1
	local color = binding.History[binding.HistoryIndex]
	if color then
		syncColorPickerFromColor(color)
		applyColorToBinding(binding, color, false)
	end
end)

local function commitBoxesToColor(mode)
	local binding = colorPickerActiveBinding
	if not binding then
		return
	end

	if mode == "RGB" then
		local r = clamp(tonumber(COLORPICKER_RBox and COLORPICKER_RBox.Text) or 0, 0, 255)
		local g = clamp(tonumber(COLORPICKER_GBox and COLORPICKER_GBox.Text) or 0, 0, 255)
		local b = clamp(tonumber(COLORPICKER_BBox and COLORPICKER_BBox.Text) or 0, 0, 255)
		syncColorPickerFromColor(Color3.fromRGB(r, g, b))
		commitCurrentColor(true)
	else
		local h = clamp((tonumber(COLORPICKER_HBox and COLORPICKER_HBox.Text) or 0) / 360, 0, 1)
		local s = clamp((tonumber(COLORPICKER_SBox and COLORPICKER_SBox.Text) or 0) / 100, 0, 1)
		local v = clamp((tonumber(COLORPICKER_VBox and COLORPICKER_VBox.Text) or 0) / 100, 0, 1)
		colorPickerState.Hue = h
		colorPickerState.Sat = s
		colorPickerState.Val = v
		updateColorPickerVisuals()
		commitCurrentColor(true)
	end
end

for _, box in ipairs({COLORPICKER_RBox, COLORPICKER_GBox, COLORPICKER_BBox}) do
	if box then
		box.FocusLost:Connect(function()
			commitBoxesToColor("RGB")
		end)
	end
end

for _, box in ipairs({COLORPICKER_HBox, COLORPICKER_SBox, COLORPICKER_VBox}) do
	if box then
		box.FocusLost:Connect(function()
			commitBoxesToColor("HSV")
		end)
	end
end

function Amphibia.BindColorPicker(colorPickerButton, config)
	config = config or {}
	local binding = colorPickerBindings[colorPickerButton]
	if binding then
		return binding.API
	end

	local preview = colorPickerButton:FindFirstChild("ColorPreview")
	local startColor = config.Default or (preview and preview.BackgroundColor3) or Color3.new(1,1,1)
	binding = {
		Button = colorPickerButton,
		Value = startColor,
		Default = config.Default or startColor,
		Callback = config.Callback,
		History = {startColor},
		HistoryIndex = 1,
		API = nil
	}
	if preview then
		preview.BackgroundColor3 = startColor
	end
	addRowHover(colorPickerButton)
	colorPickerButton.MouseButton1Click:Connect(function()
		openColorPicker(binding)
	end)

	local api = {}
	function api:Set(color)
		binding.Value = color
		if preview then
			preview.BackgroundColor3 = color
		end
		pushColorHistory(binding, color)
		return api
	end
	function api:Get()
		return binding.Value
	end
	function api:SetCallback(callback)
		binding.Callback = callback
		return api
	end
	function api:Open()
		openColorPicker(binding)
		return api
	end
	binding.API = api
	colorPickerBindings[colorPickerButton] = binding
	return api
end

local sliderBindings = setmetatable({}, {__mode = "k"})
local keybindBindings = setmetatable({}, {__mode = "k"})
local toggleBindings = setmetatable({}, {__mode = "k"})
local textboxBindings = setmetatable({}, {__mode = "k"})

function Amphibia.BindButton(button, config)
	config = config or {}
	addRowHover(button)
	button.MouseButton1Click:Connect(function()
		if config.Callback then
			config.Callback(button)
		end
	end)
	return button
end

function Amphibia.BindToggle(toggleButton, config)
	config = config or {}
	if toggleBindings[toggleButton] then
		return toggleBindings[toggleButton]
	end
	addRowHover(toggleButton)
	local state = config.Default == true
	local active = toggleButton:FindFirstChild("ToggleFrame") and toggleButton.ToggleFrame:FindFirstChild("Active")
	local nameText = toggleButton:FindFirstChild("NameText")
	local function apply(instant)
		if active then
			if state then
				active.Visible = true
				active.Size = UDim2.fromOffset(14, 14)
				active.BackgroundTransparency = 0
				if not instant then
					tween(active, DEFAULT_TWEEN, {Size = UDim2.fromOffset(14, 14), BackgroundTransparency = 0})
				end
			else
				if instant then
					active.Visible = false
					active.Size = UDim2.fromOffset(0, 0)
					active.BackgroundTransparency = 1
				else
					local hideTween = tween(active, DEFAULT_TWEEN, {Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1})
					if hideTween then
						hideTween.Completed:Connect(function()
							if not state then
								active.Visible = false
							end
						end)
					end
				end
			end
		end
		if nameText then
			local target = state and Color3.fromRGB(153,70,255) or Color3.fromRGB(255,255,255)
			if instant then
				nameText.TextColor3 = target
			else
				tween(nameText, DEFAULT_TWEEN, {TextColor3 = target})
			end
		end
	end
	apply(true)
	local api = {}
	function api:Set(value)
		state = value == true
		apply(false)
		if config.Callback then
			config.Callback(state)
		end
		return api
	end
	function api:Get()
		return state
	end
	toggleButton.MouseButton1Click:Connect(function()
		api:Set(not state)
	end)
	toggleBindings[toggleButton] = api
	return api
end

function Amphibia.BindTextbox(textboxButton, config)
	config = config or {}
	if textboxBindings[textboxButton] then
		return textboxBindings[textboxButton]
	end
	addRowHover(textboxButton)
	local box = textboxButton:FindFirstChildOfClass("TextBox")
	if not box then
		return nil
	end
	local defaultColor = box.BackgroundColor3
	box.Focused:Connect(function()
		tween(box, DEFAULT_TWEEN, {BackgroundColor3 = darkenColor3(defaultColor, 0.85)})
	end)
	box.FocusLost:Connect(function(enterPressed)
		tween(box, DEFAULT_TWEEN, {BackgroundColor3 = defaultColor})
		if config.Callback then
			config.Callback(box.Text, enterPressed)
		end
	end)
	local api = {}
	function api:Set(text)
		box.Text = tostring(text)
		return api
	end
	function api:Get()
		return box.Text
	end
	textboxBindings[textboxButton] = api
	return api
end

function Amphibia.BindSlider(sliderButton, config)
	config = config or {}
	if sliderBindings[sliderButton] then
		return sliderBindings[sliderButton]
	end
	addRowHover(sliderButton)
	sliderButton.Interactable = true
	local min = tonumber(config.Min) or 0
	local max = tonumber(config.Max) or 100
	local step = tonumber(config.Step) or 1
	local decimals = tonumber(config.Decimals) or 0
	local callback = config.Callback
	local line = sliderButton:FindFirstChild("SliderLine")
	local knob = line and line:FindFirstChild("SliderKnob")
	local fill = line and line:FindFirstChild("SliderFill")
	local valueFrame = sliderButton:FindFirstChild("SliderValueFrame")
	local valueBox = valueFrame and valueFrame:FindFirstChildOfClass("TextBox")
	local value = tonumber(config.Default)
	if value == nil then
		value = min
	end
	value = clamp(value, min, max)
	local dragging = false

	local function apply(newValue, fromCallback)
		newValue = clamp(roundToStep(newValue, step), min, max)
		value = newValue
		local alpha = (value - min) / math.max(max - min, 0.0001)
		if knob then
			tween(knob, DEFAULT_TWEEN, {Position = UDim2.new(alpha, 0, 0.5, 0)})
		end
		if fill then
			tween(fill, DEFAULT_TWEEN, {Size = UDim2.new(alpha, 0, 1, 0)})
		end
		if valueBox then
			valueBox.Text = formatNumber(value, decimals)
		end
		if fromCallback and callback then
			callback(value)
		end
	end

	local function valueFromMouse(mousePos)
		if not line then
			return value
		end
		local alpha = clamp((mousePos.X - line.AbsolutePosition.X) / line.AbsoluteSize.X, 0, 1)
		return min + (max - min) * alpha
	end

	apply(value, false)

	if line then
		line.Active = true
		line.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end
			dragging = true
			apply(valueFromMouse(getMousePosition()), true)
		end)
	end

	UIS.InputChanged:Connect(function(input)
		if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		apply(valueFromMouse(getMousePosition()), true)
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	if valueBox then
		valueBox.Focused:Connect(function()
			if valueFrame then
				tween(valueFrame, DEFAULT_TWEEN, {BackgroundColor3 = darkenColor3(Color3.fromRGB(104,104,104), 0.9)})
			end
		end)
		valueBox.FocusLost:Connect(function()
			if valueFrame then
				tween(valueFrame, DEFAULT_TWEEN, {BackgroundColor3 = Color3.fromRGB(104,104,104)})
			end
			local entered = tonumber(valueBox.Text)
			if entered then
				apply(entered, true)
			else
				apply(value, false)
			end
		end)
	end

	local api = {}
	function api:Set(newValue)
		apply(newValue, true)
		return api
	end
	function api:Get()
		return value
	end
	sliderBindings[sliderButton] = api
	return api
end

local function normalizeKeyName(keyCode)
	local text = keyCode.Name or "Unknown"
	text = text:gsub("Left", "L")
	text = text:gsub("Right", "R")
	text = text:gsub("Control", "Ctrl")
	return text
end

function Amphibia.BindKeybind(keybindButton, config)
	config = config or {}
	if keybindBindings[keybindButton] then
		return keybindBindings[keybindButton]
	end
	addRowHover(keybindButton)
	keybindButton.Interactable = true
	local listening = false
	local keyLabel = keybindButton:FindFirstChild("KeybindFrame") and keybindButton.KeybindFrame:FindFirstChild("KeybindText")
	local boundKey = config.Default or (keyLabel and keyLabel.Text ~= "" and Enum.KeyCode[keyLabel.Text]) or Enum.KeyCode.Unknown

	local function refresh()
		if keyLabel then
			if listening then
				keyLabel.Text = "..."
			else
				keyLabel.Text = (boundKey and boundKey ~= Enum.KeyCode.Unknown) and normalizeKeyName(boundKey) or "-"
			end
		end
	end
	refresh()

	keybindButton.MouseButton1Click:Connect(function()
		listening = true
		refresh()
	end)

	UIS.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		if listening then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
					boundKey = Enum.KeyCode.Unknown
				else
					boundKey = input.KeyCode
				end
				listening = false
				refresh()
				if config.OnChanged then
					config.OnChanged(boundKey)
				end
			end
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard and boundKey and boundKey ~= Enum.KeyCode.Unknown and input.KeyCode == boundKey then
			if config.Callback then
				config.Callback(boundKey)
			end
		end
	end)

	local api = {}
	function api:Set(keyCode)
		boundKey = keyCode or Enum.KeyCode.Unknown
		refresh()
		return api
	end
	function api:Get()
		return boundKey
	end
	keybindBindings[keybindButton] = api
	return api
end

local tabData = {}
local currentTabButton = nil
local currentTabContent = nil

local function collectTabPairs()
	table.clear(tabData)
	for _, object in ipairs(TABS_TabsBg:GetDescendants()) do
		if object:IsA("TextButton") then
			local scrolling = MAIN_TabsContentFolder:FindFirstChild(object.Name .. "TabContent")
			if scrolling then
				table.insert(tabData, {Button = object, Content = scrolling})
			end
		end
	end
end

collectTabPairs()

local function applyTabVisual(info, selected, hovering)
	if not info or not info.Button then
		return
	end
	local targetColor = selected and Color3.fromRGB(180, 110, 255) or (hovering and Color3.fromRGB(178, 178, 178) or Color3.fromRGB(255,255,255))
	tween(info.Button, DEFAULT_TWEEN, {TextColor3 = targetColor})
	info.Button:SetAttribute("Selected", selected)
end

for _, info in ipairs(tabData) do
	addRowHover(info.Button)
	applyTabVisual(info, false, false)
	info.Button.MouseEnter:Connect(function()
		if info.Button:GetAttribute("Selected") then
			return
		end
		applyTabVisual(info, false, true)
	end)
	info.Button.MouseLeave:Connect(function()
		applyTabVisual(info, info.Button:GetAttribute("Selected") == true, false)
	end)
end

local function setTab(tabButton)
	for _, info in ipairs(tabData) do
		local selected = info.Button == tabButton
		info.Content.Visible = selected
		if selected then
			info.Content.Position = UDim2.new(0.241, 6, 0.101, 0)
			tween(info.Content, OPEN_TWEEN, {Position = UDim2.new(0.241, 0, 0.101, 0)})
			currentTabButton = info.Button
			currentTabContent = info.Content
		end
		applyTabVisual(info, selected, false)
	end
end

for _, info in ipairs(tabData) do
	info.Button.MouseButton1Click:Connect(function()
		setTab(info.Button)
	end)
end

if not currentTabButton and #tabData > 0 then
	setTab(tabData[1].Button)
end

local function gatherSections(scrolling)
	local sections = {}
	for _, columnName in ipairs({"LeftColumn", "RightColumn"}) do
		local column = scrolling:FindFirstChild(columnName)
		if column then
			for _, child in ipairs(column:GetChildren()) do
				if child:IsA("Frame") and child:FindFirstChild("ButtonHolderFrame") and child:FindFirstChild("Header") then
					table.insert(sections, child)
				end
			end
		end
	end
	return sections
end

local function searchInTab(scrolling, query)
	local sections = gatherSections(scrolling)
	local tabHasResults = false
	for _, sectionFrame in ipairs(sections) do
		local header = sectionFrame.Header
		local sectionNameText = header and header:FindFirstChild("SectionName")
		local sectionName = sectionNameText and string.lower(sectionNameText.Text) or string.lower(sectionFrame.Name)
		local controls = sectionFrame:FindFirstChild("ButtonHolderFrame")
		local anyControlVisible = false
		if controls then
			for _, child in ipairs(controls:GetChildren()) do
				if child:IsA("TextButton") or child:IsA("ImageButton") or child:IsA("Frame") then
					local controlNameLabel = child:FindFirstChild("NameText")
					if controlNameLabel and controlNameLabel:IsA("TextLabel") then
						local text = string.lower(controlNameLabel.Text)
						local visible = (query == "") or text:find(query, 1, true) ~= nil or sectionName:find(query, 1, true) ~= nil
						child.Visible = visible
						anyControlVisible = anyControlVisible or visible
					end
				end
			end
		end
		local sectionVisible = (query == "") or anyControlVisible or sectionName:find(query, 1, true) ~= nil
		sectionFrame.Visible = sectionVisible
		tabHasResults = tabHasResults or sectionVisible
	end
	return tabHasResults
end

MAIN_SearchFrameTextBox.Focused:Connect(function()
	tween(MAIN_SearchFrame, DEFAULT_TWEEN, {BackgroundColor3 = Color3.fromRGB(35,35,35)})
	tween(MAIN_SearchFrameSearchImage, DEFAULT_TWEEN, {ImageTransparency = 0.32})
end)

MAIN_SearchFrameTextBox.FocusLost:Connect(function()
	tween(MAIN_SearchFrame, DEFAULT_TWEEN, {BackgroundColor3 = Color3.fromRGB(255,255,255)})
	tween(MAIN_SearchFrameSearchImage, DEFAULT_TWEEN, {ImageTransparency = 0.6})
end)

MAIN_SearchFrameTextBox:GetPropertyChangedSignal("Text"):Connect(function()
	local query = string.lower(MAIN_SearchFrameTextBox.Text)
	local firstMatchButton = nil
	for _, info in ipairs(tabData) do
		local hasResults = searchInTab(info.Content, query)
		info.Button.TextTransparency = hasResults and 0 or 0.55
		if not info.Button:GetAttribute("Selected") then
			applyTabVisual(info, false, false)
		end
		if not firstMatchButton and hasResults then
			firstMatchButton = info.Button
		end
	end
	if query ~= "" and currentTabContent and not searchInTab(currentTabContent, query) and firstMatchButton then
		setTab(firstMatchButton)
	end
	if query == "" and currentTabButton then
		setTab(currentTabButton)
	end
end)

MAIN_SettingsButton.MouseButton1Click:Connect(function()
	if Amphibia.Notify then
		Amphibia.Notify({
			Title = "Settings",
			Description = "This button is ready for your own settings window or actions.",
			Duration = 3.2
		})
	end
end)

NOTIFICATIONS_MainFrame.Visible = false
NOTIFICATIONS_MainFrame.Parent = NotificationsGui
NOTIFICATIONS_MainFrame.AnchorPoint = Vector2.zero
NOTIFICATIONS_MainFrame.Position = UDim2.fromOffset(-1000, -1000)

local notificationScaleCache = setmetatable({}, {__mode = "k"})
local notifications = {}
local notificationRenderHookCreated = false

local function createNotificationRenderLoop()
	if notificationRenderHookCreated then
		return
	end
	notificationRenderHookCreated = true
	RunService.RenderStepped:Connect(function(dt)
		for _, entry in ipairs(notifications) do
			if entry.Frame and entry.Frame.Parent then
				if not entry.Dragging and not entry.ManualPosition then
					local current = entry.Frame.Position
					local target = entry.Target
					entry.Frame.Position = UDim2.fromOffset(
						current.X.Offset + (target.X - current.X.Offset) * math.clamp(dt * 16, 0, 1),
						current.Y.Offset + (target.Y - current.Y.Offset) * math.clamp(dt * 16, 0, 1)
					)
				end

				if not entry.Frozen and not entry.Closing then
					local now = tick()
					entry.Remaining = math.max(0, entry.EndTime - now)
					local progress = entry.Duration > 0 and (entry.Remaining / entry.Duration) or 0
					local timeline = entry.Frame:FindFirstChild("TimeLine")
					if timeline then
						timeline.Size = UDim2.fromOffset(math.floor(entry.Frame.AbsoluteSize.X * progress), 2)
					end
					local timeLeft = entry.Frame:FindFirstChild("TimeLeft")
					if timeLeft then
						timeLeft.Text = tostring(math.max(0, math.ceil(entry.Remaining))) .. "s"
					end
					if entry.Remaining <= 0 then
						entry:Close()
					end
				end
			end
		end
	end)
end

local function refreshNotificationTargets()
	local viewport = getViewportSize()
	local paddingRight = 20
	local paddingBottom = 20
	local gap = 10
	local used = 0
	for _, entry in ipairs(notifications) do
		if entry.Frame and entry.Frame.Parent and not entry.ManualPosition then
			local height = entry.Frame.AbsoluteSize.Y > 0 and entry.Frame.AbsoluteSize.Y or entry.Frame.Size.Y.Offset
			local width = entry.Frame.AbsoluteSize.X > 0 and entry.Frame.AbsoluteSize.X or entry.Frame.Size.X.Offset
			entry.Target = Vector2.new(viewport.X - width - paddingRight, viewport.Y - paddingBottom - height - used)
			used += height + gap
		end
	end
end

local function removeNotification(entry)
	for i, v in ipairs(notifications) do
		if v == entry then
			table.remove(notifications, i)
			break
		end
	end
	if entry.Frame then
		entry.Frame:Destroy()
	end
	refreshNotificationTargets()
end

function Amphibia.Notify(config)
	config = config or {}
	createNotificationRenderLoop()

	local frame = NOTIFICATIONS_MainFrame:Clone()
	frame.Visible = true
	frame.Parent = NotificationsGui
	frame.Name = GenerateRandomName(8)
	frame.Position = UDim2.fromOffset(getViewportSize().X + 30, getViewportSize().Y - frame.Size.Y.Offset - 20)

	local title = frame:FindFirstChild("NotificationName")
	local desc = frame:FindFirstChild("NotificationDescription")
	local timeLeft = frame:FindFirstChild("TimeLeft")
	local freezeButton = frame:FindFirstChild("FreezeButton")
	local freezeIcon = freezeButton and freezeButton:FindFirstChild("FreezeButtonIcon")
	local closeButton = frame:FindFirstChild("CloseButton")
	local dragLine = frame:FindFirstChild("DragLine")
	local timelineGlow = frame:FindFirstChild("TimeLineGlow")

	if title then
		title.Text = tostring(config.Title or "Notification")
	end
	if desc then
		desc.Text = tostring(config.Description or "")
		desc.TextWrapped = true
		desc.TextYAlignment = Enum.TextYAlignment.Top
		local bounds = TextService:GetTextSize(desc.Text, desc.TextSize, desc.Font, Vector2.new(182, 1000))
		desc.Size = UDim2.fromOffset(182, math.max(37, bounds.Y + 2))
		local targetHeight = math.max(65, 30 + desc.Size.Y.Offset + 14)
		frame.Size = UDim2.fromOffset(253, targetHeight)
		local dragLineRef = frame:FindFirstChild("DragLine")
		if dragLineRef then
			dragLineRef.Size = UDim2.fromOffset(5, math.max(43, targetHeight - 22))
		end
		local timeline = frame:FindFirstChild("TimeLine")
		if timeline then
			timeline.Position = UDim2.fromOffset(0, targetHeight - 2)
			timeline.Size = UDim2.fromOffset(253, 2)
		end
		local timelineGlowRef = frame:FindFirstChild("TimeLineGlow")
		if timelineGlowRef then
			timelineGlowRef.Position = UDim2.fromOffset(0, targetHeight - 18)
			timelineGlowRef.Size = UDim2.fromOffset(253, 17)
		end
		if timeLeft then
			timeLeft.Position = UDim2.fromOffset(211, math.max(40, targetHeight - 22))
		end
	end
	if timeLeft then
		timeLeft.Text = tostring(math.ceil(config.Duration or 3.5)) .. "s"
	end
	if freezeButton then
		freezeButton.ImageTransparency = 1
	end
	if freezeIcon then
		freezeIcon.ImageTransparency = 0.84
	end
	if timelineGlow then
		timelineGlow.BackgroundTransparency = 0.02
	end
	animateIconButton(closeButton, 0.84, 0.58)
	if freezeIcon then
		freezeButton.MouseEnter:Connect(function()
			tween(freezeIcon, DEFAULT_TWEEN, {ImageTransparency = 0.56})
		end)
		freezeButton.MouseLeave:Connect(function()
			if not frame:GetAttribute("Frozen") then
				tween(freezeIcon, DEFAULT_TWEEN, {ImageTransparency = 0.84})
			end
		end)
	end

	local entry = {
		Frame = frame,
		Duration = tonumber(config.Duration) or 3.5,
		EndTime = tick() + (tonumber(config.Duration) or 3.5),
		Remaining = tonumber(config.Duration) or 3.5,
		Frozen = false,
		Dragging = false,
		ManualPosition = false,
		Target = Vector2.new(0, 0),
		DragOffset = Vector2.zero,
		Closing = false,
	}

	function entry:Close()
		if self.Closing then
			return
		end
		self.Closing = true
		local scale = notificationScaleCache[frame]
		if scale then
			tween(scale, CLOSE_TWEEN, {Scale = 0.97})
		end
		fadeGuiObjectTree(frame, CLOSE_TWEEN)
		tween(frame, CLOSE_TWEEN, {BackgroundTransparency = 1})
		task.delay(0.22, function()
			removeNotification(self)
		end)
	end

	table.insert(notifications, entry)
	refreshNotificationTargets()
	local scale = createScale(frame, 0.97)
	notificationScaleCache[frame] = scale
	tween(scale, OPEN_TWEEN, {Scale = 1})

	closeButton.MouseButton1Click:Connect(function()
		entry:Close()
	end)
	freezeButton.MouseButton1Click:Connect(function()
		entry.Frozen = not entry.Frozen
		frame:SetAttribute("Frozen", entry.Frozen)
		if entry.Frozen then
			entry.StoredRemaining = entry.Remaining
			if freezeIcon then
				tween(freezeIcon, DEFAULT_TWEEN, {ImageTransparency = 0.2})
			end
			if timelineGlow then
				tween(timelineGlow, DEFAULT_TWEEN, {BackgroundTransparency = 0.3})
			end
		else
			entry.EndTime = tick() + (entry.StoredRemaining or entry.Remaining)
			if freezeIcon then
				tween(freezeIcon, DEFAULT_TWEEN, {ImageTransparency = 0.84})
			end
			if timelineGlow then
				tween(timelineGlow, DEFAULT_TWEEN, {BackgroundTransparency = 0.02})
			end
		end
	end)

	if dragLine then
		dragLine.Active = true
		dragLine.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end
			entry.Dragging = true
			entry.ManualPosition = true
			entry.DragOffset = (getMousePosition()) - frame.AbsolutePosition
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					entry.Dragging = false
				end
			end)
		end)
	end

	UIS.InputChanged:Connect(function(input)
		if entry.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local mousePos = getMousePosition()
			frame.Position = UDim2.fromOffset(mousePos.X - entry.DragOffset.X, mousePos.Y - entry.DragOffset.Y)
		end
	end)

	return entry
end

local function tryBindControl(control)
	if control == button then
		Amphibia.BindButton(control, {})
	elseif control == toggle then
		Amphibia.BindToggle(control, {})
	elseif control == textbox then
		Amphibia.BindTextbox(control, {})
	elseif control == slider then
		Amphibia.BindSlider(control, {Min = 0, Max = 100, Step = 1, Default = 0})
	elseif control == keybind then
		Amphibia.BindKeybind(control, {})
	elseif control == colorPicker then
		Amphibia.BindColorPicker(control, {Default = control.ColorPreview.BackgroundColor3})
	elseif control == dropdown then
		Amphibia.BindDropdown(control, {Title = "dropdown"})
	end
end

for _, control in ipairs({button, dropdown, toggle, colorPicker, textbox, slider, keybind}) do
	tryBindControl(control)
end

function Amphibia.Boot()
	return Amphibia
end

	return Amphibia
end

return createAmphibia()
