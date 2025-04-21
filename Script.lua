local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- Remote Script to Run on Teleport
local scriptToRun = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))()
loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
]]

-- Variables
local visited = {}
local detectionEnabled = true

-- GUI Setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "DetectionGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 90)
frame.Position = UDim2.new(0.5, -125, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, 0, 0.5, 0)
status.Position = UDim2.new(0, 0, 0, 0)
status.BackgroundTransparency = 1
status.Font = Enum.Font.GothamBold
status.TextScaled = true
status.TextColor3 = Color3.new(1,1,1)
status.Text = "Checking..."

local countLabel = Instance.new("TextLabel", frame)
countLabel.Size = UDim2.new(1, 0, 0.3, 0)
countLabel.Position = UDim2.new(0, 0, 0.5, 0)
countLabel.BackgroundTransparency = 1
countLabel.Font = Enum.Font.Gotham
countLabel.TextScaled = true
countLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
countLabel.Text = "Players: 0/0"

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.5, -5, 0.2, 0)
toggle.Position = UDim2.new(0.5, 5, 0.8, 0)
toggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
toggle.Font = Enum.Font.GothamBold
toggle.TextColor3 = Color3.new(0,0,0)
toggle.TextScaled = true
toggle.Text = "ON"

local function updateStatus(text, color)
	status.Text = text
	status.TextColor3 = color
end

local function updateCount()
	local count = #Players:GetPlayers()
	countLabel.Text = "Players: "..count.."/"..Players.MaxPlayers
end

toggle.MouseButton1Click:Connect(function()
	detectionEnabled = not detectionEnabled
	if detectionEnabled then
		toggle.Text = "ON"
		toggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	else
		toggle.Text = "OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	end
end)

-- Proximity Detection
local function isPlayerClose()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (char.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
			if dist <= 35 then return true end
		end
	end
	return false
end

-- Server Hop Logic
local function hop()
	updateStatus("Finding Server...", Color3.fromRGB(255, 255, 0))
	local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
	local success, data = pcall(function()
		return HttpService:JSONDecode(game:HttpGet(url))
	end)

	if success and data and data.data then
		for _, server in pairs(data.data) do
			local id = server.id
			local count = server.playing
			if not visited[id] and id ~= game.JobId and count < server.maxPlayers then
				local afterJoin = count + 1
				if afterJoin >= 2 and afterJoin <= 5 then
					visited[id] = true
					updateStatus("Teleporting...", Color3.fromRGB(255, 165, 0))
					queue_on_teleport(scriptToRun)
					TeleportService:TeleportToPlaceInstance(PlaceId, id, LocalPlayer)
					return
				end
			end
		end
		-- Reset cycle
		visited = {}
		updateStatus("Restarting Cycle...", Color3.fromRGB(150, 150, 255))
	end
end

-- Main Loop
task.spawn(function()
	while true do
		task.wait(1)
		updateCount()
		if detectionEnabled then
			local players = #Players:GetPlayers()
			if players > 5 then
				updateStatus("Too Many Players", Color3.fromRGB(255, 80, 80))
				task.wait(1)
				hop()
			elseif isPlayerClose() then
				updateStatus("Player Close!", Color3.fromRGB(255, 100, 100))
				task.wait(1)
				hop()
			else
				updateStatus("Safe", Color3.fromRGB(0, 255, 0))
			end
		else
			updateStatus("Detection OFF", Color3.fromRGB(255, 0, 0))
		end
	end
end)
