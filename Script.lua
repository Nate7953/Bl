local wrapperUrl = "https://raw.githubusercontent.com/Nate7953/BlockSpin-Auto-Farm-Roblox/refs/heads/main/Script.lua"
local originalScriptUrl = "https://raw.githubusercontent.com/NoLag-id/No-Lag-HUB/refs/heads/main/Garden/Garden-V1.lua"

queue_on_teleport("loadstring(game:HttpGetAsync('" .. wrapperUrl .. "'))()")

loadstring(game:HttpGetAsync(originalScriptUrl))()
