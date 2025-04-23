local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

local visitedServers = {}
visitedServers[game.JobId] = true

local scriptToRun = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))()
loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
]]

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

-- Toggle
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

-- Nearby Detection
local function isPlayerNearby()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local theirPos = player.Character.HumanoidRootPart.Position
            if (myPos - theirPos).Magnitude <= 35 then
                return true
            end
        end
    end
    return false
end

-- Robust teleport retry
local function robustTeleport(placeId, serverId)
    for attempt = 1, 5 do
        local success = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, serverId, LocalPlayer)
        end)
        if success then
            updateStatus("Teleporting...", Color3.fromRGB(255, 165, 0))
            return
        else
            task.wait(2)
        end
    end
    updateStatus("Teleport Failed", Color3.fromRGB(255, 0, 0))
end

-- Server Hop
local function serverHop()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            local playerCountAfterJoin = server.playing + 1
            if server.id ~= game.JobId and server.playing < server.maxPlayers and playerCountAfterJoin <= 5 and not visitedServers[server.id] then
                visitedServers[server.id] = true
                queue_on_teleport(scriptToRun)
                robustTeleport(PlaceId, server.id)
                return
            end
        end
        updateStatus("No New Servers", Color3.fromRGB(255, 80, 80))
    else
        warn("Failed to get server list")
    end
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

-- Main Loop
task.spawn(function()
    while true do
        task.wait(1)
        if not toggle then continue end
        updatePlayerCount()
        local count = #Players:GetPlayers()
        if isPlayerNearby() then
            updateStatus("Player Close", Color3.fromRGB(255, 80, 80))
            task.wait(0.1)
            serverHop()
        elseif count > 6 then
            updateStatus("Too Many Players", Color3.fromRGB(255, 150, 80))
            task.wait(4)
            serverHop()
        else
            updateStatus("Safe", Color3.fromRGB(0, 255, 0))
        end
    end
end)
