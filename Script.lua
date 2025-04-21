local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- Script to run after teleport
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
frame.Size = UDim2.new(0, 240, 0, 100)
frame.Position = UDim2.new(0.5, -120, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local uiStroke = Instance.new("UIStroke", frame)
uiStroke.Color = Color3.fromRGB(60, 60, 60)
uiStroke.Thickness = 2

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0.4, 0)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.Text = "Loading..."

local countLabel = Instance.new("TextLabel", frame)
countLabel.Size = UDim2.new(1, 0, 0.3, 0)
countLabel.Position = UDim2.new(0, 0, 0.4, 0)
countLabel.BackgroundTransparency = 1
countLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
countLabel.Font = Enum.Font.Gotham
countLabel.TextScaled = true
countLabel.Text = "..."

-- Toggle Button
local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(0.4, 0, 0.25, 0)
toggleButton.Position = UDim2.new(0.3, 0, 0.7, 5)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
toggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextScaled = true
toggleButton.Text = "ON"
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 8)

local detectionActive = true
toggleButton.MouseButton1Click:Connect(function()
	detectionActive = not detectionActive
	if detectionActive then
		toggleButton.Text = "ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	else
		toggleButton.Text = "OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	end
end)

-- Status update
local function updateStatus(text, color)
	statusLabel.Text = text
	statusLabel.TextColor3 = color
end

-- Server ID tracker
local visitedServers = {}

-- Count active players
local function updatePlayerCount()
	countLabel.Text = "Players: " .. tostring(#Players:GetPlayers())
end

-- Nearby player detection
local function isPlayerNearby()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
	local myPos = char.HumanoidRootPart.Position

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if (myPos - player.Character.HumanoidRootPart.Position).Magnitude <= 35 then
				return true
			end
		end
	end
	return false
end

-- Server hop function
local function serverHop()
	local success, result = pcall(function()
		return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
	end)

	if success and result and result.data then
		for _, server in ipairs(result.data) do
			local playerCount = server.playing
			local afterJoin = playerCount + 1
			if server.id ~= game.JobId and not visitedServers[server.id] and playerCount < server.maxPlayers and (afterJoin >= 2 and afterJoin <= 4) then
				visitedServers[server.id] = true
				updateStatus("Hopping Server", Color3.fromRGB(255, 165, 0))
				queue_on_teleport(scriptToRun)
				TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
				return
			end
		end
		-- Reset visited list if all servers checked
		visitedServers = {}
		updateStatus("Restarting Server List", Color3.fromRGB(255, 255, 100))
	else
		warn("Failed to get server list")
	end
end

-- Main loop
task.spawn(function()
	while true do
		updatePlayerCount()
		if not detectionActive then
			updateStatus("Detection Off", Color3.fromRGB(150, 150, 150))
			task.wait(1)
			continue
		end

		local currentPlayerCount = #Players:GetPlayers()
		if isPlayerNearby() then
			updateStatus("Player Close", Color3.fromRGB(255, 50, 50))
			task.wait(1)
			serverHop()
			break
		elseif currentPlayerCount > 5 then
			updateStatus("Too Many Players", Color3.fromRGB(255, 150, 0))
			task.wait(1)
			serverHop()
			break
		else
			updateStatus("Safe", Color3.fromRGB(0, 255, 0))
		end
		task.wait(1)
	end
end)
