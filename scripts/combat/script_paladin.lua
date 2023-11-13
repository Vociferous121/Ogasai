script_paladin = {
	message = "Paladin Combat Script",
	paladinMenu = include("scripts\\combat\\script_paladinEX.lua"),
	isSetup = false,
	isChecked = true,
	stopIfMHBroken = true,
	useFlashOfLightCombat = true,
	aura = "Devotion Aura",
	blessing = "Blessing of Wisdom",
	waitTimer = 0,
	eatHealth = 30,
	drinkMana = 35,
	shieldHealth = 13,
	lohHealth = 9,
	holyLightHealth = 45,
	flashOfLightHP = 70,
	potionHealth = 10,
	potionMana = 15,
	consecrationMana = 50,
	meleeDistance = 3.4,
	useSealOfCrusader = true,
	useJudgement = true,
	runOnce = true,
}

function script_paladin:setup()

	-- Sort Aura  

	--use Devotion Aura if nothing else
	if (not HasSpell("Retribution Aura")) and (not HasSpell("Sanctity Aura")) and (not localObj:HasBuff("Stoneskin")) then
		self.aura = "Devotion Aura";	

		-- else use Ret aura if have it
	elseif (not HasSpell("Sanctity Aura")) and (HasSpell("Retribution Aura")) then
		self.aura = "Retribution Aura";

		-- else use Sanctity aura if have it
	elseif (HasSpell("Sanctity Aura")) then
		self.aura = "Sanctity Aura";	
	end

	-- Sort Blessing  

	-- Blessing of wisdom
	if (HasSpell("Blessing of Wisdom")) then
		self.blessing = "Blessing of Wisdom";
	
		--Blessing of might
	elseif (HasSpell("Blessing of Might")) then
		self.blessing = "Blessing of Might";
	end
	
	--set holy light health no flash of light
	if (not HasSpell("Flash of Light")) then
		self.holyLightHealth = 66;
	end

	script_grind.jumpRandomFloat = 92;
	script_grind.jump = true;
	self.waitTimer = GetTimeEX();

	self.isSetup = true;

end

function script_paladin:spellAttack(spellName, target)
	if (HasSpell(spellName)) then
		if (target:IsSpellInRange(spellName)) then
			if (not IsSpellOnCD(spellName)) then
				if (not IsAutoCasting(spellName)) then
					target:FaceTarget();
					--target:TargetEnemy();
					return target:CastSpell(spellName);
				end
			end
		end
	end
	return false;
end

function script_paladin:enemiesAttackingUs(range) -- returns number of enemies attacking us within range
    local unitsAttackingUs = 0; 
    local currentObj, typeObj = GetFirstObject(); 
    while currentObj ~= 0 do 
    	if typeObj == 3 then
		if (currentObj:CanAttack()) and (not currentObj:IsDead()) then
                	if (script_grind:isTargetingMe(currentObj)) and (currentObj:GetDistance() <= range) then 
                		unitsAttackingUs = unitsAttackingUs + 1; 
                	end 
            	end 
       	end
        currentObj, typeObj = GetNextObject(currentObj); 
    end
    return unitsAttackingUs;
end

-- Run backwards if the target is within range
function script_paladin:runBackwards(targetObj, range) 
	local localObj = GetLocalPlayer();
 	if targetObj ~= 0 then
 		local xT, yT, zT = targetObj:GetPosition();
 		local xP, yP, zP = localObj:GetPosition();
 		local distance = targetObj:GetDistance();
 		local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
 		local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 		local xUV, yUV, zUV = (1/vectorLength)*xV-1, (1/vectorLength)*yV-1, (1/vectorLength)*zV;		
 		local moveX, moveY, moveZ = (xT) - xUV*1, (yT) - yUV*1, zT - zUV;		
 		if (distance < range) then 
 			Move(moveX, moveY, moveZ);
			JumpOrAscendStart();
			targetObj:FaceTarget();
 			return true;
 		end
	end
	return false;
end

-- Run forwards if the target is low health
function script_paladin:runForwards(targetObj, range) 
	local localObj = GetLocalPlayer();
 	if targetObj ~= 0 then
 		local xT, yT, zT = targetObj:GetPosition();
 		local xP, yP, zP = localObj:GetPosition();
 		local distance = targetObj:GetDistance();
 		local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
 		local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 		local xUV, yUV, zUV = (1/vectorLength)*xV-1, (4/vectorLength)*yV+5, (1/vectorLength)*zV;		
 		local moveX, moveY, moveZ = (xT) - xUV*1, (yT) - yUV*1, zT - zUV;		
 		if (distance < range) then 
 			Move(moveX, moveY, moveZ);
			JumpOrAscendStart();
			targetObj:FaceTarget();
 			return true;
 		end
	end
	return false;
end

function script_paladin:draw()
	--script_paladin:window();

	local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());

	if (onScreen) then
		DrawText(self.message, tX+75, tY+44, 255, 255, 255);

	else
		DrawText(self.message, 25, 185, 255, 0, 0);
	end
end



--[[ error codes: 	0 - All Good , 
			1 - missing arg , 
			2 - invalid target , 
			3 - not in range, 
			4 - do nothing , 
			5 - targeted player pet/totem
			6 - stop bot request from combat script  ]]--



function script_paladin:healAndBuff(localObj, localMana)

	local localMana = GetLocalPlayer():GetManaPercentage();
	local localHealth = GetLocalPlayer():GetHealthPercentage();
	local localObj = GetLocalPlayer();

	-- Set aura - cast aura
	if (self.aura ~= 0 and not IsMounted()) then
		if (not localObj:HasBuff(self.aura) and HasSpell(self.aura)) then
			CastSpellByName(self.aura);
			self.waitTimer = GetTimeEX() + 1750;
		end
	end

	-- Buff with Blessing
	if (self.blessing ~= 0) and (HasSpell(self.blessing)) then
		if (localMana > 10) and (not localObj:HasBuff(self.blessing)) then
			Buff(self.blessing, localObj);
			self.waitTimer = GetTimeEX() + 1750;
			return 0;
		end
	end

	if (localObj:HasBuff("Judgement")) and (not IsSpellOnCD("Judgement")) and (localObj:HasBuff("Seal of Righteousness")) then
		CastSpellByName("Judgement");
		self.waitTimer = GetTimeEX() + 1650;
		return 0;
	end

	-- Check: Use Lay of Hands
	if (localHealth < self.lohHealth) and (HasSpell("Lay on Hands")) and (not IsSpellOnCD("Lay on Hands")) then 
		if (Cast("Lay on Hands", localObj)) then 
			self.message = "Cast Lay on Hands...";
			return 0;
		end
	end
			
	-- Check: Divine Protection if BoP on CD
	if(localHealth < self.shieldHealth) and (not localObj:HasDebuff("Forbearance")) then
		if (HasSpell("Divine Shield")) and (not IsSpellOnCD("Divine Shield")) then
			CastSpellByName("Divine Shield");
			self.message = "Cast Divine Shield...";
			return 0;
		elseif (HasSpell("Divine Protection")) and (not IsSpellOnCD("Divine Protection")) then
			CastSpellByName("Divine Protection");
			self.message = "Cast Divine Protection...";
			return 0;
		elseif (HasSpell("Blessing of Protection")) and (not IsSpellOnCD("Blessing of Protection")) then
			CastSpellByName("Blessing of Protection");
			self.message = "Cast Blessing of Protection...";
			return 0;
		end
	end

	-- flash of light not in combat
	if (HasSpell("Flash of Light")) and (localMana >= 40) and (not IsInCombat()) and (localHealth >= self.holyLightHealth) and (localHealth <= 85) then
		CastHeal("Flash of Light", localObj);
		self.waitTimer = GetTimeEX() + 1500;
		return 0;
	end

	local checkHealth = GetLocalPlayer():GetHealthPercentage();

	-- holy light
	if (localMana > 18) and (checkHealth < self.holyLightHealth) and (not IsMoving()) then
		CastHeal("Holy Light", localObj);
		self.waitTimer = GetTimeEX() + 3250;
		return 0;
	end

	-- Flash of Light in combat
	if (self.useFlashOfLightCombat) then
		if (IsInCombat()) and (HasSpell("Flash of Light")) and (localHealth <= self.flashOfLightHP) and (localMana >= 10) then
			CastHeal("Flash of Light", localObj);
			self.waitTimer = GetTimeEX() + 1500;
			self.message = "Flash of Light enabled - Healing!";
			return 0;				
		end
	end

return false;
end

function script_paladin:run(targetGUID)
	
	local localObj = GetLocalPlayer();

	local localMana = localObj:GetManaPercentage();

	local localHealth = localObj:GetHealthPercentage();

	local localLevel = localObj:GetLevel();

	-- setup
	if (not self.isSetup) then
		script_paladin:setup();
	end

	-- if dead run rest of script
	if (localObj:IsDead()) then
		return 0; 
	end

	-- stop when target is dead and still in combat
	if (IsInCombat()) and (GetLocalPlayer():GetUnitsTarget() == 0) then
		return 4;
	end

	-- Check: If Mainhand is broken stop bot
	isMainHandBroken = GetInventoryItemBroken("player", 16);
	
	if (self.stopIfMHBroken) and (isMainHandBroken) then
		self.message = "The main hand weapon is broken...";
		return 6;
	end

	-- Assign the target 
	targetObj = GetGUIDObject(targetGUID);

	if (targetObj == 0) or (targetObj == nil) then
		return 2;
	end	

	if (script_paladin:healAndBuff(localObj, localMana)) then
		return;
	end

	-- Check: Do nothing if we are channeling or casting or wait timer
	if (IsChanneling()) or (IsCasting()) or (self.waitTimer > GetTimeEX()) then
		return 4;
	end

	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(300, 700);

		if (IsMoving()) or (not IsInCombat()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom
		elseif (IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		end
	end
	
	--Valid Enemy
	if (targetObj ~= 0) and (not localObj:IsStunned()) then

		-- Cant Attack dead targets
		if (targetObj:IsDead()) or (not targetObj:CanAttack()) then
			self.waitTimer = GetTimeEX() + 1200;
			return 0;
		end
		
		if (not IsStanding()) and (not IsEating()) and (not IsDrinking()) then
			JumpOrAscendStart();
		end

		if (targetObj:GetDistance() <= 8) and (not IsMoving()) then
			targetObj:FaceTarget();
		end

		-- Check move into melee range
		if (targetObj:GetDistance() > self.meleeDistance) or (not targetObj:IsInLineOfSight()) and (IsInCombat()) then
			return 3;
		end

		if (not targetObj:IsFleeing()) then
			if (script_paladin:healAndBuff(localObj, localMana)) then
				return;
			end
		end

		-- Auto Attack
		if (targetObj:GetDistance() < 40) and (not IsMoving()) then
			targetObj:AutoAttack();
		-- stops spamming auto attacking while moving to target
		elseif (targetObj:GetDistance() <= 8) then
			targetObj:AutoAttack();
			targetObj:FaceTarget();
		end
	
		targetHealth = targetObj:GetHealthPercentage();

		-- Don't attack if we should rest first
		if (localHealth < self.eatHealth) and (not script_grind:isTargetingMe(targetObj)) and (targetHealth > 99) and (not targetObj:IsStunned()) and (script_grind.lootobj == nil) then
			self.message = "Need rest...";
			return 4;
		end

		-- Check: if we target player pets/totems
		if (GetTarget() ~= nil) and (targetObj ~= nil) then
			if (UnitPlayerControlled("target")) and (GetTarget() ~= localObj) then 
				script_grind:addTargetToBlacklist(targetObj:GetGUID());
				return 5; 
			end
		end 
		
		-- Opener

		if (not IsInCombat()) then

			self.targetObjGUID = targetObj:GetGUID();

			self.runOnce = true;

			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";
	
			-- Dismount
			if (IsMounted()) and (targetObj:GetDistance() < 25) then
				DisMount(); 
				return 0;
			 end

			if (script_paladin:paladinPull(targetObj)) then
				return;
			end


			-- check if we are in combat?
			if (IsInCombat()) and (targetObj:GetDistance() <= self.meleeDistance) and (targetHealth > 99) and (not IsAutoCasting("Attack")) then
				targetObj:AutoAttack();
				self.waitTimer = GetTimeEX() + 200;	
			end
					
		-- Combat WE ARE NOW IN COMBAT

		else	

			self.message = "Killing " .. targetObj:GetUnitName() .. "...";

			-- Dismount
			if (IsMounted()) then 
				DisMount();
			end

			--targetObj = GetGUIDObject(targetGUID);

			if (not targetObj:IsFleeing()) then
				if (script_paladin:healAndBuff(localObj, localMana)) then
					return;
				end
			end

			-- Run backwards if we are too close to the target
			if (targetObj:GetDistance() < .9) then 
				if (script_paladin:runBackwards(targetObj,1)) then 
					JumpOrAscendStart();
					targetObj:FaceTarget();
					self.runOnce = false;
					return 4; 
				end 
				if (IsMoving()) then
					JumpOrAscendStart();
					targetObj:FaceTarget();
				end
			end

			if (script_grind.jump) and (IsMoving()) and (localHealth > self.holyLightHealth) and (localHealth > self.flashOfLightHP) then
				local randomJumping = math.random(1, 100);
				if (randomJumping > 90) then
					JumpOrAscendStart();
					targetObj:FaceTarget();
				end
			end

			-- Check if we are in melee range
			if (targetObj:GetDistance() > self.meleeDistance) or (not targetObj:IsInLineOfSight()) then
				return 3;
			end
			
			-- recheck auto attack
			if (targetObj:GetDistance() <= self.meleeDistance) and (not IsAutoCasting("Attack")) then
				targetObj:AutoAttack();
			end

			-- Check: Stun with HoJ before healing if available
			if (IsInCombat()) and (targetObj:GetDistance() <= self.meleeDistance) and (HasSpell("Hammer of Justice")) and (not IsSpellOnCD("Hammer of Justice")) then
				if (Cast("Hammer of Justice", targetObj)) then
					self.waitTimer = GetTimeEX() + 1750;
					return 0;
				end
			end

			-- dwarf stone form racial
			if (HasSpell("Stoneform")) and (not IsSpellOnCD("Stoneform")) and (IsInCombat()) and (targetHealth >= 35) and (localHealth >= 15) then
				CastSpellByName("Stoneform");
				self.waitTimer = GetTimeEX() + 1550;
				return 0;
			end

			-- Holy strike
		--	if (HasSpell("Holy Strike")) and (localMana > 15) and (not IsSpellOnCD("Holy Strike")) then
		--		if (targetObj:GetDistance() <= self.meleeDistance) then
		--			targetObj:FaceTarget();
		--			Cast("Holy Strike", targetObj);
		--			return 0;
		--		end
		--	end

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

			-- Check: Remove desease or poison
			if (HasSpell("Cleanse")) then
				if (localObj:HasDebuff("Rabies")) or (localObj:HasDebuff("Corrosive Poison")) or (localObj:HasDebuff("Poison")) or (localObj:HasDebuff("Fevered Fatigue"))
					or (localObj:HasDebuff("Dark Sludge")) or (localObj:HasDebuff("Corrosive Poison")) or (localObj:HasDebuff("Slowing Poison"))
						or (localObj:HasDebuff("Infected Bite")) or (localObj:HasDebuff("Wandering Plague"))
							or (localObj:HasDebuff("Plague Mind")) or (localObj:HasDebuff("Fevered Fatigue")) then

				-- add some randomness to how quick the bot casts cleanse

						local cleanseRandom = random(1, 100);
					if (cleanseRandom > 90) then
						if (Buff("Cleanse", localObj)) then 
							self.message = "Cleansing..."; 
							self.waitTimer = GetTimeEX() + 1750; 
							return 0; 
						end
					end
				end
			end

			-- remove disease with purify
			if (HasSpell("Purify")) then
				if (localObj:HasDebuff("Rabies")) or (localObj:HasDebuff("Corrosive Poison")) or (localObj:HasDebuff("Poison")) or (localObj:HasDebuff("Fevered Fatigue"))
					or (localObj:HasDebuff("Dark Sludge")) or (localObj:HasDebuff("Corrosive Poison")) or (localObj:HasDebuff("Slowing Poison"))
						or (localObj:HasDebuff("Infected Bite")) or (localObj:HasDebuff("Wandering Plague"))
							or (localObj:HasDebuff("Plague Mind")) or (localObj:HasDebuff("Fevered Fatigue")) or (localObj:HasDebuff("Tetanus")) then

				-- add some randomness to how quick the bot casts cleanse

						local cleanseRandom = random(1, 100);
					if (cleanseRandom > 90) then
						if (Buff("Purify", localObj)) then 
							self.message = "Cleansing..."; 
							self.waitTimer = GetTimeEX() + 1750; 
							return 0; 
						end
					end
				end
			end


			-- Check: Remove movement disables with Freedom
			if (localObj:IsMovementDisabed() and HasSpell("Blessing of Freedom")) then
				Buff("Blessing of Freedom", localObj);
				return 0;
			end

			-- Check: Seal of the Crusader until we use judgement
			if (self.useSealOfCrusader) and (not targetObj:HasDebuff("Judgement of the Crusader")) and (targetObj:GetDistance() < 15) and (not localObj:HasBuff("Seal of the Crusader")) and localMana > 15 and (not IsSpellOnCD("Judgement")) and (targetObj:GetHealthPercentage() > 25) then
				if (Cast("Seal of the Crusader", targetObj)) then
					return 3;
				end
			end

			-- Check: Exorcism
			if (targetObj:GetCreatureType() == "Demon") or (targetObj:GetCreatureType() == "Undead") then
				if (targetObj:GetDistance() < 30) and (HasSpell("Exorcism")) and (not IsSpellOnCD("Exorcism")) and (localMana > 30) then
					if (Cast("Exorcism", targetObj)) then 
						return 0;
					end
				end
			end

			-- Check: If we are in melee range, do melee attacks ----- RETURN 0   ONLY USE IN MELEE RANGE
			if (targetObj:GetDistance() <= self.meleeDistance + 2) then

				-- run forwards
				if (not self.runOnce) then
					if (targetHealth <= 29) and (script_grind.jump) then
						if (script_paladin:runForwards(targetObj,1)) then
							targetObj:FaceTarget();
							return 4;
						end
					end
				end

				
				if (not targetObj:IsFleeing()) then
					if (script_paladin:healAndBuff(localObj, localMana)) then
						return;
					end
				end
					
				if (targetObj:IsInLineOfSight() and not IsMoving()) and (targetObj:GetDistance() <= 6) then
					targetObj:FaceTarget();	
				end

				-- hammer of justice when fleeing
				if (targetObj:IsCasting()) or (targetObj:IsFleeing()) then
					if (HasSpell("Hammer of Justice")) and (not IsSpellOnCD("Hammer of Justice")) and (localMana > 8) then
						if (Cast("Hammer of Justice", targetObj)) then
							self.waitTimer = GetTimeEX() + 2000;
							return 0;
						end
					end
				end
	
				-- On low health do seal of light if targetHP > 50 and localMana < 15
				if (HasSpell("Seal of Light")) and (not localObj:HasBuff("Seal of Light")) and (localMana < 15) then
					if (targetHealth > 50) or (script_grind:enemiesAttackingUs(5) > 1) then
						if (Cast("Seal of Light", targetObj)) then
							self.waitTimer = GetTimeEX() + 1000;
						end
					end
				end

				-- on low mana do seal of wisdom if selfMana < 25 and targetHP > 50
				if (HasSpell("Seal of Wisdom")) and (not localObj:HasBuff("Seal of Light")) or (not localObj:HasBuff("Seal of Wisdom")) then
					if (localMana < 25) and (targetHealth > 50) then
						if (Cast("Seal of Wisdom", targetObj)) then
							self.waitTimer = GetTimeEX() + 1000;
						end
					end
				end

				-- Stun the target if target has seal of crusader debuff
				if (not IsSpellOnCD("Judgement")) and (localMana > 50) and (HasSpell("Hammer of Justice")) and (not IsSpellOnCD("Hammer of Justice")) then
					if (targetHealth > 50) and (targetObj:HasDebuff("Judgement of the Crusader")) and (localObj:HasBuff("Seal of Command") or localObj:HasBuff("Seal of Righteousness")) then
						if (Cast("Hammer of Justice", targetObj)) then
							self.waitTimer = GetTimeEX() + 1750; 
							return 0;
						end
					end
				end
		
				-- Use Judgement on the stunned target
				if (targetObj:HasDebuff("Hammer of Justice")) and (localObj:HasBuff("Seal of Command") or localObj:HasBuff("Seal of Righteousness")) and (self.useJudgement) then
					if (targetObj:GetDistance() <= self.meleeDistance) and (localMana > 15) then
						if (Cast("Judgement", targetObj)) then
							self.waitTimer = GetTimeEX() + 750;
							return 0;
						end
					end
				end

				-- Seal of the Crusader until we used judgement
				if (self.useSealOfCrusader) and (HasSpell("Seal of the Crusader")) and (localMana > 15) and (targetHealth > 55) then
					if (not targetObj:HasDebuff("Judgement of the Crusader")) and (not localObj:HasBuff("Seal of the Crusader")) and (not localObj:HasBuff("Seal of Light")) then
						if (Buff("Seal of the Crusader", localObj)) then
							self.waitTimer = GetTimeEX() + 1500; 
							return 0;
						 end
					end 
				elseif (targetHealth < 55) then
					if (not localObj:HasBuff("Seal of Righteousness")) and (not localObj:HasBuff("Seal of the Crusader")) and (localMana > 15) then
						CastSpellByName("Seal of Righteousness");
						self.waitTimer = GetTimeEX() + 1750;
						return 0;
					end
				end

				-- use Judgement when we have crusader buffed
				if (self.useJudgement) and(HasSpell("Judgement")) and (not IsSpellOnCD("Judgement")) and (localObj:HasBuff("Seal of the Crusader")) and (localMana > 15) then
					if (targetObj:GetDistance() < 10) and (not targetObj:HasDebuff("Judgement of the Crusader")) and (localObj:HasBuff("Seal of the Crusader")) then
						if (Cast("Judgement", targetObj)) then
							self.waitTimer = GetTimeEX() + 1500; 
							return 0;
						end 
					end
				end

				-- Check: Seal of Righteousness (before we have SoC)
				if (not localObj:HasBuff("Seal of Righteousness")) and (not localObj:HasBuff("Seal of the Crusader")) and (not HasSpell("Seal of Command")) and
					(not localObj:HasBuff("Seal of Light")) and (localMana > 15) then 
					if (Buff("Seal of Righteousness", localObj)) then
						self.waitTimer = GetTimeEX() + 1500;
						return 0;
					end
				end

				-- Check: Judgement with Righteousness or Command if we have a lot of mana
				if (self.useJudgement) and (localMana > 50) and (not IsSpellOnCD("Judgement")) then
					if (localObj:HasBuff("Seal of Righteousness") or localObj:HasBuff("Seal of Command")) then 
						if (Cast("Judgement", targetObj)) then
							self.waitTimer = GetTimeEX() + 750;
 							return 0;
						end 
					end
				end

				-- Check: Use judgement if we are buffed with Righteousness or Command and the target is low
				if (self.useJudgement) and (targetHealth < 10) and (HasSpell("Seal of Command") or HasSpell("Seal of Righteousness")) and (localMana > 15) then
					if (localObj:HasBuff("Seal of Righteousness") or localObj:HasBuff("Seal of Command")) and (targetObj:GetDistance() < 10) then
						if (Cast("Judgement", targetObj)) then self.waitTimer = GetTimeEX() + 1500;
 							return 0;
						end
					end
				end

				-- Check: Seal of Command
				if (HasSpell("Seal of Command")) and (not localObj:HasBuff("Seal of Command")) and (localMana > 15) then
					if (not localObj:HasBuff("Seal of the Crusader")) and (not localObj:HasBuff("Seal of Light")) then 
						if (Buff("Seal of Command", localObj)) then
							self.waitTimer = GetTimeEX() + 1500;
 							return 0;
						end
					end
				end

				-- Consecration when we have adds
				if (HasSpell("Consecration")) and (not IsSpellOnCD("Consecration")) and (localMana > self.consecrationMana) then
					if (script_grind:enemiesAttackingUs(4) >= 1) then
						CastSpellByName("Consecration"); self.waitTimer = GetTimeEX() + 1500;
 						return 0;	
					end
				end
			end
			return 0;
		end
	end
end

function script_paladin:rest()

	if (GetLocalPlayer():GetHealthPercentage() <= self.eatHealth) then
		ClearTarget();
	end

	if(not self.isSetup) then
		script_paladin:setup();
	end
	
	self.runOnce = true;

	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(300, 700);

		if (IsMoving()) or (not IsInCombat()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom
		elseif (IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		end
	end

	local localObj = GetLocalPlayer();
	local localLevel = localObj:GetLevel();
	local localHealth = localObj:GetHealthPercentage();
	local localMana = localObj:GetManaPercentage();

	-- heal before eating
	if (IsStanding()) and (not IsEating()) and (not IsDrinking()) then
		if (script_paladin:healAndBuff(localObj, localMana)) then
			return;
		end
	end

	-- Buff with Blessing
	if (self.blessing ~= 0 and HasSpell(self.blessing) and not IsMounted()) then
		if (localMana > 10 and not localObj:HasBuff(self.blessing)) then
			Buff(self.blessing, localObj);
			return false;
		end
	end

	-- Stop moving before we can rest
	if(localHealth < self.eatHealth or localMana < self.drinkMana) and (not IsEating()) and (not IsDrinking()) then
		if (IsMoving()) then
			StopMoving();
			return true;
		end
	end

	-- Eat and Drink
	if (not IsDrinking() and localMana < self.drinkMana) then
		self.message = "Need to drink...";
		self.waitTimer = GetTimeEX() + 2000;
		-- Dismount
		if(IsMounted()) then 
			DisMount(); 
			return true; 
		end
		if (IsMoving()) then
			StopMoving();
			return true;
		end

		if (script_helper:drinkWater()) then 
			self.message = "Drinking..."; 
			self.waitTimer = GetTimeEX() + 2000;
			return true; 
		else 
			self.message = "No drinks! (or drink not included in script_helper)";
			ClearTarget();
			return true; 
		end
	end
	if (not IsEating() and localHealth < self.eatHealth) then
		-- Dismount
		if(IsMounted()) then DisMount(); end
		self.message = "Need to eat...";
		self.waitTimer = GetTimeEX() + 2000;	
		if (IsMoving()) then
			StopMoving();
			return true;
		end
		
		if (script_helper:eat()) then 
			self.message = "Eating..."; 
			self.waitTimer = GetTimeEX() + 2000;
			return true; 
		else 
			self.message = "No food! (or food not included in script_helper)";
			ClearTarget();
			return true; 
		end	
	end

	if ((localMana < 98 and IsDrinking()) or (localHealth < 98 and IsEating())) then
		self.message = "Resting to full hp/mana...";
		return true;
	end

	--if(localMana < self.drinkMana or localHealth < self.eatHealth) then
	--	if (IsMoving()) then
	--		StopMoving();
	--	end
	--	return true;
	--end

	if (not IsDrinking()) and (not IsEating()) then
		if (not IsStanding()) then
			JumpOrAscendStart();
		end
	end

	-- Don't need to rest
	return false;
end

function script_paladin:window()

	if (self.isChecked) then
	
		--Close existing Window
		EndWindow();

		if(NewWindow("Class Combat Options", 200, 200)) then
			script_paladin:menuEX();
		end
	end
end

function script_paladin:paladinPull(targetObj)
	-- Check: Exorcism
	if (targetObj:GetDistance() < 30) and (HasSpell("Exorcism")) and (not IsSpellOnCD("Exorcism")) then
		if (targetObj:GetCreatureType() == "Demon") or (targetObj:GetCreatureType() == "Undead") then
			if (Cast("Exorcism", targetObj)) then 
				self.message = "Pulling with Exocism...";
				return 0;
			end
		end
	end

	-- Check move into melee range
	if (targetObj:GetDistance() > self.meleeDistance) or (not targetObj:IsInLineOfSight()) then
		return 3;
	end
	
return;
end