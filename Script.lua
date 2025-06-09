-- ✅ Auto-reloader for Delta Executor (Works Forever)
local scriptURL = "https://raw.githubusercontent.com/NoLag-id/No-Lag-HUB/refs/heads/main/Loader/LoaderV1.lua"

-- Reload script after every server hop
queue_on_teleport('loadstring(game:HttpGet("' .. scriptURL .. '"))()')

-- Run script immediately
loadstring(game:HttpGet(scriptURL))()
