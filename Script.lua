local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- Script to queue on teleport
local scriptToRun = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))()
loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
]]

-- GUI
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "StatusGui"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 250, 0, 100)
frame.Position = UDim2.new(0.5, -125, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Active, frame.Draggable = true, true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(60, 60, 60)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0.5, 0)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Text = "Status: Loading..."

local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(0.6, 0, 0.3, 0)
toggleButton.Position = UDim2.new(0.2, 0, 0.6, 0)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextScaled = true
toggleButton.Text = "OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 80, 80)
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", toggleButton)

local detectionEnabled = false
toggleButton.MouseButton1Click:Connect(function()
    detectionEnabled = not detectionEnabled
    toggleButton.Text = detectionEnabled and "ON" or "OFF"
    toggleButton.TextColor3 = detectionEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
end)

local function updateStatus(text, color)
    statusLabel.Text = "Status: " .. text
    statusLabel.TextColor3 = color
end

-- Check nearby players
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

-- Server hop logic
local function serverHop()
    local cursor = ""
    repeat
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and result and result.data then
            for _, server in ipairs(result.data) do
                local playerCount = server.playing + 1
                if server.id ~= game.JobId and playerCount >= 2 and playerCount <= 5 and server.playing < server.maxPlayers then
                    queue_on_teleport(scriptToRun)
                    updateStatus("Hopping Server", Color3.fromRGB(255, 165, 0))
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                    return
                end
            end
            cursor = result.nextPageCursor
        else
            warn("Failed to get server list")
            break
        end
    until not cursor

    updateStatus("No Servers Found", Color3.fromRGB(255, 80, 80))
end

-- Main loop
task.spawn(function()
    while true do
        task.wait(1)
        if detectionEnabled then
            local nearby = isPlayerNearby()
            local playerCount = #Players:GetPlayers()
            if nearby then
                updateStatus("Player Close", Color3.fromRGB(255, 100, 100))
                serverHop()
            elseif playerCount > 5 then
                updateStatus("Too Many Players", Color3.fromRGB(255, 150, 80))
                serverHop()
            else
                updateStatus("Safe", Color3.fromRGB(0, 255, 0))
            end
        else
            updateStatus("Detection Off", Color3.fromRGB(150, 150, 150))
        end
    end
end)
