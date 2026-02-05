
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Camera: Camera = Workspace.CurrentCamera
local LocalPlayer: Player = Players.LocalPlayer


local Settings = {
    AimbotEnabled = false,
    TeamCheck = false,
    WallCheck = false,
    AimPart = "Head",
    RandomTarget = false,
    RandomDelay = { 0.4, 1.2 },
    Sensitivity = 0.5,
    FOV = 300,

    ActivationInput = Enum.UserInputType.MouseButton2,

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



type PersistedSettings = {
    AimbotEnabled: boolean,
    TeamCheck: boolean,
    WallCheck: boolean,
    AimPart: string,
    RandomTarget: boolean,
    Sensitivity: number,
    FOV: number,
}


local CONFIG_FILE: string = "crysteel_aim_config.json"

local FS = {
    readfile = (readfile :: any),
    writefile = (writefile :: any),
    isfile = (isfile :: any),
}

local function LoadConfig(): PersistedSettings?
    if not FS.isfile or not FS.readfile then
        return nil
    end

    if not FS.isfile(CONFIG_FILE) then
        return nil
    end

    local raw: string = FS.readfile(CONFIG_FILE)
    local decoded: unknown = HttpService:JSONDecode(raw)

    if type(decoded) ~= "table" then
        return nil
    end

    return decoded :: PersistedSettings
end

local function SaveConfig(data: PersistedSettings): ()
    if not FS.writefile then
        return
    end

    FS.writefile(CONFIG_FILE, HttpService:JSONEncode(data))
end

local function CommitSettings(): ()
    SaveConfig({
        AimbotEnabled = Settings.AimbotEnabled,
        TeamCheck = Settings.TeamCheck,
        WallCheck = Settings.WallCheck,
        AimPart = Settings.AimPart,
        RandomTarget = Settings.RandomTarget,
        Sensitivity = Settings.Sensitivity,
        FOV = Settings.FOV,
    })
end

do
    local saved: PersistedSettings? = LoadConfig()
    if saved then
        Settings.AimbotEnabled = saved.AimbotEnabled
        Settings.TeamCheck = saved.TeamCheck
        Settings.WallCheck = saved.WallCheck
        Settings.AimPart = saved.AimPart
        Settings.RandomTarget = saved.RandomTarget
        Settings.Sensitivity = saved.Sensitivity
        Settings.FOV = saved.FOV
    end
end



task.spawn(function()
    while true do
        if Settings.RandomTarget then
            Settings.AimPart = (math.random(1, 2) == 1) and "Head" or "HumanoidRootPart"
        end

        task.wait(
            math.random() * (Settings.RandomDelay[2] - Settings.RandomDelay[1])
                + Settings.RandomDelay[1]
        )
    end
end)



local Library = {}
local MainFrame: Frame?

function Library:CreateUI(): Frame
    if CoreGui:FindFirstChild("CrysteelAimUI") then
        CoreGui.CrysteelAimUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrysteelAimUI"

    pcall(function()
        ScreenGui.Parent = CoreGui
    end)

    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 240, 0, 330)
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

function Library:CreateToggle(
    parent: Instance,
    text: string,
    default: boolean,
    callback: (boolean) -> ()
): ()
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

    local state: boolean = default

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

function Library:CreateKeybindToggle(
    parent: Instance,
    text: string,
    callback: (Enum.UserInputType | Enum.KeyCode) -> ()
): ()
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
    Button.Size = UDim2.new(0, 90, 0, 22)
    Button.Position = UDim2.new(1, -100, 0.5, -11)
    Button.BackgroundColor3 = Settings.Theme.Blue
    Button.TextColor3 = Color3.new(0, 0, 0)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)

    local listening: boolean = false

    local function update(input: Enum.UserInputType | Enum.KeyCode)
        Button.Text = input.Name
    end

    update(Settings.ActivationInput)

    Button.MouseButton1Click:Connect(function()
        listening = true
        Button.Text = "PRESS..."
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp or not listening then
            return
        end

        if input.UserInputType == Enum.UserInputType.Keyboard then
            callback(input.KeyCode)
            update(input.KeyCode)
        else
            callback(input.UserInputType)
            update(input.UserInputType)
        end

        listening = false
    end)
end



local function IsVisible(target: Player, part: BasePart): boolean
    if not Settings.WallCheck then
        return true
    end

    local origin: Vector3 = Camera.CFrame.Position
    local direction: Vector3 = part.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, target.Character }

    return Workspace:Raycast(origin, direction, params) == nil
end

local function GetClosestPlayer(): Player?
    local closest: Player? = nil
    local shortest: number = Settings.FOV

    local mousePos: Vector2 = UserInputService:GetMouseLocation()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then
            continue
        end

        local char = plr.Character
        if not char then
            continue
        end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            continue
        end

        if Settings.TeamCheck and plr.Team == LocalPlayer.Team then
            continue
        end

        local part = char:FindFirstChild(Settings.AimPart)
        if not part then
            continue
        end

        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then
            continue
        end

        local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
        if dist < shortest and IsVisible(plr, part) then
            shortest = dist
            closest = plr
        end
    end

    return closest
end

local function IsActivationHeld(): boolean
    local input = Settings.ActivationInput

    if typeof(input) == "EnumItem" then
        if input.EnumType == Enum.UserInputType then
            return UserInputService:IsMouseButtonPressed(input)
        elseif input.EnumType == Enum.KeyCode then
            return UserInputService:IsKeyDown(input)
        end
    end

    return false
end

RunService.RenderStepped:Connect(function()
    if not Settings.AimbotEnabled then
        return
    end

    if not IsActivationHeld() then
        return
    end

    local target = GetClosestPlayer()
    if not target or not target.Character then
        return
    end

    local part = target.Character:FindFirstChild(Settings.AimPart)
    if not part then
        return
    end

    local cf = Camera.CFrame
    Camera.CFrame = cf:Lerp(
        CFrame.new(cf.Position, part.Position),
        Settings.Sensitivity
    )
end)



local Container = Library:CreateUI()

Library:CreateToggle(Container, "TOGGLE", Settings.AimbotEnabled, function(v)
    Settings.AimbotEnabled = v
    CommitSettings()
end)

Library:CreateToggle(Container, "TEAM CHECK", Settings.TeamCheck, function(v)
    Settings.TeamCheck = v
    CommitSettings()
end)

Library:CreateToggle(Container, "WALL CHECK", Settings.WallCheck, function(v)
    Settings.WallCheck = v
    CommitSettings()
end)

Library:CreateKeybindToggle(Container, "AIM KEY", function(input)
    Settings.ActivationInput = input
    CommitSettings()
end)

StarterGui:SetCore("SendNotification", {
    Title = "CRYSTEEL AIM",
    Text = "R-CTRL to toggle UI",
    Duration = 5,
})

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl and MainFrame then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
	
