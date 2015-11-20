
DEBUG_SPEW = 1

require('libraries/notifications')

_G.playerlist = {}

_G.good_base_position = -6500 --calculate to get bad or other position

special_creeper_good = { normal = "npc_dota_creep_goodguys_melee",
						range = "npc_dota_creep_goodguys_ranged",
						attacker = "npc_dota_creep_goodguys_melee_upgraded",
						defencer = "tetris_rock_golem",
						heeler = "tetris_forest_troll_high_priest"}

special_creeper_bad = {	normal = "npc_dota_creep_badguys_melee",
						range = "npc_dota_creep_badguys_ranged",
						attacker = "npc_dota_creep_badguys_melee_upgraded",
						defencer = "tetris_rock_golem",
						heeler = "tetris_forest_troll_high_priest"}

function TetrisGameMode:InitGameMode()
	print("init game")
	-- Get Rid of Shop button - Change the UI Layout if you want a shop button
	GameRules:GetGameModeEntity():SetHUDVisible(6, false)
	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1700)

	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(TetrisGameMode, 'OnPlayerPickHero'), self)
	ListenToGameEvent('entity_killed', Dynamic_Wrap(TetrisGameMode, 'OnEntityKilled'), self)

	CustomGameEventManager:RegisterListener( "remove_line", Dynamic_Wrap(TetrisGameMode, "OnLineRemoved"))
	CustomGameEventManager:RegisterListener( "tetris_failed", Dynamic_Wrap(TetrisGameMode, "OnTetrisFailed"))
	CustomGameEventManager:RegisterListener( "train_army", Dynamic_Wrap(TetrisGameMode, "TrainArmy") )

	--hejk add for listen gamestate
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
  	GameRules:SetHeroSelectionTime(1)
	GameRules:SetPreGameTime(1)
	-- GameRules:SetPostGameTime(5)
	GameRules:SetSameHeroSelectionEnabled(true)

	--init structures
  	_G.goodguy_key_structure = CreateUnitByName("npc_dota_goodguys_tower4", Vector(0,_G.good_base_position,128), false, nil, nil, DOTA_TEAM_GOODGUYS)
  	CreateUnitByName("npc_dota_goodguys_tower3_mid", Vector(0,-4500,128), false, nil, nil, DOTA_TEAM_GOODGUYS)
  	CreateUnitByName("npc_dota_goodguys_tower2_mid", Vector(0,-3000,128), false, nil, nil, DOTA_TEAM_GOODGUYS)
  	CreateUnitByName("npc_dota_goodguys_tower1_mid", Vector(0,-1500,128), false, nil, nil, DOTA_TEAM_GOODGUYS)
  	_G.badguy_key_structure = CreateUnitByName("npc_dota_badguys_tower4", Vector(0,-_G.good_base_position,128), false, nil, nil, DOTA_TEAM_BADGUYS)
  	CreateUnitByName("npc_dota_goodguys_tower3_mid", Vector(0,4500,128), false, nil, nil, DOTA_TEAM_BADGUYS)
  	CreateUnitByName("npc_dota_goodguys_tower2_mid", Vector(0,3000,128), false, nil, nil, DOTA_TEAM_BADGUYS)
  	CreateUnitByName("npc_dota_goodguys_tower1_mid", Vector(0,1500,128), false, nil, nil, DOTA_TEAM_BADGUYS)

  	--init constant

end

function TetrisGameMode:OnPlayerPickHero(keys)
	print("hero pick")
	local hero = EntIndexToHScript(keys.heroindex)
	local player = EntIndexToHScript(keys.player)
	local playerID = hero:GetPlayerID()

	hero:SetGold(0, false) 
	-- hero:SetControllableByPlayer(-2,false)--nobody shall control a hero
	print("playerID" .. playerID)
	--test output
	print("GetTeam"..hero:GetTeam())
	print("GetTeamNumber"..hero:GetTeamNumber())
	local playerStats = {
					id=playerID,
					--team=0.-- get form hero:GetTeamNumber(),
					--totalmoney=0,-- get at the end of game GetTotalEarnedGold(int iPlayerID)
					--spentOnSkill=0,-- totalMoney - creeperMoney - GetGold(int playerID)
					spentOnCreeper=0-- get directly
					}
	_G.playerlist[playerID] = playerStats
	-- table.insert(_G.playerlist,)
	CustomGameEventManager:Send_ServerToPlayer(player, "tetris_start", {})
end

function TetrisGameMode:OnEntityKilled(event)
	local killedUnit = EntIndexToHScript(event.entindex_killed)
	print(killedUnit:GetUnitName())
end

function TetrisGameMode:OnLineRemoved(args)
	print("LUA_OnLineRemoved")
	-- local unit = CreateUnitByName("npc_dota_creep_badguys_melee_upgraded", Vector(0,-6500,128), false, nil, nil, 2)--DOTA_TEAM_GOODGUYS
	-- print("Before")
	-- unit:AddNewModifier(nil, nil, "modifier_phased", {duration=0.1})
	-- unit:MoveToPositionAggressive(Vector(0,-6000,128))
	-- print("After")
	--add exp&gold spawn Creeper
	local team = PlayerResource:GetTeam(args['PlayerID'])
	local hero_name = PlayerResource:GetSelectedHeroName(args['PlayerID'])
	local hero = PlayerResource:GetSelectedHeroEntity(args['PlayerID'])
	print("hero"..hero_name.."Label"..hero:GetUnitLabel()) 
	unit_name = ""	
	exp_gain = 0
	gold_gain = 0

	if args.count==1 then

		if hero:GetUnitLabel()=="Heeler" then
			unit_name = special_creeper_good.range
		elseif hero:GetUnitLabel() then
			unit_name = special_creeper_good.normal
		end

		exp_gain = 30
		gold_gain = 30
	elseif args.count==2 then

		if hero:GetUnitLabel()=="Heeler" then
			unit_name = special_creeper_good.range
		elseif hero:GetUnitLabel() then
			unit_name = special_creeper_good.normal
		end

		exp_gain = 70
		gold_gain = 70
	elseif args.count==3 then

		if hero:GetUnitLabel()=="Heeler" then
			unit_name = special_creeper_good.heeler
		elseif hero:GetUnitLabel()=="Defencer" then
			unit_name = special_creeper_good.defencer
		elseif hero:GetUnitLabel() then
			unit_name = special_creeper_good.attacker
		end

		exp_gain = 110
		gold_gain = 110
	elseif args.count==4 then
		
		if hero:GetUnitLabel()=="Heeler" then
			unit_name = special_creeper_good.heeler
		elseif hero:GetUnitLabel()=="Defencer" then
			unit_name = special_creeper_good.defencer
		elseif hero:GetUnitLabel() then
			unit_name = special_creeper_good.attacker
		end

		exp_gain = 180
		gold_gain = 180
	end
	

	hero:AddExperience(exp_gain,DOTA_ModifyGold_CreepKill,false,false)
	hero:ModifyGold(gold_gain,false,DOTA_ModifyGold_CreepKill)
    -- npc_dota_neutral_forest_troll_high_priest
    -- local unit = CreateUnitByName("npc_dota_creep_goodguys_melee_upgraded", Vector(0,-6000,128), false, nil, nil, DOTA_TEAM_GOODGUYS)
    
    print(unit_name)
    self:spawnUnit(unit_name,team)
    

    --for test if gold useful
    print("getGold"..PlayerResource:GetGold(args['PlayerID']))
    print("GetTotalGoldSpent"..PlayerResource:GetTotalGoldSpent(args['PlayerID']))
    print("GetTotalEarnedGold"..PlayerResource:GetTotalEarnedGold(args['PlayerID'])
end

function TetrisGameMode:TrainArmy(args)
	local team = PlayerResource:GetTeam(args['PlayerID'])
	self:spawnUnit(args.target,team)
end

function TetrisGameMode:spawnUnit(name,team)

	spawn_position = 0

	if team == DOTA_TEAM_GOODGUYS then
		spawn_position = _G.good_base_position;
	else
		--bad guys
		spawn_position = -_G.good_base_position;
	end
	
    local unit = CreateUnitByName(name, Vector(0,spawn_position,128), false, nil, nil, team)

    for i=0,2 do
		local ability = unit:GetAbilityByIndex(i)
		if ability then ability:SetLevel(ability:GetMaxLevel()) end
	end

    unit:AddNewModifier(nil, nil, "modifier_phased", {duration=0.1})

end

function TetrisGameMode:OnTetrisFailed(args)
	local team = PlayerResource:GetTeam(args['PlayerID'])
	self:spawnUnit("",team)
	-- local hero = PlayerResource:GetSelectedHeroEntity(args['PlayerID'])
	-- hero:ModifyGold(-1000,false,0)

	Notifications:TopToAll({text = "player:"..args['PlayerID'].."reach the top",duration = 5})
end

-- Evaluate the state of the game
function TetrisGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		if not _G.goodguy_key_structure:IsAlive() then
			print("good lose")
			GameRules:SetGameWinner(3)
		elseif not _G.badguy_key_structure:IsAlive() then
			print("bad lose")
			GameRules:SetGameWinner(2)
		end
		for _,player in pairs(_G.playerlist) do
			CustomGameEventManager:Send_ServerToAllClients(player, "tetris_start", {})
		end
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		print("DOTA_GAMERULES_STATE_POST_GAME")
		CustomUI:DynamicHud_Create(-1,"END_STATS","file://{resources}/layout/custom_game/end_stats.xml",nil)
		return nil
	end
	return 1
end