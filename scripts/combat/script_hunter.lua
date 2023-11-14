script_hunter = {
	message = 'Hunter Combat Script',
	hunterExtra = include("scripts\\combat\\script_hunterEX.lua"),
	drinkMana = 30,
	eatHealth = 65,
	potionHealth = 10,
	potionMana = 20,
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
	waitAfterCombat = 8,
	useFeedPet = true,
	meleeDistance = 5,
	useCheetah = false,
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

	DEFAULT_CHAT_FRAME:AddMessage('script_hunter: Ammo name is set to: "' .. self.ammoName .. '" ...');
	if (not strfind(itemName, "Arrow")) then
		DEFAULT_CHAT_FRAME:AddMessage('script_hunter: Ammo will be bought at "Bullet" vendors...');
		script_vendor.itemIsArrow = false;
		self.ammoIsArrow = false;
		script_vendor.ammoName = itemName;
	else
		DEFAULT_CHAT_FRAME:AddMessage('script_hunter: Ammo will be bought at "Arrow" vendors...');
		script_vendor.ammoName = itemName;
		self.ammoIsArrow = true;
	end	

	-- Save the name of pet food we use
	if (GetContainerItemLink(self.bagWithPetFood-1, self.slotWithPetFood)  ~= nil) then
		local _, _, iLink = string.find(GetContainerItemLink(self.bagWithPetFood-1, self.slotWithPetFood), "(item:%d+)");
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType,
   		itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(iLink);
		self.foodName = itemName;
		DEFAULT_CHAT_FRAME:AddMessage('script_hunter: Pet food name is set to: "' .. self.foodName .. '" ...');
	else
		DEFAULT_CHAT_FRAME:AddMessage('script_hunter: Please set the pet food name in hunter options...');
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
 	if targetObj ~= 0 then
 		local xT, yT, zT = targetObj:GetPosition();
 		local xP, yP, zP = localObj:GetPosition();
 		local distance = targetObj:GetDistance();
 		local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
 		local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 		local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;		
 		local moveX, moveY, moveZ = xT + xUV*20, yT + yUV*20, zT + zUV;		
 		if (distance < range and targetObj:IsInLineOfSight()) then 
 			script_nav:moveToTarget(localObj, moveX, moveY, moveZ);
 			return true;
 		end
	end
	return false;
end

function script_hunter:draw()
	local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
	if (onScreen) then
		DrawText(self.message, tX+75, tY+44, 255, 250, 205);
	else
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
	local playerHasTarget = GetLocalPlayer():GetUnitsTarget();

	if (pet ~= nil and pet ~= 0) then
		petHP = pet:GetHealthPercentage();
		local petMana = GetPet():GetManaPercentage();
		local petFocus = GetPet():GetFocus();
		local petHasTarget = GetPet():GetUnitsTarget();
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
	if (IsInCombat()) and (playerHasTarget == 0) then
		if (petHasTarget ~= 0) then
			TargetNearestEnemy();
		else
			return 4;
		end
	end

	if (IsInCombat()) and (playerHasTarget == 0) then
		if (petHasTarget == 0) then
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

	script_hunterEX:chooseAspect(targetObj);

	--Valid Enemy
	if (targetObj ~= 0 and targetObj ~= nil) then

		self.message = "Killing " .. targetObj:GetUnitName() .. "...";
		
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

		-- check line of sight
		if (not targetObj:IsInLineOfSight()) or (targetObj:GetDistance() > 32) then
			return 3;
		end

		if (targetObj:GetDistance() < 25) and (targetObj:IsInLineOfSight()) and (not IsMoving()) then
			if (not targetObj:FaceTarget()) then
				targetObj:FaceTarget();
			end
		end

		-- Auto Attack
		if (targetObj:GetDistance() < 42) then
			targetObj:AutoAttack();
			if (not IsMoving()) and (self.hasPet) and (GetLocalPlayer():GetUnitsTarget() ~= 0) then
				PetAttack();
			end
		end

		-- Check: if we target player pets/totems
		if (GetTarget() ~= nil and targetObj ~= nil) then
			if (UnitPlayerControlled("target") and GetTarget() ~= localObj) then 
				script_grind:addTargetToBlacklist(targetObj:GetGUID());
				return 5; 
			end
		end 

		-- check pet range
		if (self.hasPet) and (GetPet() ~= 0) then 
			if (GetPet():GetDistance() > 30) and (GetLocalPlayer():GetUnitsTarget() == 0) then 
				PetFollow();
			end
		elseif (self.hasPet) and (GetPet():GetDistance() <= 30) and (GetLocalPlayer():GetUnitsTarget() ~= 0) then 
			PetAttack();
			targetObj:AutoAttack();
		end
	
	-- not in combat do pull stuff

	if (not IsInCombat()) and (targetObj:GetDistance() < 35) and (targetObj:GetDistance() > 15) then

			if (targetObj:GetDistance() > 30) or (not targetObj:IsInLineOfSight()) then
				return 3;
			end

			if (self.hasPet) and (not IsMoving()) then
				PetAttack();
				self.waitTimer = GetTimeEX() + 250;
			end

			-- use hunters mark
			if (GetLocalPlayer():GetUnitsTarget() ~= 0) and (targetObj:CanAttack()) and (not targetObj:IsDead()) and (HasSpell("Hunter's Mark")) and (not targetObj:HasDebuff("Hunter's Mark")) then
				CastSpellByName("Hunter's Mark");
				PetAttack();
				targetObj:FaceTarget();
				self.waitTimer = GetTimeEX() + 1500;
				return 0;
			end

			-- auto shot
			if (not IsAutoCasting("Auto Shot")) and (targetObj:IsInLineOfSight()) then
				CastSpellByName("Auto Shot");
				targetObj:FaceTarget();
				PetAttack();
				return 0;
			end

			-- use concussive shot
			if (HasSpell("Concussive Shot")) and (not IsSpellOnCD("Concussive Shot")) and (targetObj:IsInLineOfSight()) then
				CastSpellByName("Concussive Shot");
				PetAttack();
				return 0;
			end

			-- use serpent sting
			if (HasSpell("Serpent Sting")) and (not targetObj:HasDebuff("Serpent Sting")) and (targetObj:IsInLineOfSight()) then
				CastSpellByName("Serpent Sting");
				PetAttack();
				return 0;
			end
	
			-- use arcane shot
			if (HasSpell("Arcane Shot")) and (not IsSpellOnCD("Arcane Shot")) and (targetObj:IsInLineOfSight()) then
				CastSpellByName("Arcane Shot");
				return 0;
			end

			if (not self.hasPet) then
				if (targetObj:GetDistance() < 10) then
					targetObj:AutoAttack();
				else
					return 3;
				end
			end
			
		-- NOW IN COMBAT
			-----------------------------

		else	

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
		if (script_grind:enemiesAttackingUs() > 1 and HasSpell('Rapid Fire') and not IsSpellOnCD('Rapid Fire')) then
			CastSpellByName('Rapid Fire');
			return 0;
		end

		-- Check: If pet is stunned, feared etc use Bestial Wrath
		if (self.hasPet and GetPet() ~= 0 and GetPet() ~= nil) then
			if ((pet:IsStunned() or pet:IsConfused() or pet:IsFleeing()) and UnitExists("Pet") and HasSpell('Bestial Wrath')) then 
				if (script_hunter:cast('Bestial Wrath', targetObj)) then 
					return true; 
				end
			end
		end

		-- mend pet
		if (script_hunter:mendPet(localMana, petHP)) then
			self.waitTimer = GetTimeEX() + 3850;
			return 0;
		end

		-- feign death if pet is dead
		if (self.hasPet) and (petHP < 1) and (HasSpell("Feign Death")) and (not IsSpellOnCD("Feign Death")) and (script_hunter:enemiesAttackingMe() > 1) then
			CastSpellByName("Feign Death");
			self.waitTimer = GetTimeEX() + 3850;
			return 0;
		end

		-- War Stomp Tauren Racial
		if (HasSpell("War Stomp")) and (not IsSpellOnCD("War Stomp")) and (not IsMoving()) and (targetObj:GetDistance() <= 6) then
			if (targetObj:IsCasting()) or (targetObj:IsFleeing()) or (localLevel < 10) and (IsAutoCasting("Auto Attack")) then
				CastSpellByName("War Stomp");
				self.waitTimer = GetTimeEX() + 200;
				return 0;
			end
		end
		
		-- move backwards if target too close for melee attacks
		if (targetObj:GetDistance() < 0.50) then
			if (script_hunter:runBackwards(targetObj, 2)) then
				self.waitTimer = GetTimeEX() + 1850;
				return 0;
			end
		end		

		-- walk away from target if pet target guid is the same guid as target targeting me
		if (targetObj:GetDistance() <= 14) and (not script_grind:isTargetingMe(targetObj)) and (targetObj:GetUnitsTarget() ~= 0) then
			if (targetObj:GetUnitsTarget():GetGUID() == pet:GetGUID()) then

				script_grind.tickRate = 100;
				local randomMoveBack = math.random(14, 18);

				if (script_hunter:runBackwards(targetObj, randomMoveBack)) then
					PetAttack();
					self.message = "Moving away from target for range attacks...";
					return 4;
				end
			end
		end

		if (targetObj:GetDistance() > 15) and (targetObj:GetDistance() < 35) then
		-- use hunter's mark first
		if (HasSpell("Hunter's Mark")) and (not targetObj:HasDebuff("Hunter's Mark")) and (targetObj:IsInLineOfSight()) and (targetHealth >= 50) then
			CastSpellByName("Hunter's Mark");
			targetObj:FaceTarget();
			return 0;
		end
	
		-- use concussive shot
		if (HasSpell("Concussive Shot")) and (not IsSpellOnCD("Concussive Shot")) and (targetObj:IsTargetingMe()) then
			CastSpellByName("Concussive Shot");
			targetObj:FaceTarget();
			return 0;
		end

		-- use serpent sting
		if (HasSpell("Serpent Sting")) and (not targetObj:HasDebuff("Serpent Sting")) and (targetObj:IsInLineOfSight()) then
			CastSpellByName("Serpent Sting");
			targetObj:FaceTarget();
			return 0;
		end
	
		-- use arcane shot
		if (HasSpell("Arcane Shot")) and (not IsSpellOnCD("Arcane Shot")) and (targetObj:IsInLineOfSight()) then
			CastSpellByName("Arcane Shot");
			targetObj:FaceTarget();
			return 0;
		end

		-- mend pet
		if (script_hunter:mendPet(localMana, petHP)) then
			self.waitTimer = GetTimeEX() + 3850;
			return 0;
		end

		end

		-- Auto Attack
		if (targetObj:GetDistance() <= self.meleeDistance) then
			if (not targetObj:AutoAttack()) then
				targetObj:AutoAttack();
			end

			-- cast raptor strike
			if (HasSpell("Raptor Strike")) and (not IsSpellOnCD("Raptor Strike")) and (localMana > 10) then
				CastSpellByName("Raptor Strike");
				return 0;
			end
					
			-- cast wing clip
			if (HasSpell("Wing Clip")) and (not IsSpellOnCD("Wing Clip")) and (localMana > 10) and (targetHealth < 35) then
				CastSpellByName("Wing Clip");
				return 0;
			end
		end
	end
	end			
			
end

function script_hunter:mendPet(localMana, petHP)
	local mendPet = HasSpell("Mend Pet");
	if (mendPet) and (IsInCombat()) and (self.hasPet) and (petHP > 0) then
		if (GetPet():GetHealthPercentage() < 35) then

			script_grind.tickRate = 100;
			self.message = "Pet has lower than 35% HP, mending pet...";

			-- Check: If in range to mend the pet 
			if (GetPet():GetDistance() < 20) and (localMana > 10) and (GetPet():IsInLineOfSight()) then 
				if (IsMoving()) then
					StopMoving();
					return true;
				end 

				CastSpellByName("Mend Pet"); 
				self.waitTimer = GetTimeEX() + 3850;
				return true;

			elseif (localMana > 10) then 
				script_nav:moveToTarget(GetLocalPlayer(), GetPet():GetPosition()); 
				return true; 
			end 
			
		end
	end
	return false;
end

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
	if(localHealth < self.eatHealth or localMana < self.drinkMana) then
		if (IsMoving()) then
			StopMoving();
			return true;
		end
	end

	-- if has bandage then use bandages
	if (self.hasBandages) and (self.useBandage) and (not IsMoving()) then
		if (not localObj:HasDebuff("Creeping Mold")) and (not IsEating()) and (localHealth <= self.eatHealth) and (not localObj:HasDebuff("Recently Bandaged")) and (not localObj:HasDebuff("Poison")) then
		if (IsMoving()) then
			StopMoving();
		end
			self.waitTimer = GetTimeEX() + 1200;
		if (IsStanding()) and (not IsInCombat()) and (not IsMoving()) and (not localObj:HasDebuff("Recently Bandaged")) then
			script_helper:useBandage()		
			self.waitTimer = GetTimeEX() + 6000;
		end
		return 0;
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

		self.message = "We need to drink...";
		if (IsMoving()) then
			StopMoving();
			return true;
		end

		if (localMana < self.drinkMana) or (localHealth < self.eatHealth) then
			self.waitTimer = GetTimeEX() + 1422;
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
		self.waitTimer = GetTimeEX() + 1200;
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

	if (not script_grind.useVendor) and (inventoryFull and self.stopWhenBagsFull) then
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