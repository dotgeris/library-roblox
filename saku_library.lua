local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Library = {
    Connections = {},
    Theme = {
        Accent = Color3.fromRGB(0, 150, 255),
        Background = Color3.fromRGB(25, 25, 25),
        Border = Color3.fromRGB(45, 45, 45),
        WidgetBg = Color3.fromRGB(15, 15, 15),
        Text = Color3.fromRGB(200, 200, 200),
        TextDim = Color3.fromRGB(120, 120, 120),
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
    Label.TextStrokeTransparency = 1 -- Crisp, no shadow
    return Label
end

function Library:CreateWindow(title)
    if self.MainGui then self.MainGui:Destroy() end
    
    local MainGui = Instance.new("ScreenGui", CoreGui)
    MainGui.Name = "SakuUI"
    MainGui.ResetOnSpawn = false
    self.MainGui = MainGui

    -- Main Window
    local OuterBorder = Instance.new("Frame", MainGui)
    OuterBorder.BackgroundColor3 = Library.Theme.Accent
    OuterBorder.BorderSizePixel = 0
    OuterBorder.Position = UDim2.new(0.5, -250, 0.5, -250)
    OuterBorder.Size = UDim2.new(0, 500, 0, 520)

    local MainBg = Instance.new("Frame", OuterBorder)
    MainBg.BackgroundColor3 = Library.Theme.Background
    MainBg.BorderSizePixel = 0
    MainBg.Position = UDim2.new(0, 1, 0, 1)
    MainBg.Size = UDim2.new(1, -2, 1, -2)

    -- Top Bar
    local TopBar = Instance.new("Frame", MainBg)
    TopBar.BackgroundTransparency = 1
    TopBar.Size = UDim2.new(1, 0, 0, 20)

    local TitleLabel = CreateTextLabel(TopBar, title, Library.Theme.Accent, Enum.TextXAlignment.Left)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)

    local TopBorder = Instance.new("Frame", MainBg)
    TopBorder.BackgroundColor3 = Library.Theme.Border
    TopBorder.BorderSizePixel = 0
    TopBorder.Position = UDim2.new(0, 10, 0, 20)
    TopBorder.Size = UDim2.new(1, -20, 0, 1)

    local TabContainer = Instance.new("Frame", TopBar)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(1, -300, 0, 0)
    TabContainer.Size = UDim2.new(0, 290, 1, 0)

    local TabsList = Instance.new("UIListLayout", TabContainer)
    TabsList.FillDirection = Enum.FillDirection.Horizontal
    TabsList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    TabsList.SortOrder = Enum.SortOrder.LayoutOrder
    TabsList.Padding = UDim.new(0, 5)

    -- Content Area
    local ContentArea = Instance.new("Frame", MainBg)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 10, 0, 30)
    ContentArea.Size = UDim2.new(1, -20, 1, -40)

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = OuterBorder.Position
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

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Size = UDim2.new(0, 0, 1, 0)
        TabBtn.Font = Library.Theme.Font
        TabBtn.TextSize = Library.Theme.TextSize
        TabBtn.Text = name
        TabBtn.TextColor3 = Library.Theme.TextDim
        TabBtn.AutomaticSize = Enum.AutomaticSize.X

        local TabContent = Instance.new("Frame", ContentArea)
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.Visible = false

        -- Left and Right Columns
        local LeftCol = Instance.new("Frame", TabContent)
        LeftCol.BackgroundTransparency = 1
        LeftCol.Size = UDim2.new(0.5, -5, 1, 0)
        LeftCol.Position = UDim2.new(0, 0, 0, 0)
        local LeftList = Instance.new("UIListLayout", LeftCol)
        LeftList.SortOrder = Enum.SortOrder.LayoutOrder
        LeftList.Padding = UDim.new(0, 10)

        local RightCol = Instance.new("Frame", TabContent)
        RightCol.BackgroundTransparency = 1
        RightCol.Size = UDim2.new(0.5, -5, 1, 0)
        RightCol.Position = UDim2.new(0.5, 5, 0, 0)
        local RightList = Instance.new("UIListLayout", RightCol)
        RightList.SortOrder = Enum.SortOrder.LayoutOrder
        RightList.Padding = UDim.new(0, 10)

        local Tab = {
            Button = TabBtn,
            Content = TabContent,
            Left = LeftCol,
            Right = RightCol
        }

        table.insert(self.Tabs, Tab)

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(self.Tabs) do
                t.Button.TextColor3 = Library.Theme.TextDim
                t.Content.Visible = false
            end
            TabBtn.TextColor3 = Library.Theme.Accent
            TabContent.Visible = true
            self.CurrentTab = Tab
        end)

        if #self.Tabs == 1 then
            TabBtn.TextColor3 = Library.Theme.Accent
            TabContent.Visible = true
            self.CurrentTab = Tab
        end

        function Tab:CreateGroup(groupName, side)
            local targetCol = side == "left" and self.Left or self.Right
            
            local GroupOuter = Instance.new("Frame", targetCol)
            GroupOuter.BackgroundColor3 = Library.Theme.Border
            GroupOuter.BorderSizePixel = 0
            GroupOuter.Size = UDim2.new(1, 0, 0, 20) -- dynamic size later
            
            local GroupInner = Instance.new("Frame", GroupOuter)
            GroupInner.BackgroundColor3 = Library.Theme.Background
            GroupInner.BorderSizePixel = 0
            GroupInner.Position = UDim2.new(0, 1, 0, 1)
            GroupInner.Size = UDim2.new(1, -2, 1, -2)

            local GroupTitle = CreateTextLabel(GroupInner, groupName, Library.Theme.Text, Enum.TextXAlignment.Center)
            GroupTitle.Size = UDim2.new(1, 0, 0, 20)

            local TitleLine = Instance.new("Frame", GroupInner)
            TitleLine.BackgroundColor3 = Library.Theme.Border
            TitleLine.BorderSizePixel = 0
            TitleLine.Position = UDim2.new(0, 5, 0, 20)
            TitleLine.Size = UDim2.new(1, -10, 0, 1)

            local ItemsContainer = Instance.new("Frame", GroupInner)
            ItemsContainer.BackgroundTransparency = 1
            ItemsContainer.Position = UDim2.new(0, 10, 0, 26)
            ItemsContainer.Size = UDim2.new(1, -20, 1, -30)

            local ItemList = Instance.new("UIListLayout", ItemsContainer)
            ItemList.SortOrder = Enum.SortOrder.LayoutOrder
            ItemList.Padding = UDim.new(0, 4)

            -- Adjust group size based on content
            ItemList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                GroupOuter.Size = UDim2.new(1, 0, 0, ItemList.AbsoluteContentSize.Y + 36)
            end)

            local Group = {}

            function Group:CreateLabel(text)
                local Frame = Instance.new("Frame", ItemsContainer)
                Frame.BackgroundTransparency = 1
                Frame.Size = UDim2.new(1, 0, 0, 16)
                local Label = CreateTextLabel(Frame, text, Library.Theme.Text, Enum.TextXAlignment.Left)
                Label.Size = UDim2.new(1, 0, 1, 0)
                return Label
            end

            function Group:CreateCheckbox(text, default, callback)
                local Frame = Instance.new("Frame", ItemsContainer)
                Frame.BackgroundTransparency = 1
                Frame.Size = UDim2.new(1, 0, 0, 16)
                
                local BoxOuter = Instance.new("Frame", Frame)
                BoxOuter.BackgroundColor3 = Library.Theme.Border
                BoxOuter.BorderSizePixel = 0
                BoxOuter.Size = UDim2.new(0, 10, 0, 10)
                BoxOuter.Position = UDim2.new(0, 0, 0.5, -5)

                local BoxBg = Instance.new("Frame", BoxOuter)
                BoxBg.BackgroundColor3 = Library.Theme.WidgetBg
                BoxBg.BorderSizePixel = 0
                BoxBg.Position = UDim2.new(0, 1, 0, 1)
                BoxBg.Size = UDim2.new(1, -2, 1, -2)
                
                local Fill = Instance.new("Frame", BoxBg)
                Fill.BackgroundColor3 = Library.Theme.Accent
                Fill.BorderSizePixel = 0
                Fill.Position = UDim2.new(0, 1, 0, 1)
                Fill.Size = UDim2.new(1, -2, 1, -2)
                Fill.Visible = default or false
                
                local Label = CreateTextLabel(Frame, text, Library.Theme.Text, Enum.TextXAlignment.Left)
                Label.Position = UDim2.new(0, 18, 0, 0)
                Label.Size = UDim2.new(1, -18, 1, 0)
                
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
                
                return { Frame = Frame, Toggle = function(state) toggled = state Fill.Visible = toggled if callback then callback(toggled) end end }
            end

            function Group:CreateSlider(text, min, max, default, decimals, callback)
                local Frame = Instance.new("Frame", ItemsContainer)
                Frame.BackgroundTransparency = 1
                Frame.Size = UDim2.new(1, 0, 0, 32)
                
                local Label = CreateTextLabel(Frame, text, Library.Theme.TextDim, Enum.TextXAlignment.Left)
                Label.Size = UDim2.new(1, 0, 0, 14)
                
                local SliderOuter = Instance.new("Frame", Frame)
                SliderOuter.BackgroundColor3 = Library.Theme.Border
                SliderOuter.BorderSizePixel = 0
                SliderOuter.Size = UDim2.new(1, 0, 0, 14)
                SliderOuter.Position = UDim2.new(0, 0, 0, 16)
                
                local SliderBg = Instance.new("Frame", SliderOuter)
                SliderBg.BackgroundColor3 = Library.Theme.WidgetBg
                SliderBg.BorderSizePixel = 0
                SliderBg.Position = UDim2.new(0, 1, 0, 1)
                SliderBg.Size = UDim2.new(1, -2, 1, -2)
                
                local SliderFill = Instance.new("Frame", SliderBg)
                SliderFill.BackgroundColor3 = Library.Theme.Accent
                SliderFill.BorderSizePixel = 0
                SliderFill.Size = UDim2.new(0, 0, 1, 0)
                
                local ValueLabel = CreateTextLabel(SliderOuter, tostring(default), Library.Theme.Text, Enum.TextXAlignment.Center)
                ValueLabel.Size = UDim2.new(1, 0, 1, 0)
                
                local Btn = Instance.new("TextButton", SliderOuter)
                Btn.BackgroundTransparency = 1
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.Text = ""

                local currentVal = default or min
                local dragging = false
                
                local function formatValue(val)
                    if decimals > 0 then
                        return string.format("%."..decimals.."f", val)
                    else
                        return tostring(math.floor(val))
                    end
                end

                local function updateSlider(mouseX)
                    local w = SliderOuter.AbsoluteSize.X
                    local pct = math.clamp((mouseX - SliderOuter.AbsolutePosition.X) / w, 0, 1)
                    local val = min + (max - min) * pct
                    if decimals == 0 then val = math.floor(val + 0.5) end
                    
                    SliderFill.Size = UDim2.new(pct, 0, 1, 0)
                    ValueLabel.Text = formatValue(val)
                    currentVal = val
                    if callback then callback(val) end
                end
                
                -- Init
                SliderFill.Size = UDim2.new((currentVal - min)/(max - min), 0, 1, 0)
                ValueLabel.Text = formatValue(currentVal)
                
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

            function Group:CreateDropdown(text, options, default, callback)
                local Frame = Instance.new("Frame", ItemsContainer)
                Frame.BackgroundTransparency = 1
                Frame.Size = UDim2.new(1, 0, 0, 36)
                
                local Label = CreateTextLabel(Frame, text, Library.Theme.Text, Enum.TextXAlignment.Left)
                Label.Position = UDim2.new(0, 18, 0, 0) -- indented like image
                Label.Size = UDim2.new(1, -18, 0, 16)
                
                local BoxOuter = Instance.new("Frame", Frame)
                BoxOuter.BackgroundColor3 = Library.Theme.Border
                BoxOuter.BorderSizePixel = 0
                BoxOuter.Size = UDim2.new(1, 0, 0, 16)
                BoxOuter.Position = UDim2.new(0, 0, 0, 18)
                
                local BoxBg = Instance.new("Frame", BoxOuter)
                BoxBg.BackgroundColor3 = Library.Theme.WidgetBg
                BoxBg.BorderSizePixel = 0
                BoxBg.Position = UDim2.new(0, 1, 0, 1)
                BoxBg.Size = UDim2.new(1, -2, 1, -2)
                
                local SelectedLabel = CreateTextLabel(BoxBg, default or options[1] or "", Library.Theme.Text, Enum.TextXAlignment.Left)
                SelectedLabel.Position = UDim2.new(0, 5, 0, 0)
                SelectedLabel.Size = UDim2.new(1, -20, 1, 0)
                
                local Arrow = CreateTextLabel(BoxBg, "v", Library.Theme.TextDim, Enum.TextXAlignment.Right)
                Arrow.Position = UDim2.new(1, -15, 0, 0)
                Arrow.Size = UDim2.new(0, 10, 1, 0)
                
                local Btn = Instance.new("TextButton", BoxOuter)
                Btn.BackgroundTransparency = 1
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.Text = ""
                
                -- Floating List
                local ListOuter = Instance.new("Frame", MainGui)
                ListOuter.BackgroundColor3 = Library.Theme.Border
                ListOuter.BorderSizePixel = 0
                ListOuter.Size = UDim2.new(0, BoxOuter.AbsoluteSize.X, 0, #options * 16 + 2)
                ListOuter.Visible = false
                ListOuter.ZIndex = 10
                
                local ListBg = Instance.new("Frame", ListOuter)
                ListBg.BackgroundColor3 = Library.Theme.WidgetBg
                ListBg.BorderSizePixel = 0
                ListBg.Position = UDim2.new(0, 1, 0, 1)
                ListBg.Size = UDim2.new(1, -2, 1, -2)
                ListBg.ZIndex = 10
                
                local ListLayout = Instance.new("UIListLayout", ListBg)
                
                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton", ListBg)
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Size = UDim2.new(1, 0, 0, 16)
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
                    ListOuter.Size = UDim2.new(0, BoxOuter.AbsoluteSize.X, 0, #options * 16 + 2)
                end)
                
                table.insert(Library.Connections, RunService.RenderStepped:Connect(function()
                    if ListOuter.Visible then
                        ListOuter.Position = UDim2.new(0, BoxOuter.AbsolutePosition.X, 0, BoxOuter.AbsolutePosition.Y + 18)
                    end
                end))
            end

            function Group:CreateColorPicker(text, defaultColor, callback)
                local Frame = Instance.new("Frame", ItemsContainer)
                Frame.BackgroundTransparency = 1
                Frame.Size = UDim2.new(1, 0, 0, 16)
                
                local Label = CreateTextLabel(Frame, text, Library.Theme.Text, Enum.TextXAlignment.Left)
                Label.Size = UDim2.new(1, -20, 1, 0)
                
                local ColorBoxOuter = Instance.new("Frame", Frame)
                ColorBoxOuter.BackgroundColor3 = Library.Theme.Border
                ColorBoxOuter.BorderSizePixel = 0
                ColorBoxOuter.Size = UDim2.new(0, 16, 0, 10)
                ColorBoxOuter.Position = UDim2.new(1, -16, 0.5, -5)
                
                local ColorBoxBg = Instance.new("Frame", ColorBoxOuter)
                ColorBoxBg.BackgroundColor3 = defaultColor or Color3.fromRGB(255, 0, 0)
                ColorBoxBg.BorderSizePixel = 0
                ColorBoxBg.Position = UDim2.new(0, 1, 0, 1)
                ColorBoxBg.Size = UDim2.new(1, -2, 1, -2)
                
                local ColorBtn = Instance.new("TextButton", ColorBoxOuter)
                ColorBtn.BackgroundTransparency = 1
                ColorBtn.Size = UDim2.new(1, 0, 1, 0)
                ColorBtn.Text = ""

                -- Simple Color Picker Popup
                local PickerOuter = Instance.new("Frame", MainGui)
                PickerOuter.BackgroundColor3 = Library.Theme.Border
                PickerOuter.BorderSizePixel = 0
                PickerOuter.Size = UDim2.new(0, 150, 0, 150)
                PickerOuter.Visible = false
                PickerOuter.ZIndex = 20

                local PickerBg = Instance.new("Frame", PickerOuter)
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

                local Overlay1 = Instance.new("Frame", PickerBg)
                Overlay1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Overlay1.BorderSizePixel = 0
                Overlay1.Size = UDim2.new(1, 0, 1, 0)
                Overlay1.ZIndex = 21
                local Grad1 = Instance.new("UIGradient", Overlay1)
                Grad1.Rotation = 90
                Grad1.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 1)
                })

                local Overlay2 = Instance.new("Frame", PickerBg)
                Overlay2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                Overlay2.BorderSizePixel = 0
                Overlay2.Size = UDim2.new(1, 0, 1, 0)
                Overlay2.ZIndex = 22
                local Grad2 = Instance.new("UIGradient", Overlay2)
                Grad2.Rotation = 90
                Grad2.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 0)
                })

                local CfgBtn = Instance.new("TextButton", PickerBg)
                CfgBtn.BackgroundTransparency = 1
                CfgBtn.Size = UDim2.new(1, 0, 1, 0)
                CfgBtn.Text = ""
                CfgBtn.ZIndex = 23

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
                    if s < 1 then y = s / 2
                    elseif v < 1 then y = 0.5 + (1 - v) / 2
                    else y = 0.5 end
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
                        if callback then callback(currentColor) end
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

            return Group
        end
        return Tab
    end
    return Window
end

return Library
