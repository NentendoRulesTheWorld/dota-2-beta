
require( "ai_core" )
require('tetris_mode')

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
	behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorRun } )
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
