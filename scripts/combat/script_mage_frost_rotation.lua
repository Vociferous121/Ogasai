script_mage = {
	message = 'Frost Mage Rotation',
	drinkMana = 40,
	eatHealth = 51,
	potionHealth = 10,
	potionMana = 20,
	water = {},
	numWater = 0,
	food = {},
	numfood = 0,
	manaGem = {},
	numGem = 0,
	isSetup = false,
	polyTimer = 0,
	cooldownTimer = 0,
	addPolymorphed = false,
	useManaShield = true,
	iceBlockHealth = 35,
	iceBlockMana = 25,
	evocationMana = 15,
	evocationHealth = 35,
	manaGemMana = 20,
	polymorphAdds = true,
	useFireBlast = true,
	useFrostNova = true,
	useConeofCold = true,
	coneOfColdMana = 35,
	coneOfColdHealth = 15,
	useQuelDoreiMeditation = true,
	QuelDoreiMeditationMana = 22,
	useWandMana = 20,
	useWandHealth = 20,
	manaShieldHealth = 80,
	manaShieldMana = 20,
	useFrostWard = false,
	useFireWard = false,
	
	waitTimer = 0,
	useWand = true,
	gemTimer = 0,
	isChecked = true
}

function script_mage:window()

	if (self.isChecked) then
	
		--Close existing Window
		EndWindow();

		if(NewWindow("Class Combat Options", 200, 200)) then
			script_mage:menu();
		end
	end
end

function script_mage:cast(spellName, target)
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

function script_mage:ConeofCold(spellName)
	if (HasSpell(spellName)) then
			if (not IsSpellOnCD(spellName)) then
				if (not IsAutoCasting(spellName)) then
					CastSpellByName(spellName);
				end
			end
		end
	return false;
end

function script_mage:addWater(name)
	self.water[self.numWater] = name;
	self.numWater = self.numWater + 2;
end

function script_mage:addFood(name)
	self.food[self.numfood] = name;
	self.numfood = self.numfood + 2;
end

function script_mage:addManaGem(name)
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

	self.isSetup = true;
end

function script_mage:draw()
	--script_mage:window();
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
			5 - targeted player pet/totem  ]]--

function script_mage:run(targetGUID)
	
	if(not self.isSetup) then
		script_mage:setup();
	end
	
	local localObj = GetLocalPlayer();
	local localMana = localObj:GetManaPercentage();
	local localHealth = localObj:GetHealthPercentage();
	local localLevel = localObj:GetLevel();
	
	if (localObj:IsDead()) then
		return 0;
	end
	
	-- Assign the target 
	targetObj =  GetGUIDObject(targetGUID);

	if(targetObj == 0 or targetObj == nil or targetObj:IsDead()) then
		ClearTarget();
		return 2;
	end

	-- Check: Do nothing if we are channeling, casting or Ice Blocked
	if (IsChanneling() or IsCasting() or localObj:HasBuff('Ice Block') or self.waitTimer > GetTimeEX()) then
		return 4;
	end

	--Valid Enemy
	if (targetObj ~= 0 and targetObj ~= nil) then
		
		-- Cant Attack dead targets
		if (targetObj:IsDead() or not targetObj:CanAttack()) then
			ClearTarget();
			return 2;
		end
		
		if (not IsStanding()) then
			StopMoving();
		end

		-- Don't attack if we should rest first
		if ((localHealth < self.eatHealth or localMana < self.drinkMana) and not script_grind:isTargetingMe(targetObj)
			and not targetObj:IsFleeing() and not targetObj:IsStunned() and not script_mage:isAddPolymorphed()) then
			self.message = "Need rest...";
			return 4;
		end

		targetHealth = targetObj:GetHealthPercentage();

		-- Auto Attack
		if (targetObj:GetDistance() < 40) then
			targetObj:AutoAttack();
		end
		
		-- Opener
		if (not IsInCombat()) then
			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";

			-- Opener spell
			if (HasSpell("Frostbolt")) then
				if(not targetObj:IsSpellInRange('Frostbolt') or not targetObj:IsInLineOfSight())  then
					return 3;
				end

				-- Check: If in range and in line of sight stop moving
				if (targetObj:IsInLineOfSight()) then
					if(IsMoving()) then StopMoving(); end
				end

				if (script_mage:cast('Frostbolt', targetObj)) then
					self.waitTimer = GetTimeEX() + 200;
					return 0;
				end

				if (not targetObj:IsInLineOfSight()) then
					return 3;
				end
				return 0;
			end
			
		-- Combat
		else	
			self.message = "Killing " .. targetObj:GetUnitName() .. "...";

			-- Check: Keep Ice Barrier up if possible
			if (HasSpell("Ice Barrier") and not IsSpellOnCD("Ice Barrier") and not localObj:HasBuff("Ice Barrier")) then
					CastSpellByName('Ice Barrier');
					return 0;
			-- Check: If we have Cold Snap use it to clear the Ice Barrier CD
			--elseif (HasSpell("Ice Barrier") and IsSpellOnCD("Ice Barrier") and HasSpell('Cold Snap') and not IsSpellOnCD("Cold Snap") and not localObj:HasBuff('Ice Barrier')) then
					--CastSpellByName('Cold Snap');
					--return 0;
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
			if (localMana < self.evocationMana and localHealth > self.evocationHealth and HasSpell("Evocation") and not IsSpellOnCD("Evocation")) then		
				self.message = "Using Evocation...";
				CastSpellByName("Evocation"); 
				return 0;
			end
			-- Use Quel'dorei Meditation if we have low Mana
			if (localMana < self.QuelDoreiMeditationMana and HasSpell("Quel'dorei Meditation") and not IsSpellOnCD("Quel'dorei Meditation")) then		
				self.message = "Using Quel'dorei Meditation...";
				CastSpellByName("Quel'dorei Meditation"); 
				return 0;
			end

			-- Use Mana Shield if we more than 35 procent mana and no active Ice Barrier
			if (not localObj:HasBuff('Ice Barrier') and HasSpell('Mana Shield') and localMana > self.manaShieldMana and localHealth <= self.manaShieldHealth and not localObj:HasBuff('Mana Shield') and targetObj:GetDistance() < 15) then
				if (not targetObj:HasDebuff('Frost Nova') and not targetObj:HasDebuff('Frostbite')) then
					CastSpellByName('Mana Shield');
					return 0;
				end
			end

	--Frost Ward
		if (localMana > 50 and not IsMounted() and self.useFrostWard) and IsInCombat() then
			if (not IsSpellOnCD("Frost Ward")) or (not IsSpellOnCD("Fire Ward")) then
				if (not Buff('Frost Ward', localObj)) or (not Buff('Fire Ward', localObj)) then
					if (HasSpell("Frost Ward")) then
						self.waitTimer = GetTimeEX() + 1500;
						CastSpellByName("Frost Ward");
						end
					end
				end
			end

	--Fire Ward
		if (localMana > 50 and not IsMounted() and self.useFireWard) and IsInCombat() then
			if (not IsSpellOnCD("Fire Ward")) or (not IsSpellOnCD("Frost Ward")) then
				if (not Buff('Fire Ward', localObj)) or (not Buff('Frost Ward', localObj)) then
					if (HasSpell("Fire Ward")) then
						self.waitTimer = GetTimeEX() + 1500;
						CastSpellByName("Fire Ward");
						end
					end
				end
			end

			-- Check: Frostnova when the target is close, but not when we polymorhped one enemy or the target is affected by Frostbite
			if (targetObj:GetDistance() < 5 and not targetObj:HasDebuff("Frostbite") and HasSpell("Frost Nova") and not IsSpellOnCD("Frost Nova")) and self.useFrostNova then
				self.message = "Frost nova the target(s)...";
				CastSpellByName("Frost Nova");
				return 0;
			end

			if (HasSpell('Ice Block') and not IsSpellOnCD('Ice Block') and localHealth < self.iceBlockHealth and localMana < self.iceBlockMana) then
				self.message = "Using Ice Block...";
				CastSpellByName('Ice Block');
				return 0;
			end

						-- Fire blast
			if (self.useFireBlast and targetObj:GetDistance() < 20 and HasSpell('Fire Blast') and localMana > 7) then
				if (script_mage:cast('Fire Blast', targetObj)) then
					return 0;
				end
			end
			
			-- Wand if low mana or target is low
			if (self.useWand) then
				if ((localMana <= self.useWandMana or targetHealth <= self.useWandHealth) and localObj:HasRangedWeapon()) then
					self.message = "Using wand...";
					if (not IsAutoCasting("Shoot")) then
						targetObj:FaceTarget();
						targetObj:CastSpell("Shoot");
						self.waitTimer = GetTimeEX() + 1650; 
						return 0;
					end
					return 0;
				end
			end

			--Cone of Cold 2 test
			if (self.useConeofCold and HasSpell('Cone of Cold')) and IsInCombat() and localMana <= self.coneOfColdMana and targetHealth >= self.coneOfColdHealth then
				if (targetObj:GetDistance() < 10) then
						if (script_mage:ConeofCold('Cone of Cold')) then
							return 0;
						end
					end
				end

			-- Main damage source
			if (HasSpell("Frostbolt")) then
				if(not targetObj:IsSpellInRange('Frostbolt')) then
					return 3;
				end
				if (script_mage:cast('Frostbolt', targetObj)) then
					return 0;
				end
				if (not targetObj:IsInLineOfSight()) then
					return 3;
				end	
			else
				if(not targetObj:IsSpellInRange('Fireball')) then
					return 3;
				end
				if (script_mage:cast('Fireball', targetObj)) then
					return 0;
				end
				if (not targetObj:IsInLineOfSight()) then
					return 3;
				end	
			end		
		end
	end
end

function script_mage:rest()

	if(not self.isSetup) then
		script_mage:setup();
	end

	local localObj = GetLocalPlayer();
	local localMana = localObj:GetManaPercentage();
	local localHealth = localObj:GetHealthPercentage();

	--Create Water
	local waterIndex = -1;
	for i=0,self.numWater do
		if (HasItem(self.water[i])) then
			waterIndex = i;
			break;
		end
	end
	
	if (waterIndex == -1 and HasSpell('Conjure Water')) then 
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
				return true;
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
	if (foodIndex == -1 and HasSpell('Conjure Food')) then 
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
				return true;
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
	if (gemIndex == -1 and (HasSpell('Conjure Mana Ruby') 
				or HasSpell('Conjure Mana Citrine') 
				or HasSpell('Conjure Mana Jade')
				or HasSpell('Conjure Mana Agate'))) then 
		self.message = "Conjuring mana gem...";
		if(IsMounted()) then 
			DisMount(); 
		end
		if (IsMoving()) then
			StopMoving();
			return true;
		end
		if (not IsStanding()) then
			StopMoving();
		end

		if (localMana > 20 and not IsDrinking() and not IsEating() and not AreBagsFull()) then
			if (HasSpell('Conjure Mana Ruby')) then
				CastSpellByName('Conjure Mana Ruby')
				return true;
			elseif (HasSpell('Conjure Mana Citrine')) then
				CastSpellByName('Conjure Mana Citrine')
				return true;
			elseif (HasSpell('Conjure Mana Jade')) then
				CastSpellByName('Conjure Mana Jade')
				return true;
			elseif (HasSpell('Conjure Mana Agate')) then
				CastSpellByName('Conjure Mana Agate')
				return true;
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
	
	if(localMana < self.drinkMana or localHealth < self.eatHealth) then
		if (IsMoving()) then
			StopMoving();
		end
		return true;
	end
	
	if((localMana < 98 and IsDrinking()) or (localHealth < 98 and IsEating())) then
		self.message = "Resting to full hp/mana...";
		return true;
	end

	-- Do buffs if we got some mana 
	if (localMana > 30 and not IsMounted()) then
		if (not Buff('Arcane Intellect', localObj)) then
			if (not Buff('Dampen Magic', localObj)) then
				if (HasSpell("Ice Armor")) then
					if (not Buff('Ice Armor', localObj)) then
						return false;
					end
				else	
					if (not Buff('Frost Armor', localObj)) then
						return false;
					end
				end
			end
		end
	end

	-- No rest / buff needed
	return false;
end

function script_mage:menu()
	if (CollapsingHeader("Frost Mage Rotation")) then
		local wasClicked = false;
		Text('Drink below mana percentage');
		self.drinkMana = SliderFloat("DM%", 1, 100, self.drinkMana);
		Text('Eat below health percentage');
		self.eatHealth = SliderFloat("EH%", 1, 100, self.eatHealth);
		Separator();
		Text('Skills options:');
		wasClicked, self.useWand = Checkbox("Use Wand", self.useWand);
		wasClicked, self.useFireBlast = Checkbox("Use Fire Blast", self.useFireBlast);
		wasClicked, self.useConeofCold = Checkbox("Use Cone of Cold", self.useConeofCold);
		wasClicked, self.useManaShield = Checkbox("Use Mana Shield", self.useManaShield);
		wasClicked, self.useFrostNova = Checkbox("Use Frost Nova", self.useFrostNova);
		wasClicked, self.useQuelDoreiMeditation = Checkbox("Use QuelDoreiMeditation", self.useQuelDoreiMeditation);
		wasClicked, self.useFrostWard = Checkbox("Use Frost Ward", self.useFrostWard);
		wasClicked, self.useFireWard = Checkbox("Use Fire Ward", self.useFireWard);
				Separator();
				Text('Wand options:');
		Text('Wand below self mana percent');
		self.useWandMana = SliderFloat("WM%", 1, 75, self.useWandMana);
		Text('Wand below target HP percent');
		self.useWandHealth = SliderFloat("WH%", 1, 75, self.useWandHealth);
				Separator();
				Text('Cone of Cold options:');
		Text('Cone of Cold above self mana percent');
		self.coneOfColdMana = SliderFloat("CCM", 20, 75, self.coneOfColdMana);
		Text('Cone of Cold above target health percent');
		self.coneOfColdHealth = SliderFloat("CCH", 5, 50, self.coneOfColdHealth);
				Separator();
				Text('Evocation options:');
		Text('Evocation above health percent');
		self.evocationHealth = SliderFloat("EH%", 1, 90, self.evocationHealth);
		Text('Evocation below mana percent');
		self.evocationMana = SliderFloat("EM%", 1, 90, self.evocationMana);
		Text('Queldorei Meditation below mana percent');
		self.QuelDoreiMeditationMana = SliderFloat("QM%", 1, 90, self.QuelDoreiMeditationMana);
				Separator();
				Text('Ice Block options:');
		Text('Ice Block below health percent');
		self.iceBlockHealth = SliderFloat("IBH%", 5, 90, self.iceBlockHealth);
		Text('Ice Block below mana percent');
		self.iceBlockMana = SliderFloat("IBM%", 5, 90, self.iceBlockMana);
				Separator();
				Text('Mana Shield options:');
		Text('Mana Shield below self health percent');
		self.manaShieldHealth = SliderFloat("MS%", 5, 99, self.manaShieldHealth);
		Text('Mana Shield above self mana percent');
		self.manaShieldMana = SliderFloat("MM%", 10, 65, self.manaShieldMana);
				Separator();
				Text('Mana Gem options:');
		Text('Mana Gem below mana percent');
		self.manaGemMana = SliderFloat("MG%", 1, 90, self.manaGemMana);		
	end
end





-- BACKUP OF NEW ADDITIONS
--Frost Ward
		--if (localMana > 50 and not IsMounted() and self.useFrostWard) then
		--	if (not IsSpellOnCD("Frost Ward")) or (not IsSpellOnCD("Fire Ward")) then
		--		if (not Buff('Frost Ward', localObj)) or (not Buff('Fire Ward', localObj)) then
		--			if (HasSpell("Frost Ward")) then
		--				self.waitTimer = GetTimeEX() + 1500;
		--				CastSpellByName("Frost Ward");
		--		end
		--	end
		--end
	--end

	--Fire Ward
	--	if (localMana > 50 and not IsMounted() and self.useFireWard) then
	--		if (not IsSpellOnCD("Fire Ward")) or (not IsSpellOnCD("Frost Ward")) then
	--			if (not Buff('Fire Ward', localObj)) or (not Buff('Frost Ward', localObj)) then
	--				if (HasSpell("Fire Ward")) then
	--					self.waitTimer = GetTimeEX() + 1500;
	--					CastSpellByName("Fire Ward");
	--			end
	--		end
	--	end
	--end
