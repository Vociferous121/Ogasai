script_hunter = {
	message = 'Hunter Combat Script',
	hunterExtra = include("scripts\\combat\\script_hunterEX.lua"),
	drinkMana = 30,
	eatHealth = 65,
	potionHealth = 10,
	potionMana = 15,
	feedTimer = 0,
	waitTimer = 0,
	hasPet = true,
	bagWithPetFood = 4,
	slotWithPetFood = GetContainerNumSlots(3), -- last slot in the bag
	foodName = 'PET FOOD NAME',
	stopWhenNoPetFood = false,
	quiverBagNr = 5,
	ammoIsArrow = true,
	useVendor = false,
	buyWhenQuiverEmpty = true,
	stopWhenQuiverEmpty = false,
	stopWhenBagsFull = true,
	hsWhenStop = false,
	hsBag = 1, -- HS in backpack (1rst bag)
	hsSlot = 1, -- HS in slot 1 of the bag: hsBag
	ammoName = 0,
	isSetup = false,
	isChecked = true,
	rangeDistance = 38,
	followTargetDistance = 38,
	useBandage = false,
	hasBandages = false,
	useFeedPet = true,
	meleeDistance = 6,
	useCheetah = true,
	useMarkMana = 45,
	useMark = true,
	useMultiShot = false,
	--useScorpidSting = false,
	waitAfterCombat = true,

}	


function script_hunter:setup()
	-- no more bug first time
	self.feedTimer = GetTimeEX();
	self.waitTimer = GetTimeEX();
	
	-- Save the name of ammo we use
	local bagSlots = GetContainerNumSlots(self.quiverBagNr-1);
	if (GetContainerItemLink(self.quiverBagNr-1, bagSlots)  ~= nil) then
		_,_,itemLink = string.find(GetContainerItemLink(self.quiverBagNr-1, bagSlots),"(item:%d+)");
		itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType,
   		itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemLink);
		self.ammoName = itemName;
	end

	--DEFAULT_CHAT_FRAME:AddMessage('script_hunter: Ammo name is set to: "' .. self.ammoName .. '" ...');
	if (not strfind(itemName, "Arrow")) then
	--	DEFAULT_CHAT_FRAME:AddMessage('script_hunter: Ammo will be bought at "Bullet" vendors...');
		script_vendor.itemIsArrow = false;
		self.ammoIsArrow = false;
		script_vendor.ammoName = itemName;
	else
	--	DEFAULT_CHAT_FRAME:AddMessage('script_hunter: Ammo will be bought at "Arrow" vendors...');
		script_vendor.ammoName = itemName;
		self.ammoIsArrow = true;
	end	

	-- Save the name of pet food we use
	if (GetContainerItemLink(self.bagWithPetFood-1, self.slotWithPetFood)  ~= nil) then
		local _, _, iLink = string.find(GetContainerItemLink(self.bagWithPetFood-1, self.slotWithPetFood), "(item:%d+)");
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType,
   		itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(iLink);
		self.foodName = itemName;
		--DEFAULT_CHAT_FRAME:AddMessage('script_hunter: Pet food name is set to: "' .. self.foodName .. '" ...');
	else
		--DEFAULT_CHAT_FRAME:AddMessage('script_hunter: Please set the pet food name in hunter options...');
	end

	if (GetLocalPlayer():GetLevel() < 3) then
		self.buyWhenQuiverEmpty = false;
	end

	self.isSetup = true;

end

function script_hunter:cast(spellName, target)
	if (HasSpell(spellName)) then
		if (target:IsSpellInRange(spellName)) then
			if (not IsSpellOnCD(spellName)) then
				if (not IsAutoCasting(spellName)) then
					target:TargetEnemy();
					if (targetObj:IsInLineOfSight()) then
						target:FaceTarget();
					elseif (target:CastSpell(spellName)) then
						return true;
					elseif (not target:CastSpell(spellName)) then
						return false;
					end
					return target:CastSpell(spellName);
				end
			end
		end
	end
	return false;
end

function script_hunter:enemiesAttackingMe() -- returns number of enemies attacking me
	local unitsAttackingUs = 0; 
	local currentObj, typeObj = GetFirstObject(); 
	while currentObj ~= 0 do 
    	if typeObj == 3 then
		if (currentObj:CanAttack() and not currentObj:IsDead()) then
                	if (script_grind:isTargetingMe(currentObj)) then 
                		unitsAttackingUs = unitsAttackingUs + 1; 
                	end 
            	end 
       	end
        currentObj, typeObj = GetNextObject(currentObj); 
    end
    return unitsAttackingUs;
end

-- Run backwards if the target is within range
function script_hunter:runBackwards(targetObj, range) 
	local localObj = GetLocalPlayer();
 	if (targetObj ~= 0) and (not script_checkDebuffs:hasDisabledMovement()) then
 		local xT, yT, zT = targetObj:GetPosition();
 		local xP, yP, zP = localObj:GetPosition();
 		local distance = targetObj:GetDistance();
 		local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
 		local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 		local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;		
 		local moveX, moveY, moveZ = xT + xUV*20, yT + yUV*20, zT + zUV;		
 		if (distance < range and targetObj:IsInLineOfSight()) then
 			script_navEX:moveToTarget(localObj, moveX, moveY, moveZ);
 			return true;
 		end
	end
	return false;
end

function script_hunter:draw()
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
			5 - targeted player pet/totem
 ]]--

function script_hunter:run(targetGUID)
	local localObj = GetLocalPlayer();
	local localMana = localObj:GetManaPercentage();
	local localHealth = localObj:GetHealthPercentage();
	local localLevel = localObj:GetLevel();

	if (localObj:IsDead()) then
		return 0;
	end

	-- Assign the target 
	targetObj = GetGUIDObject(targetGUID);

	if(targetObj == 0 or targetObj == nil) then
		ClearTarget();
		return 2;
	end

	-- Check: Do we have a pet?
	if (self.hasPet) then
		if (localLevel < 10) then
			self.hasPet = false;
		end
	end

	local pet = GetPet();
	local petHP = 0;
	if (pet ~= nil and pet ~= 0) then
		petHP = pet:GetHealthPercentage();
		local petMana = GetPet():GetManaPercentage();
		local petFocus = GetPet():GetFocus();
	end

	if (self.hasPet and not IsInCombat()) then
		if (script_hunterEX:petChecks()) then
			return 0;
		end
	end

	-- Check: Do nothing if we are channeling, casting or wait timer
	if (IsChanneling() or IsCasting() or self.waitTimer > GetTimeEX()) then
		return 4;
	end

	-- force bot to attack pets target
	if (IsInCombat()) and (GetPet() ~= 0) and (not PlayerHasTarget()) and (GetNumPartyMembers() < 1) and (self.hasPet) then
		if (PetHasTarget()) then
			if (GetPet():GetDistance() > 10) then
				AssistUnit("pet");
				PetFollow();
			end
		else
			AssistUnit("pet");
			return 4;
		end
	end

	-- pet not in line of sight
	if (GetPet() ~= 0) then
		if (IsInCombat()) and (not GetPet():IsInLineOfSight()) then
			PetFollow();
			return 3;

		end
	end
	
	-- stuck in combat
	if (self.waitAfterCombat)and (self.hasPet) and (IsInCombat()) and (GetPet() ~= 0) then
		if (not PlayerHasTarget()) and (not PetHasTarget()) and (GetNumPartyMembers() < 1) and (script_vendor.status == 0) then
			AssistUnit("pet");
			self.message = "No Target - stuck in combat! WAITING!";
			return 4;
		end
	end

	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(500, 1000);

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
	if (not IsMounted()) then
		script_hunterEX:chooseAspect(targetObj);
	end

	--Valid Enemy
	if (targetObj ~= 0 and targetObj ~= nil) then

		if (IsInCombat()) and (script_grind.skipHardPull) and (GetNumPartyMembers() == 0) then
			if (script_checkAdds:checkAdds()) then
				script_om:FORCEOM();
				return true;
			end
		end

		self.message = "Killing " .. targetObj:GetUnitName() .. "...";

		if (self.hasPet) and (not GetPet() ~= 0) then
			CallPet();
		end
		
		-- Cant Attack dead targets
		if (targetObj:IsDead() or not targetObj:CanAttack()) then
			self.waitTimer = GetTimeEX() + 1200;
			return 0;
		end

		-- Don't attack if we should rest first
		if (localHealth < self.eatHealth and not script_grind:isTargetingMe(targetObj)
			and targetHealth > 99 and not targetObj:IsStunned() and script_grind.lootobj ~= nil) then
			self.message = "Need rest...";
			return 4;
		end

		targetHealth = targetObj:GetHealthPercentage();

		if (not targetObj:IsFleeing()) and (not targetObj:IsInLineOfSight()) then
			if (not script_checkDebuffs:petDebuff()) then
				PetFollow();
			end
		end

		-- check line of sight
		if (not targetObj:IsInLineOfSight()) or (targetObj:GetDistance() > 32) then
			return 3;
		end

		-- face target
		if (targetObj:GetDistance() < 25) and (targetObj:IsInLineOfSight()) and (not IsMoving()) then
			if (not targetObj:FaceTarget()) then
				targetObj:FaceTarget();
			end
		end

		-- Auto Attack
		if (targetObj:GetDistance() < 35) and (targetObj:IsInLineOfSight()) then
			if (self.hasPet) then
				PetAttack();
			end
			targetObj:AutoAttack();
		end

		-- Check: if we target player pets/totems
		if (GetTarget() ~= 0) and (GetPet() ~= 0) then
			if (GetTarget():GetGUID() ~= GetLocalPlayer():GetGUID())
			and (GetTarget():GetGUID() ~= GetPet():GetGUID()) then
				if (UnitPlayerControlled("target")) then 
					script_grind:addTargetToBlacklist(targetObj:GetGUID());
					return 5; 
				end
			end
		end 

		-- check pet range
		if (GetPet() ~= 0) then
			if (self.hasPet) and (GetPet() ~= 0) and (GetPet():GetDistance() > 35) and (GetLocalPlayer():GetUnitsTarget() == 0) then 
				PetFollow();
			end
			if (self.hasPet) and (GetPet():GetDistance() <= 32) and (GetLocalPlayer():GetUnitsTarget() ~= 0) then 
				PetAttack();
				targetObj:AutoAttack();
			end
	
			if (self.hasPet) and (GetPet() ~= 0) and (targetObj:IsFleeing()) and (targetObj:GetCreatureType() == 'Humanoid') then
				PetFollow();
			end
		end
	

	-- NOT    in combat ---  do pull stuff

			if (GetLocalPlayer():GetLevel() < 10) then
				if (targetObj:GetDistance() > 11) and (targetObj:GetDistance() < 35) then
					script_hunter:hunterPull(targetObj);
				elseif (targetObj:GetDistance() <= 11) then
					if (targetObj:GetDistance() > 4) then
						return 3;
					end
				end
			end
						
	
			if (not IsInCombat()) and (targetObj:GetDistance() < 35) and (targetObj:GetDistance() >= 12) and (targetObj:IsInLineOfSight()) then
				script_hunter:hunterPull(targetObj);
				script_grind:setWaitTimer(1500);
				targetObj:FaceTarget();
				return;
			

		-- NOW IN COMBAT
			-----------------------------

		else


			self.message = "Killing " .. targetObj:GetUnitName() .. "...";

			if (not targetObj:IsInLineOfSight()) then
				return 3;
			end

			if (not HasSpell("War Stomp")) then
				CheckRacialSpells();
			end

			if (not targetObj:IsFleeing()) and (not targetObj:IsInLineOfSight()) then
				if (not script_checkDebuffs:petDebuff()) then
					PetFollow();
				end
			end

			-- force auto shot if in combat
			if (IsInCombat()) then
				if (not IsAutoCasting("Auto Shot")) and (targetObj:GetDistance() > 15) and (targetObj:GetDistance() < 30) and (targetObj:IsInLineOfSight()) then
					CastSpellByName("Auto Shot");
					targetObj:FaceTarget();
					PetAttack();
					return 0;
				end
			end
	
			-- Check: Use Healing Potion 
			if (localHealth <= self.potionHealth) then 
				if (script_helper:useHealthPotion()) then 
					return 0; 
				end 
			end
	
			-- Check: Use Mana Potion 
			if (localMana <= self.potionMana) then 
				if (script_helper:useManaPotion()) then 
					return 0; 
				end 
			end
	
			-- Check: Use Rapid Fire if we have adds
			if (script_grind:enemiesAttackingUs() > 1) and (HasSpell("Rapid Fire")) and (not IsSpellOnCD('Rapid Fire')) and (localMana > 10) then
				CastSpellByName('Rapid Fire');
				return 0;
			end
	
			-- Check: If pet is stunned, feared etc use Bestial Wrath
			if (self.hasPet) and (GetPet() ~= 0) and (GetPet() ~= nil) then
				if ((pet:IsStunned() or pet:IsConfused() or pet:IsFleeing()) and UnitExists("Pet") and HasSpell('Bestial Wrath')) then 
					if (script_hunter:cast('Bestial Wrath', targetObj)) then 
						return true; 
					end
				end
			end

			-- mend pet
			if (HasSpell("Mend Pet")) and (GetPet() ~= 0) then
				-- Check: Mend the pet if it has lower than 70% HP and out of combat
				if (script_hunter.hasPet) and (petHP < 50) and (petHP > 0) then	
					if (GetPet():GetDistance() > 20) then
						PetFollow();
						return true;
					
					elseif (GetPet():GetDistance() < 20) and (localMana >= 15) then
						if (script_hunter.hasPet) and (petHP < 60) and (petHP > 0) then
							script_hunter.message = "Pet has lower than 50% HP, mending pet...";	
							if (IsMoving()) or (not IsStanding()) then
								StopMoving();
								return true;
							end
							CastSpellByName('Mend Pet');
							script_hunter.waitTimer = GetTimeEX() + 1850; 
							return true;
						end
					end
				end
			end

			-- feign death if pet is dead
			if (self.hasPet) and (petHP < 1) then
				if (HasSpell("Feign Death")) and (not IsSpellOnCD("Feign Death")) and (localMana > 7) and (script_hunter:enemiesAttackingMe() > 1) then
					CastSpellByName("Feign Death");
					self.waitTimer = GetTimeEX() + 3850;
					return 0;
				end
			end

			--Racial
			if (not IsMoving()) and (targetObj:GetDistance() <= 6) then
				if (IsAutoCasting("Auto Attack")) then
					CheckRacialSpells();
					self.waitTimer = GetTimeEX() + 200;
					return 0;
				end
			end
		
			-- move backwards if target too close for melee attacks
			if (targetObj:GetDistance() < 0.50) then
				script_grind.tickRate = 135;
				script_rotation.tickRate = 135;
				if (script_hunter:runBackwards(targetObj, 2)) then
					self.waitTimer = GetTimeEX() + 1850;
					return 0;
				end
			end

	-- mend pet
			if (HasSpell("Mend Pet")) and (GetPet() ~= 0) then
				-- Check: Mend the pet if it has lower than 70% HP and out of combat
				if (script_hunter.hasPet) and (petHP < 50) and (petHP > 0) then	
					if (GetPet():GetDistance() > 20) then
						PetFollow();
						return true;
					
					elseif (GetPet():GetDistance() < 20) and (localMana >= 15) then
						if (script_hunter.hasPet) and (petHP < 60) and (petHP > 0) then
							script_hunter.message = "Pet has lower than 50% HP, mending pet...";	
							CastSpellByName('Mend Pet');
							script_hunter.waitTimer = GetTimeEX() + 1850; 
							return true;
						end
					end
				end
			end	

			-- follower 
			if (GetNumPartyMembers() > 0) then
				if (targetObj:GetDistance() <= 14) and (targetObj:IsInLineOfSight())
				and (targetObj:GetUnitsTarget() ~= 0)
				and (targetObj:GetUnitsTarget():GetGUID() ~= localObj:GetGUID()) then
					if (script_hunter:runBackwards(targetObj, 15)) then
						script_grind.tickRate = 100;
						script_rotation.tickRate = 135;
						PetAttack();
						self.message = "Moving away from target for range attacks...";
						return;
					end
				end
			end
			-- walk away from target if pet target guid is the same guid as target targeting me
			if (GetPet() ~= 0) and (self.hasPet) and (targetObj:GetDistance() <= 14) and (not script_grind:isTargetingMe(targetObj)) and (targetObj:GetUnitsTarget() ~= 0) and (not script_checkDebuffs:hasDisabledMovement()) and (targetObj:IsInLineOfSight()) then
				if (targetObj:GetUnitsTarget():GetGUID() == pet:GetGUID()) then

					if (script_hunter:runBackwards(targetObj, 15)) then
						script_grind.tickRate = 100;
						script_rotation.tickRate = 135;
						PetAttack();
						self.message = "Moving away from target for range attacks...";
						return 4;
					end
				end
			end

			if (targetObj:GetDistance() > 14) and (targetObj:GetDistance() < 35) then

				-- use Hunter's Mark first
				if (self.useMark) then
					if (HasSpell("Hunter's Mark")) and (not targetObj:HasDebuff("Hunter's Mark")) and (targetObj:IsInLineOfSight()) and (targetHealth >= 50) and (localMana >= self.useMarkMana) then
						CastSpellByName("Hunter's Mark");
						targetObj:FaceTarget();
						return 0;
					end
				end
		
				-- use concussive shot
				if (not IsSpellOnCD("Concussive Shot")) then
					if (HasSpell("Concussive Shot")) and (localMana > 25) and (targetObj:IsTargetingMe() or targetObj:IsFleeing()) then
						CastSpellByName("Concussive Shot");
						targetObj:FaceTarget();
						return 0;
					end	
				end

				-- use serpent sting
				if (not targetObj:HasDebuff("Serpent Sting")) and (not self.useScorpidSting) then
					if (HasSpell("Serpent Sting")) and (targetObj:IsInLineOfSight()) and (localMana >25) then	
						CastSpellByName("Serpent Sting");
						targetObj:FaceTarget();
						return 0;
					end
				end

				-- use arcane shot
				if (not IsSpellOnCD("Arcane Shot")) then
					if (HasSpell("Arcane Shot")) and (targetObj:IsInLineOfSight()) and (localMana > 15) then
						CastSpellByName("Arcane Shot");
						targetObj:FaceTarget();
						return 0;
					end
				end

				-- multi shot
				if (self.useMultiShot) then
					if (HasSpell("Multi-Shot")) and (not IsSpellOnCD("Multi-Shot")) and (localMana >= 25) then
						CastSpellByName("Multi-Shot");
						return 0;
					end
				end
	
				-- mend pet
			if (HasSpell("Mend Pet")) and (GetPet() ~= 0) then
				-- Check: Mend the pet if it has lower than 70% HP and out of combat
				if (script_hunter.hasPet) and (petHP < 50) and (petHP > 0) then	
					if (GetPet():GetDistance() > 20) then
						PetFollow();
						return true;
					
					elseif (GetPet():GetDistance() < 20) and (localMana >= 15) then
						if (script_hunter.hasPet) and (petHP < 60) and (petHP > 0) then
							script_hunter.message = "Pet has lower than 50% HP, mending pet...";	
							CastSpellByName('Mend Pet');
							script_hunter.waitTimer = GetTimeEX() + 1850; 
							return true;
						end
					end
				end
			end

			end

			-- melee attacks otherwise

			-- Auto Attack
			if (targetObj:GetDistance() < 14) then

			if (self.hasPet) and (not GetPet() ~= 0) then
				CallPet();
			end

			-- walk away from target if pet target guid is the same guid as target targeting me
			if (GetPet() ~= 0) and (self.hasPet) and (targetObj:GetDistance() <= 14)
				and (not script_grind:isTargetingMe(targetObj))
				and (targetObj:GetUnitsTarget() ~= 0)
				and (not script_checkDebuffs:hasDisabledMovement()) and (targetObj:IsInLineOfSight()) then
				if (targetObj:GetUnitsTarget():GetGUID() == pet:GetGUID()) then

					if (script_hunter:runBackwards(targetObj, 15)) then
						script_grind.tickRate = 100;
						script_rotation.tickRate = 135;
						PetAttack();
						self.message = "Moving away from target for range attacks...";
						return 4;
					end
				end
			end


				targetObj:AutoAttack();

				if (targetObj:GetDistance() > self.meleeDistance) and (GetNumPartyMembers() == 0) then
					return 3;
				end

				-- cast raptor strike
				if (HasSpell("Raptor Strike")) and (not IsSpellOnCD("Raptor Strike")) and (localMana > 10) then
						targetObj:FaceTarget();
					if (not IsSpellOnCD("Raptor Strike")) then
						targetObj:FaceTarget();
						if (CastSpellByName("Raptor Strike")) then
							targetObj:FaceTarget();
							return 0;
						end
					end
				end
					
				-- cast wing clip
				if (HasSpell("Wing Clip")) and (not IsSpellOnCD("Wing Clip")) and (localMana > 10) and (targetHealth < 35) then
					CastSpellByName("Wing Clip");
					return 0;
				end

			end -- melee auto attack

		end -- distance >12 <35

	end -- valid enemy	
			
end -- run function

function script_hunter:rest()

	local pet = GetPet();

	if (not self.isSetup) then
		script_hunter:setup();
	end

	if (IsInCombat()) and (not targetObj:IsTargetingMe()) then
		self.waitTimer = GetTimeEX() + 3500;
	end

	if (HasItem("Linen Bandage")) or 
		(HasItem("Heavy Linen Bandage")) or 
		(HasItem("Wool Bandage")) or 
		(HasItem("Heavy Wool Bandage")) or 
		(HasItem("Silk Bandage")) or 
		(HasItem("Heavy Silk Bandage")) or 
		(HasItem("Mageweave Bandage")) or 
		(HasItem("Heavy Mageweave Bandage")) or 
		(HasItem("Runecloth Bandage")) or 
		(HasItem("Heavy Runecloth Bandage")) then

		self.hasBandages = true;
	else
		self.hasBandages = false;
		self.useBandage = false;
	end

	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(500, 1000);

		if (IsMoving()) or (not IsInCombat()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom
		elseif (IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		end
	end

	local localObj = GetLocalPlayer();
	local localMana = localObj:GetManaPercentage();
	local localHealth = localObj:GetHealthPercentage();

	-- Stop moving before we can rest
	if(localHealth < self.eatHealth) or (localMana < self.drinkMana) then
		if (IsMoving()) then
			StopMoving();
			return true;
		end
	end

	-- if has bandage then use bandages
	if (self.hasBandages) and (self.useBandage) and (not IsMoving()) then
		if (not script_checkDebuffs:hasPoison()) and (not IsEating()) and (localHealth <= self.eatHealth) and (not localObj:HasDebuff("Recently Bandaged")) then
			if (IsMoving()) then
				StopMoving();
			end
			self.waitTimer = GetTimeEX() + 1200;
			if (IsStanding()) and (not IsInCombat()) and (not IsMoving()) and (not localObj:HasDebuff("Recently Bandaged")) then
				script_helper:useBandage()		
				self.waitTimer = GetTimeEX() + 6000;
			end
			
		end
	end

	-- Check: Let the feed pet duration last, don't engage new targets
	if (self.feedTimer > GetTimeEX()) and (self.useFeedPet) and (not IsInCombat()) and (self.hasPet) and (GetPet() ~= 0) then 
		self.message = "Feeding the pet, pausing...";
		if (GetPet():GetDistance() > 8) then
			PetFollow();
			self.waitTimer = GetTimeEX() + 1250;
			return true;
		end
		return true;
	end

	-- Eat and Drink
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

	if (not IsEating() and localHealth < self.eatHealth) then	
		self.message = "We need to eat...";
		if (IsMoving()) then
			StopMoving();
			self.waitTimer = GetTimeEX() + 1422;
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
	
	if(localMana < self.drinkMana or localHealth < self.eatHealth) then
		if (IsMoving()) then
			StopMoving();
		end
		return true;
	end

	-- night elve stealth while resting
	if (IsDrinking() or IsEating()) and (HasSpell("Shadowmeld")) and (not IsSpellOnCD("Shadowmeld")) and (not localObj:HasBuff("Shadowmeld")) then
		if (CastSpellByName("Shadowmeld")) then
			return 0;
		end
	end
	
	-- continue resting if eating or drinking
	if((localMana < 98 and IsDrinking()) or (localHealth < 98 and IsEating())) then
		self.message = "Resting, eating and/or drinking...";
		return true;
	end

	-- Check hunter bags if they are full
	local inventoryFull = true;
	-- Check bags 1-4, except the quiver bag (quiverBagNr)
	for i=1,4 do 
		if (i ~= self.quiverBagNr) then 
			for y=1,GetContainerNumSlots(i-1) do 
				local texture, itemCount, locked, quality, readable = GetContainerItemInfo(i-1,y);
				if (itemCount == 0 or itemCount == nil) then 
					inventoryFull = false; 
				end 
			end 
		end 
	end

	-- Tell the grinder we cant loot
	if (inventoryFull) then
		script_grind.bagsFull = true;
	end

	if (self.useVendor and inventoryFull) then
		script_vendor:sell();
		return false;
	end

	-- Check: If Mainhand is broken stop bot
	local isRangedBroken = GetInventoryItemBroken("player", 18);
	
	if (isRangedBroken and self.useVendor) then
		self.message = "Our weapon is broken, go to reapir...";
		script_vendor:repair();
		return false;
	end

	if (GetNumPartyMembers() == 0) and (not script_grind.useVendor) and (inventoryFull and self.stopWhenBagsFull) then
		self.message = "Inventory is full...";

		if (IsMoving()) then
			StopMoving();
		end
		
		if (self.hsWhenStop) then
			if (GetContainerItemCooldown(self.hsBag-1, self.hsSlot) == 0) then 
				UseItem('Hearthstone'); 
				self.message = "Inventory is full, using hearthstone...";
				return true; 
			else 
				Logout(); StopBot(); return true; 
			end 	
		end
		return true;
	end

	-- Quiver check : should we go buy ammo?
	if (self.buyWhenQuiverEmpty and self.ammoName ~= 0 and not IsInCombat()) then
		local ammoNr = 0;
		for y=1,GetContainerNumSlots(self.quiverBagNr-1) do
			local texture, itemCount, locked, quality, readable = GetContainerItemInfo(self.quiverBagNr-1,y);
			if (itemCount ~= nil) then 
				ammoNr = ammoNr + 1; 
			end 
		end

		-- Go buy ammo if we have just 1 stack of ammo left
		if (ammoNr <= 1 and self.ammoName ~= 0) then
			script_vendor:buyAmmo(self.quiverBagNr-1, self.ammoName, self.ammoIsArrow);
			return false;
		end 
	end

	-- Quiver check : Stop when out of ammo?
	if (self.stopWhenQuiverEmpty and not IsInCombat()) then
		local quiverEmpty = true;
		for y=1,GetContainerNumSlots(self.quiverBagNr-1) do
			local texture, itemCount, locked, quality, readable = GetContainerItemInfo(self.quiverBagNr-1,y);
			if (itemCount ~= nil) then 
				quiverEmpty = false; 
			end 
		end

		if (quiverEmpty and self.hsWhenStop) then
			if (GetContainerItemCooldown(self.hsBag-1, self.hsSlot) == 0) then 
				UseItem('Hearthstone'); 
				self.message = "Quiver is empty, using hearthstone...";
				return true; 
			else 
				Logout(); StopBot(); return true; 
			end 	
		end
		if (quiverEmpty) then
			Logout(); StopBot(); return true;
		end
	end

	-- Check pet food, change bag and/or slot if the stack ran out
	script_hunterEX:checkPetFood();

	-- Pet checks
	if (script_hunterEX:petChecks()) then return true; end

	-- Aspect check
	if (not IsMounted()) then if (script_hunterEX:chooseAspect(script_grind:getTarget())) then return false; end end

	-- No rest / buff needed
	if (self.needToRest) then
		self.waitTimer = GetTimeEX() + 500;
		self.message = "Need to rest!";
		return;
	end
	return false;
end

function script_hunter:hunterPull(targetObj)

			local localMana = GetLocalPlayer():GetManaPercentage();

			if (not targetObj:IsInLineOfSight()) then
				return 3;
			end

			if (GetPet() ~= 0) and (self.hasPet) and (not targetObj:IsFleeing()) and (not targetObj:IsInLineOfSight()) and (GetPet():GetDistance() > 15) then
				PetFollow();
			end

			if (self.hasPet) and (not IsMoving()) then
				PetAttack();
			end

			-- use Hunter's Mark
			if (self.useMark) and (localMana >= self.useMarkMana) and (not targetObj:HasDebuff("Hunter's Mark")) then
				if (GetLocalPlayer():GetUnitsTarget() ~= 0) and (targetObj:CanAttack()) and (not targetObj:IsDead()) and (HasSpell("Hunter's Mark")) then
					CastSpellByName("Hunter's Mark");
					PetAttack();
					targetObj:FaceTarget();
					self.waitTimer = GetTimeEX() + 1500;
					return 0;
				end
			end

			-- auto shot
			if (not IsAutoCasting("Auto Shot")) and (targetObj:IsInLineOfSight()) then
				CastSpellByName("Auto Shot");
				targetObj:FaceTarget();
				if (GetPet() ~= 0) and (self.hasPet) then
				PetAttack();
				end
				self.waitTimer = GetTimeEX() + 1500;
				script_grind:setWaitTimer(1500);
				return 0;
			end

			-- use concussive shot
			if (not IsSpellOnCD("Concussive Shot")) then
				if (HasSpell("Concussive Shot")) and (targetObj:IsInLineOfSight()) and (localMana > 20) then
					CastSpellByName("Concussive Shot");
					PetAttack();
					return 0;
				end
			end

			-- use serpent sting
			if (not targetObj:HasDebuff("Serpent Sting")) and (not self.useScorpidSting) then
				if (HasSpell("Serpent Sting")) and (targetObj:IsInLineOfSight()) and (localMana > 15) and (targetHealth > 30) then
					CastSpellByName("Serpent Sting");
					PetAttack();
					return 0;
				end
			end

			-- use Scorpid Sting
			--if (not targetObj:HasDebuff("Scorpid Sting")) then
			--	if (HasSpell("Scorpid Sting")) and (targetObj:IsInLineOfSight()) and (localMana > 20) and (targetHealth > 30) then
			--		CastSpellByName("Scorpid Sting");
			--		PetAttack();
			--		return 0;
			--	end
			--end
					
			-- use arcane shot
			if (not IsSpellOnCD("Arcane Shot")) then
				if (HasSpell("Arcane Shot")) and (targetObj:IsInLineOfSight()) and (localMana > 10) then
					CastSpellByName("Arcane Shot");
					return 0;
				end
			end

			if (not self.hasPet) then
				if (targetObj:GetDistance() < 12) then
					targetObj:AutoAttack();
				else
					return 3;
				end
			end
	return;
end