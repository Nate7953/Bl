-- SERVICES
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- GUI SETUP
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ServerHopGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 230, 0, 100)
frame.Position = UDim2.new(0.5, -115, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(60, 60, 60)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0.5, 0)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 16
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Text = "Checking..."

local playerCountLabel = Instance.new("TextLabel", frame)
playerCountLabel.Size = UDim2.new(1, 0, 0.25, 0)
playerCountLabel.Position = UDim2.new(0, 0, 0.5, 0)
playerCountLabel.BackgroundTransparency = 1
playerCountLabel.Font = Enum.Font.Gotham
playerCountLabel.TextSize = 14
playerCountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
playerCountLabel.Text = "Players: 0"

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0.25, 0)
toggle.Position = UDim2.new(0, 0, 0.75, 0)
toggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Text = "OFF"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 14

-- VARIABLES
local enabled = false
local visitedServers = {}

-- FUNCTIONS
local function updateStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color
end

local function updatePlayerCount(count)
    playerCountLabel.Text = "Players: " .. tostring(count)
end

local function isPlayerNearby()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (char.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist <= 35 then return true end
        end
    end
    return false
end

local function serverHop()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and result and result.data then
        for _, server in pairs(result.data) do
            local count = server.playing
            local total = count + 1
            if server.id ~= game.JobId and not visitedServers[server.id] and total <= 5 and total >= 2 then
                visitedServers[server.id] = true
                updateStatus("Hopping...", Color3.fromRGB(255, 165, 0))
                queue_on_teleport([[
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))()
                    loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
                ]])
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                return
            end
        end
        visitedServers = {} -- Reset and retry
        updateStatus("Restarting Cycle", Color3.fromRGB(100, 200, 255))
    else
        updateStatus("Error Fetching Servers", Color3.fromRGB(255, 80, 80))
    end
end

-- MAIN LOOP
task.spawn(function()
    while true do
        task.wait(1.5)
        if enabled then
            local playerCount = #Players:GetPlayers()
            updatePlayerCount(playerCount)

            if isPlayerNearby() then
                updateStatus("Player Close", Color3.fromRGB(255, 100, 100))
                task.wait(1)
                serverHop()
            elseif playerCount > 5 then
                updateStatus("Too Many Players", Color3.fromRGB(255, 130, 100))
                task.wait(1)
                serverHop()
            else
                updateStatus("Safe", Color3.fromRGB(0, 255, 0))
            end
        else
            updateStatus("Detection Off", Color3.fromRGB(255, 0, 0))
        end
    end
end)

-- TOGGLE BUTTON FUNCTION
toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "ON" or "OFF"
    toggle.BackgroundColor3 = enabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)
