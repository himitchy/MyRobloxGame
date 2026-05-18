--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DragonConfig = require(ReplicatedStorage:WaitForChild("DragonConfig"))

local function spawnDragon(dragonType: string, position: Vector3)
	local model = Instance.new("Model")
	model.Name = dragonType .. "Dragon"

	-- Large red placeholder body; named HumanoidRootPart so proximity
	-- detection in DragonTamingServer can find it
	local body = Instance.new("Part")
	body.Name = "HumanoidRootPart"
	body.Size = Vector3.new(8, 4, 12)
	body.Color = Color3.fromRGB(200, 40, 40)
	body.Material = Enum.Material.SmoothPlastic
	body.CFrame = CFrame.new(position)
	body.Parent = model
	model.PrimaryPart = body

	-- Humanoid required for flee speed change on failed tame
	local humanoid = Instance.new("Humanoid")
	humanoid.WalkSpeed = 8
	humanoid.Parent = model

	local typeValue = Instance.new("StringValue")
	typeValue.Name = "DragonType"
	typeValue.Value = dragonType
	typeValue.Parent = model

	model.Parent = workspace
	CollectionService:AddTag(model, DragonConfig.WILD_TAG)
end

spawnDragon("Ember", Vector3.new(0, 3, -30))
