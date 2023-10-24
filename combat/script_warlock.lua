script_warlock = {
	message = 'Warlock Combat Script',
	warlockMenu = include("scripts\\combat\\script_warlockEX.lua"),
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
	alwaysFear = false,
	useDrainMana = false,
	hasPet = false,
	useVoid = false,
	useImp = false,
	useSuccubus = false,
	useFelhunter = false,
	wandHealthPreset = 10, -- preset to attack target with 10% HP using wand, reset in Setup function for dungeon to cast shadowbolt
	drainSoulHealthPreset = 30,
	hasSufferingSpell = false,
	hasConsumeShadowsSpell = false,
	hasSacrificeSpell = false,
	followTargetDistance = 100,
	targetCorruption = false,
	targetImmolate = false,
	rangeDistance = 35,
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

function script_warlock:isTargetingGroup(y) 
	for i = 1, GetNumPartyMembers() do
		local partyMember = GetPartyMember(i);
		if (partyMember ~= nil and partyMember ~= 0 and not partyMember:IsDead()) then
			if (y:GetUnitsTarget() ~= nil and y:GetUnitsTarget() ~= 0 and not script_follow:isTargetingPet(y)) then
				return y:GetUnitsTarget():GetGUID() == partyMember:GetGUID();
			end
		end
	end
	return false;
end


--function script_warlock:addHealthStone(name)
--	self.healthStone[self.numStone] = name;
--	self.numStone = self.numStone + 1;
--end

function script_warlock:setup()
	--script_warlock:addHealthStone('Major Healthstone');
	--script_warlock:addHealthStone('Greater Healthstone');
	--script_warlock:addHealthStone('Healthstone');
	--script_warlock:addHealthStone('Lesser Healthstone');
	--script_warlock:addHealthStone('Minor Healthstone');

	self.waitTimer = GetTimeEX();
	self.fearTimer = GetTimeEX();
	self.cooldownTimer = GetTimeEX();


-- issue with hasPet and not having pet low level causing the bot to stop
-- may be a combat command. learning a pet spell and summoning pet continues the script
	if (GetNumPartyMembers() >= 1) then
		self.fearAdds = false;
		self.useImp = true;
		self.healPetHealth = 20;
		self.drainLifeHealth = 50;
		self.wandHealthPreset = 5;
		self.drainSoulHealthPreset = 10;
	end

	if (GetNumPartyMembers() < 1) then
		if (not HasSpell("Summon Voidwalker")) and (HasSpell("Summon Imp")) then
			self.useImp = true;
			self.useVoid = false;
			self.useSuccubus = false;
			self.useFelhunter = false;
			self.hasPet = false;
		elseif (HasSpell("Summon Voidwalker")) then
			self.useImp = false;
			self.useVoid = true;
			self.useSuccubus = false;
			self.useFelhunter = false;
			self.hasPet = false;
		elseif (not HasSpell("Summon Imp")) then
			self.useImp = false;
			self.useVoid = false;
			self.useSuccubus = false;
			self.useFelhunter = false;
			self.hasPet = false;
		-- elseif (HasSpell("Summon Succubus")) then
		-- 	self.useSuccubus = true;
		-- 	self.useImp = false;
		-- 	self.useVoid = false;
		-- elseif ("HasSpell("Summon Felhunter")) then
		-- 	self.useSuccubus = false;
		-- 	self.useImp = false;
		-- 	self.useVoid = false;
		--	self.useFelhunter = true;
		end
	end

	-- set corruption based on talent points assuming affliction spec
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

		
	if (not localObj:HasRangedWeapon()) then
		self.useShadowBolt = true;
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

	if (GetPet() ~= 0) then
		self.hasPet = true;
	else
		if (GetPet() == 0 or GetPet():GetHealthPercentage() < 1) then
			self.hasPet = false;
		end
	end

	-- Check: If the pet is void and has spell Consume Shadows
	if (self.hasPet) and (self.useVoid) and (GetPet() ~= 0) then
		name, __, __, __, __, __, __ = GetPetActionInfo(6);
		if (name == "Consume Shadows") then 
			self.hasConsumeShadowsSpell = true;
		end
	end
	
	-- Check: If the pet is void and has spell suffering
	if (self.hasPet) and (self.useVoid) and (GetPet() ~= 0) then
		name, __, __, __, __, __, __ = GetPetActionInfo(7);
		if (name == "Suffering") then 
			self.hasSufferingSpell = true;
		end
	end

	-- Check: If the pet is void and has spell sacrifice
	if (self.hasPet) and (self.useVoid) and (GetPet() ~= 0) then
		name, __, __, __, __, __, __ = GetPetActionInfo(5);
		if (name == "Sacrifice") then 
			self.hasSacrificeSpell = true;
		end
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

	if (not script_grind.adjustTickRate) then
		if (not IsInCombat()) or (targetObj:GetDistance() > self.rangeDistance) then
			script_grind.tickRate = 100;
		elseif (IsInCombat()) then
			script_grind.tickRate = 750;
		end
	end

	--Valid Enemy
	if (targetObj ~= 0 and targetObj ~= nil) then
		
		if (targetObj:GetHealthPercentage() < 80) then
			if (targetObj:HasDebuff("Corruption")) then
				self.targetCorruption = true;
			else 
				self.targetCorruption = false;
			end
			if (targetObj:HasDebuff("Immolate")) then
				self.targetImmolate = true;
			else
				self.targetImmolate = false;
			end
		end

		-- Cant Attack dead targets
		if (targetObj:IsDead() or not targetObj:CanAttack()) then
			ClearTarget();
			return 2;
		end
		
		-- stand if sitting
		if (not IsStanding()) then
			JumpOrAscendStart();
		end

		if (targetObj:IsInLineOfSight() and not IsMoving()) and (targetObj:GetHealthPercentage() < 99) then
			if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
				if (not targetObj:FaceTarget()) then
					targetObj:FaceTarget();
				end
			end
		end

		-- set target health
		targetHealth = targetObj:GetHealthPercentage();

		-- Auto attack
		if (targetObj:GetDistance() < 40) or (localMana < 25) then
			targetObj:AutoAttack();
		end


		-- level 1 - 4
			if (not HasSpell("Summon Imp")) and (localMana > 25) and (targetObj:IsInLineOfSight()) and (GetLocalPlayer():GetLevel() <= 3) and (not IsMoving()) then
				if (Cast('Shadow Bolt', targetObj)) then
					targetObj:FaceTarget();
					self.waitTimer = GetTimeEX() + 1650;
					return;
				end
			elseif (not self.targetImmolate) and (HasSpell("Summon Imp")) and (localMana > 25) and (targetObj:IsInLineOfSight()) and (not targetObj:HasDebuff("Immolate")) then
				if (IsMoving()) then
					StopMoving();
					targetObj:FaceTarget();
					PetAttack();
				end
	
				targetObj:FaceTarget();
				CastSpellByName("Immolate");
				self.targetImmolate = true;
				self.waitTimer = GetTimeEX() + 2650;
			end

		-- Check: if we target player pets/totems
		if (GetTarget() ~= nil and targetObj ~= nil) then
			if (UnitPlayerControlled("target") and GetTarget() ~= localObj) then 
				script_grind:addTargetToBlacklist(targetObj:GetGUID());
				return 5; 
			end
		end 

		-- nav move to target causing crashes on follower
		-- move to cancel Health Funnel when payer has low HP
		if (GetNumPartyMembers() < 1) then
			if (GetPet() ~= 0 and self.hasPet) and (self.useVoid or self.useImp or self.useSuccubus or self.useFelhunter) then
				if (GetPet():HasBuff("Health Funnel") and localHealth < 40) then
					local _x, _y, _z = localObj:GetPosition();
					script_nav:moveToTarget(localObj, _x + 1, _y + 1, _z); 
					return 0;
				end
			end
		end

			-- nav move to target causing crashes on follower
		-- move to cancel Drain Life when we get Nightfall buff
		if (GetNumPartyMembers() < 1) then
			if (GetTarget() ~= 0 and self.hasPet) and (HasSpell("Drain Life")) then	
				if (GetTarget():HasDebuff("Drain Life") and localObj:HasBuff("Shadow Trance")) then
				local _x, _y, _z = localObj:GetPosition();
					script_nav:moveToTarget(localObj, _x + 1, _y, _z); 
					return 0;
				end
			end
		end

		-- START OF COMBAT PHASE

		-- Opener - not in combat pulling target
		if (not IsInCombat()) then
			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";
			
			-- Opener check range of ALL SPELLS
			if (HasSpell("Corruption")) and (not targetObj:HasDebuff("Corruption")) then
				if (not targetObj:IsSpellInRange("Corruption")) or (not targetObj:IsInLineOfSight()) then
				return 3;
				end
			elseif (not targetObj:IsSpellInRange("Shadowbolt")) or (not targetObj:IsInLineOfSight()) then
				return 3;
			end

			-- level 1 - 4
			if (not HasSpell("Summon Imp")) and (localMana > 25) then
				if (Cast('Shadow Bolt', targetObj)) then
					return 0;
				end
			end

			-- if pet goes too far then recall
			if (GetPet() ~= 0 and self.hasPet) and (self.useVoid or self.useImp or self.useSuccubus or self.useFelhunter) and (GetPet():GetDistance() > 40) then
				PetFollow();
			end

			-- Dismount
			if (IsMounted()) then
				DisMount(); 
			end

			-- new follow target
			if (targetObj:IsInLineOfSight() and not IsMoving()) then
				if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) and (targetObj:GetHealthPercentage() < 99) then
					if (not targetObj:FaceTarget()) then
						targetObj:FaceTarget();
					end
				end
			end

			-- check pet
			if(GetPet() ~= 0) then 
				self.hasPet = true; 
			else
				if (GetPet() == 0 or GetPet():GetHealthPercentage() < 1) then
					self.hasPet = false;
				end
			end

			-- spells to pull

			-- Amplify Curse on CD
			if (HasSpell("Amplify Curse")) and (not IsSpellOnCD("Amplify Curse")) and (targetObj:GetDistance() <= 50) then
				CastSpellByName("Amplify Curse");
				return 0;
			end

			-- resummon when sacrifice is active
			if (self.useVoid) and (self.sacrificeVoid) and (localObj:HasBuff("Sacrifice")) and (not self.hasPet) and (localMana > 35) then
				if (GetPet == 0 or GetPet():GetHealthPercentage() < 1) and (not self.hasPet) then
					if (CastSpellByName("Summon Voidwalker")) then
						self.hasPet = true;
						return 0;
					end
				end
			end

			if (HasSpell("Siphon Life")) and (self.enableSiphonLife) and (targetHealth > 20) then
					self.message = "Stacking DoT's";
					 if (self.useVoid or self.useImp or self.useSuccubus or self.useFelhunter) and (self.hasPet) then
						PetAttack();
					end
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					targetObj:FaceTarget();

					if (Cast("Siphon Life", targetObj)) then
						self.waitTimer = GetTimeEX() + 1600; 
						return 0;
					end
			elseif (HasSpell("Curse of Agony")) and (self.enableCurseOfAgony) and (targetHealth > 20) then
				self.message = "Stacking DoT's";
				if (self.useVoid or self.useImp or self.useSuccubus or self.useFelhunter) and (self.hasPet) then
					PetAttack();
				end
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				targetObj:FaceTarget();
				if (Cast('Curse of Agony', targetObj)) then 
					self.waitTimer = GetTimeEX() + 1600;
					return 0;
				end
			else
				if (HasSpell("Shadow Bolt")) then
					self.message = "Pulling Target";
					if (self.useVoid or self.useImp or self.useSuccubus or self.useFelhunter) and (self.hasPet) then
						PetAttack();
					end
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
						targetObj:FaceTarget();
					if (CastSpellByName("Shadow Bolt", targetObj)) then
						self.waitTimer = GetTimeEX() + 1800;
						return 0;
					end
				end
			end

			if (not targetObj:IsInLineOfSight()) then -- check line of sight
				self.message = "Moving into Line of Sight of target";
				return 3;
			end
	
			if (targetObj:IsInLineOfSight() and not IsMoving()) then
				if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) and (targetObj:GetHealthPercentage() < 99) then
					if (not targetObj:FaceTarget()) then
						targetObj:FaceTarget();
					end
				end
			end
			
			-- IN COMBAT

			-- Combat
		else	
			self.message = "Killing " .. targetObj:GetUnitName() .. "...";

			-- causes crashing after combat phase?
			-- follow target if single target fear is active and moves out of spell range
			--if (self.alwaysFear) and (targetObj:HasDebuff("Fear")) and (targetObj:GetDistance() > 20) then
			--	script_nav:moveToTarget(localObj, targetObj:GetPosition());
			--	self.waitTimer = GetTimeEX() + 500;
			--end

			-- recall pet if too far > 30
			if (GetPet() ~= 0) and (self.useVoid or self.useImp or self.useSuccubus or self.useFelhunter) and (GetPet():GetDistance() > 25) then
				self.message = "Recalling Pet - too far!";
				PetFollow();
			end

			-- Set the pet to attack
			if (GetPet() ~= 0) and (self.useVoid or self.useImp or self.useSuccubus or self.useFelhunter) and (GetPet():GetHealthPercentage() >= 1) and (targetObj:GetDistance() < 35) and (targetHealth < 99 or targetObj:HasDebuff("Curse of Agony") or 
				targetObj:HasDebuff("Corruption")) or (script_grind:isTargetingMe(targetObj)) and (not targetObj:HasDebuff("Fear")) then
				PetAttack();
			end

			-- check pet
			if(GetPet() ~= 0) then 
				self.hasPet = true; 
			else
				if (GetPet() == 0 or GetPet():GetHealthPercentage() < 1) then
					self.hasPet = false;
				end
			end

			-- Dismount
			if(IsMounted()) then 
				DisMount();
			end

			-- new follow / face target
			if (targetObj:IsInLineOfSight() and not IsMoving()) then
				if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) and (targetHealth < 99) then
					if (not targetObj:FaceTarget()) then
						targetObj:FaceTarget();
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

			-- death coil
			if (HasSpell("Death Coil")) and (not IsSpellOnCD("Death Coil")) and (localHealth < 65) and (localMana > 20) then
				if (CastSpellByName("Death Coil", targetObj)) then
					self.waitTimer = GetTimeEC() + 1500;
					return 0;
				end
			end

			-- voidwalker taunt
			if (GetPet() ~= 0) and (self.useVoid) and (not IsSpellOnCD("Suffering")) and (script_grind:enemiesAttackingUs(5) >= 2) and (self.hasSufferingSpell) then
				if (CastSpellByName("Suffering")) then
				end
			end

			-- check pet
			if(GetPet() ~= 0) then 
				self.hasPet = true; 
			else
				if (GetPet() == 0) or (GetPet():GetHealthPercentage() < 1) then
					self.hasPet = false;
				end
			end

			-- sacrifice voidwalker low health
			if (GetPet() ~= 0) and (self.useVoid) and (self.hasSacrificeSpell) and (self.sacrificeVoid) and (localHealth <= self.sacrificeVoidHealth or GetPet():GetHealthPercentage() <= self.sacrificeVoidHealth) then
				CastSpellByName("Sacrifice");
				self.waitTimer = GetTimeEX() + 1500;
				self.hasPet = false;
				return 0;
			end

			-- check pet
			if(GetPet() ~= 0) then 
				self.hasPet = true; 
			else
				if (GetPet() == 0) or (GetPet():GetHealthPercentage() < 1) then
					self.hasPet = false;
				end
			end


			-- resummon when sacrifice is active
			if (self.useVoid) and (self.sacrificeVoid) and (localObj:HasBuff("Sacrifice")) and (not self.hasPet) and (localMana > 35) then
				if (not self.hasPet) then
					if (CastSpellByName("Summon Voidwalker")) then
						self.hasPet = true;
						return 0;
					end
				end
			end

			-- Dark Pact instead of lifetap in combat
			if (HasSpell("Dark Pact")) and (localMana < 40) and (GetPet() ~= 0 or self.hasPet) and (self.useImp or self.useVoid or self.useSuccubus or self.useFelhunter) and (not IsLooting()) then
				if (GetPet():GetManaPercentage() > 20) and (not IsSpellOnCD("Dark Pact")) then
					if (CastAndWalk("Dark Pact", localObj)) then
						self.message = "Casting Dark Pact instead of drinking!";
						return;
					end
				end
			end
			-- Check: If we get Nightfall buff then cast Shadow Bolt
			if (localObj:HasBuff("Shadow Trance")) then
				if (Cast('Shadow Bolt', targetObj)) then
					return 0;
				end
			end	

			-- Use Healthstone
			--if (localHealth < self.stoneHealth) then
			--	for i=0,self.numStone do
			--		if(HasItem(self.healthStone[i])) then
			--			if (UseItem(self.healthStone[i])) then
			--				return 0;
			--			end
			--		end
			--	end
			--end

			-- Fear single Target
			if (self.alwaysFear) and (HasSpell("Fear")) and (not targetObj:HasDebuff("Fear")) and (targetObj:GetHealthPercentage() > 40) then
				if (Cast("Fear", targetObj)) then
					self.waitTimer = GetTimeEX() + 1900;
					return 0;
				end
			end
			
			if (targetObj:IsInLineOfSight() and not IsMoving() and targetHealth < 99) then
				if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
					if (not targetObj:FaceTarget()) then
						targetObj:FaceTarget();
					end
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

			-- Howling Terror Fear
			if (HasSpell("Howling Terror")) and (not IsSpellOnCD("Howling Terror")) and (script_grind:enemiesAttackingUs(5) >= 3) then
				if (localHealth > 25) then
					CastSpellByName("Howling Terror");
					self.waitTimer = GetTimeEX() + 1500;
					return 0;
				end
			end
			
			-- Check: If we don't have a soul shard, try to make one
			if (targetHealth < self.drainSoulHealthPreset and targetHealth > 3 and HasSpell("Drain Soul") and not HasItem('Soul Shard')) then
				if (Cast('Drain Soul', targetObj)) then
					return 0;
				end
			end

				-- nav move to target causing crashes on follower
			-- Check: Heal the pet if it's below 50% and we are above 50%
			if (GetNumPartyMembers() < 1) then
				if (GetPet() ~= 0) and (self.useVoid or self.useImp or self.useSuccubus or self.useFelhunter) and (GetPet():GetHealthPercentage() > 1 and GetPet():GetHealthPercentage() <= self.healPetHealth) and (HasSpell("Health Funnel")) and (localHealth > 60) then
					if (GetPet():GetDistance() >= 20 or not GetPet():IsInLineOfSight()) and (self.hasPet) then
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
			end

			-- if pet goes too far then recall
			if (GetPet() ~= 0) and (self.useVoid or self.useImp or self.useSuccubus or self.useFelhunter) and (GetPet():GetDistance() > 40) then
				PetFollow();
			end

			-- Wand if low mana
			if (localMana <= 5 or targetHealth <= self.wandHealthPreset) and (localObj:HasRangedWeapon()) and (not self.enableGatherShards) then
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
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 1600;
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
				if (targetHealth <= 30 and targetHealth >= 6) and (HasSpell("Drain Soul")) then
					if (IsAutoCasting("Shoot")) then
						script_nav:moveToTarget(localObj, targetObj:GetPosition()); 
						self.waitTimer = GetTimeEX() + 500;
						return 0;
					elseif (targetObj:GetDistance() <= 30) then
						if (Cast('Drain Soul', targetObj)) then
						self.waitTimer = GetTimeEX() + 500;
						return 0;
						end
					else
						script_nav:moveToTarget(localObj, targetObj:GetPosition()); 
						self.waitTimer = GetTimeEX() + 500;
						return 0;
					end
				end
			end

			-- Drain Life on low health
			if (HasSpell("Drain Life")) and (targetObj:GetCreatureType() ~= "Mechanic") and (localHealth <= self.drainLifeHealth) and (localMana > 5) and (not IsChanneling()) and (not self.useDrainMana) then
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

			-- Drain Mana on low mana
			if (HasSpell("Drain Mana")) and (self.useDrainMana) and (targetObj:GetCreatureType() ~= "Mechanic") and (targetObj:GetManaPercentage() >= 25) and (localMana <= 65) then
				self.message = "Casting Drain Mana";
				if (targetObj:GetDistance() < 20) then
					if (IsMoving()) then StopMoving(); 
						return; 
					end
					if (Cast('Drain Mana', targetObj)) then 
						return; 
					end
				else
					script_nav:moveToTarget(localObj, targetObj:GetPosition()); 
					self.waitTimer = GetTimeEX() + 2000;
					return 0;
				end
			end

			-- check pet
			if(GetPet() ~= 0) then 
				self.hasPet = true; 
			else
				if (GetPet() == 0 or GetPet():GetHealthPercentage() < 1) then
					self.hasPet = false;
				end
			end

				-- nav move to target causing crashes on follower
			-- Check: Heal the pet if it's below 50% and we are above 50%
			if (GetNumPartyMembers() < 1) then
				if (GetPet() ~= 0) and (self.useVoid or self.useImp or self.useSuccubus or self.useFelhunter) and (GetPet():GetHealthPercentage() > 0 and GetPet():GetHealthPercentage() <= self.healPetHealth) and (HasSpell("Health Funnel")) and (localHealth > 60) then
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
			end

-- Check: Keep the Curse of Agony up (24 s duration)
			if (self.enableCurseOfAgony) then
				if (not targetObj:HasDebuff("Curse of Agony") and targetHealth > 20) then
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					if (Cast('Curse of Agony', targetObj)) then
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 1600;
						return 0;
					end
				end
			end
	
			-- Check: Keep the Corruption DoT up (15 s duration)
			if (not self.targetCorruption) and (self.enableCorruption) and (not targetObj:HasDebuff("Corruption")) then
				if (not targetObj:HasDebuff("Corruption") and targetHealth >= 20) then
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					if (not self.targetCorruption) and (targetObj:IsInLineOfSight()) and (not targetObj:HasDebuff("Corruption")) then
						self.targetCorruption = true;
						Cast('Corruption', targetObj);
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 1600 + (self.corruptionCastTime / 10); 
					end
				end
			end
	
			-- Check: Keep the Immolate DoT up (15 s duration)
			if (not self.targetImmolate) and (self.enableImmolate) and (not targetObj:HasDebuff("Immolate")) and (not IsSpellOnCD("Immolate")) then
				if (not targetObj:HasDebuff("Immolate")) and (localMana > 25) and (targetHealth > 20) then
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					if (targetObj:IsInLineOfSight()) and (not targetObj:HasDebuff("Immolate")) then
						self.targetImmolate = true;
						CastSpellByName("Immolate", targetObj);
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 2650;
						return 0;
					end
				end
			end

			if (self.useShadowBolt) then
				-- Cast: Shadow Bolt
				if (Cast('Shadow Bolt', targetObj)) then
					targetObj:FaceTarget();
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					return 0;
				end
				-- wand instead
			elseif (self.useWand) and (localHealth > self.drainLifeHealth or GetPet():GetHealthPercentage() > self.healPetHealth) and (not IsChanneling()) then
				if (localObj:HasRangedWeapon()) then
					self.message = "Using wand...";
					if (not IsAutoCasting("Shoot")) then
						targetObj:FaceTarget();
						targetObj:CastSpell("Shoot");
						self.waitTimer = GetTimeEX() + 1250; 
						return true;
					end
				end
			end	

			if (self.useShadowBolt) then
				CastSpellByName("Shadow Bolt");
				self.waitTimer = GetTimeEX() + 1000;
			end

			if (targetObj:IsInLineOfSight() and not IsMoving()) then
				if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) and (targetHealth < 99) then
					if (not targetObj:FaceTarget()) then
						targetObj:FaceTarget();
					end
				end
			end
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

	if (not script_grind.adjustTickRate) then
		if (not IsInCombat()) then
			script_grind.tickRate = 100;
		elseif (IsInCombat()) then
			script_grind.tickRate = 750;
		end
	end

	-- use scrolls
	if (script_helper:useScrolls()) then
		self.waitTimer = GetTimeEX() + 1500;
	end

	-- check pet
	if(GetPet() ~= 0) then 
		self.hasPet = true; 
	else
		if (GetPet() == 0 or GetPet():GetHealthPercentage() < 1) then
			self.hasPet = false;
		end
	end

	-- Dark Pact instead of drink
	if (HasSpell("Dark Pact")) and (IsStanding()) and (localMana < 75) and (GetPet() ~= 0 or self.hasPet) and (self.useImp or self.useVoid or self.useSuccubus or self.useFelhunter) then
		if (not IsSpellOnCD("Dark Pact")) and (GetPet():GetManaPercentage() > 20) and (IsStanding()) then
			if (CastAndWalk("Dark Pact", localObj)) then
				self.message = "Casting Dark Pact instead of drinking!";
				return;
			end
		end
	end

	-- Stop moving before we can rest
	if(localMana < self.drinkMana or localHealth < self.eatHealth) and (not IsSwimming()) then
		self.waitTimer = GetTimeEX() + 2000;
		if (IsMoving()) then
			StopMoving();
			return true;
		end	
	end

	-- Cast: Life Tap if conditions are right, see the function
	if (localMana < localHealth and HasSpell("Life Tap") and localHealth > self.lifeTapHealth 
		and localMana < self.lifeTapMana and not IsInCombat() and (not IsEating() and not IsDrinking())) then
		if (not IsStanding()) then
			JumpOrAscendStart();
		end
		if (CastSpellByName("Life Tap")) then
			self.waitTimer = GetTimeEX() + 1600;
			return 0;
		end
		return 0;
	end

	-- Eat and Drink
	if (not IsDrinking() and localMana < self.drinkMana) and (not IsSwimming()) then
		self.message = "Need to drink...";
		self.waitTimer = GetTimeEX() + 2000;
		if (IsMoving()) then
			StopMoving();
			self.waitTimer = GetTimeEX() + 2000;
			return true;
		end

		if (script_helper:drinkWater()) then 
			self.message = "Drinking..."; 
			self.waitTimer = GetTimeEX() + 2000;
			return true; 
		else 
			self.message = "No drinks! (or drink not included in script_helper)";
			return true; 
		end
	end
	if (not IsEating() and localHealth < self.eatHealth) and (not IsSwimming()) then
		self.waitTimer = GetTimeEX() + 2000;
		self.message = "Need to eat...";	
		if (IsMoving()) then
			StopMoving();
			return true;
		end
		
		if (script_helper:eat()) then 
			self.message = "Eating..."; 
			self.waitTimer = GetTimeEX() + 2000;
			return true; 
		else 
			self.message = "No food! (or food not included in script_helper)";
			return true; 
		end	
	end

	if (localMana < 98 and IsDrinking()) or (localHealth < 98 and IsEating()) then
		self.message = "Resting to full hp/mana...";
		self.waitTimer = GetTimeEX() + 2000;
		return true;
	end

	if (GetPet() ~= 0) and (self.useVoid) and (GetPet():GetHealthPercentage() < 75 and GetPet():GetHealthPercentage() > 1) and (self.hasConsumeShadowsSpell) and (not IsSpellOnCD("Consume Shadows")) then
		CastSpellByName("Consume Shadows");
		self.waitTimer = GetTimeEX() + 7500;
		self.message = "Using Voidwalker spell Consume Shadows";
		return true;
	end

	if (GetPet() == 0 or GetPet():GetHealthPercentage() < 1) then
		self.hasPet = false;
	else
		if (GetPet() ~= 0) then
			self.hasPet = true;
		end
	end
	
	-- Check: Summon our Demon if we are not in combat
	if (not IsEating()) and (not self.hasPet) and (not IsDrinking()) and (GetPet() == 0 or GetPet():GetHealthPercentage() < 1) and (HasSpell("Summon Imp")) and (self.useVoid or self.useImp or self.useSuccubus or self.useFelhunter) then
		-- succubus	
		if (GetPet() == 0 or GetPet():GetHealthPercentage() < 1) and (not self.hasPet) and (self.useSuccubus) and (HasSpell("Summon Succubus")) and HasItem('Soul Shard') then
			if (not IsStanding() or IsMoving()) then 
				StopMoving();
			end
			-- summon succubus
			if (localMana > 35) and (GetPet() == 0 or GetPet():GetHealthPercentage() < 1) and (not self.hasPet) then
				if (not IsStanding() or IsMoving()) then
					StopMoving();
				end
				if (CastSpellByName("Summon Succubus")) and (GetPet == 0 or GetPet():GetHealthPercentage() < 1) and (not self.hasPet) then
					self.waitTimer = GetTimeEX() + 14000;
					self.message = "Summoning Succubus";
					self.hasPet = true;
					return 0; 
				end
			end
		elseif (GetPet() == 0 or GetPet():GetHealthPercentage() < 1) and (self.useVoid) and (HasSpell("Summon Voidwalker")) and (HasItem('Soul Shard')) and (not self.hasPet) then
			if (not IsStanding() or IsMoving()) then 
				StopMoving();
			end
			-- summon voidwalker
			if (localMana > 35) and (GetPet() == 0 or GetPet():GetHealthPercentage() < 1) and (not self.hasPet) then
				if (not IsStanding() or IsMoving()) then
					StopMoving();
				end
				if (CastSpellByName("Summon Voidwalker")) and (GetPet == 0 or GetPet():GetHealthPercentage() < 1) and (not self.hasPet) then
					self.waitTimer = GetTimeEX() + 14000;
					self.message = "Summoning Void Walker";
					self.hasPet = true;
					return 0; 
				end
			end
		elseif (GetPet() == 0 or GetPet():GetHealthPercentage() < 1) and (self.useFelhunter) and (HasSpell("Summon Felhunter")) and (HasItem('Soul Shard')) and (not self.hasPet) then
			if (not IsStanding() or IsMoving()) then 
				StopMoving();
			end
			-- summon Felhunter
			if (localMana > 35) and (GetPet() == 0 or GetPet():GetHealthPercentage() < 1) and (not self.hasPet) then
				if (not IsStanding() or IsMoving()) then
					StopMoving();
				end
				if (CastSpellByName("Summon Felhunter")) and (GetPet == 0) and (not self.hasPet) then
					self.waitTimer = GetTimeEX() + 14000;
					self.message = "Summoning Felhunter";
					hasPet = true;
					return 0; 
				end
			end
		elseif (GetPet() == 0 or GetPet():GetHealthPercentage() < 1) and (HasSpell("Summon Imp")) and (self.useImp) and (not IsChanneling()) and (not self.hasPet) then
			if (not IsStanding() or IsMoving()) then
				StopMoving();
			end
			-- summon Imp
			if (localMana > 35) and (GetPet() == 0 or GetPet():GetHealthPercentage() < 1) and (not self.hasPet) then
				if (not IsStanding() or IsMoving()) then
					StopMoving();
				end
				if (CastSpellByName("Summon Imp")) and (GetPet == 0 or GetPet():GetHealthPercentage() < 1) and (not self.hasPet) then
					self.waitTimer = GetTimeEX() + 14000;
					self.message = "Summoning Imp";
					self.hasPet = true;
					return 0;
				end
			end
		end
	end

	--Create Healthstone
	--local stoneIndex = -1;
	--for i=0,self.numStone do
	--	if (HasItem(self.healthStone[i])) then
	--		stoneIndex= i;
	--		break;
	--	end
	--end

	--if (HasSpell('Create Healthstone')) then
	--	if (stoneIndex == -1 and HasItem("Soul Shard")) then 
	--		if (localMana > 10 and not IsDrinking() and not IsEating() and not AreBagsFull()) then
	--			self.message = "Creating a healthstone...";
	--			if (HasSpell('Create Healthstone') and IsMoving()) then
	--				StopMoving();
	--				return true;
	--			end
	--			if (HasSpell('Create Healthstone')) then
	--			CastSpellByName('Create Healthstone');
	--				return true;
	--			end
	--		end
	--	end
	--end

	-- Do buffs if we got some mana 
	if (localMana > 30) and (IsStanding()) then
		if(HasSpell("Demon Armor")) then
			if (not localObj:HasBuff("Demon Armor")) then
				if (not Buff("Demon Armor", localObj)) then
					return false;
				else
					self.message = "Buffing...";
					return true;
				end
			end
		elseif (not localObj:HasBuff('Demon Skin') and HasSpell('Demon Skin')) and (IsStanding()) then
			if (not Buff('Demon Skin', localObj)) then
				return false;
			else
				self.message = "Buffing...";
				return true;
			end
		end
		if (HasSpell("Unending Breath")) and (self.useUnendingBreath) and (IsStanding())then
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
	if (GetPet() ~= 0) and (self.useVoid or self.useImp or self.useSuccubus or self.useFelhunter) then
		if (GetPet():GetHealthPercentage() < 50) and (localHealth > 60) then
			if (GetPet():GetDistance() > 8) then
				PetFollow();
				self.waitTimer = GetTimeEX() + 1850; 
				return true;
			end
			if (GetPet():GetDistance() < 20 and localMana > 10) then
				if (GetPet() ~= 0 and GetPet():GetHealthPercentage() < 70 and GetPet():GetHealthPercentage() > 0) then
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
			script_warlock:menuEX();
		end
	end
end