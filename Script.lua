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

-- GUI Setup
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "StatusGui"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 260, 0, 90)
frame.Position = UDim2.new(0.5, -130, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 12)

local uiStroke = Instance.new("UIStroke", frame)
uiStroke.Color = Color3.fromRGB(60, 60, 60)
uiStroke.Thickness = 2

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0.5, 0)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.Text = "Checking..."

local serverCountLabel = Instance.new("TextLabel", frame)
serverCountLabel.Size = UDim2.new(1, 0, 0.3, 0)
serverCountLabel.Position = UDim2.new(0, 0, 0.5, 0)
serverCountLabel.BackgroundTransparency = 1
serverCountLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
serverCountLabel.Font = Enum.Font.Gotham
serverCountLabel.TextScaled = true
serverCountLabel.Text = "Server 0 / 0"

local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(0, 60, 0, 25)
toggleButton.Position = UDim2.new(1, -65, 1, -30)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
toggleButton.Text = "OFF"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.TextScaled = true

local toggleUICorner = Instance.new("UICorner", toggleButton)
toggleUICorner.CornerRadius = UDim.new(0, 6)

local detectionEnabled = true
toggleButton.MouseButton1Click:Connect(function()
	detectionEnabled = not detectionEnabled
	if detectionEnabled then
		toggleButton.Text = "ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	else
		toggleButton.Text = "OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	end
end)

-- Utilities
local visitedServers = {}
local function updateStatus(text, color)
	statusLabel.Text = text
	statusLabel.TextColor3 = color
end

local function updateServerCount(current, total)
	serverCountLabel.Text = "Server " .. current .. " / " .. total
end

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

local function getServers()
	local servers = {}
	local cursor = ""
	repeat
		local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
		local success, result = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)
		if success and result and result.data then
			for _, server in ipairs(result.data) do
				local afterJoin = server.playing + 1
				if server.id ~= game.JobId and afterJoin >= 2 and afterJoin <= 5 then
					table.insert(servers, server.id)
				end
			end
			cursor = result.nextPageCursor or ""
		else
			break
		end
	until cursor == nil or cursor == ""
	return servers
end

local function serverHopLoop()
	while true do
		task.wait(2)
		if not detectionEnabled then
			updateStatus("Detection OFF", Color3.fromRGB(255, 0, 0))
			continue
		end

		local nearby = isPlayerNearby()
		local currentCount = #Players:GetPlayers()

		if nearby then
			updateStatus("Player Close", Color3.fromRGB(255, 80, 80))
		elseif currentCount > 5 then
			updateStatus("Too Many Players", Color3.fromRGB(255, 150, 80))
		else
			updateStatus("Safe", Color3.fromRGB(0, 255, 0))
			continue
		end

		local servers = getServers()
		for i, id in ipairs(servers) do
			updateServerCount(i, #servers)
			if not visitedServers[id] then
				visitedServers[id] = true
				updateStatus("Hopping Server", Color3.fromRGB(255, 165, 0))
				queue_on_teleport(scriptToRun)
				TeleportService:TeleportToPlaceInstance(PlaceId, id, LocalPlayer)
				return
			end
		end

		-- Reset visited and loop again
		visitedServers = {}
		updateStatus("Restarting Cycle", Color3.fromRGB(255, 255, 0))
	end
end

task.spawn(serverHopLoop)
