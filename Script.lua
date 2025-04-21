local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

local visitedServers = {}
local currentIndex = 1
local maxStored = 1000

-- Script to run on teleport
local scriptToRun = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))()
loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
]]

-- Create GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StatusGui"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    pcall(function() screenGui.Parent = game.CoreGui end)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 60)
    frame.Position = UDim2.new(0.5, -110, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = frame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(60, 60, 60)
    uiStroke.Thickness = 2
    uiStroke.Parent = frame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 1, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextScaled = true
    statusLabel.Text = "Initializing..."
    statusLabel.Name = "StatusLabel"
    statusLabel.Parent = frame

    return statusLabel
end

local statusLabel = createGUI()

local function updateStatus(text, color)
    if statusLabel then
        statusLabel.Text = text
        statusLabel.TextColor3 = color
    end
end

-- Check if any player is nearby
local function isPlayerNearby()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local myPos = char.HumanoidRootPart.Position

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

-- Get public servers
local function getServers()
    local servers = {}
    local cursor = ""
    repeat
        local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100&cursor=%s", PlaceId, cursor)
        local success, data = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if success and data and data.data then
            for _, server in pairs(data.data) do
                if server.id ~= game.JobId and server.playing >= 2 and server.playing <= 4 and server.playing + 1 <= server.maxPlayers then
                    if not visitedServers[server.id] then
                        table.insert(servers, server)
                    end
                end
            end
            cursor = data.nextPageCursor or ""
        else
            break
        end
    until cursor == "" or #servers >= 50
    return servers
end

-- Teleport to server
local function serverHop()
    updateStatus("Searching servers...", Color3.fromRGB(255, 255, 0))

    local servers = getServers()
    if #servers == 0 then
        visitedServers = {} -- reset if all servers visited
        servers = getServers()
        if #servers == 0 then
            updateStatus("No suitable servers.", Color3.fromRGB(255, 0, 0))
            return
        end
    end

    local target = servers[math.random(1, #servers)]
    visitedServers[target.id] = true
    if #visitedServers > maxStored then visitedServers = {} end

    queue_on_teleport(scriptToRun)
    updateStatus("Hopping server...", Color3.fromRGB(255, 165, 0))
    TeleportService:TeleportToPlaceInstance(PlaceId, target.id, LocalPlayer)
end

-- Main loop
task.spawn(function()
    while true do
        task.wait(1)
        local count = #Players:GetPlayers()
        local nearby = isPlayerNearby()

        if nearby then
            updateStatus("Player too close!", Color3.fromRGB(255, 100, 100))
            task.wait(1)
            serverHop()
            break
        elseif count > 5 then
            updateStatus("Too many players!", Color3.fromRGB(255, 120, 0))
            task.wait(1)
            serverHop()
            break
        else
            updateStatus("Safe", Color3.fromRGB(0, 255, 0))
        end
    end
end)
