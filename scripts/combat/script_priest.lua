script_priest = {
	message = 'Priest Combat Script',
	drinkMana = 50,
	eatHealth = 35,
	isSetup = false,
	renewHP = 90,
	shieldHP = 80,
	flashHealHP = 75,
	lesserHealHP = 60,
	healHP = 45,
	greaterHealHP = 20,
	potionMana = 10,
	potionHealth = 10,
	waitTimer = 0,
	useWand = true,
	useWandMana = 100,
	useWandHealth = 100,
	isChecked = true,
	useSmite = false,
	useLesserHeal = false,
	mindBlastMana = 30,
	wandSpeed = '1600',
	useScream = true,
	checkParty = false,
}

function script_priest:healAndBuff(targetObject, localMana)

	local targetHealth = targetObject:GetHealthPercentage();

	-- Buff Fortitude
	if (localMana > 25 and not IsInCombat() and not targetObject:HasBuff("Power Word: Fortitude")) then
		if (Buff('Power Word: Fortitude', targetObject)) then 
			return true; 
		end
	end
	
	-- Buff Divine Spirit
	if (localMana > 25 and not IsInCombat() and not targetObject:HasBuff('Divine Spirit')) then
		if (Buff('Divine Spirit', targetObject)) then
			return true; 
		end
	end

	-- Renew
	if (localMana > 12 and targetHealth < self.renewHP and not targetObject:HasBuff("Renew")) then
		if (Buff('Renew', targetObject)) then
			return true;
		end
	end

	-- Shield
	if (localMana > 10 and targetHealth < self.shieldHP and not targetObject:HasDebuff("Weakened Soul") and IsInCombat()) then
		if (Buff('Power Word: Shield', targetObject)) then 
			targetObj:FaceTarget();
			return true; 
		end
	end

	-- Greater Heal
	if (localMana > 20 and targetHealth < self.greaterHealHP) then
		if (script_priest:heal('Heal', targetObject)) then
			return true;
		end
	end

	-- Heal
	if (localMana > 15 and targetHealth < self.healHP) then
		if (script_priest:heal('Heal', targetObject)) then
			return true;
		end
	end

	-- Flash Heal
	if (localMana > 8 and targetHealth < self.flashHealHP) then
		if (script_priest:heal('Flash Heal', targetObject)) then
			return true;
		end
	end
	
	-- Lesser Heal
	if (localMana > 10 and targetHealth < self.lesserHealHP) then
		if (self.useLesserHeal and script_priest:heal('Lesser Heal', targetObject)) then
			return true;
		end
	end

	return false;
end

function script_priest:heal(spellName, target)

	if (HasSpell(spellName)) then 
		if (target:IsSpellInRange(spellName)) then 
			if (not IsSpellOnCD(spellName)) then 
				if (not IsAutoCasting(spellName)) then
					target:TargetEnemy(); 
					CastSpellByName(spellName); 
					-- Wait for global CD before next spell cast
					local CastTime, MaxRange, MinRange, PowerType, Cost, SpellId, SpellObj = GetSpellInfo(spellName); 
					self.waitTimer = GetTimeEX() + CastTime + 1800;
					return true; 
				end 
			end 
		end 
	end

	return false;
end

function script_priest:cast(spellName, target)
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

function script_priest:enemiesAttackingUs(range) -- returns number of enemies attacking us within range
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
function script_priest:runBackwards(targetObj, range) 

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
 			--script_nav:moveToTarget(localObj, moveX, moveY, moveZ);
			Move(moveX, moveY, moveZ);
 			return true;
 		end
	end

	return false;
end

function script_priest:setup()
	self.waitTimer = GetTimeEX();
	self.isSetup = true;
end

function script_priest:draw()
	--script_priest:window();
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

function script_priest:run(targetGUID)
	
	if(not self.isSetup) then
		script_priest:setup();
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
	if (IsChanneling() or IsCasting() or self.waitTimer > GetTimeEX()) then
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

		targetHealth = targetObj:GetHealthPercentage();

		-- Auto Attack
		if (targetObj:GetDistance() < 40) then
			targetObj:AutoAttack();
		end

		-- Check: if we target player pets/totems
		if (GetTarget() ~= nil and targetObj ~= nil) then
			if (UnitPlayerControlled("target") and GetTarget() ~= localObj) then 
				script_grind:addTargetToBlacklist(targetObj:GetGUID());
				return 5; 
			end
		end 
		
		-- Opener
		if (not IsInCombat()) then

			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";
			
			-- Opener check range of ALL SPELLS
			if(not targetObj:IsSpellInRange('Smite'))  then
			self.message = "Use Smite as range check!";
				return 3;
			end

			-- Dismount
			if (IsMounted()) then DisMount(); end

			-- Devouring Plague
			if (HasSpell("Devouring Plague")) and (localMana > 25) and (targetObj:GetDistance() < 30) then
				if (not IsSpellOnCD("Devouring Plague")) then
					if (not targetObj:IsInLineOfSight()) then
						return 3;
					end
					if (Cast("Devouring Plague", targetObj)) then
						self.waitTimer = GetTimeEX() + 200;
						self.message = "Casting Devouring Plague!";
						return 0;
					end
				end
			end

			-- Mind Blast
			if (HasSpell("Mind Blast")) and (localMana > self.mindBlastMana) then
				if (not IsSpellOnCD("Mind Blast")) and (targetObj:GetDistance() < 30) then
					if (not targetObj:IsInLineOfSight()) then
						return 3;
					end
					if (Cast("Mind Blast", targetObj)) then	
						self.waitTimer = GetTimeEX() + 750;
						self.message = "Casting Mind Blast!";
						return 0;
					end
				end
			end

			-- shadow word pain if mindblast is on CD
			if (HasSpell("Shadow Word: Pain")) and (localMana > 10) and (targetObj:GetDistance() < 30) then
				if (not targetObj:HasDebuff("Shadow Word: Pain")) and (targetHealth > 15) then
					if (not targetObj:IsInLineOfSight()) then
						return 3;
					end
					if (Cast("Shadow Word: Pain", targetObj)) then
						self.waitTimer = GetTimeEX() + 750;
						return 0;
					end
				end
			end

			-- Use Smite if we have it
			if (self.useSmite) then
				if (not targetObj:IsInLineOfSight()) then
					return 3;
				end
				if (script_priest:cast('Smite', targetObj)) then
					self.waitTimer = GetTimeEX() + 750;
					self.message = "Smite was checked, we are using it!";
					return 0;
				end
			end

			
			if (not targetObj:IsInLineOfSight()) then
				return 3;
			end

		-- Combat
		else	

			self.message = "Killing.. now in combat" .. targetObj:GetUnitName() .. "...";

			-- Dismount
			if (IsMounted()) then DisMount(); end

			if (script_priest:healAndBuff(localObj, localMana)) then
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

			if (self.useScream and script_priest:enemiesAttackingUs(5) > 1 and targetHealth > 20 and localMana > 10) then
				if (HasSpell('Psychic Scream') and not IsSpellOnCD('Psychic Scream')) then
					CastSpellByName('Psychic Scream');
					self.message = 'Adds close, use Psychic Scream...';
					return 0;
				end
			end

			-- use mind blast on CD
			if (HasSpell("Mind Blast")) and (not IsSpellOnCD("Mind Blast")) then
				if (targetHealth > 20) and (localMana > self.mindBlastMana) then
					if (Cast("Mind Blast", targetObj)) then
						self.waitTimer = GetTimeEX() + 750;
						return 0;
					end
				end
			end

			-- Check: Keep Shadow Word: Pain up
			if (not targetObj:HasDebuff("Shadow Word: Pain") and localMana > 10) then
				if (Cast('Shadow Word: Pain', targetObj)) then 
					self.waitTimer = GetTimeEX() + 750;
					self.message = "Keeping DoT up!";
					return 0; 
				end
			end

			-- Check: Keep Inner Fire up
			if (not localObj:HasBuff('Inner Fire') and HasSpell('Inner Fire') and localMana > 8) then
				if (Buff('Inner Fire', localObj)) then
					self.waitTimer = GetTimeEX() + 750;
					return 0;
				end
			end

			-- Cast: Smite (last choice e.g. at level 1)
			if (self.useSmite and localMana > 10) then
				if (Cast('Smite', targetObj)) then 
					self.waitTimer = GetTimeEX() + 750;
					return 0; 
				end
			end

			if (not localObj:HasRangedWeapon()) then
				self.useSmite = true;
			end

			--Wand if set to use wand
			wandSpeed = self.wandSpeed;
			if (IsSpellOnCD("Mind Blast")) and (not localObj:IsCasting()) then
				if ((localMana <= self.useWandMana and targetHealth <= self.useWandHealth) and localObj:HasRangedWeapon() and self.useWand) then
					if (not IsAutoCasting("Shoot")) then
						self.message = "Using wand...";
						targetObj:FaceTarget();
						targetObj:CastSpell("Shoot");
						self.waitTimer = GetTimeEX() + (self.wandSpeed + 100); 
						return 0;
					end
				end
			self.waitTimer = GetTimeEX() + 250;
			end
		end
	end
end


function script_priest:rest()

	if(not self.isSetup) then
		script_priest:setup();
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

	if (script_priest:healAndBuff(localObj, localMana)) then 
		return true;
	end

	-- Check: Drink
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

	-- Check: Eat
	if (not IsEating() and localHealth < self.eatHealth) then
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
	
	-- Check: Keep resting
	if((localMana < 98 and IsDrinking()) or (localHealth < 98 and IsEating())) then
		self.message = "Resting to full hp/mana...";
		return true;
	end

	-- No rest / buff needed
	return false;
end

--function script_priest:mount()
--
--	if(not IsMounted() and not IsSwimming() and not IsIndoors() 
--		and not IsLooting() and not IsCasting() and not IsChanneling() 
--			and not IsDrinking() and not IsEating()) then
--		
--		if(IsMoving()) then
--			return true;
--		end
--		
--		return UseItem(self.mountName);
--	end
--	
--	return false;
--end

function script_priest:window()

	if (self.isChecked) then
	
		--Close existing Window
		EndWindow();

		if(NewWindow("Combat Options and Self Heals", 200, 200)) then
			script_priest:menu();
		end
	end
end


function script_priest:menu()

	if (1 < 2) then -- I just needed SOMETHING to be true....
		local wasClicked = false;
		wasClicked, self.useScream = Checkbox("Fear On/Off", self.useScream);
		SameLine();
		wasClicked, self.useLesserHeal = Checkbox("Lesser Heal On/Off", self.useLesserHeal);
		SameLine();
		wasClicked, self.useSmite = Checkbox("Smite On/Off", self.useSmite);
		SameLine();
		Separator();
		if (CollapsingHeader("Priest Combat Options")) then
		Text('Mind Blast above self mana percent');
		self.mindBlastMana = SliderInt("MBM%", 10, 100, self.mindBlastMana);
		Separator();
		Text('Wand options:');
		Separator();
		wasClicked, self.useWand = Checkbox("Use Wand", self.useWand);	
		Text('Wand below self mana percent');
		self.useWandMana = SliderInt("WM%", 10, 100, self.useWandMana);
		Text('Wand below target HP percent');
		self.useWandHealth = SliderInt("WH%", 10, 100, self.useWandHealth);
		Text('Wand Attack Speed (1.1 = 1100)');
		self.wandSpeed = InputText("WS", self.wandSpeed);
		end
		if (CollapsingHeader("Priest Self Heals - Combat Script")) then
		Text('Drink below mana percentage');
		self.drinkMana = SliderInt("DM%", 1, 99, self.drinkMana);
		Text('Eat below health percentage');
		self.eatHealth = SliderInt("EH%", 1, 99, self.eatHealth);
		Separator();
		Text('Self Heals');
		self.renewHP = SliderInt("Renew HP%", 1, 99, self.renewHP);	
		self.shieldHP = SliderInt("Shiled HP%", 1, 99, self.shieldHP);
		self.flashHealHP = SliderInt("Flash heal HP%", 1, 99, self.flashHealHP);	
		self.lesserHealHP = SliderInt("Lesser heal HP%", 1, 99, self.lesserHealHP);	
		self.healHP = SliderInt("Heal HP%", 1, 99, self.healHP);	
		self.greaterHealHP = SliderInt("Greater Heal HP%", 1, 99, self.greaterHealHP);
		self.potionHealth = SliderInt("Potion HP%", 1, 99, self.potionHealth);
		self.potionMana = SliderInt("Potion Mana%", 1, 99, self.potionMana);
		Separator();	
	end
end
end