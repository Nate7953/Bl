local plr = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId
local JobId = game.JobId

-- ✅ After teleport, auto-load both scripts if flag is passed
local data = TeleportService:GetLocalPlayerTeleportData()
if data and data.__shouldLoadScripts then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/BlockSpin-Auto-Farm-Roblox/refs/heads/main/Script.lua"))()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/xQuartyx/QuartyzScript/main/Loader.lua"))()(
	return
end

-- ✅ GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "MoneyGui"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 125)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local function createLabel(text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.Position = UDim2.new(0, 5, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 16
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = frame
    return lbl
end

local timerTxt = createLabel("Next Hop: 30:00", 5)
local walletTxt = createLabel("Wallet: ...", 30)
local bankTxt = createLabel("Bank: ...", 55)

-- ✅ Variables
local totalTime = 1800 -- 30 mins
local fastHop = false -- set by Test button

-- ✅ Server Picker
local function pickServer()
	local servers = {}
	local cursor = ""
	repeat
		local success, result = pcall(function()
			return game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. cursor)
		end)
		if success then
			local data = HttpService:JSONDecode(result)
			for _, srv in ipairs(data.data) do
				if srv.id ~= JobId and srv.playing < srv.maxPlayers then
					table.insert(servers, srv.id)
				end
			end
			cursor = data.nextPageCursor
		else
			warn("Server fetch failed:", result)
			break
		end
	until not cursor or #servers > 0

	return #servers > 0 and servers[math.random(1, #servers)] or nil
end

-- ✅ Teleport Function
local function teleportWithScripts()
	local teleportData = {__shouldLoadScripts = true}
	local srv = pickServer()
	if srv then
		TeleportService:TeleportToPlaceInstance(PlaceId, srv, plr, teleportData)
	else
		warn("Fallback teleport being used")
		task.wait(1)
		TeleportService:Teleport(PlaceId, plr, teleportData)
	end
end

-- ✅ Test Button
local testBtn = Instance.new("TextButton")
testBtn.Size = UDim2.new(0, 200, 0, 20)
testBtn.Position = UDim2.new(0, 10, 0, 80)
testBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
testBtn.BorderSizePixel = 0
testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
testBtn.Text = "⏩ Test: Skip to 1 min"
testBtn.Font = Enum.Font.SourceSansBold
testBtn.TextSize = 14
testBtn.Parent = frame
testBtn.MouseButton1Click:Connect(function()
	fastHop = true
end)

-- ✅ Wallet & Bank Reader
task.spawn(function()
	while true do
		local wallet = "N/A"
		local bank = "N/A"
		for _,v in ipairs(plr.PlayerGui:GetDescendants()) do
			if v:IsA("TextLabel") then
				local t = v.Text
				if t:find("Hand Balance:") then
					wallet = t:match("%$[%d,]+") or wallet
				elseif t:find("Bank Balance:") then
					bank = t:match("%$[%d,]+") or bank
				end
			end
		end
		walletTxt.Text = "Wallet: " .. wallet
		bankTxt.Text = "Bank: " .. bank
		task.wait(1)
	end
end)

-- ✅ Countdown Handler
task.spawn(function()
	while totalTime > 0 do
		if fastHop and totalTime > 60 then
			totalTime = 60 -- force 1 minute timer
		end
		timerTxt.Text = string.format("Next Hop: %02d:%02d", math.floor(totalTime / 60), totalTime % 60)
		task.wait(1)
		totalTime -= 1
	end
	teleportWithScripts()
end)
