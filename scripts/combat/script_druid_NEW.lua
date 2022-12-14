script_druid = {
	message = 'Druid - Feral',
	eatHealth = 60,
	drinkMana = 50,
	rejuvenationMana = 15,	-- use rejuvenation above this mana
	rejuvenationHealth = 85,	-- use rejuvenation below this health
	regrowthHealth = 60,
	healingTouchHealth = 38,
	healthToShift = 40, -- health to shapeshift out of form to heal
	potionHealth = 12,
	potionMana = 20,
	isSetup = false,
	meeleDistance = 5,
	waitTimer = 0,
	stopIfMHBroken = true,
	cat = false,	-- is cat form selected
	bear = false,	-- is bear form selected
	isCat = false,	-- is in cat form
	isBear = false,	-- is in bear form
	isChecked = true,
	pullWithWrath = true,
	pullWithMoonfire = false,
	useEntanglingRoots = true,

}

function script_druid:setup()
	--Sort forms
	if (not HasSpell("Cat Form") and not HasSpell("Bear Form")) then
		self.cat = false;
		self.bear = false;
	end

	-- set entangle roots on startup
	if (not HasSpell("Entangling Roots")) then
		self.useEntanglingRoots = false;
	end

	-- turn pull spells off automatically if have form spells
	if (HasSpell("Bear Form") or HasSpell("Cat Form") or HasSpell("Dire Bear Form")) then
		self.pullWithWrath = false;
		self.pullWithMoonfire = false;
	end

	-- sort forms redundant checkbox
	if (localObj:HasBuff("Bear Form")) or (localObj:HasBuff("Dire Bear Form")) then
		self.isBear = true;
		self.isCat = false;
	end

	-- sort forms redundant checkbox
	if localObj:HasBuff("Cat Form") then
		self.isCat = true;
		self.isBear = false;
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
 		local moveX, moveY, moveZ = xT + xUV*5, yT + yUV*5, zT + zUV;		
 		if (distance < range) then 
 			Move(moveX, moveY, moveZ);
			self.waitTimer = GetTimeEX() + 1500;
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
	
	-- sort forms redundant checkbox
	if (localObj:HasBuff("Bear Form")) or (localObj:HasBuff("Dire Bear Form")) then
		isBear = true;
		isCat = false;
	end

	-- sort forms redundant checkbox
	if localObj:HasBuff("Cat Form") then
		isCat = true;
		isBear = false;
	end

	--Valid Enemy
	if (targetObj ~= 0) then
		
		-- Cant Attack dead targets
		if (targetObj:IsDead() or not targetObj:CanAttack()) then
			return 0;
		end

		-- stand up if sitting
		if (not IsStanding()) then
			JumpOrAscendStart();
		end
	
		if (not IsMoving() and targetObj:GetDistance() < 10) then
			targetObj:FaceTarget();
		end

		-- assign target health
		targetHealth = targetObj:GetHealthPercentage();

		-- Auto Attack
		if (targetObj:GetDistance() <= 40) then
			targetObj:AutoAttack();
		end

		-- Check: if we target player pets/totems
		if (GetTarget() ~= nil and targetObj ~= nil) then
			if (UnitPlayerControlled("target") and GetTarget() ~= localObj) then 
				script_grind:addTargetToBlacklist(targetObj:GetGUID());
				return 5; 
			end
		end 
		
		----------
		----- OPENER 
		---------

		-- sort forms redundant checkbox
		if (localObj:HasBuff("Bear Form")) or (localObj:HasBuff("Dire Bear Form")) then
			self.isBear = true;
			self.isCat = false;
		else 
			self.isBear = false;
		end

		-- sort forms redundant checkbox
		if localObj:HasBuff("Cat Form") then
			isCat = true;
			isBear = false;
		end

		-- Opener
		if (not IsInCombat()) then
			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";

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
			if (self.bear) and (not self.isBear) and (not localObj:HasBuff("Bear Form") and not localObj:HasBuff("Dire Bear Form")) and (localHealth >= self.healthToShift) then
				if (HasSpell("Dire Bear Form")) then
					if (CastSpellByName("Dire Bear Form")) then
						self.waitTimer = GetTimeEX() + 1500;
						return 0;
					end
				elseif (HasSpell("Bear Form")) then
					if (CastSpellByName("Bear Form")) then
						self.waitTimer = GetTimeEX() + 1500;
						return 0;
					end
				end
			end

			-- faerie fire
			if (self.isBear) then
				if (HasSpell("Faerie Fire (Feral)")) and (not targetObj:HasDebuff("Faerie Fire")) then
					if Cast("Faerie Fire (Feral)", targetObj) then
						self.waitTimer = GetTimeEX() + 1500;
						return 0;
					end
				end
			end

			-- Enrage
			if (self.isBear) then
				if (HasSpell("Enrage")) and (not IsSpellOnCD("Enrage")) then
					if (CastSpellByName("Enrage")) then
						return 0;
					end
				end
			end

			-- Demoralizing Roar
			if (self.isBear) then
				if (HasSpell("Demoralizing Roar")) and (not targetObj:HasBuff("Demoralizing Roar")) and (localRage > 10) then
					if (CastSpellByName("Demoralizing Roar")) then
						return 0;
					end
				end
			end

			-- sort forms redundant checkbox
			if (localObj:HasBuff("Bear Form")) or (localObj:HasBuff("Dire Bear Form")) then
				isBear = true;
				isCat = false;
			end

			-- sort forms redundant checkbox
			if localObj:HasBuff("Cat Form") then
				isCat = true;
				isBear = false;
			end

			-- pull cat form
			------

			-- faerie fire
			if (self.isCat) then
				if (HasSpell("Faerie Fire (Feral)")) and (not targetObj:HasDebuff("Faerie Fire")) then
					if Cast("Faerie Fire (Feral)", targetObj) then
						self.waitTimer = GetTimeEX() + 1500;
						return 0;
					end
				end
			end

			if (self.isCat) then
				if (HasSpell("Tiger's Fury")) and (not localObj:HasBuff("Tiger's Fury")) and (not IsSpellOnCD("Tiger's Fury")) and (localEnergy > 30) then
					if (CastSpellByName("Tiger's Fury")) then
						return 0;
					end
				end
			end

			----
			-- pull no form
			----

			-- Wrath to pull if not in bear or cat form
			if (not isBear or not isCat) then
				if (self.pullWithWrath) and (HasSpell("Wrath")) and (localMana >= 35) and (not IsSpellOnCD("Wrath")) then
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					if (Cast("Wrath", targetObj)) then
						self.waitTimer = GetTimeEX() + 1500;
						self.message = "Casting Wrath!";
						return 0; -- keep trying until cast
					end
					-- Entangling roots when target is far enough away and we have enough mana
					if (self.useEntanglingRoots) then
						if (HasSpell("Entangling Roots")) and (not targetObj:HasDebuff("Enatangle Roots")) and (localMana > 45) and (targetObj:GetDistance() > 12) then
							if (Cast("Entangling Roots", targetObj)) then
								return 0;
							end
						end
					end
					-- Moonfire to pull if not in bear or cat form
				elseif (self.pullWithMoonfire) and (HasSpell("Moonfire")) and (localMana >= 25) and (not IsSpellOnCD("Moonfire")) and (not targetObj:HasDebuff("Moonfire")) then
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					if (Cast("Moonfire", targetObj)) then
						self.waitTimer = GetTimeEX() + 1500;
						self.message = "Casting Moonfire!";
						return 0; -- keep trying until cast
					end
					-- Entangling roots when target is far enough away and we have enough mana
					if (self.useEntanglingRoots) then
						if (HasSpell("Entangling Roots")) and (not targetObj:HasDebuff("Enatangle Roots")) and (localMana > 45) and (targetObj:GetDistance() > 12) then
							if (Cast("Entangling Roots", targetObj)) then
								return 0;
							end
						end
					end
				end
			end

			-- move into line of sight
			if (targetObj:GetDistance() > 30 or not targetObj:IsInLineOfSight()) then
				return 3;
			end

			targetObj:FaceTarget();
		-- Combat
		else	
			self.message = "Killing " .. targetObj:GetUnitName() .. "...";

			-- sort forms redundant checkbox
			if (localObj:HasBuff("Bear Form")) or (localObj:HasBuff("Dire Bear Form")) then
				isBear = true;
				isCat = false;
			end

			-- sort forms redundant checkbox
			if localObj:HasBuff("Cat Form") then
				isCat = true;
				isBear = false;
			end

			-- heals in forms
			-- Regrowth
			if (HasSpell("Regrowth")) and (self.isBear) and (localHealth <= self.healHealthWhenShifted) and (localObj:HasBuff("Bear Form") or localObj:HasBuff("Dire Bear Form")) then
				if (localObj:HasBuff("Dire Bear Form")) then
					if (CastSpellByName("Dire Bear Form") and not localObj:HasBuff("Dire Bear Form")) then
						selfwaitTimer = GetTimeEX() + 1500;
					end
				end
				if (localObj:HasBuff("Bear Form")) then
					if (CastSpellByName("Bear Form") and not localObj:HasBuff("Bear Form")) then
						selfwaitTimer = GetTimeEX() + 1500;
					end
				end
				if (not localObj:HasBuff("Regrowth")) and (localHealth < self.regrowthHealth) and (localMana > 40) then
					if (CastHeal("Regrowth", localObj)) then
						return 0;
					end
				end
				if (HasSpell("Dire Bear Form")) then
					if (not localObj:HasBuff("Dire Bear Form")) then
						if (CastSpellByName("Dire Bear Form") and not localObj:HasBuff("Dire Bear Form")) then
							selfwaitTimer = GetTimeEX() + 1500;
						end
					end
				elseif (not localObj:HasBuff("Bear Form") and not HasSpell("Dire Bear Form")) then
					if (CastSpellByName("Bear Form") and not localObj:HasBuff("Bear Form")) then
						selfwaitTimer = GetTimeEX() + 1500;
					end
				end
			end

				-- Healing Touch
				if (HasSpell("Healing Touch")) then
					if (localHealth < self.healingTouchHealth) and (localMana > 30) then
						if (CastHeal("Healing Touch", localObj)) then
							return 0;
						end
					end
				end

				-- Rejuvenation
				if (HasSpell("Rejuvenation")) then
					if (not localObj:HasBuff("Rejuvenation")) and (localHealth < self.rejuvenationHealth) and (localMana > self.rejuvenationMana) then
						if (CastHeal("Rejuvenation", localObj)) then
							return 0;
						end
					end
				end

			-- attacks in bear form
			if (isBear and not isCat) and (localObj:HasBuff("Bear Form") or localObj:HasBuff("Dire Bear Form")) and (not localObj:HasBuff("Cat Form")) then

				-- Run backwards if we are too close to the target
				if (targetObj:GetDistance() <= .5) then 
					if (script_druid:runBackwards(targetObj,2)) then 
						return 4; 
					end 
				end
				
				-- keep faerie fire up
				if (HasSpell("Faerie Fire (Feral)")) and (not targetObj:HasDebuff("Faerie Fire (Feral)")) and (not IsSpellOnCD("Faerie Fire (Feral)")) then
					if (Cast("Faerie Fire (Feral)", targetObj)) then
						return 0;
					end
				end

				-- demo Roar
				if (script_druid:enemiesAttackingUs(6) >=2) then
					if (HasSpell("Demoralizing Roar")) and (not targetObj:HasDebuff("Demoralizing Roar")) and (localRage > 10) then
						if (CastSpellByName("Demoralizing Roar")) then
							return 0;
						end
					end
				end

				-- Swipe
				if (script_druid:enemiesAttackingUs(6) >=2) then
					if (HasSpell("Swipe")) and (not targetObj:HasDebuff("Swipe")) and (localRage > 15) then
						if (CastSpellByName("Swipe")) then
							return 0;
						end
					end
				end

				if (HasSpell("Maul")) and (localRage > 10) then
					if (Cast("Maul", targetObj)) then
						return 0;
					end
				end
			end

			-- attacks in cat form
			if (isCat) and (not isBear) and (localObj:HasBuff("Cat Form") and (not localObj:HasBuff("Dire Bear Form") or not localObj:HasBuff("Bear Form"))) then
				return true;
			end

			-- attacks when not in form

			if (not isBear and not isCat) then
			
				-- Run backwards if we are too close to the target
				if (targetObj:GetDistance() <= .5) then 
					if (script_druid:runBackwards(targetObj,2)) then 
						return 4; 
					end 
				end

				-- run backwards if target affected by Entangling roots and low health
				if (localHealth < 50) and (targetObj:HasDebuff("Entangling Roots")) and (targetObj ~= 0) and (IsInCombat()) then
					if (script_druid:runBackwards(targetObj, 13)) then -- Moves if the target is closer than 7 yards
						self.message = "Moving away from target...";
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

				---
				---
				-- heals before trying to attack!
					-- better to do this in each form instead of a function but can be changed.
						-- this was just quicker and easier in my opinion and more direct

				-- Regrowth
				if (HasSpell("Regrowth")) then
					if (not localObj:HasBuff("Regrowth")) and (localHealth < self.regrowthHealth) and (localMana > 40) then
						if (CastHeal("Regrowth", localObj)) then
							return 0;
						end
					end
				end

				-- Healing Touch
				if (HasSpell("Healing Touch")) then
					if (localHealth < self.healingTouchHealth) and (localMana > 30) then
						if (CastHeal("Healing Touch", localObj)) then
							return 0;
						end
					end
				end

				-- Rejuvenation
				if (HasSpell("Rejuvenation")) then
					if (not localObj:HasBuff("Rejuvenation")) and (localHealth < self.rejuvenationHealth) and (localMana > self.rejuvenationMana) then
						if (CastHeal("Rejuvenation", localObj)) then
							return 0;
						end
					end
				end

				-- end of heals!
				---
				---

				-- entangling root in combat
				if (self.useEntanglingRoots) then
					-- Entangling roots on low health
					if (HasSpell("Entangling Roots")) and (not targetObj:HasDebuff("Enatangle Roots")) and (localMana > 45) and (localHealth < 45) then
						if (Cast("Entangling Roots", targetObj)) then
							return 0;
						end
					end

					-- Entangling roots when target is far enough away and we have enough mana
					if (HasSpell("Entangling Roots")) and (not targetObj:HasDebuff("Enatangle Roots")) and (localMana > 45) and (targetObj:GetDistance() > 20) then
						if (Cast("Entangling Roots", targetObj)) then
							return 0;
						end
					end
				end

				-- War Stomp Tauren Racial
				if (HasSpell("War Stomp")) and (not IsSpellOnCD("War Stomp")) and (targetObj:IsCasting() or script_druid:enemiesAttackingUs(5) >= 2)
					and (targetHealth >= 50) and (not IsMoving()) then
					CastSpellByName("War Stomp");
					self.waitTimer = GetTimeEX() + 200;
					return 0;
				end

				-- keep moonfire up
				if (localMana > 30) and (targetHealth > 5) and (not targetObj:HasDebuff("Moonfire")) then
					if (Cast("Moonfire", targetObj)) then
						return 0;
					end

					-- spam moonfire until target is killed
				elseif (localMana > 30) and (targetHealth < 8) and (not IsSpellOnCD("Moonfire")) then
					if (Cast("Moonfire", targetObj)) then
						return 0;
					end
				end

				-- Wrath
				if (localMana > 40) and (targetHealth > 15) then
					if (Cast("Wrath", targetObj)) then
						return 0;
					end
				end	
			end -- end of it not bear or cat... no form attacks

			-- auto attack condition for low level druids needing to use spells at range
			if (localMana <= 35 or isBear or isCat) then
				if targetObj:GetDistance() <= self.meeleDistance then
					targetObj:FaceTarget();
					targetObj:AutoAttack();
				else
					script_nav:moveToTarget(localObj, targetObj:GetPosition());
					self.waitTimer = GetTimeEX() + 2000;
					return 0;
				end
			end

			return 0; -- else in combat return 0
		end -- end of not incombat else incombat phase
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

	-- sort forms redundant checkbox
	if (localObj:HasBuff("Bear Form")) or (localObj:HasBuff("Dire Bear Form")) then
		isBear = true;
		isCat = false;
	end

	-- sort forms redundant checkbox
	if localObj:HasBuff("Cat Form") then
		isCat = true;
		isBear = false;
	end

	----
	-- buffs not in form
	----

	-- Mark of the Wild
	if (not isBear and not isCat) then
		if (HasSpell("Mark of the Wild")) and (not localObj:HasBuff("Mark of the Wild")) and (localMana > 40) then
			if (Buff("Mark of the Wild", localObj)) then
				return 0;
			end
		end
	end

	-- Thorns
	if (not isBear and not isCat) then
		if (HasSpell("Thorns")) and (not localObj:HasBuff("Thorns")) and (localMana > 30) then
			if (Buff("Thorns", localObj)) then
				return 0;
			end
		end
	end

	----
	-- buffs in forms
	----



	---
	-- heals not in forms
	---

	-- Regrowth
	if (not isBear and not isCat) then
		if (HasSpell("Regrowth")) and (not localObj:HasBuff("Regrowth")) and (localHealth < 55) and (localMana > 40) then
			if (CastHeal("Regrowth", localObj)) then
				return 0;
			end
		end
	end

	-- Rejuvenation
	if (not isBear and not isCat) then
		if (HasSpell("Rejuvenation")) and (not localObj:HasBuff("Rejuvenation")) and (localHealth < 85) and (localMana > self.rejuvenationMana) then
			if (CastHeal("Rejuvenation", localObj)) then
				return 0;
			end
		end
	end
	
	-- Drink something
	if (not isBear and not isCat) then
		if (not IsDrinking() and localMana < self.drinkMana) then
			self.message = "Need to drink...";
			if (IsMoving()) then
				StopMoving();
				return true;
			end

			if (script_helper:drinkWater()) then 
				self.message = "Drinking..."; 
				return true; 
			else 
				self.message = "No drinks! (or drink not included in script_helper)";
				return true; 
			end
		end
	end

	-- Eat something
	if (not isBear and not isCat) then
		if (not IsEating() and localHealth < self.eatHealth) then
			self.message = "Need to eat...";
			if (IsInCombat()) then
				return true;
			end
			
			if (IsMoving()) then
				StopMoving();
				return true;
			end

			if (script_helper:eat()) then 
				self.message = "Eating..."; 
				return true; 
			else 
				self.message = "No food! (or food not included in script_helper)";
				return true; 
			end		
		end
	end

	-- Continue resting
	if(localHealth < 98 and IsEating() or localMana < 98 and IsDrinking()) then
		self.message = "Resting up to full HP/Mana...";
		return true;
	end
		
	-- Stand up if we are rested
	if (localHealth > 98 and (IsEating() or not IsStanding()) 
	    and localMana > 98 and (IsDrinking() or not IsStanding())) then
		StopMoving();
		return false;
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
			script_druid:menuEX();
		end
	end
end
