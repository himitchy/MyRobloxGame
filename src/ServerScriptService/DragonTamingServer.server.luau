--!strict

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DragonConfig = require(ReplicatedStorage:WaitForChild("DragonConfig"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RequestTame  = Remotes:WaitForChild("RequestTame")  :: RemoteEvent
local TamingUpdate = Remotes:WaitForChild("TamingUpdate") :: RemoteEvent
local TamingResult = Remotes:WaitForChild("TamingResult") :: RemoteEvent

local activeSessions: { [Player]: boolean } = {}

local function getClosestWildDragon(player: Player): Model?
	local character = player.Character
	if not character then return nil end
	local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then return nil end

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

	return best
end

local function isPlayerNearDragon(player: Player, dragon: Model): boolean
	local character = player.Character
	if not character then return false end
	local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local dragonRoot = dragon:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root or not dragonRoot then return false end
	return (root.Position - dragonRoot.Position).Magnitude <= DragonConfig.TAME_RADIUS
end

local function runTamingSequence(player: Player, dragon: Model)
	activeSessions[player] = true

	local dragonTypeValue = dragon:FindFirstChild("DragonType") :: StringValue?
	local typeName = if dragonTypeValue then dragonTypeValue.Value else "Ember"
	local dragonData = DragonConfig.Types[typeName] or DragonConfig.Types["Ember"]

	local success = true

	for stage = 1, DragonConfig.TAME_STAGES do
		-- Abort if player left, dragon was removed, or player walked away
		if not player.Parent or not dragon.Parent or not isPlayerNearDragon(player, dragon) then
			success = false
			break
		end

		TamingUpdate:FireClient(player, stage / DragonConfig.TAME_STAGES, stage, DragonConfig.TAME_STAGES)

		if math.random() < dragonData.difficulty then
			success = false
			break
		end

		task.wait(DragonConfig.STAGE_INTERVAL)
	end

	activeSessions[player] = nil

	if not dragon.Parent then return end

	if success then
		CollectionService:RemoveTag(dragon, DragonConfig.WILD_TAG)
		CollectionService:AddTag(dragon, DragonConfig.TAMED_TAG)

		local ownerTag = Instance.new("StringValue")
		ownerTag.Name = "Owner"
		ownerTag.Value = player.Name
		ownerTag.Parent = dragon

		TamingResult:FireClient(player, true, dragonData.displayName)
	else
		-- Dragon flees at double speed for 5 seconds
		local humanoid = dragon:FindFirstChildOfClass("Humanoid") :: Humanoid?
		if humanoid then
			local normalSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = normalSpeed * 2
			task.delay(5, function()
				if humanoid and humanoid.Parent then
					humanoid.WalkSpeed = normalSpeed
				end
			end)
		end

		TamingResult:FireClient(player, false, dragonData.displayName)
	end
end

RequestTame.OnServerEvent:Connect(function(player: Player)
	if activeSessions[player] then return end

	local dragon = getClosestWildDragon(player)
	if not dragon then return end

	task.spawn(runTamingSequence, player, dragon)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	activeSessions[player] = nil
end)
