-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local PlaceId = game.PlaceId

if not _G.VisitedServers then
    _G.VisitedServers = {}
end

-- Use two opposite corners to define the bounding box (kitchen area)
local corner1 = Vector3.new(-287.26, 250, 330.31) -- Lower corner
local corner2 = Vector3.new(-231.58, 270.07, 357.42) -- Upper corner

-- Calculate min and max positions
local regionMin = Vector3.new(
    math.min(corner1.X, corner2.X),
    math.min(corner1.Y, corner2.Y),
    math.min(corner1.Z, corner2.Z)
)
local regionMax = Vector3.new(
    math.max(corner1.X, corner2.X),
    math.max(corner1.Y, corner2.Y),
    math.max(corner1.Z, corner2.Z)
)

-- Optional debug box
local wall = Instance.new("Part")
wall.Size = regionMax - regionMin
wall.Position = (regionMin + regionMax) / 2
wall.Anchored = true
wall.CanCollide = false
wall.Color = Color3.fromRGB(255, 0, 0)
wall.Transparency = 1
wall.Parent = Workspace

-- Function to teleport to a new server
local function hop()
    if not _G.VisitedServers[game.JobId] then
        _G.VisitedServers[game.JobId] = true
    end

    queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xQuartyx/QuartyzScript/refs/heads/main/Block%20Spin/Default.lua"))();
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/BlockSpin-Auto-Farm-Roblox/refs/heads/main/Script.lua"))();
    ]])

    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if success and result and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId and not _G.VisitedServers[server.id] then
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                return
            end
        end
    end

    task.delay(5, hop)
end

-- Player region check
local function isPlayerInRegion(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local pos = player.Character.HumanoidRootPart.Position
        return (pos.X >= regionMin.X and pos.X <= regionMax.X and
                pos.Y >= regionMin.Y and pos.Y <= regionMax.Y and
                pos.Z >= regionMin.Z and pos.Z <= regionMax.Z)
    end
    return false
end

-- Detection loop
task.spawn(function()
    while true do
        task.wait(0.05)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and isPlayerInRegion(player) then
                hop()
                return
            end
        end
    end
end)

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0, 200, 0, 50)
startButton.Position = UDim2.new(0, 10, 0, 10)
startButton.Text = "Start"
startButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.Font = Enum.Font.GothamBold
startButton.TextSize = 24
startButton.Parent = screenGui

-- Make draggable
local function makeDraggable(Frame)
    local dragging
    local dragStart
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    Frame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(Frame.Position.X.Scale, Frame.Position.X.Offset + delta.X,
                                       Frame.Position.Y.Scale, Frame.Position.Y.Offset + delta.Y)
            dragStart = input.Position
        end
    end)
end

makeDraggable(startButton)

-- Load script on click
startButton.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xQuartyx/QuartyzScript/refs/heads/main/Block%20Spin/Default.lua"))()
end)
