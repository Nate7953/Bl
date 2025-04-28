-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local PlaceId = game.PlaceId

if not _G.VisitedServers then
    _G.VisitedServers = {}
end

-- Wall Coordinates (Define the bounding box region)
local pos1 = Vector3.new(-287.26, 250, 350)  -- First coordinate
local pos2 = Vector3.new(-231.89, 265.07, 357.42)  -- Second coordinate

-- Create the Region3 (bounding box)
local region = Region3.new(pos1, pos2)

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
    task.delay(25, hop)
end

-- Function to check if a player is inside the Region3 (bounding box)
local function isPlayerInRegion(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local charPos = player.Character.HumanoidRootPart.Position

        -- Get min and max coordinates of the region
        local regionMin = region.CFrame.Position - region.Size / 2
        local regionMax = region.CFrame.Position + region.Size / 2

        -- Check if the player's position is within the region bounds
        if charPos.X >= regionMin.X and charPos.X <= regionMax.X and
           charPos.Y >= regionMin.Y and charPos.Y <= regionMax.Y and
           charPos.Z >= regionMin.Z and charPos.Z <= regionMax.Z then
            return true
        end
    end
    return false
end

-- Main loop to check for players entering the region
task.spawn(function()
    while true do
        task.wait(0.1)  -- Check every second
        
        -- Loop through all players in the game
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and isPlayerInRegion(player) then
                -- If the player is in the region, teleport the local player
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
