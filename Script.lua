if not game:IsLoaded() then game.Loaded:Wait() end

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- Track visited JobIds globally across hops
_G.VisitedServers = _G.VisitedServers or {}
_G.VisitedServers[game.JobId] = true

-- Auto-run these scripts every teleport
queue_on_teleport([[
    if not game:IsLoaded() then game.Loaded:Wait() end
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/Bl/main/Script.lua"))()
    loadstring(game:HttpGet("https://rawscripts.net/raw/BlockSpin-OMEGA!!-Auto-Farm-Money-with-ATMs-and-Steak-House-35509"))()
]])

-- GUI Setup
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "StatusGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 70)
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

local function updateStatus(text, color)
	statusLabel.Text = text
	statusLabel.TextColor3 = color
end

local function updatePlayerCount()
	local count = #Players:GetPlayers()
	local max = Players.MaxPlayers or "?"
	countLabel.Text = count .. " / " .. max .. " Players"
end

local function hop()
	updateStatus("Hopping...", Color3.fromRGB(255, 255, 0))
	local servers = {}

	local success, result = pcall(function()
		return game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
	end)

	if success then
		local data = HttpService:JSONDecode(result)
		for _, server in pairs(data.data) do
			local id = server.id
			if tonumber(server.playing) < 8 and not _G.VisitedServers[id] and id ~= game.JobId then
				TeleportService:TeleportToPlaceInstance(PlaceId, id, LocalPlayer)
				break
			end
		end
	else
		updateStatus("Failed to Get Servers", Color3.fromRGB(255, 0, 0))
	end
end

task.spawn(function()
	while true do
		task.wait(2)
		if not toggle then continue end

		updatePlayerCount()

		if #Players:GetPlayers() > 8 then
			updateStatus("Too Many Players", Color3.fromRGB(255, 100, 0))
			task.wait(5)
			hop()
		elseif _G.VisitedServers[game.JobId] then
			updateStatus("Already Visited. Hopping...", Color3.fromRGB(255, 150, 0))
			task.wait(5)
			hop()
		else
			updateStatus("Safe", Color3.fromRGB(0, 255, 0))
		end
	end
end)
