script_hunterEX = {

	
}

function script_hunterEX:chooseAspect(targetObj)

	local localObj = GetLocalPlayer();
	local localHealth = localObj:GetHealthPercentage();
	local localMana = localObj:GetManaPercentage();
	local localLevel = localObj:GetLevel();

	if (not IsStanding()) then 
		return false;
	end

	hasHawk = HasSpell("Aspect of the Hawk");
	hasMonkey = HasSpell("Aspect of the Monkey");
	hasCheetah = HasSpell("Aspect of the Cheetah");
	
	if (hasMonkey) and (localObj:GetLevel() < 10) then 
		if (not localObj:HasBuff('Aspect of the Monkey')) then  
			CastSpellByName('Aspect of the Monkey'); 
			return true; 
		end	
	elseif (hasMonkey) and (targetObj ~= nil) and (not targetObj ~= 0) then
		if (targetObj:GetDistance() <= 5) and (IsInCombat()) and (localHealth <= 50) then
			if (not localObj:HasBuff('Aspect of the Monkey')) then  
				CastSpellByName('Aspect of the Monkey'); 
				return true; 
			end
		else
			if (hasHawk) and (targetObj:GetDistance() <= 37) and (not targetObj:IsDead()) and (targetObj:CanAttack()) then 
				if (not localObj:HasBuff('Aspect of the Hawk')) then 
					CastSpellByName('Aspect of the Hawk'); 
					return true; 
				end 
			end
		end
	elseif (script_hunter.useCheetah) and (hasCheetah) and (not IsInCombat()) and (targetObj == nil) and (localMana > script_hunter.drinkMana + 10) then 
		if (not localObj:HasBuff('Aspect of the Cheetah')) then 
			CastSpellByName('Aspect of the Cheetah'); 
			return true;  
		end 
	end
	return false;
end

function script_hunterEX:petChecks()
	local localObj = GetLocalPlayer();
	local localMana = localObj:GetManaPercentage();
	local pet = GetPet();
	local petHP = 0;

	if (pet ~= nil and pet ~= 0) then
		petHP = pet:GetHealthPercentage();
	end
	
	-- has pet check
	if (localObj:GetLevel() < 10) then
		script_hunter.hasPet = false;
	end

	-- Check: If pet is dismissed then Call pet 
	if (GetPet() == 0) and (script_hunter.hasPet) and (IsStanding()) then
		script_hunter.message = "Pet is missing, calling pet...";
		if (IsMoving()) or (not IsStanding()) then
			StopMoving();
		end
		CallPet();
		script_hunter.waitTimer = GetTimeEX() + 1850;
		return true;
	end

	-- Check: If pet is dead, then revive pet
	if (script_hunter.hasPet) and (GetPet():IsDead()) and (not IsInCombat()) and (HasSpell("Revive Pet")) then	
		script_hunter.message = "Pet is dead, reviving pet...";
		if (IsMoving()) or (not IsStanding()) then 
			StopMoving(); 
			return true; 
		end
		CastSpellByName("Call Pet");
		if (localMana > 60) then 
			CastSpellByName('Revive Pet'); 
			script_hunter.waitTimer = GetTimeEX() + 1850;
			return true; 
		else 
			script_hunter.message = "Pet is dead, need more mana to ress it...";
			return true; 
		end
	end

	-- Check: Stop if we ran out of pet food in the "pet food slot"
	if (script_hunter.stopWhenNoPetFood) and (script_hunter.hasPet) and (not IsInCombat()) then

		local texture, itemCount, locked, quality, readable = GetContainerItemInfo(script_hunter.bagWithPetFood-1, script_hunter.slotWithPetFood);

		if (itemCount == nil) then
			script_hunter.message = "No more pet food, stopping the bot..."; 
			if (IsMoving() or not IsStanding()) then
				StopMoving();
				return true;
			end
			if (GetContainerItemCooldown(script_hunter.hsBag-1, script_hunter.hsSlot) == 0 and script_hunter.hsWhenStop) then 
				UseItem('Hearthstone'); 
				script_hunter.waitTimer = GetTimeEX() + 1850; 
				return true; 
			else 
				Logout(); 
				StopBot(); 
				return true;  
			end 
		end
	end

	-- Check: If pet isn't happy, feed it 
	if (petHP > 0) and (script_hunter.hasPet) and (script_hunter.useFeedPet) then
	
		local happiness, damagePercentage, loyaltyRate = GetPetHappiness();

		if (not GetPet():IsDead()) and (script_hunter.feedTimer < GetTimeEX()) and (not IsInCombat()) then
			if (happiness < 3 or loyaltyRate < 0) and (GetPet():GetDistance() <= 8) and (not IsInCombat()) then
				script_hunter.message = "Pet is not happy, feeding the pet...";
				if (not IsStanding()) then
					StopMoving();
					return true;
				end
				CastSpellByName("Feed Pet"); 
				TargetUnit("Pet"); 
				PickupContainerItem(script_hunter.bagWithPetFood-1, script_hunter.slotWithPetFood);

				-- Set a 20 seconds timer for this check (Feed Pet duration)
					script_hunter.feedTimer = GetTimeEX() + 20000; 
					script_hunter.waitTimer = GetTimeEX() + 1850; 
				return true;
			end
		end
	end	

	-- If we have the skill Mend Pet
	local mendPet = HasSpell("Mend Pet");

	if (mendPet) then
		-- Check: Mend the pet if it has lower than 70% HP and out of combat
		if (script_hunter.hasPet) and (petHP < 60) and (petHP > 0) and (not IsInCombat()) then
			if (GetPet():GetDistance() > 8) then
				PetFollow();
				script_hunter.waitTimer = GetTimeEX() + 1850; 
				return true;
			end
			if (GetPet():GetDistance() < 20) and (localMana > 10) then
				if (script_hunter.hasPet) and (petHP < 60) and (not IsInCombat()) and (petHP > 0) then
					script_hunter.message = "Pet has lower than 60% HP, mending pet...";
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
	return false;
end

function script_hunterEX:checkPetFood()

	-- Check for pet food, change bag/slot if we have too
	if (GetContainerItemLink(script_hunter.bagWithPetFood-1, script_hunter.slotWithPetFood)  == nil) then
		bagNr = 0;
		bagSlot = 0;
		for i = 0, 4 do
			if i ~= script_hunter.quiverBagNr-1 then
				for y = 0, GetContainerNumSlots(i) do
					if (GetContainerItemLink(i, y) ~= nil) then
						local _, _, iLink = string.find(GetContainerItemLink(i, y), "(item:%d+)");
						local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType,
   							itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(iLink);
						if (script_hunter.foodName == itemName) then
							script_hunter.bagWithPetFood = i+1;
							script_hunter.slotWithPetFood = y;
							break;
						end
					end
				end
			end
		end
	end
end

function script_hunterEX:menu()

		local wasClicked = false;

	if (CollapsingHeader("Hunter Combat Options")) then

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
		
			self.menuBandages = true;
		else
			self.menuBandages = false;
		end
		
		if (self.menuBandages) or (GetLocalPlayer():GetLevel() >= 10) then
			Separator();
		end

		if (GetLocalPlayer():GetLevel() >= 10) then
			wasClicked, script_hunter.hasPet = Checkbox("Use Pet", script_hunter.hasPet);
		end

		if (self.menuBandages) then
			SameLine();
			wasClicked, script_hunter.useBandage = Checkbox("Use Bandages", script_hunter.useBandage);
		end

		if (HasSpell("Aspect of the Cheetah")) then
			Separator();
			wasClicked, script_hunter.useCheetah = Checkbox("Use Cheetah", script_hunter.useCheetah);
		end

		SameLine();
		if (GetPet() ~= 0) and (GetLocalPlayer():GetLevel() >= 10) then
			wasClicked, script_hunter.waitAfterCombat = Checkbox("Wait After Combat", script_hunter.waitAfterCombat);
		end
		Separator();

		Text('Drink below mana percentage');
		script_hunter.drinkMana = SliderInt("M%", 1, 100, script_hunter.drinkMana);

		Text('Eat below health percentage');
		script_hunter.eatHealth = SliderInt("H%", 1, 100, script_hunter.eatHealth);

		Text('Use health potions below percentage');
		script_hunter.potionHealth = SliderInt("HP%", 1, 99, script_hunter.potionHealth);

		Text('Use mana potions below percentage');
		script_hunter.potionMana = SliderInt("MP%", 1, 99, script_hunter.potionMana);

		Separator();

		if (HasSpell("Hunter's Mark")) then
			wasClicked, script_hunter.useMark = Checkbox("Use Hunter's Mark", script_hunter.useMark);
			if (script_hunter.useMark) then
				Text("Use Hunter Mark above mana percentage");
				script_hunter.useMarkMana = SliderInt("MM", 5, 100, script_hunter.useMarkMana);
			end
		end

		if (HasSpell("Multi-Shot")) then
			wasClicked, script_hunter.useMultiShot = Checkbox("Use MultiShot", script_hunter.useMultiShot);
		end

		--if (HasSpell("Scorpid Sting")) then
		--	SameLine();
		--	wasClicked, script_hunter.useScorpidSting = Checkbox("Scorpid Sting", script_hunter.useScorpidSting);
		--end

		if (CollapsingHeader("|+| Vendor Settings -- These May Be Defunct")) then
			Text('Vendor/Bag settings:');
			wasClicked, script_hunter.useVendor = Checkbox("Vendor when full inventory", script_hunter.useVendor);	
		
			if (script_grind.useVendor) then
				script_hunter.useVendor = true;
			end
			if (script_hunter.useVendor) then
				script_grind.useVendor = true;
			end
			if (script_hunter.useVendor) or (script_grind.useVendor) then
				script_hunter.stopWhenBagsFull = false;
			end
		end

		if (CollapsingHeader("|+| Buy Ammo")) then
			wasClicked, script_hunter.buyWhenQuiverEmpty = Checkbox("Buy ammo when only 1 stack left.", script_hunter.buyWhenQuiverEmpty);

			if (script_hunter.buyWhenQuiverEmpty) then
				script_hunter.quiverBagNr = InputText("Bag# for quiver (2-5)", script_hunter.quiverBagNr);
			end
		end

		Separator();

		if (CollapsingHeader("|+| Feed Pet Options")) then
			wasClicked, script_hunter.useFeedPet = Checkbox("Auto Feed Pet", script_hunter.useFeedPet);
	
			if (script_hunter.hasPet) and (script_hunter.useFeedPet) then	

				Text('Always put the pet food in the last slot of the bag.');

				Text("Bag # with pet food (2-5)");
				script_hunter.bagWithPetFood = InputText("BPF", script_hunter.bagWithPetFood);
	
				Text("Bagslot# with pet food (1-Maxslot)");
				script_hunter.slotWithPetFood = InputText("SPF", script_hunter.slotWithPetFood);

				Text("Pet Food Name:");
				script_hunter.foodName = InputText("PFN", script_hunter.foodName);

				Separator();
			end
		end

		Separator();	
		
		if (CollapsingHeader("|+| Stop Hunter Settings")) then

			Text('Stop settings:');

			wasClicked, script_hunter.stopWhenBagsFull = Checkbox("Stop when bags are full", script_hunter.stopWhenBagsFull);

			wasClicked, script_hunter.stopWhenQuiverEmpty = Checkbox("Stop when we run out of ammo", script_hunter.stopWhenQuiverEmpty);
		
			if (script_hunter.hasPet) then

				wasClicked, script_hunter.stopWhenNoPetFood = Checkbox("Stop when we run out of pet food", script_hunter.stopWhenNoPetFood);

			end
		
			wasClicked, script_hunter.hsWhenStop = Checkbox("Use HS before stopping the bot, if not on CD", script_hunter.hsWhenStop);

			if (script_hunter.hsWhenStop) then

				script_hunter.hsBag = InputText("Bag# for HS", script_hunter.hsBag);

				script_hunter.hsSlot = InputText("Bag-slot (1-X) for HS", script_hunter.hsSlot);
			end
		end
	end
end