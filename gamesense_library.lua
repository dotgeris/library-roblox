local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Library = {
    Connections = {},
    Theme = {
        Accent = Color3.fromRGB(150, 255, 0), -- Lime Green
        Background = Color3.fromRGB(15, 15, 15),
        TabBg = Color3.fromRGB(10, 10, 10),
        Border = Color3.fromRGB(40, 40, 40),
        WidgetBg = Color3.fromRGB(25, 25, 25),
        Text = Color3.fromRGB(200, 200, 200),
        TextDim = Color3.fromRGB(130, 130, 130),
        Font = Enum.Font.Code,
        TextSize = 13
    }
}

function Library:Unload()
    for _, v in pairs(self.Connections) do
        v:Disconnect()
    end
    self.Connections = {}
    if self.MainGui then
        self.MainGui:Destroy()
    end
end

local function CreateTextLabel(parent, text, color, align)
    local Label = Instance.new("TextLabel", parent)
    Label.BackgroundTransparency = 1
    Label.Font = Library.Theme.Font
    Label.TextSize = Library.Theme.TextSize
    Label.TextColor3 = color
    Label.Text = text
    Label.TextXAlignment = align or Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Center
    Label.TextStrokeTransparency = 1
    return Label
end

function Library:CreateWindow(title)
    if self.MainGui then self.MainGui:Destroy() end
    
    local MainGui = Instance.new("ScreenGui", CoreGui)
    MainGui.Name = "SkeetUI"
    MainGui.ResetOnSpawn = false
    self.MainGui = MainGui

    -- Main Window
    local OuterBorder = Instance.new("Frame", MainGui)
    OuterBorder.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    OuterBorder.BorderColor3 = Color3.fromRGB(30, 30, 30)
    OuterBorder.BorderSizePixel = 1
    OuterBorder.Position = UDim2.new(0.5, -330, 0.5, -300)
    OuterBorder.Size = UDim2.new(0, 660, 0, 600)

    local MainBg = Instance.new("Frame", OuterBorder)
    MainBg.BackgroundColor3 = Library.Theme.Background
    MainBg.BorderColor3 = Color3.fromRGB(40, 40, 40)
    MainBg.BorderSizePixel = 1
    MainBg.Position = UDim2.new(0, 1, 0, 1)
    MainBg.Size = UDim2.new(1, -2, 1, -2)

    -- Left Tab Bar
    local TabBar = Instance.new("Frame", MainBg)
    TabBar.BackgroundColor3 = Library.Theme.TabBg
    TabBar.BorderColor3 = Library.Theme.Border
    TabBar.BorderSizePixel = 1
    TabBar.Position = UDim2.new(0, 0, 0, 0)
    TabBar.Size = UDim2.new(0, 60, 1, 0)

    local TabContainer = Instance.new("Frame", TabBar)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 0, 0, 20)
    TabContainer.Size = UDim2.new(1, 0, 1, -20)

    local TabsList = Instance.new("UIListLayout", TabContainer)
    TabsList.SortOrder = Enum.SortOrder.LayoutOrder
    TabsList.Padding = UDim.new(0, 5)

    -- Content Area
    local ContentArea = Instance.new("Frame", MainBg)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 61, 0, 0)
    ContentArea.Size = UDim2.new(1, -61, 1, 0)

    -- Rainbow Top Line
    local RainbowLine = Instance.new("Frame", ContentArea)
    RainbowLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    RainbowLine.BorderSizePixel = 0
    RainbowLine.Size = UDim2.new(1, 0, 0, 2)
    
    local UIGrad = Instance.new("UIGradient", RainbowLine)
    UIGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 255, 0))
    })

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    OuterBorder.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = OuterBorder.Position
        end
    end)
    OuterBorder.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            OuterBorder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Insert then MainGui.Enabled = not MainGui.Enabled end
        if input.KeyCode == Enum.KeyCode.End then self:Unload() end
    end))

    local Window = {
        Tabs = {},
        CurrentTab = nil
    }

    function Window:CreateTab(iconText)
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Size = UDim2.new(1, 0, 0, 50)
        TabBtn.Text = ""

        local Icon = Instance.new("ImageLabel", TabBtn)
        Icon.BackgroundTransparency = 1
        Icon.Size = UDim2.new(0, 36, 0, 36)
        Icon.Position = UDim2.new(0.5, -18, 0.5, -18)
        Icon.Image = iconText -- will be the rbxassetid
        Icon.ImageColor3 = Library.Theme.TextDim

        local ActiveLine = Instance.new("Frame", TabBtn)
        ActiveLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ActiveLine.BorderSizePixel = 0
        ActiveLine.Size = UDim2.new(0, 2, 1, 0)
        ActiveLine.Visible = false

        local TabContent = Instance.new("Frame", ContentArea)
        TabContent.BackgroundTransparency = 1
        TabContent.Position = UDim2.new(0, 15, 0, 15)
        TabContent.Size = UDim2.new(1, -30, 1, -30)
        TabContent.Visible = false

        local LeftCol = Instance.new("Frame", TabContent)
        LeftCol.BackgroundTransparency = 1
        LeftCol.Size = UDim2.new(0.5, -5, 1, 0)
        local LeftList = Instance.new("UIListLayout", LeftCol)
        LeftList.SortOrder = Enum.SortOrder.LayoutOrder
        LeftList.Padding = UDim.new(0, 15)

        local RightCol = Instance.new("Frame", TabContent)
        RightCol.BackgroundTransparency = 1
        RightCol.Size = UDim2.new(0.5, -5, 1, 0)
        RightCol.Position = UDim2.new(0.5, 5, 0, 0)
        local RightList = Instance.new("UIListLayout", RightCol)
        RightList.SortOrder = Enum.SortOrder.LayoutOrder
        RightList.Padding = UDim.new(0, 15)

        local Tab = {
            Button = TabBtn,
            Content = TabContent,
            Left = LeftCol,
            Right = RightCol,
            Icon = Icon,
            ActiveLine = ActiveLine
        }

        table.insert(self.Tabs, Tab)

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(self.Tabs) do
                t.Icon.ImageColor3 = Library.Theme.TextDim
                t.ActiveLine.Visible = false
                t.Content.Visible = false
            end
            Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            ActiveLine.Visible = true
            TabContent.Visible = true
            self.CurrentTab = Tab
        end)

        if #self.Tabs == 1 then
            Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            ActiveLine.Visible = true
            TabContent.Visible = true
            self.CurrentTab = Tab
        end

        function Tab:CreateGroup(groupName, side)
            local targetCol = side == "left" and self.Left or self.Right
            
            local GroupOuter = Instance.new("Frame", targetCol)
            GroupOuter.BackgroundTransparency = 1
            GroupOuter.Size = UDim2.new(1, 0, 0, 20)
            
            local GroupBox = Instance.new("Frame", GroupOuter)
            GroupBox.BackgroundColor3 = Library.Theme.Background
            GroupBox.BorderColor3 = Library.Theme.Border
            GroupBox.BorderSizePixel = 1
            GroupBox.Position = UDim2.new(0, 0, 0, 8)
            GroupBox.Size = UDim2.new(1, 0, 1, -8)

            local GroupTitle = CreateTextLabel(GroupOuter, " " .. groupName .. " ", Color3.fromRGB(255, 255, 255), Enum.TextXAlignment.Left)
            GroupTitle.BackgroundColor3 = Library.Theme.Background
            GroupTitle.BackgroundTransparency = 0 -- Opaque background to mask border
            GroupTitle.BorderSizePixel = 0
            GroupTitle.Font = Enum.Font.Code
            GroupTitle.Position = UDim2.new(0, 12, 0, 0)
            GroupTitle.AutomaticSize = Enum.AutomaticSize.X
            GroupTitle.Size = UDim2.new(0, 0, 0, 16)

            local ItemsContainer = Instance.new("Frame", GroupBox)
            ItemsContainer.BackgroundTransparency = 1
            ItemsContainer.Position = UDim2.new(0, 15, 0, 15)
            ItemsContainer.Size = UDim2.new(1, -30, 1, -25)

            local ItemList = Instance.new("UIListLayout", ItemsContainer)
            ItemList.SortOrder = Enum.SortOrder.LayoutOrder
            ItemList.Padding = UDim.new(0, 8)

            ItemList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                GroupOuter.Size = UDim2.new(1, 0, 0, ItemList.AbsoluteContentSize.Y + 35)
            end)

            local Group = {}

            function Group:CreateCheckbox(text, default, callback)
                local Frame = Instance.new("Frame", ItemsContainer)
                Frame.BackgroundTransparency = 1
                Frame.Size = UDim2.new(1, 0, 0, 14)
                
                local BoxOuter = Instance.new("Frame", Frame)
                BoxOuter.BackgroundColor3 = Library.Theme.Background
                BoxOuter.BorderColor3 = Library.Theme.Border
                BoxOuter.BorderSizePixel = 1
                BoxOuter.Size = UDim2.new(0, 10, 0, 10)
                BoxOuter.Position = UDim2.new(0, 0, 0.5, -5)
                
                local Fill = Instance.new("Frame", BoxOuter)
                Fill.BackgroundColor3 = Library.Theme.Accent
                Fill.BorderSizePixel = 0
                Fill.Position = UDim2.new(0, 1, 0, 1)
                Fill.Size = UDim2.new(1, -2, 1, -2)
                Fill.Visible = default or false
                
                local Label = CreateTextLabel(Frame, text, Library.Theme.Text, Enum.TextXAlignment.Left)
                Label.Position = UDim2.new(0, 20, 0, 0)
                Label.Size = UDim2.new(1, -20, 1, 0)
                
                local Btn = Instance.new("TextButton", Frame)
                Btn.BackgroundTransparency = 1
                Btn.Size = UDim2.new(1, -30, 1, 0) -- Leave space on right for keybinds
                Btn.Text = ""

                local toggled = default or false
                Btn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    Fill.Visible = toggled
                    if callback then callback(toggled) end
                end)
                
                local Checkbox = { Frame = Frame, Toggle = function(state) toggled = state Fill.Visible = toggled if callback then callback(toggled) end end }
                
                function Checkbox:AddKeybind(defaultKey, kbCallback)
                    local KbLabel = CreateTextLabel(Frame, "[-]", Library.Theme.TextDim, Enum.TextXAlignment.Right)
                    KbLabel.Size = UDim2.new(1, 0, 1, 0)
                    if defaultKey then KbLabel.Text = "[" .. defaultKey.Name .. "]" end
                    
                    local KBtn = Instance.new("TextButton", Frame)
                    KBtn.BackgroundTransparency = 1
                    KBtn.Position = UDim2.new(1, -30, 0, 0)
                    KBtn.Size = UDim2.new(0, 30, 1, 0)
                    KBtn.Text = ""

                    local listening = false
                    KBtn.MouseButton1Click:Connect(function()
                        listening = true
                        KbLabel.Text = "[...]"
                        KbLabel.TextColor3 = Library.Theme.Accent
                    end)

                    table.insert(Library.Connections, UserInputService.InputBegan:Connect(function(input, gp)
                        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                            listening = false
                            local key = input.KeyCode
                            if key == Enum.KeyCode.Escape then
                                KbLabel.Text = "[-]"
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

            function Group:CreateDropdown(text, options, default, callback)
                local Frame = Instance.new("Frame", ItemsContainer)
                Frame.BackgroundTransparency = 1
                Frame.Size = UDim2.new(1, 0, 0, 38)
                
                local Label = CreateTextLabel(Frame, text, Library.Theme.Text, Enum.TextXAlignment.Left)
                Label.Size = UDim2.new(1, 0, 0, 14)
                
                local BoxOuter = Instance.new("Frame", Frame)
                BoxOuter.BackgroundColor3 = Library.Theme.WidgetBg
                BoxOuter.BorderColor3 = Library.Theme.Border
                BoxOuter.BorderSizePixel = 1
                BoxOuter.Size = UDim2.new(1, 0, 0, 18)
                BoxOuter.Position = UDim2.new(0, 0, 0, 18)
                
                local SelectedLabel = CreateTextLabel(BoxOuter, default or options[1] or "", Library.Theme.Text, Enum.TextXAlignment.Left)
                SelectedLabel.Position = UDim2.new(0, 8, 0, 0)
                SelectedLabel.Size = UDim2.new(1, -20, 1, 0)
                
                local Arrow = CreateTextLabel(BoxOuter, "▼", Library.Theme.TextDim, Enum.TextXAlignment.Right)
                Arrow.Position = UDim2.new(1, -8, 0, 0)
                Arrow.Size = UDim2.new(0, 10, 1, 0)
                
                local Btn = Instance.new("TextButton", BoxOuter)
                Btn.BackgroundTransparency = 1
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.Text = ""
                
                -- Floating List
                local ListOuter = Instance.new("Frame", MainGui)
                ListOuter.BackgroundColor3 = Library.Theme.WidgetBg
                ListOuter.BorderColor3 = Library.Theme.Border
                ListOuter.BorderSizePixel = 1
                ListOuter.Size = UDim2.new(0, BoxOuter.AbsoluteSize.X, 0, #options * 18 + 2)
                ListOuter.Visible = false
                ListOuter.ZIndex = 10
                
                local ListLayout = Instance.new("UIListLayout", ListOuter)
                ListLayout.Padding = UDim.new(0, 0)
                
                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton", ListOuter)
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Size = UDim2.new(1, 0, 0, 18)
                    OptBtn.Font = Library.Theme.Font
                    OptBtn.TextSize = Library.Theme.TextSize
                    OptBtn.TextColor3 = Library.Theme.TextDim
                    OptBtn.Text = "  " .. opt
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    OptBtn.ZIndex = 11
                    
                    OptBtn.MouseEnter:Connect(function() OptBtn.TextColor3 = Library.Theme.Accent end)
                    OptBtn.MouseLeave:Connect(function() OptBtn.TextColor3 = Library.Theme.TextDim end)
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        SelectedLabel.Text = opt
                        ListOuter.Visible = false
                        if callback then callback(opt) end
                    end)
                end
                
                Btn.MouseButton1Click:Connect(function()
                    ListOuter.Visible = not ListOuter.Visible
                    ListOuter.Size = UDim2.new(0, BoxOuter.AbsoluteSize.X, 0, #options * 18)
                end)
                
                table.insert(Library.Connections, RunService.RenderStepped:Connect(function()
                    if ListOuter.Visible then
                        ListOuter.Position = UDim2.new(0, BoxOuter.AbsolutePosition.X, 0, BoxOuter.AbsolutePosition.Y + 20)
                    end
                end))
            end

            function Group:CreateSlider(text, min, max, default, symbol, callback)
                local Frame = Instance.new("Frame", ItemsContainer)
                Frame.BackgroundTransparency = 1
                Frame.Size = UDim2.new(1, 0, 0, 30)
                
                local Label = CreateTextLabel(Frame, text, Library.Theme.Text, Enum.TextXAlignment.Left)
                Label.Size = UDim2.new(1, 0, 0, 14)
                
                local SliderTrack = Instance.new("Frame", Frame)
                SliderTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                SliderTrack.BorderSizePixel = 0
                SliderTrack.Size = UDim2.new(1, 0, 0, 4)
                SliderTrack.Position = UDim2.new(0, 0, 0, 20)
                
                local SliderFill = Instance.new("Frame", SliderTrack)
                SliderFill.BackgroundColor3 = Library.Theme.Accent
                SliderFill.BorderSizePixel = 0
                SliderFill.Size = UDim2.new(0, 0, 1, 0)
                
                local ValueLabel = CreateTextLabel(Frame, tostring(default) .. (symbol or ""), Library.Theme.Text, Enum.TextXAlignment.Center)
                ValueLabel.Size = UDim2.new(1, 0, 0, 14)
                ValueLabel.Position = UDim2.new(0, 0, 0, 15) -- Overlays the track visually
                
                local Btn = Instance.new("TextButton", Frame)
                Btn.BackgroundTransparency = 1
                Btn.Size = UDim2.new(1, 0, 0, 16)
                Btn.Position = UDim2.new(0, 0, 0, 14)
                Btn.Text = ""

                local currentVal = default or min
                local dragging = false
                
                local function updateSlider(mouseX)
                    local w = SliderTrack.AbsoluteSize.X
                    local pct = math.clamp((mouseX - SliderTrack.AbsolutePosition.X) / w, 0, 1)
                    local val = math.floor(min + (max - min) * pct + 0.5)
                    
                    SliderFill.Size = UDim2.new(pct, 0, 1, 0)
                    ValueLabel.Text = tostring(val) .. (symbol or "")
                    currentVal = val
                    if callback then callback(val) end
                end
                
                SliderFill.Size = UDim2.new((currentVal - min)/(max - min), 0, 1, 0)
                ValueLabel.Text = tostring(currentVal) .. (symbol or "")
                
                Btn.MouseButton1Down:Connect(function()
                    dragging = true
                    updateSlider(UserInputService:GetMouseLocation().X)
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                table.insert(Library.Connections, RunService.RenderStepped:Connect(function()
                    if dragging then updateSlider(UserInputService:GetMouseLocation().X) end
                end))
            end

            return Group
        end
        return Tab
    end
    return Window
end

return Library
