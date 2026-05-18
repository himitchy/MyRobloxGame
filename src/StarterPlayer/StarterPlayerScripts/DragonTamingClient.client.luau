--!strict

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DragonConfig = require(ReplicatedStorage:WaitForChild("DragonConfig"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RequestTame  = Remotes:WaitForChild("RequestTame")  :: RemoteEvent
local TamingUpdate = Remotes:WaitForChild("TamingUpdate") :: RemoteEvent
local TamingResult = Remotes:WaitForChild("TamingResult") :: RemoteEvent

local player = Players.LocalPlayer
local isTaming = false
local nearbyDragon: Model? = nil

-- UI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DragonTamingGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local promptLabel = Instance.new("TextLabel")
promptLabel.Size = UDim2.fromOffset(280, 44)
promptLabel.Position = UDim2.new(0.5, -140, 0.82, 0)
promptLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
promptLabel.BackgroundTransparency = 0.45
promptLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
promptLabel.TextSize = 17
promptLabel.Font = Enum.Font.GothamBold
promptLabel.Visible = false
promptLabel.Parent = screenGui

local progressBg = Instance.new("Frame")
progressBg.Size = UDim2.fromOffset(280, 22)
progressBg.Position = UDim2.new(0.5, -140, 0.78, 0)
progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
progressBg.Visible = false
progressBg.Parent = screenGui

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(80, 200, 110)
progressBar.BorderSizePixel = 0
progressBar.Parent = progressBg

local progressText = Instance.new("TextLabel")
progressText.Size = UDim2.new(1, 0, 1, 0)
progressText.BackgroundTransparency = 1
progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
progressText.TextSize = 13
progressText.Font = Enum.Font.Gotham
progressText.Text = ""
progressText.Parent = progressBg

local function showPrompt(text: string)
	promptLabel.Text = text
	promptLabel.Visible = true
end

local function hidePrompt()
	promptLabel.Visible = false
end

local function showProgress(ratio: number, label: string)
	progressBar.Size = UDim2.new(ratio, 0, 1, 0)
	progressText.Text = label
	progressBg.Visible = true
end

local function hideProgress()
	progressBg.Visible = false
end

-- Proximity detection
RunService.Heartbeat:Connect(function()
	if isTaming then return end

	local character = player.Character
	if not character then
		nearbyDragon = nil
		hidePrompt()
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then return end

	local best: Model? = nil
	local bestDist = DragonConfig.TAME_RADIUS

	for _, instance in CollectionService:GetTagged(DragonConfig.WILD_TAG) do
		local dragon = instance :: Model
		local dragonRoot = dragon:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not dragonRoot then continue end
		local dist = (root.Position - dragonRoot.Position).Magnitude
		if dist < bestDist then
			bestDist = dist
			best = dragon
		end
	end

	nearbyDragon = best

	if best then
		showPrompt("[E]  Tame Dragon")
	else
		hidePrompt()
	end
end)

-- E key to start taming
UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
	if gameProcessed then return end
	if input.KeyCode ~= Enum.KeyCode.E then return end
	if isTaming or not nearbyDragon then return end

	isTaming = true
	hidePrompt()
	showProgress(0, "Taming…  0 / " .. DragonConfig.TAME_STAGES)
	RequestTame:FireServer()
end)

-- Progress updates from server
TamingUpdate.OnClientEvent:Connect(function(ratio: number, stage: number, total: number)
	showProgress(ratio, string.format("Taming…  %d / %d", stage, total))
end)

-- Final result from server
TamingResult.OnClientEvent:Connect(function(success: boolean, dragonName: string)
	isTaming = false
	hideProgress()

	if success then
		progressBar.BackgroundColor3 = Color3.fromRGB(80, 200, 110)
		showPrompt("You tamed a " .. dragonName .. "!")
	else
		showPrompt("The " .. dragonName .. " fled!")
	end

	task.delay(3, function()
		if not isTaming then
			hidePrompt()
		end
	end)
end)
