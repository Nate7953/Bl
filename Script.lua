-- 🔁 Persistent auto-reloader for your BlockSpin Auto-Farm
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local scriptURL = "https://raw.githubusercontent.com/Nate7953/BlockSpin-Auto-Farm-Roblox/refs/heads/main/Script.lua"

-- Reload the script automatically after server hop
Players.LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started then
        queue_on_teleport([[
            loadstring(game:HttpGet("]] .. scriptURL .. [["))()
        ]])
    end
end)

-- Initial run
loadstring(game:HttpGet(scriptURL))()
