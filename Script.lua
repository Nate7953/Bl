local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

local visitedJobId = JobId  -- Track current server

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

local function updateStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color
end

local function updatePlayerCount()
    local count = #Players:GetPlayers()
    local max = Players.MaxPlayers or "?"
    countLabel.Text = count .. " / " .. max .. " Players"
end

-- Teleport function with server-visit tracking for Delta
local function teleportToNewServer()
    updateStatus("Teleporting...", Color3.fromRGB(255, 200, 0))

    -- Avoid rejoining the same server
    if game.JobId == visitedJobId then
        updateStatus("Already in this server", Color3.fromRGB(255, 0, 0))
        return
    end

    visitedJobId = game.JobId  -- Update the visited server

    -- Queue scripts to run after teleport
    queue_on_teleport([[
        if game.JobId ~= "]] .. visitedJobId .. [[" then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/main/Script.lua"))()
            loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
        end
    ]])

    -- Try teleport
    local success, err = pcall(function()
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end)
    if not success then
        updateStatus("Teleport Failed", Color3.fromRGB(255, 0, 0))
        warn(err)
    end
end

-- Loop for checking player count and triggering teleport if needed
task.spawn(function()
    while true do
        task.wait(1.4)
        if not toggle then continue end
        updatePlayerCount()

        if #Players:GetPlayers() > 8 then
            updateStatus("Too Many Players", Color3.fromRGB(255, 120, 0))
            task.wait(4.3)
            teleportToNewServer()  -- Teleport when there are too many players
        else
            updateStatus("Safe", Color3.fromRGB(0, 255, 0))
        end
    end
end)
