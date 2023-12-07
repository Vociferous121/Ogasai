script_druid = {
	message = 'Druid',
	menuIncluded = include("scripts\\combat\\script_druidEX.lua"),
	eatHealth = 35,
	drinkMana = 50,
	rejuvenationHealth = 80,	-- use rejuvenation below this health
	regrowthHealth = 70,
	healingTouchHealth = 45,
	healthToShift = 55,	-- health to shapeshift
	potionHealth = 18,
	potionMana = 20,
	isSetup = false,
	meleeDistance = 3.9,
	waitTimer = 0,
	stopIfMHBroken = true,
	useCat = false,		-- is cat form selected
	useBear = false,	-- is bear form selected
	isChecked = true,
	useEntanglingRoots = true,
	waitTimer = GetTimeEX(),
	useStealth = true,
	stealthOpener = "Ravage",
	shiftToDrink = true,	-- shapeshift out of form to drink
	useCharge = true,
	useRest = true,		-- rest in shapeshift form
	maulRage = 15,
	wasInCombat = false,	-- was in combat used to adjust tick rate
	runOnce = false,
	shapeshiftMana = 33,	-- cost of shapeshift mana
	hasDrinks = true,
}


-- switch to bear form when in cat form
-- adds >= 2 and when 1 dies switch back to cat form
-- add conditional to main phases ' don't do this when x is true '
-- if targets in combat = 2 then x = true else y
-- mana > 50 % else stay in bear form
-- switch when health is low and already out of form to heal then choose bear form over cat form
-- stun target if we switch back to cat form - or return maul and waste all rage
-- TELL CAT FORM TO ONLY BE USED WHEN <= 2 ADDS PROBABLY EASIEST SOLUTION


function script_druid:setup()

	local localObj = GetLocalPlayer();
	local localLevel = localObj:GetLevel();
	local isBear = localObj:HasBuff("Bear Form");
	local isCat = localObj:HasBuff("Cat Form");
	local isMoonkin = localObj:HasBuff("Moonkin Form");
	local isTravel = localObj:HasBuff("Travel Form");
	local isBear2 = localObj:HasBuff("Dire Bear Form");
	if (localLevel >= 30) then
		self.drinkMana = 35;
	end
	-- set entangle roots on startup
	if (not HasSpell("Entangling Roots")) then
		self.useEntanglingRoots = false;
	end

	if (HasSpell("Bear Form")) and (not HasSpell("Cat Form")) then
		self.meleeDistance = 4.80;
	end

	if (not HasSpell("Ravage")) then
		self.stealthOpener = "Shred";
	end
	--if (HasSpell("Pounce")) then
	--	self.stealthOpener = "Pounce";
	--end
	if (not HasSpell("Shred")) then
		self.stealthOpener = "Claw";
	end

	if (not HasSpell("Prowl")) then
		useStealth = false;
	end
	
	if (not HasSpell("Bear Form")) then
		shiftToDrink = false;
		useCharge = false;
		useRest = false;
	end

	if (HasSpell("Feral Charge")) or (localObj:GetLevel() >= 15) then
		self.maulRage = 10;
	end

	if (localObj:GetLevel() >= 20) then
		self.shapeshiftMana = 25;
	end
	
	if (localObj:GetLevel() >= 30) then
		self.shapeshiftMana = 22;
	end

	if (localObj:GetLevel() >= 35) then
		self.shapeshiftMana = 20;
	end

	if (localObj:GetLevel() >= 10) and (not HasSpell("Cat Form")) then
		self.useBear = true;
	end
	if (localObj:GetLevel() >= 20) and (HasSpell("Cat Form")) then
		self.useBear = false;
		self.useCat = true;
	end

	if (not HasSpell("Regrowth")) and (HasSpell("Bear Form")) then
		self.healingTouchHealth = 60;
	end

	self.waitTimer = GetTimeEX();	

	self.isSetup = true;
end

function script_druid:enemiesAttackingUs(range) -- returns number of enemies attacking us within range
    local unitsAttackingUs = 0; 
    local currentObj, typeObj = GetFirstObject(); 
    while currentObj ~= 0 do 
    	if typeObj == 3 then
			if (currentObj:CanAttack() and not currentObj:IsDead()) then
				if (script_grind:isTargetingMe(currentObj) and currentObj:GetDistance() <= range) then 
					unitsAttackingUs = unitsAttackingUs + 1; 
				end 
			end 
       	end
        currentObj, typeObj = GetNextObject(currentObj); 
    end
    return unitsAttackingUs;
end

-- Run backwards if the target is within range
function script_druid:runBackwards(targetObj, range) 
	local localObj = GetLocalPlayer();
 	if targetObj ~= 0 and (not script_checkDebuffs:hasDisabledMovement()) then
 		local xT, yT, zT = targetObj:GetPosition();
 		local xP, yP, zP = localObj:GetPosition();
 		local distance = targetObj:GetDistance();
 		local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
 		local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 		local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;	
 		local moveX, moveY, moveZ = xT + xUV*16, yT + yUV*16, zT + zUV;		
 		if (distance < range and targetObj:IsInLineOfSight()) then 
			script_navEX:moveToTarget(localObj, moveX, moveY, moveZ);
			if (IsMoving()) then
				JumpOrAscendStart();
			end
 			return true;
 		end
	end
	return false;
end

function script_druid:draw()
	local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
	if (onScreen) then
		if (script_grind.adjustText) and (script_grind.drawEnabled) then
			tX = tX + script_grind.adjustX;
			tY = tY + script_grind.adjustY;
		end

	DrawText(self.message, tX+75, tY+44, 255, 250, 205);
	else
		if (script_grind.adjustText) and (script_grind.drawEnabled) then
			tX = tX + script_grind.adjustX;
			tY = tY + script_grind.adjustY;
		end

	DrawText(self.message, 25, 185, 255, 250, 205);
	end
end

--[[ error codes: 	0 - All Good , 
			1 - missing arg , 
			2 - invalid target , 
			3 - not in range, 
			4 - do nothing , 
			5 - targeted player pet/totem
			6 - stop bot request from combat script 
]]--

function script_druid:healsAndBuffs()

	local localObj = GetLocalPlayer();
	local localHealth = localObj:GetHealthPercentage();
	local localMana = localObj:GetManaPercentage();
	local localRage = localObj:GetRagePercentage();
	local localLevel = localObj:GetLevel();
	local isBear = localObj:HasBuff("Bear Form");
	local isCat = localObj:HasBuff("Cat Form");
	local isTravel = localObj:HasBuff("Travel Form");
	local isBear2 = localObj:HasBuff("Dire Bear Form");
	local hasRejuv = localObj:HasBuff("Rejuvenation"); 
	local hasRegrowth = localObj:HasBuff("Regrowth");

	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(750, 1150);

		if (IsMoving()) or (not IsInCombat()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		elseif (IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		end
	end

		-- Dismount
		if (IsMounted()) then 
			DisMount(); 
			return 4; 
		end
--------------

	-- shapeshift out of bear form to heal
	if ( (isBear or isBear2) and (localHealth <= self.healthToShift) and (localMana >= self.shapeshiftMana) and (not hasRejuv) and (not hasRegrowth) and (script_grind.enemiesAttackingUs(12) == 1 ) )
	or ( (isBear or isBear2) and (localHealth <= self.healthToShift) and (localMana >= self.shapeshiftMana) and (not hasRejuv) and (not hasRegrowth) and (script_grind.enemiesAttackingUs(12) >= 2) )
	or ( (isBear or isBear2) and (localHealth <= 65) and (not IsInCombat()) and (localMana >= 75) and (not hasRejuv) and (not hasRegrowth) )
	then
		if (not script_grind.adjustTickRate) then
			script_grind.tickRate = 135;
		end
		if (script_druidEX:bearForm()) then
			self.waitTimer = GetTimeEX() + 1500;
		end
		
	end

	local localCP = GetComboPoints("player", "target");
	local localEnergy = localObj:GetEnergyPercentage();


	-- shapeshift out of cat form to heal
	if ( (isCat) and (localHealth <= self.healthToShift) and (localMana >= self.shapeshiftMana) and (not hasRejuv) and (not hasRegrowth) )
	or ( (isCat) and (localHealth <= 65) and (not IsInCombat()) and (localMana >= 75) and (not hasRejuv) and (not hasRegrowth) )
	then

		if (not script_grind.adjustTickRate) then
			script_grind.tickRate = 335;
		end
		if (localObj:HasBuff("Cat Form")) then
			CastSpellByName("Cat Form");
			self.waitTimer = GetTimeEX() + 700;
		end
	end


	-- heal - we left form out of combat
	if (not IsInCombat()) and (not isBear and not isBear2) and (not isCat) and (not isTravel) and (localHealth <= 65) and (localMana >= 75) and (not hasRejuv) and (not hasRegrowth) and (not IsMoving()) and (IsStanding()) and (not IsMounted()) then
			if (IsMoving()) then
				StopMoving();
			end
		if (CastSpellByName("Rejuvenation", localObj)) then
			self.waitTimer = GetTimeEX() + 1650;
			return 0;
		end
	end

------------------------------------

	-- shapeshift if has rejuv and regrowth and mana is high enough and health is low enough
	if (self.useBear and (isBear or isBear2)) and (localHealth <= self.healthToShift - 35) and (localMana >= 65) and (hasRejuv) and (hasRegrowth) then
		if (not script_grind.adjustTickRate) then
			script_grind.tickRate = 335;
		end
		if (script_druidEX.bearForm()) then
			self.waitTimer = GetTimeEX() + 1500;
		end
	end

	-- shapeshift out of cat form to heal - already have rejuve and regrowth
	if (self.useCat and isCat) and (localHealth <= self.healthToShift - 25) and (localMana >= 65) and (hasRejuv) and (hasRegrowth) then
		if (not script_grind.adjustTickRate) then	
			script_grind.tickRate = 335;
		end
		if (localObj:HasBuff("Cat Form")) then
			CastSpellByName("Cat Form");
			self.waitTimer = GetTimeEX() + 500;
		end
	end


------------------------

	local isBear = localObj:HasBuff("Bear Form");
	local isBear2 = localObj:HasBuff("Dire Bear Form");
	local isCat = localObj:HasBuff("Cat Form");
	local isTravel = localObj:HasBuff("Travel Form");

	-- moving buffs hierarchy up
	if (not isBear and not isBear2) and (not isCat) and (not isTravel) and (IsStanding()) and (not IsEating()) and (not IsDrinking()) and (not IsLooting()) and (script_grind.lootObj == 0 or script_grind.lootObj == nil) and (not IsMounted()) then

		-- Innervate
		if (IsInCombat()) and (HasSpell("Innervate")) and (not IsSpellOnCD("Innervate")) and (not localObj:HasBuff("Innervate")) and (localMana <= self.shapeshiftMana) then
			if (CastSpellByName("Innervate", localObj)) then
				self.waitTimer = GetTimeEX() + 3500;
				return 0;
			end
		end

		-- Mark of the Wild
		if (not IsInCombat()) and (localMana > 75) and (HasSpell("Mark of the Wild")) and (not IsMounted()) then
			if (not localObj:HasBuff("Mark of the Wild")) then
				if (CastSpellByName("Mark of the Wild", localObj)) then
					self.waitTimer = GetTimeEX() + 2500;
					return 0;
				end
			end
		end
	
		-- Thorns
		if (localMana > 30) and (HasSpell("Thorns")) and (not localObj:HasBuff("Thorns")) and (not IsMounted()) then
			if (localHealth >= self.healthToShift) and (not IsMounted()) then
				if (CastSpellByName("Thorns", localObj)) then
					self.waitTimer = GetTimeEX() + 2550;
					return 0;
				end
			end
		end
	end

	-- if not isBear and not isCat and not isTravel
	if (not isBear and not isBear2) and (not isCat) and (not isTravel) and (IsStanding()) and (not IsEating()) and (not IsDrinking()) and (not IsLooting()) and (script_grind.lootObj == 0 or script_grind.lootObj == nil) and (not localObj:IsStunned()) and (not IsMounted()) then

		-- Check: Use Healing Potion 
		if (localHealth < self.potionHealth) then 
			if (script_helper:useHealthPotion()) then 
				return 0; 
			end 
		end

		-- Check: Use Mana Potion 
		if (localMana < self.potionMana) then 
			if (script_helper:useManaPotion()) then 
				return 0; 
			end 
		end

		-- Regrowth
		if (HasSpell("Regrowth")) and (not localObj:HasBuff("Regrowth")) then
			if (localHealth <= self.regrowthHealth) and (localMana >= 40) and (not localObj:HasBuff("Regrowth")) then
				if (not IsMoving()) and (not IsLooting()) and (not localObj:HasBuff("Regrowth")) then
					if (not IsChanneling()) and (not IsCasting()) and (not localObj:HasBuff("Regrowth")) then
						if (IsMoving()) and (not localObj:HasBuff("Regrowth")) then
							StopMoving();
						end
						if (not script_grind.adjustTickRate) then
							script_grind.tickRate = 2850;
						end
						if (not localObj:HasBuff("Regrowth")) then
							if (CastSpellByName("Regrowth", localObj)) then
								self.waitTimer = GetTimeEX() + 4250;
								return 4;
							end
						end
					end
				end
			end
		end

		-- Rejuvenation
		if (HasSpell("Rejuvenation")) and (not localObj:HasBuff("Rejuvenation")) and (localHealth <= self.rejuvenationHealth) and (not IsLooting()) and (IsStanding()) and (localHealth <= 80) then
			if (localLevel < 10 and localMana >= 25) or (localLevel >= 10 and localMana >= self.shapeshiftMana + 5) then 
				if (IsMoving()) then
					StopMoving();
				end
				if (CastSpellByName("Rejuvenation", localObj)) then
					self.waitTimer = GetTimeEX() + 1600;
					return 0;
				end
			end
		end

		-- Healing Touch
		if (HasSpell("Healing Touch")) and (not IsLooting()) and (not IsMoving()) and (IsStanding()) then
			if (localHealth < self.healingTouchHealth) and (localMana > 25) then
				if (CastHeal("Healing Touch", localObj)) then
					self.waitTimer = GetTimeEX() + 2700;
					return 0;
				end
			end
		end

		-- cast rejuvenation if we have regrowth
		if (localObj:HasBuff("Regrowth")) and (not localObj:HasBuff("Rejuvenation")) and (localMana >= 15) and (not IsMoving()) and (IsStanding()) and (localHealth <= 80) then
				if (IsMoving()) then
					StopMoving();
				end
			if (CastSpellByName("Rejuvenation", targetObj)) then
				self.waitTimer = GetTimeEX() + 1750;
				return 0;
			end
		end

		-- cure poison
		if (not HasSpell("Abolish Poison")) and (HasSpell("Cure Poison")) and (script_checkDebuffs:hasPoison()) and (localMana >= 45) and (not IsMoving()) and (IsStanding()) then
			if (CastSpellByName("Cure Poison", localObj)) then 
				self.waitTimer = GetTimeEX() + 1750; 
				return 0; 
			end
		elseif (HasSpell("Abolish Poison")) and (not localObj:HasBuff("Abolish Poison")) and (script_checkDebuffs:hasPoison()) and (localMana >= 45) and (not IsMoving()) and (IsStanding()) then
			if (CastSpellByName("Abolish Poison", targetObj)) then
				self.waitTimer = GetTimeEX() + 1750;
				return 0;
			end
		end

		-- remove curse
		if (HasSpell("Remove Curse")) and (script_checkDebuffs:hasCurse()) and (not IsMoving()) and (IsStanding()) then
			if (localMana >= 30) then
				if (CastSpellByName("Remove Curse", localObj)) then
					self.waitTimer = GetTimeEX() + 1750;
					return 0;
				end
			end
		end
	end

--------------------------




	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(750, 1150);

		if (IsMoving()) or (not IsInCombat()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		elseif (IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		end
	end
			
return false;
end

function script_druid:run(targetGUID)
	
	if(not self.isSetup) then
		script_druid:setup();
	end
	
	local localObj = GetLocalPlayer();
	local localHealth = localObj:GetHealthPercentage();
	local localMana = localObj:GetManaPercentage();
	local localLevel = localObj:GetLevel();
	local localRage = localObj:GetRagePercentage();
	local localEnergy = localObj:GetEnergyPercentage();
	local localCP = GetComboPoints("player", "target");
	local isTravel = localObj:HasBuff("Travel Form");
	local isBear = localObj:HasBuff("Bear Form");
	local isCat = localObj:HasBuff("Cat Form");
	local isBear2 = localObj:HasBuff("Dire Bear Form");
	local isMoonkin = localObj:HasBuff("Moonkin Form");

	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(750, 1150);

		if (IsMoving()) or (not IsInCombat()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom
		elseif (IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		end
	end

	-- don't attack dead objects
	if (localObj:IsDead()) then
		return 0; 
	end

	-- check heals and buffs
	--if (script_druid:healsAndBuffs())  and (not localObj:HasBuff("Frenzied Regeneration")) then
	--	self.waitTimer = GetTimeEX() + 2550;
	--	return;
	--end

	-- Assign the target 
	targetObj = GetGUIDObject(targetGUID);
	
	-- check for a valid target
	if(targetObj == 0 or targetObj == nil) then
		return 2;
	end

	-- Check: if we target player pets/totems
	if (GetTarget() ~= nil and targetObj ~= nil) then
		if (UnitPlayerControlled("target") and GetTarget() ~= localObj) then 
			script_grind:addTargetToBlacklist(targetObj:GetGUID());
			return 5; 
		end
	end 

	-- Check: Do nothing if we are channeling or casting or wait timer
	if (IsChanneling() or IsCasting() or (self.waitTimer > GetTimeEX())) then
		return 4;
	end
	
	-- remove travel form before combat
	if (isTravel) then
		if (CastSpellByName("Travel Form")) then
			self.waitTimer = GetTimeEX() + 1500;
			return 0;
		end
	end

	--Valid Enemy
	if (targetObj ~= 0) and (not localObj:IsStunned()) then
		
		-- Cant Attack dead targets
		if (targetObj:IsDead() or not targetObj:CanAttack()) then
			return 0;
		end

		-- stand up if sitting
		if (not IsStanding()) then
			JumpOrAscendStart();
		end

-- stay in form bear if bear form is selected
		if (self.useBear) or ( script_grind.enemiesAttackingUs(12) >= 2 and (HasSpell("Bear Form") or HasSpell("Dire Bear Form")) and (not IsDrinking()) and (not IsEating()) )

		or ( (targetObj:GetLevel() >= (localObj:GetLevel() + 2)) and (IsInCombat()) and (HasSpell("Bear Form") or HasSpell("Dire Bear Form")) and (not IsDrinking()) and (not IsEating()) and (targetObj:GetHealthPercentage() >= 45) and (IsInCombat()) ) then

			if (not isBear and not isBear2) and (not isCat) and (localMana > self.shapeshiftMana) and (localHealth >= self.healthToShift) and (IsStanding()) then
				if (not script_grind.adjustTickRate) then
					script_grind.tickRate = 335;
				end
				if (script_druidEX.bearForm()) then
					self.waitTimer = GetTimeEX() + 1500;
				end
			end
		end
	
	-- stay in form cat if cat form is selected -- cast cat form
	if (script_grind.enemiesAttackingUs(10) < 2) and (HasSpell("Cat Form")) and (self.useCat) and (not isCat) and (not self.useBear) and (not isBear and not isBear2) and (localMana >= self.shapeshiftMana) and (localHealth >= self.healthToShift) and (IsStanding()) and (not IsDrinking()) and (not IsEating()) and (targetObj:GetLevel() <= localObj:GetLevel() + 2) then
		if (not script_grind.adjustTickRate) then
			script_grind.tickRate = 335;
		end
		if (CastSpellByName("Cat Form")) then
			self.waitTimer = GetTimeEX() + 1200;
			return 0;
		end
		return 0;
	end

		-- use prowl before spamming auto attack and move in range of target!
		if (not IsInCombat()) and (self.useCat) and (isCat) and (self.useStealth) and (HasSpell("Prowl")) and (not IsSpellOnCD("Prowl")) and (not localObj:HasBuff("Prowl")) and (script_grind.lootObj == nil or script_grind.lootObj == 0) and (not script_checkDebuffs:hasPoison()) and (IsStanding()) and (IsMoving()) then
			CastSpellByName("Prowl");
			JumpOrAscendStart();
			return 0;
		end
	
		-- face target
		if (not IsMoving() and targetObj:GetDistance() <= self.meleeDistance) then
				targetObj:FaceTarget();
		end

		-- assign target health
		targetHealth = targetObj:GetHealthPercentage();


	-- shapeshift out of cat form to use bear form 2 or more targets - leave form
		if (self.useCat) and (isCat) and (localMana >= self.shapeshiftMana) and (localHealth <= self.healthToShift) and (GetNumPartyMembers() < 2) then
			if (script_grind:enemiesAttackingUs(12) >= 2) or (targetObj:GetLevel() >= localObj:GetLevel() + 2 and (IsInCombat())) then
		
				if (not script_grind.adjustTickRate) then
					script_grind.tickRate = 125;
				end
				if (localObj:HasBuff("Cat Form")) then
					if (CastSpellByName("Cat Form")) then
						DEFAULT_CHAT_FRAME:AddMessage(" --- Shifted - attacked by adds");
						self.wasInCombat = true;
						self.runOnce = true;
						self.waitTimer = GetTimeEX() + 500;
					end
				end
			end
		end

		-- stay in cat form - placed here to allow faster movement and stealth to target
		-- not in cat form and conditions right then stay in cat form
		if (script_grind.enemiesAttackingUs(12) < 2) and (not isCat) and (self.useCat) and (not self.useBear) and (not isBear and not isBear2) and (localHealth >= self.healthToShift) and (localMana >= self.shapeshiftMana) and (targetObj:GetLevel() <= localObj:GetLevel() +2) and (not IsDrinking()) and (not IsEating()) then
			if (HasSpell("Cat Form")) then
				CastSpellByName("Cat Form");
				return 0;
			end
		end

		-- War Stomp Tauren Racial
		if (not isBear and not isBear2) and (not isCat) and (IsInCombat()) then
			if (targetObj:IsCasting() or script_druid:enemiesAttackingUs(6) >= 2) and (GetNumPartyMembers() < 2) and (not targetObj:HasDebuff("Entangling Roots")) and (targetObj:GetDistance() <= 8) then
				if (HasSpell("War Stomp")) and (not IsSpellOnCD("War Stomp")) and (not IsMoving()) then
					CastSpellByName("War Stomp", localObj);
					self.waitTimer = GetTimeEX() + 200;
					return 0;
				end
			end
		end

		-- check heals and buffs
		if (script_druid:healsAndBuffs()) and (not localObj:HasBuff("Frenzied Regeneration")) and (not IsLooting()) then
			self.waitTimer = GetTimeEX() + 2550;
			return;
		end

		-- stop bot from moving target to target when stuck in combat and we need to rest
		--if (IsInCombat()) and (localObj:GetUnitsTarget() == 0) then
		--	self.message = "Waiting! Stuck in combat phase!";
		--	return 4;
		--end
		
		----------
		----- OPENER 
		---------

		-- Opener
		if (not IsInCombat()) and (not isTravel) then
			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";

			local __, lastError = GetLastError();
			if (lastError ~= 51) then
					local tX, tY, tZ = targetObj:GetPosition();
				if (isCat) and (self.useCat) and (self.useStealth) and (localObj:HasBuff("Prowl")) then
					if (HasSpell(self.stealthOpener)) and (not IsSpellOnCD(self.stealthOpener)) and (localEnergy >= 50) and (targetObj:GetDistance() <= 6) then
						if (CastSpellByName(self.stealthOpener)) then
							if (not IsMoving()) then
								targetObj:FaceTarget();
							end
							self.waitTimer = GetTimeEX() + 300;
							return 0;
						end
						targetObj:AutoAttack();
						if (not IsMoving()) then
							targetObj:FaceTarget();
						end
					end
				end
			end
							
			-- Auto Attack
			if (targetObj:GetDistance() < 35) and (not IsAutoCasting("Attack")) and (localMana >= self.drinkMana) then
				targetObj:AutoAttack();
			end

			-- keep faerie fire up
			if not self.useStealth and targetObj:GetDistance() <= 30 then
				if HasSpell("Faerie Fire (Feral)") then
					CastSpellByName("Faerie Fire (Feral)()");
					targetObj:FaceTarget();
					return 0;
				end
			end

			-- use dash if stealthed
			if (HasSpell("Dash")) and (isCat) and (not IsSpellOnCD("Dash")) and (targetObj:GetDistance() >= 20) and (localObj:HasBuff("Prowl")) then
				if (CastSpellByName("Dash", localObj)) then
					self.waitTimer = GetTimeEX() + 300;
					return 0;
				end
			end

			-- enrage if has charge
			if (isBear or isBear2) and (HasSpell("Feral Charge")) and (HasSpell("Enrage")) and (not IsSpellOnCD("Enrage")) and (not IsSpellOnCD("Feral Charge")) and (targetObj:GetDistance() <= 45) then
				if (CastSpellByName("Enrage", localObj)) then
					return 0;
				elseif (localObj:HasBuff("Bear Form")) then
					return 3;
				end
			end

			-- use charge in bear form
			if (isBear or isBear2) and (self.useCharge) and (HasSpell("Feral Charge")) and (not IsSpellOnCD("Feral Charge")) and (localRage >= 5) then
				if (self.useBear) and (isBear or isBear2) and (targetObj:GetDistance() < 26) and (targetObj:GetDistance() > 10) then
						targetObj:FaceTarget();
					if (CastSpellByName("Feral Charge")) then
						targetObj:FaceTarget();
						return 0;
					end
				end
			end

			-- check melee distance
			if (isBear or isBear2 or isCat) and (targetObj:GetDistance() > self.meleeDistance) then
				return 3;
			end

			-- move to enemy target
			if (not self.useBear) and (not self.useCat) and (not isBear and not isBear2) and (not isCat) and (targetObj:GetDistance() > 27) and (localMana >= self.drinkMana) then
				return 3;
			end

			-- Dismount
			if (IsMounted()) and (targetObj:GetDistance() < 25) then 
				DisMount(); 
				return 4; 
			end

			-- stop moving if we get close enough to target and not in combat yet
			if (not IsInCombat()) and (targetObj:GetDistance() <= self.meleeDistance) then
				if (IsMoving()) then
					StopMoving();
				end
					if (not IsMoving()) then
						targetObj:FaceTarget();
					end
				self.waitTimer = GetTimeEX() + 800;
			end

			----
	-- pull in form
			----




	-- pull bear form
			------

			-- stay in form
			-- not in bear form and conditions right then stay in bear form
		if ( (not isBear and not isBear2) and (self.useBear) and (not isCat) and (localHealth > self.healthToShift + 5) and (localMana > self.shapeshiftMana) and (not IsDrinking()) and (not IsEating()) )
		or ( (script_grind.enemiesAttackingUs(12) >= 2) and (not isBear and not isBear2) and (not isCat) and (localMana > self.shapeshiftMana) and (localHealth > self.healthToShift + 5) and (IsStanding()) and (HasSpell("Bear Form") or HasSpell("Dire Bear Form")) ) 
		or ( (targetObj:GetLevel() >= (localObj:GetLevel() + 2) and IsInCombat() ) and (not isBear and not isBear2) and (not isCat) and (localMana > self.shapeshiftMana) and (localHealth > self.healthToShift + 5) and (IsStanding()) and (HasSpell("Bear Form") or HasSpell("Dire Bear Form")) )
		then
			if (script_druidEX.bearForm()) then
				self.waitTimer = GetTimeEX() + 1500;
			end
		end
		
		-- if in bear form do these pulls
		if (isBear or isBear2) and (not isCat) then

			-- Enrage
			if (HasSpell("Enrage")) and (not IsSpellOnCD("Enrage")) and (targetObj:GetDistance() < 45) and (localHealth > self.healthToShift + 25) then
				if (CastSpellByName("Enrage")) then
					return 0;
				end
			end

			-- Demoralizing Roar
			if (HasSpell("Demoralizing Roar")) and (not targetObj:HasBuff("Demoralizing Roar")) and (localRage > 10) and (not targetObj:HasDebuff("Demoralizing Shout")) then
				if (CastSpellByName("Demoralizing Roar")) then
					return 0;
				end
			end
		end


	-- end of bear form pulling




	-- pull cat form
			------

		-- stay in form
		-- not in cat form and conditions right then stay in cat form
		if (script_grind.enemiesAttackingUs(12) < 2) and (not isCat) and (self.useCat) and (not self.useBear) and (not isBear and not isBear2) and (localHealth >= self.healthToShift) and (localMana >= self.shapeshiftMana) and (targetObj:GetLevel() <= (localObj:GetLevel() + 2)) and (not IsDrinking()) and (not IsEatings()) then
			if (HasSpell("Cat Form")) then
				CastSpellByName("Cat Form");
				return 0;
			end
		end

		-- if in cat form do these pulls	
		if (isCat) and (not isBear and not isBear2) then

			-- face target
			if (targetObj:GetDistance() <= self.meleeDistance + 2) and (not IsMoving()) then
				targetObj:FaceTarget();
			end

			-- cast tigers fury if we have time
			if (HasSpell("Tiger's Fury")) and (not localObj:HasBuff("Tiger's Fury")) and (not IsSpellOnCD("Tiger's Fury")) and (localEnergy >= 30) then
				if (CastSpellByName("Tiger's Fury")) then
					self.waitTimer = GetTimeEX() + 1550;
					return 0;
				end
			end

			-- check range
			if (targetObj:GetDistance() > self.meleeDistance) and (isCat) then
				return 3;
			end
	
		end


	-- end of cat form pulling



			----
	-- pull no form
	-- or level less than 10
			----

		if (not isBear and not isBear2 and not isCat) or (isMoonkin) then

			-- move into line of sight
			if (targetObj:GetDistance() > 28) or (not targetObj:IsInLineOfSight()) and (localMana >= self.drinkMana) then
				return 3;
			end

			-- face target
			if (targetObj:GetDistance() <= 30) and (not IsMoving()) then
				targetObj:FaceTarget();
			end

			--pull with starfire
			if (HasSpell("Starfire")) and (localMana >= self.drinkMana) then
				if (CastSpellByName("Starfire", targetObj)) then
					targetObj:FaceTarget();
					return 0;
				end
			end

			-- Wrath to pull if no moonfire spell
			if (not HasSpell("Moonfire")) and (localMana >= self.drinkMana) and (not IsMoving()) and (targetObj:GetDistance() <= 30) then
				if (CastSpellByName("Wrath", targetObj)) then
					targetObj:FaceTarget();
					self.waitTimer = GetTimeEX() + 1650;
					self.message = "Casting Wrath!";
					return 0; -- keep trying until cast
				end
			end
			
			-- use moonfire to pull if has spell
			if (HasSpell("Moonfire")) and (localMana >= self.drinkMana) and (not targetObj:HasDebuff("Moonfire")) then
				if (CastSpellByName("Moonfire", targetObj)) then
					self.waitTimer = GetTimeEX() + 1650;
					targetObj:FaceTarget();
					return 0;
				end
			end
			
			-- Entangling roots when target is far enough away and we have enough mana
			if (not self.useBear) and (not self.useCat) and (self.useEntanglingRoots) and (not IsInCombat()) and (not IsMoving()) and (localMana >= self.drinkMana) and (not targetObj:IsCasting()) then
				if (HasSpell("Entangling Roots")) and (not targetObj:HasDebuff("Entangling Roots")) then
					if (CastSpellByName("Entangling Roots", targetObj)) then
						self.waitTimer = GetTimeEX() + 1650;
						return 0;
					end
				end
			end
		end

	-- end of pulling not in combat phase


	-- Combat -- start of combat phase! in combat!

	-- IN COMBAT

	-- IN COMBAT




		else	

			-- dismount before combat
			if (IsMounted()) then
				DisMount();
			end

			self.message = "Killing " .. targetObj:GetUnitName() .. "...";

			-- check heals and buffs
			if (script_druid:healsAndBuffs()) and (not IsLooting()) and (not localObj:HasBuff("Frenzied Regeneration")) then
				self.waitTimer = GetTimeEX() + 2550;
				return;
			end

	-- attacks in bear form IN COMBAT PHASE

			local isBear = localObj:HasBuff("Bear Form");
			local isBear2 = localObj:HasBuff("Dire Bear Form");
			local isCat = localObj:HasBuff("Cat Form");

			-- stay in form - bear form conditions
			if ( (self.useBear) and (not isBear and not isBear2) and (not isCat) and (localHealth > self.healthToShift)
				and (localMana >= self.shapeshiftMana) )
			or ( (self.useBear) and (not isCat) and (script_grind.enemiesAttackingUs(12) >= 2) and (not isBear and not isBear2) and (localMana >= self.shapeshiftMana)
				and (not isCat) and (localHealth > self.healthToShift) )
			or ( (targetObj:GetLevel() >= (localObj:GetLevel() + 2) and IsInCombat()) and (not isBear and not isBear2) and (localMana >= self.shapeshiftMana)
				and (not isCat) and (localHealth > self.healthToShift) and (HasSpell("Bear Form") or HasSpell("Dire Bear Form")) )

			then
				if (not script_grind.adjustTickRate) then
					script_grind.tickRate = 100;
				end
				if (script_druidEX:bearForm()) then
					self.waitTimer = GetTimeEX() + 1500;
				end
			end
			
			-- shift for debuff removal self use bear form
			if (self.hasDrinks) and (isBear or isBear2) and (not isCat and not self.useCat) and (script_checkDebuffs:hasDisabledMovement()) and (localMana >= self.shapeshiftMana*2) and (localHealth > self.healthToShift + 20) and (script_grind.enemiesAttackingUs(12) < 2) then
				if (not script_grind.adjustTickRate) then
					script_grind.tickRate = 100;
				end
				if (script_druidEX:bearForm()) then
					self.waitTimer = GetTimeEX() + 1500;
				end
			end

			-- shift for debuff removal self use cat form - cat form
			if (self.hasDrinks) and (isCat or not isCat) and (not isBear and not isBear2 and not self.useBear) and (script_checkDebuffs:hasDisabledMovement()) and (localMana >= self.shapeshiftMana*2) and (localHealth > self.healthToShift + 20) then
				if (not script_grind.adjustTickRate) then
					DEFAULT_CHAT_FRAME:AddMessage(" --- Shifted out of form to remove disabled movement debuff!");
					script_grind.tickRate = 100;
				end
				if (HasSpell("Cat Form")) then
					CastSpellByName("Cat Form");
					self.waitTimer = GetTimeEX() + 1500;
					return 0;
				end
			end


			-- do these attacks only in bear form
			if (isBear or isBear2) and (not isCat) then

				if (targetObj:GetDistance() > self.meleeDistance) then
					return 3;
				end

				-- face target
				if (targetObj:GetDistance() <= self.meleeDistance) and (not IsMoving()) then
					targetObj:FaceTarget();
				end

				-- if we are switching froms from cat to bear then speed up script tick rate
				if (self.wasInCombat) and (self.runOnce) then
					script_grind.tickRate = 125;
					self.runOnce = false;
				end

				-- face target
				if (targetObj:GetDistance() <= self.meleeDistance) and (not IsMoving()) then
					targetObj:FaceTarget();
				end

				-- check line of sight and move to target
				if (not targetObj:IsInLineOfSight()) and (isBear or isBear2) then
					return 3;
				end

				if (IsMoving()) then
					local randomJumpBear = random(1, 100);
					if (randomJumpBear >= 90) then
						JumpOrAscendStart();
					end
				end

				-- Run backwards if we are too close to the target
				if (targetObj:GetDistance() <= 0.8) then 
					if (script_druid:runBackwards(targetObj,2)) then 
						self.waitTimer = GetTimeEX() + 1850;
						return 0;
					end 
				end

				-- keep auto attack on
				if (not IsAutoCasting("Attack")) then
					targetObj:AutoAttack();
					if (targetObj:GetDistance() < self.meleeDistance) and (not IsMoving()) then
						targetObj:FaceTarget();
					elseif (targetObj:GetDistance() > self.meleeDistance) then
						return 3;
					end
				end

				-- back away from enemy if charge is not on CD and use charge in combat??

				-- use charge in bear form
				if (self.useCharge) and (HasSpell("Feral Charge")) and (not IsSpellOnCD("Feral Charge")) and (localRage >= 5) then
					if (self.useBear) and (isBear or isBear2) and (targetObj:GetDistance() < 26) and (targetObj:GetDistance() > 10) then
						CastSpellByName("Feral Charge");
						return 4;
					end
				end

				-- growl in group
				if (GetNumPartyMembers() >= 2) and (not targetObj:IsTargetingMe()) and (targetObj:GetDistance() <= 10) then
					if (not IsSpellOnCD("Growl")) then
						CastSpellByName("Growl", targetObj);
						self.waitTimer = GetTimeEX() + 800;
						return 0;
					end
				end

				-- bash
				if (HasSpell("Bash")) and (not IsSpellOnCD("Bash")) and (localRage >= 10) and (targetObj:GetDistance() <= self.meleeDistance) and (targetHealth >= 15) then
					if (targetObj:IsCasting()) or (localHealth <= self.healthToShift + 15) then
						CastSpellByName("Bash");
						return 0;
					end
				end

				-- frenzied regeneration
				if (isBear or isBear2) and (HasSpell("Frenzied Regeneration")) and (not IsSpellOnCD("Frenzied Regeneration")) and (localHealth < 50) and (localRage >= 15) and (localMana < 40) then
					if (CastSpellByName("Frenzied Regeneration")) then
						self.waitTimer = GetTimeEX() + 1000;
					end
				end

				if (targetObj:GetDistance() > self.meleeDistance) then
					return 3;
				end

				-- keep faerie fire up
				if HasSpell("Faerie Fire (Feral)") and not IsSpellOnCD("Faerie Fire (Feral)") and not targetObj:HasDebuff("Faerie Fire (Feral)") then
					CastSpellByName("Faerie Fire (Feral)()");
					return 0;
				end

				-- Enrage
				if (HasSpell("Enrage")) and (not IsSpellOnCD("Enrage")) and (targetObj:GetDistance() < 30) and (localHealth > 65) and (targetHealth >= 40) then
					if (CastSpellByName("Enrage")) then
						return 0;
					end
				end

				-- demo Roar
				if (HasSpell("Demoralizing Roar")) and (not targetObj:HasDebuff("Demoralizing Roar")) and (localRage >= 10) then
					if (CastSpellByName("Demoralizing Roar")) then
						return 0;
					end
				end

				-- Swipe
				if (script_druid:enemiesAttackingUs(10) >= 2) and (not localObj:HasBuff("Frenzied Regeneration")) then
					if (HasSpell("Swipe")) and (not targetObj:HasDebuff("Swipe")) and (localRage >= 15) then
						if (CastSpellByName("Swipe")) then
							return 0;
						end
					end
				end

				-- maul non humanoids
				if (HasSpell("Maul")) and (not IsCasting()) and (not IsChanneling())and (not IsMoving()) and (targetObj:GetCreatureType() ~= 'Humanoid') and (targetObj:GetDistance() <= self.meleeDistance) and (not localObj:HasBuff("Frenzied Regeneration")) and ( (script_grind.enemiesAttackingUs(12) >= 2 and localRage >= 20) or (script_grind.enemiesAttackingUs(12) < 2 and localRage >= self.maulRage) ) then
						targetObj:FaceTarget();
					if (CastSpellByName("Maul", targetObj)) then
						targetObj:AutoAttack();
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 200;
						return 0;
					end
				
				end

				-- maul humanoids fleeing conditions
				if (HasSpell("Maul")) and (not IsCasting()) and (not IsChanneling()) and (not IsMoving())
					and (targetObj:GetCreatureType() == 'Humanoid') and (targetHealth > 30)
					and (targetObj:GetDistance() <= self.meleeDistance) and (not localObj:HasBuff("Frenzied Regeneration"))
						and ( (script_grind.enemiesAttackingUs(12) >= 2 and localRage >= 20 and HasSpell("Swipe"))
						or (script_grind.enemiesAttackingUs(12) < 2 and localRage >= self.maulRage)
						or (script_grind.enemiesAttackingUs(12) >= 2 and not HasSpell("Swipe") and localRage >= self.maulRage) )
				then
						targetObj:FaceTarget();
					if (CastSpellByName("Maul", targetObj)) then
						targetObj:AutoAttack();
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 200;
						return 0;
					end
				
				end

				-- face target
				if (targetObj:GetDistance() <= self.meleeDistance) and (isBear or isBear2) and (not IsMoving()) then
					targetObj:FaceTarget();
				end

			end -- end of bear form in combat attacks



	-- attacks in cat form IN COMBAT PHASE

			-- shift for debuff removal - cat form
			if (self.hasDrinks) and (self.useCat) and (isCat or not isCat) and (script_checkDebuffs:hasDisabledMovement()) and (localMana >= self.shapeshiftMana*2) and (localHealth > self.healthToShift + 20) then
				if (not script_grind.adjustTickRate) then
					DEFAULT_CHAT_FRAME:AddMessage(" --- Shifted out of form to remove movement disabled debuff!");
					script_grind.tickRate = 100;
				end
				if (isCat) or (not IsCat) then
					CastSpellByName("Cat Form");
					self.waitTimer = GetTimeEX() + 1500;
					return 0;
				end
			end

			--stay in form
			if (script_grind.enemiesAttackingUs(12) < 2) and (self.useCat and not isCat) and (not self.useBear and not isBear and not isBear2) and (localHealth >= self.healthToShift) and (localMana >= self.shapeshiftMana) and (IsStanding()) and (targetObj:GetLevel() <= (localObj:GetLevel() + 2) ) then	
				if (not script_grind.adjustTickRate) then
					script_grind.tickRate = 100;
				end
				if (CastSpellByName("Cat Form")) then
					self.waitTimer = GetTimeEX() + 800;
				end
			end

			-- do these attacks only in cat form
			if (isCat) and (not isBear and not isBear2) then

				if (targetObj:GetDistance() > self.meleeDistance) and (isCat) then
					return 3;
				end

				-- Run backwards if we are too close to the target
				if (targetObj:GetDistance() <= .5) then 
					if (script_druid:runBackwards(targetObj,2)) then 
						return 4; 
					end 
				end

				-- keep auto attack on
				if (not IsAutoCasting("Attack")) then
					targetObj:AutoAttack();
					if (not IsMoving()) then
						targetObj:FaceTarget();
					end
				end

				-- face target
				if (targetObj:GetDistance() <= self.meleeDistance) and (not IsMoving()) then
					targetObj:FaceTarget();
				end

				-- keep faerie fire up
				if HasSpell("Faerie Fire (Feral)") and not IsSpellOnCD("Faerie Fire (Feral)") and not targetObj:HasDebuff("Faerie Fire (Feral)") then
					CastSpellByName("Faerie Fire (Feral)()");
					self.waitTimer = GetTimeEX() + 1600;
					return 0;
				end

		-- Ferocious Bite with 5 CPs
				if (localCP > 4) and (localEnergy >= 35) and (HasSpell("Ferocious Bite")) then
					if (CastSpellByName("Ferocious Bite", targetObj)) then
						self.waitTimer = GetTimeEX() + 1600;
						return 0;
					end
				end

				-- Rip with 3 CPs
				if (localCP >= 3) and (targetHealth <= 50) and (localEnergy >= 30) and (not HasSpell("Ferocious Bite")) and (not targetObj:HasDebuff("Rip")) and (not targetObj:GetCreatureType() == "Elemental") then
					if (CastSpellByName("Rip", targetObj)) then
						self.waitTimer = GetTimeEX() + 1000;
						return;
					end
				end
			
				-- Dynamic health check when using Ferocious Bite between 1 and 4 CP
				if (targetHealth - 10 <= (10 * localCP)) and (localEnergy >= 35) and (HasSpell("Ferocious Bite")) then
					if (CastSpellByName("Ferocious Bite", targetObj)) then
						self.waitTimer = GetTimeEX() + 1000;
						return;
					end
				end
				
				-- keep tiger's fury up
				if (HasSpell("Tiger's Fury")) and (not localObj:HasBuff("Tiger's Fury")) and (not IsSpellOnCD("Tiger's Fury")) and (localEnergy >= 30) then
					if (CastSpellByName("Tiger's Fury")) then
						self.waitTimer = GetTimeEX() + 1600;
						return 0;
					end
				end

				-- keep rake up
				if (HasSpell("Rake")) and (not targetObj:HasDebuff("Rake")) and (targetHealth >= 30) and (localEnergy >= 35) and (not targetObj:GetCreatureType() == "Elemental") then
					if (CastSpellByName("Rake", targetObj)) then
						self.waitTimer = GetTimeEX() + 2200;
						return 0;
					end
				end

				-- Use Claw
				if (localCP < 5) and (localEnergy >= 40) then
					if (CastSpellByName("Claw")) then
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 1600;
						return 0;
					end
				end
			end



	-- attacks when not in form

		-- no bear form or cat form

			if ( (not isBear and not isBear2) and (not isCat) and (not self.useBear) and (not self.useCat) ) or (isMoonkin) then

				-- face target
				if (targetObj:GetDistance() < 30) and (not IsMoving()) then
					targetObj:FaceTarget();
				end
			
				-- Run backwards if we are too close to the target
				if (targetObj:GetDistance() <= .5) then 
					if (script_druid:runBackwards(targetObj,2)) then 
						return 4; 
					end 
				end

				-- Check: Move backwards if the target is affected by Entangling Root
				if (self.useEntanglingRoots) and (not self.useBear) and (not self.useCat) then
					if (not targetObj:HasDebuff("Entangling Roots")) and (not localObj:HasDebuff("Web")) and (not localObj:HasDebuff("Encasing Webs")) and (localMana > 65) and (targetHealth >= 35) then
						if (not script_grind.adjustTickRate) then
							script_grind.tickRate = 100;
						end
						if (not targetObj:HasDebuff("Entangling Roots")) and (not targetObj:IsCasting()) then
							if (CastSpellByName("Entangling Roots")) then
								self.waitTimer = GetTimeEX() + 300;
								return 4;
							end
						end
					end 
				end	
					-- run backwards if target is entangled
				if (targetObj:HasDebuff("Entangling Roots")) and (localMana > 36) then
					if (script_druid:runBackwards(targetObj, 12)) then
						self.waitTimer = GetTimeEX() + 500;
					return 4;
					end
				end

				-- check heals and buffs
				if (script_druid:healsAndBuffs()) and (not IsLooting()) and (not localObj:HasBuff("Frenzied Regeneration")) then
					self.waitTimer = GetTimeEX() + 2550;
					return;
				end

				-- War Stomp Tauren Racial
				if (HasSpell("War Stomp")) and (not IsSpellOnCD("War Stomp")) and (targetObj:IsCasting() or script_druid:enemiesAttackingUs(10) >= 2) and (not IsMoving()) and (targetObj:GetDistance() <= 8) then
					CastSpellByName("War Stomp");
					self.waitTimer = GetTimeEX() + 200;
					return 0;
				end

				-- keep moonfire up
				if (localMana > 30) and (targetHealth > 5) and (not targetObj:HasDebuff("Moonfire")) and (HasSpell("Moonfire")) then
					if (CastSpellByName("Moonfire", targetObj)) then
						self.waitTimer = GetTimeEX() + 1650;
						targetObj:FaceTarget();
						return 0;
					end
				end

				-- spam moonfire until target is killed
				if (localMana > 30) and (targetHealth < 10) and (not IsSpellOnCD("Moonfire")) and (HasSpell("Moonfire")) then
					if (CastSpellByName("Moonfire", targetObj)) then
						self.waitTimer = GetTimeEX() + 1650;
						targetObj:FaceTarget();
						return 0;
					end
				end

				-- starfire
				if (HasSpell("Starfire")) and (localMana > 60) and (script_grind:enemiesAttackingUs(10) < 2) and (not IsMoving()) then
					if (CastSpellByName("Starfire", targetObj)) then
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 800;
					end
				end

				-- Wrath
				if (localMana > 30) and (targetHealth > 15) then
					if (CastSpellByName("Wrath", targetObj)) then
						self.waitTimer = GetTimeEX() + 1650;
						targetObj:FaceTarget();
						return 0;
					end
				end	

			end -- end of if not bear or cat... no form attacks
			
			-- auto attack condition for melee
			if (localMana <= 30 or isBear or isBear2 or isCat) then
				if (targetObj:GetDistance() <= self.meleeDistance) then
					if (not IsMoving()) then
						targetObj:FaceTarget();
					end
					targetObj:AutoAttack();
				else
					return 3;
				end
			end
		end -- end of else combat phase

		-- set tick rate for script to run
		if (not script_grind.adjustTickRate) then
	
			local tickRandom = random(750, 1150);
		
			if (IsMoving()) or (not IsInCombat()) then
				script_grind.tickRate = 135;
			elseif (not IsInCombat()) and (not IsMoving()) then
				script_grind.tickRate = tickRandom;
			elseif (IsInCombat()) and (not IsMoving()) then
				script_grind.tickRate = tickRandom;
			end
		end
	end -- end valid target
end -- end of function

function script_druid:rest()
	if(not self.isSetup) then
		script_druid:setup();
	end

	local localObj = GetLocalPlayer();

	local localLevel = localObj:GetLevel();

	local localHealth = localObj:GetHealthPercentage();

	local localMana = localObj:GetManaPercentage();

	local isBear = localObj:HasBuff("Bear Form");

	local isCat = localObj:HasBuff("Cat Form");

	local isBear2 = localObj:HasBuff("Dire Bear Form");

	local isTravel = localObj:HasBuff("Travel Form");

	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(750, 1150);

		if (IsMoving()) or (not IsInCombat()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom
		elseif (IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		end
	end

	-- shapeshift into cat form after bear form
	if (not IsInCombat()) and (isBear or isBear2) and (self.useCat) and (not IsDrinking()) and (not IsEating()) and (localMana >= self.shapeshiftMana) then
		if (script_druidEX:bearForm()) then
			self.waitTimer = GetTimeEX() + 1500;
		end
	end

	-- shift for debuff removal - cat form
	if (self.hasDrinks) and (self.useCat) and (isCat or not isCat) and (script_checkDebuffs:hasDisabledMovement()) and (localMana >= self.shapeshiftMana*2) and (localHealth > self.healthToShift + 20) then
		if (not script_grind.adjustTickRate) then
			DEFAULT_CHAT_FRAME:AddMessage(" --- Shifted out of form to remove movement disabled debuff!");
			script_grind.tickRate = 100;
		end
		if (isCat) or (not IsCat) then
			CastSpellByName("Cat Form");
			self.waitTimer = GetTimeEX() + 1500;
			return 0;
		end
	end

	-- shift for debuff removal - bear form
	if (self.hasDrinks) and (isBear or isBear2) and (HasSpell("Bear Form") or HasSpell("Dire Bear Form")) and (script_checkDebuffs:hasDisabledMovement()) and (localMana >= self.shapeshiftMana*2) and (localHealth > self.healthToShift + 20) then
		if (not script_grind.adjustTickRate) then
			DEFAULT_CHAT_FRAME:AddMessage(" --- Shifted out of form to remove movement disabled debuff!");
			script_grind.tickRate = 100;
		end
		if (script_druidEX:bearForm()) then
			self.waitTimer = GetTimeEX() + 1500;
		end
	end

	-- shift to drink - in bear form
	if (isBear or isBear2) and (self.shiftToDrink) and (not IsInCombat()) then
		if (localMana <= self.drinkMana - 20) and (isBear or isBear2) then
			if (script_druidEX:bearForm()) then
				self.waitTimer = GetTimeEX() + 1500;
			end
		end
	end

	-- shift to drink - in cat form
	if (self.shiftToDrink) and (localMana <= self.drinkMana - 20) and (isCat) and (not IsInCombat()) and (isCat) then 			if (CastSpellByName("Cat Form")) then
			self.waitTimer = GetTimeEX() + 1650;
			return 0;
		end
	end

	-- Drink something if not in form
	if (not isBear and not isBear2) and (not isCat) and (not isTravel) and (not IsInCombat()) and (not IsDrinking()) and (localMana <= self.drinkMana) and (not localObj:HasBuff("Innervate")) then
		
			self.message = "Need to drink...";

	
			-- Dismount
			if(IsMounted()) then 
				DisMount(); 
				return true; 
			end
			if (IsMoving()) then
				StopMoving();
				return true;
			end

			if (script_helper:drinkWater()) and (not IsInCombat()) then 
				self.message = "Drinking..."; 
				self.waitTimer = GetTimeEX() + 2500;
				return true; 
			else 
				self.message = "No drinks! (or drink not included in script_helper)";
				self.shapeshiftMana = 50;
				self.shitToDrink = false;
				self.hasDrinks = false;
				return true; 
			end
		end
	
	-- eat if not in form
	if (not isBear and not isBear2) and (not isCat) and (not isTravel) and (not IsInCombat()) and (not IsEating() and localHealth < self.eatHealth) then

			self.message = "Need to eat...";	

			-- Dismount
			if(IsMounted()) then
				DisMount();
			end
			if (IsMoving()) then
				StopMoving();
				return true;
			end
			
			if (script_helper:eat()) and (not IsInCombat()) then 
				self.message = "Eating..."; 
				self.waitTimer = GetTimeEX() + 1500;
				return true; 
			else 
				self.message = "No food! (or food not included in script_helper)";
				self.waitTimer = GetTimeEX() + 1200;
				return true; 
			end	
		end

	-- check heals and buffs
	if (script_druid:healsAndBuffs()) and (not IsLooting()) and (script_grind.lootObj == nil or script_grind.lootObj == 0) and (not IsDrinking()) and (not IsEating()) and (not localObj:HasBuff("Frenzied Regeneration")) and (not IsMoving()) then
		self.waitTimer = GetTimeEX() + 3000;
		script_grind:setWaitTimer(3000);
	end	

	-- rest in form
	if (isBear or isBear2 or isCat) and (self.useRest) and (script_grind.lootObj == nil or script_grind.lootObj == 0) then
		if (localObj:GetUnitsTarget() == 0) then
			if (localMana <= 75 or localHealth <= 75) and (not IsInCombat()) then
				if (isCat) and (HasSpell("Prowl")) and (not IsSpellOnCD("Prowl")) and (not localObj:HasBuff("Prowl")) and (not script_checkDebuffs:hasPoison()) then
					CastSpellByName("Prowl", localObj);
				end
				self.message = "Waiting - low mana or health and shapeshifted! Change heal/drink!";
				return true;
			end
		end		
	end	

	-- stop bot to rest if we need to rest
	if (self.useRest) and (localMana < self.drinkMana or localHealth < self.eatHealth) then
		if (IsMoving()) then
			StopMoving();
			self.waitTimer = GetTimeEX() + 500;
		end
		return true;
	elseif (IsDrinking() and localMana < self.drinkMana) or (IsEating() and localHealth < self.eatHealth) then
		return true;
	end

	-- cast shadowmeld if eating and has shadowmeld
	if (IsEating()) or (IsDrinking()) and (not IsStanding()) and (HasSpell("Shadowmeld")) and (not IsSpellOnCD("Shadowmeld")) and (not isCat) and (not isBear and not isBear2) and (not isTravel) then
		if (CastSpellByName("Shadowmeld")) then
			self.waitTimer = GetTimeEX() + 2000;
			return 0;
		end
	end
	
	-- Continue resting
	if(localHealth < 98 and IsEating() or localMana < 98 and IsDrinking()) then
		self.message = "Resting up to full HP/Mana...";
		return true;
	end

	-- Stand up if we are rested
	if (localHealth > 98 and (IsEating() or not IsStanding())) and (localMana > 98 and (IsDrinking() or not IsStanding())) then
		StopMoving();
		return false;
	end

-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(750, 1150);

		if (IsMoving()) or (not IsInCombat()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		elseif (IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		end
	end

	-- Don't need to rest
	return false;
end

function script_druid:window()

	if (self.isChecked) then
	
		--Close existing Window
		EndWindow();

		if(NewWindow("Class Combat Options", 200, 200)) then
			script_druidEX:menu();
		end
	end
end
