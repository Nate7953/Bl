local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local CurrentJobId = game.JobId

-- Store visited servers
local visitedServers = {}
visitedServers[CurrentJobId] = true

-- This is the script to run again after teleport
getgenv().ScriptToRun = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))()
loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
]]

-- If you just joined from teleport, run again
if getgenv().ScriptToRun then
	loadstring(getgenv().ScriptToRun)()
	getgenv().ScriptToRun = nil
end

-- GUI to show what's going on
local gui = Instance.new("ScreenGui", game.CoreGui)
local label = Instance.new("TextLabel", gui)
label.Size = UDim2.new(0, 300, 0, 50)
label.Position = UDim2.new(0.5, -150, 0, 20)
label.BackgroundTransparency = 0.4
label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold
label.TextScaled = true
label.Text = "Starting..."

-- Function to update GUI
local function updateStatus(text)
	label.Text = text
end

-- Function to teleport to a new server
local function teleportToNewServer()
	while true do
		local success, servers = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(
				"https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
		end)

		if success and servers and servers.data then
			for _, server in ipairs(servers.data) do
				local totalPlayers = server.playing
				if server.id ~= CurrentJobId and not visitedServers[server.id] and totalPlayers < 7 then
					visitedServers[server.id] = true
					updateStatus("Teleporting to server with " .. totalPlayers .. " players...")
					getgenv().ScriptToRun = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))()
loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
					]]
					TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
					return
				end
			end
			updateStatus("No servers found. Retrying...")
		else
			updateStatus("Failed to get server list. Retrying...")
		end
		wait(3)
	end
end

-- MAIN LOOP
task.spawn(function()
	while true do
		local playerCount = #Players:GetPlayers()
		if playerCount >= 7 then
			updateStatus("Too many players: " .. playerCount .. " - Hopping...")
			wait(2)
			teleportToNewServer()
			break
		else
			updateStatus("Good server: " .. playerCount .. " players")
		end
		wait(3)
	end
end)
