-- Services
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local CurrentJobId = game.JobId

-- Store visited servers to avoid rejoining
local visitedServers = {}
visitedServers[CurrentJobId] = true

-- Re-execute after teleport
getgenv().ScriptToRun = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))()
loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
]]

-- Rerun after teleport (Delta sometimes keeps session)
if getgenv().ScriptToRun then
	loadstring(getgenv().ScriptToRun)()
	getgenv().ScriptToRun = nil
end

-- GUI Setup
local gui = Instance.new("ScreenGui", game.CoreGui)
local label = Instance.new("TextLabel", gui)
label.Size = UDim2.new(0, 300, 0, 50)
label.Position = UDim2.new(0.5, -150, 0, 20)
label.BackgroundTransparency = 0.3
label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold
label.TextScaled = true
label.Text = "Initializing..."

local function updateStatus(text)
	label.Text = text
end

-- Force teleport with retry
local function forceTeleport(serverId)
	updateStatus("Teleporting...")
	local success = false
	for i = 1, 5 do
		local didTp = pcall(function()
			TeleportService:TeleportToPlaceInstance(PlaceId, serverId, LocalPlayer)
		end)
		if didTp then
			success = true
			break
		end
		updateStatus("Teleport failed. Retrying ("..i..")")
		wait(2)
	end
	if not success then
		updateStatus("All teleport attempts failed. Retrying new server...")
		wait(2)
	end
end

-- Server hop logic
local function serverHop()
	while true do
		local success, data = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(
				"https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
		end)

		if success and data and data.data then
			for _, server in ipairs(data.data) do
				local id = server.id
				local playing = server.playing
				if id ~= CurrentJobId and not visitedServers[id] and playing < 7 then
					visitedServers[id] = true
					updateStatus("Joining "..playing.." player server...")
					getgenv().ScriptToRun = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))()
loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
					]]
					forceTeleport(id)
					return
				end
			end
		end

		updateStatus("No valid servers found. Trying again...")
		wait(5)
	end
end

-- Auto-hop if server gets too full
task.spawn(function()
	while true do
		local count = #Players:GetPlayers()
		if count >= 7 then
			updateStatus("Too many players ("..count.."). Server hopping...")
			wait(2)
			serverHop()
			break
		else
			updateStatus("Good server: "..count.." players.")
		end
		wait(3)
	end
end)
