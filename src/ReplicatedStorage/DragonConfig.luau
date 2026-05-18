--!strict

export type DragonType = {
	displayName: string,
	difficulty: number, -- failure chance per taming stage (0–1)
}

local DragonConfig = {}

DragonConfig.TAME_RADIUS = 15    -- studs a player must be within to tame
DragonConfig.TAME_STAGES = 5     -- number of progress steps
DragonConfig.STAGE_INTERVAL = 1  -- seconds between each stage

DragonConfig.WILD_TAG = "WildDragon"
DragonConfig.TAMED_TAG = "TamedDragon"

DragonConfig.Types = {
	Ember = { displayName = "Ember Dragon", difficulty = 0.15 },
	Frost = { displayName = "Frost Dragon", difficulty = 0.25 },
	Storm = { displayName = "Storm Dragon", difficulty = 0.40 },
} :: { [string]: DragonType }

return DragonConfig
