local plr = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId
local JobId = game.JobId

-- ✅ If just teleported, auto-load main script and this one again
local data = TeleportService:GetLocalPlayerTeleportData()
if data and type(data) == "table" and data.__loader then
    loadstring(data.__loader)()
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

-- ✅ Update Wallet + Bank
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
			warn("Failed to fetch servers:", result)
			break
		end
	until not cursor or #servers > 0

	return #servers > 0 and servers[math.random(1, #servers)] or nil
end

-- ✅ Countdown + Teleport (with test button)
local totalTime = 1800 -- 30 minutes

-- ✅ Test Button
local testBtn = Instance.new("TextButton")
testBtn.Size = UDim2.new(0, 80, 0, 20)
testBtn.Position = UDim2.new(1, -85, 1, -25)
testBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
testBtn.Text = "Test"
testBtn.Font = Enum.Font.SourceSansBold
testBtn.TextSize = 14
testBtn.Parent = frame
testBtn.MouseButton1Click:Connect(function()
	totalTime = math.max(0, totalTime - 1740) -- subtract 29 minutes
end)

task.spawn(function()
	while totalTime > 0 do
		timerTxt.Text = string.format("Next Hop: %02d:%02d", math.floor(totalTime / 60), totalTime % 60)
		task.wait(1)
		totalTime -= 1
	end

	local loaderCode = [[
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/BlockSpin-Auto-Farm-Roblox/refs/heads/main/Script.lua"))()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Nate7953/BlockSpin-Auto-Farm-Roblox/refs/heads/main/Script.lua"))()
	]]

	local teleportData = {__loader = loaderCode}
	local srv = pickServer()
	if srv then
		TeleportService:TeleportToPlaceInstance(PlaceId, srv, plr, teleportData)
	else
		warn("No new server found, retrying fallback...")
		task.wait(60)
		TeleportService:Teleport(PlaceId, plr, teleportData)
	end
end)
