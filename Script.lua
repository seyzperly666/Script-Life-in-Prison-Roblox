-- Services
local players = game:GetService("Players")
local local_player = players.LocalPlayer
local starter_gui = game:GetService("StarterGui")
local user_input_service = game:GetService("UserInputService")
local tween_service = game:GetService("TweenService")
local run_service = game:GetService("RunService")
local replicated_storage = game:GetService("ReplicatedStorage")

-- Création de l'interface du panel admin
local screen_gui = Instance.new("ScreenGui")
screen_gui.Parent = local_player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 500)
frame.Position = UDim2.new(0.5, -175, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(34, 34, 34) -- Dark background
frame.BackgroundTransparency = 0.85
frame.BorderSizePixel = 0
frame.Parent = screen_gui

-- Ombres et coins arrondis pour un effet moderne
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Titre du panel
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 350, 0, 60)
title.Text = "Admin Control Panel"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextStrokeTransparency = 0.8
title.Parent = frame

-- Création des boutons stylisés
local function createButton(name, position, callback, color, text)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 320, 0, 50)
    button.Position = position
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Font = Enum.Font.Gotham
    button.TextSize = 18
    button.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    button.MouseButton1Click:Connect(callback)

    return button
end

-- Fonction pour tuer un joueur
local function killPlayer(player)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        humanoid.Health = 0
    end
end

-- Fonction pour kick un joueur
local function kickPlayer(player)
    if player ~= local_player then
        player:Kick("You have been kicked by an admin.")
    end
end

-- Fonction pour aimbot (auto-cibler un joueur)
local function aimbot(target)
    local character = local_player.Character
    if not character then return end
    
    local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")
    if not humanoid_root_part then return end
    
    local target_character = target.Character
    if not target_character then return end

    local target_humanoid_root_part = target_character:FindFirstChild("HumanoidRootPart")
    if not target_humanoid_root_part then return end

    -- Effectue un aimbot en dirigeant le regard du joueur vers la cible
    character:SetPrimaryPartCFrame(target_humanoid_root_part.CFrame)
end

-- Création des boutons
local button_kill = createButton("Kill Player", UDim2.new(0, 15, 0, 80), function()
    local target = players:GetPlayers()[2] -- Change ici pour cibler un joueur spécifique
    killPlayer(target)
end, Color3.fromRGB(255, 50, 50), "Kill Player")

local button_kick = createButton("Kick Player", UDim2.new(0, 15, 0, 150), function()
    local target = players:GetPlayers()[2] -- Change ici pour cibler un joueur spécifique
    kickPlayer(target)
end, Color3.fromRGB(50, 150, 255), "Kick Player")

local button_aimbot = createButton("Aimbot", UDim2.new(0, 15, 0, 220), function()
    local target = players:GetPlayers()[2] -- Change ici pour cibler un joueur spécifique
    aimbot(target)
end, Color3.fromRGB(50, 255, 50), "Aimbot")

-- Ajouter une animation de notification
starter_gui:SetCore("SendNotification", {
    Title = "Admin Panel Loaded",
    Text = "Welcome to the Admin Panel!",
    Icon = "rbxassetid://10248739816"
})

-- Effet de survol des boutons
for _, button in pairs(frame:GetChildren()) do
    if button:IsA("TextButton") then
        button.MouseEnter:Connect(function()
            tween_service:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)

        button.MouseLeave:Connect(function()
            tween_service:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = button.BackgroundColor3}):Play()
        end)
    end
end
