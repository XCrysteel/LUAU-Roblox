local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    AimbotEnabled = false,
    TeamCheck = false,
    WallCheck = false,
    AimPart = "Head",
    RandomTarget = false,
    RandomDelay = {0.4, 1.2},
    Sensitivity = 0.5,
    FOV = 300,
    Theme = {
        Main = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(40, 40, 40),
        Text = Color3.fromRGB(255, 255, 255),
        Red = Color3.fromRGB(255, 60, 60),
        Green = Color3.fromRGB(60, 255, 100),
        Blue = Color3.fromRGB(60, 150, 255),
        Stroke = Color3.fromRGB(80, 80, 80)
    }
}

task.spawn(function()
    while true do
        if Settings.RandomTarget then
            Settings.AimPart = (math.random(1, 2) == 1) and "Head" or "HumanoidRootPart"
        end
        task.wait(math.random() * (Settings.RandomDelay[2] - Settings.RandomDelay[1]) + Settings.RandomDelay[1])
    end
end)

local Library = {}
local MainFrame = nil

function Library:CreateUI()
    if CoreGui:FindFirstChild("CrysteelAimUI") then
        CoreGui.CrysteelAimUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrysteelAimUI"
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 240, 0, 300)
    Frame.Position = UDim2.new(0.5, -120, 0.4, 0)
    Frame.BackgroundColor3 = Settings.Theme.Main
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui
    MainFrame = Frame

    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Settings.Theme.Stroke
    Stroke.Thickness = 1.5

    local Title = Instance.new("TextLabel", Frame)
    Title.Text = "CRYSTEEL AIM"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Settings.Theme.Text
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 20

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

    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

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

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)

    local state = default
    Button.MouseButton1Click:Connect(function()
        state = not state
        Button.Text = state and "ON" or "OFF"
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Settings.Theme.Green or Settings.Theme.Red
        }):Play()
        callback(state)
    end)
end

function Library:CreateCycler(parent, text, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 32)
    Frame.BackgroundColor3 = Settings.Theme.Accent

    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

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
    Button.Size = UDim2.new(0, 70, 0, 22)
    Button.Position = UDim2.new(1, -80, 0.5, -11)
    Button.BackgroundColor3 = Settings.Theme.Blue
    Button.Text = "HEAD"
    Button.TextColor3 = Color3.new(0, 0, 0)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)

    local modes = { "HEAD", "TORSO", "RANDOM" }
    local index = 1

    Button.MouseButton1Click:Connect(function()
        index = index % #modes + 1
        local mode = modes[index]
        Button.Text = mode
        callback(mode)
    end)
end

local function IsVisible(target, part)
    if not Settings.WallCheck then
        return true
    end
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { LocalPlayer.Character, target.Character }
    params.FilterType = Enum.RaycastFilterType.Exclude
    return Workspace:Raycast(origin, direction, params) == nil
end

local function GetClosestPlayer()
    local closest, shortest = nil, Settings.FOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer
            and v.Character
            and v.Character:FindFirstChild("Humanoid")
            and v.Character.Humanoid.Health > 0
            and v.Character:FindFirstChild(Settings.AimPart)
        then
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then
                continue
            end
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character[Settings.AimPart].Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if dist < shortest and IsVisible(v, v.Character[Settings.AimPart]) then
                    shortest = dist
                    closest = v
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if Settings.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target and target.Character then
            local part = target.Character:FindFirstChild(Settings.AimPart)
            if part then
                local cf = Camera.CFrame
                Camera.CFrame = cf:Lerp(CFrame.new(cf.Position, part.Position), Settings.Sensitivity)
            end
        end
    end
end)

local Container = Library:CreateUI()

Library:CreateToggle(Container, "TOGGLE", false, function(v)
    Settings.AimbotEnabled = v
end)

Library:CreateToggle(Container, "TEAM Check", false, function(v)
    Settings.TeamCheck = v
end)

Library:CreateToggle(Container, "WALL Check", false, function(v)
    Settings.WallCheck = v
end)

Library:CreateCycler(Container, "TARGET", function(mode)
    if mode == "HEAD" then
        Settings.RandomTarget = false
        Settings.AimPart = "Head"
    elseif mode == "TORSO" then
        Settings.RandomTarget = false
        Settings.AimPart = "HumanoidRootPart"
    else
        Settings.RandomTarget = true
    end
end)

StarterGui:SetCore("SendNotification", {
    Title = "CRYSTEEL AIM",
    Text = "R-CTRL for UI",
    Duration = 5
})

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl and MainFrame then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

