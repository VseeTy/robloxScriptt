local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local scriptEnabled = true -- Variable to toggle the script on/off
local clickDetectors = {} -- Store references to all ClickDetectors

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

    -- Display the path as a notification
    StarterGui:SetCore("SendNotification", {
        Title = "Entity Clicked",
        Text = "Path: " .. path,
        Duration = 5 -- Notification duration in seconds
    })
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