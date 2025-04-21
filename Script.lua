local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- Script to run after teleport
local scriptToRun = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))()
loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
]]

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatusGui"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 100)
frame.Position = UDim2.new(0.5, -125, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(60, 60, 60)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0.5, 0)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.Text = "Checking..."
statusLabel.Parent = frame

local cycleLabel = Instance.new("TextLabel")
cycleLabel.Size = UDim2.new(1, 0, 0.25, 0)
cycleLabel.Position = UDim2.new(0, 0, 0.5, 0)
cycleLabel.BackgroundTransparency = 1
cycleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
cycleLabel.Font = Enum.Font.Gotham
cycleLabel.TextScaled = true
cycleLabel.Text = "Cycle: 0"
cycleLabel.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, 0, 0.25, 0)
toggleButton.Position = UDim2.new(0, 0, 0.75, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Text = "ON"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextScaled = true
toggleButton.Parent = frame
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 6)

-- Functions
local detectionEnabled = true
local visitedServerIds = {}
local cycleCount = 0

toggleButton.MouseButton1Click:Connect(function()
    detectionEnabled = not detectionEnabled
    toggleButton.Text = detectionEnabled and "ON" or "OFF"
    toggleButton.BackgroundColor3 = detectionEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

local function updateStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
end

local function isPlayerNearby()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local myPos = char.HumanoidRootPart.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if (myPos - player.Character.HumanoidRootPart.Position).Magnitude <= 35 then
                return true
            end
        end
    end
    return false
end

local function getServers()
    local allServers = {}
    local cursor = ""
    repeat
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then url = url .. "&cursor=" .. cursor end

        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and result and result.data then
            for _, server in ipairs(result.data) do
                table.insert(allServers, server)
            end
            cursor = result.nextPageCursor or ""
        else
            break
        end
    until cursor == "" or #allServers >= 200

    return allServers
end

local function serverHop()
    local servers = getServers()
    for _, server in ipairs(servers) do
        local id = server.id
        local currentPlayers = server.playing
        local totalPlayers = currentPlayers + 1

        if id ~= game.JobId and not visitedServerIds[id] and totalPlayers >= 2 and totalPlayers <= 5 and currentPlayers < server.maxPlayers then
            visitedServerIds[id] = true
            queue_on_teleport(scriptToRun)
            updateStatus("Hopping Server...", Color3.fromRGB(255, 165, 0))
            TeleportService:TeleportToPlaceInstance(PlaceId, id, LocalPlayer)
            return
        end
    end

    visitedServerIds = {}
    cycleCount += 1
    cycleLabel.Text = "Cycle: " .. cycleCount
    updateStatus("Restarting Cycle...", Color3.fromRGB(200, 200, 50))
end

-- Loop
task.spawn(function()
    while true do
        task.wait(1)
        if not detectionEnabled then
            updateStatus("Detection OFF", Color3.fromRGB(255, 50, 50))
        else
            local nearby = isPlayerNearby()
            local currentCount = #Players:GetPlayers()

            if nearby then
                updateStatus("Player Close - Hopping", Color3.fromRGB(255, 80, 80))
                task.wait(1)
                serverHop()
            elseif currentCount > 5 then
                updateStatus("Too Many Players", Color3.fromRGB(255, 120, 80))
                task.wait(1)
                serverHop()
            else
                updateStatus("Safe", Color3.fromRGB(0, 255, 0))
            end
        end
    end
end)
