local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Library = {
    Connections = {},
    Windows = {},
    Theme = {
        Accent = Color3.fromRGB(114, 120, 173), -- Lavender/Purple
        Background = Color3.fromRGB(12, 12, 12),
        GroupBg = Color3.fromRGB(15, 15, 15),
        WidgetBg = Color3.fromRGB(30, 30, 30),
        Border = Color3.fromRGB(40, 40, 40),
        Text = Color3.fromRGB(200, 200, 200),
        TextDim = Color3.fromRGB(120, 120, 120),
        Font = Enum.Font.GothamMedium,
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
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Parent = parent
    Label.BackgroundTransparency = 1
    Label.Font = Library.Theme.Font
    Label.TextSize = Library.Theme.TextSize
    Label.TextColor3 = color or Library.Theme.Text
    Label.Text = text or ""
    Label.TextXAlignment = align or Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Center
    return Label
end

local function MakeDraggable(topbar, frame)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    table.insert(Library.Connections, RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
end

function Library:CreateWindow(title, size, position)
    if not self.MainGui then
        local MainGui = Instance.new("ScreenGui")
        MainGui.Name = "Style5UI"
        MainGui.Parent = CoreGui
        MainGui.ResetOnSpawn = false
        self.MainGui = MainGui

        table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.Insert then MainGui.Enabled = not MainGui.Enabled end
            if input.KeyCode == Enum.KeyCode.End then self:Unload() end
        end))
    end

    local WindowFrame = Instance.new("Frame")
    WindowFrame.Name = "Window"
    WindowFrame.Parent = self.MainGui
    WindowFrame.BackgroundColor3 = Library.Theme.Background
    WindowFrame.BorderColor3 = Library.Theme.Border
    WindowFrame.BorderSizePixel = 1
    WindowFrame.Position = position or UDim2.new(0.5, -275, 0.5, -250)
    WindowFrame.Size = size or UDim2.new(0, 550, 0, 600)
    WindowFrame.Active = true

    local WindowCorner = Instance.new("UICorner")
    WindowCorner.CornerRadius = UDim.new(0, 4)
    WindowCorner.Parent = WindowFrame

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = WindowFrame
    TopBar.BackgroundColor3 = Library.Theme.Background
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 35)

    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 4)
    TopBarCorner.Parent = TopBar

    local TitleContainer = Instance.new("Frame")
    TitleContainer.Name = "Title"
    TitleContainer.Parent = TopBar
    TitleContainer.BackgroundTransparency = 1
    TitleContainer.Position = UDim2.new(0, 15, 0, 0)
    TitleContainer.Size = UDim2.new(0, 80, 1, 0)

    local ImGuiLabel = CreateTextLabel(TitleContainer, "ImGui", Library.Theme.Text)
    ImGuiLabel.Size = UDim2.new(0, 40, 1, 0)
    ImGuiLabel.Font = Enum.Font.GothamBold
    
    local OrgLabel = CreateTextLabel(TitleContainer, ".org", Library.Theme.Accent)
    OrgLabel.Position = UDim2.new(0, 40, 0, 0)
    OrgLabel.Size = UDim2.new(0, 40, 1, 0)
    OrgLabel.Font = Enum.Font.GothamBold

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "Tabs"
    TabContainer.Parent = TopBar
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 100, 0, 0)
    TabContainer.Size = UDim2.new(1, -110, 1, 0)

    local TabsLayout = Instance.new("UIListLayout")
    TabsLayout.Parent = TabContainer
    TabsLayout.FillDirection = Enum.FillDirection.Horizontal
    TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabsLayout.Padding = UDim.new(0, 0)

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "Content"
    ContentArea.Parent = WindowFrame
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 10, 0, 40)
    ContentArea.Size = UDim2.new(1, -20, 1, -50)

    MakeDraggable(TopBar, WindowFrame)

    local Window = {
        Frame = WindowFrame,
        Tabs = {},
        CurrentTab = nil
    }

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = name .. "Tab"
        TabBtn.Parent = TabContainer
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(0, 0, 1, 0)
        TabBtn.AutomaticSize = Enum.AutomaticSize.X
        TabBtn.Font = Library.Theme.Font
        TabBtn.TextSize = 13
        TabBtn.TextColor3 = Library.Theme.TextDim
        TabBtn.Text = name

        local TabPadding = Instance.new("UIPadding")
        TabPadding.PaddingLeft = UDim.new(0, 15)
        TabPadding.PaddingRight = UDim.new(0, 15)
        TabPadding.Parent = TabBtn

        local Indicator = Instance.new("Frame")
        Indicator.Name = "Indicator"
        Indicator.Parent = TabBtn
        Indicator.BackgroundColor3 = Library.Theme.Accent
        Indicator.BorderSizePixel = 0
        Indicator.Position = UDim2.new(0, 0, 1, -2)
        Indicator.Size = UDim2.new(1, 0, 0, 2)
        Indicator.Visible = false
        Indicator.ZIndex = 2

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "Content"
        TabContent.Parent = ContentArea
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.Visible = false
        TabContent.ScrollBarThickness = 0
        TabContent.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)

        local TabPadding = Instance.new("UIPadding")
        TabPadding.Parent = TabContent
        TabPadding.PaddingTop = UDim.new(0, 5)
        TabPadding.PaddingBottom = UDim.new(0, 5)

        local LeftCol = Instance.new("Frame")
        LeftCol.Name = "Left"
        LeftCol.Parent = TabContent
        LeftCol.BackgroundTransparency = 1
        LeftCol.Size = UDim2.new(0.5, -5, 0, 0)
        LeftCol.AutomaticSize = Enum.AutomaticSize.Y

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.Parent = LeftCol
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 10)

        local RightCol = Instance.new("Frame")
        RightCol.Name = "Right"
        RightCol.Parent = TabContent
        RightCol.BackgroundTransparency = 1
        RightCol.Position = UDim2.new(0.5, 5, 0, 0)
        RightCol.Size = UDim2.new(0.5, -5, 0, 0)
        RightCol.AutomaticSize = Enum.AutomaticSize.Y

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.Parent = RightCol
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 10)

        local Tab = {
            Button = TabBtn,
            Content = TabContent,
            Left = LeftCol,
            Right = RightCol
        }

        table.insert(Window.Tabs, Tab)

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Button.TextColor3 = Library.Theme.TextDim
                t.Button.Indicator.Visible = false
                t.Content.Visible = false
            end
            TabBtn.TextColor3 = Library.Theme.Text
            Indicator.Visible = true
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end)

        if #Window.Tabs == 1 then
            TabBtn.TextColor3 = Library.Theme.Text
            Indicator.Visible = true
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end

        function Tab:CreateGroup(name, side)
            local targetCol = side == "right" and self.Right or self.Left
            
            local GroupBox = Instance.new("Frame")
            GroupBox.Name = name .. "Group"
            GroupBox.Parent = targetCol
            GroupBox.BackgroundColor3 = Library.Theme.GroupBg
            GroupBox.BorderColor3 = Library.Theme.Border
            GroupBox.BorderSizePixel = 1
            GroupBox.Size = UDim2.new(1, 0, 0, 100)

            local GroupCorner = Instance.new("UICorner")
            GroupCorner.CornerRadius = UDim.new(0, 4)
            GroupCorner.Parent = GroupBox

            local Header = Instance.new("Frame")
            Header.Name = "Header"
            Header.Parent = GroupBox
            Header.BackgroundTransparency = 1
            Header.Position = UDim2.new(0, 10, 0, 10)
            Header.Size = UDim2.new(1, -20, 0, 20)

            local HeaderLabel = CreateTextLabel(Header, string.upper(name), Library.Theme.Text)
            HeaderLabel.Size = UDim2.new(0, 0, 1, 0)
            HeaderLabel.AutomaticSize = Enum.AutomaticSize.X
            HeaderLabel.Font = Enum.Font.GothamBold
            HeaderLabel.TextSize = 11

            local HeaderLine = Instance.new("Frame")
            HeaderLine.Name = "Line"
            HeaderLine.Parent = Header
            HeaderLine.BackgroundColor3 = Library.Theme.Border
            HeaderLine.BorderSizePixel = 0
            HeaderLine.Position = UDim2.new(0, 0, 0.5, 0)
            HeaderLine.Size = UDim2.new(1, 0, 0, 1)
            HeaderLine.ZIndex = 0

            local function UpdateLine()
                local labelWidth = HeaderLabel.AbsoluteSize.X
                HeaderLine.Position = UDim2.new(0, labelWidth + 10, 0.5, 0)
                HeaderLine.Size = UDim2.new(1, -(labelWidth + 10), 0, 1)
            end

            HeaderLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateLine)
            task.defer(UpdateLine)

            local Container = Instance.new("Frame")
            Container.Name = "Container"
            Container.Parent = GroupBox
            Container.BackgroundTransparency = 1
            Container.Position = UDim2.new(0, 10, 0, 40)
            Container.Size = UDim2.new(1, -20, 1, -50)

            local ContainerLayout = Instance.new("UIListLayout")
            ContainerLayout.Parent = Container
            ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContainerLayout.Padding = UDim.new(0, 12)

            ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                GroupBox.Size = UDim2.new(1, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 55)
            end)

            local Group = {}

            function Group:CreateToggle(text, default, callback)
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = text .. "Toggle"
                ToggleFrame.Parent = Container
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Size = UDim2.new(1, 0, 0, 20)

                local Box = Instance.new("Frame")
                Box.Name = "Box"
                Box.Parent = ToggleFrame
                Box.BackgroundColor3 = Library.Theme.WidgetBg
                Box.BorderColor3 = Library.Theme.Border
                Box.BorderSizePixel = 1
                Box.Size = UDim2.new(0, 16, 0, 16)
                Box.Position = UDim2.new(0, 0, 0.5, -8)

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 3)
                BoxCorner.Parent = Box

                local Fill = Instance.new("Frame")
                Fill.Name = "Fill"
                Fill.Parent = Box
                Fill.BackgroundColor3 = Library.Theme.Accent
                Fill.BorderSizePixel = 0
                Fill.Position = UDim2.new(0.5, -4, 0.5, -4)
                Fill.Size = UDim2.new(0, 8, 0, 8)
                Fill.Visible = default or false

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(0, 2)
                FillCorner.Parent = Fill

                local Label = CreateTextLabel(ToggleFrame, text, Library.Theme.Text)
                Label.Position = UDim2.new(0, 25, 0, 0)
                Label.Size = UDim2.new(1, -25, 1, 0)

                local Btn = Instance.new("TextButton")
                Btn.Name = "Button"
                Btn.Parent = ToggleFrame
                Btn.BackgroundTransparency = 1
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.Text = ""

                local toggled = default or false
                Btn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    Fill.Visible = toggled
                    if callback then callback(toggled) end
                end)

                local Toggle = {
                    Set = function(self, val)
                        toggled = val
                        Fill.Visible = toggled
                        if callback then callback(toggled) end
                    end
                }

                function Toggle:CreateKeybind(defaultKey, callback)
                    local KeyLabel = CreateTextLabel(ToggleFrame, defaultKey and defaultKey.Name or "NONE", Library.Theme.TextDim, Enum.TextXAlignment.Right)
                    KeyLabel.Size = UDim2.new(1, 0, 1, 0)
                    
                    local KeyBtn = Instance.new("TextButton")
                    KeyBtn.Parent = ToggleFrame
                    KeyBtn.BackgroundTransparency = 1
                    KeyBtn.Size = UDim2.new(1, 0, 1, 0)
                    KeyBtn.Text = ""
                    KeyBtn.ZIndex = 2

                    local listening = false
                    KeyBtn.MouseButton1Click:Connect(function()
                        listening = true
                        KeyLabel.Text = "..."
                    end)

                    table.insert(Library.Connections, UserInputService.InputBegan:Connect(function(input, gp)
                        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                            listening = false
                            local key = input.KeyCode
                            KeyLabel.Text = key.Name
                            if callback then callback(key) end
                        end
                    end))
                end

                return Toggle
            end

            function Group:CreateSlider(text, min, max, default, callback)
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = text .. "Slider"
                SliderFrame.Parent = Container
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Size = UDim2.new(1, 0, 0, 35)

                local Label = CreateTextLabel(SliderFrame, text, Library.Theme.Text)
                Label.Size = UDim2.new(1, 0, 0, 15)

                local ValueLabel = CreateTextLabel(SliderFrame, tostring(default), Library.Theme.TextDim, Enum.TextXAlignment.Right)
                ValueLabel.Size = UDim2.new(1, 0, 0, 15)

                local Track = Instance.new("Frame")
                Track.Name = "Track"
                Track.Parent = SliderFrame
                Track.BackgroundColor3 = Library.Theme.WidgetBg
                Track.BorderSizePixel = 0
                Track.Position = UDim2.new(0, 0, 0, 20)
                Track.Size = UDim2.new(1, 0, 0, 8)

                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(0, 4)
                TrackCorner.Parent = Track

                local Fill = Instance.new("Frame")
                Fill.Name = "Fill"
                Fill.Parent = Track
                Fill.BackgroundColor3 = Library.Theme.Accent
                Fill.BorderSizePixel = 0
                Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(0, 4)
                FillCorner.Parent = Fill

                local Btn = Instance.new("TextButton")
                Btn.Name = "Button"
                Btn.Parent = Track
                Btn.BackgroundTransparency = 1
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.Text = ""

                local dragging = false
                local function update()
                    local mousePos = UserInputService:GetMouseLocation()
                    local pct = math.clamp((mousePos.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * pct + 0.5)
                    Fill.Size = UDim2.new(pct, 0, 1, 0)
                    ValueLabel.Text = tostring(val)
                    if callback then callback(val) end
                end

                Btn.MouseButton1Down:Connect(function()
                    dragging = true
                end)

                table.insert(Library.Connections, UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end))

                table.insert(Library.Connections, RunService.RenderStepped:Connect(function()
                    if dragging then update() end
                end))

                return {
                    Set = function(self, val)
                        local pct = (val - min) / (max - min)
                        Fill.Size = UDim2.new(pct, 0, 1, 0)
                        ValueLabel.Text = tostring(val)
                        if callback then callback(val) end
                    end
                }
            end

            function Group:CreateDropdown(text, options, default, callback)
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = text .. "Dropdown"
                DropdownFrame.Parent = Container
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Size = UDim2.new(1, 0, 0, 40)

                local Label = CreateTextLabel(DropdownFrame, text, Library.Theme.Text)
                Label.Size = UDim2.new(1, 0, 0, 15)

                local Box = Instance.new("Frame")
                Box.Name = "Box"
                Box.Parent = DropdownFrame
                Box.BackgroundColor3 = Library.Theme.WidgetBg
                Box.BorderColor3 = Library.Theme.Border
                Box.BorderSizePixel = 1
                Box.Position = UDim2.new(0, 0, 0, 20)
                Box.Size = UDim2.new(1, 0, 0, 20)

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 3)
                BoxCorner.Parent = Box

                local SelectedLabel = CreateTextLabel(Box, default or "None", Library.Theme.TextDim)
                SelectedLabel.Position = UDim2.new(0, 10, 0, 0)
                SelectedLabel.Size = UDim2.new(1, -30, 1, 0)
                SelectedLabel.TextSize = 12

                local Arrow = CreateTextLabel(Box, "▼", Library.Theme.TextDim, Enum.TextXAlignment.Right)
                Arrow.Position = UDim2.new(1, -20, 0, 0)
                Arrow.Size = UDim2.new(0, 15, 1, 0)

                local Btn = Instance.new("TextButton")
                Btn.Name = "Button"
                Btn.Parent = Box
                Btn.BackgroundTransparency = 1
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.Text = ""

                local List = Instance.new("Frame")
                List.Name = "List"
                List.Parent = Window.Frame
                List.BackgroundColor3 = Library.Theme.WidgetBg
                List.BorderColor3 = Library.Theme.Border
                List.BorderSizePixel = 1
                List.Size = UDim2.new(0, 0, 0, 0)
                List.Visible = false
                List.ZIndex = 10

                local ListCorner = Instance.new("UICorner")
                ListCorner.CornerRadius = UDim.new(0, 3)
                ListCorner.Parent = List

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.Parent = List
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Name = opt
                    OptBtn.Parent = List
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Size = UDim2.new(1, 0, 0, 20)
                    OptBtn.Font = Library.Theme.Font
                    OptBtn.TextSize = 12
                    OptBtn.TextColor3 = Library.Theme.TextDim
                    OptBtn.Text = opt
                    OptBtn.ZIndex = 11

                    OptBtn.MouseButton1Click:Connect(function()
                        SelectedLabel.Text = opt
                        List.Visible = false
                        if callback then callback(opt) end
                    end)
                end

                Btn.MouseButton1Click:Connect(function()
                    List.Visible = not List.Visible
                    List.Position = UDim2.new(0, Box.AbsolutePosition.X - Window.Frame.AbsolutePosition.X, 0, Box.AbsolutePosition.Y - Window.Frame.AbsolutePosition.Y + 25)
                    List.Size = UDim2.new(0, Box.AbsoluteSize.X, 0, #options * 20)
                end)

                return {
                    Set = function(self, val)
                        SelectedLabel.Text = val
                        if callback then callback(val) end
                    end
                }
            end

            function Group:CreateColorPicker(text, default, callback)
                local PickerFrame = Instance.new("Frame")
                PickerFrame.Name = text .. "ColorPicker"
                PickerFrame.Parent = Container
                PickerFrame.BackgroundTransparency = 1
                PickerFrame.Size = UDim2.new(1, 0, 0, 20)

                local Label = CreateTextLabel(PickerFrame, text, Library.Theme.Text)
                Label.Size = UDim2.new(1, -25, 1, 0)

                local Box = Instance.new("Frame")
                Box.Name = "Box"
                Box.Parent = PickerFrame
                Box.BackgroundColor3 = default or Color3.fromRGB(255, 255, 255)
                Box.BorderColor3 = Library.Theme.Border
                Box.BorderSizePixel = 1
                Box.Position = UDim2.new(1, -20, 0.5, -6)
                Box.Size = UDim2.new(0, 20, 0, 12)

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 2)
                BoxCorner.Parent = Box

                local Btn = Instance.new("TextButton")
                Btn.Name = "Button"
                Btn.Parent = Box
                Btn.BackgroundTransparency = 1
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.Text = ""

                -- Simplified color picker for now
                Btn.MouseButton1Click:Connect(function()
                    local newColor = Color3.fromHSV(tick() % 5 / 5, 1, 1) -- Random/Cycling color for demo
                    Box.BackgroundColor3 = newColor
                    if callback then callback(newColor) end
                end)

                return {
                    Set = function(self, val)
                        Box.BackgroundColor3 = val
                        if callback then callback(val) end
                    end
                }
            end

            function Group:CreateButton(text, callback)
                local BtnFrame = Instance.new("Frame")
                BtnFrame.Name = text .. "Button"
                BtnFrame.Parent = Container
                BtnFrame.BackgroundTransparency = 1
                BtnFrame.Size = UDim2.new(1, 0, 0, 25)

                local Btn = Instance.new("TextButton")
                Btn.Name = "Button"
                Btn.Parent = BtnFrame
                Btn.BackgroundColor3 = Library.Theme.WidgetBg
                Btn.BorderColor3 = Library.Theme.Border
                Btn.BorderSizePixel = 1
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.Font = Library.Theme.Font
                Btn.TextSize = 13
                Btn.TextColor3 = Library.Theme.Text
                Btn.Text = text

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 4)
                BtnCorner.Parent = Btn

                Btn.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
            end

            return Group
        end

        return Tab
    end

    return Window
end

return Library
