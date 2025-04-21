local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- Track visited server IDs
local visitedServers = {}
local function isServerVisited(serverId)
	return visitedServers[serverId] == true
end

local function markServerVisited(serverId)
	visitedServers[serverId] = true
end

local function resetVisitedServers()
	visitedServers = {}
end

-- Script to run on teleport (load both scripts)
local scriptToRun = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))()
loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
]]

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatusGui"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 60)
frame.Position = UDim2.new(0.5, -110, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = frame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(60, 60, 60)
uiStroke.Thickness = 2
uiStroke.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.Text = "Checking..."
statusLabel.Parent = frame

-- Update GUI text
local function updateStatus(text, color)
	if statusLabel and typeof(statusLabel) == "Instance" then
		statusLabel.Text = text
		statusLabel.TextColor3 = color
	end
end

-- Player proximity detection
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

-- Server hopping logic
local function serverHop()
	updateStatus("Looking for Server...", Color3.fromRGB(255, 255, 0))

	local success, result = pcall(function()
		return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
	end)

	if success and result and result.data then
		local found = false
		for _, server in ipairs(result.data) do
			local playerCount = server.playing
			local willBe = playerCount + 1
			if not isServerVisited(server.id) and server.id ~= game.JobId and server.playing < server.maxPlayers and (willBe >= 3 and willBe <= 5) then
				queue_on_teleport(scriptToRun)
				markServerVisited(server.id)
				updateStatus("Hopping Server...", Color3.fromRGB(255, 165, 0))
				TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
				found = true
				break
			end
		end
		if not found then
			resetVisitedServers()
			updateStatus("Cycle Reset... Retrying", Color3.fromRGB(255, 100, 100))
		end
	else
		updateStatus("Server List Failed", Color3.fromRGB(255, 0, 0))
	end
end

-- Main loop
task.spawn(function()
	while true do
		task.wait(1.5)

		local currentPlayers = #Players:GetPlayers()
		local nearby = isPlayerNearby()

		if nearby then
			updateStatus("Player Too Close", Color3.fromRGB(255, 80, 80))
			task.wait(1)
			serverHop()
			break
		elseif currentPlayers > 5 then
			updateStatus("Too Many Players", Color3.fromRGB(255, 150, 80))
			task.wait(1)
			serverHop()
			break
		else
			updateStatus("Safe", Color3.fromRGB(0, 255, 0))
		end
	end
end)
