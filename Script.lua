local wrapperUrl = "https://raw.githubusercontent.com/Nate7953/BlockSpin-Auto-Farm-Roblox/refs/heads/main/Script.lua"
local originalScriptUrl = "https://raw.githubusercontent.com/NoLag-id/No-Lag-HUB/refs/heads/main/Garden/Garden-V1.lua"

-- Queue the wrapper script to run after teleport (not just the original script)
queue_on_teleport("loadstring(game:HttpGetAsync('" .. wrapperUrl .. "'))()")

-- Load the original script now
loadstring(game:HttpGetAsync(originalScriptUrl))()
