local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Clean up existing menu
local existing = CoreGui:FindFirstChild("RoseMenu")
if existing then
    existing:Destroy()
end

-- Menu Theme & Configuration
local Library = {
    Connections = {},
    Theme = {
        Background = Color3.fromRGB(25, 25, 25), -- Slightly lighter for inner content
        OuterBg = Color3.fromRGB(15, 15, 15), -- The padded gap background
        Black = Color3.fromRGB(0, 0, 0),
        Grey = Color3.fromRGB(45, 45, 45),
        DropdownBg = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(255, 0, 0),
        Text = Color3.fromRGB(220, 220, 220),
        TextDim = Color3.fromRGB(130, 130, 130),
        Font = Enum.Font.Code,
        TextSize = 13
    }
}

function Library:Unload()
    for _, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    if self.MainGui then
        self.MainGui:Destroy()
    end
end

-- Helper for standard Black -> Grey -> Background borders
local function CreateBorderBox(parent)
    local BlackOuter = Instance.new("Frame", parent)
    BlackOuter.BackgroundColor3 = Library.Theme.Black
    BlackOuter.BorderSizePixel = 0
    BlackOuter.Size = UDim2.new(1, 0, 1, 0)
    
    local GreyInner = Instance.new("Frame", BlackOuter)
    GreyInner.BackgroundColor3 = Library.Theme.Grey
    GreyInner.BorderSizePixel = 0
    GreyInner.Position = UDim2.new(0, 1, 0, 1)
    GreyInner.Size = UDim2.new(1, -2, 1, -2)
    
    local Bg = Instance.new("Frame", GreyInner)
    Bg.BackgroundColor3 = Library.Theme.Background
    Bg.BorderSizePixel = 0
    Bg.Position = UDim2.new(0, 1, 0, 1)
    Bg.Size = UDim2.new(1, -2, 1, -2)
    
    return BlackOuter, Bg, GreyInner
end

-- Helper for creating text with strokes
local function CreateTextLabel(parent, text, color, xAlignment)
    local Label = Instance.new("TextLabel", parent)
    Label.BackgroundTransparency = 1
    Label.Font = Library.Theme.Font
    Label.Text = text
    Label.TextColor3 = color or Library.Theme.Text
    Label.TextSize = Library.Theme.TextSize
    Label.TextStrokeColor3 = Library.Theme.Black
    Label.TextStrokeTransparency = 0 -- IMPORTANT: Black outline from screenshot!
    Label.TextXAlignment = xAlignment or Enum.TextXAlignment.Left
    return Label
end

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RoseMenu"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Library.MainGui = ScreenGui

    -- 1. Outer Border Hierarchy (Grey -> Black -> Gap -> Black -> Grey -> Content)
    local OuterGrey = Instance.new("Frame", ScreenGui)
    OuterGrey.Name = "OuterFrame"
    OuterGrey.BackgroundColor3 = self.Theme.Grey
    OuterGrey.BorderSizePixel = 0
    OuterGrey.Position = UDim2.new(0.5, -275, 0.5, -175)
    OuterGrey.Size = UDim2.new(0, 550, 0, 350)
    OuterGrey.Active = true

    local OuterBlack = Instance.new("Frame", OuterGrey)
    OuterBlack.BackgroundColor3 = self.Theme.Black
    OuterBlack.BorderSizePixel = 0
    OuterBlack.Position = UDim2.new(0, 1, 0, 1)
    OuterBlack.Size = UDim2.new(1, -2, 1, -2)

    local OuterGap = Instance.new("Frame", OuterBlack)
    OuterGap.BackgroundColor3 = self.Theme.OuterBg
    OuterGap.BorderSizePixel = 0
    OuterGap.Position = UDim2.new(0, 1, 0, 1)
    OuterGap.Size = UDim2.new(1, -2, 1, -2)

    local InnerBlack = Instance.new("Frame", OuterGap)
    InnerBlack.BackgroundColor3 = self.Theme.Black
    InnerBlack.BorderSizePixel = 0
    InnerBlack.Position = UDim2.new(0, 4, 0, 4)
    InnerBlack.Size = UDim2.new(1, -8, 1, -8)

    local InnerGrey = Instance.new("Frame", InnerBlack)
    InnerGrey.BackgroundColor3 = self.Theme.Grey
    InnerGrey.BorderSizePixel = 0
    InnerGrey.Position = UDim2.new(0, 1, 0, 1)
    InnerGrey.Size = UDim2.new(1, -2, 1, -2)

    local MainFrame = Instance.new("Frame", InnerGrey)
    MainFrame.BackgroundColor3 = self.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0, 1, 0, 1)
    MainFrame.Size = UDim2.new(1, -2, 1, -2)

    -- Draggable Logic
    local dragging, dragInput, dragStart, startPos
    OuterGrey.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = OuterGrey.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    OuterGrey.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    table.insert(Library.Connections, RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            OuterGrey.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    -- Keybinds
    table.insert(Library.Connections, UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            OuterGrey.Visible = not OuterGrey.Visible
            UserInputService.MouseIconEnabled = OuterGrey.Visible
        elseif input.KeyCode == Enum.KeyCode.End then
            Library:Unload()
        end
    end))

    -- 2. Title Section
    local TitleArea = Instance.new("Frame", MainFrame)
    TitleArea.BackgroundTransparency = 1
    TitleArea.Size = UDim2.new(1, 0, 0, 25)

    local TitleText = CreateTextLabel(TitleArea, '<font color="#ffffff">r o </font><font color="#ff0000">s e</font>', self.Theme.Text, Enum.TextXAlignment.Center)
    TitleText.Size = UDim2.new(1, 0, 1, 0)
    TitleText.RichText = true

    -- Gradient Red Line
    local RedLineBox = Instance.new("Frame", MainFrame)
    RedLineBox.BackgroundColor3 = self.Theme.Accent
    RedLineBox.BorderSizePixel = 0
    RedLineBox.Position = UDim2.new(0, 10, 0, 24)
    RedLineBox.Size = UDim2.new(1, -20, 0, 1)
    
    local Gradient = Instance.new("UIGradient", RedLineBox)
    Gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1)
    })

    -- 3. Tabs Box
    local TabsOuter, TabsBg, TabsInner = CreateBorderBox(MainFrame)
    TabsOuter.Position = UDim2.new(0, 10, 0, 32)
    TabsOuter.Size = UDim2.new(1, -20, 0, 26)

    local TabBarLayout = Instance.new("UIListLayout", TabsBg)
    TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
    TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local Window = {
        Tabs = {},
        CurrentTab = nil
    }

    function Window:CreateTab(name)
        local TabButtonWrapper = Instance.new("Frame", TabsBg)
        TabButtonWrapper.BackgroundColor3 = Library.Theme.Background
        TabButtonWrapper.BorderSizePixel = 0
        TabButtonWrapper.Size = UDim2.new(1/6, 0, 1, 0) -- 6 tabs evenly spaced

        local TabButton = Instance.new("TextButton", TabButtonWrapper)
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(1, -1, 1, 0) -- -1 for separator
        TabButton.Font = Library.Theme.Font
        TabButton.Text = name
        TabButton.TextColor3 = Library.Theme.TextDim
        TabButton.TextSize = Library.Theme.TextSize
        TabButton.TextStrokeTransparency = 0
        TabButton.TextStrokeColor3 = Library.Theme.Black

        -- Vertical separator (Black + Grey line)
        local SepBlack = Instance.new("Frame", TabButtonWrapper)
        SepBlack.BackgroundColor3 = Library.Theme.Black
        SepBlack.BorderSizePixel = 0
        SepBlack.Position = UDim2.new(1, -2, 0, 0)
        SepBlack.Size = UDim2.new(0, 1, 1, 0)
        
        local SepGrey = Instance.new("Frame", TabButtonWrapper)
        SepGrey.BackgroundColor3 = Library.Theme.Grey
        SepGrey.BorderSizePixel = 0
        SepGrey.Position = UDim2.new(1, -1, 0, 0)
        SepGrey.Size = UDim2.new(0, 1, 1, 0)

        local TabContent = Instance.new("Frame", MainFrame)
        TabContent.BackgroundTransparency = 1
        TabContent.Position = UDim2.new(0, 10, 0, 66)
        TabContent.Size = UDim2.new(1, -20, 1, -76)
        TabContent.Visible = false

        -- Left and Right Columns for Content (Cards)
        local LeftBoxOuter, LeftBoxBg, _ = CreateBorderBox(TabContent)
        LeftBoxOuter.Size = UDim2.new(0.5, -4, 1, 0)
        
        local RightBoxOuter, RightBoxBg, _ = CreateBorderBox(TabContent)
        RightBoxOuter.Position = UDim2.new(0.5, 4, 0, 0)
        RightBoxOuter.Size = UDim2.new(0.5, -4, 1, 0)

        local Tab = {
            Button = TabButton,
            Content = TabContent,
            Left = LeftBoxBg,
            Right = RightBoxBg
        }
        table.insert(Window.Tabs, Tab)

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Button.TextColor3 = Library.Theme.TextDim
                t.Content.Visible = false
            end
            TabButton.TextColor3 = Library.Theme.Accent
            TabContent.Visible = true
        end)

        if #Window.Tabs == 1 then
            TabButton.TextColor3 = Library.Theme.Accent
            TabContent.Visible = true
        end

        function Tab:CreateGroup(title, side)
            local ParentCol = side == "right" and Tab.Right or Tab.Left
            
            local GroupTop = Instance.new("Frame", ParentCol)
            GroupTop.BackgroundTransparency = 1
            GroupTop.Size = UDim2.new(1, 0, 0, 22)
            
            local GroupTitle = CreateTextLabel(GroupTop, title, Library.Theme.Text, Enum.TextXAlignment.Left)
            GroupTitle.Position = UDim2.new(0, 6, 0, 0)
            GroupTitle.Size = UDim2.new(1, -12, 1, 0)
            
            local LineBlack = Instance.new("Frame", GroupTop)
            LineBlack.BackgroundColor3 = Library.Theme.Black
            LineBlack.BorderSizePixel = 0
            LineBlack.Position = UDim2.new(0, 0, 1, -1)
            LineBlack.Size = UDim2.new(1, 0, 0, 1)

            local LineGrey = Instance.new("Frame", GroupTop)
            LineGrey.BackgroundColor3 = Library.Theme.Grey
            LineGrey.BorderSizePixel = 0
            LineGrey.Position = UDim2.new(0, 0, 1, 0)
            LineGrey.Size = UDim2.new(1, 0, 0, 1)

            local Container = Instance.new("Frame", ParentCol)
            Container.BackgroundTransparency = 1
            Container.Position = UDim2.new(0, 0, 0, 26)
            Container.Size = UDim2.new(1, 0, 1, -26)
            
            local UIListLayout = Instance.new("UIListLayout", Container)
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Padding = UDim.new(0, 6)
            
            local UIPadding = Instance.new("UIPadding", Container)
            UIPadding.PaddingLeft = UDim.new(0, 8)
            UIPadding.PaddingRight = UDim.new(0, 8)

            local Group = {Container = Container}
            
            function Group:CreateCheckbox(text, default, callback)
                local Frame = Instance.new("Frame", Group.Container)
                Frame.BackgroundTransparency = 1
                Frame.Size = UDim2.new(1, 0, 0, 12)
                
                local BoxOuter, BoxBg, _ = CreateBorderBox(Frame)
                BoxOuter.Size = UDim2.new(0, 12, 0, 12)
                
                local Fill = Instance.new("Frame", BoxBg)
                Fill.BackgroundColor3 = Library.Theme.Accent
                Fill.BorderSizePixel = 0
                Fill.Size = UDim2.new(1, 0, 1, 0)
                Fill.Visible = default or false
                
                local Button = Instance.new("TextButton", Frame)
                Button.BackgroundTransparency = 1
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.Text = ""
                
                local Label = CreateTextLabel(Frame, text, Library.Theme.Text, Enum.TextXAlignment.Left)
                Label.Position = UDim2.new(0, 20, 0, -1)
                Label.Size = UDim2.new(1, -20, 1, 0)
                
                local toggled = default or false
                Button.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    Fill.Visible = toggled
                    if callback then callback(toggled) end
                end)
                
                local Checkbox = { Frame = Frame }
                
                function Checkbox:AddPlus()
                    local Plus = CreateTextLabel(Frame, "+", Library.Theme.Text, Enum.TextXAlignment.Right)
                    Plus.Size = UDim2.new(1, 0, 1, 0)
                end

                function Checkbox:AddColorPicker(defaultColor, colCallback)
                    local ColorBoxOuter, ColorBoxBg, _ = CreateBorderBox(Frame)
                    ColorBoxOuter.Size = UDim2.new(0, 16, 0, 10)
                    ColorBoxOuter.Position = UDim2.new(1, -16, 0.5, -5)
                    ColorBoxBg.BackgroundColor3 = defaultColor or Color3.fromRGB(255, 0, 0)
                    
                    local ColorBtn = Instance.new("TextButton", ColorBoxOuter)
                    ColorBtn.BackgroundTransparency = 1
                    ColorBtn.Size = UDim2.new(1, 0, 1, 0)
                    ColorBtn.Text = ""

                    -- Color Picker Popup
                    local PickerOuter = Instance.new("Frame", Library.MainGui)
                    PickerOuter.BackgroundColor3 = Library.Theme.Black
                    PickerOuter.BorderSizePixel = 0
                    PickerOuter.Size = UDim2.new(0, 150, 0, 150)
                    PickerOuter.Visible = false
                    PickerOuter.ZIndex = 20

                    local PickerInner = Instance.new("Frame", PickerOuter)
                    PickerInner.BackgroundColor3 = Library.Theme.Grey
                    PickerInner.BorderSizePixel = 0
                    PickerInner.Position = UDim2.new(0, 1, 0, 1)
                    PickerInner.Size = UDim2.new(1, -2, 1, -2)
                    PickerInner.ZIndex = 20

                    local PickerBg = Instance.new("Frame", PickerInner)
                    PickerBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    PickerBg.BorderSizePixel = 0
                    PickerBg.Position = UDim2.new(0, 1, 0, 1)
                    PickerBg.Size = UDim2.new(1, -2, 1, -2)
                    PickerBg.ZIndex = 20

                    -- Rainbow Gradient
                    local Rainbow = Instance.new("UIGradient", PickerBg)
                    Rainbow.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    })

                    -- White to Transparent
                    local Overlay1 = Instance.new("Frame", PickerBg)
                    Overlay1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Overlay1.BorderSizePixel = 0
                    Overlay1.Size = UDim2.new(1, 0, 1, 0)
                    Overlay1.ZIndex = 21
                    
                    local Grad1 = Instance.new("UIGradient", Overlay1)
                    Grad1.Rotation = 90
                    Grad1.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(0.5, 1),
                        NumberSequenceKeypoint.new(1, 1)
                    })

                    -- Transparent to Black
                    local Overlay2 = Instance.new("Frame", PickerBg)
                    Overlay2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    Overlay2.BorderSizePixel = 0
                    Overlay2.Size = UDim2.new(1, 0, 1, 0)
                    Overlay2.ZIndex = 22
                    
                    local Grad2 = Instance.new("UIGradient", Overlay2)
                    Grad2.Rotation = 90
                    Grad2.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(0.5, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    })

                    local CfgBtn = Instance.new("TextButton", PickerBg)
                    CfgBtn.BackgroundTransparency = 1
                    CfgBtn.Size = UDim2.new(1, 0, 1, 0)
                    CfgBtn.Text = ""
                    CfgBtn.ZIndex = 23

                    -- Cursor
                    local Cursor = Instance.new("Frame", PickerBg)
                    Cursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Cursor.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    Cursor.BorderSizePixel = 1
                    Cursor.Size = UDim2.new(0, 4, 0, 4)
                    Cursor.ZIndex = 24
                    Cursor.Position = UDim2.new(0.5, -2, 0.5, -2)

                    local currentColor = ColorBoxBg.BackgroundColor3

                    local function updateCursorFromColor(color)
                        local h, s, v = color:ToHSV()
                        local x = h
                        local y = 0
                        if s < 1 then
                            y = s / 2
                        elseif v < 1 then
                            y = 0.5 + (1 - v) / 2
                        else
                            y = 0.5
                        end
                        Cursor.Position = UDim2.new(x, -2, y, -2)
                    end
                    updateCursorFromColor(currentColor)

                    local dragging = false
                    CfgBtn.MouseButton1Down:Connect(function() dragging = true end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                    end)
                    
                    local GuiService = game:GetService("GuiService")
                    
                    table.insert(Library.Connections, RunService.RenderStepped:Connect(function()
                        if dragging and PickerOuter.Visible then
                            local mousePos = UserInputService:GetMouseLocation()
                            local guiInset = GuiService:GetGuiInset()
                            local mouseX = mousePos.X - guiInset.X
                            local mouseY = mousePos.Y - guiInset.Y
                            
                            local rectPos = PickerBg.AbsolutePosition
                            local rectSize = PickerBg.AbsoluteSize
                            local x = math.clamp((mouseX - rectPos.X) / rectSize.X, 0, 1)
                            local y = math.clamp((mouseY - rectPos.Y) / rectSize.Y, 0, 1)
                            
                            Cursor.Position = UDim2.new(x, -2, y, -2)
                            
                            local h = x
                            local s, v
                            if y <= 0.5 then
                                s = y * 2
                                v = 1
                            else
                                s = 1
                                v = 1 - (y - 0.5) * 2
                            end
                            
                            currentColor = Color3.fromHSV(h, s, v)
                            ColorBoxBg.BackgroundColor3 = currentColor
                            if colCallback then colCallback(currentColor) end
                        end
                    end))

                    ColorBtn.MouseButton1Click:Connect(function()
                        PickerOuter.Visible = not PickerOuter.Visible
                        if PickerOuter.Visible then
                            PickerOuter.Position = UDim2.new(0, ColorBoxOuter.AbsolutePosition.X + 25, 0, ColorBoxOuter.AbsolutePosition.Y)
                        end
                    end)

                    table.insert(Library.Connections, RunService.RenderStepped:Connect(function()
                        if PickerOuter.Visible then
                            PickerOuter.Position = UDim2.new(0, ColorBoxOuter.AbsolutePosition.X + 25, 0, ColorBoxOuter.AbsolutePosition.Y)
                        end
                    end))
                end

                function Checkbox:AddKeybind(defaultKey, kbCallback)
                    local KbLabel = CreateTextLabel(Frame, "[" .. (defaultKey and defaultKey.Name or "None") .. "]", Library.Theme.TextDim, Enum.TextXAlignment.Right)
                    KbLabel.Size = UDim2.new(1, 0, 1, 0)
                    
                    local Btn = Instance.new("TextButton", Frame)
                    Btn.BackgroundTransparency = 1
                    Btn.Size = UDim2.new(0, 40, 1, 0)
                    Btn.Position = UDim2.new(1, -40, 0, 0)
                    Btn.Text = ""

                    local listening = false
                    Btn.MouseButton1Click:Connect(function()
                        listening = true
                        KbLabel.Text = "[...]"
                        KbLabel.TextColor3 = Library.Theme.Accent
                    end)

                    table.insert(Library.Connections, UserInputService.InputBegan:Connect(function(input, gp)
                        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                            listening = false
                            local key = input.KeyCode
                            if key == Enum.KeyCode.Escape then
                                KbLabel.Text = "[None]"
                                KbLabel.TextColor3 = Library.Theme.TextDim
                                if kbCallback then kbCallback(nil) end
                            else
                                KbLabel.Text = "[" .. key.Name .. "]"
                                KbLabel.TextColor3 = Library.Theme.TextDim
                                if kbCallback then kbCallback(key) end
                            end
                        end
                    end))
                end

                return Checkbox
            end
            
            function Group:CreateDropdown(text, options, currentOpt, callback)
                local Frame = Instance.new("Frame", Group.Container)
                Frame.BackgroundTransparency = 1
                Frame.Size = UDim2.new(1, 0, 0, 36)
                
                local Label = CreateTextLabel(Frame, text, Library.Theme.Text, Enum.TextXAlignment.Left)
                Label.Size = UDim2.new(1, 0, 0, 14)
                
                local BoxOuter, BoxBg, _ = CreateBorderBox(Frame)
                BoxOuter.Position = UDim2.new(0, 0, 0, 16)
                BoxOuter.Size = UDim2.new(1, 0, 0, 20)
                BoxBg.BackgroundColor3 = Library.Theme.DropdownBg
                
                local ValueLabel = CreateTextLabel(BoxBg, currentOpt, Library.Theme.Text, Enum.TextXAlignment.Left)
                ValueLabel.Position = UDim2.new(0, 6, 0, 0)
                ValueLabel.Size = UDim2.new(1, -12, 1, 0)

                local Plus = CreateTextLabel(BoxBg, "+", Library.Theme.Text, Enum.TextXAlignment.Right)
                Plus.Position = UDim2.new(0, -6, 0, 0)
                Plus.Size = UDim2.new(1, 0, 1, 0)
                
                local Button = Instance.new("TextButton", BoxBg)
                Button.BackgroundTransparency = 1
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.Text = ""
                
                -- Dropdown List
                local ListOuter = Instance.new("Frame", Library.MainGui)
                ListOuter.BackgroundColor3 = Library.Theme.Black
                ListOuter.BorderSizePixel = 0
                ListOuter.Visible = false
                ListOuter.ZIndex = 10
                
                local ListInner = Instance.new("Frame", ListOuter)
                ListInner.BackgroundColor3 = Library.Theme.Grey
                ListInner.BorderSizePixel = 0
                ListInner.Position = UDim2.new(0, 1, 0, 1)
                ListInner.Size = UDim2.new(1, -2, 1, -2)
                ListInner.ZIndex = 10

                local ListBg = Instance.new("Frame", ListInner)
                ListBg.BackgroundColor3 = Library.Theme.DropdownBg
                ListBg.BorderSizePixel = 0
                ListBg.Position = UDim2.new(0, 1, 0, 1)
                ListBg.Size = UDim2.new(1, -2, 1, -2)
                ListBg.ZIndex = 10

                local ListLayout = Instance.new("UIListLayout", ListBg)
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                
                for _, opt in pairs(options) do
                    local OptBtn = Instance.new("TextButton", ListBg)
                    OptBtn.BackgroundColor3 = Library.Theme.DropdownBg
                    OptBtn.BorderSizePixel = 0
                    OptBtn.Size = UDim2.new(1, 0, 0, 20)
                    OptBtn.Font = Library.Theme.Font
                    OptBtn.Text = "  " .. opt
                    OptBtn.TextColor3 = Library.Theme.Text
                    OptBtn.TextSize = Library.Theme.TextSize
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    OptBtn.TextStrokeTransparency = 0
                    OptBtn.TextStrokeColor3 = Library.Theme.Black
                    OptBtn.ZIndex = 11
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        ValueLabel.Text = opt
                        ListOuter.Visible = false
                        Plus.Text = "+"
                        if callback then callback(opt) end
                    end)
                    
                    OptBtn.MouseEnter:Connect(function() OptBtn.TextColor3 = Library.Theme.Accent end)
                    OptBtn.MouseLeave:Connect(function() OptBtn.TextColor3 = Library.Theme.Text end)
                end
                
                Button.MouseButton1Click:Connect(function()
                    local open = not ListOuter.Visible
                    ListOuter.Visible = open
                    Plus.Text = open and "-" or "+"
                    if open then
                        ListOuter.Size = UDim2.new(0, BoxOuter.AbsoluteSize.X, 0, #options * 20 + 4)
                        ListOuter.Position = UDim2.new(0, BoxOuter.AbsolutePosition.X, 0, BoxOuter.AbsolutePosition.Y + 22)
                    end
                end)
                
                -- Update position if dragging
                table.insert(Library.Connections, RunService.RenderStepped:Connect(function()
                    if ListOuter.Visible then
                        ListOuter.Position = UDim2.new(0, BoxOuter.AbsolutePosition.X, 0, BoxOuter.AbsolutePosition.Y + 22)
                    end
                end))
            end

            return Group
        end
        
        return Tab
    end

    return Window
end

return Library
