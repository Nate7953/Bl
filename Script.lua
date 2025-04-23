local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

local visitedServers = {}
visitedServers[game.JobId] = true

-- Define the two script URLs
local script1 = "https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"
local script2 = "https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"

-- GUI Setup
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "StatusGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 70)
frame.Position = UDim2.new(0.5, -120, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local uiStroke = Instance.new("UIStroke", frame)
uiStroke.Color = Color3.fromRGB(60, 60, 60)
uiStroke.Thickness = 2

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0.5, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.Text = "Checking..."

local countLabel = Instance.new("TextLabel", frame)
countLabel.Size = UDim2.new(1, 0, 0.5, 0)
countLabel.Position = UDim2.new(0, 0, 0.5, 0)
countLabel.BackgroundTransparency = 1
countLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
countLabel.Font = Enum.Font.Gotham
countLabel.TextScaled = true
countLabel.Text = "0 / 0 Players"

-- Toggle for GUI
local toggle = true
local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(0, 60, 0, 25)
toggleButton.Position = UDim2.new(1, -65, 1, 5)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
toggleButton.Text = "On"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextScaled = true
toggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)

toggleButton.MouseButton1Click:Connect(function()
    toggle = not toggle
    toggleButton.Text = toggle and "On" or "Off"
    toggleButton.BackgroundColor3 = toggle and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

-- GUI Update Functions
local function updateStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color
end

local function updatePlayerCount()
    local count = #Players:GetPlayers()
    local max = Players.MaxPlayers or "?"
    countLabel.Text = count .. " / " .. max .. " Players"
end

-- Function to check if there are too many players and teleport
local isTeleporting = false  -- Lock to prevent teleporting multiple times at once

local function teleportToServer()
    if isTeleporting then
        print("Teleport is already in process. Skipping this teleport.")
        return
    end

    -- Check if the number of players is greater than 8
    if #Players:GetPlayers() > 8 then
        print("There are more than 8 players in the current server. Attempting to join a new server.")
        
        -- Set teleporting flag to true
        isTeleporting = true
        
        -- Attempt to teleport to another server
        local success, message = pcall(function()
            TeleportService:Teleport(PlaceId, LocalPlayer)
        end)

        if success then
            print("Successfully teleported to a new server.")
        else
            warn("Teleport failed: " .. message)
        end

        -- Reset teleporting flag after a short delay
        task.wait(5)  -- Adjust this wait time if necessary
        isTeleporting = false
    else
        print("The server has fewer than 8 players, no need to hop.")
    end
end

-- Function to reload your scripts after teleport
local function reloadScripts()
    print("Reloading auto-farming and other scripts...")

    -- Directly loading the first script using loadstring
    local success1, err1 = pcall(function()
        loadstring(game:HttpGet(script1))()
    end)
    if not success1 then
        warn("Failed to load script1: " .. err1)
    else
        print("Successfully loaded script1.")
    end

    -- Directly loading the second script using loadstring
    local success2, err2 = pcall(function()
        loadstring(game:HttpGet(script2))()
    end)
    if not success2 then
        warn("Failed to load script2: " .. err2)
    else
        print("Successfully loaded script2.")
    end
end

-- Server Hop
local function serverHop()
    teleportToServer()
    
    -- Wait for the new server to load, then reload the scripts
    wait(15)  -- Increased wait time to allow the new server to load
    reloadScripts()
end

-- Auto-rehop if stuck too long
local lastJobId = game.JobId
local lastHopTime = tick()
task.spawn(function()
    while true do
        task.wait(60)
        if game.JobId == lastJobId and tick() - lastHopTime > 300 then
            updateStatus("Stuck? Rehopping", Color3.fromRGB(255, 0, 255))
            serverHop()
        end
    end
end)

-- Main Loop to check player count and decide whether to teleport
task.spawn(function()
    while true do
        task.wait(1)
        
        if not toggle then continue end
        
        updatePlayerCount()
        local count = #Players:GetPlayers()

        -- Check if another player is nearby, if so, teleport
        if count > 8 then
            updateStatus("Too Many Players", Color3.fromRGB(255, 150, 80))
            task.wait(4)
            serverHop()
        else
            updateStatus("Safe", Color3.fromRGB(0, 255, 0))
        end
    end
end)
