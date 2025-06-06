local promptBox = script.Parent:WaitForChild("PromptBox")
local generateButton = script.Parent:WaitForChild("GenerateButton")
local outputLabel = script.Parent:WaitForChild("OutputLabel")
local remoteFunction = game:GetService("ReplicatedStorage"):WaitForChild("GetCodeFromAI")

generateButton.MouseButton1Click:Connect(function()
    local prompt = promptBox.Text
    outputLabel.Text = "Thinking..."
    local response = remoteFunction:InvokeServer(prompt)
    outputLabel.Text = response
end)
