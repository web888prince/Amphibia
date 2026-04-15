local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

local Player = Players.LocalPlayer
local PlayerGui = Player and Player:FindFirstChildOfClass("PlayerGui")

local DEFAULT_ACCENT_A = Color3.fromRGB(150, 64, 255)
local DEFAULT_ACCENT_B = Color3.fromRGB(238, 48, 255)
local DEFAULT_HEADER_ACCENT_B = Color3.fromRGB(137, 98, 255)

local function safeCoreParent()
    local ok, core = pcall(function()
        return CoreGui
    end)

    if ok and core then
        return core
    end

    if PlayerGui then
        return PlayerGui
    end

    return game:GetService("StarterGui")
end

local Default_Parent = safeCoreParent()

local _scriptName = "Amphibia'"
local _scriptIcon = "rbxassetid://76305975133668"

local _settingsImageId = "rbxassetid://9405931578"
local _searchImageId = "rbxassetid://75273157378006"
local _closeImageId = "rbxassetid://130334254289066"
local _moveImageId = "rbxassetid://87351486351798"
local _randomImageId = "rbxassetid://82824171769924"
local _resetImageId = "rbxassetid://438217404"
local _freezeImageId = "rbxassetid://13200344988"
local _tripleDotImageId = "rbxassetid://127075876244307"

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
	keybindButton.Interactable = true

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

local function buildRootGuis(parent)
    local MainGui = Instance.new("ScreenGui")
    MainGui.Parent = parent
    MainGui.Enabled = true
    MainGui.IgnoreGuiInset = true
    MainGui.ResetOnSpawn = false
    MainGui.DisplayOrder = 0
    MainGui.Name = GenerateRandomName(10)

    local ColorPickerGui = Instance.new("ScreenGui")
    ColorPickerGui.Parent = parent
    ColorPickerGui.Enabled = false
    ColorPickerGui.IgnoreGuiInset = true
    ColorPickerGui.ResetOnSpawn = false
    ColorPickerGui.DisplayOrder = 5
    ColorPickerGui.Name = "ColorPickerGui"

    local NotificationsGui = Instance.new("ScreenGui")
    NotificationsGui.Parent = parent
    NotificationsGui.Enabled = true
    NotificationsGui.IgnoreGuiInset = true
    NotificationsGui.ResetOnSpawn = false
    NotificationsGui.DisplayOrder = 100
    NotificationsGui.Name = "NotificationsGui"

    local PopupGui = Instance.new("ScreenGui")
    PopupGui.Parent = parent
    PopupGui.Enabled = true
    PopupGui.IgnoreGuiInset = true
    PopupGui.ResetOnSpawn = false
    PopupGui.DisplayOrder = 50
    PopupGui.Name = "PopupGui"

    return {
        MainGui = MainGui,
        ColorPickerGui = ColorPickerGui,
        NotificationsGui = NotificationsGui,
        PopupGui = PopupGui,
    }
end

local function buildMainWindow(MainGui)
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

    ---------------------------------------------------------------------------------------------------
    --                                                                                         TABS  --
    ---------------------------------------------------------------------------------------------------

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

    ---------------------------------------------------------------------------------------------------
    --                                                                                 COLOR PICKER  --

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
        MAIN_ScriptName = MAIN_ScriptName,
        MAIN_ScriptImage = MAIN_ScriptImage,
        TABS_TabsBg = TABS_TabsBg,
    }
end

local function buildColorPickerWindow(ColorPickerGui)
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

    return {
        COLORPICKER_MainFrame = COLORPICKER_MainFrame,
        COLORPICKER_MainFrameLastColorFolder = COLORPICKER_MainFrameLastColorFolder,
        COLORPICKER_ColorPickerMainFrame = COLORPICKER_ColorPickerMainFrame,
        COLORPICKER_ColorPickerMainFrameDot = COLORPICKER_ColorPickerMainFrameDot,
        COLORPICKER_LastColorLastColor1 = COLORPICKER_LastColorLastColor1,
        COLORPICKER_LastColorLastColor2 = COLORPICKER_LastColorLastColor2,
        COLORPICKER_LastColorLastColor3 = COLORPICKER_LastColorLastColor3,
        COLORPICKER_LastColorLastColor4 = COLORPICKER_LastColorLastColor4,
        COLORPICKER_LastColorLastColor5 = COLORPICKER_LastColorLastColor5,
        COLORPICKER_CurrentColorFrame = COLORPICKER_CurrentColorFrame,
        COLORPICKER_ColorSelectorFrame = COLORPICKER_ColorSelectorFrame,
        COLORPICKER_ColorSelectorFrameSelectLine = COLORPICKER_ColorSelectorFrameSelectLine,
        COLORPICKER_HeaderBgFrame = COLORPICKER_HeaderBgFrame,
        COLORPICKER_CloseButton = COLORPICKER_CloseButton,
        COLORPICKER_RandomColor = COLORPICKER_RandomColor,
        COLORPICKER_ResetToDefault = COLORPICKER_ResetToDefault,
        COLORPICKER_WindowDesc = COLORPICKER_WindowDesc,
        COLORPICKER_WindowName = COLORPICKER_WindowName,
        COLORPCIKER_OtherText = COLORPCIKER_OtherText,
    }
end

local function buildNotificationTemplate(NotificationsGui)
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

    local NOTIFICATIONS_TimeLeft = Instance.new("TextLabel")
    NOTIFICATIONS_TimeLeft.Parent = NOTIFICATIONS_MainFrame
    NOTIFICATIONS_TimeLeft.Name = "TimeLeft"
    NOTIFICATIONS_TimeLeft.BackgroundTransparency = 1
    NOTIFICATIONS_TimeLeft.Position = UDim2.new(0.834,0,0.646,0)
    NOTIFICATIONS_TimeLeft.Size = UDim2.new(0,35,0,23)
    NOTIFICATIONS_TimeLeft.ZIndex = 1
    NOTIFICATIONS_TimeLeft.Text = "nilS"
    NOTIFICATIONS_TimeLeft.TextColor3 = Color3.fromRGB(63,63,63)
    NOTIFICATIONS_TimeLeft.TextSize = 13
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
    local button = createButton("button", section)
    local dropdown = createDropdown("dropdown", section, -1)
    local toggle = createToggle("toggle", section)
    local colorPicker = createColorPicker("color picker", section)

    NOTIFICATIONS_MainFrame.Visible = false

    return {
        NOTIFICATIONS_MainFrame = NOTIFICATIONS_MainFrame,
        NOTIFICATIONS_DragLine = NOTIFICATIONS_DragLine,
        NOTIFICATIONS_TimeLine = NOTIFICATIONS_TimeLine,
        NOTIFICATIONS_TimeLineGlow = NOTIFICATIONS_TimeLineGlow,
        NOTIFICATIONS_CloseButton = NOTIFICATIONS_CloseButton,
        NOTIFICATIONS_FreezeButton = NOTIFICATIONS_FreezeButton,
        NOTIFICATIONS_FreezeButtonIcon = NOTIFICATIONS_FreezeButtonIcon,
        NOTIFICATIONS_TimeLeft = NOTIFICATIONS_TimeLeft,
        NOTIFICATIONS_NotificationName = NOTIFICATIONS_NotificationName,
        NOTIFICATIONS_NotificationDescription = NOTIFICATIONS_NotificationDescription,
    }
end

local function tween(object, info, props)
    if not object then
        return nil
    end

    local tw = TweenService:Create(object, info, props)
    tw:Play()
    return tw
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function roundToStep(value, step)
    step = tonumber(step) or 1
    if step == 0 then
        return value
    end

    return math.floor((value / step) + 0.5) * step
end

local function clamp(v, a, b)
    return math.max(a, math.min(b, v))
end

local function createGradientAnimationList()
    return {
        items = {},
        connection = nil,
    }
end

local function addAnimatedGradient(store, gradient, speed)
    if not gradient then
        return
    end

    table.insert(store.items, {
        gradient = gradient,
        speed = speed or 0.35,
        offset = 0,
    })

    if store.connection then
        return
    end

    store.connection = RunService.RenderStepped:Connect(function(dt)
        for _, item in ipairs(store.items) do
            if item.gradient.Parent then
                item.offset = (item.offset + (dt * item.speed)) % 2
                item.gradient.Offset = Vector2.new(item.offset - 1, 0)
            end
        end
    end)
end

local function makeAccentSequence(a, b)
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, a),
        ColorSequenceKeypoint.new(1, b),
    })
end

local function safeDisconnect(connection)
    if connection then
        connection:Disconnect()
    end
end

local function setObjectTransparency(object, alpha)
    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
        object.TextTransparency = alpha
        local ok = pcall(function()
            object.TextStrokeTransparency = math.max(alpha, object.TextStrokeTransparency)
        end)
        return ok
    end

    if object:IsA("ImageLabel") or object:IsA("ImageButton") then
        object.ImageTransparency = alpha
        return
    end

    if object:IsA("Frame") then
        object.BackgroundTransparency = alpha
        return
    end

    if object:IsA("UIStroke") then
        object.Transparency = alpha
        return
    end
end

local function fadeTree(root, alpha, duration)
    local info = TweenInfo.new(duration or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    for _, object in ipairs(root:GetDescendants()) do
        if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
            tween(object, info, {
                TextTransparency = alpha,
            })

            pcall(function()
                tween(object, info, {
                    TextStrokeTransparency = math.max(alpha, object.TextStrokeTransparency)
                })
            end)
        elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
            tween(object, info, {
                ImageTransparency = alpha,
            })
        elseif object:IsA("Frame") then
            tween(object, info, {
                BackgroundTransparency = alpha,
            })
        elseif object:IsA("UIStroke") then
            tween(object, info, {
                Transparency = alpha,
            })
        end
    end
end

local function createInvisibleDragHandle(parent, size, position, zIndex)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.BackgroundTransparency = 1
    button.Text = ""
    button.AutoButtonColor = false
    button.Size = size
    button.Position = position
    button.ZIndex = zIndex or 999
    button.Name = "DragHitbox"
    return button
end

local function absoluteAnchorPosition(frame)
    return Vector2.new(
        frame.AbsolutePosition.X + (frame.AbsoluteSize.X * frame.AnchorPoint.X),
        frame.AbsolutePosition.Y + (frame.AbsoluteSize.Y * frame.AnchorPoint.Y)
    )
end

local function enableSmoothDrag(frame, handle)
    local state = {
        dragging = false,
        target = absoluteAnchorPosition(frame),
        offset = Vector2.zero,
    }

    local rsConnection
    rsConnection = RunService.RenderStepped:Connect(function()
        if not frame.Parent then
            if rsConnection then
                rsConnection:Disconnect()
            end
            return
        end

        local anchor = absoluteAnchorPosition(frame)
        local nx = lerp(anchor.X, state.target.X, 0.18)
        local ny = lerp(anchor.Y, state.target.Y, 0.18)
        frame.Position = UDim2.new(0, nx, 0, ny)
    end)

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state.dragging = true
            local mouse = UserInputService:GetMouseLocation()
            state.offset = mouse - absoluteAnchorPosition(frame)

            local endConnection
            endConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    state.dragging = false
                    safeDisconnect(endConnection)
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not state.dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = UserInputService:GetMouseLocation()
            state.target = mouse - state.offset
        end
    end)

    return state
end

local function createTextGradient(label, colors, animatedStore)
    local gradient = label:FindFirstChild("AnimatedTextGradient")
    if not gradient then
        gradient = Instance.new("UIGradient")
        gradient.Name = "AnimatedTextGradient"
        gradient.Parent = label
    end

    gradient.Color = colors
    gradient.Rotation = 0
    addAnimatedGradient(animatedStore, gradient, 0.28)
    return gradient
end

local function applyHoverBackground(button)
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    button.BackgroundTransparency = 1
    button.AutoButtonColor = false

    button.MouseEnter:Connect(function()
        tween(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.72,
        })
    end)

    button.MouseLeave:Connect(function()
        tween(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1,
        })
    end)
end

local function makePopupButton(text, width, height)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.BackgroundTransparency = 0.15
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Size = UDim2.fromOffset(width, height)

    local corner = Instance.new("UICorner")
    corner.Parent = btn
    corner.CornerRadius = UDim.new(0, 4)

    local stroke1 = Instance.new("UIStroke")
    stroke1.Parent = btn
    stroke1.Color = Color3.fromRGB(45, 45, 45)
    stroke1.Thickness = 2

    local stroke2 = Instance.new("UIStroke")
    stroke2.Parent = btn
    stroke2.Color = Color3.fromRGB(0, 0, 0)
    stroke2.Thickness = 1
    stroke2.Transparency = 0.3

    local label = Instance.new("TextLabel")
    label.Parent = btn
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.RobotoMono
    label.Text = text
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 255, 255)

    return btn, label
end

local function scoreSearch(text, query)
    local source = string.lower(text or "")
    local q = string.lower(query or "")

    if q == "" then
        return 0
    end

    local score = 0

    if source == q then
        score += 1000
    end

    if string.find(source, q, 1, true) then
        score += 250
    end

    for token in string.gmatch(q, "%S+") do
        if string.find(source, token, 1, true) then
            score += 100
            if string.sub(source, 1, #token) == token then
                score += 50
            end
        end
    end

    return score
end

local function textSizeY(text, size, width)
    local bounds = TextService:GetTextSize(text, size, Enum.Font.RobotoMono, Vector2.new(width, 1000))
    return bounds.Y
end

local function buildConfirmDialog(parent, animatedStore)
    local overlay = Instance.new("TextButton")
    overlay.Parent = parent
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.45
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.Text = ""
    overlay.AutoButtonColor = false
    overlay.Visible = false
    overlay.ZIndex = 300

    local frame = Instance.new("Frame")
    frame.Parent = overlay
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.Size = UDim2.fromOffset(285, 132)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.ZIndex = 301

    local corner = Instance.new("UICorner")
    corner.Parent = frame
    corner.CornerRadius = UDim.new(0, 4)

    local gradient = Instance.new("UIGradient")
    gradient.Parent = frame
    gradient.Rotation = -90
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
    })

    local stroke1 = Instance.new("UIStroke")
    stroke1.Parent = frame
    stroke1.Color = Color3.fromRGB(48, 48, 48)
    stroke1.Thickness = 2

    local stroke2 = Instance.new("UIStroke")
    stroke2.Parent = frame
    stroke2.Color = DEFAULT_ACCENT_A
    stroke2.Thickness = 1
    stroke2.Transparency = 0.1

    local title = Instance.new("TextLabel")
    title.Parent = frame
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(12, 10)
    title.Size = UDim2.fromOffset(260, 24)
    title.Font = Enum.Font.RobotoMono
    title.Text = "Close menu?"
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 17
    title.ZIndex = 302

    local subtitle = Instance.new("TextLabel")
    subtitle.Parent = frame
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.fromOffset(12, 38)
    subtitle.Size = UDim2.fromOffset(260, 34)
    subtitle.Font = Enum.Font.RobotoMono
    subtitle.Text = "Are you sure you want to close the menu?"
    subtitle.TextWrapped = true
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextYAlignment = Enum.TextYAlignment.Top
    subtitle.TextColor3 = Color3.fromRGB(175, 175, 175)
    subtitle.TextSize = 13
    subtitle.ZIndex = 302

    local yesButton, yesLabel = makePopupButton("Yes", 120, 28)
    yesButton.Parent = frame
    yesButton.Position = UDim2.fromOffset(12, 90)
    yesButton.ZIndex = 302
    yesLabel.ZIndex = 303
    createTextGradient(yesLabel, makeAccentSequence(DEFAULT_ACCENT_A, DEFAULT_ACCENT_B), animatedStore)

    local cancelButton, cancelLabel = makePopupButton("Cancel", 120, 28)
    cancelButton.Parent = frame
    cancelButton.Position = UDim2.fromOffset(152, 90)
    cancelButton.ZIndex = 302
    cancelLabel.ZIndex = 303

    return {
        Overlay = overlay,
        Frame = frame,
        Title = title,
        Subtitle = subtitle,
        Yes = yesButton,
        Cancel = cancelButton,
    }
end

local Window = {}
Window.__index = Window
local Category = {}
Category.__index = Category
local Tab = {}
Tab.__index = Tab
local Section = {}
Section.__index = Section

function Window:_setAccentColors(a, b)
    self.AccentA = a or DEFAULT_ACCENT_A
    self.AccentB = b or DEFAULT_ACCENT_B
    self.AccentLineB = DEFAULT_HEADER_ACCENT_B

    local headerStroke = self.Refs.MAIN_HeaderBgFrame:FindFirstChildOfClass("UIStroke")
    if headerStroke then
        headerStroke.Color = self.AccentA
    end

    local headerGlow = self.Refs.MAIN_MainBgFrame:FindFirstChild("HeaderContent")
    if headerGlow and headerGlow:FindFirstChild("HeaderStrokeGlow") then
        headerGlow.HeaderStrokeGlow.BackgroundColor3 = self.AccentA
    end

    local tabsSplitter = self.Refs.MAIN_MainBgFrame:FindFirstChild("HeaderSplitter")
    if tabsSplitter then
        tabsSplitter.BackgroundColor3 = self.AccentA
    end
end

function Window:_selectTab(tab)
    if self.ActiveTab == tab then
        return
    end

    if self.SearchResults and self.SearchResults.Visible then
        self.SearchResults.Visible = false
    end

    for _, each in ipairs(self.Tabs) do
        each.Scrolling.Visible = false
        tween(each.Button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 0,
            BackgroundTransparency = 1,
        })
    end

    self.ActiveTab = tab
    tab.Scrolling.Visible = true
    tween(tab.Button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.72,
    })

    local gradient = tab.Button:FindFirstChild("ActiveTextGradient")
    if not gradient then
        gradient = Instance.new("UIGradient")
        gradient.Name = "ActiveTextGradient"
        gradient.Parent = tab.Button
    end
    gradient.Color = makeAccentSequence(self.AccentA, self.AccentB)
    addAnimatedGradient(self.AnimatedGradients, gradient, 0.25)
end

function Window:_flashControl(gui)
    if not gui then
        return
    end

    gui.BackgroundColor3 = self.AccentA
    tween(gui, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.35,
    })

    task.delay(0.25, function()
        if gui and gui.Parent then
            gui.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            tween(gui, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1,
            })
        end
    end)
end

function Window:_createSearchResults()
    local scrolling = Instance.new("ScrollingFrame")
    scrolling.Parent = self.Refs.MAIN_TabsContentFolder
    scrolling.Name = "SearchResults"
    scrolling.BackgroundTransparency = 1
    scrolling.Position = UDim2.new(0.241, 0, 0.101, 0)
    scrolling.Size = UDim2.new(0, 581, 0, 435)
    scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrolling.ScrollBarImageTransparency = 1
    scrolling.ScrollBarThickness = 0
    scrolling.Visible = false

    local holder = Instance.new("Frame")
    holder.Parent = scrolling
    holder.BackgroundTransparency = 1
    holder.Size = UDim2.new(1, 0, 0, 0)
    holder.AutomaticSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout")
    layout.Parent = holder
    layout.Padding = UDim.new(0, 10)

    local padding = Instance.new("UIPadding")
    padding.Parent = holder
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)

    self.SearchResults = scrolling
    self.SearchResultsHolder = holder
end

function Window:_renderSearch(query)
    if not self.SearchResults then
        self:_createSearchResults()
    end

    local holder = self.SearchResultsHolder
    for _, child in ipairs(holder:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end

    local results = {}
    for _, control in ipairs(self.SearchIndex) do
        local score = scoreSearch(control.SearchText, query)
        if score > 0 then
            table.insert(results, {
                Score = score,
                Control = control,
            })
        end
    end

    table.sort(results, function(a, b)
        if a.Score == b.Score then
            return a.Control.Name < b.Control.Name
        end
        return a.Score > b.Score
    end)

    local title = Instance.new("TextLabel")
    title.Parent = holder
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -6, 0, 18)
    title.Font = Enum.Font.RobotoMono
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextSize = 15
    title.Text = ("Search results: %d"):format(#results)

    if #results == 0 then
        local empty = Instance.new("TextLabel")
        empty.Parent = holder
        empty.BackgroundTransparency = 1
        empty.Size = UDim2.new(1, -6, 0, 18)
        empty.Font = Enum.Font.RobotoMono
        empty.TextColor3 = Color3.fromRGB(120, 120, 120)
        empty.TextXAlignment = Enum.TextXAlignment.Left
        empty.TextSize = 13
        empty.Text = "No matching controls"
    end

    for i = 1, math.min(#results, 40) do
        local item = results[i].Control

        local resultButton = Instance.new("TextButton")
        resultButton.Parent = holder
        resultButton.Size = UDim2.new(1, -6, 0, 44)
        resultButton.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        resultButton.BackgroundTransparency = 0
        resultButton.AutoButtonColor = false
        resultButton.Text = ""

        local corner = Instance.new("UICorner")
        corner.Parent = resultButton
        corner.CornerRadius = UDim.new(0, 4)

        local stroke = Instance.new("UIStroke")
        stroke.Parent = resultButton
        stroke.Color = Color3.fromRGB(42, 42, 42)
        stroke.Thickness = 1

        local name = Instance.new("TextLabel")
        name.Parent = resultButton
        name.BackgroundTransparency = 1
        name.Position = UDim2.fromOffset(8, 4)
        name.Size = UDim2.new(1, -16, 0, 18)
        name.Font = Enum.Font.RobotoMono
        name.Text = item.Name
        name.TextColor3 = Color3.fromRGB(255, 255, 255)
        name.TextSize = 14
        name.TextXAlignment = Enum.TextXAlignment.Left

        local path = Instance.new("TextLabel")
        path.Parent = resultButton
        path.BackgroundTransparency = 1
        path.Position = UDim2.fromOffset(8, 22)
        path.Size = UDim2.new(1, -16, 0, 16)
        path.Font = Enum.Font.RobotoMono
        path.Text = item.Path
        path.TextColor3 = Color3.fromRGB(130, 130, 130)
        path.TextSize = 12
        path.TextXAlignment = Enum.TextXAlignment.Left

        resultButton.MouseEnter:Connect(function()
            tween(resultButton, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.2,
            })
        end)

        resultButton.MouseLeave:Connect(function()
            tween(resultButton, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0,
            })
        end)

        resultButton.MouseButton1Click:Connect(function()
            self.Refs.MAIN_SearchFrameTextBox.Text = ""
            self.SearchResults.Visible = false
            self:_selectTab(item.Tab)
            self:_flashControl(item.Root)
        end)
    end
end

function Window:_registerSearchItem(control)
    table.insert(self.SearchIndex, control)
end

function Window:_bindSearch()
    self.Refs.MAIN_SearchFrameTextBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = self.Refs.MAIN_SearchFrameTextBox.Text
        if query == "" then
            if self.SearchResults then
                self.SearchResults.Visible = false
            end

            if self.ActiveTab then
                self.ActiveTab.Scrolling.Visible = true
            end
            return
        end

        for _, tab in ipairs(self.Tabs) do
            tab.Scrolling.Visible = false
        end

        self:_renderSearch(query)
        self.SearchResults.Visible = true
    end)
end

function Window:_buildPopup()
    local blocker = Instance.new("TextButton")
    blocker.Parent = self.Root.PopupGui
    blocker.BackgroundTransparency = 1
    blocker.Size = UDim2.fromScale(1, 1)
    blocker.Text = ""
    blocker.Visible = false
    blocker.ZIndex = 499

    local popup = Instance.new("Frame")
    popup.Parent = self.Root.PopupGui
    popup.Visible = false
    popup.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    popup.Size = UDim2.fromOffset(180, 40)
    popup.ZIndex = 500

    local corner = Instance.new("UICorner")
    corner.Parent = popup
    corner.CornerRadius = UDim.new(0, 4)

    local stroke1 = Instance.new("UIStroke")
    stroke1.Parent = popup
    stroke1.Color = Color3.fromRGB(45, 45, 45)
    stroke1.Thickness = 2

    local stroke2 = Instance.new("UIStroke")
    stroke2.Parent = popup
    stroke2.Color = Color3.fromRGB(0, 0, 0)
    stroke2.Thickness = 1
    stroke2.Transparency = 0.35

    local list = Instance.new("ScrollingFrame")
    list.Parent = popup
    list.BackgroundTransparency = 1
    list.Size = UDim2.fromScale(1, 1)
    list.CanvasSize = UDim2.new()
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.ScrollBarThickness = 0
    list.ScrollBarImageTransparency = 1
    list.ZIndex = 501

    local layout = Instance.new("UIListLayout")
    layout.Parent = list
    layout.Padding = UDim.new(0, 4)

    local padding = Instance.new("UIPadding")
    padding.Parent = list
    padding.PaddingLeft = UDim.new(0, 4)
    padding.PaddingRight = UDim.new(0, 4)
    padding.PaddingTop = UDim.new(0, 4)
    padding.PaddingBottom = UDim.new(0, 4)

    blocker.MouseButton1Click:Connect(function()
        popup.Visible = false
        blocker.Visible = false
    end)

    self.Popup = {
        Blocker = blocker,
        Root = popup,
        List = list,
    }
end

function Window:_openDropdown(control)
    if not self.Popup then
        self:_buildPopup()
    end

    local popup = self.Popup.Root
    local list = self.Popup.List

    for _, child in ipairs(list:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end

    local values = control.Values or {}
    local itemHeight = 28
    popup.Size = UDim2.fromOffset(math.max(170, control.Root.AbsoluteSize.X - 24), math.min(220, (#values * (itemHeight + 4)) + 8))
    popup.Visible = true
    self.Popup.Blocker.Visible = true

    task.defer(function()
        local mouse = UserInputService:GetMouseLocation()
        local x = mouse.X + 12
        local y = control.Root.AbsolutePosition.Y + 4
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        local popupWidth = popup.AbsoluteSize.X
        local popupHeight = popup.AbsoluteSize.Y

        if x + popupWidth > viewport.X - 8 then
            x = viewport.X - popupWidth - 8
        end

        if y + popupHeight > viewport.Y - 8 then
            y = viewport.Y - popupHeight - 8
        end

        popup.Position = UDim2.fromOffset(x, y)
    end)

    local function isSelected(value)
        if control.Multi then
            return control.SelectedMap[value] == true
        end
        return control.Value == value
    end

    local function updateValueText()
        if control.ValueLabel then
            if control.Multi then
                local picked = {}
                for _, value in ipairs(control.Values) do
                    if control.SelectedMap[value] then
                        table.insert(picked, value)
                    end
                end
                control.ValueLabel.Text = (#picked > 0 and table.concat(picked, ", ") or "none")
            else
                control.ValueLabel.Text = tostring(control.Value or "none")
            end
        end
    end

    for _, value in ipairs(values) do
        local item = Instance.new("TextButton")
        item.Parent = list
        item.Size = UDim2.new(1, 0, 0, itemHeight)
        item.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        item.BackgroundTransparency = isSelected(value) and 0.1 or 0.72
        item.AutoButtonColor = false
        item.Text = ""
        item.ZIndex = 501

        local corner = Instance.new("UICorner")
        corner.Parent = item
        corner.CornerRadius = UDim.new(0, 4)

        local label = Instance.new("TextLabel")
        label.Parent = item
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -12, 1, 0)
        label.Position = UDim2.fromOffset(6, 0)
        label.Font = Enum.Font.RobotoMono
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 13
        label.Text = tostring(value)
        label.ZIndex = 502

        if isSelected(value) then
            local gradient = Instance.new("UIGradient")
            gradient.Parent = item
            gradient.Color = makeAccentSequence(self.AccentA, self.AccentB)
            addAnimatedGradient(self.AnimatedGradients, gradient, 0.24)
        end

        item.MouseEnter:Connect(function()
            if not isSelected(value) then
                tween(item, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0.5,
                })
            end
        end)

        item.MouseLeave:Connect(function()
            if not isSelected(value) then
                tween(item, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0.72,
                })
            end
        end)

        item.MouseButton1Click:Connect(function()
            if control.Multi then
                control.SelectedMap[value] = not control.SelectedMap[value]
                local selected = {}
                for _, each in ipairs(control.Values) do
                    if control.SelectedMap[each] then
                        table.insert(selected, each)
                    end
                end
                control.Value = selected
            else
                control.Value = value
            end

            updateValueText()

            if control.Callback then
                control.Callback(control.Value)
            end

            if not control.Multi then
                popup.Visible = false
                self.Popup.Blocker.Visible = false
            else
                self:_openDropdown(control)
            end
        end)
    end
end

function Window:_buildColorPickerExtras()
    local refs = self.ColorRefs
    refs.COLORPCIKER_OtherText.Visible = false

    local satGrad = Instance.new("UIGradient")
    satGrad.Parent = refs.COLORPICKER_ColorPickerMainFrame
    satGrad.Rotation = 0
    satGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
    })
    satGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })

    local valueOverlay = Instance.new("Frame")
    valueOverlay.Parent = refs.COLORPICKER_ColorPickerMainFrame
    valueOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    valueOverlay.BorderSizePixel = 0
    valueOverlay.Size = UDim2.fromScale(1, 1)
    valueOverlay.ZIndex = refs.COLORPICKER_ColorPickerMainFrameDot.ZIndex - 1

    local valueCorner = Instance.new("UICorner")
    valueCorner.Parent = valueOverlay
    valueCorner.CornerRadius = UDim.new(0, 4)

    local valueGrad = Instance.new("UIGradient")
    valueGrad.Parent = valueOverlay
    valueGrad.Rotation = 90
    valueGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })

    local hueGradient = refs.COLORPICKER_ColorSelectorFrame:FindFirstChildOfClass("UIGradient")
    if hueGradient then
        hueGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
        })
    end

    refs._SaturationGradient = satGrad
    refs._ValueOverlay = valueOverlay

    local valueHolder = Instance.new("Frame")
    valueHolder.Parent = refs.COLORPICKER_MainFrame
    valueHolder.BackgroundTransparency = 1
    valueHolder.Position = UDim2.new(0.587, 0, 0.36, 0)
    valueHolder.Size = UDim2.fromOffset(180, 150)
    valueHolder.ZIndex = 5

    local valueLayout = Instance.new("UIListLayout")
    valueLayout.Parent = valueHolder
    valueLayout.Padding = UDim.new(0, 4)

    local fields = {}
    local names = {
        {"R", "rgb"},
        {"G", "rgb"},
        {"B", "rgb"},
        {"H", "hsv"},
        {"S", "hsv"},
        {"V", "hsv"},
    }

    for _, info in ipairs(names) do
        local row = Instance.new("Frame")
        row.Parent = valueHolder
        row.BackgroundTransparency = 1
        row.Size = UDim2.new(1, 0, 0, 20)
        row.ZIndex = 5

        local label = Instance.new("TextLabel")
        label.Parent = row
        label.BackgroundTransparency = 1
        label.Size = UDim2.fromOffset(18, 20)
        label.Font = Enum.Font.RobotoMono
        label.Text = info[1] .. ":"
        label.TextColor3 = Color3.fromRGB(86, 86, 86)
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 5

        local box = Instance.new("TextBox")
        box.Parent = row
        box.BackgroundTransparency = 1
        box.Position = UDim2.fromOffset(20, 0)
        box.Size = UDim2.fromOffset(70, 20)
        box.Font = Enum.Font.RobotoMono
        box.Text = "0"
        box.TextColor3 = Color3.fromRGB(255, 255, 255)
        box.TextSize = 12
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.ClearTextOnFocus = false
        box.ZIndex = 5

        fields[info[1]] = {
            Mode = info[2],
            Box = box,
        }
    end

    refs.ValueFields = fields
end

function Window:_pushRecentColor(color)
    local rgb = {
        color.R,
        color.G,
        color.B,
    }

    local key = string.format("%.3f-%.3f-%.3f", rgb[1], rgb[2], rgb[3])
    if self.ColorPickerRecentMap[key] then
        return
    end

    table.insert(self.ColorPickerRecent, 1, color)
    self.ColorPickerRecentMap[key] = true

    while #self.ColorPickerRecent > 5 do
        local removed = table.remove(self.ColorPickerRecent)
        if removed then
            local removeKey = string.format("%.3f-%.3f-%.3f", removed.R, removed.G, removed.B)
            self.ColorPickerRecentMap[removeKey] = nil
        end
    end
end

function Window:_refreshRecentColorFrames()
    local refs = self.ColorRefs
    local frames = {
        refs.COLORPICKER_LastColorLastColor1,
        refs.COLORPICKER_LastColorLastColor2,
        refs.COLORPICKER_LastColorLastColor3,
        refs.COLORPICKER_LastColorLastColor4,
        refs.COLORPICKER_LastColorLastColor5,
    }

    for index, frame in ipairs(frames) do
        local color = self.ColorPickerRecent[index]
        frame.Visible = color ~= nil
        if color then
            frame.BackgroundColor3 = color
        end
    end
end

function Window:_applyColorPickerState(pushToRecent)
    local refs = self.ColorRefs
    local state = self.ColorPickerState
    local hueColor = Color3.fromHSV(state.H, 1, 1)

    refs.COLORPICKER_CurrentColorFrame.BackgroundColor3 = Color3.fromHSV(state.H, state.S, state.V)
    refs.COLORPICKER_ColorPickerMainFrame.BackgroundColor3 = hueColor

    local x = clamp(state.S * refs.COLORPICKER_ColorPickerMainFrame.AbsoluteSize.X, 0, refs.COLORPICKER_ColorPickerMainFrame.AbsoluteSize.X)
    local y = clamp((1 - state.V) * refs.COLORPICKER_ColorPickerMainFrame.AbsoluteSize.Y, 0, refs.COLORPICKER_ColorPickerMainFrame.AbsoluteSize.Y)
    tween(refs.COLORPICKER_ColorPickerMainFrameDot, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
        Position = UDim2.fromOffset(x - 4, y - 4),
    })

    local selectorY = clamp(state.H * refs.COLORPICKER_ColorSelectorFrame.AbsoluteSize.Y, 0, refs.COLORPICKER_ColorSelectorFrame.AbsoluteSize.Y)
    tween(refs.COLORPICKER_ColorSelectorFrameSelectLine, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
        Position = UDim2.new(0, 0, 0, selectorY),
    })

    local color = Color3.fromHSV(state.H, state.S, state.V)

    if refs.ValueFields then
        refs.ValueFields.R.Box.Text = tostring(math.floor(color.R * 255 + 0.5))
        refs.ValueFields.G.Box.Text = tostring(math.floor(color.G * 255 + 0.5))
        refs.ValueFields.B.Box.Text = tostring(math.floor(color.B * 255 + 0.5))
        refs.ValueFields.H.Box.Text = tostring(math.floor(state.H * 360 + 0.5))
        refs.ValueFields.S.Box.Text = tostring(math.floor(state.S * 100 + 0.5))
        refs.ValueFields.V.Box.Text = tostring(math.floor(state.V * 100 + 0.5))
    end

    if self.OpenColorControl then
        self.OpenColorControl.Value = color
        self.OpenColorControl.Preview.BackgroundColor3 = color
        if self.OpenColorControl.Callback then
            self.OpenColorControl.Callback(color)
        end
    end

    if pushToRecent then
        self:_pushRecentColor(color)
        self:_refreshRecentColorFrames()
    end
end

function Window:_openColorPicker(control)
    self.OpenColorControl = control
    self.ColorRefs.COLORPICKER_WindowDesc.Text = "from: " .. control.Path
    self.ColorRefs.COLORPICKER_WindowName.Text = control.Name
    self.Root.ColorPickerGui.Enabled = true
    self.ColorRefs.COLORPICKER_MainFrame.Visible = true

    local h, s, v = control.Value:ToHSV()
    self.ColorPickerState.H = h
    self.ColorPickerState.S = s
    self.ColorPickerState.V = v
    self.ColorPickerState.Default = control.Default or control.Value

    self:_applyColorPickerState(false)
end

function Window:_closeColorPicker()
    self.Root.ColorPickerGui.Enabled = false
    self.OpenColorControl = nil
    self:_refreshRecentColorFrames()
end

function Window:_bindColorPicker()
    self:_buildColorPickerExtras()
    local refs = self.ColorRefs

    local pickerDrag = createInvisibleDragHandle(refs.COLORPICKER_MainFrame, UDim2.new(1, 0, 0, 50), UDim2.fromOffset(0, 0), 20)
    enableSmoothDrag(refs.COLORPICKER_MainFrame, pickerDrag)

    local draggingSquare = false
    local draggingHue = false

    local function updateFromSquare(mouse)
        local abs = refs.COLORPICKER_ColorPickerMainFrame.AbsolutePosition
        local size = refs.COLORPICKER_ColorPickerMainFrame.AbsoluteSize
        local x = clamp(mouse.X - abs.X, 0, size.X)
        local y = clamp(mouse.Y - abs.Y, 0, size.Y)

        self.ColorPickerState.S = x / math.max(size.X, 1)
        self.ColorPickerState.V = 1 - (y / math.max(size.Y, 1))
        self:_applyColorPickerState(false)
    end

    local function updateFromHue(mouse)
        local abs = refs.COLORPICKER_ColorSelectorFrame.AbsolutePosition
        local size = refs.COLORPICKER_ColorSelectorFrame.AbsoluteSize
        local y = clamp(mouse.Y - abs.Y, 0, size.Y)
        self.ColorPickerState.H = y / math.max(size.Y, 1)
        self:_applyColorPickerState(false)
    end

    refs.COLORPICKER_ColorPickerMainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSquare = true
            updateFromSquare(UserInputService:GetMouseLocation())
        end
    end)

    refs.COLORPICKER_ColorSelectorFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = true
            updateFromHue(UserInputService:GetMouseLocation())
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        local mouse = UserInputService:GetMouseLocation()
        if draggingSquare then
            updateFromSquare(mouse)
        elseif draggingHue then
            updateFromHue(mouse)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if draggingSquare or draggingHue then
                self:_applyColorPickerState(true)
            end
            draggingSquare = false
            draggingHue = false
        end
    end)

    refs.COLORPICKER_CloseButton.MouseButton1Click:Connect(function()
        self:_closeColorPicker()
    end)

    refs.COLORPICKER_RandomColor.MouseButton1Click:Connect(function()
        self.ColorPickerState.H = math.random()
        self.ColorPickerState.S = math.random()
        self.ColorPickerState.V = math.random()
        self:_applyColorPickerState(true)
    end)

    refs.COLORPICKER_ResetToDefault.MouseButton1Click:Connect(function()
        local default = self.ColorPickerState.Default or Color3.new(1, 1, 1)
        local h, s, v = default:ToHSV()
        self.ColorPickerState.H = h
        self.ColorPickerState.S = s
        self.ColorPickerState.V = v
        self:_applyColorPickerState(true)
    end)

    local recentFrames = {
        refs.COLORPICKER_LastColorLastColor1,
        refs.COLORPICKER_LastColorLastColor2,
        refs.COLORPICKER_LastColorLastColor3,
        refs.COLORPICKER_LastColorLastColor4,
        refs.COLORPICKER_LastColorLastColor5,
    }

    for index, frame in ipairs(recentFrames) do
        local hitbox = Instance.new("TextButton")
        hitbox.Parent = frame
        hitbox.BackgroundTransparency = 1
        hitbox.Size = UDim2.fromScale(1, 1)
        hitbox.Text = ""
        hitbox.AutoButtonColor = false

        hitbox.MouseButton1Click:Connect(function()
            local color = self.ColorPickerRecent[index]
            if color then
                local h, s, v = color:ToHSV()
                self.ColorPickerState.H = h
                self.ColorPickerState.S = s
                self.ColorPickerState.V = v
                self:_applyColorPickerState(true)
            end
        end)
    end

    for key, field in pairs(refs.ValueFields) do
        field.Box.FocusLost:Connect(function(enterPressed)
            local num = tonumber(field.Box.Text)
            if not num then
                self:_applyColorPickerState(false)
                return
            end

            if key == "R" or key == "G" or key == "B" then
                local r = tonumber(refs.ValueFields.R.Box.Text) or 0
                local g = tonumber(refs.ValueFields.G.Box.Text) or 0
                local b = tonumber(refs.ValueFields.B.Box.Text) or 0
                local color = Color3.fromRGB(clamp(r, 0, 255), clamp(g, 0, 255), clamp(b, 0, 255))
                local h, s, v = color:ToHSV()
                self.ColorPickerState.H = h
                self.ColorPickerState.S = s
                self.ColorPickerState.V = v
            else
                local h = clamp((tonumber(refs.ValueFields.H.Box.Text) or 0) / 360, 0, 1)
                local s = clamp((tonumber(refs.ValueFields.S.Box.Text) or 0) / 100, 0, 1)
                local v = clamp((tonumber(refs.ValueFields.V.Box.Text) or 0) / 100, 0, 1)
                self.ColorPickerState.H = h
                self.ColorPickerState.S = s
                self.ColorPickerState.V = v
            end

            self:_applyColorPickerState(enterPressed)
        end)
    end
end

function Window:_buildNotifications()
    local bottomHolder = Instance.new("Frame")
    bottomHolder.Parent = self.Root.NotificationsGui
    bottomHolder.BackgroundTransparency = 1
    bottomHolder.Size = UDim2.fromScale(1, 1)
    bottomHolder.Name = "NotificationHolder"

    self.NotificationHolder = bottomHolder
    self.NotificationOrder = {}
end

function Window:_reflowNotifications()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local stackedIndex = 0

    for _, notification in ipairs(self.NotificationOrder) do
        if notification.Frame and notification.Frame.Parent then
            if not notification.Floating then
                stackedIndex += 1
                local targetX = 18
                local targetY = viewport.Y - 18 - notification.Frame.AbsoluteSize.Y - ((stackedIndex - 1) * (notification.Frame.AbsoluteSize.Y + 10))
                notification.Target = Vector2.new(targetX, targetY)
            end
        end
    end
end

function Window:_closeNotification(notification)
    if notification.Closing then
        return
    end
    notification.Closing = true

    local scale = notification.Scale
    tween(scale, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Scale = 0.88,
    })
    fadeTree(notification.Frame, 1, 0.16)

    task.delay(0.18, function()
        for i, item in ipairs(self.NotificationOrder) do
            if item == notification then
                table.remove(self.NotificationOrder, i)
                break
            end
        end

        if notification.Frame then
            notification.Frame:Destroy()
        end

        self:_reflowNotifications()
    end)
end

function Window:Notify(options)
    options = options or {}

    local frame = self.NotificationTemplate.NOTIFICATIONS_MainFrame:Clone()
    frame.Parent = self.NotificationHolder
    frame.Visible = true
    frame.Position = UDim2.fromOffset(-280, 0)

    local closeButton = frame:FindFirstChild("CloseButton")
    local freezeButton = frame:FindFirstChild("FreezeButton")
    local freezeIcon = freezeButton and freezeButton:FindFirstChild("FreezeButtonIcon")
    local timeLine = frame:FindFirstChild("TimeLine")
    local timeLineGlow = frame:FindFirstChild("TimeLineGlow")
    local timeLeft = frame:FindFirstChild("TimeLeft")
    local title = frame:FindFirstChild("NotificationName")
    local desc = frame:FindFirstChild("NotificationDescription")

    if title then
        title.Text = tostring(options.Title or "Notification")
    end

    if desc then
        desc.Text = tostring(options.Description or options.Content or "")
        desc.TextWrapped = true
        desc.TextYAlignment = Enum.TextYAlignment.Top
        local wantedHeight = math.max(37, textSizeY(desc.Text, 12, 182))
        desc.Size = UDim2.fromOffset(182, wantedHeight)
        local newHeight = math.max(65, 26 + wantedHeight + 14)
        frame.Size = UDim2.fromOffset(253, newHeight)
        if timeLine then
            timeLine.Position = UDim2.new(0, 0, 1, -2)
            timeLine.Size = UDim2.fromOffset(253, 2)
        end
        if timeLineGlow then
            timeLineGlow.Position = UDim2.new(0, 0, 1, -17)
            timeLineGlow.Size = UDim2.fromOffset(253, 17)
        end
    end

    local scale = Instance.new("UIScale")
    scale.Parent = frame
    scale.Scale = 0.96

    local record = {
        Frame = frame,
        Scale = scale,
        Duration = tonumber(options.Duration) or 5,
        Remaining = tonumber(options.Duration) or 5,
        Frozen = false,
        Floating = false,
        Closing = false,
        Target = Vector2.new(18, 18),
    }

    table.insert(self.NotificationOrder, 1, record)
    self:_reflowNotifications()

    local runConnection
    runConnection = RunService.RenderStepped:Connect(function(dt)
        if not frame.Parent then
            safeDisconnect(runConnection)
            return
        end

        if not record.Frozen and not record.Closing then
            record.Remaining -= dt
            if timeLeft then
                timeLeft.Text = string.format("%.1fs", math.max(0, record.Remaining))
            end

            local alpha = clamp(record.Remaining / math.max(record.Duration, 0.001), 0, 1)
            if timeLine then
                timeLine.Size = UDim2.fromOffset(math.floor(253 * alpha), 2)
            end
            if timeLineGlow then
                timeLineGlow.Size = UDim2.fromOffset(math.floor(253 * alpha), 17)
            end

            if record.Remaining <= 0 then
                self:_closeNotification(record)
                safeDisconnect(runConnection)
                return
            end
        end

        if record.Target then
            local pos = frame.Position
            local cx, cy = pos.X.Offset, pos.Y.Offset
            local nx = lerp(cx, record.Target.X, 0.18)
            local ny = lerp(cy, record.Target.Y, 0.18)
            frame.Position = UDim2.fromOffset(nx, ny)
        end
    end)

    tween(scale, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Scale = 1,
    })

    if closeButton then
        closeButton.MouseButton1Click:Connect(function()
            self:_closeNotification(record)
        end)
    end

    if freezeButton then
        freezeButton.MouseButton1Click:Connect(function()
            record.Frozen = not record.Frozen
            if freezeIcon then
                tween(freezeIcon, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                    ImageTransparency = record.Frozen and 0.25 or 0.84,
                })
            end
        end)
    end

    local dragHitbox = createInvisibleDragHandle(frame, UDim2.fromOffset(26, frame.AbsoluteSize.Y + 10), UDim2.fromOffset(-6, -5), 20)
    local dragState = {
        dragging = false,
        offset = Vector2.zero,
    }

    dragHitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragState.dragging = true
            record.Floating = true
            record.Target = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
            dragState.offset = UserInputService:GetMouseLocation() - Vector2.new(frame.AbsolutePosition.X, frame.AbsolutePosition.Y)

            frame.ZIndex = 999
            for _, descObj in ipairs(frame:GetDescendants()) do
                pcall(function()
                    descObj.ZIndex = math.max(descObj.ZIndex, 999)
                end)
            end

            self:_reflowNotifications()

            local changed
            changed = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragState.dragging = false
                    safeDisconnect(changed)
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragState.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = UserInputService:GetMouseLocation()
            record.Target = mouse - dragState.offset
        end
    end)

    return record
end

function Window:SetVisible(state)
    self.Visible = state
    self.Root.MainGui.Enabled = state
    if not state then
        self.Root.ColorPickerGui.Enabled = false
    end
end

function Window:Destroy()
    if self.AnimatedGradients.connection then
        self.AnimatedGradients.connection:Disconnect()
    end

    for _, root in pairs(self.Root) do
        if typeof(root) == "Instance" and root.Parent then
            root:Destroy()
        end
    end
end

function Window:_buildCloseConfirm()
    local confirm = buildConfirmDialog(self.Root.PopupGui, self.AnimatedGradients)
    self.CloseConfirm = confirm

    self.Refs.MAIN_CloseButton.MouseButton1Click:Connect(function()
        confirm.Overlay.Visible = true
    end)

    confirm.Cancel.MouseButton1Click:Connect(function()
        confirm.Overlay.Visible = false
    end)

    confirm.Yes.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
end

function Window:_bindMenuDrag()
    local dragHandle = createInvisibleDragHandle(self.Refs.MAIN_MainBgFrame, UDim2.new(1, 0, 0, 50), UDim2.fromOffset(0, 0), 25)
    enableSmoothDrag(self.Refs.MAIN_MainBgFrame, dragHandle)
end

function Window:_bindHotkey()
    local keybind = self.Config.MenuKeybind
    if typeof(keybind) ~= "EnumItem" then
        return
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end

        if input.KeyCode == keybind then
            self:SetVisible(not self.Visible)
        end
    end)
end

function Window:_makeBaseControl(kind, root, name, section, options)
    options = options or {}
    applyHoverBackground(root)

    local control = {
        Kind = kind,
        Root = root,
        Name = tostring(name),
        Section = section,
        Tab = section.Tab,
        Category = section.Tab.Category,
        Window = self,
        Path = section.Tab.Category.Name .. " / " .. section.Tab.Name .. " / " .. section.Name,
        Callback = options.Callback,
    }

    local searchParts = {
        control.Name,
        control.Path,
        tostring(kind),
    }

    if options.Keywords then
        for _, keyword in ipairs(options.Keywords) do
            table.insert(searchParts, tostring(keyword))
        end
    end

    control.SearchText = table.concat(searchParts, " ")
    self:_registerSearchItem(control)

    table.insert(self.Controls, control)
    return control
end

function Section:AddButton(options)
    options = options or {}
    local button = createButton(options.Name or "Button", self.Frame, options.LayoutOrder, options.ExplorerName)
    local control = self.Window:_makeBaseControl("button", button, options.Name or "Button", self, options)

    button.MouseButton1Click:Connect(function()
        if options.Callback then
            options.Callback()
        end
    end)

    return control
end

function Section:AddToggle(options)
    options = options or {}
    local toggleButton = createToggle(options.Name or "Toggle", self.Frame, options.LayoutOrder, options.ExplorerName)
    local control = self.Window:_makeBaseControl("toggle", toggleButton, options.Name or "Toggle", self, options)
    control.Value = options.Default == true
    control.ActiveFrame = toggleButton.ToggleFrame.Active
    control.NameText = toggleButton.NameText
    control.NameGradient = createTextGradient(control.NameText, makeAccentSequence(self.Window.AccentA, self.Window.AccentB), self.Window.AnimatedGradients)

    local function apply()
        if control.Value then
            control.ActiveFrame.Visible = true
            tween(control.ActiveFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(14, 14),
            })
            control.NameGradient.Enabled = true
        else
            tween(control.ActiveFrame, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(0, 0),
            })
            control.NameGradient.Enabled = false
            task.delay(0.09, function()
                if control.ActiveFrame.Parent and not control.Value then
                    control.ActiveFrame.Visible = false
                end
            end)
        end

        if options.Callback then
            options.Callback(control.Value)
        end
    end

    if control.Value then
        control.ActiveFrame.Visible = true
        control.ActiveFrame.Size = UDim2.fromOffset(14, 14)
        control.NameGradient.Enabled = true
    else
        control.ActiveFrame.Visible = false
        control.ActiveFrame.Size = UDim2.fromOffset(0, 0)
        control.NameGradient.Enabled = false
    end

    function control:Set(value)
        control.Value = value == true
        apply()
    end

    toggleButton.MouseButton1Click:Connect(function()
        control:Set(not control.Value)
    end)

    return control
end

function Section:AddTextbox(options)
    options = options or {}
    local textboxButton = createTextbox(options.Name or "Textbox", self.Frame, options.LayoutOrder, options.ExplorerName)
    local control = self.Window:_makeBaseControl("textbox", textboxButton, options.Name or "Textbox", self, options)
    control.Box = textboxButton:FindFirstChildOfClass("TextBox")
    control.Box.PlaceholderText = options.Placeholder or ""
    control.Value = options.Default or ""
    control.Box.Text = control.Value

    control.Box.FocusLost:Connect(function()
        control.Value = control.Box.Text
        if options.Callback then
            options.Callback(control.Value)
        end
    end)

    if options.Live then
        control.Box:GetPropertyChangedSignal("Text"):Connect(function()
            control.Value = control.Box.Text
            if options.Callback then
                options.Callback(control.Value)
            end
        end)
    end

    return control
end

function Section:AddSlider(options)
    options = options or {}
    local sliderButton = createSlider(options.Name or "Slider", self.Frame, options.LayoutOrder, options.ExplorerName)
    local control = self.Window:_makeBaseControl("slider", sliderButton, options.Name or "Slider", self, options)
    control.Min = tonumber(options.Min) or 0
    control.Max = tonumber(options.Max) or 100
    control.Step = tonumber(options.Step) or 1
    control.Value = clamp(tonumber(options.Default) or control.Min, control.Min, control.Max)

    local line = sliderButton.SliderLine
    local knob = line.SliderKnob
    local box = sliderButton:FindFirstChildOfClass("TextBox")
    local fill = Instance.new("Frame")
    fill.Parent = line
    fill.Name = "Fill"
    fill.BackgroundColor3 = self.Window.AccentA
    fill.BorderSizePixel = 0
    fill.Size = UDim2.fromScale(0, 1)
    fill.ZIndex = 1

    local fillCorner = Instance.new("UICorner")
    fillCorner.Parent = fill
    fillCorner.CornerRadius = UDim.new(1, 0)

    local fillGradient = Instance.new("UIGradient")
    fillGradient.Parent = fill
    fillGradient.Color = makeAccentSequence(self.Window.AccentA, self.Window.AccentB)
    addAnimatedGradient(self.Window.AnimatedGradients, fillGradient, 0.28)

    local function applyValue(trigger)
        local alpha = (control.Value - control.Min) / math.max(control.Max - control.Min, 0.001)
        tween(fill, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromScale(alpha, 1),
        })
        tween(knob, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(alpha, 0, 0.5, 0),
        })
        box.Text = tostring(control.Value)
        if trigger and options.Callback then
            options.Callback(control.Value)
        end
    end

    function control:Set(value, trigger)
        local rounded = roundToStep(clamp(tonumber(value) or control.Min, control.Min, control.Max), control.Step)
        control.Value = rounded
        applyValue(trigger ~= false)
    end

    local dragging = false

    line.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local mouse = UserInputService:GetMouseLocation()
            local rel = clamp(mouse.X - line.AbsolutePosition.X, 0, line.AbsoluteSize.X)
            local alpha = rel / math.max(line.AbsoluteSize.X, 1)
            control:Set(control.Min + ((control.Max - control.Min) * alpha), true)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = UserInputService:GetMouseLocation()
            local rel = clamp(mouse.X - line.AbsolutePosition.X, 0, line.AbsoluteSize.X)
            local alpha = rel / math.max(line.AbsoluteSize.X, 1)
            control:Set(control.Min + ((control.Max - control.Min) * alpha), true)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    box.FocusLost:Connect(function()
        control:Set(tonumber(box.Text) or control.Value, true)
    end)

    control:Set(control.Value, false)
    return control
end

function Section:AddDropdown(options)
    options = options or {}
    local dropdownButton = createDropdown(options.Name or "Dropdown", self.Frame, options.LayoutOrder, options.ExplorerName)
    local control = self.Window:_makeBaseControl("dropdown", dropdownButton, options.Name or "Dropdown", self, options)
    control.Values = options.Values or options.Options or {}
    control.Multi = options.Multi == true
    control.SelectedMap = {}
    control.Value = options.Default or (control.Multi and {} or control.Values[1])

    local valueText = Instance.new("TextLabel")
    valueText.Parent = dropdownButton
    valueText.BackgroundTransparency = 1
    valueText.Size = UDim2.fromOffset(90, 16)
    valueText.Position = UDim2.new(0.56, 0, 0.22, 0)
    valueText.Font = Enum.Font.RobotoMono
    valueText.TextSize = 12
    valueText.TextColor3 = Color3.fromRGB(170, 170, 170)
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.ZIndex = 1
    control.ValueLabel = valueText

    if control.Multi and typeof(control.Value) == "table" then
        for _, v in ipairs(control.Value) do
            control.SelectedMap[v] = true
        end
    end

    if not control.Multi then
        valueText.Text = tostring(control.Value or "none")
    else
        valueText.Text = "none"
    end

    dropdownButton.MouseButton1Click:Connect(function()
        self.Window:_openDropdown(control)
    end)

    return control
end

function Section:AddColorPicker(options)
    options = options or {}
    local pickerButton = createColorPicker(options.Name or "Color picker", self.Frame, options.LayoutOrder, options.ExplorerName)
    local control = self.Window:_makeBaseControl("colorpicker", pickerButton, options.Name or "Color picker", self, options)
    control.Value = options.Default or Color3.fromRGB(255, 255, 255)
    control.Default = control.Value
    control.Preview = pickerButton.ColorPreview

    control.Preview.BackgroundColor3 = control.Value

    pickerButton.MouseButton1Click:Connect(function()
        self.Window:_openColorPicker(control)
    end)

    return control
end

function Section:AddKeybind(options)
    options = options or {}
    local defKey = options.Default
    local text = ""
    if typeof(defKey) == "EnumItem" then
        text = defKey.Name
    elseif type(defKey) == "string" then
        text = defKey
    end

    local keybindButton = createKeybind(options.Name or "Keybind", self.Frame, text, options.LayoutOrder, options.ExplorerName)
    local control = self.Window:_makeBaseControl("keybind", keybindButton, options.Name or "Keybind", self, options)
    control.Value = typeof(defKey) == "EnumItem" and defKey or nil
    control.Text = keybindButton.KeybindFrame.KeybindText
    local listening = false

    local function setKey(key)
        control.Value = key
        control.Text.Text = key and key.Name or ""
    end

    setKey(control.Value)

    keybindButton.MouseButton1Click:Connect(function()
        listening = true
        control.Text.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end

        if listening then
            if input.KeyCode == Enum.KeyCode.Escape then
                setKey(nil)
            elseif input.UserInputType == Enum.UserInputType.Keyboard then
                setKey(input.KeyCode)
            end

            listening = false
            if options.Changed then
                options.Changed(control.Value)
            end
            return
        end

        if control.Value and input.KeyCode == control.Value then
            if options.Callback then
                options.Callback(control.Value)
            end
        end
    end)

    return control
end

function Tab:CreateSection(name, options)
    options = options or {}
    local sectionFrame = createSection(name, self.Scrolling, options.Side or "Left")
    local section = setmetatable({
        Window = self.Window,
        Tab = self,
        Name = name,
        Frame = sectionFrame,
    }, Section)

    table.insert(self.Sections, section)
    return section
end

function Category:CreateTab(name, options)
    options = options or {}
    local button, scrolling = createTab(name, self.TabsHolder, self.Window.Refs.MAIN_TabsContentFolder)
    local tab = setmetatable({
        Window = self.Window,
        Category = self,
        Name = name,
        Button = button,
        Scrolling = scrolling,
        Sections = {},
    }, Tab)

    table.insert(self.Window.Tabs, tab)
    table.insert(self.Tabs, tab)

    applyHoverBackground(button)
    button.MouseButton1Click:Connect(function()
        self.Window:_selectTab(tab)
    end)

    if not self.Window.ActiveTab then
        self.Window:_selectTab(tab)
    end

    return tab
end

function Window:CreateCategory(name)
    local categoryFrame, tabsHolder = createTabCategory(name, self.Refs.TABS_TabsBg)
    local category = setmetatable({
        Window = self,
        Name = name,
        Frame = categoryFrame,
        TabsHolder = tabsHolder,
        Tabs = {},
    }, Category)

    table.insert(self.Categories, category)
    return category
end

function Window:CreateTab(name)
    if not self.DefaultCategory then
        self.DefaultCategory = self:CreateCategory("Main")
    end

    return self.DefaultCategory:CreateTab(name)
end

function Library.new(config)
    config = config or {}

    local parent = config.Parent or safeCoreParent()
    Default_Parent = parent
    _scriptName = config.Name or "Amphibia'"
    _scriptIcon = config.Icon or "rbxassetid://76305975133668"

    local root = buildRootGuis(parent)
    local refs = buildMainWindow(root.MainGui)
    local colorRefs = buildColorPickerWindow(root.ColorPickerGui)
    local notificationTemplate = buildNotificationTemplate(root.NotificationsGui)

    refs.MAIN_ScriptName.Text = _scriptName
    refs.MAIN_ScriptName.TextShadow.Text = _scriptName
    refs.MAIN_ScriptImage.Image = _scriptIcon

    local self = setmetatable({
        Root = root,
        Refs = refs,
        ColorRefs = colorRefs,
        NotificationTemplate = notificationTemplate,
        Config = config,
        Visible = true,
        Tabs = {},
        Categories = {},
        Controls = {},
        SearchIndex = {},
        AnimatedGradients = createGradientAnimationList(),
        ColorPickerRecent = {},
        ColorPickerRecentMap = {},
        ColorPickerState = {
            H = 0,
            S = 1,
            V = 1,
            Default = Color3.fromRGB(255,255,255),
        },
    }, Window)

    self:_setAccentColors(config.AccentA or DEFAULT_ACCENT_A, config.AccentB or DEFAULT_ACCENT_B)
    self:_createSearchResults()
    self:_buildPopup()
    self:_buildNotifications()
    self:_buildCloseConfirm()
    self:_bindMenuDrag()
    self:_bindHotkey()
    self:_bindSearch()
    self:_bindColorPicker()

    return self
end

return Library
