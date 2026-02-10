local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    ExpanderEnabled = false,
    TeamCheck = false,
    ShowHitbox = false,
    HitboxSize = 10,
    TargetPart = "HumanoidRootPart",
    ActivationInput = Enum.KeyCode.RightControl,
    Theme = {
        Main = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(40, 40, 40),
        Text = Color3.fromRGB(255, 255, 255),
        Red = Color3.fromRGB(255, 60, 60),
        Green = Color3.fromRGB(60, 255, 100),
        Blue = Color3.fromRGB(60, 150, 255),
        Stroke = Color3.fromRGB(80, 80, 80),
    }
}

local CONFIG_FILE = "crysteel_hitbox_config.json"

local FS = {
    readfile = (readfile),
    writefile = (writefile),
    isfile = (isfile),
}

local function LoadConfig()
    if not FS.isfile or not FS.readfile then return nil end
    if not FS.isfile(CONFIG_FILE) then return nil end

    local raw = FS.readfile(CONFIG_FILE)
    local decoded = HttpService:JSONDecode(raw)

    if type(decoded) ~= "table" then return nil end
    return decoded
end

local function SaveConfig(data)
    if not FS.writefile then return end
    FS.writefile(CONFIG_FILE, HttpService:JSONEncode(data))
end

local function CommitSettings()
    SaveConfig({
        ExpanderEnabled = Settings.ExpanderEnabled,
        TeamCheck = Settings.TeamCheck,
        ShowHitbox = Settings.ShowHitbox,
        HitboxSize = Settings.HitboxSize,
    })
end

do
    local saved = LoadConfig()
    if saved then
        Settings.ExpanderEnabled = saved.ExpanderEnabled
        Settings.TeamCheck = saved.TeamCheck
        Settings.ShowHitbox = saved.ShowHitbox
        Settings.HitboxSize = saved.HitboxSize or 10
    end
end

local Library = {}
local MainFrame = nil

function Library:CreateUI()
    if CoreGui:FindFirstChild("CrysteelHitboxUI") then
        CoreGui.CrysteelHitboxUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrysteelHitboxUI"

    pcall(function()
        ScreenGui.Parent = CoreGui
    end)

    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 240, 0, 350)
    Frame.Position = UDim2.new(0.5, -120, 0.4, 0)
    Frame.BackgroundColor3 = Settings.Theme.Main
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Visible = false
    Frame.Draggable = true
    Frame.Parent = ScreenGui

    MainFrame = Frame

    local UICorner = Instance.new("UICorner", Frame)
    UICorner.CornerRadius = UDim.new(0, 6)

    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Settings.Theme.Stroke
    Stroke.Thickness = 1.5

    local Title = Instance.new("TextLabel", Frame)
    Title.Text = "CRYSTEEL EXPANDER"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Settings.Theme.Text
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 18

    local Line = Instance.new("Frame", Frame)
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.Position = UDim2.new(0, 0, 0, 40)
    Line.BackgroundColor3 = Settings.Theme.Stroke
    Line.BorderSizePixel = 0

    local Container = Instance.new("Frame", Frame)
    Container.Size = UDim2.new(1, -20, 1, -50)
    Container.Position = UDim2.new(0, 10, 0, 50)
    Container.BackgroundTransparency = 1

    local UIList = Instance.new("UIListLayout", Container)
    UIList.Padding = UDim.new(0, 8)

    return Container
end

function Library:CreateToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 32)
    Frame.BackgroundColor3 = Settings.Theme.Accent

    local Corner = Instance.new("UICorner", Frame)
    Corner.CornerRadius = UDim.new(0, 4)

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = text
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Settings.Theme.Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Button = Instance.new("TextButton", Frame)
    Button.Size = UDim2.new(0, 50, 0, 22)
    Button.Position = UDim2.new(1, -60, 0.5, -11)
    Button.Text = default and "ON" or "OFF"
    Button.BackgroundColor3 = default and Settings.Theme.Green or Settings.Theme.Red
    Button.TextColor3 = Color3.new(0, 0, 0)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12

    local BtnCorner = Instance.new("UICorner", Button)
    BtnCorner.CornerRadius = UDim.new(0, 4)

    local state = default

    Button.MouseButton1Click:Connect(function()
        state = not state
        Button.Text = state and "ON" or "OFF"

        TweenService:Create(
            Button,
            TweenInfo.new(0.2),
            { BackgroundColor3 = state and Settings.Theme.Green or Settings.Theme.Red }
        ):Play()

        callback(state)
    end)
end

function Library:CreateSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 45)
    Frame.BackgroundColor3 = Settings.Theme.Accent

    local Corner = Instance.new("UICorner", Frame)
    Corner.CornerRadius = UDim.new(0, 4)

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = text
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Settings.Theme.Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ValueLabel = Instance.new("TextLabel", Frame)
    ValueLabel.Text = tostring(default)
    ValueLabel.Size = UDim2.new(0, 40, 0, 20)
    ValueLabel.Position = UDim2.new(1, -50, 0, 2)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.TextColor3 = Settings.Theme.Blue
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local SliderBar = Instance.new("Frame", Frame)
    SliderBar.Size = UDim2.new(1, -20, 0, 6)
    SliderBar.Position = UDim2.new(0, 10, 0, 30)
    SliderBar.BackgroundColor3 = Settings.Theme.Main

    local BarCorner = Instance.new("UICorner", SliderBar)
    BarCorner.CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", SliderBar)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Settings.Theme.Blue

    local FillCorner = Instance.new("UICorner", Fill)
    FillCorner.CornerRadius = UDim.new(1, 0)

    local Trigger = Instance.new("TextButton", SliderBar)
    Trigger.Size = UDim2.new(1, 0, 1, 0)
    Trigger.BackgroundTransparency = 1
    Trigger.Text = ""

    local isDragging = false

    local function Update(input)
        local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(((pos * (max - min)) + min) * 10) / 10

        TweenService:Create(Fill, TweenInfo.new(0.1), {
            Size = UDim2.new(pos, 0, 1, 0)
        }):Play()

        ValueLabel.Text = tostring(value)
        callback(value)
    end

    Trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            Update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(input)
        end
    end)
end

local function RevertPlayer(player)
    if not player or not player.Character then return end

    local part = player.Character:FindFirstChild(Settings.TargetPart)
    if part then
        part.Transparency = 1
        part.CanCollide = true
        part.Size = Vector3.new(2, 2, 1)
    end
end

local function UpdateHitboxes()
    if not Settings.ExpanderEnabled then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end

        local char = plr.Character
        if not char then continue end

        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        if Settings.TeamCheck and plr.Team == LocalPlayer.Team then
            RevertPlayer(plr)
            continue
        end

        local part = char:FindFirstChild(Settings.TargetPart)
        if part then
            part.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
            part.Transparency = Settings.ShowHitbox and 0.6 or 1
            part.CanCollide = false
            part.Material = Enum.Material.ForceField
            part.Color = Settings.Theme.Red
        end
    end
end

RunService.Heartbeat:Connect(UpdateHitboxes)

local Container = Library:CreateUI()

Library:CreateToggle(Container, "ENABLE EXPANDER", Settings.ExpanderEnabled, function(v)
    Settings.ExpanderEnabled = v
    if not v then
        for _, p in pairs(Players:GetPlayers()) do
            RevertPlayer(p)
        end
    end
    CommitSettings()
end)

Library:CreateSlider(Container, "SIZE", 2, 50, Settings.HitboxSize, function(v)
    Settings.HitboxSize = v
    CommitSettings()
end)

Library:CreateToggle(Container, "SHOW HITBOX", Settings.ShowHitbox, function(v)
    Settings.ShowHitbox = v
    CommitSettings()
end)

Library:CreateToggle(Container, "TEAM CHECK", Settings.TeamCheck, function(v)
    Settings.TeamCheck = v
    CommitSettings()
end)

StarterGui:SetCore("SendNotification", {
    Title = "CRYSTEEL EXPANDER",
    Text = "R-CTRL to toggle UI",
    Duration = 5,
})

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.ActivationInput and MainFrame then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
