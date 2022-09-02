script_warlock = {
	message = 'Warlock Combat Script',
	drinkMana = 40,
	eatHealth = 55,
	potionHealth = 10,
	potionMana = 20,
	healthStone = {},
	numStone = 0,
	stoneHealth = 30,
	isSetup = false,
	fearTimer = 0,
	cooldownTimer = 0,
	addFeared = false,
	fearAdds = true,
	waitTimer = 0,
	useWand = true,
	isChecked = true,
	useVoid = false,
	useImp = false,
	useSuccubus = true;
	corruptionCastTime = 0, -- 0-2000 ms = 2000 with no improved corruption talent
	lifeTapHealth = 75,
	lifeTapMana = 80,
	soulShard = 0;
	useShadowBolt = false,
	useWandHealth = 100,
	useWandMana = 100,
	enableGatherShards = false,
	enableSiphonLife = true,
	enableCurseOfAgony = true,
	enableImmolate = true,
	enableCorruption = true,
	drainLifeHealth = 75,
	healPetHealth = 40,
	sacrificeVoid = true,
	sacrificeVoidHealth = 10,
	useUnendingBreath = false,
	alwaysFear = false;
}

function script_warlock:cast(spellName, target)
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

function script_warlock:getTargetNotFeared()
   	local unitsAttackingUs = 0; 
   	local currentObj, typeObj = GetFirstObject(); 
   	while currentObj ~= 0 do 
   		if typeObj == 3 then
			if (currentObj:CanAttack() and not currentObj:IsDead()) then
               	if ((script_grind:isTargetingMe(currentObj) or script_grind:isTargetingPet(currentObj)) and not currentObj:HasDebuff('Fear')) then 
           			return currentObj;
               	end 
           	end 
       	end
        currentObj, typeObj = GetNextObject(currentObj); 
    end
	return nil;
end

function script_warlock:isAddFeared()
	local currentObj, typeObj = GetFirstObject(); 
	local localObj = GetLocalPlayer();
	while currentObj ~= 0 do 
		if typeObj == 3 then
			if (currentObj:HasDebuff("Fear")) then 
				return true; 
			end
		end
		currentObj, typeObj = GetNextObject(currentObj); 
	end
    return false;
end

function script_warlock:fearAdd(targetObjGUID) 
	local currentObj, typeObj = GetFirstObject(); 
	local localObj = GetLocalPlayer();
	while currentObj ~= 0 do 
		if typeObj == 3 then
			if (currentObj:CanAttack() and not currentObj:IsDead()) then
				if (currentObj:GetGUID() ~= targetObjGUID and script_grind:isTargetingMe(currentObj)) then
					if (not currentObj:HasDebuff("Fear") and currentObj:GetCreatureType() ~= 'Elemental' and not currentObj:IsCritter()) then
						ClearTarget();
						if (script_warlock:cast('Fear', currentObj)) then 
							self.addFeared = true; 
							fearTimer = GetTimeEX() + 8000;
							return true; 
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
function script_warlock:runBackwards(targetObj, range) 
	local localObj = GetLocalPlayer();
 	if targetObj ~= 0 then
 		local xT, yT, zT = targetObj:GetPosition();
 		local xP, yP, zP = localObj:GetPosition();
 		local distance = targetObj:GetDistance();
 		local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
 		local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 		local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;		
 		local moveX, moveY, moveZ = xT + xUV*10, yT + yUV*10, zT + zUV*10;		
 		if (distance < range and targetObj:IsInLineOfSight()) then 
 			script_nav:moveToTarget(localObj, moveX, moveY, moveZ);
 			return true;
 		end
	end
	return false;
end

function script_warlock:addHealthStone(name)
	self.healthStone[self.numStone] = name;
	self.numStone = self.numStone + 1;
end

function script_warlock:setup()
	script_warlock:addHealthStone('Major Healthstone');
	script_warlock:addHealthStone('Greater Healthstone');
	script_warlock:addHealthStone('Healthstone');
	script_warlock:addHealthStone('Lesser Healthstone');
	script_warlock:addHealthStone('Minor Healthstone');

	self.waitTimer = GetTimeEX();
	self.fearTimer = GetTimeEX();
	self.cooldownTimer = GetTimeEX();

	if (not HasSpell("Summon Voidwalker")) then
		self.useImp = true;
		self.useVoid = false;
	elseif (not HasSpell("Summon Succubus")) then
		self.useImp = false;
		self.useVoid = true;
	elseif (HasSpell("Summon Succubus")) then
		self.useSuccubus = true;
		self.alwaysFear = true;
	end

	if (GetLocalPlayer():GetLevel() < 10) then
		self.corruptionCastTime = 20;
	elseif (GetLocalPlayer():GetLevel() == 10) then
		self.corruptionCastTime = 16;
	elseif (GetLocalPlayer():GetLevel() == 11) then
			self.corruptionCastTime = 12;
	elseif (GetLocalPlayer():GetLevel() == 12) then
		self.corruptionCastTime = 8;
	elseif (GetLocalPlayer():GetLevel() == 13) then
			self.corruptionCastTime = 4;
	elseif (GetLocalPlayer():GetLevel() == 14) then
		self.corruptionCastTime = 0;
	end

	self.isSetup = true;
end

function script_warlock:draw()
	--script_warlock:window();
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

function script_warlock:run(targetGUID)
	
	if(not self.isSetup) then
		script_warlock:setup();
	end
	
	local localObj = GetLocalPlayer();
	local localMana = localObj:GetManaPercentage();
	local localHealth = localObj:GetHealthPercentage();
	local localLevel = localObj:GetLevel();

	local hasPet = false;
	
	if (GetPet():GetHealthPercentage() <= 0) then
		hasPet = false;
	end

	-- if has pet then set variable
	if(GetPet() ~= 0) then
		hasPet = true;
	end
	
	-- don't attack dead targets
	if (localObj:IsDead()) then
		return 0;
	end
	
	-- Assign the target 
	targetObj =  GetGUIDObject(targetGUID);

	-- clear target
	if(targetObj == 0 or targetObj == nil or targetObj:IsDead()) then
		ClearTarget();
		return 2;
	end

	-- Check: Do nothing if we are channeling, casting
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
		
		-- stand if sitting
		if (not IsStanding()) then
			StopMoving();
		end

		-- set target health
		targetHealth = targetObj:GetHealthPercentage();

		-- Auto attack
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

		-- move to cancel Health Funnel when payer has low HP
		if (hasPet) then
			if (GetPet():HasBuff("Health Funnel") and localHealth < 40) then
				local _x, _y, _z = localObj:GetPosition();
				script_nav:moveToTarget(localObj, _x + 1, _y + 1, _z); 
				return 0;
			end
		end

		-- move to cancel Drain Life when we get Nightfall buff
		if (GetTarget() ~= 0) then	
			if (GetTarget():HasDebuff("Drain Life") and localObj:HasBuff("Shadow Trance")) then
				local _x, _y, _z = localObj:GetPosition();
				script_nav:moveToTarget(localObj, _x + 1, _y, _z); 
				return 0;
			end
		end

		-- START OF COMBAT PHASE

		-- Opener - not in combat pulling target
		if (not IsInCombat()) then
			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";
			
			-- Opener check range of ALL SPELLS
			if(not targetObj:IsSpellInRange('Shadow Bolt') or not targetObj:IsInLineOfSight()) then
				return 3;
			end

			-- if pet goes too far then recall
			if (hasPet) and (not IsInCombat()) and (GetPet():GetDistance() > 40) then
				PetFollow();
			end

			-- Dismount
			if (IsMounted()) then
				DisMount(); 
			end

			-- spells to pull

			if (HasSpell("Siphon Life")) and (self.enableSiphonLife) then
				self.message = "Stacking DoT's";
				if (hasPet) then
					PetAttack();
				end
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (Cast("Siphon Life", targetObj)) then 
					self.waitTimer = GetTimeEX() + 1600; 
					return 0;
				end
			elseif (HasSpell("Curse of Agony")) and (self.enableCurseOfAgony) then
				self.message = "Stacking DoT's";
				if (hasPet) then
					PetAttack();
				end
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (Cast('Curse of Agony', targetObj)) then 
					self.waitTimer = GetTimeEX() + 1600;
					return 0;
				end
			elseif (HasSpell("Immolate")) and (self.enableImmolate) then
				self.message = "Stacking DoT's";
				if (hasPet) then
					PetAttack();
				end
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (Cast('Immolate', targetObj)) then 
					self.waitTimer = GetTimeEX() + 2200;
					return 0;
				end
			else
				if (Cast('Shadow Bolt', targetObj)) then
					self.message = "Pulling Target";
					if (hasPet) then
						PetAttack();
					end
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					return 0;
				end
			end

			if (not targetObj:IsInLineOfSight()) then -- check line of sight
				self.message = "Moving into Line of Sight of target";
				return 3;
			end
	
			-- IN COMBAT

			-- Combat
		else	
			self.message = "Killing " .. targetObj:GetUnitName() .. "...";

			-- recall pet if too far > 30
			if (hasPet) and (GetPet():GetDistance() > 30) then
				self.message = "Recalling Pet - too far!";
				PetFollow();
			end

			-- Set the pet to attack
			if (hasPet) and (targetObj:GetDistance() < 35) and (targetHealth < 99 or targetObj:HasDebuff("Curse of Agony") or 
				targetObj:HasDebuff("Corruption")) or (script_grind:isTargetingMe(targetObj)) then
				self.message = "Sending pet to attack";
				PetAttack();
			end

			-- Dismount
			if(IsMounted()) then 
				DisMount();
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

			-- sacrifice voidwalker low health
			if (hasPet) and (self.sacrificeVoid) and (localHealth <= self.sacrificeVoidHealth or GetPet():GetHealthPercentage() < self.sacrificeVoidHealth) then
				hasPet = false;
				CastSpellByName("Sacrifice");
				return 0;
			end

			-- Check: If we get Nightfall buff then cast Shadow Bolt
			if (localObj:HasBuff("Shadow Trance")) then
				if (Cast('Shadow Bolt', targetObj)) then
					return 0;
				end
			end	

			-- Use Healthstone
			if (localHealth < self.stoneHealth) then
				for i=0,self.numStone do
					if(HasItem(self.healthStone[i])) then
						if (UseItem(self.healthStone[i])) then
							return 0;
						end
					end
				end
			end

			-- Fear single Target
			if (self.alwaysFear) and (HasSpell("Fear")) and (not targetObj:HasDebuff("Fear")) and (targetObj:GetHealthPercentage() > 10) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (Cast("Fear", targetObj)) then
					self.waitTimer = GetTimeEX() + 2300;
					return 0;
				end
			end

			-- Check if add already feared
			if (not script_warlock:isAddFeared() and not (self.fearTimer < GetTimeEX())) then
				self.addFeared = false;
			end

			-- Check: Fear add
			if (targetObj ~= nil) and (self.fearAdds) and (script_grind:enemiesAttackingUs(5) > 1) and (HasSpell('Fear')) and (not self.addFeared) and (self.fearTimer < GetTimeEX()) then
				self.message = "Fearing add...";
				script_warlock:fearAdd(targetObj:GetGUID());
			end 

			-- Check: Sort target selection if add is feared
			if (self.addFeared) then
				if(script_grind:enemiesAttackingUs() >= 1 and targetObj:HasDebuff('Fear')) then
					ClearTarget();
					targetObj = script_warlock:getTargetNotFeared();
					targetObj:AutoAttack();
				end
			end

			-- Check: If we don't have a soul shard, try to make one
			if (targetHealth < 30 and HasSpell("Drain Soul") and not HasItem('Soul Shard')) then
				if (Cast('Drain Soul', targetObj)) then
					return 0;
				end
			end

			-- Check: Heal the pet if it's below 50% and we are above 50%
			if (hasPet) and (GetPet():GetHealthPercentage() > 0 and GetPet():GetHealthPercentage() <= self.healPetHealth) and (HasSpell("Health Funnel")) and (localHealth > 50) then
				if (GetPet():GetDistance() >= 20 or not GetPet():IsInLineOfSight()) then
					self.message = "Healing pet!";
					script_nav:moveToTarget(localObj, GetPet():GetPosition()); 
					self.waitTimer = GetTimeEX() + 2000;
					return 0;
				else
					StopMoving();
				end
				CastSpellByName("Health Funnel"); 
				return 0;
			end

			-- Wand if low mana
			if (localMana <= 5 or targetHealth <= 10) and (localObj:HasRangedWeapon()) and (not self.enableGatherShards) then
				self.message = "Using wand...";
				if (not IsAutoCasting("Shoot")) then
					targetObj:FaceTarget();
					targetObj:CastSpell("Shoot");
					self.waitTimer = GetTimeEX() + 1250; 
					return true;
				end
			end
			
			-- Check: Keep Siphon Life up (30 s duration)
			if (self.enableSiphonLife) then
				if (not targetObj:HasDebuff("Siphon Life") and targetHealth > 20) then
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					if (Cast('Siphon Life', targetObj)) then
						self.waitTimer = GetTimeEX() + 1600;
						return 0;
					end
				end
			end

			-- Check: Keep the Curse of Agony up (24 s duration)
			if (self.enableCurseOfAgony) then
				if (not targetObj:HasDebuff("Curse of Agony") and targetHealth > 20) then
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					if (Cast('Curse of Agony', targetObj)) then
						self.waitTimer = GetTimeEX() + 1600;
						return 0;
					end
				end
			end
	
			-- Check: Keep the Corruption DoT up (15 s duration)
			if (self.enableCorruption) then
				if (not targetObj:HasDebuff("Corruption") and targetHealth > 20) then
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					if (Cast('Corruption', targetObj)) then
						self.waitTimer = GetTimeEX() + 1600 + (self.corruptionCastTime / 10); 
						return 0; 
					end
				end
			end
	
			-- Check: Keep the Immolate DoT up (15 s duration)
			if (self.enableImmolate) then
				if (not targetObj:HasDebuff("Immolate") and targetHealth > 20) then
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					if (Cast('Immolate', targetObj)) then
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 2500;
						return 0;
					end
				end
			end

			-- life tap in combat
			if HasSpell("Life Tap") and not IsSpellOnCD("Life Tap") and localHealth > 35 and localMana < 15 then
				if (CastSpellByName("Life Tap")) then
					self.message = "Using Life Tap!";
					return 0;
				end
			end

			-- gather shards enabled
			if (self.enableGatherShards) then
				self.message = "Gathering Soulshards - bot will NOT stop";
				if (targetHealth < 35) and (HasSpell("Drain Soul")) then
					if (targetObj:GetDistance() <= 20) then
						if (IsAutoCasting("Shoot")) then
							script_nav:moveToTarget(localObj, _x + 1, _y, _z);
							targetObj:FaceTarget();
							return 0;
						end
						if (Cast('Drain Soul', targetObj)) then
							return 0;
						end
					else
						script_nav:moveToTarget(localObj, targetObj:GetPosition()); 
						self.waitTimer = GetTimeEX() + 1000;
						return 0;
					end
				end
			end

			-- Drain Life on low health
			if (HasSpell("Drain Life")) and (targetObj:GetCreatureType() ~= "Mechanic") and (localHealth <= self.drainLifeHealth) and (localMana > 5) then
				self.message = "Casting Drain Life";
				if (targetObj:GetDistance() < 20) then
					if (IsMoving()) then StopMoving(); 
						return; 
					end
					if (Cast('Drain Life', targetObj)) then 
						return; 
					end
				else
					script_nav:moveToTarget(localObj, targetObj:GetPosition()); 
					self.waitTimer = GetTimeEX() + 2000;
					return 0;
				end
			end

			-- Check: Heal the pet if it's below 50% and we are above 50%
			if (hasPet) and (GetPet():GetHealthPercentage() > 0 and GetPet():GetHealthPercentage() <= self.healPetHealth) and (HasSpell("Health Funnel")) and (localHealth > 50) then
				self.message = "Healing pet with Health Funnel";
				if (GetPet():GetDistance() >= 20 or not GetPet():IsInLineOfSight()) then
					script_nav:moveToTarget(localObj, GetPet():GetPosition()); 
					self.waitTimer = GetTimeEX() + 2000;
					return 0;
				else
					StopMoving();
				end
				CastSpellByName("Health Funnel"); 
				return 0;
			end

			if (self.useShadowBolt) then
				-- Cast: Shadow Bolt
				if (Cast('Shadow Bolt', targetObj)) then
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					return 0;
				end
				-- wand instead
			elseif (self.useWand) and (localHealth > self.drainLifeHealth and GetPet():GetHealthPercentage() > self.healPetHealth) and (not IsChanneling()) then
				if (localObj:HasRangedWeapon()) then
					self.message = "Using wand...";
					if (not IsAutoCasting("Shoot")) then
						targetObj:FaceTarget();
						targetObj:CastSpell("Shoot");
						self.waitTimer = GetTimeEX() + 1250; 
						return false;
					end
				end
			end	
		end
	end
end

function script_warlock:lifeTap(localHealth, localMana)
	if (localMana < localHealth and HasSpell("Life Tap") and localHealth > self.lifeTapHealth and localMana < self.lifeTapMana and not IsMounted() and not IsInCombat()) then
		if(IsSpellOnCD("Life Tap")) then 
			return false; 
		else 
			CastSpellByName("Life Tap"); 
			return true; 
		end
	end
end


function script_warlock:rest()

	if(not self.isSetup) then
		script_warlock:setup();
	end

	local localObj = GetLocalPlayer();
	local localMana = localObj:GetManaPercentage();
	local localHealth = localObj:GetHealthPercentage();
	local hasPet = false;

	if(GetPet() ~= 0) then 
		hasPet = true; 
	end

	if(localMana < self.drinkMana or localHealth < self.eatHealth) then
		if (IsMoving()) then
			StopMoving();
			return true;
		end	
	end

	-- Cast: Life Tap if conditions are right, see the function
	if (not IsDrinking() and not IsEating()) then
		if (script_warlock:lifeTap(localHealth, localMana)) then
			return true; 
		end
	end

	-- Eat and Drink
	if (not IsDrinking() and localMana < self.drinkMana) then
		self.message = "Need to drink...";
		self.waitTimer = GetTimeEX() + 1200;
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

	if (localMana < 98 and IsDrinking()) or (localHealth < 98 and IsEating()) then
		self.message = "Resting to full hp/mana...";
		return true;
	end

	if (hasPet) and (self.useVoid) and (GetPet():GetHealthPercentage() < 75) and (HasSpell("Consume Shadows")) then
		CastSpellByName("Consume Shadows");
		self.waitTimer = GetTimeEX() + 7500;
		self.message = "Using Voidwalker Consume Shadows";
		return true;
	end

	-- Check: If the pet is an Imp, require Firebolt to be in slot 4
	local petIsImp = false;
	if (hasPet) then
		name, __, __, __, __, __, __ = GetPetActionInfo(4);
		if (name == "Firebolt") then petIsImp = true; end
	end
	
	-- Check: Summon our Demon if we are not in combat (Voidwalker is Summoned in favor of the Imp)
	if (not IsEating() and not IsDrinking() and (not hasPet)) then	
		if (not hasPet and not self.useVoid or self.useImp) or (HasSpell("Summon Succubus")) and HasItem('Soul Shard') and (self.useSuccubus) then
			if (not IsStanding() or IsMoving()) then 
				StopMoving();
			end
			if (localMana > 40) and (not hasPet) then
				CastSpellByName("Summon Succubus");
				self.waitTimer = GetTimeEX() + 14000;
				self.message = "Summoning Succubus";
				return true; 
			end
		elseif ((not hasPet or petIsImp) and HasSpell("Summon Voidwalker") and HasItem('Soul Shard') and self.useVoid) then
			if (not IsStanding() or IsMoving()) then 
				StopMoving();
			end
			if (localMana > 40) and (not hasPet) then
				CastSpellByName("Summon Voidwalker");
				self.waitTimer = GetTimeEX() + 14000;
				self.message = "Summoning Void Walker";
				return true; 
			end
		elseif (not hasPet and HasSpell("Summon Imp") and self.useImp) then
			if (not IsStanding() or IsMoving()) then
				StopMoving();
			end
			if (localMana > 30) then
				CastSpellByName("Summon Imp");
				self.waitTimer = GetTimeEX() + 14000;
				self.message = "Summoning Imp";
				return true;
			end
		end
	end

	--Create Healthstone
	local stoneIndex = -1;
	for i=0,self.numStone do
		if (HasItem(self.healthStone[i])) then
			stoneIndex= i;
			break;
		end
	end

	if (HasSpell('Create Healthstone')) then
		if (stoneIndex == -1 and HasItem("Soul Shard")) then 
			if (localMana > 10 and not IsDrinking() and not IsEating() and not AreBagsFull()) then
				self.message = "Creating a healthstone...";
				if (HasSpell('Create Healthstone') and IsMoving()) then
					StopMoving();
					return true;
				end
				if (HasSpell('Create Healthstone')) then
				CastSpellByName('Create Healthstone');
					return true;
				end
			end
		end
	end

	-- Do buffs if we got some mana 
	if (localMana > 30) then
		if(HasSpell("Demon Armor")) then
			if (not localObj:HasBuff("Demon Armor")) then
				if (not Buff("Demon Armor", localObj)) then
					return false;
				else
					self.message = "Buffing...";
					return true;
				end
			end
		elseif (not localObj:HasBuff('Demon Skin') and HasSpell('Demon Skin')) then
			if (not Buff('Demon Skin', localObj)) then
				return false;
			else
				self.message = "Buffing...";
				return true;
			end
		end
		if (HasSpell("Unending Breath")) and (self.useUnendingBreath) then
			if (not localObj:HasBuff('Unending Breath')) then
				if (not Buff('Unending Breath', localObj)) then
					return false;
				else
					self.message = "Buffing...";
					return true;
				end
			end
		end
	end

	-- Check: Health funnel on the pet or wait for it to regen if lower than 70%
	if (hasPet and GetPet():GetHealthPercentage() > 0) then
		if (GetPet():GetHealthPercentage() < 70) then
			if (GetPet():GetDistance() > 8) then
				PetFollow();
				self.waitTimer = GetTimeEX() + 1850; 
				return true;
			end
			if (GetPet():GetDistance() < 20 and localMana > 10) then
				if (hasPet and GetPet():GetHealthPercentage() < 70 and GetPet():GetHealthPercentage() > 0) then
					self.message = "Pet has lower than 70% HP, using health funnel...";
					if (IsMoving() or not IsStanding()) then StopMoving(); return true; end
					if (HasSpell('Health Funnel')) then CastSpellByName('Health Funnel'); end
					self.waitTimer = GetTimeEX() + 1850; 
					return true;
				end
			end
		end
	end

	-- No rest / buff needed
	return false;
end

function script_warlock:mount()

	if(not IsMounted() and not IsSwimming() and not IsIndoors() 
		and not IsLooting() and not IsCasting() and not IsChanneling() 
			and not IsDrinking() and not IsEating()) then
		
		if(IsMoving()) then
			return true;
		end
		
		return UseItem(self.mountName);
	end
	
	return false;
end

function script_warlock:window()

	if (self.isChecked) then
	
		--Close existing Window
		EndWindow();

		if(NewWindow("Class Combat Options", 200, 200)) then
			script_warlock:menu();
		end
	end
end

function script_warlock:menu()
	if (CollapsingHeader("Warlock Combat Options")) then

		local wasClicked = false;

		if (HasSpell("Summon Imp")) then
			wasClicked, self.useImp = Checkbox("Use Imp", self.useImp);
			SameLine();
		end
		
		if (HasSpell("Summon Voidwalker")) then
			wasClicked, self.useVoid = Checkbox("Use Voidwalker", self.useVoid);
			SameLine();

			if (self.useVoid) then
				self.useImp = false;
				self.useSuccubus = false;
			end
		end

		if (HasSpell("Summon Succubus")) then
			wasClicked, self.useSuccubus = Checkbox("Use Succubus", self.useSuccubus);

			if (self.useSuccubus) then
				self.useImp = false;
				self.useVoid = false;
			end
		end
		
		if (HasSpell("Drain Soul")) then
			wasClicked, self.enableGatherShards = Checkbox("Gather Soul Shards", self.enableGatherShards);
		end

		Text('Drink below mana percentage');
		self.drinkMana = SliderFloat("M%", 1, 100, self.drinkMana);
		Text('Eat below health percentage');
		self.eatHealth = SliderFloat("H%", 1, 100, self.eatHealth);
		Text('Use health potions below percentage');
		self.potionHealth = SliderFloat("HP%", 1, 99, self.potionHealth);
		Text('Use mana potions below percentage');
		self.potionMana = SliderFloat("MP%", 1, 99, self.potionMana);
		Separator();

		Text('Skills options:');

		-- always fear
		if (HasSpell("Fear")) then
			wasClicked, self.alwaysFear = Checkbox("Fear Single Targets", self.alwaysFear);
			SameLine();
			
			if (self.alwaysFear) then
				self.fearAdds = false;
			end
		end
		
		-- fear only adds
		if (HasSpell("Fear")) then
			wasClicked, self.fearAdds = Checkbox("Fear Adds", self.fearAdds);

			if (self.fearAdds) then
				self.alwaysFear = false;
			end
		end

		-- use wand
		if (localObj:HasRangedWeapon()) then
			wasClicked, self.useWand = Checkbox("Use Wand", self.useWand);
			SameLine();

			if (self.useWand) then
				self.useShadowBolt = false;
			end
		end

		-- shadowbolt
		wasClicked, self.useShadowBolt = Checkbox("Shadowbolt instead of wand", self.useShadowBolt);
	
		if (self.useShadowBolt) then
			self.useWand = false;
		end

		-- unending breath
		if (HasSpell("Unending Breath")) then
			wasClicked, self.useUnendingBreath = Checkbox("Unending Breath On/Off", self.useUnendingBreath);
		end

		Separator();

		if (HasSpell("Drain Life")) then
			Text("Use Drain Life below self health percent");
			self.drainLifeHealth = SliderInt("DLH", 1, 80, self.drainLifeHealth);
			Separator();
		end

		if (HasSpell("Health Funnel")) then
			Text("Heal Pet below pet health percent");
			self.healPetHealth = SliderInt("HPH", 1, 80, self.healPetHealth);
		end

		if (self.useVoid) then
			wasClicked, self.sacrificeVoid = Checkbox("Sacrifice Voidwalker when low self health", self.sacrificeVoid);
			if (self.sacrificeVoid) then
				Text("Self Health OR Pet Health percent to Sacrifice Voidwalker")
				self.sacrificeVoidHealth = SliderInt("SVH", 1, 25, self.sacrificeVoidHealth);
				Separator();
			end
		end

		if (CollapsingHeader("-- DoT Options")) then
			if (HasSpell("Corruption")) and (self.enableCorruption) then
				Text("Corruption cast time - 14 is 1.4 seconds");	
				self.corruptionCastTime = SliderInt("CCT (ms)", 0, 20, self.corruptionCastTime);
				Separator();
			end
			
			if (HasSpell("Siphon Life")) then
				wasClicked, self.enableSiphonLife = Checkbox("Siphon Life On/Off", self.enableSiphonLife);
				SameLine();
			end

			if (HasSpell("Immolate")) then
				wasClicked, self.enableImmolate = Checkbox("Immolate On/Off",self.enableImmolate);
			end

			if (HasSpell("Curse of Agony")) then
				wasClicked, self.enableCurseOfAgony = Checkbox("Curse of Agony On/Off", self.enableCurseOfAgony);
				SameLine();
			end

			if (HasSpell("Corruption")) then
				wasClicked, self.enableCorruption = Checkbox("Corruption On/Off", self.enableCorruption);
			end

		end		

		if (CollapsingHeader("-- Curse Options")) then
			Text("TODO! ?? maybe.. is it worth it?");
		end

		if (localObj:HasRangedWeapon() and self.useWand) then
			if (CollapsingHeader("-- Wand Options")) then
				Text("Use Wand below target health percent");
				self.useWandHealth = SliderInt("WH", 1, 100, self.useWandHealth);
				Text("Use Wand below self mana percent");
				self.useWandMana = SliderInt("WM", 1, 100, self.useWandMana);
			end
		end

		Separator();

		if (HasSpell("Life Tap")) then
			if (CollapsingHeader("-- Life Tap Options")) then
				Text("Use Life Tap above this percent health");
				self.lifeTapHealth = SliderInt("LTH", 50, 90, self.lifeTapHealth);
				Text("Use Life Tap below this percent mana");
				self.lifeTapMana = SliderInt("LTM", 15, 80, self.lifeTapMana);
			end
		end
	end
end