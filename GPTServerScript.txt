local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteFunction = Instance.new("RemoteFunction")
remoteFunction.Name = "GetCodeFromAI"
remoteFunction.Parent = ReplicatedStorage

-- 🔑 REPLACE WITH YOUR OPENAI API KEY BELOW
local API_KEY = "sk-REPLACE_THIS_WITH_YOUR_KEY"

local endpoint = "https://api.openai.com/v1/chat/completions"

remoteFunction.OnServerInvoke = function(player, promptText)
    local body = {
        model = "gpt-4",
        messages = {
            { role = "system", content = "You are a helpful Roblox Lua code assistant." },
            { role = "user", content = promptText }
        }
    }

    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = endpoint,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. API_KEY
            },
            Body = HttpService:JSONEncode(body)
        })
    end)

    if not success then
        return "Request failed: " .. tostring(response)
    end

    if not response.Success then
        return "HTTP error: " .. response.StatusCode
    end

    local data = HttpService:JSONDecode(response.Body)
    local message = data.choices[1].message.content

    return message
end
