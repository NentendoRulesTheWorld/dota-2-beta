-- Generated from template

if TetrisGameMode == nil then
	_G.TetrisGameMode = class({})
end

require('tetris_mode')

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]

	--towers
	PrecacheResource( "model", "models/props_structures/tower_good.vmdl", context )
	PrecacheResource( "particle", "particles/base_attacks/ranged_tower_good.vpcf", context )
	PrecacheResource( "soundfile", "sounds/weapons/towers/attack_radient.vsnd", context )

	PrecacheResource( "model", "models/props_structures/tower_bad.vmdl", context )
	PrecacheResource( "particle", "particles/base_attacks/ranged_tower_bad.vpcf", context )
	PrecacheResource( "soundfile", "sounds/weapons/towers/attack_dire.vsnd", context )
	PrecacheResource( "model", "models/props_structures/tower001.vmdl", context )
	
	--creeper
	PrecacheResource( "model", "models/creeps/neutral_creeps/n_creep_golem_a/neutral_creep_golem_a.mdl", context )
	PrecacheResource( "model", "models/creeps/neutral_creeps/n_creep_forest_trolls/n_creep_forest_troll_high_priest.mdl", context )

	PrecacheResource( "particle", "particles/base_attacks/ranged_badguy.vpcf", context )
	PrecacheResource( "particle", "particles/base_attacks/ranged_goodguy.vpcf", context )

	--skill
	PrecacheResource( "particle", "particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", context )
	
	
	
end

-- Create the game mode when we activate
function Activate()
	GameRules.TetrisGameMode = TetrisGameMode()
	GameRules.TetrisGameMode:InitGameMode()
end