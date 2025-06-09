local wrapperUrl = "https://raw.githubusercontent.com/YourUsername/YourRepo/main/WrapperScript.lua"
local originalScriptUrl = "https://raw.githubusercontent.com/NoLag-id/No-Lag-HUB/refs/heads/main/Garden/Garden-V1.lua"

queue_on_teleport("loadstring(game:HttpGetAsync('" .. wrapperUrl .. "'))()")

loadstring(game:HttpGetAsync(originalScriptUrl))()
