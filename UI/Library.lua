
-- Amphibia UI Library
-- Clean API version
-- ModuleScript / loadstring friendly

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local Amphibia = {}
Amphibia.__index = Amphibia

local STYLE = {
    Title = "Amphibia'",
    Icon = "rbxassetid://76305975133668",

    Images = {
        Settings = "rbxassetid://9405931578",
        Search = "rbxassetid://75273157378006",
        Close = "rbxassetid://130334254289066",
        Random = "rbxassetid://82824171769924",
        Reset = "rbxassetid://438217404",
        Freeze = "rbxassetid://13200344988",
        TripleDot = "rbxassetid://127075876244307",
    },

    Colors = {
        White = Color3.fromRGB(255,255,255),
        Black = Color3.fromRGB(0,0,0),
        Main = Color3.fromRGB(16,16,16),
        Header = Color3.fromRGB(24,24,24),
        Section = Color3.fromRGB(20,20,20),
        PurpleA = Color3.fromRGB(150,64,255),
        PurpleB = Color3.fromRGB(238,48,255),
        Border = Color3.fromRGB(40,40,40),
        BorderSoft = Color3.fromRGB(61,61,61),
        Gray = Color3.fromRGB(130,130,130),
        GrayText = Color3.fromRGB(170,170,170),
        TabHover = Color3.fromRGB(190,190,190),
        TabIdle = Color3.fromRGB(255,255,255),
        SearchA = Color3.fromRGB(27,27,27),
        SearchB = Color3.fromRGB(29,29,29),
    },

    Fonts = {
        Main = Enum.Font.RobotoMono,
    },

    Sizes = {
        Window = Vector2.new(767, 484),
        Search = Vector2.new(355, 31),
        SectionWidth = 276,
        RowWidth = 265,
        PopupWidth = 250,
        NotificationWidth = 330,
    },

    Tween = {
        Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Soft = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Smooth = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        ModalIn = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        ModalOut = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    }
}

local function tween(obj, info, props)
    return TweenService:Create(obj, info, props)
end

local function play(obj, info, props)
    local tw = tween(obj, info, props)
    tw:Play()
    return tw
end

local function mouseLocation()
    local p = UserInputService:GetMouseLocation()
    return Vector2.new(p.X, p.Y)
end

local function clamp(v, a, b)
    return math.max(a, math.min(b, v))
end

local function roundToStep(v, step)
    step = math.max(step or 1, 0.0001)
    return math.floor((v / step) + 0.5) * step
end

local function shallowCopy(t)
    local out = {}
    for k, v in pairs(t) do
        out[k] = v
    end
    return out
end

local function randomName()
    return "Amphibia_" .. HttpService:GenerateGUID(false):gsub("%-", "")
end

local function make(className, props, children)
    local inst = Instance.new(className)
    if props then
        for k, v in pairs(props) do
            inst[k] = v
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    return inst
end

local function addCorner(parent, radius)
    return make("UICorner", {
        CornerRadius = UDim.new(0, radius or 4),
        Parent = parent,
    })
end

local function addDoubleStroke(parent, strokeColor, innerTransparency)
    local a = make("UIStroke", {
        Parent = parent,
        Color = strokeColor or STYLE.Colors.BorderSoft,
        Thickness = 2,
        ZIndex = 1,
    })
    local b = make("UIStroke", {
        Parent = parent,
        Color = STYLE.Colors.Black,
        Thickness = 1,
        Transparency = innerTransparency == nil and 0.5 or innerTransparency,
        ZIndex = 2,
    })
    return a, b
end

local function addMainGradient(parent, rot)
    return make("UIGradient", {
        Parent = parent,
        Rotation = rot or -90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, STYLE.Colors.Black),
            ColorSequenceKeypoint.new(1, STYLE.Colors.White),
        }
    })
end

local function addHeaderGlow(parent, width)
    local glow = make("Frame", {
        Parent = parent,
        BackgroundColor3 = STYLE.Colors.PurpleA,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0.1,0),
        Size = UDim2.new(0, width, 0, 17),
        ZIndex = 5,
    })
    make("UIGradient", {
        Parent = glow,
        Rotation = 90,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,0.727),
            NumberSequenceKeypoint.new(1,1),
        }
    })
    return glow
end

local function descendants(root)
    local list = {}
    for _, obj in ipairs(root:GetDescendants()) do
        table.insert(list, obj)
    end
    table.insert(list, root)
    return list
end

local function fadeGuiObjectTree(root, target, duration, destroyAfter)
    local info = TweenInfo.new(duration or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    for _, obj in ipairs(descendants(root)) do
        local props = {}
        if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextBox") or obj:IsA("ScrollingFrame") or obj:IsA("ViewportFrame") then
            props.BackgroundTransparency = target
        end
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            props.TextTransparency = target
            if obj.TextStrokeTransparency < 1 then
                props.TextStrokeTransparency = math.min(1, target + 0.45)
            end
        end
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            props.ImageTransparency = target
        end
        if obj:IsA("UIStroke") then
            props.Transparency = target
        end
        if obj:IsA("UIGradient") and obj.Transparency.Keypoints[1].Value < 1 then
            local keys = {}
            for _, kp in ipairs(obj.Transparency.Keypoints) do
                table.insert(keys, NumberSequenceKeypoint.new(kp.Time, clamp(target, 0, 1)))
            end
            props.Transparency = NumberSequence.new(keys)
        end
        if next(props) then
            play(obj, info, props)
        end
    end
    if destroyAfter then
        task.delay(duration or 0.18, function()
            if root and root.Parent then
                root:Destroy()
            end
        end)
    end
end

local function screenPositionToScale(parent, absoluteTopLeft, target)
    local absSize = parent.AbsoluteSize
    local absPos = parent.AbsolutePosition
    local anchor = target.AnchorPoint
    local posX = absoluteTopLeft.X - absPos.X + (target.AbsoluteSize.X * anchor.X)
    local posY = absoluteTopLeft.Y - absPos.Y + (target.AbsoluteSize.Y * anchor.Y)
    local x = posX / math.max(absSize.X, 1)
    local y = posY / math.max(absSize.Y, 1)
    return UDim2.fromScale(x, y)
end

local function makeHoverShade(button)
    local shade = make("Frame", {
        Parent = button,
        Name = "HoverShade",
        BackgroundColor3 = STYLE.Colors.Black,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,1,0),
        ZIndex = 0,
    })
    addCorner(shade, 4)
    local function setHover(state)
        play(shade, STYLE.Tween.Fast, {BackgroundTransparency = state and 0.88 or 1})
    end
    button.MouseEnter:Connect(function() setHover(true) end)
    button.MouseLeave:Connect(function() setHover(false) end)
    return shade
end

local function makeDrag(handle, target, opts)
    opts = opts or {}
    local state = {
        Dragging = false,
        StartMouse = nil,
        StartPos = nil,
        Conn = nil,
    }

    local function stop()
        state.Dragging = false
        if state.Conn then
            state.Conn:Disconnect()
            state.Conn = nil
        end
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        state.Dragging = true
        state.StartMouse = mouseLocation()
        state.StartPos = target.AbsolutePosition

        state.Conn = RunService.RenderStepped:Connect(function()
            if not state.Dragging then
                return
            end
            local delta = mouseLocation() - state.StartMouse
            local nextAbs = state.StartPos + delta

            if opts.ClampedToScreen then
                local view = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
                nextAbs = Vector2.new(
                    clamp(nextAbs.X, 0, view.X - target.AbsoluteSize.X),
                    clamp(nextAbs.Y, 0, view.Y - target.AbsoluteSize.Y)
                )
            end

            local parent = target.Parent
            if parent and parent:IsA("GuiObject") then
                play(target, STYLE.Tween.Fast, {Position = screenPositionToScale(parent, nextAbs, target)})
            elseif parent and parent:IsA("LayerCollector") then
                local anchor = target.AnchorPoint
                play(target, STYLE.Tween.Fast, {
                    Position = UDim2.new(
                        0,
                        nextAbs.X + (target.AbsoluteSize.X * anchor.X),
                        0,
                        nextAbs.Y + (target.AbsoluteSize.Y * anchor.Y)
                    )
                })
            end
        end)
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            stop()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            stop()
        end
    end)
end

local function centerModalOpen(frame)
    local scale = frame:FindFirstChildOfClass("UIScale") or make("UIScale", {Parent = frame, Scale = 0.86})
    frame.Visible = true
    scale.Scale = 0.86
    frame.BackgroundTransparency = 1
    play(scale, STYLE.Tween.ModalIn, {Scale = 1})
    play(frame, STYLE.Tween.ModalIn, {BackgroundTransparency = 0})
end

local function centerModalClose(frame)
    local scale = frame:FindFirstChildOfClass("UIScale")
    if not scale then
        scale = make("UIScale", {Parent = frame, Scale = 1})
    end
    play(scale, STYLE.Tween.ModalOut, {Scale = 0.86})
    play(frame, STYLE.Tween.ModalOut, {BackgroundTransparency = 1})
end

local function setTextColorGradient(stroke)
    local g = make("UIGradient", {
        Parent = stroke,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, STYLE.Colors.PurpleA),
            ColorSequenceKeypoint.new(1, STYLE.Colors.PurpleB),
        },
        Rotation = -50,
    })
    return g
end

local function makeLabel(props)
    props = props or {}
    return make("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = STYLE.Fonts.Main,
        TextColor3 = props.TextColor3 or STYLE.Colors.White,
        TextSize = props.TextSize or 14,
        Text = props.Text or "",
        TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
        TextStrokeColor3 = props.TextStrokeColor3 or STYLE.Colors.Black,
        TextStrokeTransparency = props.TextStrokeTransparency == nil and 0 or props.TextStrokeTransparency,
        Position = props.Position,
        Size = props.Size,
        ZIndex = props.ZIndex,
        Name = props.Name,
        Parent = props.Parent,
        TextWrapped = props.TextWrapped or false,
        RichText = props.RichText or false,
        AutomaticSize = props.AutomaticSize,
        AnchorPoint = props.AnchorPoint,
        LayoutOrder = props.LayoutOrder,
    })
end

local function colorToRGB(color)
    return math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5)
end

local function textSizeY(text, size, width)
    local bounds = TextService:GetTextSize(text or "", size, STYLE.Fonts.Main, Vector2.new(width, 10000))
    return bounds.Y
end

local function safeDisconnect(conn)
    if conn then
        conn:Disconnect()
    end
end

local UIHelpers = {}

function UIHelpers.SectionBase(section, name)
    local row = make("TextButton", {
        Parent = section.ButtonHolder,
        Name = name,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        TextTransparency = 1,
        Size = UDim2.new(0, STYLE.Sizes.RowWidth, 0, 29),
        AutoButtonColor = false,
    })
    makeHoverShade(row)

    local label = makeLabel({
        Parent = row,
        Name = "NameText",
        Size = UDim2.new(1,0,1,0),
        Text = name,
        TextSize = 14,
    })
    return row, label
end

function UIHelpers.RightField(parent, width)
    local frame = make("Frame", {
        Parent = parent,
        BackgroundColor3 = Color3.fromRGB(104,104,104),
        BorderSizePixel = 0,
        Size = UDim2.new(0, width, 0, 19),
        ZIndex = 1,
    })
    addCorner(frame, 4)
    make("UIGradient", {
        Parent = frame,
        Rotation = -90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(120,120,120)),
            ColorSequenceKeypoint.new(1, STYLE.Colors.White),
        }
    })
    addDoubleStroke(frame, STYLE.Colors.BorderSoft, 0.43)
    return frame
end

local function buildRoot(parent)
    local root = {}
    root.Gui = make("ScreenGui", {
        Parent = parent or CoreGui,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        Name = randomName(),
        DisplayOrder = 30,
    })

    root.Dark = make("Frame", {
        Parent = root.Gui,
        BackgroundColor3 = STYLE.Colors.Black,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,0,1,0),
        ZIndex = 0,
    })

    root.Main = make("Frame", {
        Parent = root.Gui,
        Name = "MainBg",
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0,0.5,0),
        Size = UDim2.fromOffset(STYLE.Sizes.Window.X, STYLE.Sizes.Window.Y),
        BackgroundColor3 = STYLE.Colors.Main,
        BorderSizePixel = 0,
        ZIndex = 1,
    })
    addCorner(root.Main, 4)
    addMainGradient(root.Main, -90)

    root.Overlay = make("Frame", {
        Parent = root.Gui,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,0,1,0),
        ZIndex = 1000,
    })

    root.Popups = make("Folder", {
        Parent = root.Gui,
        Name = "Popups",
    })

    root.Notifications = make("Frame", {
        Parent = root.Gui,
        Name = "NotificationsRoot",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1,1),
        Position = UDim2.new(1,-18,1,-18),
        Size = UDim2.new(0, STYLE.Sizes.NotificationWidth, 1, -36),
        ZIndex = 2000,
    })
    local notifList = make("UIListLayout", {
        Parent = root.Notifications,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0,10),
    })
    root.NotificationsList = notifList

    return root
end

local function buildHeader(window)
    local refs = {}

    refs.Header = make("Frame", {
        Parent = window.Root.Main,
        Name = "HeaderBgFrame",
        BackgroundColor3 = STYLE.Colors.Header,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(0, STYLE.Sizes.Window.X, 0, 48),
        ZIndex = 2,
    })
    addCorner(refs.Header, 4)
    make("UIGradient", {
        Parent = refs.Header,
        Rotation = -90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(95,95,95)),
            ColorSequenceKeypoint.new(1, STYLE.Colors.White),
        }
    })
    local headerStroke = make("UIStroke", {
        Parent = refs.Header,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        Color = STYLE.Colors.PurpleA,
        Thickness = 1,
        ZIndex = 3,
        LineJoinMode = Enum.LineJoinMode.Round,
    })
    make("UIGradient", {
        Parent = headerStroke,
        Rotation = -90,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(0.05,1),
            NumberSequenceKeypoint.new(1,1),
        }
    })
    addHeaderGlow(window.Root.Main, STYLE.Sizes.Window.X)

    refs.Icon = make("ImageLabel", {
        Parent = window.Root.Main,
        Name = "ScriptImage",
        BackgroundTransparency = 1,
        Position = UDim2.new(0,0,0.013,0),
        Size = UDim2.new(0,38,0,38),
        Image = window.Config.Icon,
        ZIndex = 5,
    })

    refs.Title = makeLabel({
        Parent = window.Root.Main,
        Name = "ScriptName",
        Position = UDim2.new(0.05,0,0.012,0),
        Size = UDim2.new(0,130,0,34),
        Text = window.Config.Title,
        TextSize = 20,
        ZIndex = 5,
    })
    local titleStroke = make("UIStroke", {
        Parent = refs.Title,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        Thickness = 0.4,
        Color = STYLE.Colors.White,
        LineJoinMode = Enum.LineJoinMode.Round,
    })
    setTextColorGradient(titleStroke)

    refs.TitleShadow = makeLabel({
        Parent = refs.Title,
        Name = "TextShadow",
        Position = UDim2.new(0,0,-0.1,0),
        Size = UDim2.new(0,126,0,47),
        Text = window.Config.Title,
        TextSize = 20,
        TextColor3 = STYLE.Colors.Black,
        ZIndex = 4,
        TextStrokeTransparency = 1,
    })
    make("UIGradient", {
        Parent = refs.TitleShadow,
        Rotation = -90,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(0.5,0.369),
            NumberSequenceKeypoint.new(1,0),
        }
    })

    refs.SearchFrame = make("Frame", {
        Parent = window.Root.Main,
        Name = "SearchFrame",
        Position = UDim2.new(0.269,0,0.017,0),
        Size = UDim2.fromOffset(STYLE.Sizes.Search.X, STYLE.Sizes.Search.Y),
        BackgroundColor3 = STYLE.Colors.White,
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    addCorner(refs.SearchFrame, 4)
    make("UIGradient", {
        Parent = refs.SearchFrame,
        Rotation = 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, STYLE.Colors.SearchA),
            ColorSequenceKeypoint.new(1, STYLE.Colors.SearchB),
        }
    })
    make("UIStroke", {
        Parent = refs.SearchFrame,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        Color = STYLE.Colors.Border,
        Thickness = 1,
        ZIndex = 1,
        LineJoinMode = Enum.LineJoinMode.Round,
    })
    refs.SearchIcon = make("ImageLabel", {
        Parent = refs.SearchFrame,
        Name = "SearchImage",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.017,0,0.194,0),
        Size = UDim2.new(0,20,0,20),
        Image = STYLE.Images.Search,
        ImageTransparency = 0.6,
        ZIndex = 2,
    })
    refs.SearchBox = make("TextBox", {
        Parent = refs.SearchFrame,
        Name = "SearchTextBox",
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        Font = STYLE.Fonts.Main,
        TextColor3 = STYLE.Colors.White,
        TextSize = 14,
        Text = "",
        PlaceholderText = "Search",
        TextTransparency = 0.75,
        ClearTextOnFocus = false,
        ZIndex = 2,
    })
    make("UIStroke", {
        Parent = refs.SearchBox,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        Thickness = 1,
        LineJoinMode = Enum.LineJoinMode.Round,
        Color = Color3.fromRGB(33,33,33),
    })

    refs.Close = make("ImageButton", {
        Parent = window.Root.Main,
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.944,0,0.012,0),
        Size = UDim2.new(0,36,0,36),
        ImageTransparency = 0.84,
        Image = STYLE.Images.Close,
        AutoButtonColor = false,
        ZIndex = 6,
    })
    refs.Settings = make("ImageButton", {
        Parent = window.Root.Main,
        Name = "SettingsButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.74,0,0.024,0),
        Size = UDim2.new(0,25,0,25),
        Image = STYLE.Images.Settings,
        ImageTransparency = 0.84,
        AutoButtonColor = false,
        ZIndex = 6,
    })

    return refs
end

local function buildTabsArea(window)
    local refs = {}
    refs.Side = make("Frame", {
        Parent = window.Root.Main,
        Name = "TabsBg",
        Position = UDim2.new(0,0,0.097,0),
        Size = UDim2.new(0,185,0,436),
        BackgroundColor3 = STYLE.Colors.Black,
        BorderSizePixel = 0,
        ZIndex = 1,
    })
    make("UIGradient", {
        Parent = refs.Side,
        Rotation = 90,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(1,1),
        }
    })
    refs.SideList = make("UIListLayout", {
        Parent = refs.Side,
        Padding = UDim.new(0,15),
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    })
    make("UIPadding", {
        Parent = refs.Side,
        PaddingLeft = UDim.new(0,20),
        PaddingTop = UDim.new(0,20),
    })

    refs.HeaderSplit = make("Frame", {
        Parent = window.Root.Main,
        Name = "HeaderSplitter",
        BorderSizePixel = 0,
        BackgroundColor3 = STYLE.Colors.PurpleA,
        BackgroundTransparency = 0.2,
        Position = UDim2.new(0,0,0.102,0),
        Size = UDim2.new(0,185,0,1),
        ZIndex = 4,
    })
    make("UIGradient", {
        Parent = refs.HeaderSplit,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,1),
            NumberSequenceKeypoint.new(1,0),
        }
    })

    refs.Split = make("Frame", {
        Parent = window.Root.Main,
        Name = "TabsSplitter",
        Position = UDim2.new(0.24,0,0.101,0),
        Size = UDim2.new(0,1,0,434),
        BackgroundColor3 = Color3.fromRGB(85,85,85),
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    make("UIGradient", {
        Parent = refs.Split,
        Rotation = 90,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(1,1),
        }
    })

    refs.ContentFolder = make("Folder", {
        Parent = window.Root.Main,
        Name = "TabsContentFolder",
    })

    return refs
end

local function buildConfirm(window)
    local refs = {}
    refs.Dark = make("TextButton", {
        Parent = window.Root.Overlay,
        Name = "CloseConfirmOverlay",
        BackgroundColor3 = STYLE.Colors.Black,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,1,0),
        Text = "",
        Visible = false,
        ZIndex = 1002,
        AutoButtonColor = false,
    })

    refs.Frame = make("Frame", {
        Parent = refs.Dark,
        Name = "ConfirmFrame",
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0,0.5,0),
        Size = UDim2.fromOffset(340, 170),
        BackgroundColor3 = STYLE.Colors.Main,
        BorderSizePixel = 0,
        Visible = true,
        Active = true,
        ZIndex = 1003,
    })
    addCorner(refs.Frame, 4)
    addMainGradient(refs.Frame, -90)
    addDoubleStroke(refs.Frame, Color3.fromRGB(47,47,47), 0.16)

    refs.Header = make("Frame", {
        Parent = refs.Frame,
        BackgroundColor3 = STYLE.Colors.Header,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,44),
        ZIndex = 1004,
    })
    addCorner(refs.Header, 4)
    make("UIGradient", {
        Parent = refs.Header,
        Rotation = -90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(95,95,95)),
            ColorSequenceKeypoint.new(1, STYLE.Colors.White),
        }
    })
    local st = make("UIStroke", {
        Parent = refs.Header,
        Color = STYLE.Colors.PurpleA,
        Thickness = 1,
        ZIndex = 3,
    })
    make("UIGradient", {
        Parent = st,
        Rotation = -90,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(0.05,1),
            NumberSequenceKeypoint.new(1,1),
        }
    })

    refs.Title = makeLabel({
        Parent = refs.Frame,
        Name = "ConfirmTitle",
        Position = UDim2.new(0,14,0,10),
        Size = UDim2.new(1,-28,0,24),
        Text = "Are you sure?",
        TextSize = 17,
        ZIndex = 1005,
    })
    refs.Desc = makeLabel({
        Parent = refs.Frame,
        Name = "ConfirmDescription",
        Position = UDim2.new(0,14,0,58),
        Size = UDim2.new(1,-28,0,46),
        Text = "Are you sure you want to close the menu?",
        TextSize = 14,
        TextWrapped = true,
        ZIndex = 1005,
        TextColor3 = STYLE.Colors.GrayText,
        TextStrokeTransparency = 0.25,
    })

    local function confirmButton(text, x)
        local b = make("TextButton", {
            Parent = refs.Frame,
            BackgroundColor3 = STYLE.Colors.Header,
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(146, 32),
            Position = UDim2.new(0, x, 1, -44),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 1005,
        })
        addCorner(b, 4)
        make("UIGradient", {
            Parent = b,
            Rotation = 90,
            Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0,0),
                NumberSequenceKeypoint.new(1,0.75),
            }
        })
        addDoubleStroke(b, STYLE.Colors.Border, 0.5)
        makeHoverShade(b)
        makeLabel({
            Parent = b,
            Size = UDim2.new(1,0,1,0),
            Text = text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 1006,
        })
        return b
    end

    refs.Yes = confirmButton("Yes", 14)
    refs.No = confirmButton("No", 180)

    return refs
end

local function buildColorPickerModal(window)
    local refs = {}
    refs.Dark = make("TextButton", {
        Parent = window.Root.Overlay,
        Name = "ColorPickerOverlay",
        BackgroundColor3 = STYLE.Colors.Black,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,1,0),
        Text = "",
        Visible = false,
        ZIndex = 1010,
        AutoButtonColor = false,
    })
    refs.Frame = make("Frame", {
        Parent = refs.Dark,
        Name = "ColorPickerFrame",
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0,0.5,0),
        Size = UDim2.fromOffset(608, 417),
        BackgroundColor3 = STYLE.Colors.Main,
        BorderSizePixel = 0,
        Active = true,
        ZIndex = 1011,
    })
    addCorner(refs.Frame, 4)
    addMainGradient(refs.Frame, -90)
    addDoubleStroke(refs.Frame, Color3.fromRGB(47,47,47), 0.16)

    refs.Header = make("Frame", {
        Parent = refs.Frame,
        Name = "HeaderBg",
        BackgroundColor3 = STYLE.Colors.Header,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,0,0,50),
        ZIndex = 1012,
    })
    addCorner(refs.Header, 4)
    make("UIGradient", {
        Parent = refs.Header,
        Rotation = -90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(95,95,95)),
            ColorSequenceKeypoint.new(1, STYLE.Colors.White),
        }
    })
    local headerStroke = make("UIStroke", {
        Parent = refs.Header,
        Color = STYLE.Colors.PurpleA,
        Thickness = 1,
        ZIndex = 3,
    })
    make("UIGradient", {
        Parent = headerStroke,
        Rotation = -90,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(0.05,1),
            NumberSequenceKeypoint.new(1,1),
        }
    })
    addHeaderGlow(refs.Frame, 608)

    refs.Title = makeLabel({
        Parent = refs.Frame,
        Name = "Title",
        Position = UDim2.new(0,12,0,12),
        Size = UDim2.new(0,240,0,25),
        Text = "Color picker",
        TextSize = 18,
        ZIndex = 1013,
    })
    refs.Close = make("ImageButton", {
        Parent = refs.Frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1,-41,0,9),
        Size = UDim2.new(0,30,0,30),
        Image = STYLE.Images.Close,
        ImageTransparency = 0.6,
        AutoButtonColor = false,
        ZIndex = 1013,
    })

    refs.SV = make("Frame", {
        Parent = refs.Frame,
        Name = "SV",
        BackgroundColor3 = STYLE.Colors.White,
        BorderSizePixel = 0,
        Position = UDim2.new(0,22,0,84),
        Size = UDim2.fromOffset(219, 219),
        ZIndex = 1012,
        ClipsDescendants = true,
    })
    addCorner(refs.SV, 4)
    addDoubleStroke(refs.SV, Color3.fromRGB(65,65,65), 0.57)

    refs.SVHue = make("Frame", {
        Parent = refs.SV,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(255,0,0),
        Size = UDim2.new(1,0,1,0),
        ZIndex = 1012,
    })
    refs.SVWhite = make("Frame", {
        Parent = refs.SVHue,
        BorderSizePixel = 0,
        BackgroundColor3 = STYLE.Colors.White,
        Size = UDim2.new(1,0,1,0),
        ZIndex = 1012,
    })
    make("UIGradient", {
        Parent = refs.SVWhite,
        Rotation = 0,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(1,1),
        }
    })
    refs.SVBlack = make("Frame", {
        Parent = refs.SVHue,
        BorderSizePixel = 0,
        BackgroundColor3 = STYLE.Colors.Black,
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        ZIndex = 1013,
    })
    make("UIGradient", {
        Parent = refs.SVBlack,
        Rotation = 90,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,1),
            NumberSequenceKeypoint.new(1,0),
        }
    })

    refs.Dot = make("Frame", {
        Parent = refs.SV,
        Name = "Dot",
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromScale(1,0),
        Size = UDim2.fromOffset(10, 10),
        BackgroundColor3 = STYLE.Colors.White,
        BorderSizePixel = 0,
        ZIndex = 1015,
    })
    addCorner(refs.Dot, 999)
    make("UIGradient", {
        Parent = refs.Dot,
        Rotation = 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, STYLE.Colors.White),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(210,210,210)),
        }
    })
    make("UIStroke", {
        Parent = refs.Dot,
        Color = STYLE.Colors.Black,
        Thickness = 2,
        Transparency = 0.55,
        ZIndex = 2,
    })

    refs.Hue = make("Frame", {
        Parent = refs.Frame,
        Name = "Hue",
        BackgroundColor3 = Color3.fromRGB(209,209,209),
        BorderSizePixel = 0,
        Position = UDim2.new(0,267,0,84),
        Size = UDim2.fromOffset(19, 219),
        ZIndex = 1012,
    })
    addCorner(refs.Hue, 4)
    addDoubleStroke(refs.Hue, Color3.fromRGB(65,65,65), 0.57)
    make("UIGradient", {
        Parent = refs.Hue,
        Rotation = 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,0,255)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
        }
    })

    refs.HueLine = make("Frame", {
        Parent = refs.Hue,
        Name = "SelectLine",
        BackgroundColor3 = Color3.fromRGB(65,65,65),
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,0,0,1),
        ZIndex = 1014,
    })
    make("UIStroke", {
        Parent = refs.HueLine,
        Color = STYLE.Colors.Black,
        Thickness = 1.1,
        Transparency = 0.4,
        ZIndex = 1,
    })

    refs.Preview = make("Frame", {
        Parent = refs.Frame,
        Name = "CurrentColor",
        BackgroundColor3 = STYLE.Colors.White,
        BorderSizePixel = 0,
        Position = UDim2.new(0,306,0,138),
        Size = UDim2.fromOffset(54, 165),
        ZIndex = 1012,
    })
    addCorner(refs.Preview, 4)
    addDoubleStroke(refs.Preview, Color3.fromRGB(65,65,65), 0.57)

    refs.RecentText = makeLabel({
        Parent = refs.Frame,
        Position = UDim2.new(0,358,0,78),
        Size = UDim2.new(0,120,0,18),
        Text = "Recent:",
        TextSize = 12,
        TextColor3 = Color3.fromRGB(86,86,86),
        TextStrokeTransparency = 1,
        ZIndex = 1012,
    })
    refs.Recent = {}
    for i = 1, 5 do
        local swatch = make("TextButton", {
            Parent = refs.Frame,
            Name = "LastColor_" .. i,
            BackgroundColor3 = STYLE.Colors.White,
            BorderSizePixel = 0,
            Position = UDim2.new(0,358 + ((i - 1) * 46), 0, 110),
            Size = UDim2.fromOffset(31, 31),
            Text = "",
            Visible = false,
            AutoButtonColor = false,
            ZIndex = 1012,
        })
        addCorner(swatch, 4)
        make("UIGradient", {
            Parent = swatch,
            Rotation = -90,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(180,180,180)),
                ColorSequenceKeypoint.new(1, STYLE.Colors.White),
            }
        })
        addDoubleStroke(swatch, Color3.fromRGB(65,65,65), 0.57)
        refs.Recent[i] = swatch
    end

    local function actionButton(text, x, y, icon)
        local btn = make("TextButton", {
            Parent = refs.Frame,
            BackgroundColor3 = STYLE.Colors.Header,
            BorderSizePixel = 0,
            Position = UDim2.new(0, x, 0, y),
            Size = UDim2.fromOffset(104, 28),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 1012,
        })
        addCorner(btn, 4)
        make("UIGradient", {
            Parent = btn,
            Rotation = 90,
            Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0,0),
                NumberSequenceKeypoint.new(1,0.75),
            }
        })
        addDoubleStroke(btn, STYLE.Colors.Border, 0.5)
        makeHoverShade(btn)
        if icon then
            make("ImageLabel", {
                Parent = btn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0,8,0.5,-8),
                Size = UDim2.fromOffset(16,16),
                Image = icon,
                ImageTransparency = 0.3,
                ZIndex = 1013,
            })
        end
        makeLabel({
            Parent = btn,
            Position = UDim2.new(0, icon and 28 or 0, 0, 0),
            Size = UDim2.new(1, -(icon and 28 or 0), 1, 0),
            Text = text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 1013,
        })
        return btn
    end

    refs.Random = actionButton("Random", 358, 152, STYLE.Images.Random)
    refs.Reset = actionButton("Reset", 472, 152, STYLE.Images.Reset)
    refs.Back = actionButton("History -", 358, 186, nil)
    refs.Forward = actionButton("History +", 472, 186, nil)

    refs.Fields = {}
    local fieldNames = {"R", "G", "B", "H", "S", "V"}
    for i, key in ipairs(fieldNames) do
        local row = math.floor((i - 1) / 3)
        local col = (i - 1) % 3
        local holder = make("Frame", {
            Parent = refs.Frame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0,358 + (col * 82),0,236 + (row * 56)),
            Size = UDim2.fromOffset(74, 48),
            ZIndex = 1012,
        })
        makeLabel({
            Parent = holder,
            Position = UDim2.new(0,0,0,0),
            Size = UDim2.new(1,0,0,12),
            Text = key .. ":",
            TextSize = 12,
            TextColor3 = STYLE.Colors.GrayText,
            TextStrokeTransparency = 0.5,
            ZIndex = 1013,
        })
        local boxFrame = UIHelpers.RightField(holder, 74)
        boxFrame.Position = UDim2.new(0,0,0,18)
        local box = make("TextBox", {
            Parent = boxFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0),
            ClearTextOnFocus = false,
            Text = "0",
            Font = STYLE.Fonts.Main,
            TextColor3 = STYLE.Colors.White,
            TextSize = 12,
            PlaceholderText = "0",
            ZIndex = 1014,
        })
        refs.Fields[key] = box
    end

    return refs
end

local function buildDropdownPopup(window)
    local refs = {}
    refs.Root = make("TextButton", {
        Parent = window.Root.Overlay,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,1,0),
        Text = "",
        Visible = false,
        AutoButtonColor = false,
        ZIndex = 1020,
    })
    refs.Frame = make("Frame", {
        Parent = refs.Root,
        BackgroundColor3 = STYLE.Colors.Main,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.fromOffset(STYLE.Sizes.PopupWidth, 42),
        ClipsDescendants = true,
        Active = true,
        ZIndex = 1021,
    })
    addCorner(refs.Frame, 4)
    addMainGradient(refs.Frame, -90)
    addDoubleStroke(refs.Frame, Color3.fromRGB(47,47,47), 0.5)

    refs.Header = make("Frame", {
        Parent = refs.Frame,
        BackgroundColor3 = STYLE.Colors.Header,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,34),
        ZIndex = 1022,
    })
    addCorner(refs.Header, 4)
    make("UIGradient", {
        Parent = refs.Header,
        Rotation = -90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(95,95,95)),
            ColorSequenceKeypoint.new(1, STYLE.Colors.White),
        }
    })
    local hs = make("UIStroke", {
        Parent = refs.Header,
        Color = STYLE.Colors.PurpleA,
        Thickness = 1,
        ZIndex = 3,
    })
    make("UIGradient", {
        Parent = hs,
        Rotation = -90,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(0.05,1),
            NumberSequenceKeypoint.new(1,1),
        }
    })
    addHeaderGlow(refs.Frame, STYLE.Sizes.PopupWidth)
    refs.Title = makeLabel({
        Parent = refs.Frame,
        Position = UDim2.new(0,10,0,7),
        Size = UDim2.new(1,-20,0,20),
        Text = "Dropdown",
        TextSize = 15,
        ZIndex = 1023,
    })
    refs.Scroll = make("ScrollingFrame", {
        Parent = refs.Frame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0,38),
        Size = UDim2.new(1,0,1,-42),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarImageTransparency = 1,
        ScrollBarThickness = 0,
        ZIndex = 1022,
    })
    refs.List = make("UIListLayout", {
        Parent = refs.Scroll,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,4),
    })
    make("UIPadding", {
        Parent = refs.Scroll,
        PaddingLeft = UDim.new(0,8),
        PaddingRight = UDim.new(0,8),
        PaddingTop = UDim.new(0,4),
        PaddingBottom = UDim.new(0,6),
    })
    return refs
end

local function styleSection(sectionFrame, name)
    addCorner(sectionFrame, 4)
    make("UIGradient", {
        Parent = sectionFrame,
        Rotation = 90,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(1,0.831),
        }
    })
    make("UISizeConstraint", {
        Parent = sectionFrame,
        MinSize = Vector2.new(0,60),
    })
    local s1 = make("UIStroke", {
        Parent = sectionFrame,
        Color = STYLE.Colors.Black,
        Thickness = 1,
        Transparency = 0.14,
        ZIndex = 2,
    })
    local s2 = make("UIStroke", {
        Parent = sectionFrame,
        Color = STYLE.Colors.Border,
        Thickness = 2,
        ZIndex = 1,
    })
    make("UIGradient", {
        Parent = s2,
        Rotation = 90,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(1,0.444),
        }
    })

    local header = make("Frame", {
        Parent = sectionFrame,
        Name = "Header",
        BackgroundTransparency = 1,
        Size = UDim2.new(0,STYLE.Sizes.SectionWidth,0,35),
        ZIndex = 1,
    })
    make("UIListLayout", {
        Parent = header,
        Padding = UDim.new(0,7),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalFlex = Enum.UIFlexAlignment.Fill,
    })
    make("UIPadding", {
        Parent = header,
        PaddingTop = UDim.new(0,3),
    })
    local line = make("Frame", {
        Parent = header,
        Name = "Line",
        BackgroundColor3 = Color3.fromRGB(100,100,100),
        BorderSizePixel = 0,
        Size = UDim2.new(0,STYLE.Sizes.SectionWidth,0,1),
        LayoutOrder = 2,
        ZIndex = 1,
    })
    make("UIGradient", {
        Parent = line,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,1),
            NumberSequenceKeypoint.new(0.1,0.5),
            NumberSequenceKeypoint.new(0.9,0.5),
            NumberSequenceKeypoint.new(1,1),
        }
    })
    local title = makeLabel({
        Parent = header,
        Name = "SectionName",
        LayoutOrder = 1,
        Size = UDim2.new(0,215,0,25),
        Text = name,
        TextSize = 15,
        ZIndex = 1,
    })
    make("UIPadding", {
        Parent = title,
        PaddingLeft = UDim.new(0,7),
    })

    local holder = make("Frame", {
        Parent = sectionFrame,
        Name = "ButtonHolderFrame",
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(0,STYLE.Sizes.SectionWidth,0,0),
        ZIndex = 1,
    })
    make("UIListLayout", {
        Parent = holder,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    make("UIPadding", {
        Parent = holder,
        PaddingBottom = UDim.new(0,8),
        PaddingLeft = UDim.new(0,10),
        PaddingTop = UDim.new(0,43),
    })
    return {
        Header = header,
        ButtonHolder = holder,
        Title = title,
    }
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

local function applySearch(window, query)
    query = string.lower(query or "")
    for _, section in ipairs(window.Sections) do
        local anyVisible = false
        local sectionMatch = query == "" or string.find(string.lower(section.Name), query, 1, true) ~= nil
        for _, control in ipairs(section.Controls) do
            local text = string.lower(control.SearchText or "")
            local hit = query == "" or sectionMatch or string.find(text, query, 1, true) ~= nil
            control.Row.Visible = hit
            if hit then
                anyVisible = true
            end
        end
        section.Frame.Visible = anyVisible or query == ""
    end
end

function Window:Notify(opts)
    opts = opts or {}
    local title = opts.Title or "Notification"
    local desc = opts.Description or ""
    local duration = opts.Duration or 5

    local contentHeight = textSizeY(desc, 13, STYLE.Sizes.NotificationWidth - 20)
    local bodyHeight = math.max(88, contentHeight + 62)

    local root = make("Frame", {
        Parent = self.Root.Notifications,
        Name = "Notification_" .. randomName(),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(0, STYLE.Sizes.NotificationWidth, 0, bodyHeight),
        ZIndex = 2001,
        LayoutOrder = tick() * 1000,
    })

    local body = make("Frame", {
        Parent = root,
        BackgroundColor3 = STYLE.Colors.Main,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,0,0,bodyHeight),
        ZIndex = 2002,
    })
    addCorner(body, 4)
    addMainGradient(body, -90)
    addDoubleStroke(body, Color3.fromRGB(47,47,47), 0.5)

    local header = make("Frame", {
        Parent = body,
        BackgroundColor3 = STYLE.Colors.Header,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,34),
        ZIndex = 2003,
    })
    addCorner(header, 4)
    make("UIGradient", {
        Parent = header,
        Rotation = -90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(95,95,95)),
            ColorSequenceKeypoint.new(1, STYLE.Colors.White),
        }
    })
    local hs = make("UIStroke", {
        Parent = header,
        Color = STYLE.Colors.PurpleA,
        Thickness = 1,
        ZIndex = 3,
    })
    make("UIGradient", {
        Parent = hs,
        Rotation = -90,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(0.05,1),
            NumberSequenceKeypoint.new(1,1),
        }
    })
    addHeaderGlow(body, STYLE.Sizes.NotificationWidth)

    local dragLine = make("Frame", {
        Parent = body,
        Name = "DragLine",
        BackgroundColor3 = STYLE.Colors.PurpleA,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Position = UDim2.new(0,8,0,40),
        Size = UDim2.new(1,-16,0,2),
        ZIndex = 2003,
    })
    make("UIGradient", {
        Parent = dragLine,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,1),
            NumberSequenceKeypoint.new(0.1,0.3),
            NumberSequenceKeypoint.new(0.9,0.3),
            NumberSequenceKeypoint.new(1,1),
        }
    })

    local titleLabel = makeLabel({
        Parent = body,
        Position = UDim2.new(0,10,0,7),
        Size = UDim2.new(1,-74,0,20),
        Text = title,
        TextSize = 15,
        ZIndex = 2004,
    })

    local freezeBtn = make("ImageButton", {
        Parent = body,
        BackgroundTransparency = 1,
        Position = UDim2.new(1,-52,0,8),
        Size = UDim2.fromOffset(18,18),
        Image = STYLE.Images.Freeze,
        ImageTransparency = 0.4,
        AutoButtonColor = false,
        ZIndex = 2004,
    })
    local closeBtn = make("ImageButton", {
        Parent = body,
        BackgroundTransparency = 1,
        Position = UDim2.new(1,-28,0,8),
        Size = UDim2.fromOffset(18,18),
        Image = STYLE.Images.Close,
        ImageTransparency = 0.4,
        AutoButtonColor = false,
        ZIndex = 2004,
    })

    local descLabel = makeLabel({
        Parent = body,
        Position = UDim2.new(0,10,0,50),
        Size = UDim2.new(1,-20,0,contentHeight),
        Text = desc,
        TextSize = 13,
        TextColor3 = STYLE.Colors.GrayText,
        TextStrokeTransparency = 0.5,
        TextWrapped = true,
        ZIndex = 2004,
    })

    local moved = false
    local closed = false
    local frozen = false

    local api = {}

    local function vanish()
        if closed then return end
        closed = true
        fadeGuiObjectTree(body, 1, 0.18, false)
        task.delay(0.2, function()
            if root and root.Parent then
                root:Destroy()
            end
        end)
    end

    api.Close = vanish

    closeBtn.MouseButton1Click:Connect(vanish)
    freezeBtn.MouseButton1Click:Connect(function()
        frozen = not frozen
        play(freezeBtn, STYLE.Tween.Fast, {ImageTransparency = frozen and 0.05 or 0.4})
    end)

    root.Position = UDim2.new(1, STYLE.Sizes.NotificationWidth + 20, 0, 0)
    play(root, STYLE.Tween.Smooth, {Position = UDim2.new(0,0,0,0)})

    makeDrag(dragLine, body, {ClampedToScreen = true})
    dragLine.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            moved = true
        end
    end)

    task.spawn(function()
        local started = tick()
        while not closed and root.Parent do
            if not frozen and tick() - started >= duration then
                vanish()
                break
            end
            task.wait(0.05)
        end
    end)

    return api
end

function Window:OpenConfirm(onYes)
    self.Confirm.Dark.Visible = true
    self.Confirm.Dark.BackgroundTransparency = 1
    self.Confirm.Frame.BackgroundTransparency = 1
    local scale = self.Confirm.Frame:FindFirstChildOfClass("UIScale") or make("UIScale", {Parent = self.Confirm.Frame, Scale = 0.86})
    scale.Scale = 0.86
    play(self.Confirm.Dark, STYLE.Tween.ModalIn, {BackgroundTransparency = 0.4})
    play(scale, STYLE.Tween.ModalIn, {Scale = 1})
    play(self.Confirm.Frame, STYLE.Tween.ModalIn, {BackgroundTransparency = 0})

    safeDisconnect(self._confirmYes)
    safeDisconnect(self._confirmNo)
    self._confirmYes = self.Confirm.Yes.MouseButton1Click:Connect(function()
        self:CloseConfirm()
        if onYes then
            onYes()
        end
    end)
    self._confirmNo = self.Confirm.No.MouseButton1Click:Connect(function()
        self:CloseConfirm()
    end)
end

function Window:CloseConfirm()
    if not self.Confirm.Dark.Visible then return end
    local scale = self.Confirm.Frame:FindFirstChildOfClass("UIScale")
    play(self.Confirm.Dark, STYLE.Tween.ModalOut, {BackgroundTransparency = 1})
    if scale then
        play(scale, STYLE.Tween.ModalOut, {Scale = 0.86})
    end
    play(self.Confirm.Frame, STYLE.Tween.ModalOut, {BackgroundTransparency = 1})
    task.delay(0.18, function()
        if self.Confirm and self.Confirm.Dark then
            self.Confirm.Dark.Visible = false
        end
    end)
end

local function updateTabVisual(tab, active)
    local color = active and STYLE.Colors.PurpleA or STYLE.Colors.TabIdle
    play(tab.Label, STYLE.Tween.Fast, {TextColor3 = color, TextTransparency = active and 0 or 0.15})
end

function Window:SelectTab(tabObj)
    for _, tab in ipairs(self.Tabs) do
        local active = tab == tabObj
        tab.Scroll.Visible = active
        updateTabVisual(tab, active)
    end
    self.ActiveTab = tabObj
end

function Window:CreateCategory(name)
    if self.Categories[name] then
        return self.Categories[name]
    end
    local category = make("Frame", {
        Parent = self.TabsArea.Side,
        Name = name,
        BackgroundTransparency = 1,
        Size = UDim2.new(0,100,0,0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    make("UIListLayout", {
        Parent = category,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    local holder = make("Frame", {
        Parent = category,
        Name = "TabsHolder",
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1,0,0,0),
        LayoutOrder = 2,
    })
    make("UIListLayout", {
        Parent = holder,
    })
    make("UIPadding", {
        Parent = holder,
        PaddingLeft = UDim.new(0,15),
        PaddingTop = UDim.new(0,5),
    })
    makeLabel({
        Parent = category,
        BackgroundTransparency = 1,
        TextColor3 = STYLE.Colors.White,
        Size = UDim2.new(0,84,0,10),
        Font = STYLE.Fonts.Main,
        Text = name,
        TextSize = 15,
        TextTransparency = 0.7,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
    })
    self.Categories[name] = {
        Frame = category,
        Holder = holder,
    }
    return self.Categories[name]
end

function Window:CreateTab(name, categoryName)
    local category = self:CreateCategory(categoryName or "Main")

    local button = make("TextButton", {
        Parent = category.Holder,
        Name = name,
        BackgroundTransparency = 1,
        Size = UDim2.new(0,111,0,22),
        Font = STYLE.Fonts.Main,
        Text = "",
        TextSize = 15,
        AutoButtonColor = false,
    })
    local hoverShade = make("Frame", {
        Parent = button,
        BackgroundColor3 = STYLE.Colors.Black,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0,-6,0,-1),
        Size = UDim2.new(1,12,1,2),
        ZIndex = 1,
    })
    addCorner(hoverShade, 4)
    local label = makeLabel({
        Parent = button,
        Size = UDim2.new(1,0,1,0),
        Text = name,
        TextSize = 15,
        ZIndex = 2,
    })
    button.MouseEnter:Connect(function()
        if self.ActiveTab ~= nil and self.ActiveTab.Button ~= button then
            play(hoverShade, STYLE.Tween.Fast, {BackgroundTransparency = 0.9})
            play(label, STYLE.Tween.Fast, {TextColor3 = STYLE.Colors.TabHover})
        end
    end)
    button.MouseLeave:Connect(function()
        if self.ActiveTab ~= nil and self.ActiveTab.Button ~= button then
            play(hoverShade, STYLE.Tween.Fast, {BackgroundTransparency = 1})
            play(label, STYLE.Tween.Fast, {TextColor3 = STYLE.Colors.TabIdle})
        end
    end)

    local scroll = make("ScrollingFrame", {
        Parent = self.TabsArea.ContentFolder,
        Name = name .. "TabContent",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.241,0,0.101,0),
        Size = UDim2.new(0,581,0,435),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ScrollBarImageTransparency = 1,
        ScrollBarThickness = 0,
        VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
        Visible = false,
    })
    local left = make("Frame", {
        Parent = scroll,
        Name = "LeftColumn",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(0,285,0,0),
    })
    local right = make("Frame", {
        Parent = scroll,
        Name = "RightColumn",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.496,0,0,0),
        Size = UDim2.new(0,285,0,0),
    })
    make("UIListLayout", {Parent = left, Padding = UDim.new(0,10), SortOrder = Enum.SortOrder.LayoutOrder})
    make("UIListLayout", {Parent = right, Padding = UDim.new(0,10), SortOrder = Enum.SortOrder.LayoutOrder})
    make("UIPadding", {Parent = left, PaddingLeft = UDim.new(0,10), PaddingTop = UDim.new(0,10), PaddingBottom = UDim.new(0,10)})
    make("UIPadding", {Parent = right, PaddingLeft = UDim.new(0,10), PaddingTop = UDim.new(0,10), PaddingBottom = UDim.new(0,10)})

    local tab = setmetatable({
        Window = self,
        Name = name,
        Button = button,
        Label = label,
        HoverShade = hoverShade,
        Scroll = scroll,
        Left = left,
        Right = right,
        Sections = {},
    }, Tab)

    button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self.Tabs, tab)
    if not self.ActiveTab then
        self:SelectTab(tab)
    end
    return tab
end

function Tab:CreateSection(name, side)
    local parent = (string.lower(side or "left") == "right") and self.Right or self.Left
    local frame = make("Frame", {
        Parent = parent,
        Name = name,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = STYLE.Colors.Section,
        BorderSizePixel = 0,
        Size = UDim2.new(0,STYLE.Sizes.SectionWidth,0,0),
    })
    local pieces = styleSection(frame, name)

    local section = setmetatable({
        Tab = self,
        Window = self.Window,
        Name = name,
        Frame = frame,
        Header = pieces.Header,
        ButtonHolder = pieces.ButtonHolder,
        Controls = {},
    }, Section)

    table.insert(self.Sections, section)
    table.insert(self.Window.Sections, section)
    return section
end

local function registerControl(section, row, searchText)
    local data = {
        Row = row,
        SearchText = searchText,
    }
    table.insert(section.Controls, data)
    return data
end

function Section:CreateButton(opts)
    opts = opts or {}
    local row = UIHelpers.SectionBase(self, opts.Name or "Button")
    local button = row
    button.MouseButton1Click:Connect(function()
        if opts.Callback then
            opts.Callback()
        end
    end)
    registerControl(self, button, opts.Name or "Button")
    return {
        SetCallback = function(_, cb) opts.Callback = cb end
    }
end

function Section:CreateToggle(opts)
    opts = opts or {}
    local value = opts.Default == true
    local row, label = UIHelpers.SectionBase(self, opts.Name or "Toggle")

    local outer = make("Frame", {
        Parent = row,
        Name = "ToggleFrame",
        BackgroundColor3 = Color3.fromRGB(77,77,77),
        BorderSizePixel = 0,
        Position = UDim2.new(0.909,0,0.172,0),
        Size = UDim2.fromOffset(18,18),
        ZIndex = 1,
    })
    addCorner(outer, 1)
    make("UIGradient", {
        Parent = outer,
        Rotation = -90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(62,62,62)),
            ColorSequenceKeypoint.new(1, STYLE.Colors.White),
        }
    })
    addDoubleStroke(outer, Color3.fromRGB(54,54,54), 0.29)

    local active = make("Frame", {
        Parent = outer,
        Name = "Active",
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0,0.5,0),
        Size = UDim2.fromOffset(14,14),
        BackgroundColor3 = STYLE.Colors.White,
        BorderSizePixel = 0,
        Visible = false,
    })
    addCorner(active, 1)
    make("UIGradient", {
        Parent = active,
        Rotation = -90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(111,59,185)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(144,70,255)),
        }
    })
    make("UIStroke", {
        Parent = active,
        Color = STYLE.Colors.Black,
        Thickness = 1,
        Transparency = 0.46,
    })

    local api = {}
    local function apply(state, fire)
        value = state == true
        active.Visible = true
        play(active, STYLE.Tween.Fast, {BackgroundTransparency = value and 0 or 1})
        play(label, STYLE.Tween.Fast, {TextColor3 = value and STYLE.Colors.PurpleA or STYLE.Colors.White})
        if fire ~= false and opts.Callback then
            opts.Callback(value)
        end
    end
    function api:Set(state)
        apply(state, true)
    end
    function api:Get()
        return value
    end
    function api:SetCallback(cb)
        opts.Callback = cb
    end

    row.MouseButton1Click:Connect(function()
        api:Set(not value)
    end)
    registerControl(self, row, opts.Name or "Toggle")
    apply(value, false)
    return api
end

function Section:CreateTextbox(opts)
    opts = opts or {}
    local value = opts.Default or ""
    local row = UIHelpers.SectionBase(self, opts.Name or "Textbox")
    local holder = UIHelpers.RightField(row, 98)
    holder.Position = UDim2.new(0.622,0,0.17,0)

    local box = make("TextBox", {
        Parent = holder,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-8,1,0),
        Position = UDim2.new(0,4,0,0),
        Font = STYLE.Fonts.Main,
        TextColor3 = STYLE.Colors.White,
        PlaceholderColor3 = Color3.fromRGB(178,178,178),
        Text = value,
        TextStrokeColor3 = STYLE.Colors.Black,
        TextStrokeTransparency = 0.44,
        TextSize = 12,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    local api = {}
    function api:Set(text)
        value = tostring(text or "")
        box.Text = value
    end
    function api:Get()
        return value
    end
    function api:SetCallback(cb)
        opts.Callback = cb
    end

    box.FocusLost:Connect(function(enterPressed)
        value = box.Text
        if opts.Callback then
            opts.Callback(value, enterPressed)
        end
    end)

    registerControl(self, row, opts.Name or "Textbox")
    return api
end

function Section:CreateSlider(opts)
    opts = opts or {}
    local min = tonumber(opts.Min) or 0
    local max = tonumber(opts.Max) or 100
    local step = tonumber(opts.Step) or 1
    local value = clamp(tonumber(opts.Default) or min, min, max)

    local row, _ = UIHelpers.SectionBase(self, opts.Name or "Slider")
    local line = make("Frame", {
        Parent = row,
        Name = "SliderLine",
        BackgroundColor3 = STYLE.Colors.White,
        BorderSizePixel = 0,
        Position = UDim2.new(0.41,0,0.43,0),
        Size = UDim2.new(0,132,0,4),
        ZIndex = 1,
    })
    addCorner(line, 999)
    make("UIGradient", {
        Parent = line,
        Rotation = 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(95,95,95)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(38,38,38)),
        }
    })
    make("UIStroke", {
        Parent = line,
        Color = Color3.fromRGB(54,54,54),
        Thickness = 0.6,
    })

    local fill = make("Frame", {
        Parent = line,
        Name = "Fill",
        BackgroundColor3 = STYLE.Colors.PurpleA,
        BorderSizePixel = 0,
        Size = UDim2.new(0,0,1,0),
        ZIndex = 2,
    })
    addCorner(fill, 999)
    make("UIGradient", {
        Parent = fill,
        Rotation = 0,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, STYLE.Colors.PurpleA),
            ColorSequenceKeypoint.new(1, STYLE.Colors.PurpleB),
        }
    })

    local knob = make("Frame", {
        Parent = line,
        Name = "SliderKnob",
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0,0,0.5,0),
        Size = UDim2.fromOffset(11,11),
        BackgroundColor3 = STYLE.Colors.White,
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    addCorner(knob, 999)
    make("UIGradient", {
        Parent = knob,
        Rotation = -45,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(109,109,109)),
            ColorSequenceKeypoint.new(1, STYLE.Colors.White),
        }
    })
    make("UIStroke", {
        Parent = knob,
        Color = STYLE.Colors.Black,
        Thickness = 1,
        Transparency = 0.5,
    })

    local valueFrame = UIHelpers.RightField(row, 34)
    valueFrame.Position = UDim2.new(1,-34,0.17,0)
    local valueBox = make("TextBox", {
        Parent = valueFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        Font = STYLE.Fonts.Main,
        PlaceholderText = tostring(min),
        Text = "",
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextColor3 = STYLE.Colors.White,
        ClearTextOnFocus = false,
    })

    local dragging = false
    local api = {}

    local function render(fire)
        local alpha = (value - min) / math.max((max - min), 1e-4)
        fill.Size = UDim2.new(alpha,0,1,0)
        knob.Position = UDim2.new(alpha,0,0.5,0)
        valueBox.Text = tostring(value)
        if fire ~= false and opts.Callback then
            opts.Callback(value)
        end
    end

    function api:Set(v)
        v = roundToStep(clamp(tonumber(v) or min, min, max), step)
        value = v
        render(true)
    end
    function api:Get()
        return value
    end
    function api:SetCallback(cb)
        opts.Callback = cb
    end

    local function setFromX(x)
        local absPos = line.AbsolutePosition.X
        local absSize = line.AbsoluteSize.X
        local alpha = clamp((x - absPos) / math.max(absSize,1), 0, 1)
        api:Set(min + ((max - min) * alpha))
    end

    row.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setFromX(mouseLocation().X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromX(mouseLocation().X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    valueBox.FocusLost:Connect(function()
        api:Set(valueBox.Text)
    end)

    registerControl(self, row, opts.Name or "Slider")
    render(false)
    return api
end

function Section:CreateKeybind(opts)
    opts = opts or {}
    local value = opts.Default or Enum.KeyCode.Unknown
    local listening = false
    local row = UIHelpers.SectionBase(self, opts.Name or "Keybind")
    local frame = UIHelpers.RightField(row, 46)
    frame.Position = UDim2.new(0.81,0,0.17,0)
    local label = makeLabel({
        Parent = frame,
        Name = "KeybindText",
        Size = UDim2.new(1,0,1,0),
        Text = value ~= Enum.KeyCode.Unknown and value.Name or "",
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextColor3 = Color3.fromRGB(211,211,211),
        TextStrokeTransparency = 0.5,
        ZIndex = 2,
    })

    local api = {}
    local function apply(newKey, fire)
        value = newKey
        label.Text = newKey ~= Enum.KeyCode.Unknown and newKey.Name or ""
        if fire ~= false and opts.OnChanged then
            opts.OnChanged(value)
        end
    end
    function api:Set(newKey)
        apply(newKey, true)
    end
    function api:Get()
        return value
    end
    function api:SetCallback(cb)
        opts.Callback = cb
    end

    row.MouseButton1Click:Connect(function()
        listening = true
        label.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            api:Set(input.KeyCode)
            return
        end
        if not listening and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == value then
            if opts.Callback then
                opts.Callback(value)
            end
        end
    end)

    registerControl(self, row, opts.Name or "Keybind")
    apply(value, false)
    return api
end

function Section:CreateDropdown(opts)
    opts = opts or {}
    local row = UIHelpers.SectionBase(self, opts.Name or "Dropdown")
    local icon = make("ImageLabel", {
        Parent = row,
        Name = "SettingsImageLabel",
        Image = STYLE.Images.TripleDot,
        Position = UDim2.new(0.905,0,0.131,0),
        Size = UDim2.fromOffset(20,20),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ImageTransparency = 0.26,
        ImageColor3 = STYLE.Colors.White,
    })

    local multi = opts.Multi == true
    local maxHeight = opts.MaxHeight or 230
    local items = {}
    local selected = {}
    local api = {}

    local popup = self.Window.DropdownPopup
    local ownerId = HttpService:GenerateGUID(false)

    local function refreshOptionVisual(item)
        if not item.Row then return end
        local on = item.Type == "button" and false or selected[item.Id] == true
        play(item.Highlight, STYLE.Tween.Fast, {BackgroundTransparency = on and 0.84 or 1})
        play(item.Text, STYLE.Tween.Fast, {TextColor3 = on and STYLE.Colors.PurpleA or STYLE.Colors.White})
    end

    local function rebuild()
        for _, child in ipairs(popup.Scroll:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end
        for _, item in ipairs(items) do
            local btn = make("TextButton", {
                Parent = popup.Scroll,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1,0,0,26),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 1023,
            })
            item.Row = btn
            item.Highlight = make("Frame", {
                Parent = btn,
                BackgroundColor3 = STYLE.Colors.Black,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1,0,1,0),
                ZIndex = 1022,
            })
            addCorner(item.Highlight, 4)
            item.Text = makeLabel({
                Parent = btn,
                Position = UDim2.new(0,8,0,0),
                Size = UDim2.new(1,-16,1,0),
                Text = item.TextValue,
                TextSize = 13,
                ZIndex = 1024,
            })
            btn.MouseEnter:Connect(function()
                if item.Type == "button" or not selected[item.Id] then
                    play(item.Highlight, STYLE.Tween.Fast, {BackgroundTransparency = 0.9})
                end
            end)
            btn.MouseLeave:Connect(function()
                refreshOptionVisual(item)
            end)
            btn.MouseButton1Click:Connect(function()
                if item.Type == "button" then
                    if item.Callback then
                        item.Callback()
                    end
                    return
                end
                if multi then
                    selected[item.Id] = not selected[item.Id]
                else
                    selected = {}
                    selected[item.Id] = true
                end
                refreshOptionVisual(item)
                if item.Callback then
                    item.Callback(selected)
                end
                if opts.Callback then
                    opts.Callback(selected)
                end
            end)
            refreshOptionVisual(item)
        end
        local target = math.min(maxHeight, (#items * 30) + 46)
        popup.Frame.Size = UDim2.fromOffset(STYLE.Sizes.PopupWidth, target)
    end

    function api:AddOption(text, id, callback)
        table.insert(items, {
            Type = "option",
            TextValue = text,
            Id = id or string.lower(text):gsub("%s+", "_"),
            Callback = callback,
        })
        rebuild()
    end

    function api:AddButton(text, callback)
        table.insert(items, {
            Type = "button",
            TextValue = text,
            Callback = callback,
        })
        rebuild()
    end

    function api:Clear()
        items = {}
        selected = {}
        rebuild()
    end

    function api:GetSelected()
        return shallowCopy(selected)
    end

    function api:SetCallback(cb)
        opts.Callback = cb
    end

    function api:Open()
        local mouse = mouseLocation()
        local pos = row.AbsolutePosition
        popup.OwnerId = ownerId
        popup.Root.Visible = true
        popup.Title.Text = opts.Title or (opts.Name or "Dropdown")
        popup.Frame.Size = UDim2.fromOffset(STYLE.Sizes.PopupWidth, 40)
        popup.Frame.Position = UDim2.new(0, mouse.X + 12, 0, pos.Y)
        rebuild()
        local target = popup.Frame.Size.Y.Offset
        popup.Frame.ClipsDescendants = true
        popup.Frame.Size = UDim2.fromOffset(STYLE.Sizes.PopupWidth, 34)
        play(popup.Frame, STYLE.Tween.Smooth, {Size = UDim2.fromOffset(STYLE.Sizes.PopupWidth, target)})
    end

    function api:Close()
        if popup.OwnerId ~= ownerId then return end
        local sizeY = popup.Frame.Size.Y.Offset
        play(popup.Frame, STYLE.Tween.ModalOut, {Size = UDim2.fromOffset(STYLE.Sizes.PopupWidth, 34)})
        task.delay(0.18, function()
            if popup.OwnerId == ownerId then
                popup.Root.Visible = false
            end
        end)
    end

    row.MouseButton1Click:Connect(function()
        api:Open()
    end)

    self.Window.DropdownHandlers[ownerId] = api
    registerControl(self, row, opts.Name or "Dropdown")
    return api
end

function Section:CreateColorPicker(opts)
    opts = opts or {}
    local color = opts.Default or STYLE.Colors.PurpleA
    local history = {color}
    local historyIndex = 1
    local row = UIHelpers.SectionBase(self, opts.Name or "Color Picker")
    local preview = make("Frame", {
        Parent = row,
        Name = "ColorPreview",
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Position = UDim2.new(0.741,0,0.185,0),
        Size = UDim2.fromOffset(62,17),
        ZIndex = 1,
    })
    addCorner(preview, 4)
    make("UIGradient", {
        Parent = preview,
        Rotation = -90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(103,103,103)),
            ColorSequenceKeypoint.new(1, STYLE.Colors.White),
        }
    })
    addDoubleStroke(preview, STYLE.Colors.BorderSoft, 0.43)

    local picker = self.Window.ColorPicker
    local svConn, hueConn
    local hue, sat, val = Color3.toHSV(color)
    local active = false
    local api = {}

    local function pushHistory(col)
        if historyIndex < #history then
            for i = #history, historyIndex + 1, -1 do
                table.remove(history, i)
            end
        end
        table.insert(history, col)
        historyIndex = #history
        while #history > 20 do
            table.remove(history, 1)
            historyIndex = historyIndex - 1
        end
    end

    local function refreshRecent()
        local recent = {}
        for i = #history, math.max(1, #history - 4), -1 do
            table.insert(recent, history[i])
        end
        for i = 1, 5 do
            local sw = picker.Recent[i]
            local c = recent[i]
            sw.Visible = c ~= nil
            if c then
                sw.BackgroundColor3 = c
            end
        end
    end

    local function syncFields()
        local r, g, b = colorToRGB(color)
        picker.Fields.R.Text = tostring(r)
        picker.Fields.G.Text = tostring(g)
        picker.Fields.B.Text = tostring(b)
        picker.Fields.H.Text = tostring(math.floor(hue * 360 + 0.5))
        picker.Fields.S.Text = tostring(math.floor(sat * 100 + 0.5))
        picker.Fields.V.Text = tostring(math.floor(val * 100 + 0.5))
    end

    local function render(fire)
        color = Color3.fromHSV(hue, sat, val)
        preview.BackgroundColor3 = color
        picker.Preview.BackgroundColor3 = color
        picker.SVHue.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        picker.Dot.Position = UDim2.fromScale(sat, 1 - val)
        picker.HueLine.Position = UDim2.new(0,0,hue,0)
        syncFields()
        if fire ~= false and opts.Callback then
            opts.Callback(color)
        end
    end

    local function applyColor(newColor, saveHistory, fire)
        hue, sat, val = Color3.toHSV(newColor)
        color = newColor
        render(fire)
        if saveHistory ~= false then
            pushHistory(color)
            refreshRecent()
        end
    end

    function api:Set(newColor)
        applyColor(newColor, true, true)
    end
    function api:Get()
        return color
    end
    function api:SetCallback(cb)
        opts.Callback = cb
    end
    function api:Open()
        active = true
        picker.Owner = api
        picker.Dark.Visible = true
        centerModalOpen(picker.Frame)
        picker.Dark.BackgroundTransparency = 1
        play(picker.Dark, STYLE.Tween.ModalIn, {BackgroundTransparency = 0.4})
        render(false)
        refreshRecent()
    end
    function api:Close()
        if picker.Owner ~= api then return end
        active = false
        play(picker.Dark, STYLE.Tween.ModalOut, {BackgroundTransparency = 1})
        centerModalClose(picker.Frame)
        task.delay(0.18, function()
            if picker.Owner == api then
                picker.Dark.Visible = false
            end
        end)
    end

    local function setSVFromMouse()
        local p = mouseLocation()
        local absPos = picker.SV.AbsolutePosition
        local absSize = picker.SV.AbsoluteSize
        sat = clamp((p.X - absPos.X) / math.max(absSize.X,1), 0, 1)
        val = 1 - clamp((p.Y - absPos.Y) / math.max(absSize.Y,1), 0, 1)
        render(true)
    end

    local function setHueFromMouse()
        local p = mouseLocation()
        local absPos = picker.Hue.AbsolutePosition
        local absSize = picker.Hue.AbsoluteSize
        hue = clamp((p.Y - absPos.Y) / math.max(absSize.Y,1), 0, 1)
        render(true)
    end

    picker.Close.MouseButton1Click:Connect(function()
        if picker.Owner == api then
            api:Close()
        end
    end)

    picker.Dark.MouseButton1Click:Connect(function(x, y)
        if picker.Owner ~= api then return end
        local pos = picker.Frame.AbsolutePosition
        local size = picker.Frame.AbsoluteSize
        if x >= pos.X and x <= pos.X + size.X and y >= pos.Y and y <= pos.Y + size.Y then
            return
        end
        api:Close()
    end)

    picker.SV.InputBegan:Connect(function(input)
        if picker.Owner ~= api then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setSVFromMouse()
            safeDisconnect(svConn)
            svConn = UserInputService.InputChanged:Connect(function(changed)
                if changed.UserInputType == Enum.UserInputType.MouseMovement then
                    setSVFromMouse()
                end
            end)
        end
    end)
    picker.Hue.InputBegan:Connect(function(input)
        if picker.Owner ~= api then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setHueFromMouse()
            safeDisconnect(hueConn)
            hueConn = UserInputService.InputChanged:Connect(function(changed)
                if changed.UserInputType == Enum.UserInputType.MouseMovement then
                    setHueFromMouse()
                end
            end)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            safeDisconnect(svConn)
            safeDisconnect(hueConn)
            if active then
                pushHistory(color)
                refreshRecent()
            end
        end
    end)

    picker.Random.MouseButton1Click:Connect(function()
        if picker.Owner ~= api then return end
        api:Set(Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255)))
    end)
    picker.Reset.MouseButton1Click:Connect(function()
        if picker.Owner ~= api then return end
        api:Set(opts.Default or STYLE.Colors.PurpleA)
    end)
    picker.Back.MouseButton1Click:Connect(function()
        if picker.Owner ~= api then return end
        historyIndex = clamp(historyIndex - 1, 1, #history)
        applyColor(history[historyIndex], false, true)
    end)
    picker.Forward.MouseButton1Click:Connect(function()
        if picker.Owner ~= api then return end
        historyIndex = clamp(historyIndex + 1, 1, #history)
        applyColor(history[historyIndex], false, true)
    end)
    for i, sw in ipairs(picker.Recent) do
        sw.MouseButton1Click:Connect(function()
            if picker.Owner ~= api then return end
            applyColor(sw.BackgroundColor3, true, true)
        end)
    end

    local fieldMap = {
        R = function(v)
            local _, g, b = colorToRGB(color)
            api:Set(Color3.fromRGB(clamp(v,0,255), g, b))
        end,
        G = function(v)
            local r, _, b = colorToRGB(color)
            api:Set(Color3.fromRGB(r, clamp(v,0,255), b))
        end,
        B = function(v)
            local r, g = colorToRGB(color)
            api:Set(Color3.fromRGB(r, g, clamp(v,0,255)))
        end,
        H = function(v)
            hue = clamp(v / 360, 0, 1); render(true)
        end,
        S = function(v)
            sat = clamp(v / 100, 0, 1); render(true)
        end,
        V = function(v)
            val = clamp(v / 100, 0, 1); render(true)
        end,
    }
    for key, box in pairs(picker.Fields) do
        box.FocusLost:Connect(function()
            if picker.Owner ~= api then return end
            local num = tonumber(box.Text)
            if num then
                fieldMap[key](num)
                pushHistory(color)
                refreshRecent()
            else
                syncFields()
            end
        end)
    end

    row.MouseButton1Click:Connect(function()
        api:Open()
    end)

    registerControl(self, row, opts.Name or "Color Picker")
    render(false)
    refreshRecent()
    return api
end

function Window:Destroy()
    if self.Root and self.Root.Gui then
        self.Root.Gui:Destroy()
    end
end

function Amphibia.new(config)
    config = config or {}
    local self = setmetatable({}, Window)
    self.Config = {
        Title = config.Title or STYLE.Title,
        Icon = config.Icon or STYLE.Icon,
        Parent = config.Parent or CoreGui,
    }
    self.Root = buildRoot(self.Config.Parent)
    self.Header = buildHeader(self)
    self.TabsArea = buildTabsArea(self)
    self.Confirm = buildConfirm(self)
    self.ColorPicker = buildColorPickerModal(self)
    self.DropdownPopup = buildDropdownPopup(self)
    self.Categories = {}
    self.Tabs = {}
    self.Sections = {}
    self.ActiveTab = nil
    self.DropdownHandlers = {}

    self.Header.Close.MouseButton1Click:Connect(function()
        self:OpenConfirm(function()
            self:Destroy()
        end)
    end)
    self.Header.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        applySearch(self, self.Header.SearchBox.Text)
    end)

    makeDrag(self.Header.Header, self.Root.Main, {ClampedToScreen = true})
    makeDrag(self.ColorPicker.Header, self.ColorPicker.Frame, {ClampedToScreen = true})

    self.DropdownPopup.Root.MouseButton1Click:Connect(function(x, y)
        local pos = self.DropdownPopup.Frame.AbsolutePosition
        local size = self.DropdownPopup.Frame.AbsoluteSize
        if x >= pos.X and x <= pos.X + size.X and y >= pos.Y and y <= pos.Y + size.Y then
            return
        end
        self.DropdownPopup.Root.Visible = false
    end)

    return self
end

Amphibia.CreateWindow = Amphibia.new

return Amphibia
