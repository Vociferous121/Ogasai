script_druid = {
	message = 'Druid',
	menuIncluded = include("scripts\\combat\\script_druidEX.lua"),
	eatHealth = 60,
	drinkMana = 50,
	rejuvenationMana = 18,	-- use rejuvenation above this mana
	rejuvenationHealth = 80,	-- use rejuvenation below this health
	regrowthHealth = 60,
	healingTouchHealth = 45,
	healthToShift = 47,
	potionHealth = 12,
	potionMana = 20,
	isSetup = false,
	meleeDistance = 3.9,
	waitTimer = 0,
	stopIfMHBroken = true,
	useCat = false,	-- is cat form selected
	useBear = false,	-- is bear form selected
	isChecked = true,
	useEntanglingRoots = true,
	waitTimer = GetTimeEX(),
	useStealth = true,

}

function script_druid:setup()

	local isBear = GetLocalPlayer():HasBuff("Bear Form");
	local isCat = GetLocalPlayer():HasBuff("Cat Form");
	if (GetLocalPlayer():GetLevel() >= 40) then
		isBear = GetLocalPlayer():HasBuff("Dire Bear Form");
	end

	-- set entangle roots on startup
	if (not HasSpell("Entangling Roots")) then
		self.useEntanglingRoots = false;
	end

	if (HasSpell("Bear Form")) or (HasSpell("Dire Bear Form")) and (GetLocalPlayer():GetLevel() < 20) then
		self.useBear = true;
	elseif (HasSpell("Cat Form")) then
		self.useCat = true;
	end
	
	self.waitTimer = GetTimeEX();	

	self.isSetup = true;
end

function script_druid:getSpellCost(spell)
	_, _, _, _, cost, _, _ = GetSpellInfo(spell);
	return cost;
end

function script_druid:spellAttack(spellName, target)
	if (HasSpell(spellName)) then
		if (target:IsSpellInRange(spellName)) then
			if (not IsSpellOnCD(spellName)) then
				if (not IsAutoCasting(spellName)) then
					target:FaceTarget();
					return target:CastSpell(spellName);
				end
			end
		end
	end
	return false;
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
 	if targetObj ~= 0 then
 		local xT, yT, zT = targetObj:GetPosition();
 		local xP, yP, zP = localObj:GetPosition();
 		local distance = targetObj:GetDistance();
 		local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
 		local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 		local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;		
 		local moveX, moveY, moveZ = xT + xUV*10, yT + yUV*10, zT + zUV;		
 		if (distance < range and targetObj:IsInLineOfSight()) then 
			Move(moveX, moveY, moveZ);
 			return true;
 		end
	end
	return false;
end

function script_druid:draw()
	--script_druid:window();
	local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
	if (onScreen) then
		DrawText(self.message, tX+75, tY+40, 0, 255, 255);
	else
		DrawText(self.message, 25, 185, 0, 255, 255);
	end
end

--[[ error codes: 	0 - All Good , 
			1 - missing arg , 
			2 - invalid target , 
			3 - not in range, 
			4 - do nothing , 
			5 - targeted player pet/totem
			6 - stop bot request from combat script  ]]--




function script_druid:healsAndBuffs()

	local localHealth = GetLocalPlayer():GetHealthPercentage();
	local localMana = GetLocalPlayer():GetManaPercentage();
	local localLevel = GetLocalPlayer():GetLevel();
	local localObj = GetLocalPlayer();
	local isBear = GetLocalPlayer():HasBuff("Bear Form");
	local isCat = GetLocalPlayer():HasBuff("Cat Form");
	if (GetLocalPlayer():GetLevel() >= 40) then
		isBear = GetLocalPlayer():HasBuff("Dire Bear Form");
	end

	-- shapeshift out of bear form to use regrowth, then use healing touch
	if (self.useBear and isBear) and (localHealth <= self.healthToShift) and (localMana >= 25) then
		if (localObj:HasBuff("Dire Bear Form")) then
			CastSpellByName("Dire Bear Form");
			self.waitTimer = GetTimeEX() + 1500;
		end
		if (localObj:HasBuff("Bear Form")) then
			CastSpellByName("Bear Form");
			self.waitTimer = GetTimeEX() + 1500;
		end
		if (not localObj:HasBuff("Regrowth")) and (localHealth <= self.regrowthHealth) and (localMana > 40) then
			CastHeal("Regrowth", localObj);
			self.waitTimer = GetTimeEX() + 1500;
			return 0;
		end
		if (CastSpellByName("Healing Touch", localObj)) then
			self.waitTimer = GetTimeEX() + 2500;
			return 0;
		end
		if (HasSpell("Dire Bear Form")) then
			if (not localObj:HasBuff("Dire Bear Form")) then
				CastSpellByName("Dire Bear Form");
				selfwaitTimer = GetTimeEX() + 1500;
			end
		elseif (not localObj:HasBuff("Bear Form") and not HasSpell("Dire Bear Form")) then
			CastSpellByName("Bear Form");
			selfwaitTimer = GetTimeEX() + 1500;
		end
	end


	-- shapeshift out of cat form to use regrowth, then use healing touch
	if (self.useCat and isCat) and (localHealth <= self.healthToShift) and (localMana >= 25) then
		if (localObj:HasBuff("Cat Form")) then
			CastSpellByName("Cat Form");
			self.waitTimer = GetTimeEX() + 1500;
		end
		if (not localObj:HasBuff("Regrowth")) and (localHealth <= self.regrowthHealth) and (localMana > 40) then
			CastHeal("Regrowth", localObj);
			self.waitTimer = GetTimeEX() + 1500;
			return 0;
		end
		if (CastSpellByName("Healing Touch", localObj)) then
			self.waitTimer = GetTimeEX() + 2500;
			return 0;
		end
		if (HasSpell("Cat Form")) then
			if (not localObj:HasBuff("Cat Form")) then
				CastSpellByName("Cat Form");
				selfwaitTimer = GetTimeEX() + 1500;
			end
		end
	end

	
	-- redundancy check heals cat/bear checked but not is bear or not is cat HEALTH-TO-SHIFT CONTROL HEALS
	if (self.useBear or self.useCat) and (not isBear or not isCat) then

		-- Regrowth
		if (HasSpell("Regrowth")) and (not localObj:HasBuff("Regrowth")) and (localHealth <= self.healthToShift) and (localMana >= 40) then
			if (CastHeal("Regrowth", localObj)) then
				return 0;
			end
		end

		-- Rejuvenation
		if (HasSpell("Rejuvenation")) and (not localObj:HasBuff("Rejuvenation")) and (localHealth <= self.healthToShift) and (localMana >= self.rejuvenationMana) then
			if (CastHeal("Rejuvenation", localObj)) then
				self.waitTimer = GetTimeEX() + 1500;
				return 0;
			end
		end
	end

	-- if not is
	if (not isBear) and (not isCat) and (IsStanding()) and (not IsEating()) and (not IsDrinking()) then

		-- Healing Touch
		if (HasSpell("Healing Touch")) then
			if (localHealth < self.healingTouchHealth) and (localMana > 25) then
				if (CastHeal("Healing Touch", localObj)) then
					self.waitTimer = GetTimeEX() + 1500;
					return 0;
				end
			end
		end

		-- Regrowth
		if (HasSpell("Regrowth")) and (not localObj:HasBuff("Regrowth")) and (localHealth <= 55) and (localMana >= 40) then
			if (CastHeal("Regrowth", localObj)) then
				return 0;
			end
		end

		-- Rejuvenation
		if (HasSpell("Rejuvenation")) and (not localObj:HasBuff("Rejuvenation")) and (localHealth <= self.rejuvenationHealth) and (localMana >= self.rejuvenationMana) then
			if (CastHeal("Rejuvenation", localObj)) then
				self.waitTimer = GetTimeEX() + 1500;
				return 0;
			end
		end
		
		-- Mark of the Wild
		if (not IsInCombat()) and (localMana > 40) then
			if (HasSpell("Mark of the Wild")) and (not localObj:HasBuff("Mark of the Wild")) then
				CastSpellByName("Mark of the Wild", localObj);
				self.waitTimer = GetTimeEX() + 1700;
				return 4;
	
			end
		end

		-- Thorns
		if  (localMana > 30) then
			if (HasSpell("Thorns")) and (not localObj:HasBuff("Thorns")) then
				CastSpellByName("Thorns", localObj);
				self.waitTimer = GetTimeEX() + 1500;
				return 4;
			end
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
	local localRage = GetLocalPlayer():GetRagePercentage();
	local localEnergy = GetLocalPlayer():GetEnergyPercentage();
	local isBear = GetLocalPlayer():HasBuff("Bear Form");
	local isCat = GetLocalPlayer():HasBuff("Cat Form");
	if (GetLocalPlayer():GetLevel() >= 40) then
		isBear = GetLocalPlayer():HasBuff("Dire Bear Form");
	end

	if (localObj:IsDead()) then
		return 0; 
	end

	-- Assign the target 
	targetObj = GetGUIDObject(targetGUID);
	
	if(targetObj == 0 or targetObj == nil) then
		return 2;
	end

	-- Check: Do nothing if we are channeling or casting or wait timer
	if (IsChanneling() or IsCasting() or (self.waitTimer > GetTimeEX())) then
		return 4;
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
	
		if (not IsMoving() and targetObj:GetDistance() < 10) then
			if (not targetObj:FaceTarget()) then
				targetObj:FaceTarget();
			end
		end

		-- assign target health
		targetHealth = targetObj:GetHealthPercentage();

		-- Check: if we target player pets/totems
		if (GetTarget() ~= nil and targetObj ~= nil) then
			if (UnitPlayerControlled("target") and GetTarget() ~= localObj) then 
				script_grind:addTargetToBlacklist(targetObj:GetGUID());
				return 5; 
			end
		end 

		if (script_druid:healsAndBuffs()) then
			return;
		end
		
		----------
		----- OPENER 
		---------

		-- Opener
		if (not IsInCombat()) then
			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";

			-- Auto Attack
			if (targetObj:GetDistance() <= 40) and (not IsMoving()) then
				targetObj:AutoAttack();
			elseif (targetObj:GetDistance() <= 30) and (targetObj:IsInLineOfSight()) then
				targetObj:AutoAttack();
			end

			if (self.useCat) and (isCat) and (self.useStealth) and (HasSpell("Prowl")) and (not IsSpellOnCD("Prowl")) and (not localObj:HasBuff("Prowl")) then
				CastSpellByName("Prowl");
				self.waitTimer = GetTimeEX() + 1500;
				return 0;
			end

			if (not self.useBear) and (not self.useCat) and (not isBear) and (not isCat) and (targetObj:GetDistance() > 27) then
				return 3;
			end
			if (isBear or isCat) and (self.useBear or self.useCat) and (targetObj:GetDistance() > self.meleeDistance) then
				return 3;
			end

			-- Dismount
			if (IsMounted()) and (targetObj:GetDistance() < 25) then 
				DisMount(); 
				return 4; 
			end

			----
	-- pull in form
			----




	-- pull bear form
			------

			-- stay in form
			-- not in bear form and conditions right then stay in bear form
		if (not isBear) and (self.useBear) and (localHealth >= self.healthToShift) and (localMana >= self.drinkMana) then
			if (HasSpell("Dire Bear Form")) then
				CastSpellByName("Dire Bear Form");
				self.waitTimer = GetTimeEX() + 1500;
				return 0;
			elseif (HasSpell("Bear Form")) then
				CastSpellByName("Bear Form");
				self.waitTimer = GetTimeEX() + 1500;
				return 0;
			end
		end
		
		if (self.useBear) and (isBear) and (not self.useCat) and (not isCat) then

			-- faerie fire
			if (HasSpell("Faerie Fire (Feral)")) and (not targetObj:HasDebuff("Faerie Fire")) then
				if Cast("Faerie Fire (Feral)", targetObj) then
					self.waitTimer = GetTimeEX() + 1500;
					return 0;
				end
			end

			-- Enrage
			if (HasSpell("Enrage")) and (not IsSpellOnCD("Enrage")) then
				if (CastSpellByName("Enrage")) then
					return 0;
				end
			end

			-- Demoralizing Roar
			if (HasSpell("Demoralizing Roar")) and (not targetObj:HasBuff("Demoralizing Roar")) and (localRage > 10) then
				if (CastSpellByName("Demoralizing Roar")) then
					return 0;
				end
			end
		end


	-- end of bear form pulling




	-- pull cat form
			------

		-- stay in form
		-- not in cat form and conditions right then stay in bear form
		if (not isCat) and (self.useCat) and (localHealth >= self.healthToShift) and (localMana >= self.drinkMana) then
			if (HasSpell("Cat Form")) then
				CastSpellByName("Cat Form");
				self.waitTimer = GetTimeEX() + 1500;
				return 0;
			end
		end

			
		if (self.useCat) and (isCat) and (not self.useBear) and (not isBear) then

			-- faerie fire
			if (not self.useStealth) and (HasSpell("Faerie Fire (Feral)")) and (not targetObj:HasDebuff("Faerie Fire")) then
				if Cast("Faerie Fire (Feral)", targetObj) then
					self.waitTimer = GetTimeEX() + 1500;
					return 0;
				end
			end

			if (HasSpell("Tiger's Fury")) and (not localObj:HasBuff("Tiger's Fury")) and (not IsSpellOnCD("Tiger's Fury")) and (localEnergy > 30) then
				if (CastSpellByName("Tiger's Fury")) then
					return 0;
				end
			end
		end



	-- end of cat form pulling



			----
	-- pull no form
	-- or level less than 10
			----

		if (not self.useBear) and (not isBear) and (not self.useCat) and (not isCat) then

			-- Wrath to pull if no moonfire spell
			if (not HasSpell("Moonfire")) and (localMana >= 35) then
				CastSpellByName("Wrath", targetObj);
				targetObj:FaceTarget();
				self.message = "Casting Wrath!";
				return 0; -- keep trying until cast
			end

			-- use moonfire to pull if has spell
			if (HasSpell("Moonfire")) and (localMana >= 35) and (not targetObj:HasDebuff("Moonfire")) then
				CastSpellByName("Moonfire", targetObj);
				targetObj:FaceTarget();
				return 0;
			end
			
			-- Entangling roots when target is far enough away and we have enough mana
			if (not self.useBear) and (not self.useCat) and (self.useEntanglingRoots) then
				if (HasSpell("Entangling Roots")) and (not targetObj:HasDebuff("Enatangle Roots")) and (localMana > 45) then
					if (Cast("Entangling Roots", targetObj)) then
						return 0;
					end
				end
			end
			
			-- move into line of sight
			if (targetObj:GetDistance() > 30) or (not targetObj:IsInLineOfSight()) then
				return 3;
			end
		end

	-- end of pulling not in combat phase





	-- Combat -- start of combat phase! in combat!

	-- IN COMBAT

	-- IN COMBAT


		else	


			self.message = "Killing " .. targetObj:GetUnitName() .. "...";


			if (script_druid:healsAndBuffs()) then
				return;
			end


	-- attacks in bear form IN COMBAT PHASE

			-- stay in form
			if (self.useBear) and (not isBear) and (not self.useCat) and (not isCat) and (localHealth + 10 >= self.healthToShift) then
				CastSpellByName("Bear Form");
				self.waitTimer = GetTimeEX() + 1500;
			end

			-- do these attacks only in bear form
			if (self.useBear) and (isBear) and (not isCat) and (not self.useCat) then

				-- Run backwards if we are too close to the target
				if (targetObj:GetDistance() <= .5) then 
					if (script_druid:runBackwards(targetObj,2)) then 
						return 4; 
					end 
				end

				-- keep auto attack on
				if (not IsAutoCasting("Attack")) then
					targetObj:AutoAttack();
				end
				
				-- keep faerie fire up
				if (HasSpell("Faerie Fire (Feral)")) and (not targetObj:HasDebuff("Faerie Fire (Feral)")) and (not IsSpellOnCD("Faerie Fire (Feral)")) then
					if (Cast("Faerie Fire (Feral)", targetObj)) then
						return 0;
					end
				end

				-- demo Roar
				if (script_druid:enemiesAttackingUs(10) >= 2) then
					if (HasSpell("Demoralizing Roar")) and (not targetObj:HasDebuff("Demoralizing Roar")) and (localRage > 10) then
						if (CastSpellByName("Demoralizing Roar")) then
							return 0;
						end
					end
				end

				-- Swipe
				if (script_druid:enemiesAttackingUs(10) >= 2) then
					if (HasSpell("Swipe")) and (not targetObj:HasDebuff("Swipe")) and (localRage > 15) then
						if (CastSpellByName("Swipe")) then
							return 0;
						end
					end
				end

				-- maul
				if (HasSpell("Maul")) and (localRage > 15) then
					if (Cast("Maul", targetObj)) then
						return 0;
					end
				end

			end -- end of bear form in combat attacks



	-- attacks in cat form IN COMBAT PHASE

			--stay in form
			if (self.useCat) and (not isCat) and (not self.useBear) and (not isBear) and (localHealth + 10 >= self.healthToShift) then
				CastSpellByName("Cat Form");
				self.waitTimer = GetTimeEX() + 1500;
			end

			-- do these attacks only in cat form
			if (self.useCat) and (isCat) and (not self.useBear) and (not isBear) then

				-- Run backwards if we are too close to the target
				if (targetObj:GetDistance() <= .5) then 
					if (script_druid:runBackwards(targetObj,2)) then 
						return 4; 
					end 
				end

				-- keep auto attack on
				if (not IsAutoCasting("Attack")) then
					targetObj:AutoAttack();
				end

				-- keep faerie fire up
				if (HasSpell("Faerie Fire (Feral)")) and (not targetObj:HasDebuff("Faerie Fire (Feral)")) and (not IsSpellOnCD("Faerie Fire (Feral)")) then
					if (Cast("Faerie Fire (Feral)", targetObj)) then
						return 0;
					end
				end
				
				-- keep tiger's fury up
				if (HasSpell("Tiger's Fury")) and (not localObj:HasBuff("Tiger's Fury")) and (not IsSpellOnCD("Tiger's Fury")) and (localEnergy > 30) then
					if (CastSpellByName("Tiger's Fury")) then
						return 0;
					end
				end





			end



	-- attacks when not in form

		-- no bear form or cat form

			if (not self.useBear) and (not isBear) and (not self.useCat) and (not isCat) then
			
				-- Run backwards if we are too close to the target
				if (targetObj:GetDistance() <= .5) then 
					if (script_druid:runBackwards(targetObj,2)) then 
						return 4; 
					end 
				end

				-- Check: Move backwards if the target is affected by Entangling Root
				if (self.useEntanglingRoots) then
					if (not targetObj:HasDebuff("Entangling Roots")) and (not localObj:HasDebuff("Web")) and (not localObj:HasDebuff("Encasing Webs")) and (localMana > 65) and (targetHealth >= 35) then
					script_grind.tickRate = 287;
					script_rotation.tickRate = 269;
						if (not targetObj:HasDebuff("Entangling Roots")) then
							CastSpellByName("Entangling Roots");
							return 4;
						end
					end 
				end	

				if (targetObj:HasDebuff("Entangling Roots")) and (localMana > 25) then
					if (script_druid:runBackwards(targetObj, 2)) then
						self.waitTimer = GetTimeEX() + 900;
					return 4;
					end
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

				if (script_druid:healsAndBuffs()) then
					return;
				end

				-- War Stomp Tauren Racial
				if (HasSpell("War Stomp")) and (not IsSpellOnCD("War Stomp")) and (targetObj:IsCasting() or script_druid:enemiesAttackingUs(10) >= 2) and (not IsMoving()) then
					CastSpellByName("War Stomp");
					self.waitTimer = GetTimeEX() + 200;
					return 0;
				end

				-- keep moonfire up
				if (localMana > 30) and (targetHealth > 5) and (not targetObj:HasDebuff("Moonfire")) then
					if (Cast("Moonfire", targetObj)) then
						return 0;
					end
				end

				-- spam moonfire until target is killed
				if (localMana > 30) and (targetHealth < 10) and (not IsSpellOnCD("Moonfire")) then
					if (Cast("Moonfire", targetObj)) then
						return 0;
					end
				end

				-- Wrath
				if (localMana > 30) and (targetHealth > 15) then
					if (Cast("Wrath", targetObj)) then
						return 0;
					end
				end	
			end -- end of if not bear or cat... no form attacks

			if (targetObj:HasDebuff("Entangling Roots")) and (localMana > 15) then
				CastSpellByName("Wrath");
				self.waitTimer = GetTimeEX() + 1200;
			end

			-- auto attack condition for melee
			if (localMana <= 35) or (self.useBear) or (self.useCat) or (isBear) or (isCat) then
				if (targetObj:GetDistance() <= self.meleeDistance) then
					if (not targetObj:FaceTarget()) then
						targetObj:FaceTarget();
					end
					targetObj:AutoAttack();
				elseif (not targetObj:HasDebuff("Entangling Roots")) then
					return 3;
				end
			end

		end -- end of else combat phase
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

	local isBear = GetLocalPlayer():HasBuff("Bear Form");

	local isCat = GetLocalPlayer():HasBuff("Cat Form");

	if (GetLocalPlayer():GetLevel() >= 40) then
		isBear = GetLocalPlayer():HasBuff("Dire Bear Form");
	end

	if (script_druid:healsAndBuffs()) then
		return;
	end
	
	if (not IsMoving()) and (not IsInCombat()) then
		ClearTarget();
	end

	-- Drink something
	if (not isBear) and (not isCat) then
		if (not IsDrinking() and localMana < self.drinkMana) then
			self.waitTimer = GetTimeEX() + 3500;
			self.message = "Need to drink...";
			if (IsMoving()) then
				StopMoving();
				return true;
			end
				self.waitTimer = GetTimeEX() + 3500;

			if (script_helper:drinkWater()) then 
				self.waitTimer = GetTimeEX() + 1500;
				self.message = "Drinking..."; 
				return true; 
			else 
				self.message = "No drinks! (or drink not included in script_helper)";
				ClearTarget();
				return true; 
			end
		end
	end

	-- Eat something
	if (not isBear) and (not isCat) then
		if (not IsEating() and localHealth < self.eatHealth) then
			self.waitTimer = GetTimeEX() + 3500;
			self.message = "Need to eat...";
			if (IsInCombat()) then
				return true;
			end
			
			if (IsMoving()) then
				StopMoving();
				return true;
			end

				self.waitTimer = GetTimeEX() + 3500;

			if (script_helper:eat()) then 
				self.waitTimer = GetTimeEX() + 1500;
				self.message = "Eating..."; 
				return true; 
			else 
				self.message = "No food! (or food not included in script_helper)";
				ClearTarget();
				return true; 
			end		
		end
	end

	-- Continue resting
	if(localHealth < 98 and IsEating() or localMana < 98 and IsDrinking()) then
		ClearTarget();
		self.message = "Resting up to full HP/Mana...";
		return true;
	end
		
	-- Stand up if we are rested
	if (localHealth > 98 and (IsEating() or not IsStanding()) 
	    and localMana > 98 and (IsDrinking() or not IsStanding())) then
		StopMoving();
		return false;
	end

	-- rest in form
	if (self.useBear and isBear) or (self.useCat and isCat) then
		if (localMana <= 50) and (not IsInCombat()) then
			if (IsMoving()) then
				StopMoving();
			end
			self.message = "Low mana and shapeshifted! Waiting!";
			return true;
		end
	end

	-- Don't need to rest
	return false;
end

function script_druid:mount()
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
