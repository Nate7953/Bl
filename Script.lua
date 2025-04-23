local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = 104715542330896

-- TRACK SERVERS
local visitedServers = {}
visitedServers[game.JobId] = true

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatusGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 240, 0, 70)
frame.Position = UDim2.new(0.5, -120, 0.1, 0)
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
countLabel.Size = UDim2.new(1, 0, 0.5, 0)
countLabel.Position = UDim2.new(0, 0, 0.5, 0)
countLabel.BackgroundTransparency = 1
countLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
countLabel.Font = Enum.Font.Gotham
countLabel.TextScaled = true
countLabel.Text = "0 / 0 Players"

-- TOGGLE BUTTON
local toggle = true
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

-- STATUS & PLAYER COUNTS
local function updateStatus(text, color)
	statusLabel.Text = text
	statusLabel.TextColor3 = color
end

local function updatePlayerCount()
	local count = #Players:GetPlayers()
	local max = Players.MaxPlayers or "?"
	countLabel.Text = count .. " / " .. max .. " Players"
end

-- NEARBY PLAYER DETECTION
local function isPlayerNearby()
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return false end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (player.Character.HumanoidRootPart.Position - root.Position).Magnitude
			if dist <= 35 then return true end
		end
	end
	return false
end

-- SERVER HOP FUNCTION (SIMPLE WORKING TELEPORT METHOD)
local function serverHop()
	updateStatus("Checking player count...", Color3.fromRGB(255, 255, 0))
	if #Players:GetPlayers() > 7 then
		updateStatus("Too many players, hopping...", Color3.fromRGB(0, 255, 255))
		local success, message = pcall(function()
			TeleportService:Teleport(PlaceId, LocalPlayer)
		end)

		if success then
			updateStatus("Teleported!", Color3.fromRGB(0, 255, 0))
		else
			updateStatus("Teleport failed", Color3.fromRGB(255, 0, 0))
			warn("Teleport failed: " .. message)
		end
	else
		updateStatus("Not enough players to hop", Color3.fromRGB(255, 255, 255))
	end
end

-- INIT CHECK
updatePlayerCount()
if #Players:GetPlayers() > 7 or isPlayerNearby() then
	task.wait(0.5)
	serverHop()
end

-- LOOP
task.spawn(function()
	while true do
		task.wait(0.2)
		if not toggle then continue end
		updatePlayerCount()

		if #Players:GetPlayers() > 7 then
			task.wait(4.1)
			serverHop()
		elseif isPlayerNearby() then
			task.wait(0.2)
			serverHop()
		end
	end
end)
