local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dotgeris/library-roblox/refs/heads/main/gamesense_library.lua"))()

local Window = Library:CreateWindow("Skeet")

-- Use standard material icons via rbxassetid
local TabAim = Window:CreateTab("rbxassetid://6031225815")    -- Target/Aim
local TabAntiAim = Window:CreateTab("rbxassetid://6031262936") -- Person/Alien
local TabVisuals = Window:CreateTab("rbxassetid://6031206881") -- Sun/Visuals
local TabMisc = Window:CreateTab("rbxassetid://6031091004")    -- Settings/Gear
local TabSkins = Window:CreateTab("rbxassetid://6031280882")   -- Palette/Skins
local TabPlayers = Window:CreateTab("rbxassetid://6031262936") -- Person
local TabConfig = Window:CreateTab("rbxassetid://6031225818")  -- Save/Floppy

-- ================= AIMBOT TAB =================
local AimbotLeft = TabAim:CreateGroup("Aimbot", "left")

local CbEnable = AimbotLeft:CreateCheckbox("Enabled", false)
CbEnable:AddKeybind(nil)

AimbotLeft:CreateDropdown("Target selection", {"Cycle", "Distance", "Health"}, "Cycle")
AimbotLeft:CreateDropdown("Target hitbox", {"Head", "Neck", "Chest"}, "Head")

local CbMulti = AimbotLeft:CreateCheckbox("Multi-point", false)
CbMulti:AddKeybind(nil)
AimbotLeft:CreateDropdown(" ", {"-"}, "-")

AimbotLeft:CreateCheckbox("Prefer safe point", false)
local CbForceSafe = AimbotLeft:CreateCheckbox("Force safe point", false)
CbForceSafe:AddKeybind(nil)
AimbotLeft:CreateDropdown("Avoid unsafe hitboxes", {"-"}, "-")

AimbotLeft:CreateCheckbox("Automatic fire", false)
AimbotLeft:CreateCheckbox("Automatic penetration", false)
AimbotLeft:CreateCheckbox("Silent aim", false)

AimbotLeft:CreateSlider("Minimum hit chance", 0, 100, 50, "%")
AimbotLeft:CreateSlider("Minimum damage", 0, 100, 10, "")
AimbotLeft:CreateCheckbox("Automatic scope", false)
AimbotLeft:CreateCheckbox("Reduce aim step", false)
AimbotLeft:CreateSlider("Maximum FOV", 0, 180, 180, "°")

AimbotLeft:CreateCheckbox("Log misses due to spread", true)
AimbotLeft:CreateDropdown("Low FPS mitigations", {"-"}, "-")

-- Right Column
local AimbotRight = TabAim:CreateGroup("Other", "right")

AimbotRight:CreateCheckbox("Remove recoil", false)
AimbotRight:CreateDropdown("Accuracy boost", {"Low", "Medium", "High"}, "Low")

AimbotRight:CreateCheckbox("Delay shot", false)
local CbQuickStop = AimbotRight:CreateCheckbox("Quick stop", false)
CbQuickStop:AddKeybind(nil)
local CbQuickPeek = AimbotRight:CreateCheckbox("Quick peek assist", false)
CbQuickPeek:AddKeybind(nil)
AimbotRight:CreateCheckbox("Anti-aim correction", false)

local CbForceBody = AimbotRight:CreateCheckbox("Force body aim", false)
CbForceBody:AddKeybind(nil)
AimbotRight:CreateCheckbox("Force body aim on peek", false)

local CbDuckPeek = AimbotRight:CreateCheckbox("Duck peek assist", false)
CbDuckPeek:AddKeybind(nil)
local CbDoubleTap = AimbotRight:CreateCheckbox("Double tap", false)
CbDoubleTap:AddKeybind(nil)

print("Skeet Style UI Loaded!")
