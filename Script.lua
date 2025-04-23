-- Services
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

-- Server memory
local visitedServers = {}
local currentJobId = game.JobId
local nextPageCursor = nil
local teleporting = false
local toggle = true

-- GUI (unchanged)
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "StatusGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 240, 0, 70)
frame.Position = UDim2.new(0.5, -120, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(60, 60, 60)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0.5, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.Text = "Waiting..."

local countLabel = Instance.new("TextLabel", frame)
countLabel.Size = UDim2.new(1, 0, 0.5, 0)
countLabel.Position = UDim2.new(0, 0, 0.5, 0)
countLabel.BackgroundTransparency = 1
countLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
countLabel.Font = Enum.Font.Gotham
countLabel.TextScaled = true
countLabel.Text = "0 / ? Players"

local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(0, 60, 0, 25)
toggleButton.Position = UDim2.new(1, -65, 1, 5)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
toggleButton.Text = "On"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextScaled = true
toggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
toggleButton.MouseButton1Click:Connect(function()
	toggle = not toggle
	toggleButton.Text = toggle and "On" or "Off"
	toggleButton.BackgroundColor3 = toggle and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

-- GUI Update Helpers
local function updateStatus(text, color)
	statusLabel.Text = text
	statusLabel.TextColor3 = color
end

local function updatePlayerCount()
	local total = #Players:GetPlayers()
	local max = game.Players.MaxPlayers or "?"
	countLabel.Text = total .. " / " .. max .. " Players"
end

-- Proximity check
local function isPlayerTooClose()
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
	local myPos = LocalPlayer.Character.HumanoidRootPart.Position
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if (myPos - player.Character.HumanoidRootPart.Position).Magnitude < 35 then
				return true
			end
		end
	end
	return false
end

-- Fetch servers
local function getServers()
	local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
	if nextPageCursor then
		url = url .. "&cursor=" .. nextPageCursor
	end
	local success, response = pcall(function()
		return HttpService:JSONDecode(game:HttpGet(url))
	end)
	if success and response and response.data then
		nextPageCursor = response.nextPageCursor
		return response.data
	end
	return {}
end

-- Teleport Logic
local function serverHop()
	if teleporting then return end
	teleporting = true

	local tries = 0
	while tries < 10 do
		local servers = getServers()
		for _, server in ipairs(servers) do
			if server.id ~= currentJobId and not visitedServers[server.id] and server.playing < server.maxPlayers then
				local projected = server.playing + 1
				if projected <= 7 then
					visitedServers[server.id] = true
					updateStatus("Teleporting...", Color3.fromRGB(255, 170, 0))
					queue_on_teleport(scriptToRun)

					local success, result = pcall(function()
						return TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
					end)

					if not success then
						updateStatus("Teleport failed. Retrying in 60s", Color3.fromRGB(255, 50, 50))
						wait(60)
						teleporting = false
						return
					end

					return
				end
			end
		end
		tries += 1
		wait(1)
	end

	updateStatus("No valid servers", Color3.fromRGB(200, 0, 0))
	teleporting = false
end

-- Main Loop
task.spawn(function()
	while true do
		task.wait(1)
		if not toggle then continue end
		updatePlayerCount()

		local count = #Players:GetPlayers()
		if count > 7 then
			updateStatus("Too many players", Color3.fromRGB(255, 80, 80))
			wait(1)
			serverHop()
		elseif isPlayerTooClose() then
			updateStatus("Player nearby!", Color3.fromRGB(255, 100, 100))
			wait(1)
			serverHop()
		else
			updateStatus("Safe", Color3.fromRGB(0, 255, 0))
		end
	end
end)
