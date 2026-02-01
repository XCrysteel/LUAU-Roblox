local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    AimbotEnabled = false,
    TeamCheck = false,
    WallCheck = false,
    AimPart = "Head",
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

local Library = {}
local MainFrame = nil

function Library:CreateUI()
    if game.CoreGui:FindFirstChild("CrysteelAimUI") then
        game.CoreGui.CrysteelAimUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrysteelAimUI"
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local Frame = Instance.new("Frame")
    Frame.Name = "Main"
    Frame.Size = UDim2.new(0, 240, 0, 300)
    Frame.Position = UDim2.new(0.5, -120, 0.4, 0)
    Frame.BackgroundColor3 = Settings.Theme.Main
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui
    MainFrame = Frame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = Frame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Settings.Theme.Stroke
    UIStroke.Thickness = 1.5
    UIStroke.Parent = Frame

    local Title = Instance.new("TextLabel")
    Title.Text = "CRYSTEEL AIM"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Settings.Theme.Text
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 20
    Title.Parent = Frame

    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.Position = UDim2.new(0, 0, 0, 40)
    Line.BackgroundColor3 = Settings.Theme.Stroke
    Line.BorderSizePixel = 0
    Line.Parent = Frame

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -20, 1, -50)
    Container.Position = UDim2.new(0, 10, 0, 50)
    Container.BackgroundTransparency = 1
    Container.Parent = Frame

    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 8)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Parent = Container

    return Container
end

function Library:CreateToggle(parent, text, defaultState, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 32)
    Frame.BackgroundColor3 = Settings.Theme.Accent
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Settings.Theme.Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 50, 0, 22)
    Button.Position = UDim2.new(1, -60, 0.5, -11)
    Button.BackgroundColor3 = defaultState and Settings.Theme.Green or Settings.Theme.Red
    Button.Text = defaultState and "ON" or "OFF"
    Button.TextColor3 = Color3.new(0, 0, 0)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.Parent = Frame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Button

    local currentState = defaultState
    Button.MouseButton1Click:Connect(function()
        currentState = not currentState
        Button.Text = currentState and "ON" or "OFF"
        local targetColor = currentState and Settings.Theme.Green or Settings.Theme.Red
        game:GetService("TweenService"):Create(
            Button,
            TweenInfo.new(0.2),
            { BackgroundColor3 = targetColor }
        ):Play()
        callback(currentState)
    end)
end

function Library:CreateCycler(parent, text, defaultVal, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 32)
    Frame.BackgroundColor3 = Settings.Theme.Accent
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Settings.Theme.Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 60, 0, 22)
    Button.Position = UDim2.new(1, -70, 0.5, -11)
    Button.BackgroundColor3 = Settings.Theme.Blue
    Button.Text = defaultVal
    Button.TextColor3 = Color3.new(0, 0, 0)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.Parent = Frame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        if Button.Text == "HEAD" then
            Button.Text = "TORSO"
            callback("HumanoidRootPart")
        else
            Button.Text = "HEAD"
            callback("Head")
        end
    end)
end

local function IsVisible(target, part)
    if not Settings.WallCheck then
        return true
    end

    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { LocalPlayer.Character, target.Character }
    params.FilterType = Enum.RaycastFilterType.Exclude

    local result = Workspace:Raycast(origin, direction, params)
    return result == nil
end

local function GetClosestPlayer()
    local closestPlr = nil
    local shortestDist = Settings.FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer
            and v.Character
            and v.Character:FindFirstChild("Humanoid")
            and v.Character.Humanoid.Health > 0
            and v.Character:FindFirstChild(Settings.AimPart)
        then
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then
                continue
            end

            local pos, onScreen = Camera:WorldToViewportPoint(
                v.Character[Settings.AimPart].Position
            )

            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if dist < shortestDist then
                    if IsVisible(v, v.Character[Settings.AimPart]) then
                        shortestDist = dist
                        closestPlr = v
                    end
                end
            end
        end
    end

    return closestPlr
end

RunService.RenderStepped:Connect(function()
    if Settings.AimbotEnabled
        and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(Settings.AimPart) then
            local targetPos = target.Character[Settings.AimPart].Position
            local currentCF = Camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, targetPos)
            Camera.CFrame = currentCF:Lerp(targetCF, Settings.Sensitivity)
        end
    end
end)

local Container = Library:CreateUI()

Library:CreateToggle(Container, "AIM-TOGGLE", false, function(state)
    Settings.AimbotEnabled = state
end)

Library:CreateToggle(Container, "TEAM-Check", false, function(state)
    Settings.TeamCheck = state
end)

Library:CreateToggle(Container, "WALL-Check", false, function(state)
    Settings.WallCheck = state
end)

Library:CreateCycler(Container, "TARGET", "HEAD", function(val)
    Settings.AimPart = val
end)

StarterGui:SetCore("SendNotification", {
    Title = "CRYSTEEL AIM",
    Text = "R-CTRL For UI",
    Duration = 5
})

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl and MainFrame then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
