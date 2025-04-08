-- Services de base
local players = game:GetService("Players")
local local_player = players.LocalPlayer
local replicated_storage = game:GetService("ReplicatedStorage")
local run_service = game:GetService("RunService")

-- Variables
local aimbot_active = true
local damage_multiplier = 2  -- Dégâts doublés
local target_player = nil  -- Cible actuelle

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

-- Fonction de mise à jour de la visée
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

    -- Appliquer un effet de dégâts X2
    local humanoid = target_player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        -- Utilisation d'un module personnalisé ou méthode pour infliger des dégâts
        humanoid.Health = humanoid.Health - (humanoid.Health * damage_multiplier)
    end
end

-- Mise à jour de l'aimbot en continu
run_service.RenderStepped:Connect(function()
    updateAimbot()
end)
