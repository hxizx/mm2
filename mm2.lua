if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local ESPObjects = {}
local Murderer, Sheriff, GunDrop = nil, nil, nil
local ESPEnabled = false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 400)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.Parent = ScreenGui

local Dragging, DragInput, StartPos, StartMousePos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        StartMousePos = input.Position
        StartPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        DragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        local Delta = input.Position - StartMousePos
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end
end)

local Title = Instance.new("TextLabel")
Title.Text = "MM2 ESP & TP"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

local function createButton(text, pos, callback)
    local Button = Instance.new("TextButton")
    Button.Text = text
    Button.Size = UDim2.new(1, -10, 0, 40)
    Button.Position = UDim2.new(0, 5, 0, pos)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 16
    Button.Parent = MainFrame
    Button.MouseButton1Click:Connect(callback)
end

local function createESP(player, color)
    if ESPObjects[player] then return end

    local highlight = Instance.new("Highlight")
    highlight.Parent = game.CoreGui
    highlight.Adornee = player.Character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0

    ESPObjects[player] = highlight

    player.CharacterAdded:Connect(function()
        wait(1)
        highlight.Adornee = player.Character
    end)
end

local function removeESP()
    for _, v in pairs(ESPObjects) do
        if v then v:Destroy() end
    end
    ESPObjects = {}
end

local function findRoles()
    removeESP()
    Murderer, Sheriff, GunDrop = nil, nil, nil

    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local hasGun, hasKnife = false, false

            for _, item in pairs(player.Backpack:GetChildren()) do
                if item:IsA("Tool") then
                    if item.Name == "Gun" then hasGun = true end
                    if item.Name == "Knife" then hasKnife = true end
                end
            end
            for _, item in pairs(player.Character:GetChildren()) do
                if item:IsA("Tool") then
                    if item.Name == "Gun" then hasGun = true end
                    if item.Name == "Knife" then hasKnife = true end
                end
            end

            if hasGun then
                Sheriff = player
                createESP(player, Color3.fromRGB(0, 0, 255))
            end
            if hasKnife then
                Murderer = player
                createESP(player, Color3.fromRGB(255, 0, 0))
            end
        end
    end

    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Tool") and obj.Name == "Gun" then
            GunDrop = obj
        end
    end
end

local function teleportToPlayer(player)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    end
end

local function teleportToGun()
    if GunDrop and GunDrop.Parent == workspace then
        LocalPlayer.Character.HumanoidRootPart.CFrame = GunDrop.Handle.CFrame
    end
end

createButton("Toggle ESP", 40, function()
    ESPEnabled = not ESPEnabled
    if ESPEnabled then
        findRoles()
    else
        removeESP()
    end
end)

createButton("Teleport to Murderer", 90, function()
    teleportToPlayer(Murderer)
end)

createButton("Teleport to Sheriff", 140, function()
    teleportToPlayer(Sheriff)
end)

createButton("Teleport to Dropped Gun", 190, function()
    teleportToGun()
end)

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -10, 0, 40)
SearchBox.Position = UDim2.new(0, 5, 0, 240)
SearchBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
SearchBox.TextColor3 = Color3.new(1, 1, 1)
SearchBox.Font = Enum.Font.SourceSansBold
SearchBox.TextSize = 14
SearchBox.Text = "Enter Player Name"
SearchBox.Parent = MainFrame

createButton("Teleport to Player", 290, function()
    local search = SearchBox.Text:lower()
    local foundPlayer = nil

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():sub(1, #search) == search then
            foundPlayer = player
            break
        end
    end

    if foundPlayer then
        teleportToPlayer(foundPlayer)
    else
        SearchBox.Text = "Player Not Found!"
        wait(1)
        SearchBox.Text = "Enter Player Name"
    end
end)

spawn(function()
    while wait(1) do
        if ESPEnabled then
            findRoles()
        end
    end
end)
