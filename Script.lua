local players = game:GetService("Players")
local local_player = players.LocalPlayer
local run_service = game:GetService("RunService")
local starter_gui = game:GetService("StarterGui")
local user_input_service = game:GetService("UserInputService")

local aimbot_active = false
local icon_id = "rbxassetid://10248739816"
local screen_gui = Instance.new("ScreenGui")
screen_gui.Parent = local_player.PlayerGui

local frame = Instance.new("Frame")
frame.Parent = screen_gui
frame.Size = UDim2.new(0, 300, 0, 180)
frame.Position = UDim2.new(0.5, -150, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title_label = Instance.new("TextLabel")
title_label.Parent = frame
title_label.Size = UDim2.new(1, 0, 0, 40)
title_label.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
title_label.Text = "AimBot Control"
title_label.TextColor3 = Color3.fromRGB(255, 255, 255)
title_label.TextSize = 20
title_label.TextAlign = Enum.TextAnchor.MiddleCenter
title_label.Font = Enum.Font.GothamBold

local aimbot_button = Instance.new("TextButton")
aimbot_button.Parent = frame
aimbot_button.Size = UDim2.new(1, -40, 0, 40)
aimbot_button.Position = UDim2.new(0, 20, 0, 60)
aimbot_button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
aimbot_button.Text = "AimBot: Activate"
aimbot_button.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbot_button.TextSize = 18
aimbot_button.Font = Enum.Font.GothamMedium
aimbot_button.BorderSizePixel = 0
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

local credit_label = Instance.new("TextLabel")
credit_label.Parent = frame
credit_label.Size = UDim2.new(1, 0, 0, 30)
credit_label.Position = UDim2.new(0, 0, 1, -30)
credit_label.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
credit_label.Text = "Credits: Melouxis"
credit_label.TextColor3 = Color3.fromRGB(255, 255, 255)
credit_label.TextSize = 14
credit_label.TextAlign = Enum.TextAnchor.MiddleCenter
credit_label.Font = Enum.Font.Gotham

local function updateAimbot()
    if not aimbot_active then return end

    local closest_target = nil
    local closest_distance = math.huge

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

    if closest_target then
        local target_humanoid_root_part = closest_target.Character:FindFirstChild("HumanoidRootPart")
        if target_humanoid_root_part then
            local direction = (target_humanoid_root_part.Position - local_player.Character.HumanoidRootPart.Position).unit
            local smoothness = 0.1
            local new_cframe = CFrame.new(local_player.Character.HumanoidRootPart.Position, local_player.Character.HumanoidRootPart.Position + direction)
            local current_cframe = local_player.Character.HumanoidRootPart.CFrame
            local smooth_cframe = current_cframe:Lerp(new_cframe, smoothness)
            local_player.Character.HumanoidRootPart.CFrame = smooth_cframe

            local tool = local_player.Backpack:FindFirstChildOfClass("Tool")
            if tool then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    local humanoid = closest_target.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.Health = 0
                    end
                end
            end
        end
    end
end

run_service.RenderStepped:Connect(function()
    updateAimbot()
end)

user_input_service.InputChanged:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.Touch then
        local new_size = UDim2.new(0, input.Position.X - frame.Position.X.Offset, 0, input.Position.Y - frame.Position.Y.Offset)
        frame.Size = new_size
    end
end)
