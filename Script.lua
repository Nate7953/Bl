local Players = game:GetService("Players")

local gardenScriptURL = "https://raw.githubusercontent.com/NoLag-id/No-Lag-HUB/refs/heads/main/Garden/Garden-V1.lua"

-- Set up queue_on_teleport to auto-run the Garden script after teleport
Players.LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started then
        queue_on_teleport([[
            loadstring(game:HttpGet("]] .. gardenScriptURL .. [["))()
        ]])
    end
end)

-- Run the Garden script now
loadstring(game:HttpGet(gardenScriptURL))()
