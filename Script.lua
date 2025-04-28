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

-- Wall Coordinates (Define the first bounding box region)
local pos1 = Vector3.new(-287.26, 250, 350)  -- First coordinate
local pos2 = Vector3.new(-231.89, 265.07, 370.42)  -- Second coordinate

-- Second Door Coordinates (Define the second bounding box region)
local pos3 = Vector3.new(-287.16, 265.07, 330.31)  -- First coordinate of the second door
local pos4 = Vector3.new(-287.26, 250.81, 357.04)  -- Second coordinate of the second door

-- Create the visible wall for the first door (as a part)
local wall1 = Instance.new("Part")
wall1.Size = Vector3.new(pos2.X - pos1.X, pos2.Y - pos1.Y, pos2.Z - pos1.Z)
wall1.Position = (pos1 + pos2) / 2
wall1.Anchored = true
wall1.CanCollide = true
wall1.Color = Color3.fromRGB(255, 0, 0)  -- Red wall
wall1.Transparency = 0.5  -- Slightly transparent to make it visible
wall1.Parent = Workspace

-- Create the visible wall for the second door (as a part)
local wall2 = Instance.new("Part")
wall2.Size = Vector3.new(pos4.X - pos3.X, pos4.Y - pos3.Y, pos4.Z - pos3.Z)
wall2.Position = (pos3 + pos4) / 2
wall2.Anchored = true
wall2.CanCollide = true
wall2.Color = Color3.fromRGB(0, 0, 255)  -- Blue wall
wall2.Transparency = 0.5  -- Slightly transparent to make it visible
wall2.Parent = Workspace

-- Function to teleport to a new server
local function hop()
    if not _G.VisitedServers[game.JobId] then
        _G.VisitedServers[game.JobId] = true
    end

    -- Scripts to run after teleport
    queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xQuartyx/QuartyzScript/refs/heads/main/Block%20Spin/Default.lua"))();
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/BlockSpin-Auto-Farm-Roblox/refs/heads/main/Script.lua"))();
    ]])

    -- Attempt to get a list of available servers
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

    -- Retry after delay if no server is found
    task.delay(5, hop)
end

-- Function to check if a player is inside any of the two Region3 (bounding boxes)
local function isPlayerInRegion(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local charPos = player.Character.HumanoidRootPart.Position

        -- Check for first region (door)
        local regionMin1 = wall1.Position - wall1.Size / 2
        local regionMax1 = wall1.Position + wall1.Size / 2

        -- Check for second region (door)
        local regionMin2 = wall2.Position - wall2.Size / 2
        local regionMax2 = wall2.Position + wall2.Size / 2

        -- Check if the player's position is within the first or second region bounds
        if (charPos.X >= regionMin1.X and charPos.X <= regionMax1.X and
            charPos.Y >= regionMin1.Y and charPos.Y <= regionMax1.Y and
            charPos.Z >= regionMin1.Z and charPos.Z <= regionMax1.Z) or

           (charPos.X >= regionMin2.X and charPos.X <= regionMax2.X and
            charPos.Y >= regionMin2.Y and charPos.Y <= regionMax2.Y and
            charPos.Z >= regionMin2.Z and charPos.Z <= regionMax2.Z) then
            return true
        end
    end
    return false
end

-- Main loop to check for players entering either region
task.spawn(function()
    while true do
        task.wait(0.05)  -- Check every 50 milliseconds
        
        -- Loop through all players in the game
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and isPlayerInRegion(player) then
                -- If the player is in either region, teleport the local player
                hop()
                return
            end
        end
    end
end)

-- GUI for the button
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Create the Button
local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0, 200, 0, 50)
startButton.Position = UDim2.new(0, 10, 0, 10)
startButton.Text = "Start"
startButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  -- Green background
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)   -- White text
startButton.Font = Enum.Font.GothamBold
startButton.TextSize = 24
startButton.Parent = screenGui

-- Function to make the button draggable
local function makeDraggable(Frame)
    local dragToggle = nil
    local dragStart = nil
    local dragPos = nil

    local function update(input)
        local delta = input.Position - dragStart
        local pos = UDim2.new(Frame.Position.X.Scale, Frame.Position.X.Offset + delta.X, Frame.Position.Y.Scale, Frame.Position.Y.Offset + delta.Y)
        Frame.Position = pos
    end

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            input.Changed:Connect(function()
                if not input.UserInputState == Enum.UserInputState.Change then
                    dragToggle = false
                end
            end)
        end
    end)

    Frame.InputChanged:Connect(function(input)
        if dragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
end

-- Make the "Start" button draggable
makeDraggable(startButton)

-- Function to load the script when the button is clicked
startButton.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xQuartyx/QuartyzScript/refs/heads/main/Block%20Spin/Default.lua"))()
end)
