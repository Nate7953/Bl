-- 🌱 Forever Auto-Reloader
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

-- This is the script you want to load every time
local targetScript = "https://raw.githubusercontent.com/NoLag-id/No-Lag-HUB/refs/heads/main/Loader/LoaderV1.lua"

-- Set up forever reloader across server hops
Players.LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started then
        queue_on_teleport([[
            loadstring(game:HttpGet("]] .. targetScript .. [["))()
        ]])
    end
end)

-- Run it immediately on first execution
loadstring(game:HttpGet(targetScript))()
