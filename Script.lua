local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- Script to run when teleporting
local scriptToRun = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))()
loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
]]

-- Server ID tracking
local visited = {}
local currentIndex = 1
local serverList = {}

-- GUI Setup
local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StatusGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 60)
    frame.Position = UDim2.new(0.5, -110, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui

    local uiCorner = Instance.new("UICorner", frame)
    uiCorner.CornerRadius = UDim.new(0, 12)

    local uiStroke = Instance.new("UIStroke", frame)
    uiStroke.Color = Color3.fromRGB(60, 60, 60)
    uiStroke.Thickness = 2

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = "Loading..."

    return label
end

local statusLabel = createGui()

local function updateStatus(text, color)
    if statusLabel then
        statusLabel.Text = text
        statusLabel.TextColor3 = color
    end
end

-- Player proximity check
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

-- Fetch new servers
local function fetchServers()
    local cursor = ""
    local servers = {}
    repeat
        local url = ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100&cursor=%s"):format(PlaceId, cursor)
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.playing >= 2 and server.playing <= 4 and not visited[server.id] and server.id ~= game.JobId then
                    table.insert(servers, server)
                end
            end
            cursor = result.nextPageCursor
        else
            break
        end
        task.wait(0.2)
    until not cursor or #servers >= 100

    return servers
end

-- Hop to next server
local function serverHop()
    if #serverList == 0 then
        serverList = fetchServers()
        if #serverList == 0 then
            updateStatus("No servers found", Color3.fromRGB(255, 0, 0))
            return
        end
        currentIndex = 1
    end

    local server = serverList[currentIndex]
    visited[server.id] = true
    currentIndex += 1
    if currentIndex > #serverList then
        serverList = {}
    end

    updateStatus("Hopping...", Color3.fromRGB(255, 165, 0))
    queue_on_teleport(scriptToRun)
    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
end

-- Main loop
task.spawn(function()
    while true do
        task.wait(1)
        local count = #Players:GetPlayers()

        if isPlayerNearby() then
            updateStatus("Player Nearby", Color3.fromRGB(255, 80, 80))
            task.wait(0.9)
            serverHop()
            break
        elseif count > 5 then
            updateStatus("Too Many Players", Color3.fromRGB(255, 80, 80))
            task.wait(0.9)
            serverHop()
            break
        else
            updateStatus("Safe", Color3.fromRGB(0, 255, 0))
        end
    end
end)
