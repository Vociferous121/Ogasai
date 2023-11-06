script_mage = {
	message = 'Frostbite - Mage Combat Script',
	mageMenu = include("scripts\\combat\\script_mageEX.lua"),
	drinkMana = 40,	-- drink at this mana %
	eatHealth = 51,	-- eat at this health %
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
	useQuelDoreiMeditation = true,	-- use turtle wow spell high elf racial yes/no
	QuelDoreiMeditationMana = 22,	-- use high elf racial below this mana %
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
	useDampenMagic = false,	-- use dampen magic yes/no
	fireMage = false,	-- is fire spec yes/no
	frostMage = false,	-- is frost spec yes/no
	scorchStacks = 2,	-- scorch debuff stacks on target
	useScorch = true,	-- use  yes/no
	followTargetDistance = 100,	-- new follow/face target distance here to debug melee
	waitTimer = GetTimeEX(),	-- set wait timer variable. probably not needed?
	rangeDistance = 38,

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
						ClearTarget();
						if (script_mage:cast('Polymorph', currentObj)) then 
							self.addPolymorphed = true; 
							polyTimer = GetTimeEX() + 8000;
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
function script_mage:runBackwards(targetObj, range) 
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
	if (localObj:GetLevel() < 4) then
		self.fireMage = true;
	end

	-- set spec below level 4-10
	if (localObj:GetLevel() >= 4) and (localObj:GetLevel() < 10) then
		self.frostMage = true;
	end
	
	-- set group settings mainly used for easy follower reloads
	if (GetNumPartyMembers() > 1) then
		self.useBlink = false;
		self.useFrostNova = false;
		self.polymorphAdds = false;
		self.useDampenMagic = false;
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
	
	-- when you click the start button all of this code runs at the script tick rate

	-- check setup
	if (not self.isSetup) then
		script_mage:setup();
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

	if (not script_grind.adjustTickRate) then
		if (not IsInCombat()) or (targetObj:GetDistance() > self.rangeDistance) then
			script_grind.tickRate = 100;
		elseif (IsInCombat()) then
			script_grind.tickRate = 500;
		end
	end

	--Valid Enemy
	if (targetObj ~= 0) and (targetObj ~= nil) and (not localObj:IsStunned()) and (not localObj:IsMovementDisabed()) then
		
		-- Cant Attack dead targets
		if (targetObj:IsDead()) or (not targetObj:CanAttack()) then
			ClearTarget();
			return 2;
		end
		
		-- stand if sitting
		if (not IsStanding()) then
			JumpOrAscendStart();
		end

		-- new follow target / facetarget
		if (targetObj:IsInLineOfSight()) and (not IsMoving()) then
			if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
				if (not targetObj:FaceTarget()) then
					targetObj:FaceTarget();
				end
			end
		end

		-- Don't attack if we should rest first
		if (GetNumPartyMembers() < 1) then
			if (localHealth < self.eatHealth or localMana < self.drinkMana) and (not script_grind:isTargetingMe(targetObj))
				and (not targetObj:IsFleeing()) and (not targetObj:IsStunned()) and (not script_mage:isAddPolymorphed()) then
				self.message = "Need rest...";
				return 4;
			end
		end

		-- set target health variable
		targetHealth = targetObj:GetHealthPercentage();

		-- Auto Attack
		if (targetObj:GetDistance() < 40) then
			targetObj:AutoAttack();
		end

		-- Check: if we target player pets/totems
		if (GetTarget() ~= nil) and (targetObj ~= nil) then
			if (UnitPlayerControlled("target")) and (GetTarget() ~= localObj) then 
				script_grind:addTargetToBlacklist(targetObj:GetGUID());
				return 5; 
			end
		end 
		
		--	START OF COMBAT PHASE
	
		-- Opener - not in combat pulling target
		if (not IsInCombat()) then

			-- display message in ogasai message box
			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";

			-- Opener spell if has frostbolt.... else....

			-- read the opener as following ---- if frost mage and has frost bolt then cast frost bolt
			-- else if fire mage and has pyroblast then cast pryroblast
			-- else if not has pyroblast then cast fireball
			-- else if frost mage and not has frost bolt yet then cast fireball
				-- many line of sight and other random checks to ensure the bot is doing what it needs to do

			if (targetObj:GetDistance() <= 28) and (targetObj:IsInLineOfSight()) then
				if (IsMoving()) then
					StopMoving();
				end
			end

			-- if frost mage and has frost bolt
			if (self.frostMage) and (HasSpell("Frostbolt")) then
	
				-- check range of all spells
				if (not targetObj:IsSpellInRange("Frostbolt")) or (not targetObj:IsInLineOfSight()) then
					self.message = "Pulling with Frostbolt!";
					return 3;
				end

				-- stand if sitting
				if (not IsStanding()) then
					JumpOrAscendStart();
				end

				-- we are in spell range to pull with frostbolt then stop moving
				if (targetObj:IsSpellInRange("Frostbolt")) and (targetObj:IsInLineOfSight()) then
					if (IsMoving()) then
						StopMoving();
					end
				end

				-- Dismount
				if (IsMounted()) then
					DisMount();
				end

				-- using frostbolt if we have it do the stuff below first
				if (HasSpell("Frostbolt")) then

					-- check line of sight using frostbolt
					if (not targetObj:IsInLineOfSight()) then
						return 3;
					end
				
					-- new follow target
					if (targetObj:IsInLineOfSight()) and (not IsMoving()) and (targetObj:GetHealthPercentage() < 99) then
						if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
							if (not targetObj:FaceTarget()) then
								targetObj:FaceTarget();
								self.waitTimer = GetTimeEX() + 0;
							end
						end
					end

					-- cast the spell - frostbolt
					if (localMana > 8) and (not IsMoving()) and (targetObj:IsInLineOfSight()) then
						if (CastSpellByName("Frostbolt", targetObj)) then
							targetObj:FaceTarget();
							self.waitTimer = GetTimeEX() + 1600;
							return 0;
						end
					end
				end

				-- recheck line of sight on target
				if (not targetObj:IsInLineOfSight()) then
					return 3;
				end
				
				-- fire mage selected use these spells instead
			elseif (self.fireMage) then
				
				-- check range using pyroblast if has spell
				if (HasSpell("Pyroblast")) and (not targetObj:IsSpellInRange("Pyroblast")) then
					return 3;

					-- else check range using fireball - is there a range difference? twow there is
				elseif (not HasSpell("Pyroblast")) and (not targetObj:IsSpellInRange("Fireball")) then
					return 3;
				end
				
				-- we are in spell range to pull with fireball then stop moving
				if (targetObj:IsSpellInRange("Fireball")) and (targetObj:IsInLineOfSight()) then
					if (IsMoving()) then
						StopMoving();
					end
				end

				-- stand if sitting
				if (not IsStanding()) then
					JumpOrAscendStart();
					self.waitTimer = GetTimeEX() + 1000;
				end

				-- new follow target / face target
				if (targetObj:IsInLineOfSight()) and (not IsMoving()) and (targetObj:GetHealthPercentage() < 99) then
					if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
						if (not targetObj:FaceTarget()) then
							targetObj:FaceTarget();
							self.waitTimer = GetTimeEX() + 0;
						end
					end
				end
			
				-- cast fireball to pull we do not have pyroblast yet
				if (HasSpell("Fireball")) and (not HasSpell("Pyroblast")) then

					-- recheck line of sight
					if (not targetObj:IsInLineOfSight()) then
						return 3;
					end
		
					-- cast the spell - fireball
					if (localMana > 12) and (not IsMoving()) and (targetObj:IsInLineOfSight()) then
						if (CastSpellByName("Fireball", targetObj)) then
							targetObj:FaceTarget();
							self.message = "Pulling with Fireball!";
							self.waitTimer = GetTimeEX() + 1600;
							return 0;
						end
					end

					-- end of pulling with fireball!
					--------------------------------

					-- read below as follows ---- if has pyrpblast then cast it
						-- else if target is too close and attacking us then cast fireball
							-- else if target is close but not attacking us then cast pyroblast

				-- else if has spell pyroblast then use it instead of fireball
				elseif (HasSpell("Pyroblast")) and (not IsSpellOnCD("Pyroblast")) then
				
					-- recheck line of sight
					if (not targetObj:IsInLineOfSight()) then
						return 3;
					end
		
					-- cast the spell - pyroblast
					if (localMana > 8) and (not IsMoving()) and (IsStanding()) and (targetObj:IsInLineOfSight()) and (not script_grind:isTargetingMe(targetObj)) then
						if (not targetObj:HasDebuff("Pyroblast")) and (not script_grind:isTargetingMe(targetObj)) and (not IsMoving()) then
							if (CastSpellByName("Pyroblast", targetObj)) then
								targetObj:FaceTarget();
								self.message = "Pulling with Pyroblast!";
								self.waitTimer = GetTimeEX() + 5500;
								return 0;
							end
						end
					
						-- cast fireball instead if target is too close or attacking us
					elseif (not IsMoving()) and (IsStanding()) and (targetObj:IsInLineOfSight()) and (script_grind:isTargetingMe(targetObj)) then
					
						-- cast the spell - fireball
						if (CastSpellByName("Fireball", targetObj)) then
							targetObj:FaceTarget();
							self.message = "Pulling with Fireball!";
							self.waitTimer = GetTimeEX() + 1600;
							return 0;
						end
					end
				end

					-- end of pulling with pyroblast!
					---------------------------------------

				-- recheck line of sight
				if (not targetObj:IsInLineOfSight()) then
					return 3;
				end

				-- frost mage slected use frost mage spells
			elseif (self.frostMage) and (not HasSpell("Frostbolt")) then				

				-- else if not has frostbolt then use fireball as range check
				if (not targetObj:IsSpellInRange("Fireball")) then
					return 3;
				end

				-- check line of sight
				if (not targetObj:IsInLineOfSight()) then
					return 3;
				end	

				-- stand if sitting
				if (not IsStanding()) then
					JumpOrAscendStart();
				end

				-- new follow target / face target
				if (targetObj:IsInLineOfSight()) and (not IsMoving()) and (targetObj:GetHealthPercentage() < 99) then
					if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
						if (not targetObj:FaceTarget()) then
							targetObj:FaceTarget();
							self.waitTimer = GetTimeEX() + 0;
						end
					end
				end
				
				-- cast fireball
				if (localMana > 15) and (not IsMoving()) and (targetObj:IsInLineOfSight()) then
					if (CastSpellByName("Fireball", targetObj)) then
						self.waitTimer = GetTimeEX() + 1600;
						return 0;
					end
				end

				-- recheck line of sight
				if (not targetObj:IsInLineOfSight()) then
					return 3;
				end
			end

		if (not HasSpell("Frost Bolt")) and (self.frostMage) and (localMana > 15) then
			CastSpellByName("Fireball");
			return 0;
		end
			
		-- Combat

		else	

			-- display message in ogasai message box
			self.message = "Killing " .. targetObj:GetUnitName() .. "...";
			
			-- Dismount
			if (IsMounted()) then
				DisMount();
			end

			-- new follow target / face target
			if (targetObj:IsInLineOfSight()) and (not IsMoving()) and (targetHealth < 99) then
				if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
					if (not targetObj:FaceTarget()) then
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 0;
					end
				end
			end

			-- blink on movement stop debuffs
			if (self.useBlink) then
				if (HasSpell("Blink")) and (not IsSpellOnCD("Blink")) then
					if (localObj:HasDebuff("Web")) or (localObj:HasDebuff("Encasing Webs")) then
						if (CastSpellByName("Blink")) then
							targetObj:FaceTarget();
							self.waitTimer = GetTimeEX() + 500;
							return 0;
						end
					end
				end
			end

			-- blink frost nova on CD
			if (self.useBlink) then
				if (HasSpell("Blink")) and (not IsSpellOnCD("Blink")) and (IsSpellOnCD("Frost Nova") or IsSpellOnCD("Cone of Cold")) and (targetObj:GetDistance() < 10) and (targetHealth > self.useWandHealth + 10) then
					if (not targetObj:HasDebuff("Frostbite")) and (not targetObj:HasDebuff("Frost Nova")) and (not targetObj:HasDebuff("Blast Wave")) and (targetHealth > 10) then
						if (CastSpellByName("Blink")) then
							targetObj:FaceTarget();
							self.waitTimer = GetTimeEX() + 500;
							return 0;
						end
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

			-- Run backwards if we are too close to the target
			if (targetObj:GetDistance() <= .5) then 
				if (script_mage:runBackwards(targetObj,5)) then 
					return 4; 
				end 
			end
			
			-- Check: Move backwards if the target is affected by Frost Nova or Frost Bite
			if (GetNumPartyMembers() < 1) or (self.useFrostNova) then
				if (targetHealth > 20) and (targetObj:HasDebuff("Frostbite") or targetObj:HasDebuff("Frost Nova")) and (not localObj:HasBuff('Evocation')) and 
					(targetObj ~= 0 and IsInCombat()) and (self.useFrostNova) and (not localObj:HasDebuff("Web")) and (not localObj:HasDebuff("Encasing Webs")) then
					if (script_mage:runBackwards(targetObj, 7)) then -- Moves if the target is closer than 7 yards
						self.message = "Moving away from target...";
						if (not IsSpellOnCD("Frost Nova")) then
							CastSpellByName("Frost Nova");
							return 0;
						end
					return 4; 
					end 
				end	
			end

			-- frost nova if target is running away
			if (HasSpell("Frost Nova")) and (not IsSpellOnCD("Frost Nova")) and (targetObj:IsFleeing()) and (targetHealth > 3) then
				if (localMana > 5) and (targetObj:GetDistance() < 10) and (not targetObj:HasDebuff("Frostbite")) then
					if (CastSpellByName("Frost Nova")) then
						return;
					end
				end
			end

			-- frost nova fireMage redundancy
			if (self.fireMage and self.useFrostNova) then
				if (HasSpell("Frost Nova")) and (not IsSpellOnCD("Frost Nova")) then
					if (localMana > 5) and (targetObj:GetDistance() < 10) and (not targetObj:HasDebuff("Frost Nova")) then
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
			if (localMana < self.evocationMana and localHealth > self.evocationHealth and HasSpell("Evocation") and not IsSpellOnCD("Evocation")) and (targetHealth > 20) then		
				self.message = "Using Evocation...";
				CastSpellByName("Evocation"); 
				return 0;
			end

			-- turtle wow server high elf racial spell
			-- Use Quel'dorei Meditation if we have low Mana but targetHealth > 20%
			if (HasSpell("Quel'Dorei Meditation")) and (not IsSpellOnCD("Quel'Dorei Meditation")) then
				if (localMana < self.QuelDoreiMeditationMana) and (targetHealth > 20) then		
					self.message = "Using Quel'dorei Meditation...";
					CastSpellByName("Quel'dorei Meditation"); 
					return 0;
				end
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
					self.waitTimer = GetTimeEX() + 1800;
					return 0;
				end
			end

			-- Check if add already polymorphed
			if (not script_mage:isAddPolymorphed() and not (self.polyTimer < GetTimeEX())) then
				self.addPolymorphed = false;
			end

			-- Check: Polymorph add
			if (targetObj ~= nil and self.polymorphAdds and script_grind:enemiesAttackingUs(5) > 1 and HasSpell('Polymorph') and not self.addPolymorphed and self.polyTimer < GetTimeEX()) then
				self.message = "Polymorphing add...";
				script_mage:polymorphAdd(targetObj:GetGUID());
			end 

			-- Check: Sort target selection if add is polymorphed
			if (self.addPolymorphed) then
				if(script_grind:enemiesAttackingUs(5) >= 1 and targetObj:HasDebuff('Polymorph')) then
					ClearTarget();
					targetObj = script_mage:getTargetNotPolymorphed();
					targetObj:AutoAttack();
				end
			end

			-- Check: Frostnova when the target is close, but not when we polymorhped one enemy or the target is affected by Frostbite
			if (not self.addPolymorphed) and (targetObj:GetDistance() < 5 and not targetObj:HasDebuff("Frostbite") and HasSpell("Frost Nova") and not IsSpellOnCD("Frost Nova")) and self.useFrostNova then
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
				if (not self.addPolymorphed) and (targetObj:GetDistance() < 10) and (not targetObj:HasDebuff("Frostbite")) and (not targetObj:HasDebuff("Frost Nova")) then
					if (script_mage:coneOfCold('Cone of Cold')) then
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 1500;
						return 0;
					end
				end
			end

			-- Fire blast
			if (self.useFireBlast) and (targetObj:GetDistance() < 20) and (HasSpell("Fire Blast")) and (not IsSpellOnCD("Fire Blast")) then
				if (localMana > 8) and (targetHealth >= self.useWandHealth) and (not IsSpellOnCD("Fire Blast")) then
					if (not targetObj:IsInLineOfSight()) then
						return 3;
					end	
					if (CastSpellByName("Fire Blast", targetObj)) then
						self.waitTimer = GetTimeEX() + 1800;
						return;
					end
				end
			end

			-- blast wave
			if (self.fireMage) and (HasSpell("Blast Wave")) then
				if (localMana > 30) and (targetObj:GetDistance() < 10) and (not IsSpellOnCD("Blast Wave")) and (targetHealth > 15 or localHealth < 20) then
					if (script_mage:runBackwards(targetObj, 9)) then -- Moves if the target is closer than 7 yards
						self.message = "Moving away from target...";
						if (not IsSpellOnCD("Blast Wave")) then
							CastSpellByName("Blast Wave");
							return 0;
						end
					return 4; 
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

			-- Wand if low mana or target is low
			if (self.useWand) and (localMana <= self.useWandMana or targetHealth <= self.useWandHealth) and (not IsChanneling()) and (not localObj:IsStunned()) then
				self.message = "Using wand...";
				if (not IsAutoCasting("Shoot")) then
					targetObj:FaceTarget();
					targetObj:CastSpell("Shoot");
					self.waitTimer = GetTimeEX() + 250; 
					return true;
				end
			end
			
			-- Main damage source if all above conditions cannot be run
			-- frost mage spells
			if (HasSpell("Frostbolt")) and (self.frostMage) and (not IsChanneling()) then
				if (localMana >= self.useWandMana and targetHealth >= self.useWandHealth - 5) then
				
					-- face target if in line of sight
					if (targetObj:IsInLineOfSight()) then
						targetObj:FaceTarget();
					end
			
					-- check range
					if(not targetObj:IsSpellInRange("Frostbolt")) then
						self.message = "Frostbolt Main Damage Source!";
						return 3;
					end
				
					-- check line of sight
					if (not targetObj:IsInLineOfSight()) then
						return 3;
					end	

					-- face target if in line of sight
					if (not targetObj:FaceTarget() and targetObj:IsInLineOfSight()) then
						targetObj:FaceTarget();
					end
				
					-- cast frostbolt
					if (CastSpellByName("Frostbolt", targetObj)) then
						return 0;
					end
			
					-- recheck line of sight
					if (not targetObj:IsInLineOfSight()) then
						return 3;
					end
				end	

				-- fire mage spells
			elseif (self.fireMage) and (not IsChanneling()) then

				-- use these spells if not using wand
				if (localMana >= self.useWandMana and targetHealth >= self.useWandHealth) then
				
					-- else if not has frostbolt then use fireball as range check
					if(not targetObj:IsSpellInRange("Fireball")) then
						return 3;
					end

					-- check line of sight
					if (not targetObj:IsInLineOfSight()) then
						return 3;
					end	

					-- face target
					if (not targetObj:FaceTarget() and targetObj:IsInLineOfSight()) then
						targetObj:FaceTarget();
					end

					-- cast pyroblast
					if (targetObj:GetDistance() > 30) and (targetObj:GetManaPercentage() > 1) and (targetHealth > 50) then
						if (HasSpell("Pyroblast")) then
							if (CastSpellByName("Pyroblast", targetObj)) then
								return 0;
							end
						end
				
					else
				
						-- cast fireball
						if (CastSpellByName("Fireball", targetObj)) then
							return 0;
						end
					end

					-- recheck line of sight
					if (not targetObj:IsInLineOfSight()) then
						return 3;
					end
				end	
			
				-- this is here to check for low level "frost Mage" not having frostbolt yet
			elseif (self.frostMage) and (not HasSpell("Frostbolt")) then				
		
				-- else if not has frostbolt then use fireball as range check
				if(not targetObj:IsSpellInRange("Fireball")) then
					return 3;
				end

				-- check line of sight
				if (not targetObj:IsInLineOfSight()) then
					return 3;
				end	

				-- face target
				if (not targetObj:FaceTarget() and targetObj:IsInLineOfSight()) then
					targetObj:FaceTarget();
				end
				
				-- cast fireball
				if (CastSpellByName("Fireball", targetObj)) then
					return 0;
				end

				-- recheck line of sight
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

	if (not script_grind.adjustTickRate) then
		if (not IsInCombat()) or (targetObj:GetDistance() > self.rangeDistance) then
			script_grind.tickRate = 100;
		elseif (IsInCombat()) then
			script_grind.tickRate = 500;
		end
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
	
	if (waterIndex == -1 and HasSpell('Conjure Water') and not IsEating() and not IsDrinking() and IsStanding()) then 
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

	--Create Food
	local foodIndex = -1;
	for i=0,self.numfood do
		if (HasItem(self.food[i])) then
			foodIndex = i;
			break;
		end
	end
	if (foodIndex == -1 and HasSpell('Conjure Food') and not IsEating() and not IsDrinking() and IsStanding()) then 
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

	-- Stop moving before we can rest
	if(localHealth < self.eatHealth or localMana < self.drinkMana) and (not IsSwimming()) then
		if (IsMoving()) then
			StopMoving();
			self.waitTimer = GetTimeEX() + 2000;
			return true;
		end
	end

	-- drink something
	if (not IsDrinking() and localMana <= self.drinkMana) and (not IsInCombat()) then
		self.waitTimer = GetTimeEX() + 2000;
		self.message = "Need to drink...";
		if (IsInCombat()) then
			return true;
		end
			
		if (IsMoving()) then
			StopMoving();
			return true;
		end

		if (script_helper:drinkWater()) then 
			self.message = "Drinking..."; 
			self.waitTimer = GetTimeEX() + 10000;
			return true;
		else 
			self.message = "No drinks! (or drink not included in script_helper)";
			return true; 
		end		
	end

	if (not IsEating() and localHealth < self.eatHealth) and (not IsSwimming() and not IsInCombat()) then
		self.waitTimer = GetTimeEX() + 2000;
		-- Dismount
		if(IsMounted()) then DisMount(); end
		self.message = "Need to eat...";	
		if (IsMoving()) then
			StopMoving();
			self.waitTimer = GetTimeEX() + 2000;
			return true;
		end
		
		self.waitTimer = GetTimeEX() + 2000;
		
		if (script_helper:eat()) then 
			self.message = "Eating..."; 
			return true; 
		else 
			self.message = "No food! (or food not included in script_helper)";
			return true; 
		end	
	end
	
	if (localMana < self.drinkMana or localHealth < self.eatHealth) and (not IsSwimming() and not IsInCombat()) and (script_grind.lootObj == nil) then
		self.waitTimer = GetTimeEX() + 2000;
		if (IsMoving()) then
			self.waitTimer = GetTimeEX() + 2000;
			StopMoving();
		end
		return true;
	end

	-- night elve stealth while resting
	if (IsDrinking() or IsEating()) and (HasSpell("Shadowmeld")) and (not IsSpellOnCD("Shadowmeld")) and (not localObj:HasBuff("Shadowmeld")) then
		if (CastSpellByName("Shadowmeld")) then
			return true;
		end
	end
	
	-- continue to rest if eating or drinking
	if (localMana < 98 and IsDrinking()) or (localHealth < 98 and IsEating()) and (not IsSwimming()) then
		self.message = "Resting to full hp/mana...";
		return;
	end

	-- stand up if sitting after drinking/eating -- used for buffs
	if (not IsStanding()) then
		JumpOrAscendStart();
	end
	
	-- arcane intellect
	if (HasSpell("Arcane Intellect")) and (not localObj:HasBuff("Arcane Intellect")) and (localMana > 25) then
		CastSpellByName("Arcane Intellect", localObj);
		self.waitTimer = GetTimeEX() + 1700;
		return true;
	end
	
	-- ice armor / frost armor
	if (HasSpell("Ice Armor")) and (not localObj:HasBuff("Ice Armor")) and (localMana > 20) then
		if (CastSpellByName("Ice Armor", localObj)) then
			self.waitTimer = GetTimeEX() + 1700;
			return true;
		end
	elseif (not HasSpell("Ice Armor")) and (HasSpell("Frost Armor")) and (not localObj:HasBuff("Frost Armor")) and (localMana > 20) then
		if (CastSpellByName("Frost Armor", localObj)) then
			self.waitTimer = GetTimeEX() + 1700;
			return true;
		end
	end

	-- dampen magic
	if (self.useDampenMagic) then
		if (HasSpell("Dampen Magic")) and (not localObj:HasBuff("Dampen Magic")) and (localMana > 15) then
			if (CastSpellByName("Dampen Magic", localObj)) then
				self.waitTimer = GetTimeEX() + 1700;
				return true;
			end
		end
	end

	-- combustion
	if (HasSpell("Combustion")) and (not IsSpellOnCD("Combustion")) and not (localObj:HasBuff("Combustion")) and (self.fireMage) then
		if (CastSpellByName("Combustion")) then
			self.waitTimer = GetTimeEX() + 1700;
			return true;
		end
	end

	-- frost ward
	if (self.useFrostWard) and (HasSpell("Frost Ward")) and (not localObj:HasBuff("Frost Ward")) then
		if (localMana > 50) and (not localObj:HasBuff("Fire Ward")) then
			if (CastSpellByName("Frost Ward", localObj)) then
				self.waitTimer = GetTimeEX() + 1700;
				return true;
			end
		end
	end
	
	-- fire ward
	if (self.useFireWard) and (HasSpell("Fire Ward")) and (not localObj:HasBuff("Fire Ward")) then
		if (localMana > 50) and (not localObj:HasBuff("Frost Ward")) then
			if (CastSpellByName("Fire Ward", localObj)) then
				self.waitTimer = GetTimeEX() + 1700;
				return true;
			end
		end
	end

	-- remove curse
	if (HasSpell("Remove Lesser Curse")) and (localMana > 10) then
		if (localObj:HasDebuff("Curse of the Shadowhorn")) then
			if (CastSpellByName("Remove Lesser Curse", localObj)) then
				self.waitTimer = GetTimeEX() + 1800;
				return;
			end
		end
	end

	-- No rest / buff needed
	return false;
end