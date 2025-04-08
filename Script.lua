-- Services de base
local players = game:GetService("Players")
local local_player = players.LocalPlayer
local run_service = game:GetService("RunService")
local starter_gui = game:GetService("StarterGui")
local chat_service = game:GetService("Chat")

-- Variables
local aimbot_active = true
local damage_multiplier = 1000  -- L'effet de one-shot (dégâts très élevés)
local target_player = nil  -- Cible actuelle

-- Icône de notification
local icon_id = "rbxassetid://10248739816"  -- Remplace ceci par l'ID de ton icône personnalisée

-- Fonction pour afficher une notification de lancement
local function showLaunchNotification()
    starter_gui:SetCore("SendNotification", {
        Title = "Aimbot Script Activated",  -- Titre de la notification
        Text = "AimBot is now active!",     -- Message de la notification
        Icon = icon_id,                     -- Icône personnalisée
        Duration = 5                        -- Durée de la notification (5 secondes)
    })
end

-- Fonction pour afficher une notification de commande chat
local function showChatNotification(message)
    starter_gui:SetCore("SendNotification", {
        Title = "Chat Command",  -- Titre de la notification
        Text = message,         -- Message de la notification
        Icon = icon_id,         -- Icône personnalisée
        Duration = 5            -- Durée de la notification (5 secondes)
    })
end

-- Fonction pour trouver la cible la plus proche
local function findClosestTarget()
    local closest_distance = math.huge
    local closest_player = nil

    for _, player in pairs(players:GetPlayers()) do
        if player ~= local_player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")
            local distance = (humanoid_root_part.Position - local_player.Character.HumanoidRootPart.Position).Magnitude
            if distance < closest_distance then
                closest_distance = distance
                closest_player = player
            end
        end
    end

    return closest_player
end

-- Fonction de mise à jour de la visée et tir
local function updateAimbot()
    if not aimbot_active or not local_player.Character or not local_player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    -- Trouver la cible la plus proche
    target_player = findClosestTarget()
    if not target_player or not target_player.Character then
        return
    end

    local target_humanoid_root_part = target_player.Character:FindFirstChild("HumanoidRootPart")
    if not target_humanoid_root_part then return end

    -- Calculer la direction vers la cible
    local target_position = target_humanoid_root_part.Position
    local my_position = local_player.Character.HumanoidRootPart.Position
    local direction = (target_position - my_position).unit

    -- Effectuer une visée discrète en douceur
    local aim_smoothness = 0.1  -- 0.1 est une valeur raisonnable pour un mouvement fluide
    local new_look = CFrame.new(my_position, my_position + direction)
    local current_look = local_player.Character.HumanoidRootPart.CFrame

    -- Créer une interpolation fluide pour un aimbot plus discret
    local smooth_cframe = current_look:Lerp(new_look, aim_smoothness)
    local_player.Character.HumanoidRootPart.CFrame = smooth_cframe

    -- Si un outil est en main, activer le tir
    local tool = local_player.Backpack:FindFirstChildOfClass("Tool")
    if tool and tool:IsA("Tool") then
        -- Vérifier si l'outil est activé pour tirer
        local handle = tool:FindFirstChild("Handle")
        if handle then
            -- Appliquer le tir instantané avec un multiplicateur de dégâts
            local humanoid = target_player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- Appliquer un dégât instantané (one shot) à la cible
                humanoid.Health = humanoid.Health - humanoid.Health  -- One-shot (réduit la santé à 0)
            end
        end
    end
end

-- Lancer la notification au début
showLaunchNotification()

-- Fonction pour écouter les messages du chat et activer/désactiver l'aimbot
local function onChatMessage(player, message)
    -- Vérifie que le message vient du joueur local uniquement
    if player == local_player then
        if message:lower() == "?unaimbot" then
            -- Désactiver l'aimbot
            aimbot_active = false
            showChatNotification("Aimbot has been deactivated. Type ?aimbot to reactivate.")
        elseif message:lower() == "?aimbot" then
            -- Réactiver l'aimbot
            aimbot_active = true
            showChatNotification("Aimbot has been reactivated.")
        end
    end
end

-- Connexion à l'événement de chat
local_player.Chatted:Connect(onChatMessage)

-- Mise à jour de l'aimbot en continu
run_service.RenderStepped:Connect(function()
    updateAimbot()
end)
