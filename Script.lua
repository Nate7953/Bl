-- 🔁 Persistent auto-reloader for Garden Script
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

-- URL of the Garden Script
local scriptURL = "https://raw.githubusercontent.com/NoLag-id/No-Lag-HUB/refs/heads/main/Garden/Garden-V1.lua"

-- Auto-run after teleport
Players.LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started then
        queue_on_teleport([[
            loadstring(game:HttpGet("]] .. scriptURL .. [["))()
        ]])
    end
end)

-- First-time execution
loadstring(game:HttpGet(scriptURL))()
