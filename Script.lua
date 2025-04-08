-- Services Roblox
local players = game:GetService("Players")
local local_player = players.LocalPlayer
local run_service = game:GetService("RunService")
local starter_gui = game:GetService("StarterGui")
local user_input_service = game:GetService("UserInputService")

-- Variables
local aimbot_active = false
local icon_id = "rbxassetid://10248739816"  -- ID de l'icône personnalisée
local dragging = false
local last_drag_pos = Vector2.new(0, 0)

-- Création de l'interface graphique
local screen_gui = Instance.new("ScreenGui")
screen_gui.Parent = local_player.PlayerGui

local frame = Instance.new("Frame")
frame.Parent = screen_gui
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 0
frame.Visible = true
frame.Active = true
frame.Draggable = false

-- Fonction pour gérer le redimensionnement avec les doigts
local function onInputChanged(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.Touch then
        local new_size = UDim2.new(0, input.Position.X - frame.Position.X.Offset, 0, input.Position.Y - frame.Position.Y.Offset)
        frame.Size = new_size
    end
end

-- Bouton de fermeture (croix rouge)
local close_button = Instance.new("TextButton")
close_button.Parent = frame
close_button.Size = UDim2.new(0, 40, 0, 40)
close_button.Position = UDim2.new(1, -45, 0, 5)
close_button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
close_button.Text = "X"
close_button.TextColor3 = Color3.fromRGB(255, 255, 255)
close_button.TextSize = 24
close_button.TextButton1Click:Connect(function()
    screen_gui:Destroy()  -- Ferme le GUI
end)

-- Titre
local title_label = Instance.new("TextLabel")
title_label.Parent = frame
title_label.Size = UDim2.new(1, 0, 0, 50)
title_label.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
title_label.Text = "AimBot Control"
title_label.TextColor3 = Color3.fromRGB(255, 255, 255)
title_label.TextSize = 20
title_label.TextAlign = Enum.TextAnchor.MiddleCenter

-- Bouton Aimbot
local aimbot_button = Instance.new("TextButton")
aimbot_button.Parent = frame
aimbot_button.Size = UDim2.new(1, -40, 0, 40)
aimbot_button.Position = UDim2.new(0, 20, 0, 60)
aimbot_button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
aimbot_button.Text = "AimBot: Activate"
aimbot_button.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbot_button.TextSize = 18
aimbot_button.MouseButton1Click:Connect(function()
    if aimbot_active then
        aimbot_active = false
        aimbot_button.Text = "AimBot: Activate"
        starter_gui:SetCore("SendNotification", {
            Title = "AimBot Deactivated",
            Text = "AimBot has been deactivated.",
            Icon = icon_id,
            Duration = 5
        })
    else
        aimbot_active = true
        aimbot_button.Text = "AimBot: Deactivate"
        starter_gui:SetCore("SendNotification", {
            Title = "AimBot Activated",
            Text = "AimBot is now active!",
            Icon = icon_id,
            Duration = 5
        })
    end
end)

-- Crédit
local credit_label = Instance.new("TextLabel")
credit_label.Parent = frame
credit_label.Size = UDim2.new(1, 0, 0, 30)
credit_label.Position = UDim2.new(0, 0, 1, -30)
credit_label.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
credit_label.Text = "Credits: Melouxis"
credit_label.TextColor3 = Color3.fromRGB(255, 255, 255)
credit_label.TextSize = 16
credit_label.TextAlign = Enum.TextAnchor.MiddleCenter

-- Fonction d'activation du aimbot
local function updateAimbot()
    if not aimbot_active then return end

    local closest_target = nil
    local closest_distance = math.huge

    -- Trouver la cible la plus proche
    for _, player in pairs(players:GetPlayers()) do
        if player == local_player then continue end

        local player_character = player.Character
        if player_character then
            local humanoid_root_part = player_character:FindFirstChild("HumanoidRootPart")
            if humanoid_root_part then
                local distance = (humanoid_root_part.Position - local_player.Character.HumanoidRootPart.Position).Magnitude
                if distance < closest_distance then
                    closest_distance = distance
                    closest_target = player
                end
            end
        end
    end

    -- Si une cible est trouvée, viser et tirer
    if closest_target then
        local target_humanoid_root_part = closest_target.Character:FindFirstChild("HumanoidRootPart")
        if target_humanoid_root_part then
            -- Viser la cible avec une visée fluide
            local direction = (target_humanoid_root_part.Position - local_player.Character.HumanoidRootPart.Position).unit
            local smoothness = 0.1
            local new_cframe = CFrame.new(local_player.Character.HumanoidRootPart.Position, local_player.Character.HumanoidRootPart.Position + direction)
            local current_cframe = local_player.Character.HumanoidRootPart.CFrame
            local smooth_cframe = current_cframe:Lerp(new_cframe, smoothness)
            local_player.Character.HumanoidRootPart.CFrame = smooth_cframe

            -- Appliquer les dégâts à la cible (one-shot)
            local tool = local_player.Backpack:FindFirstChildOfClass("Tool")
            if tool then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    -- Appliquer les dégâts (one-shot)
                    local humanoid = closest_target.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.Health = 0  -- One-shot
                    end
                end
            end
        end
    end
end

-- Événement de redimensionnement sur mobile
user_input_service.InputChanged:Connect(onInputChanged)

-- Boucle d'actualisation de l'aimbot
run_service.RenderStepped:Connect(function()
    updateAimbot()
end)
