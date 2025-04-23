local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local currentPlayer = Players.LocalPlayer

-- Game ID for BlockSpin
local gameId = 104715542330896  -- BlockSpin Game ID

-- Last teleport time to prevent frequent teleportation
local lastTeleportTime = 0
local teleportCooldown = 10  -- seconds

-- Function to check if we need to hop to a new server
local function hopServers()
    -- Ensure we don't teleport too often
    if tick() - lastTeleportTime < teleportCooldown then
        print("Cooldown in effect. Not teleporting yet.")
        return
    end

    -- Check if we are in a server with more than 8 players
    if game.Players.NumPlayers > 8 then
        print("There are more than 8 players in the current server. Attempting to join a new server.")
        
        -- Attempt to teleport to another server
        local success, message = pcall(function()
            TeleportService:Teleport(gameId, currentPlayer)
        end)

        if success then
            print("Successfully teleported to a new server.")
            lastTeleportTime = tick()  -- Update last teleport time
        else
            warn("Teleport failed: " .. message)
        end
    else
        print("The server has fewer than 8 players, no need to hop.")
    end
end

-- Call the server hop function
hopServers()
