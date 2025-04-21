local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- GUI Setup
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "StatusGui"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 260, 0, 100)
frame.Position = UDim2.new(0.5, -130, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(60, 60, 60)
stroke.Thickness = 2

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0.5, 0)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = "Loading..."

local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(1, 0, 0.5, 0)
toggleButton.Position = UDim2.new(0, 0, 0.5, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "OFF"

local active = false
toggleButton.MouseButton1Click:Connect(function()
	active = not active
	if active then
		toggleButton.Text = "ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	else
		toggleButton.Text = "OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	end
end)

-- Teleport queue script
local scriptToRun = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/refs/heads/main/Script.lua"))()
loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
]]

-- Track visited servers
local visited = {}
local pageCursor = nil

local function updateStatus(text, color)
	statusLabel.Text = text
	statusLabel.TextColor3 = color
end

local function isPlayerNearby()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
	local pos = char.HumanoidRootPart.Position

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			if (plr.Character.HumanoidRootPart.Position - pos).Magnitude <= 35 then
				return true
			end
		end
	end
	return false
end

local function serverHop()
	local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
	if pageCursor then
		url = url .. "&cursor=" .. pageCursor
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(game:HttpGet(url))
	end)

	if success and result and result.data then
		for _, server in ipairs(result.data) do
			local id = server.id
			local playing = server.playing
			local totalAfterJoin = playing + 1

			if not visited[id] and playing < server.maxPlayers and totalAfterJoin >= 2 and totalAfterJoin <= 5 then
				visited[id] = true
				updateStatus("Hopping to new server...", Color3.fromRGB(255, 165, 0))
				queue_on_teleport(scriptToRun)
				TeleportService:TeleportToPlaceInstance(PlaceId, id, LocalPlayer)
				return
			end
		end

		if result.nextPageCursor then
			pageCursor = result.nextPageCursor
		else
			visited = {}
			pageCursor = nil
			updateStatus("Restarting cycle...", Color3.fromRGB(100, 100, 255))
		end
	else
		updateStatus("Failed to load servers", Color3.fromRGB(255, 80, 80))
	end
end

task.spawn(function()
	while true do
		task.wait(1.5)
		if active then
			local count = #Players:GetPlayers()
			if count > 5 then
				updateStatus("Too Many Players", Color3.fromRGB(255, 80, 80))
				task.wait(1)
				serverHop()
			elseif isPlayerNearby() then
				updateStatus("Player Close", Color3.fromRGB(255, 120, 0))
				task.wait(1)
				serverHop()
			else
				updateStatus("Safe | Players: " .. tostring(count), Color3.fromRGB(0, 255, 0))
			end
		else
			updateStatus("Detection OFF", Color3.fromRGB(200, 0, 0))
		end
	end
end)
