local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- TRACK VISITED SERVERS
local visitedServers = {}
if getgenv()._joinedServerId then
    visitedServers[getgenv()._joinedServerId] = true
    getgenv()._joinedServerId = nil
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatusGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 240, 0, 70)
frame.Position = UDim2.new(0.5, -120, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

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

-- TOGGLE
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

-- STATUS UPDATE
local function updateStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color
end

local function updatePlayerCount()
    local count = #Players:GetPlayers()
    local max = Players.MaxPlayers or "?"
    countLabel.Text = count .. " / " .. max .. " Players"
end

-- NEARBY PLAYER DETECTION
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

-- QUEUE SCRIPT ON TELEPORT
local function queueNextScript(serverId)
    local scriptToRun = string.format([[
        getgenv()._joinedServerId = "%s"
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))()
        loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
    ]], serverId)
    pcall(function()
        queue_on_teleport(scriptToRun)
    end)
end

-- TELEPORT FAILSAFE
local teleporting = false
TeleportService.TeleportInitFailed:Connect(function(_, _, _)
    teleporting = false
end)

-- SERVER HOP
local function serverHop()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if success and result and result.data then
        for _, server in ipairs(result.data) do
            local playerCountAfterJoin = server.playing + 1
            if server.id ~= game.JobId and playerCountAfterJoin <= 8 and not visitedServers[server.id] then
                visitedServers[server.id] = true
                queueNextScript(server.id)
                updateStatus("Hopping Server", Color3.fromRGB(255, 165, 0))
                teleporting = true
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)

                -- Retry if teleport fails after 60 seconds
                task.delay(60, function()
                    if teleporting then
                        updateStatus("Teleport Failed. Retrying...", Color3.fromRGB(255, 0, 0))
                        teleporting = false
                        serverHop()
                    end
                end)

                return
            end
        end
        updateStatus("No New Servers", Color3.fromRGB(255, 0, 0))
    else
        warn("Failed to retrieve server list.")
    end
end

-- MAIN LOOP
task.spawn(function()
    while true do
        task.wait(0.2)
        if not toggle then continue end
        updatePlayerCount()

        local currentPlayerCount = #Players:GetPlayers()

        if isPlayerNearby() then0
