local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Library = {
    Connections = {},
    Windows = {},
    Theme = {
        Accent = Color3.fromRGB(138, 180, 248), -- Sky Blue
        Background = Color3.fromRGB(22, 22, 22),
        WidgetBg = Color3.fromRGB(35, 35, 35),
        Border = Color3.fromRGB(10, 10, 10),
        Text = Color3.fromRGB(220, 220, 220),
        TextDark = Color3.fromRGB(20, 20, 20),
        TextDim = Color3.fromRGB(140, 140, 140),
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
    return Label
end

function Library:CreateWindow(title, size, position)
    if not self.MainGui then
        local MainGui = Instance.new("ScreenGui", CoreGui)
        MainGui.Name = "Style4UI"
        MainGui.ResetOnSpawn = false
        self.MainGui = MainGui

        table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.Insert then MainGui.Enabled = not MainGui.Enabled end
            if input.KeyCode == Enum.KeyCode.End then self:Unload() end
        end))
    end
    
    local WindowFrame = Instance.new("Frame", self.MainGui)
    WindowFrame.BackgroundColor3 = Library.Theme.Background
    WindowFrame.BorderColor3 = Library.Theme.Border
    WindowFrame.BorderSizePixel = 1
    WindowFrame.Position = position or UDim2.new(0.5, -250, 0.5, -200)
    WindowFrame.Size = size or UDim2.new(0, 500, 0, 400)
    WindowFrame.Active = true

    local LeftLine = Instance.new("Frame", WindowFrame)
    LeftLine.BackgroundColor3 = Library.Theme.Accent
    LeftLine.BorderSizePixel = 0
    LeftLine.Position = UDim2.new(0, 0, 0, 0)
    LeftLine.Size = UDim2.new(0, 2, 1, 0)

    local TopBar = Instance.new("Frame", WindowFrame)
    TopBar.BackgroundTransparency = 1
    TopBar.Position = UDim2.new(0, 5, 0, 0)
    TopBar.Size = UDim2.new(1, -5, 0, 20)
    
    if title then
        local TitleLabel = CreateTextLabel(TopBar, title, Library.Theme.Text, Enum.TextXAlignment.Left)
        TitleLabel.Size = UDim2.new(1, -10, 1, 0)
    end

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = WindowFrame.Position
            WindowFrame.ZIndex = 10 -- Bring to front
        end
    end)
    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            WindowFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    local Window = {
        Frame = WindowFrame,
        Tabs = {},
        CurrentTab = nil
    }

    if not title then
        -- This is a window that just needs to hold tabs (like the main window)
        local TabContainer = Instance.new("Frame", WindowFrame)
        TabContainer.BackgroundColor3 = Library.Theme.Border
        TabContainer.BorderSizePixel = 0
        TabContainer.Position = UDim2.new(0, 5, 0, 5)
        TabContainer.Size = UDim2.new(1, -10, 0, 22)
        
        local TabsLayout = Instance.new("UIListLayout", TabContainer)
        TabsLayout.FillDirection = Enum.FillDirection.Horizontal
        TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabsLayout.Padding = UDim.new(0, 1)

        local SubTabContainer = Instance.new("Frame", WindowFrame)
        SubTabContainer.BackgroundColor3 = Library.Theme.Border
        SubTabContainer.BorderSizePixel = 0
        SubTabContainer.Position = UDim2.new(0, 5, 0, 28)
        SubTabContainer.Size = UDim2.new(1, -10, 0, 22)
        SubTabContainer.Visible = false

        local SubTabsLayout = Instance.new("UIListLayout", SubTabContainer)
        SubTabsLayout.FillDirection = Enum.FillDirection.Horizontal
        SubTabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SubTabsLayout.Padding = UDim.new(0, 1)

        local ContentArea = Instance.new("Frame", WindowFrame)
        ContentArea.BackgroundTransparency = 1
        ContentArea.Position = UDim2.new(0, 5, 0, 55)
        ContentArea.Size = UDim2.new(1, -10, 1, -60)

        function Window:CreateTab(name)
            local TabBtn = Instance.new("TextButton", TabContainer)
            TabBtn.BackgroundColor3 = Library.Theme.WidgetBg
            TabBtn.BorderSizePixel = 0
            TabBtn.Size = UDim2.new(0, 80, 1, 0)
            TabBtn.Font = Library.Theme.Font
            TabBtn.TextSize = Library.Theme.TextSize
            TabBtn.TextColor3 = Library.Theme.Text
            TabBtn.Text = name

            local Tab = {
                Button = TabBtn,
                SubTabs = {},
                CurrentSubTab = nil,
                TabContentArea = Instance.new("Frame", ContentArea)
            }
            Tab.TabContentArea.BackgroundTransparency = 1
            Tab.TabContentArea.Size = UDim2.new(1, 0, 1, 0)
            Tab.TabContentArea.Visible = false

            table.insert(self.Tabs, Tab)

            TabBtn.MouseButton1Click:Connect(function()
                for _, t in pairs(self.Tabs) do
                    t.Button.BackgroundColor3 = Library.Theme.WidgetBg
                    t.Button.TextColor3 = Library.Theme.Text
                    t.TabContentArea.Visible = false
                    for _, st in pairs(t.SubTabs) do
                        st.Button.Visible = false
                    end
                end
                TabBtn.BackgroundColor3 = Library.Theme.Accent
                TabBtn.TextColor3 = Library.Theme.TextDark
                Tab.TabContentArea.Visible = true
                self.CurrentTab = Tab

                SubTabContainer.Visible = #Tab.SubTabs > 0
                for _, st in pairs(Tab.SubTabs) do
                    st.Button.Visible = true
                end
                if Tab.CurrentSubTab then
                    Tab.CurrentSubTab.Content.Visible = true
                end
            end)

            function Tab:CreateSubTab(subName)
                local SubBtn = Instance.new("TextButton", SubTabContainer)
                SubBtn.BackgroundColor3 = Library.Theme.WidgetBg
                SubBtn.BorderSizePixel = 0
                SubBtn.Size = UDim2.new(0, 80, 1, 0)
                SubBtn.Font = Library.Theme.Font
                SubBtn.TextSize = Library.Theme.TextSize
                SubBtn.TextColor3 = Library.Theme.Text
                SubBtn.Text = subName
                SubBtn.Visible = false

                local SubContent = Instance.new("Frame", self.TabContentArea)
                SubContent.BackgroundTransparency = 1
                SubContent.Size = UDim2.new(1, 0, 1, 0)
                SubContent.Visible = false

                local LeftCol = Instance.new("Frame", SubContent)
                LeftCol.BackgroundTransparency = 1
                LeftCol.BorderColor3 = Library.Theme.Border
                LeftCol.BorderSizePixel = 1
                LeftCol.Size = UDim2.new(0.5, -2, 1, 0)
                LeftCol.Position = UDim2.new(0, 0, 0, 0)
                local LeftList = Instance.new("UIListLayout", LeftCol)
                LeftList.SortOrder = Enum.SortOrder.LayoutOrder
                LeftList.Padding = UDim.new(0, 6)
                local LeftPad = Instance.new("UIPadding", LeftCol)
                LeftPad.PaddingLeft = UDim.new(0, 5) LeftPad.PaddingRight = UDim.new(0, 5) LeftPad.PaddingTop = UDim.new(0, 5)

                local RightCol = Instance.new("Frame", SubContent)
                RightCol.BackgroundTransparency = 1
                RightCol.BorderColor3 = Library.Theme.Border
                RightCol.BorderSizePixel = 1
                RightCol.Size = UDim2.new(0.5, -2, 1, 0)
                RightCol.Position = UDim2.new(0.5, 2, 0, 0)
                local RightList = Instance.new("UIListLayout", RightCol)
                RightList.SortOrder = Enum.SortOrder.LayoutOrder
                RightList.Padding = UDim.new(0, 6)
                local RightPad = Instance.new("UIPadding", RightCol)
                RightPad.PaddingLeft = UDim.new(0, 5) RightPad.PaddingRight = UDim.new(0, 5) RightPad.PaddingTop = UDim.new(0, 5)

                local SubTab = {
                    Button = SubBtn,
                    Content = SubContent,
                    Left = LeftCol,
                    Right = RightCol
                }
                table.insert(self.SubTabs, SubTab)

                SubBtn.MouseButton1Click:Connect(function()
                    for _, st in pairs(self.SubTabs) do
                        st.Button.BackgroundColor3 = Library.Theme.WidgetBg
                        st.Button.TextColor3 = Library.Theme.Text
                        st.Content.Visible = false
                    end
                    SubBtn.BackgroundColor3 = Library.Theme.Accent
                    SubBtn.TextColor3 = Library.Theme.TextDark
                    SubContent.Visible = true
                    self.CurrentSubTab = SubTab
                end)

                if #self.SubTabs == 1 then
                    SubBtn.BackgroundColor3 = Library.Theme.Accent
                    SubBtn.TextColor3 = Library.Theme.TextDark
                    SubContent.Visible = true
                    self.CurrentSubTab = SubTab
                    SubTabContainer.Visible = true
                end

                function SubTab:CreateGroup(side)
                    local targetCol = side == "left" and self.Left or self.Right
                    local Group = {}
                    
                    function Group:CreateCheckbox(text, default, callback)
                        local Frame = Instance.new("Frame", targetCol)
                        Frame.BackgroundTransparency = 1
                        Frame.Size = UDim2.new(1, 0, 0, 14)

                        local Label = CreateTextLabel(Frame, text, Library.Theme.Text, Enum.TextXAlignment.Left)
                        Label.Size = UDim2.new(1, -20, 1, 0)

                        local Box = Instance.new("Frame", Frame)
                        Box.BackgroundColor3 = Library.Theme.WidgetBg
                        Box.BorderColor3 = Library.Theme.Border
                        Box.BorderSizePixel = 1
                        Box.Size = UDim2.new(0, 12, 0, 12)
                        Box.Position = UDim2.new(1, -12, 0.5, -6)

                        local Fill = Instance.new("Frame", Box)
                        Fill.BackgroundColor3 = Library.Theme.Accent
                        Fill.BorderSizePixel = 0
                        Fill.Position = UDim2.new(0, 1, 0, 1)
                        Fill.Size = UDim2.new(1, -2, 1, -2)
                        Fill.Visible = default or false

                        local Btn = Instance.new("TextButton", Frame)
                        Btn.BackgroundTransparency = 1
                        Btn.Size = UDim2.new(1, 0, 1, 0)
                        Btn.Text = ""

                        local toggled = default or false
                        Btn.MouseButton1Click:Connect(function()
                            toggled = not toggled
                            Fill.Visible = toggled
                            if callback then callback(toggled) end
                        end)
                    end

                    function Group:CreateSlider(text, min, max, default, callback)
                        local Frame = Instance.new("Frame", targetCol)
                        Frame.BackgroundTransparency = 1
                        Frame.Size = UDim2.new(1, 0, 0, 26)

                        local Label = CreateTextLabel(Frame, text, Library.Theme.Text, Enum.TextXAlignment.Left)
                        Label.Size = UDim2.new(0.5, 0, 0, 14)

                        local ValueLabel = CreateTextLabel(Frame, tostring(default), Library.Theme.Text, Enum.TextXAlignment.Right)
                        ValueLabel.Size = UDim2.new(0.5, 0, 0, 14)
                        ValueLabel.Position = UDim2.new(0.5, 0, 0, 0)

                        local Track = Instance.new("Frame", Frame)
                        Track.BackgroundColor3 = Library.Theme.WidgetBg
                        Track.BorderColor3 = Library.Theme.Border
                        Track.BorderSizePixel = 1
                        Track.Size = UDim2.new(1, 0, 0, 8)
                        Track.Position = UDim2.new(0, 0, 0, 16)

                        local Fill = Instance.new("Frame", Track)
                        Fill.BackgroundColor3 = Library.Theme.Accent
                        Fill.BorderSizePixel = 0
                        Fill.Size = UDim2.new(0, 0, 1, 0)

                        local Btn = Instance.new("TextButton", Track)
                        Btn.BackgroundTransparency = 1
                        Btn.Size = UDim2.new(1, 0, 1, 0)
                        Btn.Text = ""

                        local dragging = false
                        local function update(mouseX)
                            local pct = math.clamp((mouseX - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                            local val = math.floor(min + (max - min) * pct + 0.5)
                            Fill.Size = UDim2.new(pct, 0, 1, 0)
                            ValueLabel.Text = tostring(val)
                            if callback then callback(val) end
                        end

                        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)

                        Btn.MouseButton1Down:Connect(function()
                            dragging = true
                            update(UserInputService:GetMouseLocation().X)
                        end)
                        UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                        end)
                        table.insert(Library.Connections, RunService.RenderStepped:Connect(function()
                            if dragging then update(UserInputService:GetMouseLocation().X) end
                        end))
                    end

                    function Group:CreateDropdown(text, options, default, callback)
                        local Frame = Instance.new("Frame", targetCol)
                        Frame.BackgroundTransparency = 1
                        Frame.Size = UDim2.new(1, 0, 0, 36)

                        local Label = CreateTextLabel(Frame, text, Library.Theme.Text, Enum.TextXAlignment.Left)
                        Label.Size = UDim2.new(1, 0, 0, 14)

                        local Box = Instance.new("Frame", Frame)
                        Box.BackgroundColor3 = Library.Theme.WidgetBg
                        Box.BorderColor3 = Library.Theme.Border
                        Box.BorderSizePixel = 1
                        Box.Size = UDim2.new(1, 0, 0, 18)
                        Box.Position = UDim2.new(0, 0, 0, 16)

                        local Selected = CreateTextLabel(Box, default, Library.Theme.Text, Enum.TextXAlignment.Left)
                        Selected.Position = UDim2.new(0, 5, 0, 0)
                        Selected.Size = UDim2.new(1, -20, 1, 0)

                        local Arrow = CreateTextLabel(Box, "▼", Library.Theme.TextDim, Enum.TextXAlignment.Right)
                        Arrow.Position = UDim2.new(1, -10, 0, 0)
                        Arrow.Size = UDim2.new(0, 10, 1, 0)

                        local Btn = Instance.new("TextButton", Box)
                        Btn.BackgroundTransparency = 1
                        Btn.Size = UDim2.new(1, 0, 1, 0)
                        Btn.Text = ""

                        local ListOuter = Instance.new("Frame", self.MainGui)
                        ListOuter.BackgroundColor3 = Library.Theme.WidgetBg
                        ListOuter.BorderColor3 = Library.Theme.Border
                        ListOuter.BorderSizePixel = 1
                        ListOuter.Size = UDim2.new(0, Box.AbsoluteSize.X, 0, #options * 18 + 2)
                        ListOuter.Visible = false
                        ListOuter.ZIndex = 20

                        local ListLayout = Instance.new("UIListLayout", ListOuter)
                        for _, opt in ipairs(options) do
                            local OptBtn = Instance.new("TextButton", ListOuter)
                            OptBtn.BackgroundTransparency = 1
                            OptBtn.Size = UDim2.new(1, 0, 0, 18)
                            OptBtn.Font = Library.Theme.Font
                            OptBtn.TextSize = Library.Theme.TextSize
                            OptBtn.TextColor3 = Library.Theme.TextDim
                            OptBtn.Text = "  " .. opt
                            OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                            OptBtn.ZIndex = 21

                            OptBtn.MouseEnter:Connect(function() OptBtn.TextColor3 = Library.Theme.Accent end)
                            OptBtn.MouseLeave:Connect(function() OptBtn.TextColor3 = Library.Theme.TextDim end)
                            OptBtn.MouseButton1Click:Connect(function()
                                Selected.Text = opt
                                ListOuter.Visible = false
                                if callback then callback(opt) end
                            end)
                        end

                        Btn.MouseButton1Click:Connect(function()
                            ListOuter.Visible = not ListOuter.Visible
                            ListOuter.Size = UDim2.new(0, Box.AbsoluteSize.X, 0, #options * 18 + 2)
                        end)

                        table.insert(Library.Connections, RunService.RenderStepped:Connect(function()
                            if ListOuter.Visible then
                                ListOuter.Position = UDim2.new(0, Box.AbsolutePosition.X, 0, Box.AbsolutePosition.Y + 18)
                            end
                        end))
                    end

                    function Group:CreateColorPicker(text, defaultColor, callback)
                        local Frame = Instance.new("Frame", targetCol)
                        Frame.BackgroundTransparency = 1
                        Frame.Size = UDim2.new(1, 0, 0, 14)

                        local Label = CreateTextLabel(Frame, text, Library.Theme.Text, Enum.TextXAlignment.Left)
                        Label.Size = UDim2.new(1, -20, 1, 0)

                        local Box = Instance.new("Frame", Frame)
                        Box.BackgroundColor3 = defaultColor
                        Box.BorderColor3 = Library.Theme.Border
                        Box.BorderSizePixel = 1
                        Box.Size = UDim2.new(0, 20, 0, 10)
                        Box.Position = UDim2.new(1, -20, 0.5, -5)

                        -- Picker logic abbreviated for space (using simple click print for demo)
                        local Btn = Instance.new("TextButton", Box)
                        Btn.BackgroundTransparency = 1
                        Btn.Size = UDim2.new(1, 0, 1, 0)
                        Btn.Text = ""
                        Btn.MouseButton1Click:Connect(function()
                            if callback then callback(defaultColor) end
                        end)
                    end

                    function Group:CreateKeybind(text, defaultKey, callback)
                        local Frame = Instance.new("Frame", targetCol)
                        Frame.BackgroundTransparency = 1
                        Frame.Size = UDim2.new(1, 0, 0, 14)

                        local Label = CreateTextLabel(Frame, text, Library.Theme.Text, Enum.TextXAlignment.Left)
                        Label.Size = UDim2.new(1, -40, 1, 0)

                        local Box = Instance.new("Frame", Frame)
                        Box.BackgroundColor3 = Library.Theme.WidgetBg
                        Box.BorderColor3 = Library.Theme.Border
                        Box.BorderSizePixel = 1
                        Box.Size = UDim2.new(0, 20, 0, 14)
                        Box.Position = UDim2.new(1, -20, 0, 0)

                        local keyName = "-"
                        if defaultKey then
                            keyName = defaultKey.Name
                            if #keyName > 3 then keyName = string.sub(keyName, 1, 1) end
                        end
                        local KeyLabel = CreateTextLabel(Box, keyName, Library.Theme.TextDim, Enum.TextXAlignment.Center)
                        KeyLabel.Size = UDim2.new(1, 0, 1, 0)

                        local Btn = Instance.new("TextButton", Box)
                        Btn.BackgroundTransparency = 1
                        Btn.Size = UDim2.new(1, 0, 1, 0)
                        Btn.Text = ""

                        local listening = false
                        Btn.MouseButton1Click:Connect(function()
                            listening = true
                            KeyLabel.Text = "..."
                            KeyLabel.TextColor3 = Library.Theme.Accent
                        end)

                        table.insert(Library.Connections, UserInputService.InputBegan:Connect(function(input, gp)
                            if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                                listening = false
                                local key = input.KeyCode
                                if key == Enum.KeyCode.Escape then
                                    KeyLabel.Text = "-"
                                    KeyLabel.TextColor3 = Library.Theme.TextDim
                                else
                                    local name = key.Name
                                    if #name > 3 then name = string.sub(name, 1, 1) end -- Abbreviate
                                    KeyLabel.Text = name
                                    KeyLabel.TextColor3 = Library.Theme.TextDim
                                    if callback then callback(key) end
                                end
                            end
                        end))
                    end

                    function Group:CreateButton(text, callback)
                        local Frame = Instance.new("Frame", targetCol)
                        Frame.BackgroundTransparency = 1
                        Frame.Size = UDim2.new(1, 0, 0, 20)

                        local Btn = Instance.new("TextButton", Frame)
                        Btn.BackgroundColor3 = Library.Theme.WidgetBg
                        Btn.BorderColor3 = Library.Theme.Border
                        Btn.BorderSizePixel = 1
                        Btn.Size = UDim2.new(1, 0, 1, 0)
                        Btn.Font = Library.Theme.Font
                        Btn.TextSize = Library.Theme.TextSize
                        Btn.TextColor3 = Library.Theme.Text
                        Btn.Text = text

                        Btn.MouseButton1Click:Connect(function()
                            if callback then callback() end
                        end)
                    end

                    function Group:CreateButtonGroup(text, options, default, callback)
                        local Frame = Instance.new("Frame", targetCol)
                        Frame.BackgroundTransparency = 1
                        Frame.Size = UDim2.new(1, 0, 0, 16)

                        local Label = CreateTextLabel(Frame, text, Library.Theme.Text, Enum.TextXAlignment.Left)
                        Label.Size = UDim2.new(0.5, 0, 1, 0)

                        local BtnContainer = Instance.new("Frame", Frame)
                        BtnContainer.BackgroundTransparency = 1
                        BtnContainer.Position = UDim2.new(0.5, 0, 0, 0)
                        BtnContainer.Size = UDim2.new(0.5, 0, 1, 0)

                        local Layout = Instance.new("UIListLayout", BtnContainer)
                        Layout.FillDirection = Enum.FillDirection.Horizontal
                        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                        Layout.Padding = UDim.new(0, 2)

                        local btns = {}
                        for _, opt in ipairs(options) do
                            local Btn = Instance.new("TextButton", BtnContainer)
                            Btn.BackgroundColor3 = (opt == default) and Library.Theme.Accent or Library.Theme.WidgetBg
                            Btn.BorderColor3 = Library.Theme.Border
                            Btn.BorderSizePixel = 1
                            Btn.Size = UDim2.new(0, 40, 1, 0)
                            Btn.Font = Library.Theme.Font
                            Btn.TextSize = Library.Theme.TextSize
                            Btn.TextColor3 = (opt == default) and Library.Theme.TextDark or Library.Theme.TextDim
                            Btn.Text = opt
                            table.insert(btns, Btn)

                            Btn.MouseButton1Click:Connect(function()
                                for _, b in ipairs(btns) do
                                    b.BackgroundColor3 = Library.Theme.WidgetBg
                                    b.TextColor3 = Library.Theme.TextDim
                                end
                                Btn.BackgroundColor3 = Library.Theme.Accent
                                Btn.TextColor3 = Library.Theme.TextDark
                                if callback then callback(opt) end
                            end)
                        end
                    end

                    function Group:CreateListbox(text, options, callback)
                        local Frame = Instance.new("Frame", targetCol)
                        Frame.BackgroundTransparency = 1
                        Frame.Size = UDim2.new(1, 0, 0, 120)

                        local Label = CreateTextLabel(Frame, text, Library.Theme.Text, Enum.TextXAlignment.Left)
                        Label.Size = UDim2.new(1, 0, 0, 14)

                        local Scroll = Instance.new("ScrollingFrame", Frame)
                        Scroll.BackgroundColor3 = Library.Theme.WidgetBg
                        Scroll.BorderColor3 = Library.Theme.Border
                        Scroll.BorderSizePixel = 1
                        Scroll.Position = UDim2.new(0, 0, 0, 16)
                        Scroll.Size = UDim2.new(1, 0, 1, -16)
                        Scroll.ScrollBarThickness = 4
                        Scroll.ScrollBarImageColor3 = Library.Theme.Accent

                        local Layout = Instance.new("UIListLayout", Scroll)
                        for _, opt in ipairs(options) do
                            local Btn = Instance.new("TextButton", Scroll)
                            Btn.BackgroundTransparency = 1
                            Btn.Size = UDim2.new(1, 0, 0, 18)
                            Btn.Font = Library.Theme.Font
                            Btn.TextSize = Library.Theme.TextSize
                            Btn.TextColor3 = Library.Theme.TextDim
                            Btn.Text = "  " .. opt
                            Btn.TextXAlignment = Enum.TextXAlignment.Left

                            Btn.MouseButton1Click:Connect(function()
                                for _, child in ipairs(Scroll:GetChildren()) do
                                    if child:IsA("TextButton") then child.TextColor3 = Library.Theme.TextDim end
                                end
                                Btn.TextColor3 = Library.Theme.Accent
                                if callback then callback(opt) end
                            end)
                        end
                        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                            Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
                        end)
                    end

                    function Group:CreateTextbox(text, placeholder, callback)
                        local Frame = Instance.new("Frame", targetCol)
                        Frame.BackgroundTransparency = 1
                        Frame.Size = UDim2.new(1, 0, 0, 34)

                        local Label = CreateTextLabel(Frame, text, Library.Theme.Text, Enum.TextXAlignment.Left)
                        Label.Size = UDim2.new(1, 0, 0, 14)

                        local Box = Instance.new("TextBox", Frame)
                        Box.BackgroundColor3 = Library.Theme.WidgetBg
                        Box.BorderColor3 = Library.Theme.Border
                        Box.BorderSizePixel = 1
                        Box.Position = UDim2.new(0, 0, 0, 16)
                        Box.Size = UDim2.new(1, 0, 1, -16)
                        Box.Font = Library.Theme.Font
                        Box.TextSize = Library.Theme.TextSize
                        Box.TextColor3 = Library.Theme.Text
                        Box.Text = placeholder or ""
                        Box.TextXAlignment = Enum.TextXAlignment.Left
                        
                        local pad = Instance.new("UIPadding", Box)
                        pad.PaddingLeft = UDim.new(0, 5)

                        Box.FocusLost:Connect(function()
                            if callback then callback(Box.Text) end
                        end)
                    end

                    return Group
                end
                return SubTab
            end
            
            -- Automatically click the first tab when created if it's the only one
            if #self.Tabs == 1 then
                TabBtn.BackgroundColor3 = Library.Theme.Accent
                TabBtn.TextColor3 = Library.Theme.TextDark
                Tab.TabContentArea.Visible = true
                self.CurrentTab = Tab
            end

            return Tab
        end
    end

    return Window
end

return Library
