--// Roblox Smart Server Hopper Script //---

local HttpService = game:GetService("HttpService") local TeleportService = game:GetService("TeleportService") local Players = game:GetService("Players") local LocalPlayer = Players.LocalPlayer local PlaceId = game.PlaceId

-- Script to run on teleport (queue next execution) local scriptToRun = [[ loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))() loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))() ]]

-- GUI Setup local function createStatusGui() local gui = Instance.new("ScreenGui") gui.Name = "StatusGui" gui.ResetOnSpawn = false pcall(function() gui.Parent = game.CoreGui end) if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 60)
frame.Position = UDim2.new(0.5, -110, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = frame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(60, 60, 60)
uiStroke.Thickness = 2
uiStroke.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold
label.TextScaled = true
label.Text = "Checking..."
label.Parent = frame

return label

end

local statusLabel = createStatusGui()

local function updateStatus(text, color) if statusLabel then statusLabel.Text = text statusLabel.TextColor3 = color end end

-- Track visited servers local visited = {} local function markVisited(id) visited[id] = true end local function alreadyVisited(id) return visited[id] end local function resetVisited() visited = {} end

-- Check for nearby players local function isPlayerNearby() local char = LocalPlayer.Character if not char or not char:FindFirstChild("HumanoidRootPart") then return false end local myPos = char.HumanoidRootPart.Position

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

-- Main server hopping function local function serverHop() local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet( "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" )) end)

if success and result and result.data then
    local found = false
    for _, server in ipairs(result.data) do
        local playersInServer = server.playing
        local willBeAfterJoin = playersInServer + 1

        if playersInServer >= 2 and playersInServer <= 4 and willBeAfterJoin <= 5 and not alreadyVisited(server.id) and server.id ~= game.JobId then
            markVisited(server.id)
            queue_on_teleport(scriptToRun)
            updateStatus("Hopping Server", Color3.fromRGB(255, 165, 0))
            TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
            found = true
            break
        end
    end

    if not found then
        resetVisited()
        updateStatus("No New Servers. Resetting...", Color3.fromRGB(255, 80, 80))
    end
else
    warn("Failed to fetch server list")
    updateStatus("API Error", Color3.fromRGB(255, 0, 0))
end

end

-- Main check loop while true do task.wait(1) local nearby = isPlayerNearby() local count = #Players:GetPlayers()

if nearby then
    updateStatus("Player Close", Color3.fromRGB(255, 80, 80))
    task.wait(0.9)
    serverHop()
    break
elseif count > 5 then
    updateStatus("Too Many Players", Color3.fromRGB(255, 150, 80))
    task.wait(0.9)
    serverHop()
    break
else
    updateStatus("Safe", Color3.fromRGB(0, 255, 0))
end

end
