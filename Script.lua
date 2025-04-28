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

    -- Retry after delay if no server is found
    task.delay(5, hop)
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
