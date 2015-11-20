
require( "ai_core" )
require('tetris_mode')

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
	behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorHeal, BehaviorRun } )
end

function AIThink()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil -- deactivate this think function
	end
	return behaviorSystem:Think()
end

--------------------------------------------------------------------------------------------------------

--base behavior move&attack
function getTargetPosition()
	if thisEntity:GetTeam() == DOTA_TEAM_GOODGUYS then
		return -_G.targetPosition_good;
	else
		--bad guys
		return _G.targetPosition_bad;
	end
end

BehaviorRun =
{
	order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
		Position = getTargetPosition(),
	}
}

function BehaviorRun:Evaluate()
	return 1 -- must return a value > 0, so we have a default
end

function BehaviorRun:Initialize()
end

function BehaviorRun:Begin()
	self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorRun:Continue()
	self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorRun:Think(dt)
	--usually use this function to change order's args
	local currentPos = thisEntity:GetOrigin()
	currentPos.z = 0

	if ( self.order.Position - currentPos ):Length() < 500 then
		
	end
end

--------------------------------------------------------------------------------------------------------

--ability behavior,only for unit who have positive ability
BehaviorHeal = {}

function BehaviorHeal:Evaluate()
	self.ability = thisEntity:FindAbilityByName("forest_troll_high_priest_heal")
	local target
	local desire = 0

	if self.ability and self.ability:IsFullyCastable() then
		local allfriend = FindUnitsInRadius( thisEntity:GetTeam() , thisEntity:GetOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false )
		for _,friend in pairs(allfriend) do
			if friend:GetHealthDeficit() > 100 then 
				target = friend
				break 
			end
		end
	end

	if target then
		desire = 5
		self.order =
		{
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			UnitIndex = thisEntity:entindex(),
			TargetIndex = target:entindex(),
			AbilityIndex = self.ability:entindex()
		}
	end

	return desire
end

function BehaviorHeal:Begin()
	self.endTime = GameRules:GetGameTime() + 1
end

BehaviorHeal.Continue = BehaviorHeal.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

function BehaviorHeal:Think(dt)
	if not self.ability:IsFullyCastable() and not self.ability:IsInAbilityPhase() then
		self.endTime = GameRules:GetGameTime()
	end
end
