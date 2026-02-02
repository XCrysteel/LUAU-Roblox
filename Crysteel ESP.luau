local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    MasterEnabled = false,
    ShowName = false,
    ShowHP = false,
    ShowTeam = false,
    ShowBody = false,
    ShowDistance = false,
    Theme = {
        Main = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(40, 40, 40),
        Text = Color3.fromRGB(255, 255, 255),
        Red = Color3.fromRGB(255, 60, 60),
        Green = Color3.fromRGB(60, 255, 100),
        Stroke = Color3.fromRGB(80, 80, 80),
        ChamFill = Color3.fromRGB(255, 0, 0),
        ChamOutline = Color3.fromRGB(255, 255, 255)
    }
}

local Library = {}
local MainFrame = nil

function Library:CreateUI()
    if game.CoreGui:FindFirstChild("CrysteelUI") then
        game.CoreGui.CrysteelUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrysteelUI"
    pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local Frame = Instance.new("Frame")
    Frame.Name = "Main"
    Frame.Size = UDim2.new(0, 240, 0, 360)
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
    Title.Text = "CRYSTEEL ESP"
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
    UIList.Padding = UDim.new(0, 6)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Parent = Container

    return Container
end

function Library:CreateToggle(parent, text, defaultState, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 32)
    ToggleFrame.BackgroundColor3 = Settings.Theme.Accent
    ToggleFrame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Settings.Theme.Text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 50, 0, 22)
    Button.Position = UDim2.new(1, -60, 0.5, -11)
    Button.BackgroundColor3 = defaultState and Settings.Theme.Green or Settings.Theme.Red
    Button.Text = defaultState and "ON" or "OFF"
    Button.TextColor3 = Color3.new(0, 0, 0)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.Parent = ToggleFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Button

    local currentState = defaultState

    Button.MouseButton1Click:Connect(function()
        currentState = not currentState
        Button.Text = currentState and "ON" or "OFF"

        local TweenService = game:GetService("TweenService")
        TweenService:Create(
            Button,
            TweenInfo.new(0.2),
            { BackgroundColor3 = currentState and Settings.Theme.Green or Settings.Theme.Red }
        ):Play()

        callback(currentState)
    end)
end

local ESP_Storage = {}

local function CreateESP(player)
    if player == LocalPlayer then
        return
    end

    if ESP_Storage[player] then
        if ESP_Storage[player].Billboard then
            ESP_Storage[player].Billboard:Destroy()
        end
        if ESP_Storage[player].Highlight then
            ESP_Storage[player].Highlight:Destroy()
        end
        ESP_Storage[player] = nil
    end

    local storage = {
        Billboard = nil,
        Highlight = nil
    }

    local bg = Instance.new("BillboardGui")
    bg.Name = "CrysteelVisuals"
    bg.AlwaysOnTop = true
    bg.Size = UDim2.new(0, 200, 0, 150)
    bg.StudsOffset = Vector3.new(0, 4, 0)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = bg

    local list = Instance.new("UIListLayout")
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.VerticalAlignment = Enum.VerticalAlignment.Bottom
    list.Padding = UDim.new(0, 0)
    list.Parent = container

    local function createLabel(name, color, text)
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Text = text
        lbl.TextColor3 = color
        lbl.TextStrokeTransparency = 0
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 0, 14)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.Visible = false
        lbl.Parent = container
        return lbl
    end

    createLabel("NameLabel", Color3.new(1, 1, 1), player.Name)
    createLabel("HPLabel", Color3.fromRGB(80, 255, 100), "HP: 100")
    createLabel("TeamLabel", Color3.fromRGB(255, 255, 0), "Team")
    createLabel("DistLabel", Color3.fromRGB(0, 255, 255), "Dist: 0")

    storage.Billboard = bg

    local hl = Instance.new("Highlight")
    hl.Name = "CrysteelChams"
    hl.FillColor = player.TeamColor.Color
    hl.OutlineColor = Settings.Theme.ChamOutline
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = false

    storage.Highlight = hl
    ESP_Storage[player] = storage

    local function Attach(char)
        if not char then
            return
        end

        local head = char:WaitForChild("Head", 5)
        if head then
            bg.Adornee = head
            bg.Parent = head
        end

        hl.Adornee = char
        hl.Parent = char

        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            local hpLbl = bg.Frame.HPLabel
            hum.HealthChanged:Connect(function()
                hpLbl.Text = "HP: " .. math.floor(hum.Health)
                hpLbl.TextColor3 = Color3.fromHSV((hum.Health / hum.MaxHealth) * 0.3, 1, 1)
            end)
            hpLbl.Text = "HP: " .. math.floor(hum.Health)
        end
    end

    if player.Character then
        Attach(player.Character)
    end

    player.CharacterAdded:Connect(Attach)
end

RunService.RenderStepped:Connect(function()
    if not Settings.MasterEnabled then
        return
    end

    for player, store in pairs(ESP_Storage) do
        if
            player.Character
            and player.Character:FindFirstChild("HumanoidRootPart")
            and LocalPlayer.Character
            and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        then
            if store.Billboard and store.Billboard.Frame then
                store.Billboard.Enabled = true
                local f = store.Billboard.Frame

                f.NameLabel.Visible = Settings.ShowName
                f.HPLabel.Visible = Settings.ShowHP

                if Settings.ShowTeam then
                    f.TeamLabel.Visible = true
                    f.TeamLabel.Text = "[T] " .. tostring(player.Team)
                    f.TeamLabel.TextColor3 = player.TeamColor.Color
                else
                    f.TeamLabel.Visible = false
                end

                if Settings.ShowDistance then
                    f.DistLabel.Visible = true
                    local mag =
                        (LocalPlayer.Character.HumanoidRootPart.Position
                        - player.Character.HumanoidRootPart.Position).Magnitude
                    f.DistLabel.Text = "[" .. math.floor(mag) .. " Studs]"
                else
                    f.DistLabel.Visible = false
                end
            end

            if store.Highlight then
                store.Highlight.Enabled = Settings.ShowBody
                if Settings.ShowBody then
                    store.Highlight.FillColor = player.TeamColor.Color
                end
            end
        else
            if store.Billboard then
                store.Billboard.Enabled = false
            end
            if store.Highlight then
                store.Highlight.Enabled = false
            end
        end
    end
end)

local Container = Library:CreateUI()

Library:CreateToggle(Container, "TOGGLE", false, function(state)
    Settings.MasterEnabled = state
    if not state then
        for _, store in pairs(ESP_Storage) do
            if store.Billboard then
                store.Billboard.Enabled = false
            end
            if store.Highlight then
                store.Highlight.Enabled = false
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if not ESP_Storage[p] then
                CreateESP(p)
            end
        end
    end
end)

Library:CreateToggle(Container, "ESP Name", false, function(state)
    Settings.ShowName = state
end)

Library:CreateToggle(Container, "ESP Health", false, function(state)
    Settings.ShowHP = state
end)

Library:CreateToggle(Container, "ESP Team", false, function(state)
    Settings.ShowTeam = state
end)

Library:CreateToggle(Container, "ESP Bodyparts", false, function(state)
    Settings.ShowBody = state
end)

Library:CreateToggle(Container, "ESP Distance", false, function(state)
    Settings.ShowDistance = state
end)

Players.PlayerAdded:Connect(function(p)
    if Settings.MasterEnabled then
        CreateESP(p)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if ESP_Storage[p] then
        if ESP_Storage[p].Billboard then
            ESP_Storage[p].Billboard:Destroy()
        end
        if ESP_Storage[p].Highlight then
            ESP_Storage[p].Highlight:Destroy()
        end
        ESP_Storage[p] = nil
    end
end)

StarterGui:SetCore("SendNotification", {
    Title = "CRYSTEEL Initiated",
    Text = "R-CTRL For UI",
    Duration = 5
})

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl and MainFrame then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
