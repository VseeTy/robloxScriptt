local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local scriptEnabled = true -- Variable to toggle the script on/off
local clickDetectors = {} -- Store references to all ClickDetectors

-- Create a custom notification GUI
local function createNotification(message)
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    -- Create the ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomNotification"
    screenGui.ResetOnSpawn = false -- Ensure it persists across respawns
    screenGui.Parent = playerGui

    -- Create the TextLabel
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.5, 0, 0.1, 0) -- 50% width, 10% height
    textLabel.Position = UDim2.new(0.25, 0, 0.05, 0) -- Centered at the top
    textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black background
    textLabel.BackgroundTransparency = 0.5 -- Semi-transparent
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 24
    textLabel.Text = message
    textLabel.Parent = screenGui

    -- Automatically remove the notification after 5 seconds
    task.delay(5, function()
        screenGui:Destroy()
    end)
end

local function getFullPath(instance)
    local path = instance.Name
    local parent = instance.Parent
    while parent do
        path = parent.Name .. "/" .. path
        parent = parent.Parent
    end
    return path
end

local function onEntityClicked(player, entity)
    if not scriptEnabled then return end -- Exit if the script is disabled
    local path = getFullPath(entity)
    print("Entity clicked by " .. player.Name .. ": " .. path)

    -- Display the custom notification
    createNotification("Path: " .. path)
end

-- Add ClickDetector to all entities in the workspace
for _, entity in pairs(workspace:GetDescendants()) do
    if entity:IsA("BasePart") then
        local clickDetector = Instance.new("ClickDetector")
        clickDetector.Parent = entity
        clickDetectors[clickDetector] = clickDetector.MouseClick:Connect(function(player)
            if scriptEnabled then
                onEntityClicked(player, entity)
            end
        end)
    end
end

-- Toggle the script on/off when the "H" key is pressed
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- Ignore input if the game is processing it
    if input.KeyCode == Enum.KeyCode.H then
        scriptEnabled = not scriptEnabled
        print("Script is now " .. (scriptEnabled and "enabled" or "disabled"))

        -- Enable or disable all ClickDetectors
        for clickDetector, connection in pairs(clickDetectors) do
            if scriptEnabled then
                clickDetector.MaxActivationDistance = 32 -- Restore default activation distance
                if not connection.Connected then
                    clickDetectors[clickDetector] = clickDetector.MouseClick:Connect(function(player)
                        onEntityClicked(player, clickDetector.Parent)
                    end)
                end
            else
                clickDetector.MaxActivationDistance = 0 -- Disable the clickable cursor
                connection:Disconnect()
            end
        end
    end
end)