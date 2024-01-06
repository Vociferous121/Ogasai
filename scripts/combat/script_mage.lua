script_mage = {
	message = 'Mage Combat Script',
	mageMenu = include("scripts\\combat\\script_mageEX.lua"),
	drinkMana = 70,	-- drink at this mana %
	eatHealth = 75,	-- eat at this health %
	potionHealth = 10,	-- use potion at this health %
	potionMana = 10,	-- use potioon at this mana %
	water = {},	-- water table setup
	numWater = 0,	-- number of conjured water
	food = {},	-- food table setup
	numfood = 0,	-- number of conjured food
	manaGem = {},	-- mana gem table setup
	numGem = 0,	-- number of conjured mana gems
	isSetup = false,	-- setup check
	polyTimer = 0,		-- polymorph add timer
	cooldownTimer = 0,	-- timer for cooldowns
	addPolymorphed = false,	-- add polymorphed yes/no
	useManaShield = true,	-- use mana shield yes/no
	iceBlockHealth = 35,	-- use ice block at this health %
	iceBlockMana = 25,	-- use ice block above this mana %
	evocationMana = 15,	-- use evocation below this mana %
	evocationHealth = 35,	-- use evocation above this health %
	manaGemMana = 20,	-- use mana gem below this health %
	polymorphAdds = true,	-- polymorphs adds yes/no
	useFireBlast = true,	-- use fireblast yes/no
	useFrostNova = true,	-- use frost nova yes/no
	useConeOfCold = true,	-- use cone of cold yes/no
	coneOfColdMana = 35,	-- use cone of cold above this mana %
	coneOfColdHealth = 15,	-- use cone of cold above this health %
	useWandMana = 10,	-- use wand below this mana %
	useWandHealth = 10,	-- use wand below this target health %
	manaShieldHealth = 80,	-- use mana shield below this health %
	manaShieldMana = 20,	-- use mana shield above this mana %
	useFrostWard = false,	-- use frost ward yes/no
	useFireWard = false,	-- use fire ward yes/no
	waitTimer = 0,		-- wait timer for spells
	useWand = true,	-- use wand yes/no
	gemTimer = 0,		-- gem cooldown timer
	useBlink = false,	-- use blink yes/no
	isChecked = true,	-- set up
	useDampenMagic = true,	-- use dampen magic yes/no
	fireMage = false,	-- is fire spec yes/no
	frostMage = true,	-- is frost spec yes/no
	scorchStacks = 2,	-- scorch debuff stacks on target
	useScorch = true,	-- use  yes/no
	followTargetDistance = 100,	-- new follow/face target distance here to debug melee
	waitTimer = GetTimeEX(),	-- set wait timer variable. probably not needed?
	rangeDistance = 38,
	moveAwayRest = false,

}

function script_mage:window()

	-- setup stuff
	if (self.isChecked) then
	
		--Close existing Window
		EndWindow();

		-- make the new window
		if(NewWindow("Class Combat Options", 200, 200)) then
			script_mageEX:menu();
		end
	end
end

function script_mage:cast(spellName, target) -- not used here as reference from old scripts
	if (HasSpell(spellName)) then
		if (target:IsSpellInRange(spellName)) then
			if (not IsSpellOnCD(spellName)) then
				if (not IsAutoCasting(spellName)) then
					target:FaceTarget();
					target:TargetEnemy();
					return target:CastSpell(spellName);
				end
			end
		end
	end
	return false;
end

function script_mage:coneOfCold(spellName) -- cone of cold function needed to work properly
	if (HasSpell(spellName)) then
		if (not IsSpellOnCD(spellName)) then
			if (not IsAutoCasting(spellName)) then
				CastSpellByName(spellName);
			end
		end
	end
	return false;
end

function script_mage:getTargetNotPolymorphed() -- check polymorph
   	local unitsAttackingUs = 0; 
   	local currentObj, typeObj = GetFirstObject(); 
   	while currentObj ~= 0 do 
   		if typeObj == 3 then
			if (currentObj:CanAttack() and not currentObj:IsDead()) then
               	if (script_grind:isTargetingMe(currentObj) and not currentObj:HasDebuff('Polymorphed')) then 
                	return currentObj;
               	end 
            end 
       	end
        	currentObj, typeObj = GetNextObject(currentObj); 
    end
   	return nil;
end

function script_mage:isAddPolymorphed() -- check polymorph
	local currentObj, typeObj = GetFirstObject(); 
	local localObj = GetLocalPlayer();
	while currentObj ~= 0 do 
		if typeObj == 3 then
			if (currentObj:HasDebuff("Polymorph")) then 
				return true; 
			else
				script_mage.addPolymorphed = false;
			end
		end
		currentObj, typeObj = GetNextObject(currentObj); 
	end
    return false;
end

function script_mage:polymorphAdd(targetObjGUID) -- cast the polymorph conditions
    local currentObj, typeObj = GetFirstObject(); 
    local localObj = GetLocalPlayer();
    while currentObj ~= 0 do 
    	if typeObj == 3 then
			if (currentObj:CanAttack() and not currentObj:IsDead()) then
				if (currentObj:GetGUID() ~= targetObjGUID and script_grind:isTargetingMe(currentObj)) then
					if (not currentObj:HasDebuff("Polymorph") and currentObj:GetCreatureType() ~= 'Elemental' and not currentObj:IsCritter()) and (currentObj:GetCreatureType() ~= "Undead") then
						if (currentObj:IsInLineOfSight()) then
							if (not script_grind.adjustTickRate) then
								script_grind.tickRate = 100;
							end
							if (script_mage:cast('Polymorph', currentObj)) then 
								self.addPolymorphed = true; 
								polyTimer = GetTimeEX() + 8000;
								return true; 
							end
						end
					end 
				end 
			end 
		end
        currentObj, typeObj = GetNextObject(currentObj); 
    end
    return false;
end

-- Run backwards if the target is within range
function script_mage:runBackwards(targetObj, range) 
	local localObj = GetLocalPlayer();
	script_grind.tickRate = 135;
 	if targetObj ~= 0 then
 		local xT, yT, zT = targetObj:GetPosition();
 		local xP, yP, zP = localObj:GetPosition();
 		local distance = targetObj:GetDistance();
 		local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
 		local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 		local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;
 		local moveX, moveY, moveZ = xT + xUV*10, yT + yUV*10, zT + zUV;		
 		if (distance <= range)
			and (targetObj:IsInLineOfSight())
			and (not script_checkDebuffs:hasDisabledMovement())
		then 		
 			if (script_navEX:moveToTarget(localObj, moveX, moveY, moveZ)) then
 				return true;
			end
		return true;
		end
	end

	return false;
end

function script_mage:addWater(name) -- water setup
	self.water[self.numWater] = name;
	self.numWater = self.numWater + 1;
end

function script_mage:addFood(name)	-- food setup
	self.food[self.numfood] = name;
	self.numfood = self.numfood + 1;
end

function script_mage:addManaGem(name)	-- mana gem setup
	self.manaGem[self.numGem] = name;
	self.numGem = self.numGem + 1;
end

function script_mage:setup()
	script_mage:addWater('Conjured Crystal Water');
	script_mage:addWater('Conjured Sparkling Water');
	script_mage:addWater('Conjured Mineral Water');
	script_mage:addWater('Conjured Spring Water');
	script_mage:addWater('Conjured Purified Water');
	script_mage:addWater('Conjured Fresh Water');
	script_mage:addWater('Conjured Water');
	
	script_mage:addFood('Conjured Cinnamon Roll');
	script_mage:addFood('Conjured Sweet Roll');
	script_mage:addFood('Conjured Sourdough')
	script_mage:addFood('Conjured Pumpernickel');
	script_mage:addFood('Conjured Rye');
	script_mage:addFood('Conjured Bread');
	script_mage:addFood('Conjured Muffin');
	
	script_mage:addManaGem('Mana Agate');
	script_mage:addManaGem('Mana Citrine');
	script_mage:addManaGem('Mana Jade');
	script_mage:addManaGem('Mana Ruby');

	-- no more bugs first time we run the bot
	self.waitTimer = GetTimeEX();
	self.gemTimer = GetTimeEX();
	self.cooldownTimer = GetTimeEX();
	self.polyTimer = GetTimeEX();

	-- set cone of cold to false - debug stuff
	if (not HasSpell("Cone of Cold")) then
		self.useConeOfCold = false;
	end

	-- set frost nova to false - debug stuff
	if (not HasSpell("Frost Nova")) then
		self.useFrostNova = false;
	end

	localObj = GetLocalPlayer();

	-- set spec below level 4
	if (not HasSpell("Frostbolt")) then
		self.fireMage = true;
		self.frostMage = false;
	end

	if (GetLocalPlayer():GetLevel() < 10) and (localObj:HasRangedWeapon()) then
		self.useWandHealth = 40;
	end
	
	-- set group settings mainly used for easy follower reloads
	if (GetNumPartyMembers() > 1) then
		self.useBlink = false;
		self.useFrostNova = false;
		self.polymorphAdds = false;
		self.useDampenMagic = false;
		self.drinkMana = 35;
	end

	-- if no wand then don't use wand
	if (not localObj:HasRangedWeapon()) then
		self.useWand = false;
	end

	-- use cold snap to set frost mage as true
	if (HasSpell("Cold Snap")) then
		self.frostMage = true;
		self.fireMage = false;
	end
	
	-- use pyroblast to set fire mage as true
	if (HasSpell("Pyroblast")) then
		self.fireMage = true;
		self.frostMage = false;
		self.manaShieldHealth = 95;
		self.eatHealth = 65;
		self.useWandHealth = 15;
	end

	-- hide scorch until high enough level for talent obtained debuffs
	if (GetLocalPlayer():GetLevel() < 27) or (self.frostMage) then
		self.useScorch = false;
	end

	self.isSetup = true;
end

function script_mage:draw()
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

--[[ error codes: 	0 - All Good , 
			1 - missing arg , 
			2 - invalid target , 
			3 - not in range, 
			4 - do nothing , 
			5 - targeted player pet/totem  ]]--

function script_mage:run(targetGUID)
	
	-- when you click the start button all of this code runs at the script tick rate

	-- check setup
	if (not self.isSetup) then
		script_mage:setup();
	end
	
	if (not HasSpell("Frostbolt")) then
		self.frostMage = false;
		self.fireMage = true;
	end

	local localObj = GetLocalPlayer();

	local localMana = localObj:GetManaPercentage();

	local localHealth = localObj:GetHealthPercentage();

	local localLevel = localObj:GetLevel();
	
	-- check if we are dead
	if (localObj:IsDead()) then
		return 0;
	end
	
	-- Assign the target 
	targetObj =  GetGUIDObject(targetGUID);

	-- clear dead targets
	if (targetObj == 0) or (targetObj == nil) or (targetObj:IsDead()) then
		ClearTarget();
		return 2;
	end

	-- Check: Do nothing if we are channeling, casting or Ice Blocked
	if (IsChanneling()) or (IsCasting()) or (localObj:HasBuff("Ice Block")) or (self.waitTimer > GetTimeEX()) then
		return 4;
	end

	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(350, 650);

		if (IsMoving()) or (not IsInCombat()) and (not localObj:IsCasting()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) or (localObj:IsCasting()) then
			script_grind.tickRate = tickRandom
		elseif (IsInCombat()) and (not IsMoving()) or (localObj:IsCasting()) then
			script_grind.tickRate = tickRandom;
		end
	end


	-- check silence and use wand
	if (IsInCombat())
		and (localObj:HasRangedWeapon())
		and (not IsCasting())
		and (not IsChanneling())
		and (not localObj:IsStunned())
	then
		if (script_checkDebuffs:hasSilence()
			or IsSpellOnCD("Frostbolt")
			or IsSpellOnCD("Fireball")) 
		then
			if (targetObj ~= 0)
				and (targetObj ~= nil)
			then
				if (not IsAutoCasting("Shoot")) and (PlayerHasTarget()) then
					targetObj:FaceTarget();
					targetObj:CastSpell("Shoot");
				return true;
				end
			end
		end
	end
		
	-- dismount before combat
	if (IsMounted()) then
		DisMount();
	end

	--Valid Enemy
	if (targetObj ~= 0) and (targetObj ~= nil) and (not localObj:IsStunned()) and (not localObj:IsMovementDisabed()) then

		if (IsInCombat()) and (script_grind.skipHardPull) and (GetNumPartyMembers() == 0) then
			if (script_checkAdds:checkAdds()) then
				script_om:FORCEOM();
				return;
			end
		end

		-- Cant Attack dead targets
		if (targetObj:IsDead()) or (not targetObj:CanAttack()) then
			ClearTarget();
			return 2;
		end
		
		-- stand if sitting
		if (not IsStanding()) then
			JumpOrAscendStart();
		end

		-- set target health variable
		targetHealth = targetObj:GetHealthPercentage();

		-- Auto Attack
		if (targetObj:GetDistance() < 40) and (not IsMoving()) then
			targetObj:AutoAttack();
		-- stops spamming auto attacking while moving to target
		elseif (targetObj:GetDistance() < 5) then
			targetObj:AutoAttack();
		end

		-- Check: if we target player pets/totems
		if (GetTarget() ~= 0) then
			if (GetTarget():GetGUID() ~= GetLocalPlayer():GetGUID()) then
				if (UnitPlayerControlled("target")) then 
					script_grind:addTargetToBlacklist(targetObj:GetGUID());
					return 5; 
				end
			end
		end 
		
		if (targetObj:GetDistance() > 30) or (not targetObj:IsInLineOfSight()) and (not targetObj:HasDebuff("Frost Nova")) then
			return 3;
		end

		if (targetObj:GetDistance() < 30) and (not IsMoving()) and (PlayerHasTarget()) then
			targetObj:FaceTarget();
		end
		--	START OF COMBAT PHASE
	
		-- Opener - not in combat pulling target
		if (not IsInCombat()) then

			-- display message in ogasai message box
			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";

			-- frost mage selected
			if (self.frostMage) and (targetObj:GetDistance() <= 30) and (targetObj:IsInLineOfSight()) then
				if (script_mage.frostMagePull(targetObj)) then
					script_grind:setWaitTimer(2600);
					self.waitTimer = GetTimeEX() + 2600;
					if (PlayerHasTarget()) then
						targetObj:FaceTarget();
					end
				end

				-- fire mage selected use these spells instead
			elseif (self.fireMage) and (targetObj:GetDistance() <= 30) then
				if (script_mage.fireMagePull(targetObj)) then
					script_grind:setWaitTimer(2600);
					self.waitTimer = GetTimeEX() + 2600;
					if (PlayerHasTarget()) then
						targetObj:FaceTarget();
					end
				end
			end
			
		-- Combat

		else	



			-- display message in ogasai message box
			self.message = "Killing " .. targetObj:GetUnitName() .. "...";
			
			-- Dismount
			if (IsMounted()) then
				DisMount();
			end

			-- check racial spells
			CheckRacialSpells();

			-- blink on movement stop debuffs
			if (HasSpell("Blink")) and (not IsSpellOnCD("Blink")) then
				if (script_checkDebuffs:hasDisabledMovement()) then
					local a = targetObj:GetAngle();
					FaceAngle(a);
					if (CastSpellByName("Blink")) then
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 500;
						return 0;
					end
				end
			end

			-- blink frost nova on CD
			if (self.useBlink) then
				if (HasSpell("Blink")) and (not IsSpellOnCD("Blink")) and (IsSpellOnCD("Frost Nova") or IsSpellOnCD("Cone of Cold")) and (targetObj:GetDistance() < 9) and (targetHealth > self.useWandHealth + 10) then
					if (not targetObj:HasDebuff("Frostbite")) and (not targetObj:HasDebuff("Frost Nova")) and (not targetObj:HasDebuff("Blast Wave")) and (targetHealth > 10) then
						local a = targetObj:GetAngle();
						FaceAngle(a);
						if (CastSpellByName("Blink")) then
							targetObj:FaceTarget();
							self.waitTimer = GetTimeEX() + 500;
						end
					end
				end
			end

			-- Fire blast
			if (self.useFireBlast) and (targetObj:GetDistance() <= 20) and (HasSpell("Fire Blast")) and (not IsSpellOnCD("Fire Blast")) and (localMana > 6) and (not IsMoving()) then
				if (not targetObj:HasDebuff("Frost Nova")) and (not targetObj:HasDebuff("Frostbite")) or (targetHealth < 20 and localHealth < 25) then
	
					if (not IsSpellOnCD("Fire Blast")) then
						CastSpellByName("Fire Blast", targetObj);
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 1500;
						script_grind:setWaitTimer(1600);
						return 0;
					end
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

			-- Check: Keep Ice Barrier up if possible
			if (HasSpell("Ice Barrier")) and (not IsSpellOnCD("Ice Barrier")) and (not localObj:HasBuff("Ice Barrier")) then
				CastSpellByName('Ice Barrier');
				return 0;

				-- Check: If we have Cold Snap use it to clear the Ice Barrier CD
			elseif (HasSpell("Ice Barrier")) and (IsSpellOnCD("Ice Barrier")) and (HasSpell("Cold Snap")) and (not IsSpellOnCD("Cold Snap")) and
				(not localObj:HasBuff("Ice Barrier")) then
				CastSpellByName('Cold Snap');
				return 0;
			end

			-- use cold snap to reset frost nova if we don't have ice barrier
			if (targetObj:IsInLineOfSight()) and (not HasSpell("Ice Barrier")) and (HasSpell("Cold Snap")) and (not IsSpellOnCD("Cold Snap")) and (IsSpellOnCD("Frost Nova")) and (not targetObj:HasDebuff("Frost Nova")) and (not targetObj:HasDebuff("Frostbite")) and (targetObj:GetDistance() <= 10) and ( (localMana >= 15 and targetHealth >= 20) or (localHealth <= 30 and localMana >= 10) ) then
				CastSpellByName("Cold Snap");
				self.waitTimer = GetTimeEX() + 1000;
			end

			-- Run backwards if we are too close to the target
			if (targetObj:GetDistance() <= .5) then 
				if (script_mage:runBackwards(targetObj,5)) then 
					return 4; 
				end 
			end
			
			-- Check: Move backwards if the target is affected by Frost Nova or Frost Bite
			if (GetNumPartyMembers() < 1) and (self.useFrostNova) then
				if (targetObj:HasDebuff("Frostbite") or targetObj:HasDebuff("Frost Nova")) and (targetHealth > 10 or localHealth < 35) and (not localObj:HasBuff('Evocation')) and (not script_checkDebuffs:hasDisabledMovement()) and (not IsSwimming()) and (targetObj:IsInLineOfSight()) then
					script_grind.tickRate = 0;

					if (script_mage:runBackwards(targetObj, 8)) then -- Moves if the target is closer than 7 yards

						self.message = "Moving away from target...";
						if (not IsSpellOnCD("Frost Nova")) and (targetObj:GetDistance() < 9) and (not targetObj:HasDebuff("Frostbite")) then
							CastSpellByName("Frost Nova");
							return;
						end
						if (targetObj:GetDistance() > 7) and (not IsMoving()) then
							targetObj:FaceTarget();
						end
					return 4;
					end 
				end	
			end

			-- frost nova if target is running away
			if (HasSpell("Frost Nova")) and (not IsSpellOnCD("Frost Nova")) and (targetObj:IsFleeing()) and (targetHealth > 3) then
				if (localMana > 5) and (targetObj:GetDistance() < 9) and (not targetObj:HasDebuff("Frostbite")) then
					if (CastSpellByName("Frost Nova")) then
						return;
					end
				end
			end

			-- frost nova fireMage redundancy
			if (self.fireMage and self.useFrostNova) then
				if (HasSpell("Frost Nova")) and (not IsSpellOnCD("Frost Nova")) then
					if (localMana > 5) and (targetObj:GetDistance() < 9) and (not targetObj:HasDebuff("Frost Nova")) and (not targetObj:HasDebuff("Frostbite")) then
						if (CastSpellByName("Frost Nova")) then
							return;
						end
					end
				end
			end

			-- Use Mana Gem when low on mana
			if (localMana < self.manaGemMana and GetTimeEX() > self.gemTimer) then
				for i=0,self.numGem do
					if(HasItem(self.manaGem[i])) then
						UseItem(self.manaGem[i]);
						self.gemTimer = GetTimeEX() + 120000;
						return 0;
					end
				end
			end

			-- Use Evocation if we have low Mana but still a lot of HP left
			if (localMana < self.evocationMana and localHealth > self.evocationHealth and HasSpell("Evocation") and not IsSpellOnCD("Evocation")) and (targetHealth > 35) then		
				self.message = "Using Evocation...";
				CastSpellByName("Evocation"); 
				return 0;
			end

			-- counterspell if target is casting
			if (HasSpell("Counterspell")) and (not IsSpellOnCD("Counterspell")) and (localMana > 15) and (targetObj:IsCasting()) then
				if (CastSpellByName("Counterspell", targetObj)) then
					self.waitTimer = GetTimeEX() + 1500;
					return 0;
				end
			end

			-- Use Mana Shield if we have more than 35 percent mana and no active Ice Barrier
			if (not localObj:HasBuff("Ice Barrier")) and (HasSpell("Mana Shield")) and (localMana >= self.manaShieldMana) and (localHealth <= self.manaShieldHealth) and (not localObj:HasBuff("Mana Shield")) and (IsInCombat()) then
				if (not targetObj:HasDebuff("Frost Nova") and not targetObj:HasDebuff("Frostbite")) then
					CastSpellByName("Mana Shield");
					self.waitTimer = GetTimeEX() + 1650;
					script_grind:setWaitTimer(1650);
					return 0;
				end
			end

			-- Check if add already polymorphed
			if (not script_mage:isAddPolymorphed() and not (self.polyTimer < GetTimeEX())) then
				self.addPolymorphed = false;
			end

			-- Check: Polymorph add
			if (targetObj ~= nil and self.polymorphAdds and script_grind:enemiesAttackingUs(5) > 1 and HasSpell('Polymorph') and not self.addPolymorphed and self.polyTimer < GetTimeEX()) and (targetObj:GetDistance() < 25) then
				script_grind.tickRate = 250;
				self.message = "Polymorphing add...";
				script_mage:polymorphAdd(targetObj:GetGUID());
				self.waitTimer = GetTimeEX() + 1750;
				script_grind:setWaitTimer(1500);
			end 

			-- Check: Sort target selection if add is polymorphed
			if (self.addPolymorphed) then
				if(script_grind:enemiesAttackingUs(5) >= 1 and targetObj:HasDebuff('Polymorph')) then
					ClearTarget();
					script_grind.tickRate = 250;
					targetObj = script_mage:getTargetNotPolymorphed();
					targetObj:AutoAttack();
				end
			end

			if (IsInCombat()) and (script_grind.skipHardPull) and (GetNumPartyMembers() == 0) then
				if (script_checkAdds:checkAdds()) then
					self.message = "moving away from adds...";
					script_om:FORCEOM();
					return;
				end
			end

			-- Check: Frostnova when the target is close, but not when we polymorhped one enemy or the target is affected by Frostbite
			if (not self.addPolymorphed) and (targetObj:GetDistance() < 9 and not targetObj:HasDebuff("Frostbite") and HasSpell("Frost Nova") and not IsSpellOnCD("Frost Nova")) and self.useFrostNova then
				script_grind.tickRate = 100;
				self.message = "Frost nova the target(s)...";
				CastSpellByName("Frost Nova");
				return 0;
			end			

			-- ice block
			if (self.frostMage) then
				if (HasSpell("Ice Block")) and (not IsSpellOnCD("Ice Block")) then
					if (localHealth < self.iceBlockHealth) and (localMana < self.iceBlockMana) then
						self.message = "Using Ice Block...";
						CastSpellByName('Ice Block');
						return 0;
					end
				end
			end

			-- arcane explosion in group 
			if (GetNumPartyMembers() > 1) then
				if (HasSpell("Arcane Explosion")) and (targetObj:GetDistance() < 6) and (localMana > 25) and (script_grind:enemiesAttackingUs(5) >= 2) then
					if (CastSpellByName("Arcane Explosion")) then
						return 0;
					end
				end
			end

			--Cone of Cold
			if (self.useConeOfCold) and (HasSpell('Cone of Cold')) and (localMana >= self.coneOfColdMana) and (targetHealth >= self.coneOfColdHealth) then
				if (not self.addPolymorphed) and (targetObj:GetDistance() < 9) and (not targetObj:HasDebuff("Frostbite")) and (not targetObj:HasDebuff("Frost Nova")) then
						targetObj:FaceTarget();
					if (script_mage:coneOfCold('Cone of Cold')) then
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 1500;
						return 0;
					end
				end
			end

			-- blast wave
			if (self.fireMage) and (HasSpell("Blast Wave")) then
				if (localMana > 30) and (targetObj:GetDistance() < 10) and (not IsSpellOnCD("Blast Wave")) and (targetHealth > 10 or localHealth < 35) and (not IsSwimming()) and (targetObj:IsInLineOfSight()) then
					if (script_mage:runBackwards(targetObj, 8)) then -- Moves if the target is closer than 7 yards
						script_grind.tickRate = 0;
						self.message = "Moving away from target...";
						if (not IsSpellOnCD("Blast Wave")) then
							CastSpellByName("Blast Wave");
							return 0;
						end
						if (targetObj:GetDistance() > 7) and (not IsMoving()) then
							targetObj:FaceTarget();
						end
					return 4; 
					end 
				end	
			end

			if (script_grind.skipHardPull) and (GetNumPartyMembers() == 0) then
				if (script_checkAdds:checkAdds()) then
					return true;
				end
			end
			
			if (targetHealth > 10 or localHealth < 35) and (targetObj:HasDebuff("Frostbite") or targetObj:HasDebuff("Frost Nova")) and (not localObj:HasBuff('Evocation')) and (not script_checkDebuffs:hasDisabledMovement()) and (not IsSwimming()) and (targetObj:IsInLineOfSight()) then
				if (script_mage:runBackwards(targetObj, 8)) then -- Moves if the target is closer than 7 yards
					script_grind.tickRate = 0;
					self.message = "Moving away from target...";
					if (targetObj:GetDistance() > 7) and (not IsMoving()) then
						targetObj:FaceTarget();
					end
				end
			end

			-- scorch
			if (self.fireMage) and (self.useScorch) and (HasSpell("Scorch")) and (GetLocalPlayer():GetLevel() >= 27) and (localMana > self.useWandMana and targetHealth > self.useWandHealth) then
				if (targetObj:GetDebuffStacks("Fire Vulnerability") < self.scorchStacks) then
					if (localMana > self.useWandMana) and (targetHealth > self.useWandHealth) then
						if (CastSpellByName("Scorch", targetObj)) then
							self.waitTimer = GetTimeEX() + 1800;
							return 0;
						end
					end
				end
			end
			
			-- pyroblast if target has frost nova?
			if (self.fireMage) and (not targetObj:HasDebuff("Pyroblast")) and (not IsSpellOnCD("Pyroblast")) and (IsSpellOnCD("Frost Nova")) then
				if (HasSpell("Pyroblast")) and (targetObj:HasDebuff("Frost Nova")) then
					if (CastSpellByName("Pyroblast", targetObj)) then
						self.waitTimer = GetTimeEX() + 5000;
						return 0;
					end
				end
			end

			-- Wand if mana or target health is low
			if (self.useWand and localObj:HasRangedWeapon()) and (localMana <= self.useWandMana or targetHealth <= self.useWandHealth) and (not IsChanneling()) and (not localObj:IsStunned()) then
				self.message = "Using wand...";
				if (not IsAutoCasting("Shoot")) and (PlayerHasTarget()) then
					targetObj:FaceTarget();
					targetObj:CastSpell("Shoot");
					return true;
				end
			end

			if (self.useFrostMage) and (not HasSpell("Frostbolt")) then
				CastSpellByName("Fireball", targetObj);
			end
			
			-- Main damage source if all above conditions cannot be run
			-- frost mage spells
			if (HasSpell("Frostbolt")) and (self.frostMage) and (not IsChanneling()) and (not IsMoving()) then
				if (localMana >= self.useWandMana and targetHealth >= self.useWandHealth) then

			-- Check: Frostnova when the target is close, but not when we polymorhped one enemy or the target is affected by Frostbite
				if (not self.addPolymorphed) and (targetObj:GetDistance() < 9 and not targetObj:HasDebuff("Frostbite") and HasSpell("Frost Nova") and not IsSpellOnCD("Frost Nova")) and self.useFrostNova and localMana >= 10 then
				script_grind.tickRate = 0;
				self.message = "Frost nova the target(s)...";
				CastSpellByName("Frost Nova");
			end

			if (IsInCombat()) and (script_grind.skipHardPull) and (GetNumPartyMembers() == 0) then
				if (script_checkAdds:checkAdds()) then
					self.message = "moving away from adds...";
					script_om:FORCEOM();
					return;
				end
			end
			
					-- check range
					if (not targetObj:IsSpellInRange("Frostbolt")) or (not targetObj:IsInLineOfSight()) and (not targetObj:HasDebuff("Frost Nova")) then
						return 3;
					end

					if (CastSpellByName("Frostbolt", targetObj)) then
						self.waitTimer = GetTimeEX() + 1500;
						return 0;
					end
			
				end	
			end

				-- fire mage spells
			if(self.fireMage) and (not IsChanneling()) and (not IsMoving()) then

				-- use these spells if not using wand
				if (localMana >= self.useWandMana and targetHealth >= self.useWandHealth) then

				-- Check: Frostnova when the target is close, but not when we polymorhped one enemy or the target is affected by Frostbite
					if (not self.addPolymorphed) and (targetObj:GetDistance() < 9 and not targetObj:HasDebuff("Frostbite") and HasSpell("Frost Nova") and not IsSpellOnCD("Frost Nova")) and self.useFrostNova and localMana >= 10 then
						script_grind.tickRate = 100;
						self.message = "Frost nova the target(s)...";
						CastSpellByName("Frost Nova");
					end

					-- cast pyroblast
					if (targetObj:GetDistance() < 30) then

						if (HasSpell("Pyroblast")) then
							if (CastSpellByName("Pyroblast", targetObj)) then
								return 0;
							end
						end
				
						-- cast fireball
						if (not HasSpell("Pyroblast")) then
							if (CastSpellByName("Fireball", targetObj)) then
								return 0;
							end
						end
					end

				end
			end	
			
			-- this is here to check for low level "frost Mage" not having frostbolt yet
			if (self.frostMage) and (not HasSpell("Frostbolt")) and (not IsMoving()) then				
		
				-- else if not has frostbolt then use fireball as range check
				if (not targetObj:IsSpellInRange("Fireball")) or (not targetObj:IsInLineOfSight()) and (not targetObj:HasDebuff("Frost Nova")) then
					return 3;
				end	
				
				-- cast fireball
				if (CastSpellByName("Fireball", targetObj)) then
					script_grind:setWaitTimer(1500);
					self.waitTimer = GetTimeEX() + 1500;
					return 0;
				end
			end

			-- this is here to check for low level not having a wand yet
			if (self.frostMage) and (not IsMoving()) and (not localObj:HasRangedWeapon()) and (targetHealth <= self.useWandHealth) then				
		
				if (not targetObj:IsSpellInRange("Fireball")) or (not targetObj:IsInLineOfSight()) and (not targetObj:HasDebuff("Frost Nova")) then
					return 3;
				end	
				
				-- cast frostbolt
				if (CastSpellByName("Frostbolt", targetObj)) then
					script_grind:setWaitTimer(1500);
					self.waitTimer = GetTimeEX() + 1500;
					return 0;
				end
			end

				
		end

		-- set tick rate for script to run
		if (not script_grind.adjustTickRate) then

				local tickRandom = random(350, 650);

			if (IsMoving()) or (not IsInCombat()) and (not localObj:IsCasting()) then
				script_grind.tickRate = 135;
			elseif (not IsInCombat()) and (not IsMoving()) or (localObj:IsCasting()) then
				script_grind.tickRate = tickRandom
			elseif (IsInCombat()) and (not IsMoving()) or (localObj:IsCasting()) then
				script_grind.tickRate = tickRandom;
			end
		end
	end
end

function script_mage:rest()

	if(not self.isSetup) then
		script_mage:setup();
	end

	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(550, 1261);

		if (IsMoving()) or (not IsInCombat()) and (not localObj:IsCasting()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) or (localObj:IsCasting()) then
			script_grind.tickRate = tickRandom
		elseif (IsInCombat()) and (not IsMoving()) or (localObj:IsCasting()) then
			script_grind.tickRate = tickRandom;
		end
	end


	local localObj = GetLocalPlayer();
	local localMana = localObj:GetManaPercentage();
	local localHealth = localObj:GetHealthPercentage();

	if (self.moveAwayRest) and (localMana < self.drinkMana or localHealth < self.eatHealth) and (not IsInCombat()) and (script_grind.enemyObj == nil or script_grind.enemyObj == 0) then
		if (script_checkAdds:avoidToAggro2(script_checkAdds.checkAddsRange+10)) then
			script_grind:setWaitTimer(1700);
			self.waitTimer = GetTimeEX() + 5500;
			self.message = "Moving away from adds to drink/eat.";
			return;
		end
	end

if (not IsMounted()) then

	--Create Water
	local waterIndex = -1;
	for i=0,self.numWater do
		if (HasItem(self.water[i])) then
			waterIndex = i;
			break;
		end
	end

	if (not IsEating()) and (not IsDrinking()) and (IsStanding()) then 
		if (waterIndex == -1) and (HasSpell('Conjure Water')) then
			self.message = "Conjuring water...";
			if (IsMoving()) then
				StopMoving();
				return true;
			end
			if (not IsStanding()) then
				StopMoving();
				return true;
			end
			if(IsMounted()) then 
				DisMount(); 
			end
			if (localMana > 10 and not IsDrinking() and not IsEating() and not AreBagsFull()) then
				if (HasSpell('Conjure Water')) then
					CastSpellByName('Conjure Water')
					self.waitTimer = GetTimeEX() + 1700;
					return true;
				end
			end
		end
	end

	--Create Food
	local foodIndex = -1;
	for i=0,self.numfood do
		if (HasItem(self.food[i])) then
			foodIndex = i;
			break;
		end
	end

	if (not IsEating()) and (not IsDrinking()) and (IsStanding()) then
		if (foodIndex == -1) and (HasSpell('Conjure Food')) then 
			self.message = "Conjuring food...";
			if (IsMoving()) then
				StopMoving();
				return true;
			end
			if (not IsStanding()) then
				StopMoving();
				return true;
			end
			if(IsMounted()) then 
				DisMount(); 
				return true;
			end
			if (localMana > 10 and not IsDrinking() and not IsEating() and not AreBagsFull()) then
				if (HasSpell('Conjure Food')) then
					CastSpellByName('Conjure Food')
					self.waitTimer = GetTimeEX() + 1700;
					return true;
				end
			end
		end
	end
	
	--Create Mana Gem
	local gemIndex = -1;
	for i=0,self.numGem do
		if (HasItem(self.manaGem[i])) then
			gemIndex = i;
			break;
		end
	end

	if (not IsEating()) and (not IsDrinking()) and (IsStanding()) then
		if (gemIndex == -1 and (HasSpell('Conjure Mana Ruby') 
					or HasSpell('Conjure Mana Citrine') 
					or HasSpell('Conjure Mana Jade')
					or HasSpell('Conjure Mana Agate')))
					and (not IsEating() and not IsDrinking()) then 
			self.message = "Conjuring mana gem...";
			if(IsMounted()) then 
				DisMount(); 
			end
	
			if (IsMoving()) then
				StopMoving();
				return true;
			end
	
			if (not IsStanding()) then
				JumpOrAscendStart();
			end

			if (IsStanding()) then
				StopMoving();
			end

			if (localMana > 30 and not IsDrinking() and not IsEating() and not AreBagsFull() and not IsInCombat()) then
				if (HasSpell('Conjure Mana Ruby')) then
					CastSpellByName('Conjure Mana Ruby')
					self.waitTimer = GetTimeEX() + 1800;
					return true;
				elseif (HasSpell('Conjure Mana Citrine')) then
					CastSpellByName('Conjure Mana Citrine')
					self.waitTimer = GetTimeEX() + 1800;
					return true;
				elseif (HasSpell('Conjure Mana Jade')) then
					CastSpellByName('Conjure Mana Jade')
					self.waitTimer = GetTimeEX() + 1800;
					return true;
				elseif (HasSpell('Conjure Mana Agate')) then
					CastSpellByName('Conjure Mana Agate')
					self.waitTimer = GetTimeEX() + 1800;
					return true;
				end
			end
		end
	end

	-- Stop moving before we can rest
	if(localHealth < self.eatHealth or localMana < self.drinkMana) then
		if (IsMoving()) then
			StopMoving();
			return true;
		end
	end
	
	-- stand up if sitting after drinking/eating -- used for buffs
	if (not IsEating()) and (not IsDrinking()) then

		if (not IsStanding())then
			StopMoving();
		end
	
		-- arcane intellect
		if (HasSpell("Arcane Intellect")) and (not localObj:HasBuff("Arcane Intellect")) and (localMana > 25) then
			CastSpellByName("Arcane Intellect", localObj);
			self.waitTimer = GetTimeEX() + 1700;
			script_grind:setWaitTimer(1700);
			return true;
		end
		
		-- ice armor / frost armor
		if (HasSpell("Ice Armor")) and (not localObj:HasBuff("Ice Armor")) and (localMana > 20) then
			if (CastSpellByName("Ice Armor", localObj)) then
				self.waitTimer = GetTimeEX() + 1700;
				script_grind:setWaitTimer(1700);
				return true;
			end
		elseif (not HasSpell("Ice Armor")) and (HasSpell("Frost Armor")) and (not localObj:HasBuff("Frost Armor")) and (localMana > 20) then	
			if (CastSpellByName("Frost Armor", localObj)) then
				self.waitTimer = GetTimeEX() + 1700;
				script_grind:setWaitTimer(1700);
				return true;
			end
		end
	
		-- dampen magic
		if (self.useDampenMagic) then
			if (HasSpell("Dampen Magic")) and (not localObj:HasBuff("Dampen Magic")) and (localMana > 15) then
					if (CastSpellByName("Dampen Magic", localObj)) then
					self.waitTimer = GetTimeEX() + 1700;
					script_grind:setWaitTimer(1700);
					return true;
				end
			end
		end
	
		-- combustion
		if (HasSpell("Combustion")) and (not IsSpellOnCD("Combustion")) and not (localObj:HasBuff("Combustion")) and (self.fireMage) then	
			if (CastSpellByName("Combustion")) then
				self.waitTimer = GetTimeEX() + 1700;
				script_grind:setWaitTimer(1700);
				return true;
			end
		end

		-- frost ward
		if (self.useFrostWard) and (HasSpell("Frost Ward")) and (not localObj:HasBuff("Frost Ward")) then
			if (localMana > 50) and (not localObj:HasBuff("Fire Ward")) then
				if (CastSpellByName("Frost Ward", localObj)) then
					self.waitTimer = GetTimeEX() + 1700;
					script_grind:setWaitTimer(1700);
					return true;
				end
			end
		end
	
		-- fire ward
		if (self.useFireWard) and (HasSpell("Fire Ward")) and (not localObj:HasBuff("Fire Ward")) then
			if (localMana > 50) and (not localObj:HasBuff("Frost Ward")) then
				if (CastSpellByName("Fire Ward", localObj)) then
					self.waitTimer = GetTimeEX() + 1700;
					script_grind:setWaitTimer(1700);
					return true;
				end
			end
		end

		-- remove curse
		if (HasSpell("Remove Lesser Curse")) and (script_checkDebuffs:hasCurse()) and (localMana > 10) then
			if (CastSpellByName("Remove Lesser Curse", localObj)) then
				self.waitTimer = GetTimeEX() + 1800;
				script_grind:setWaitTimer(1800);
				return true;
			end
		end
	end
	end	

-- Eat and Drink
	if (not IsDrinking() and localMana < self.drinkMana) then
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

		if (script_helper:drinkWater()) then 
			self.message = "Drinking..."; 
			return true; 
		else 
			self.message = "No drinks! (or drink not included in script_helper)";
			return true; 
		end
	end
	if (not IsEating() and localHealth < self.eatHealth) then
		-- Dismount
		if(IsMounted()) then DisMount(); end
		self.message = "Need to eat...";	
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
	
	if (localMana < self.drinkMana or localHealth < self.eatHealth) then
		if (IsMoving()) then
			StopMoving();
		end
		return true;
	end

	if (IsDrinking() and localMana >= 95 and not IsEating())
	or (IsEating() and localHealth >= 95 and not IsDrinking())
	or (IsDrinking() and IsEating() and localHealth >= 95 and localMana >= 95) then
		JumpOrAscendStart();
	end
	
	if (IsDrinking() or IsEating()) then
		self.message = "Resting to full hp/mana...";
		return true;
	end

	-- No rest / buff needed
	return false;
end

function script_mage.frostMagePull(targetObj)

	-- recheck line of sight on target
	if (not IsMounted()) and (not targetObj:IsInLineOfSight()) or (targetObj:GetDistance() > 31) and (PlayerHasTarget()) then
		return 3;
	else
		if (IsMoving()) then
			StopMoving();
		end
		if (PlayerHasTarget()) then
			targetObj:FaceTarget();
		end
		if (not IsMoving()) and (CastSpellByName("Frostbolt", targetObj)) then
			self.waitTimer = GetTimeEX() + 2300;
			script_grind:setWaitTimer(2300);
			if (PlayerHasTarget()) then
				targetObj:FaceTarget();
			end
			return true;
		end
	end
return false;
end

function script_mage.fireMagePull(targetObj)

	-- recheck line of sight on target
	if (not IsMounted()) and (not targetObj:IsInLineOfSight()) or (targetObj:GetDistance() > 31) and (PlayerHasTarget()) then
		return 3;
	else
		if (IsMoving()) then
			StopMoving();
		end
		if (HasSpell("Pyroblast")) then
			if (CastSpellByName("Pyroblast", targetObj)) then
				self.waitTimer = GetTimeEX() + 3000;
				script_grind:setWaitTimer(3000);
				if (PlayerHasTarget()) then
					targetObj:FaceTarget();
				end
				return true;
			end
		else
			if (CastSpellByName("Fireball", targetObj)) then
				self.waitTimer = GetTimeEX() + 3000;
				script_grind:setWaitTimer(3000);
				if (PlayerHasTarget()) then
					targetObj:FaceTarget();
				end
				return true;
			end
		end
	end
return false;
end
