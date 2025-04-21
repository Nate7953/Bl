local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- Script to run on teleport
local scriptToRun = [[
    -- Load the Auto-Farm script
    loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()

    -- Function to detect nearby players
    local function isPlayerNearby()
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
        local myPos = char.HumanoidRootPart.Position

        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local theirPos = player.Character.HumanoidRootPart.Position
                if (myPos - theirPos).Magnitude <= 35 then
                    return true
                end
            end
        end
        return false
    end

    -- Detect players nearby in the new server
    while true do
        wait(1)
        if isPlayerNearby() then
            -- Fire event if a player is nearby
            game:GetService("ReplicatedStorage").Events.PlayerFound:Fire()

            -- After detecting a player, attempt server hopping again
            local success, result = pcall(function()
                return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            end)

            if success and result then
                local data = game:GetService("HttpService"):JSONDecode(result)
                if data.data then
                    for _, server in pairs(data.data) do
                        if server.playing < server.maxPlayers and server.id ~= game.JobId then
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, game.Players.LocalPlayer)
                            break
                        end
                    end
                end
            end
            break
        end
    end
]]

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatusGui"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
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
statusLabel.Text = "Checking..."
statusLabel.Parent = frame

-- Update status function
local function updateStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color
end

-- Detect players nearby
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

-- Teleport to new server
local function serverHop()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if success and result and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                -- Queue both the teleportation script and the detection script to run on the new server
                queue_on_teleport(scriptToRun)
                
                updateStatus("Activating", Color3.fromRGB(255, 165, 0))
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                return
            end
        end
    else
        warn("Failed to get server list")
    end
end

-- Loop
task.spawn(function()
    while true do
        task.wait(1)
        if isPlayerNearby() then
            updateStatus("Player Close", Color3.fromRGB(255, 80, 80))
            task.wait(0.9)
            updateStatus("Activating", Color3.fromRGB(255, 165, 0))
            task.wait(0.01)
            serverHop()
            break
        else
            updateStatus("Safe", Color3.fromRGB(0, 255, 0))
        end
    end
end)
