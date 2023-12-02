script_shaman = {
	message = "Shaman Combat Script",
	shamanMenu = include("scripts\\combat\\script_shamanEX.lua"),
	eatHealth = 70,
	drinkMana = 50,
	healHealth = 65,
	potionHealth = 10,
	potionMana = 20,
	isSetup = false,
	meleeDistance = 4.41,
	waitTimer = 0,
	stopIfMHBroken = true,
	enhanceWeapon = "Rockbiter Weapon",
	totem = "no totem yet",	-- used for totem1
	totemBuff = "",		-- used for totem1
	totem2 = "no totem yet",	-- used for totem2
	totemUsed = false,		-- used for totem2
	healingSpell = "Healing Wave",
	isChecked = true,
	useEarthTotem = true,
	useFireTotem = true,
	fireTotemMana = 15,
	earthShockMana = 80,
	flameShockMana = 75,
	lightningBoltMana = 25,
	pullLightningBolt = false,
}

function script_shaman:setup()

	localObj = GetLocalPlayer();
	localLevel = localObj:GetLevel();

	-- Set weapon enhancement
	if (HasSpell("Windfury Weapon")) then
		self.enhanceWeapon = "Windfury Weapon";
	elseif (HasSpell("Flametongue Weapon")) then
		self.enhanceWeapon = "Flametongue Weapon";
	elseif (HasSpell("Rockbiter Weapon")) then
		self.enchanceWeapon = "Rockbiter Weapon";
	end

	if (HasSpell("Earth Shock")) then
		self.lightningBoltMana = 80;
	end
	if (not HasSpell("Earth Shock")) then
		self.pullLightningBolt = true;
	end

	-- Set totem
	if (not HasItem("Earth Totem")) then
		self.useEarthTotem = false;
	end
	if (not HasItem("Fire Totem")) then
		self.useFireTotem = false;
	end

	-- stoneskin totem when we do not have strength of earth totem
	if (HasSpell("Stoneskin Totem")) and (not HasSpell("Strength of Earth Totem")) and (HasItem("Earth Totem")) then
		self.totem = "Stoneskin Totem";
		self.totemBuff = "Stoneskin";
	end
	-- strength of earth totem
	if (HasSpell("Strength of Earth Totem") and HasItem("Earth Totem")) then
		self.totem = "Strength of Earth Totem";
		self.totemBuff = "Strength of Earth";
	elseif (HasSpell("Grace of Air Totem") and HasItem("Air Totem")) then
		self.totem = "Grace of Air Totem";
		self.totemBuff = "Grace of Air";
	end

	if (HasSpell("Searing Totem")) and (HasItem("Fire Totem")) then
		self.totem2 = "Searing Totem";
	end

	-- Set healing spell
	if (HasSpell("Lesser Healing Wave")) then
		self.healingSpell = "Lesser Healing Wave";
	end

	if (localLevel >= 10) then
		self.drinkMana = 40;
	end

	self.waitTimer = GetTimeEX();

	self.isSetup = true;

end

-- Checks and apply enhancement on the melee weapon
function script_shaman:checkEnhancement()
	if (not IsInCombat() and not IsEating() and not IsDrinking()) then
		hasMainHandEnchant, _, _, _, _, _ = GetWeaponEnchantInfo();
		if (hasMainHandEnchant == nil) then 
			-- Apply enhancement
			if (HasSpell(self.enhanceWeapon)) then

				-- Check: Stop moving, sitting
				if (not IsStanding() or IsMoving()) then 
					StopMoving(); 
					return true;
				end 

				CastSpellByName(self.enhanceWeapon);
				self.message = "Applying " .. self.enhanceWeapon .. " on weapon...";
			else
				return false;
			end
			return true;
		end
	end 
	return false;
end

function script_shaman:spellAttack(spellName, target)
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

function script_shaman:enemiesAttackingUs(range) -- returns number of enemies attacking us within range
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
function script_shaman:runBackwards(targetObj, range) 
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
 			script_navEX:moveToTarget(localObj, moveX, moveY, moveZ);
			if (IsMoving()) then
				JumpOrAscendStart();
			end
		end
	end
	return false;
end

function script_shaman:draw()
	--script_shaman:window();
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

function script_shaman:run(targetGUID)
	
	if(not self.isSetup) then
		script_shaman:setup();
	end
	
	local localObj = GetLocalPlayer();
	local localMana = localObj:GetManaPercentage();
	local localHealth = localObj:GetHealthPercentage();
	local localLevel = localObj:GetLevel();

	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(550, 950);

		if (IsMoving()) or (not IsInCombat()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		elseif (IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		end
	end

	if (localObj:IsDead()) then
		return 0; 
	end

	-- Check: If Mainhand is broken stop bot
	isMainHandBroken = GetInventoryItemBroken("player", 16);
	
	if (self.stopIfMHBroken and isMainHandBroken) then
		self.message = "The main hand weapon is broken...";
		return 6;
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

	-- stop bot from moving target to target when stuck in combat and we need to rest
	if (IsInCombat()) and (localObj:GetUnitsTarget() == 0) then
		self.message = "Waiting! Stuck in combat phase!";
		return 4;
	end

	-- dismount before combat
	if (IsMounted()) then
		DisMount();
	end
	
	-- remove ghost wolf before combat
	if (localObj:HasBuff("Ghost Wolf")) then
		CastSpellByName("Ghost Wolf");
	end	

	--Valid Enemy
	if (targetObj ~= 0) then
	
		-- Cant Attack dead targets
		if (targetObj:IsDead() or not targetObj:CanAttack()) then
			return 0;
		end
		
		if (not IsStanding()) then
			JumpOrAscendStart();
		end

		-- Auto Attack
		--if (targetObj:GetDistance() < 40) then
		--	targetObj:AutoAttack();
		--	if (not IsMoving()) then
		--		targetObj:FaceTarget();
		--	end
		--end
	
		targetHealth = targetObj:GetHealthPercentage();

		-- Check: if we target player pets/totems
		if (GetTarget() ~= nil and targetObj ~= nil) then
			if (UnitPlayerControlled("target") and GetTarget() ~= localObj) then 
				script_grind:addTargetToBlacklist(targetObj:GetGUID());
				return 5; 
			end
		end 
		
		-- Opener
		if (not IsInCombat()) then
			self.targetObjGUID = targetObj:GetGUID();
			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";

			-- Dismount
			if (IsMounted() and targetObj:GetDistance() < 25) then DisMount(); return 0; end

			if (not IsMoving() and targetObj:GetDistance() <= 10 and targetObj:IsInLineOfSight()) then
				targetObj:FaceTarget();
			end

			-- Auto Attack
			if (targetObj:GetDistance() < 35) and (not IsAutoCasting("Attack")) and (localMana >= self.drinkMana) and (localHealth >= self.healHealth) and (script_grind.lootObj == nil or script_grind.lootObj == 0) then
				targetObj:AutoAttack();
			end

			if (self.pullLightningBolt) then
				-- Check: Not in range
				if (not targetObj:IsSpellInRange("Lightning Bolt")) or (not targetObj:IsInLineOfSight()) then
					return 3;
				elseif (not IsMoving()) and (targetObj:IsInLineOfSight()) and (targetObj:IsSpellInRange("Lightning Bolt")) then
					-- Pull with: Lighting Bolt
					if (IsMoving()) then
						StopMoving();
					end
					CastSpellByName("Lightning Bolt", targetObj);
					self.waitTimer = GetTimeEX() + 3500;
					script_grind:setWaitTimer(3500);
					targetObj:FaceTarget();
					return true;
				
				end
			elseif (targetObj:GetDistance() > self.meleeDistance) then
				-- cast fire totem before getting to target range
				if (targetObj:GetDistance() <= 20) then
					-- DO NOT TOUCH CASTING FIRE TOTEMS
					if (self.useFireTotem) then
						if (not script_shaman.totemUsed) then
							if (HasSpell(self.totem2)) then
								if (localMana >= self.fireTotemMana) then
									CastSpellByName(self.totem2);
									targetObj:FaceTarget();
									script_shaman.totemUsed = true;
									return true;
								end
							end
							script_shaman.totemUsed = true;
						end
					end
				end
				if (targetObj:GetDistance() > self.meleeDistance) then
					return 3;
				end
			end
			
			if (not IsMoving()) and (targetObj:GetDistance() <= 10) then
				targetObj:FaceTarget();
			end

			-- DO NOT TOUCH CASTING FIRE TOTEMS
			if (self.useFireTotem) and (targetObj:IsSpellInRange("Lightning Bolt")) then
				if (not script_shaman.totemUsed) then
					if (HasSpell(self.totem2)) then
						if (localMana >= self.fireTotemMana) then
							CastSpellByName(self.totem2);
							script_shaman.totemUsed = true;
							self.waitTimer = GetTimeEX() + 1750;
							return true;
						end
					end
				end
			end

			-- Totem
			if (self.useEarthTotem) then
				if (targetObj:GetDistance() <= 20) and (localMana >= self.lightningBoltMana + 10) and (HasSpell(self.totem)) and (not localObj:HasBuff(self.totemBuff)) then
					if (CastSpellByName(self.totem)) then
						self.waitTimer = GetTimeEX() + 1750;
						return 4;
					end
				end
			end

			-- stop moving if we get close enough to target and not in combat yet
			if (not IsInCombat()) and (targetObj:GetDistance() <= self.meleeDistance) and (targetHealth >= 80) then
				if (IsMoving()) then
					StopMoving();
					targetObj:FaceTarget();
				end
			end


		-- Combat
		else	



			-- stop moving if we get close enough to target
			if (IsInCombat()) and (targetObj:GetDistance() <= self.meleeDistance + 2) and (targetHealth >= 80) then
				if (IsMoving()) then
					StopMoving();
					targetObj:FaceTarget();
				end
			end

			self.message = "Killing " .. targetObj:GetUnitName() .. "...";
			-- Dismount
			if (IsMounted()) then DisMount(); end

			if (targetObj:GetDistance() <= self.meleeDistance) and (not IsMoving()) and (targetObj:IsInLineOfSight()) then
				targetObj:FaceTarget();
			end

			-- Earth Totem
			if (self.useEarthTotem) then
				if (targetObj:GetDistance() <= 12) and (HasSpell(self.totem)) and (not localObj:HasBuff(self.totemBuff)) then
					if (CastSpellByName(self.totem)) then
						if (self.useFireTotem) then
							script_grind.tickRate = 2000;
						end
						self.waitTimer = GetTimeEX() + 2000;
						script_grind:setWaitTimer(2000)
						return 4;
					end
				end
			end

			-- DO NOT TOUCH CASTING FIRE TOTEMS
			if (self.useFireTotem) then
				if (not script_shaman.totemUsed) then
					if (HasSpell(self.totem2)) then
						if (localMana >= self.fireTotemMana) then
							CastSpellByName(self.totem2);
							script_shaman.totemUsed = true;
							script_grind.tickRate = 150;
							return true;
						end
					end
				end
			end

			-- Run backwards if we are too close to the target
			if (targetObj:GetDistance() < .3) then 
				if (script_shaman:runBackwards(targetObj,1)) then 
					return 4; 
				end 
			end

			-- Check if we are in melee range
			if (targetObj:GetDistance() > self.meleeDistance or not targetObj:IsInLineOfSight()) then
				return 3;
			end

			if (not IsAutoCasting("Attack")) and (targetObj:GetDistance() <= self.meleeDistance) then 
				targetObj:AutoAttack();
				if (not IsMoving()) and (targetObj:GetDistance() <= 8) and (targetObj:IsInLineOfSight()) then
					targetObj:FaceTarget();
				end
			end

			-- Check: Healing
			if (not IsCasting()) and (not IsChanneling()) then
				if (localHealth < self.healHealth) then
					if (localMana >= 20) then 
						CastSpellByName(self.healingSpell, localObj);
						self.waitTimer = GetTimeEX() + 4000;
						script_grind:setWaitTimer(4000);
						return 4;
					end
				end
			end

			-- Check: Lightning Shield
			if (HasSpell("Lightning Shield")) and (localMana >= 35) and (not localObj:HasBuff("Lightning Shield")) then
				if (CastSpellByName("Lightning Shield", localObj)) then
					self.waitTimer = GetTimeEX() + 1500;
					return 0;
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

			if (targetObj:GetDistance() <= 30) and (not IsMoving()) and (targetObj:IsInLineOfSight()) then
				targetObj:FaceTarget();
			end

			-- Earth Shock
			if ( (targetObj:IsCasting()) or (not HasSpell("Flame Shock") and targetHealth >= 30) ) then
				if (targetObj:GetDistance() <= 20) and (localMana >= self.earthShockMana) then
					if (not IsSpellOnCD("Earth Shock")) and (HasSpell("Earth Shock")) and (not IsSpellOnCD("Flame Shock")) then
						if (CastSpellByName("Earth Shock", targetObj)) then
							self.waitTimer = GetTimeEX() + 1750;
							targetObj:FaceTarget();
							JumpOrAscendStart();
							return 0;
						end
					end
				end
			end

			-- flame shock
			if (HasSpell("Flame Shock")) and (not IsSpellOnCD("Flame Shock")) and (not IsSpellOnCD("Earth Shock")) and (localMana >= self.flameShockMana) and (targetHealth >= 55) then
				if (CastSpellByName("Flame Shock")) then
					self.waitTimer = GetTimeEX() + 1750;
					targetObj:FaceTarget();
					JumpOrAscendStart();
					return 0;
				end
			end

			-- earth shock after flame shock
			if (HasSpell("Flame Shock")) and (HasSpell("Earth Shock")) and (targetObj:HasDebuff("Flame Shock") or targetHealth <= 50) and (localMana >= self.earthShockMana) then
				if (not IsSpellOnCD("Flame Shock")) and (not IsSpellOnCD("Earth Shock")) then
					if (CastSpellByName("Earth Shock", targetObj)) then
						self.waitTimer = GetTimeEX() + 1750;
						targetObj:FaceTarget();
						JumpOrAscendStart();
						return 0;
					end
				end
			end
					
			-- cast lightning bolt in combat
			if (localMana >= self.lightningBoltMana) and (targetHealth >= 20) and (not IsMoving()) then
				if (CastSpellByName("Lightning Bolt", targetObj)) then
					targetObj:FaceTarget();
					self.waitTimer = GetTimeEX() + 1850;
					return 0;
				end
			end

			-- Check: If we are in melee range, do melee attacks
			if (targetObj:GetDistance() <= self.meleeDistance and targetObj:IsInLineOfSight()) then

				-- Check: Healing
				if (localHealth < self.healHealth) and (localMana >= 20) then 
					if (CastSpellByName(self.healingSpell, localObj)) then
						self.waitTimer = GetTimeEX() + 4000;
						script_grind:setWaitTimer(4000);
						return 0;
					end
				end

				-- stop moving if we get close enough to target and not in combat yet
				if (IsInCombat()) and (targetObj:GetDistance() <= self.meleeDistance + 2) and (targetHealth >= 80) then
					if (IsMoving()) then
						StopMoving();
						targetObj:FaceTarget();
					end
				end

				if (not IsMoving()) and (targetObj:IsInLineOfSight()) then
					targetObj:FaceTarget();
				end

				-- War Stomp Tauren Racial
				if (HasSpell("War Stomp")) and (not IsSpellOnCD("War Stomp")) then 							if (targetObj:IsCasting()) or (script_grind:enemiesAttackingUs() >= 2) or (localHealth <= self.healHealth) then
						if (CastSpellByName("War Stomp")) then
							self.waitTimer = GetTimeEX() + 500;
							return 0;
						end
					end
				end

				-- Earth Totem
				if (self.useEarthTotem) then
					if (HasSpell(self.totem) and not localObj:HasBuff(self.totemBuff)) then
						CastSpellByName(self.totem);
						self.waitTimer = GetTimeEX() + 1750;
						return 4;
					end
				end

				-- Stormstrike
				if (HasSpell("Stormstrike") and not IsSpellOnCD("Stormstrike")) then
					if (CastSpellByName("Stormstrike", targetObj)) then
						return 0;
					end
				end
			end

		end
	end

	if (not script_grind.adjustTickRate) then

		local tickRandom = random(550, 950);

		if (IsMoving()) or (not IsInCombat()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		elseif (IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		end
	end

end

function script_shaman:rest()
	if(not self.isSetup) then
		script_shaman:setup();
	end

	local localObj = GetLocalPlayer();
	local localLevel = localObj:GetLevel();
	local localHealth = localObj:GetHealthPercentage();
	local localMana = localObj:GetManaPercentage();

	if (not script_grind.adjustTickRate) then

		local tickRandom = random(1388, 2061);

		if (IsMoving()) or (not IsInCombat()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		elseif (IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		end
	end

	
	-- reset fire totem
	if (not IsInCombat()) and (script_shaman.totemUsed) and (GetLocalPlayer():GetUnitsTarget() == 0) then
		script_shaman.totemUsed = false;
	end

	-- Stop moving before we can rest
	if(localHealth < self.eatHealth or localMana < self.drinkMana) then
		if (IsMoving()) then
			StopMoving();
			return true;
		end
	end

	-- Check: Healing
	if (not IsCasting()) and (not IsChanneling()) then
		if (localHealth < 75) then
			if (localMana >= 20) then 
				CastSpellByName(self.healingSpell, localObj);
				self.waitTimer = GetTimeEX() + 4000;
				script_grind:setWaitTimer(4000);
				return 4;
			end
		end
	end

	-- Eat something
	if (not IsEating() and localHealth < self.eatHealth) and (not IsMoving()) and (not IsInCombat()) and (script_grind.lootObj == nil or script_grind.lootObj == 0) then
		self.waitTimer = GetTimeEX() + 2000;
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

	-- Drink something
	if (not IsDrinking() and localMana < self.drinkMana) and (not IsMoving()) and (not IsInCombat()) and (script_grind.lootObj == nil or script_grind.lootObj == 0) then
		self.waitTimer = GetTimeEX() + 2000;
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

	-- Keep us buffed: Lightning Shield
	if (not localObj:HasBuff("Lightning Shield")) and (localMana >= self.drinkMana) then
		if (CastSpellByName("Lightning Shield", localObj)) then
			self.waitTimer = GetTimeEX() + 1500;
			return 0;
		end
	end

	if (script_shaman:checkEnhancement()) then
		self.waitTimer = GetTimeEX() + 1750;
		return true;
	end

	if (not script_grind.adjustTickRate) then

		local tickRandom = random(1388, 2061);

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

function script_shaman:mount()
	return false;
end

function script_shaman:window()

	if (self.isChecked) then
	
		--Close existing Window
		EndWindow();

		if(NewWindow("Class Combat Options", 200, 200)) then
			script_shamanEX:menu();
		end
	end
end