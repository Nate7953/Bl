--// Settings
local MAX_PLAYERS_BEFORE_HOP = 8
local DELAY_TOO_MANY_PLAYERS = 4.1
local DELAY_PLAYER_NEARBY = 0.2
local DETECTION_RANGE = 35

--// Services
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

--// Globals
getgenv().visitedServers = getgenv().visitedServers or {}
local visitedServers = getgenv().visitedServers
local toggled = true

--// GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", gui)
frame.Position = UDim2.new(0.5, -100, 0.1, 0)
frame.Size = UDim2.new(0, 200, 0, 60)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0.5, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Text = "Loading..."
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextScaled = true

local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(0, 60, 0, 25)
toggleButton.Position = UDim2.new(1, -65, 1, -25)
toggleButton.Text = "On"
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
toggleButton.TextScaled = true
toggleButton.MouseButton1Click:Connect(function()
	toggled = not toggled
	toggleButton.Text = toggled and "On" or "Off"
	toggleButton.BackgroundColor3 = toggled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

--// Nearby player check
local function isPlayerTooClose()
	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return false end
	local myPos = myChar.HumanoidRootPart.Position
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if (player.Character.HumanoidRootPart.Position - myPos).Magnitude <= DETECTION_RANGE then
				return true
			end
		end
	end
	return false
end

--// Teleport function
local function teleportToServer(serverId)
	getgenv().visitedServers[serverId] = true
	queue_on_teleport([[
		getgenv().visitedServers = getgenv().visitedServers or {}
		loadstring(game:HttpGet("YOUR_SCRIPT_URL_HERE"))()
	]])
	TeleportService:TeleportToPlaceInstance(PlaceId, serverId, LocalPlayer)
end

--// Server hop
local function hopToNewServer()
	local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
	for _, server in ipairs(servers) do
		if server.id ~= game.JobId and not visitedServers[server.id] and server.playing < server.maxPlayers and (server.playing + 1) < MAX_PLAYERS_BEFORE_HOP then
			statusLabel.Text = "Hopping server..."
			teleportToServer(server.id)
			break
		end
	end
end

--// Main loop
task.spawn(function()
	while true do
		task.wait(0.5)
		if not toggled then continue end

		local playersInServer = #Players:GetPlayers()
		local tooClose = isPlayerTooClose()

		if playersInServer >= MAX_PLAYERS_BEFORE_HOP then
			statusLabel.Text = "Too many players!"
			task.wait(DELAY_TOO_MANY_PLAYERS)
			hopToNewServer()
		elseif tooClose then
			statusLabel.Text = "Player too close!"
			task.wait(DELAY_PLAYER_NEARBY)
			hopToNewServer()
		else
			statusLabel.Text = playersInServer .. " Players - OK"
		end
	end
end)
