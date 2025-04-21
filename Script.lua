local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

local visitedServerIds = {}
local currentPageCursor = nil

local scriptToRun = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))()
loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
]]

-- GUI
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "StatusGui"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 260, 0, 80)
frame.Position = UDim2.new(0.5, -130, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local uiStroke = Instance.new("UIStroke", frame)
uiStroke.Color = Color3.fromRGB(60, 60, 60)
uiStroke.Thickness = 2

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0.5, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true
statusLabel.Text = "Checking..."

local countLabel = Instance.new("TextLabel", frame)
countLabel.Position = UDim2.new(0, 0, 0.5, 0)
countLabel.Size = UDim2.new(1, 0, 0.5, 0)
countLabel.BackgroundTransparency = 1
countLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
countLabel.Font = Enum.Font.GothamBold
countLabel.TextScaled = true
countLabel.Text = "Server: 0/0"

local function updateStatus(text, color)
	statusLabel.Text = text
	statusLabel.TextColor3 = color
end

local function updateServerCount(current, total)
	countLabel.Text = "Server: " .. current .. "/" .. total
end

-- Nearby check
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

-- Server hopping
local function serverHop()
	local allServers = {}
	local pagesChecked = 0
	local totalServers = 0

	while true do
		local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
		if currentPageCursor then
			url = url .. "&cursor=" .. currentPageCursor
		end

		local success, result = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)

		if not success or not result or not result.data then
			updateStatus("Failed to fetch servers", Color3.fromRGB(255, 80, 80))
			return
		end

		for _, server in ipairs(result.data) do
			local countAfterJoin = server.playing + 1
			if not visitedServerIds[server.id] and server.id ~= game.JobId and server.playing < server.maxPlayers and (countAfterJoin == 2 or countAfterJoin == 3 or countAfterJoin == 4) then
				visitedServerIds[server.id] = true
				updateStatus("Hopping Server...", Color3.fromRGB(255, 165, 0))
				queue_on_teleport(scriptToRun)
				TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
				return
			end
			totalServers += 1
		end

		pagesChecked += 1
		if result.nextPageCursor then
			currentPageCursor = result.nextPageCursor
		else
			break
		end
	end

	-- Reset if all visited
	if pagesChecked > 0 then
		visitedServerIds = {}
		currentPageCursor = nil
		updateStatus("Restarting Search...", Color3.fromRGB(150, 150, 255))
	else
		updateStatus("No servers found", Color3.fromRGB(255, 80, 80))
	end
end

-- Loop
task.spawn(function()
	while true do
		task.wait(1.5)
		local nearby = isPlayerNearby()
		local count = #Players:GetPlayers()
		updateServerCount(count, 5)

		if nearby then
			updateStatus("Player Nearby", Color3.fromRGB(255, 80, 80))
			task.wait(1)
			serverHop()
			break
		elseif count > 5 then
			updateStatus("Too Many Players", Color3.fromRGB(255, 150, 80))
			task.wait(1)
			serverHop()
			break
		else
			updateStatus("Safe", Color3.fromRGB(0, 255, 0))
		end
	end
end)
