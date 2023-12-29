script_paladin = {
	message = "Paladin Combat Script",
	paladinMenu = include("scripts\\combat\\script_paladinEX.lua"),
	isSetup = false,
	isChecked = true,
	stopIfMHBroken = true,
	useFlashOfLightCombat = false,
	aura = "Devotion Aura",
	blessing = "Blessing of Wisdom",
	waitTimer = 0,
	eatHealth = 30,
	drinkMana = 35,
	shieldHealth = 16,
	lohHealth = 12,
	holyLightHealth = 45,
	flashOfLightHP = 70,
	potionHealth = 15,
	potionMana = 20,
	consecrationMana = 50,
	meleeDistance = 3.85,
	useSealOfCrusader = true,
	useJudgement = true,
	useFlashOfLightCombat = false,
	useBubbleHearth = true,
}

function script_paladin:setup()
	if (not HasSpell("Retribution Aura")) and (not HasSpell("Sanctity Aura")) and (not localObj:HasBuff("Stoneskin")) then
		self.aura = "Devotion Aura";	
	elseif (not HasSpell("Sanctity Aura")) and (HasSpell("Retribution Aura")) then
		self.aura = "Retribution Aura";
	elseif (HasSpell("Sanctity Aura")) then
		self.aura = "Sanctity Aura";	
	end
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
	-- set bubble hearth false if no divine shield
	if (not HasSpell("Divine Shield")) then
		self.useBubbleHearth = false;
	end
	self.waitTimer = GetTimeEX();
	self.isSetup = true;
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
 		local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;		
 		local moveX, moveY, moveZ = xT + xUV*5, yT + yUV*5, zT + zUV;		
 		if (distance <= range) then 
 			Move(moveX, moveY, moveZ);
			self.waitTimer = GetTimeEX() + 750;
 			return true;
 		end
	end
	return false;
end

function script_paladin:draw()
	local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
	if (onScreen) then
		if (script_grind.adjustText) and (script_grind.drawEnabled) then
			tX = tX + script_grind.adjustX;
			tY = tY + script_grind.adjustY;
		end
	DrawText(self.message, tX+230, tY+9, 255, 250, 205);
	else
		if (script_grind.adjustText) and (script_grind.drawEnabled) then
			tX = tX + script_grind.adjustX;
			tY = tY + script_grind.adjustY;
		end
	DrawText(self.message, 25, 185, 255, 250, 205);
	end
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

	if (script_paladinEX:healsAndBuffs(localObj, localMana)) then
		return true;
	end
	-- Check: Do nothing if we are channeling or casting or wait timer
	if (IsChanneling()) or (IsCasting()) or (self.waitTimer > GetTimeEX()) then
		return 4;
	end

	if (IsInCombat()) and (GetLocalPlayer():GetUnitsTarget() == 0) then
		self.message = "Waiting! Stuck in combat phase!";
		return 4;
	end

	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then
		local tickRandom = random(450, 800);
		if (IsMoving()) or (not IsInCombat()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom
		elseif (IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		end
	end

	-- dismount before combat
	if (IsMounted()) then
		DisMount();
	end
	--Valid Enemy
	if (targetObj ~= 0) and (not localObj:IsStunned()) then

		if (IsInCombat()) and (script_grind.skipHardPull) and (GetNumPartyMembers() == 0) then
			if (script_checkAdds:checkAdds()) then
				script_om:FORCEOM();
				return true;
			end
		end

		-- Cant Attack dead targets
		if (targetObj:IsDead()) or (not targetObj:CanAttack()) then
			self.waitTimer = GetTimeEX() + 1200;
			return 0;
		end
		
		if (not IsStanding()) and (not IsEating()) and (not IsDrinking()) then
			JumpOrAscendStart();
		end

		if (targetObj:GetDistance() <= 8) and (not IsMoving()) then
			if (not targetObj:FaceTarget()) then
				targetObj:FaceTarget();
			end
		end

		-- Auto Attack
		if (targetObj:GetDistance() < 40) and (not IsAutoCasting("Attack")) then
			targetObj:AutoAttack();
		end
	
		targetHealth = targetObj:GetHealthPercentage();

		-- Check: if we target player pets/totems
		if (GetTarget() ~= 0) then
			if (GetTarget():GetGUID() ~= GetLocalPlayer():GetGUID()) then
				if (UnitPlayerControlled("target")) then 
					script_grind:addTargetToBlacklist(targetObj:GetGUID());
					return 5; 
				end
			end
		end 
		
		-- Opener

		if (not IsInCombat()) then

			self.targetObjGUID = targetObj:GetGUID();

			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";
	
			-- Dismount
			if (IsMounted()) and (targetObj:GetDistance() < 25) then
				DisMount(); 
				return 0;
			 end

			if (script_paladinEX:healsAndBuffs(localObj, localMana)) then
				return true;
			end

			-- Check move into melee range
			if (targetObj:GetDistance() > self.meleeDistance) or (not targetObj:IsInLineOfSight()) then
				return 3;
			end

			-- Check: Exorcism
			if (targetObj:GetDistance() < 30) and (HasSpell("Exorcism")) and (not IsSpellOnCD("Exorcism")) then
				if (targetObj:GetCreatureType() == "Demon") or (targetObj:GetCreatureType() == "Undead") then
					if (Cast("Exorcism", targetObj)) then 
						self.message = ("Pulling with Exocism...");
						return 0;
					end
				end
			end

			if (targetObj:GetDistance() <= self.meleeDistance) then
				if (not IsAutoCasting("Attack")) then
					targetObj:AutoAttack();
				end
				if (not IsMoving()) then
					targetObj:FaceTarget();
				end
			end

				
		-- Combat WE ARE NOW IN COMBAT

		else	

			if (not IsAutoCasting("Attack")) and (not IsMoving()) then
				targetObj:AutoAttack();
				targetObj:FaceTarget();
			end

			-- Check move into melee range
			if (targetObj:GetDistance() > self.meleeDistance) or (not targetObj:IsInLineOfSight()) then
				return 3;
			end

			self.message = "Killing " .. targetObj:GetUnitName() .. "...";

			-- Dismount
			if (IsMounted()) then 
				DisMount();
			end

			if (not targetObj:IsFleeing()) and (targetObj:GetDistance() < self.meleeDistance) then
				if (IsMoving()) then
					StopMoving();
				end
			end

			if (not targetObj:IsFleeing()) and (localMana > 8) then
				if (script_paladinEX:healsAndBuffs(localObj, localMana)) then
					return true;
				end
			end

			-- Run backwards if we are too close to the target
			if (targetObj:GetDistance() < .2) then 
				if (script_paladin:runBackwards(targetObj,2)) then 
					JumpOrAscendStart();
					targetObj:FaceTarget();
					return 4; 
				end 
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

			if (script_paladinEX:healsAndBuffs()) then
				return true;
			end

			-- dwarf stone form racial
			if (HasSpell("Stoneform")) and (not IsSpellOnCD("Stoneform")) and (IsInCombat()) and (targetHealth >= 35) and (localHealth >= 15) then
				CastSpellByName("Stoneform");
				self.waitTimer = GetTimeEX() + 1550;
				return 0;
			end

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

			-- Check: Seal of the Crusader until we use judgement
			if (self.useSealOfCrusader) and (not targetObj:HasDebuff("Judgement of the Crusader")) and (targetObj:GetDistance() < 15) and (not localObj:HasBuff("Seal of the Crusader")) and localMana > 15 and (not IsSpellOnCD("Judgement")) and (targetObj:GetHealthPercentage() > 25) then
				if (Cast("Seal of the Crusader", targetObj)) then
					return 0;
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
			-- in melee range
			if (targetObj:GetDistance() <= self.meleeDistance) then

				
				if (not targetObj:IsFleeing()) and (localMana > 8) then
					if (script_paladinEX:healsAndBuffs(localObj, localMana)) then
						return true;
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
				if (HasSpell("Consecration")) and (not IsSpellOnCD("Consecration")) and (localMana >= self.consecrationMana) then
					if (script_grind:enemiesAttackingUs() >= 2) then
						CastSpellByName("Consecration"); self.waitTimer = GetTimeEX() + 1500;
 						return 0;	
					end
				end

				if (targetObj:IsFleeing()) and (not script_grind.adjustTickRate) then
					script_grind.tickRate = 50;
				end
			end
		end
	end
end

function script_paladin:rest()

	if (GetLocalPlayer():GetHealthPercentage() <= self.eatHealth) and (not IsInCombat()) then
		ClearTarget();
	end

	if(not self.isSetup) then
		script_paladin:setup();
	end
	
	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(450, 800);

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
	if (IsStanding()) and (not IsEating()) and (not IsDrinking()) and (not IsMoving()) and (not IsInCombat()) and (localMana > 8) then
		if (script_paladinEX:healsAndBuffs(localObj, localMana)) then
			return true;
		end
	end

	-- Stop moving before we can rest
	if (localHealth <= self.eatHealth or localMana <= self.drinkMana) and (not IsEating()) and (not IsDrinking()) then
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
	if (IsDrinking()) and (not IsEating()) and (localHealth <= 65) then
		if (script_helper:eat()) then 
			self.message = "Eating..."; 
			self.waitTimer = GetTimeEX() + 2000;
			return true; 
		end
	end
	if (IsEating()) and (not IsDrinking()) and (localMana <= 65) then
		if (script_helper:drink()) then 
			self.message = "Drinking..."; 
			self.waitTimer = GetTimeEX() + 2000;
			return true; 
		end
	end		
	-- rest to full mana/health when eating/drinking
	if ((localMana < 98 and IsDrinking()) or (localHealth < 98 and IsEating())) then
		self.message = "Resting to full hp/mana...";
		return true;
	end

-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then
		local tickRandom = random(450, 800);
		if (IsMoving()) or (not IsInCombat()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom
		elseif (IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		end
	end
	-- Don't need to rest
	return false;
end

function script_paladin:window()
	if (self.isChecked) then
		EndWindow();
		if(NewWindow("Class Combat Options", 200, 200)) then
			script_paladin:menuEX();
		end
	end
end