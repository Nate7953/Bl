local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- Script to run on teleport
local scriptToRun = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))()
loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
]]

-- GUI Setup (unchanged) ...
-- [keep your GUI code here]

-- Status update function
local function updateStatus(text, color)
	statusLabel.Text = text
	statusLabel.TextColor3 = color
end

-- Track visited servers
local visitedServers = {}
local function hasVisited(serverId)
	for _, id in ipairs(visitedServers) do
		if id == serverId then
			return true
		end
	end
	return false
end

local function resetVisitedServers()
	visitedServers = {}
end

-- Server hopping logic
local function serverHop()
	local success, result = pcall(function()
		return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
	end)

	if success and result and result.data then
		local unvisited = {}

		for _, server in ipairs(result.data) do
			local playerCountAfterJoin = server.playing + 1
			if server.id ~= game.JobId and server.playing < server.maxPlayers and playerCountAfterJoin <= 5 then
				if server.playing >= 2 and server.playing <= 4 and not hasVisited(server.id) then
					table.insert(unvisited, server)
				end
			end
		end

		if #unvisited == 0 then
			resetVisitedServers()
			updateStatus("Cycle Complete - Resetting...", Color3.fromRGB(255, 255, 0))
			task.wait(1)
			serverHop()
			return
		end

		local chosen = unvisited[1] -- or use math.random(1, #unvisited) to randomize
		table.insert(visitedServers, chosen.id)
		queue_on_teleport(scriptToRun)
		updateStatus("Hopping to Server", Color3.fromRGB(255, 165, 0))
		TeleportService:TeleportToPlaceInstance(PlaceId, chosen.id, LocalPlayer)
	else
		warn("Failed to get server list")
	end
end

-- Nearby player detection
local function isPlayerNearby()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
	local myPos = char.HumanoidRootPart.Position

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local theirPos = player.Character.HumanoidRootPart.Position
			if (myPos - theirPos).Magnitude <= 35 then
				return true
			end
		end
	end
	return false
end

-- Main loop
task.spawn(function()
	while true do
		task.wait(1)
		local nearby = isPlayerNearby()
		local currentPlayerCount = #Players:GetPlayers()

		if nearby then
			updateStatus("Player Close", Color3.fromRGB(255, 80, 80))
			task.wait(0.9)
			serverHop()
			break
		elseif currentPlayerCount > 5 then
			updateStatus("Too Many Players", Color3.fromRGB(255, 150, 80))
			task.wait(0.9)
			serverHop()
			break
		else
			updateStatus("Safe", Color3.fromRGB(0, 255, 0))
		end
	end
end)
