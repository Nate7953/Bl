-- Updated Script with Non-Repeating Server Hopping local HttpService = game:GetService("HttpService") local TeleportService = game:GetService("TeleportService") local Players = game:GetService("Players") local LocalPlayer = Players.LocalPlayer local PlaceId = game.PlaceId

-- Cache for visited servers local visitedServerIds = {}

-- GUI Setup local screenGui = Instance.new("ScreenGui") screenGui.Name = "StatusGui" screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling screenGui.ResetOnSpawn = false screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame") frame.Size = UDim2.new(0, 240, 0, 80) frame.Position = UDim2.new(0.5, -120, 0.1, 0) frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) frame.BackgroundTransparency = 0.1 frame.BorderSizePixel = 0 frame.Active = true frame.Draggable = true frame.Parent = screenGui

local uiCorner = Instance.new("UICorner") uiCorner.CornerRadius = UDim.new(0, 12) uiCorner.Parent = frame

local uiStroke = Instance.new("UIStroke") uiStroke.Color = Color3.fromRGB(60, 60, 60) uiStroke.Thickness = 2 uiStroke.Parent = frame

local statusLabel = Instance.new("TextLabel") statusLabel.Size = UDim2.new(1, 0, 0.5, 0) statusLabel.Position = UDim2.new(0, 0, 0, 0) statusLabel.BackgroundTransparency = 1 statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255) statusLabel.Font = Enum.Font.GothamBold statusLabel.TextScaled = true statusLabel.Text = "Checking..." statusLabel.Parent = frame

local playerCountLabel = Instance.new("TextLabel") playerCountLabel.Size = UDim2.new(1, 0, 0.5, 0) playerCountLabel.Position = UDim2.new(0, 0, 0.5, 0) playerCountLabel.BackgroundTransparency = 1 playerCountLabel.TextColor3 = Color3.fromRGB(180, 180, 180) playerCountLabel.Font = Enum.Font.Gotham playerCountLabel.TextScaled = true playerCountLabel.Text = "0/0" playerCountLabel.Parent = frame

local toggleButton = Instance.new("TextButton") toggleButton.Size = UDim2.new(0, 60, 0, 30) toggleButton.Position = UDim2.new(1, -65, 1, 5) toggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0) toggleButton.Text = "OFF" toggleButton.TextColor3 = Color3.new(1,1,1) toggleButton.Font = Enum.Font.GothamBold toggleButton.TextScaled = true toggleButton.Parent = frame

local uiCornerBtn = Instance.new("UICorner") uiCornerBtn.CornerRadius = UDim.new(0, 8) uiCornerBtn.Parent = toggleButton

local detectionEnabled = false

toggleButton.MouseButton1Click:Connect(function() detectionEnabled = not detectionEnabled if detectionEnabled then toggleButton.Text = "ON" toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0) else toggleButton.Text = "OFF" toggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0) end end)

local function updateStatus(text, color) statusLabel.Text = text statusLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255) end

local function updatePlayerCount(current, max) playerCountLabel.Text = tostring(current) .. "/" .. tostring(max) end

local function isPlayerNearby() local char = LocalPlayer.Character if not char or not char:FindFirstChild("HumanoidRootPart") then return false end local myPos = char.HumanoidRootPart.Position for _, player in ipairs(Players:GetPlayers()) do if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then local theirPos = player.Character.HumanoidRootPart.Position if (myPos - theirPos).Magnitude <= 35 then return true end end end return false end

local function serverHop() local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")) end)

if success and result and result.data then
    for _, server in ipairs(result.data) do
        local playerCountAfterJoin = server.playing + 1
        if server.id ~= game.JobId and not visitedServerIds[server.id] and playerCountAfterJoin <= 5 and playerCountAfterJoin >= 2 then
            visitedServerIds[server.id] = true
            queue_on_teleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))()

loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()]]) updateStatus("Hopping Server", Color3.fromRGB(255, 165, 0)) TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer) return end end updateStatus("No Available Servers", Color3.fromRGB(255, 80, 80)) else warn("Failed to fetch servers") end end

-- Main loop coroutine.wrap(function() while true do task.wait(1) local playerCount = #Players:GetPlayers() local maxPlayers = game:GetService("Players").MaxPlayers updatePlayerCount(playerCount, maxPlayers)

if detectionEnabled then
        if isPlayerNearby() then
            updateStatus("Player Close", Color3.fromRGB(255, 80, 80))
            task.wait(1)
            serverHop()
        elseif playerCount > 5 then
            updateStatus("Too Many Players", Color3.fromRGB(255, 100, 100))
            task.wait(1)
            serverHop()
        else
            updateStatus("Safe", Color3.fromRGB(0, 255, 0))
        end
    else
        updateStatus("Detection OFF", Color3.fromRGB(255, 0, 0))
    end
end

end)()
