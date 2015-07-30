fire_out_lua = class ({})

require(DebugTools)

local startTime = nil	--spell begin time, minus end time to calculate fire range

--link
--LinkLuaModifier( "modifier_lina_laguna_blade_lua", LUA_MODIFIER_MOTION_NONE )


-- events
function fire_out_lua:OnAbilityPhaseStart()
	Log:D("OnAbilityPhaseStart")
	local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_sven/sven_spell_storm_bolt_lightning.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_sword", self:GetCaster():GetOrigin(), true )

	local vLightningOffset = self:GetCaster():GetOrigin() + Vector( 0, 0, 1600 )
	ParticleManager:SetParticleControl( nFXIndex, 1, vLightningOffset )

	ParticleManager:ReleaseParticleIndex( nFXIndex )

	return true
end

function fire_out_lua:OnSpellStart()
	Log:D("OnSpellStart")
	startTime = GameRules:GetGameTime();
	Log:D(startTime)
end

function fire_out_lua:OnAbilityPhaseInterrupted()
	Log:D("OnAbilityPhaseInterrupted")
end

function fire_out_lua:OnProjectileThink( vLocation )
	Log:D("OnProjectileThink")
end

function fire_out_lua:OnProjectileHit( hTarget, vLocation )
	Log:D("OnProjectileHit")
	Log:D(vLocation)

	local aoe_radius = self:GetSpecialValueFor( "aoe_radius" )
	local aoe_damage = self:GetSpecialValueFor( "aoe_damage" )

	if vLocation ~= nil then
		EmitSoundOn( vLocation,"Hero_Sven.StormBoltImpact",self:GetCaster() )

		local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), hTarget:GetOrigin(), nil, aoe_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then

					local damage = {
						victim = enemy,
						attacker = self:GetCaster(),
						damage = aoe_damage,
						damage_type = DAMAGE_TYPE_PHYSICAL,
					}

					ApplyDamage( damage )
					enemy:AddNewModifier( self:GetCaster(), self, "modifier_sven_storm_bolt_lua", { duration = bolt_stun_duration } )
				end
			end
		end
	end
	return true
end

function fire_out_lua:etIntrinsicModifierName()
	Log:D("etIntrinsicModifierName")
end

function fire_out_lua:OnChannelFinish( bInterrupted )
	Log:D("OnChannelFinish")
	if startTime ~= nil then
		local intervalTime = GameRules:GetGameTime() - startTime
		startTime = nil
		Log:D(intervalTime)
		--DOPO intervalTime calculattion need to rewrite
	end

	local vision_radius = self:GetSpecialValueFor( "vision_radius" )
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
	local distance_ratio = self:GetSpecialValueFor( "distance_ratio" )

	-- local info = {
	-- 		EffectName = "particles/units/heroes/hero_techies/techies_base_attack.vpcf",
	-- 		Ability = self,
	-- 		iMoveSpeed = projectile_speed,
	-- 		Source = self:GetCaster(),
	-- 		Target = self:GetCursorTarget(),
	-- 		bDodgeable = true,
	-- 		bProvidesVision = true,
	-- 		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
	-- 		iVisionRadius = vision_radius,
	-- 		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, 
	-- 	}

	local info = {
		EffectName = "particles/units/heroes/hero_techies/techies_base_attack.vpcf",
		Ability = self,
		iMoveSpeed = projectile_speed,
		Source = self:GetCaster(),
		bDodgeable = true,
		bProvidesVision = true,
		vSpawnOrigin = self:GetCaster():GetOrigin(), 
		fDistance = distance_ratio*intervalTime
	}

	ProjectileManager:CreateTrackingProjectile( info )
	EmitSoundOn( "Hero_Sven.StormBolt", self:GetCaster() )

end

function fire_out_lua:OnUpgrade()
	Log:D("OnUpgrade")
end
--------------------------------------------------------------------------------

-- Casting Behavior
-- * GetBehavior() -- Determines the type of targeting behavior used with the cursor, return expects value from DOTA_ABILITY_BEHAVIOR enum ( i.e. DOTA_ABILITY_BEHAVIOR_UNIT_TARGET, DOTA_ABILITY_BEHAVIOR_POINT )
-- * GetCooldown( nLevel ) -- Determines the cooldown started when the spell is cast. Return float value.
-- * GetCastRange( vLocation, hTarget ) -- Determines the cast range. Return integer value.
-- * GetChannelTime() -- Determines the channel time. Return float value.

--------------------------------------------------------------------------------

-- CastFilter
-- CastFilterResultTarget( hTarget ) -- hTarget is the targeted NPC.
-- GetCustomCastErrorTarget( hTarget) -- hTarget is the targeted NPC. 
-- CastFilterResultLocation( vLocation ) -- vLocation is the targeted location.
-- GetCustomCastErrorLocation( vLocation ) -- vLocation is the targeted location.
-- CastFilterResult() -- No target abilities
-- GetCustomCastError() -- No target abilities

--------------------------------------------------------------------------------


--Particle 粒子
--Projectile 投射物体