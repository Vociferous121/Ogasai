script_warrior = {
	message = 'Warrior Combat Script',
	warriorMenu = include("scripts\\combat\\script_warriorEX.lua"),
	eatHealth = 65, -- health to use food
	bloodRageHealth = 65, -- health to use bloodrage
	potionHealth = 6, -- health to use potion
	isSetup = false, -- setup check
	meleeDistance = 3.15, -- melee distance
	waitTimer = 0, -- set wait time for script
	stopIfMHBroken = true, -- stop if main hand is broken
	overpowerActionBarSlot = 73+6, -- Default: Overpower in slot 7 on the default Battle Stance Bar
	revengeActionBarSlot = 83+5,  -- default at action bar 1 (85) -- action bar 72 is battle stance - defense is 82. slot 1 is + 1
	enableGrind = true, -- enable/disable grind settings
	enableCharge = false, -- enable/disable charge
	defensiveStance = false, -- enable/disable defensive stance settings
	battleStance = true, -- enable/disable battle stance settings
	berserkerStance = false, -- enable/disable berskerer stance settings
	sunderStacks = 0, -- how many stacks of sunder armor
	enableFaceTarget = true, -- enable/disable auto facing target
	enableShieldBlock = true, -- enable/disable shield block
	shieldBlockRage = 10,  -- use shield block at this rage
	shieldBlockHealth = 90, -- use shield block at this health
	sunderArmorRage = 15,	-- use sunder armor at this rage
	enableRend = true, -- enable/disable rend
	enableCleave = false, -- enable/disable cleave
	demoShoutRage = 15, -- set higher than sunder armor due to needed threat gain -- rage to use demo shout
	enableSunder = true, -- enable/disable sunder armor in battle stance
	challengingShoutAdds = 5, -- how many adds to use challenging shout. depends on dungeon/raid
	mockingBlowActionBarSlot = 72+4,
	useMockingBlow = true,
	followTargetDistance = 36,
	useBandage = true,
	hasBandages = false,
	lastStandHealth = 8,
	useBow = false,

	-- note. the checkbox in the menu controls battle, defensive, berserker stance. all spells have arguments for which
	-- stance they apply to and can be used in. if the palyer does not click defensive stance in-game then the bot
	-- will assume you are not using defensive stance. 

}

function script_warrior:window()
	--Close existing Window
	EndWindow();
	--open class combat options window
	if(NewWindow("Class Combat Options", 200, 200)) then
		script_warriorEX:menu();
	end
end

function script_warrior:setup()
	-- no more bugs first time we run the bot

	self.waitTimer = GetTimeEX(); 
	self.isSetup = true;

	if (HasSpell("Charge")) then
		self.enableCharge = true;
	end

	if (HasSpell("Rend")) then
		self.enableRend = true;
	end

end

function script_warrior:spellAttack(spellName, target) -- used in Core files to control casting
	if (HasSpell(spellName)) then
		if (target:IsSpellInRange(spellName)) then
			if (not IsSpellOnCD(spellName)) then
				if (not IsAutoCasting(spellName)) then
					if (self.enableFaceTarget) then
						target:FaceTarget();
					end
				return target:CastSpell(spellName);
				end
			end
		end
	end
	return false;
end

function script_warrior:enemiesAttackingUs(range) -- returns number of enemies attacking us within range
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

function script_warrior:addPotion(name) -- add potions to script
	self.potion[self.numPotion] = name;
	self.numPotion = self.numPotion + 1;
end

function script_warrior:canOverpower()	-- use overpower function
	local isUsable, _ = IsUsableAction(self.overpowerActionBarSlot); 
	if (isUsable == 1 and not IsSpellOnCD("Overpower")) then 
		return true; 
	end 
	return false;
end

function script_warrior:canRevenge()	-- use revenge function
	local isUsable, _ = IsUsableAction(self.revengeActionBarSlot); 
	if (isUsable == 1 and not IsSpellOnCD("Revenge")) then 
		return true; 
	end 
	return false;
end

function script_warrior:canMockingBlow()	-- use Mocking Blow function
	local isUsable, _ = IsUsableAction(self.mockingBlowActionBarSlot); 
	if (isUsable == 1 and not IsSpellOnCD("Mocking Blow")) then 
		return true; 
	end 
	return false;
end

-- Run backwards if the target is within range
function script_warrior:runBackwards(targetObj, range) 
	local localObj = GetLocalPlayer();
 	if targetObj ~= 0 then
 		local xT, yT, zT = targetObj:GetPosition();
 		local xP, yP, zP = localObj:GetPosition();
 		local distance = targetObj:GetDistance();
 		local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
 		local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 		local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;		
 		local moveX, moveY, moveZ = xT + xUV*5, yT + yUV*5, zT + zUV;		
 		if (distance <= range) then 
 			Move(moveX, moveY, moveZ);
			self.waitTimer = GetTimeEX() + 750;
 			return true;
 		end
	end
	return false;
end

-- Run Forwards if the target is within range
function script_warrior:runForwards(targetObj, range) 
	local localObj = GetLocalPlayer();
 	if targetObj ~= 0 then
 		local xT, yT, zT = targetObj:GetPosition();
 		local xP, yP, zP = localObj:GetPosition();
 		local distance = targetObj:GetDistance();
 		local xV, yV, zV = xP + xT, yP + yT, zP + zT;	
 		local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 		local xUV, yUV, zUV = (4/vectorLength)*xV, (4/vectorLength)*yV, (1/vectorLength)*zV;		
 		local moveX, moveY, moveZ = xT + xUV-5, yT + yUV-5, zT + zUV;		
 		if (distance <= range) then 
 			Move(moveX, moveY, moveZ);
			self.waitTimer = GetTimeEX() + 750;
 			return true;
 		end
	end
	return false;
end

function script_warrior:draw()	-- draw warrior window and status text
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
			6 - stop bot request from combat script  ]]--

function script_warrior:run(targetGUID)	-- main content of script

	-- let's use this for defensive stance setup? currently just an override for settings for easier tank setup during reloads
	--if (GetNumPartyMembers() >= 3) and (self.defensiveStance) then
	--	self.eatHealth = 7;
	--	self.enableCharge = false;
	--end
	
	if (not self.isSetup) then	-- check setup stuff
		script_warrior:setup();
	end
	
	local localObj = GetLocalPlayer();
	local localRage = localObj:GetRagePercentage();
	local localHealth = localObj:GetHealthPercentage();
	local localLevel = localObj:GetLevel();

	if (localObj:IsDead()) then
		return 0; 
	end

	if (self.useBow) or (self.defensiveStance) then
		self.enableCharge = false;
	end

	-- Check: If Mainhand is broken stop bot
	isMainHandBroken = GetInventoryItemBroken("player", 16);
	
	if (self.stopIfMHBroken) and (isMainHandBroken) then
		self.message = "The main hand weapon is broken...";
		return 6;
	end

	-- Assign the target 
	targetObj =  GetGUIDObject(targetGUID);

	if(targetObj == 0 or targetObj == nil) then
		return 2;
	end

	if (IsInCombat()) and (IsChanneling() or IsCasting()) then
		targetObj:FaceTarget();
	end

	-- Check: Do nothing if we are channeling or casting or wait timer
	if (IsChanneling()) or (IsCasting()) or (self.waitTimer >= GetTimeEX()) then
		return 4;
	end

	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(300, 800);

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
	
	--Valid Enemy
	if (targetObj ~= 0) and (not localObj:IsStunned()) and (not localObj:IsMovementDisabed()) and (not localObj:HasDebuff("Disarm")) then
		

		if (IsInCombat()) and (script_grind.skipHardPull) and (GetNumPartyMembers() == 0) then
			if (script_checkAdds:checkAdds()) then
				script_om:FORCEOM();
				return;
			end
		end

		-- Cant Attack dead targets
		if (targetObj:IsDead()) or (not targetObj:CanAttack()) then
			self.waitTimer = GetTimeEX() + 2000;
			return 0;
		end

		if (not IsStanding()) then
			JumpOrAscendStart();
		end

		-- Don't attack if we should rest first
		if (localHealth < self.eatHealth and not script_grind:isTargetingMe(targetObj)
			and targetHealth > 99 and not targetObj:IsStunned() and script_grind.lootobj == nil) then
			self.message = "Need rest...";
			return 4;
		end

		if (self.useBow) and (not IsInCombat()) and (targetObj:GetDistance() <= 34) and (targetObj:GetDistance() >= 19) and (targetObj:IsInLineOfSight()) and (not IsChanneling()) and (not IsAutoCasting("Shoot Bow")) and (not IsSpellOnCD("Shoot Bow")) and (targetHealth > 99) then
				if (IsMoving()) then
					StopMoving();
				end
				if (not IsMoving()) then
					CastSpellByName("Shoot Bow");
					self.waitTimer = GetTimeEX() + 4000;
					script_grind:setWaitTimer(4000);
					return 4;
				end
		end
	
		targetHealth = targetObj:GetHealthPercentage();

		-- Check: if we target player pets/totems
		if (GetTarget() ~= 0) then
			if (GetTarget():GetGUID() ~= GetLocalPlayer():GetGUID()) then
				if (UnitPlayerControlled("target")) then 
					script_grind:addTargetToBlacklist(targetObj:GetGUID());
					return 5; 
				end
			end
		end 

		-- Use bloodrage in party as rage gain before combat
		if (GetNumPartyMembers() >= 1) and (self.defensiveStance) or (IsInCombat()) then
			if (not IsSpellOnCD('Bloodrage')) and (HasSpell('Bloodrage')) and (localHealth >= self.bloodRageHealth) 
				and (targetObj:GetDistance() <= 40) then
				CastSpellByName('Bloodrage'); 
				return 0;
			end
		end

		-- if party members >= 1 and in defensive stance then set battle shout
		if (GetNumPartyMembers() >= 1) and (self.defensiveStance) then
			if (not localObj:HasBuff("Battle Shout")) then 
				if (localRage >= 10 and HasSpell("Battle Shout")) then 
					CastSpellByName('Battle Shout'); 
				end 
			end
		end

		-- Opener
		if (not IsInCombat()) then
			self.targetObjGUID = targetObj:GetGUID();
			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";

		-- Auto Attack
		if (targetObj:GetDistance() < 40) and (targetObj:IsInLineOfSight()) and (not IsAutoCasting("Attack")) then
			targetObj:AutoAttack();
		end

		if (not IsInCombat()) and (not self.runOnce) and (targetObj:GetManaPercentage() < 1) then
			self.runOnce = true;
		end

			-- Check: Charge if possible in battle stance
			if (self.enableCharge and self.battleStance) then
				if (HasSpell("Charge")) and (not IsSpellOnCD("Charge")) and (targetObj:IsSpellInRange("Charge")) 
					and (targetObj:GetDistance() >= 12) and (targetObj:IsInLineOfSight()) then
					targetObj:FaceTarget();
					if (Cast("Charge", targetObj)) then 
						targetObj:AutoAttack();
						script_nav:resetNavPos();
						script_nav:resetPath();
						script_nav:resetNavigate();
					return 0;
					end
				end
			end	

			-- Check move into melee range
			if (targetObj:GetDistance() > self.meleeDistance or not targetObj:IsInLineOfSight()) then
				return 3;
			end

			if (targetObj:GetDistance() <= self.meleeDistance + 1) and (not targetObj:IsFleeing()) then
				if (IsMoving()) then
					StopMoving();
				end
			end



			-- Combat




		else	

			self.message = "Killing " .. targetObj:GetUnitName() .. "...";

			if (GetLocalPlayer():GetUnitsTarget() ~= 0) and (not IsAutoCasting("Attack")) and (targetObj:GetDistance() <= 8) and (not IsMoving()) then
				targetObj:AutoAttack();
				targetObj:FaceTarget();
			end

			-- Cant Attack dead targets
			if (targetObj:IsDead()) or (not targetObj:CanAttack()) then
				StopMoving();
				self.waitTimer = GetTimeEX() + 5000;
			return 0;
			end

			-- Check move into melee range
			if (targetObj:GetDistance() > self.meleeDistance or not targetObj:IsInLineOfSight()) then
				return 3;
			end
			
			-- Dismount
			if (IsMounted()) then 
				DisMount();
			end
	
			-- Run backwards if we are too close to the target
			if (targetObj:GetDistance() <= .4) then 
				if (script_warrior:runBackwards(targetObj,3)) then 
					return 4; 
				end 
			end
	
			if (not IsAutoCasting("Attack")) then
				targetObj:AutoAttack();
			end

			-- Execute the target if possible battle or berserker stance
			if (self.battleStance) or (self.berserkerStance) then
				if (targetHealth <= 18 and HasSpell('Execute')) and (localRage >= 15) then 
					if (Cast('Execute', targetObj)) then 
						return 0; 
					else 
						return 0; -- save rage for execute
					end 
				end
			end

			if (HasSpell("Concussion Blow")) and (not IsSpellOnCD("Concussion Blow")) then
				CastSpellByName("Concussion Blow");
				return 0;
			end

			-- Check: Use Healing Potion 
			if (localHealth <= self.potionHealth) then 
				if (script_helper:useHealthPotion()) then 
					UseItem("Arena Grand Master");
					return 0; 
				end 
			end

			-- check use last stand talent
			if (HasSpell("Last Stand")) and (not IsSpellOnCD("Last Stand")) and (localHealth <= self.lastStandHealth) and (IsInCombat()) and (targetHealth > 10) then
				CastSpellByName("Last Stand");
				self.waitTimer = GetTimeEX() + 1500;
				return 0;
			end

			if (IsChanneling() or IsCasting()) then
				targetObj:FaceTarget();
			end
			-- melee Skill: Heroic Strike if we got 15 rage battle stance
			if (self.battleStance) and (not IsMoving()) then
				if (localRage >= 15) and (targetHealth <= 80) then 
					targetObj:FaceTarget();
					if (targetObj:GetDistance() <= self.meleeDistance) then
						CastSpellByName('Heroic Strike', targetObj);
						targetObj:FaceTarget();
					end
				targetObj:FaceTarget();
				end 
				targetObj:FaceTarget();
			end
			if (IsChanneling() or IsCasting()) then
				targetObj:FaceTarget();
			end


			-- shield block
			-- main rage user use only if target has at least 1 sunder for threat gain
			if (self.defensiveStance) and (self.enableShieldBlock) and (targetObj:IsTargetingMe()) then
				if (HasSpell("Shield Block")) and (not IsSpellOnCD("Shield Block")) and (localRage >= self.shieldBlockRage) and (localHealth <= self.shieldBlockHealth) and (targetObj:HasDebuff("Sunder Armor")) then
					if (CastSpellByName("Shield Block")) then
						return 0;
					end
				end
			end

			-- Sunder if possible as main threat source! this is most logical and easiest solution for the bot to handle
			if (self.defensiveStance) or (self.battleStance) then 
				if (HasSpell("Sunder Armor")) and (localRage >= self.sunderArmorRage) then
					if (not targetObj:GetCreatureType() ~= 'Mechanical') and (not targetObj:GetCreatureType() ~= 'Elemental') then
						if (targetObj:GetDebuffStacks("Sunder Armor") < self.sunderStacks) then
							if (Cast("Sunder Armor", targetObj)) then
								self.waitTimer = GetTimeEX() + 1750;
							return 0;
							end
						end
					end

					-- shield bash
				elseif (self.defensiveStance) and (targetObj:IsCasting()) and (HasSpell("Shield Bash")) and (not IsSpellOnCD("Shield Bash")) then
					--if (localRage >= 10) and (targetHealth >= 10) and (self.defensiveStance) then
					--	CastSpellByName("Shield Bash");
					--	self.waitTimer = GetTimeEX() + 700;
					--end
				
					-- else get sunder out!
				elseif (localRage >= self.sunderArmorRage) and (targetObj:GetDebuffStacks("Sunder Armor") < self.sunderStacks) then
					if (not targetObj:GetCreatureType() ~= 'Mechanical') and (not targetObj:GetCreatureType() ~= 'Elemental') then
						self.waitTimer = GetTimeEX() + 500
					end
				end
			end

			-- Challenging shout
			if (HasSpell("Challenging Shout")) and (self.defensiveStance) then
				if (script_warrior:enemiesAttackingUs(10) > self.challengingShoutAdds) and (not IsSpellOnCD("Challenging Shout")) and (localRage >= 5) then
					if (CastSpellByName("Challenging Shout")) then
						self.waitTimer = GetTimeEX() + 1000;
						return 0;
					end
				end
			end

			-- TAUNT !
			if (self.defensiveStance) then
				if (HasSpell("Taunt")) and (not IsSpellOnCD("Taunt")) and (not targetObj:IsStunned()) then
					if (targetHealth <= 96 and targetHealth >= 10) then
						if (not targetObj:IsTargetingMe()) and (localObj:GetDistance() <= 10) then
							if (CastSpellByName("Taunt")) then
								targetObj:FaceTarget();
								return 0;
							end
						end
						-- use taunt
					elseif (targetHealth <= 60 and targetHealth >=10) and (not targetObj:IsTargetingMe()) and (not targetObj:IsStunned()) then
						if (CastSpellByName("Taunt")) then
							targetObj:FaceTarget();
							return 0;
						end
					end
				end 
			end

			--Taunt last resort all else is on CD or no rage
			if (self.defensiveStance) then
				if (HasSpell("Taunt")) and (not IsSpellOnCD("Taunt")) and (not targetObj:IsStunned()) then
					if (targetHealth <= 99) and (IsSpellOnCD("Revenge") or not script_warrior:canRevenge()) and (localRage <= 15) then
						if (not targetObj:IsTargetingMe()) and (localObj:GetDistance() <= 10) then
							if (CastSpellByName("Taunt")) then
								targetObj:FaceTarget();
								return 0;
							end
						end
					end
				end
			end
			
			-- revenge as taunt
			-- if taunt is on CD and no sunder armor and we can use revenge
			-- then use revenge if target is not attacking us
			if (self.defensiveStance) then   
				if (script_warrior:canRevenge()) and (localRage >= 5) then
					if (not targetObj:IsTargetingMe()) and (not IsSpellOnCD("Revenge")) then 
						CastSpellByName("Revenge"); 
						self.message = "Using Revenge!";
					end
				end
			end
			
			-- shield bash	first thing in combat!
			-- TODO add if has shield
			if (self.defensiveStance) then
				if (HasSpell("Shield Bash")) and (not IsSpellOnCD("Shield Bash")) and (localRage >= 10)
					and (targetObj:IsCasting()) and (targetHealth >= 20) then
					CastSpellByName("Shield Bash");
				end
			end

			-- taunt is on CD revenge is on CD, use sunder armor to gain aggro
			if (self.defensiveStance) and (not targetObj:IsTargetingMe()) and (HasSpell("Sunder Armor")) and (localRage >= self.sunderArmorRage) then
				if (HasSpell("Sunder Armor")) and (not IsSpellOnCD("Revenge") or not script_warrior:canRevenge()) then
					if (not targetObj:IsStunned()) and (localRage >= self.sunderArmorRage) then
						if (Cast("Sunder Armor", targetObj)) then
							return 0;
						end
					end
				end
			end
						

			-- Disarm below selfHP and plent of rage to waste
			if (self.defensiveStance) then
				if (HasSpell("Disarm")) and (localHealth <= 51) and (targetHealth >= 41) and (localRage >= 50) then
					if (targetObj:GetDebuffStacks("Sunder Armor") >= 1) and (not IsSpellOnCD("Disarm")) then
						if (CastSpellByName("Disarm")) then
							return 0;
						end
					end
				end
			end

			--Demoralizing shout if targets >= 1
			if (HasSpell("Demoralizing Shout")) and (script_warrior:enemiesAttackingUs(5) >= 2) and (not targetObj:HasDebuff("Demoralizing Shout")) and (localRage >= 10) then
				if (localRage >= self.demoShoutRage) then 
					if CastSpellByName("Demoralizing Shout") then
						return 0;
					end
				end
			end

			-- shield block
			-- main rage user use only if target has at least 1 sunder for threat gain
			if (self.defensiveStance) and (self.enableShieldBlock) and (targetObj:IsTargetingMe()) then
				if (HasSpell("Shield Block")) and (not IsSpellOnCD("Shield Block")) and (localRage >= self.shieldBlockRage) and (localHealth <= self.shieldBlockHealth) then
					if (targetObj:GetDebuffStacks("Sunder Armor") >= 1) then
						if (CastSpellByName("Shield Block")) then
							return 0;
						end
					end
				end
			end

			-- sunder armor defensive stance
			if (self.defensiveStance) then
				if (not targetObj:GetCreatureType() ~= 'Mechanical') and (not targetObj:GetCreatureType() ~= 'Elemental') then
					if (HasSpell("Sunder Armor")) and (localRage >= self.sunderArmorRage) then
						if (targetObj:GetDebuffStacks("Sunder Armor") < self.sunderStacks) then
							if (Cast("Sunder Armor", targetObj)) then
								return 0;
							end
						end
					end
				end
			end

			-- Use Revenge as main threat gain when we can 
			-- check # 2
			if (self.defensiveStance) then
				if (script_warrior:canRevenge() and not IsSpellOnCD("Revenge")) and (localRage >= 5) then 
					CastSpellByName("Revenge"); 
					self.message = "Using Revenge!";
				end  
			end
	
			-- War Stomp Tauren Racial
			if (HasSpell("War Stomp")) and (not IsSpellOnCD("War Stomp")) and (not IsMoving()) and (targetObj:GetDistance() <= 6) and (not targetObj:HasDebuff("Concussive Blow")) then
				if (targetObj:IsCasting()) or (script_warrior:enemiesAttackingUs(2)) or (targetObj:IsFleeing()) then
					CastSpellByName("War Stomp");
					self.waitTimer = GetTimeEX() + 200;
					return 0;
				end
			end

			-- Stone Form Dwarf Racial
			if (HasSpell("Stone Form")) and (not IsSpellOnCD("Stone Form")) and (script_warrior:enemiesAttackingUs() >= 2) and (localHealth <= 60) then
				CastSpellByName("Stone Form");
				self.waitTimer = GetTimeEX() + 200;
				return 0;
			end

			-- Check: Thunder clap if 2 mobs or more
			if (self.battleStance) then
				if (script_warrior:enemiesAttackingUs(5) >= 2 and HasSpell('Thunder Clap') and (localRage >= 20)
					and not IsSpellOnCD('Thunder Clap') and not targetObj:HasDebuff('Thunder Clap')) then 
					if (localRage >= 20) then
					CastSpellByName('Thunder Clap'); 
					self.waitTimer = GetTimeEX() + 550;
						return 0;
					end
				end
			end

			-- Check: Use Retaliation if we have three or more mobs on us
			if (self.battleStance) then
				if (script_warrior:enemiesAttackingUs(10) >= 3 and HasSpell('Retaliation') and not IsSpellOnCD('Retaliation')) then 
					CastSpellByName('Retaliation');
					return 0; 
				end
			end

			-- Check: Use Shield Wall if we have four or more mobs on us
			if (self.defensiveStance) then
				if (script_warrior:enemiesAttackingUs(10) >= 4 and HasSpell('Shield Wall') and not IsSpellOnCD('Shield Wall')) and (localHealth <=50) then 
					CastSpellByName('Shield Wall');
					return 0; 
				end
			end

			-- Check: Use Orc Racial Blood Fury
			if (not IsSpellOnCD('Blood Fury') and HasSpell('Blood Fury')) then 
				CastSpellByName('Blood Fury'); 
				return 0; 
			end 

			-- Check: Use Bloodrage when we have more than set HP
			if (GetNumPartyMembers() <= 1) then
				if (not IsSpellOnCD('Bloodrage') and HasSpell('Bloodrage') and localHealth >= self.bloodRageHealth) then 
					CastSpellByName('Bloodrage'); 
					return;
				end
			end

			-- Check: Keep Battle Shout up
			if (not localObj:HasBuff("Battle Shout")) then 
				if (localRage >= 10 and HasSpell("Battle Shout")) then 
					CastSpellByName('Battle Shout'); 
					return; 
				end 
			end

	-- Check: If we are in melee range, do melee attacks
			if (targetObj:GetDistance() <= self.meleeDistance) then
	
				if (targetObj:IsFleeing()) and (not script_grind.adjustTickRate) then
					script_grind.tickRate = 50;
				end

				if (not IsMoving()) then
					targetObj:FaceTarget();
				end
		
				if (localObj:IsCasting()) and (not IsAutoCasting("Attack")) then
					targetObj:AutoAttack();
				end

				-- Check move into melee range
				if (targetObj:GetDistance() > self.meleeDistance or not targetObj:IsInLineOfSight()) then
					return 3;
				end

				-- shield block
				-- main rage user use only if target has at least 1 sunder for threat gain
				if (self.defensiveStance) and (self.enableShieldBlock) and (targetObj:IsTargetingMe()) then
					if (HasSpell("Shield Block")) and (not IsSpellOnCD("Shield Block")) and (localRage >= self.shieldBlockRage) and (localHealth <= self.shieldBlockHealth) and (targetObj:HasDebuff("Sunder Armor")) then
						if (CastSpellByName("Shield Block")) then
							return 0;
						end
					end
				end

				-- sunder armor in battle stance
				if (self.battleStance) and (HasSpell("Sunder Armor")) and (localRage >= 15) then
					if (targetHealth >= 30) and (targetObj:GetDistance() <= self.meleeDistance) then
						if (targetObj:GetDebuffStacks("Sunder Armor") < self.sunderStacks) then
							if (Cast("Sunder Armor", targetObj)) then
								self.waitTimer = GetTimeEX() + 500;
								return 0;
							end
						end
					end
				end

				-- melee Skill: Overpower if possible battle stance
				if (self.battleStance) then
					if (script_warrior:canOverpower() and localRage >= 5 and not IsSpellOnCD('Overpower')) then 
						if (Cast("Overpower", targetObj)) then
							return;
						end
					end  
				end

				-- check Mocking Blow
				if (self.useMockingBlow) and (script_warrior:canMockingBlow()) and (self.battleStance) then
					if (localRage >= 10) and (not IsSpellOnCD("Mocking Blow")) then
						if (Cast("Mocking Blow", targetObj)) then
							return 0;
						end
					end
				end

				-- melee skill: Bloodthirst, save rage for this attack
				if (HasSpell("Bloodthirst") and not IsSpellOnCD("Bloodthirst")) then 
					if (localRage >= 25) then 
						if (Cast('Bloodthirst', targetObj)) then 
							return 0;
						end
					else 
						return 0; -- save rage for bloodthirst
					end 
				end  

				-- Humanoid use to flee, keep Hamstring up on them
				if (self.battleStance) or (self.berserkerStance) then
					if (targetObj:GetCreatureType() == 'Humanoid' and localRage >= 10 and not targetObj:HasDebuff('Hamstring')) and (targetHealth <= 45) then 
						if (Cast('Hamstring', targetObj)) then
							return 0; 
						end 
					end 
				end

				if (targetObj:GetDistance() <= 8) and (not IsMoving()) then
					targetObj:FaceTarget();
				end

				-- melee Skill: Rend if we got more than 10 rage battle or bersker stance
				if (self.battleStance) and (self.enableRend) then
					if (targetObj:GetCreatureType() ~= 'Mechanical' and targetObj:GetCreatureType() ~= 'Elemental' and HasSpell('Rend') and not targetObj:HasDebuff("Rend") 
						and targetHealth >= 30 and localRage >= 10) then 
						if (Cast('Rend', targetObj)) then 
							return 0; 
						end 
					end 
				end

				-- melee Skill: Heroic Strike if we got 15 rage battle stance
				if (self.battleStance) then
					if (localRage >= 15) then 
						targetObj:FaceTarget();
						if (targetObj:GetDistance() <= self.meleeDistance) then
							CastSpellByName('Heroic Strike', targetObj);
							targetObj:FaceTarget();
							return 0;
						end
					targetObj:FaceTarget();
					end 
				end

				-- wait to heroic strike in defensive stance for sunder armor >= 1
				if (self.defensiveStance) then
					if (not targetObj:GetCreatureType() ~= 'Mechanical') and (not targetObj:GetCreatureType() ~= 'Elemental') then
						if (localRage >= 45) and (targetObj:GetDebuffStacks("Sunder Armor") >= self.sunderStacks) then 
							if (targetObj:GetDistance() <= 6) then
								if (Cast('Heroic Strike', targetObj)) then
									if (self.enableFaceTarget) then
										targetObj:FaceTarget();
									end
								return 0;
								end 
							end
						end 
					end
				end

				-- heroic strike defensive stance a lot of rage - use it
				if (self.defensiveStance) then
					if (localRage >= 65) then 
						if (targetObj:GetDistance() <= 6) then
							if (Cast('Heroic Strike', targetObj)) then
								if (self.enableFaceTarget) then
									targetObj:FaceTarget();
									return 0;
								end
							end 
						end
					end 
				end
				
			end
			return 0; 
		end
	return 0;
	end
end

function script_warrior:rest()
	if(not self.isSetup) then
		script_warrior:setup();
	end

	local localObj = GetLocalPlayer();
	local localHealth = localObj:GetHealthPercentage();
	local localRage = localObj:GetRagePercentage();

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

	-- use battle shout if we have rage but need to rest and heal
	if (localHealth <= self.eatHealth) and (localRage >= 10) and (not IsEating()) and (IsStanding()) and (not IsInCombat()) and (not localObj:HasBuff("Battle Shout")) then
		CastSpellByName("Battle Shout");
		self.waitTimer = GetTimeEX() + 1900;
		return 0;
	end
	
	-- if has bandage then use bandages
	if (self.eatHealth >= 35) and (self.hasBandages) and (self.useBandage) and (not IsMoving()) and (localHealth >= 35) then
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

	-- eat if not bandages
	if (not IsEating() and localHealth <= self.eatHealth) and (not IsInCombat()) and (not IsMoving()) and (script_grind.lootObj == nil) then
		self.message = "Need to eat...";	
		if (IsMoving()) then
			StopMoving();
			return true;
		end
		if (localHealth <= self.eatHealth) then
			self.waitTimer = GetTimeEX() + 2600;
		
			if (script_helper:eat()) and (not IsMoving()) then 
				self.message = "Eating..."; 
				self.waitTimer = GetTimeEX() + 2000;
				return true; 
			else 
				self.message = "No food! (or food not included in script_helper)";
				return true; 
			end
		end	
	end
	
	if (localHealth < self.eatHealth) then
		if (IsMoving()) then
			StopMoving();
		end
		return true;
	end

	-- night elve stealth while resting
	if (IsEating()) and (HasSpell("Shadowmeld")) and (not IsSpellOnCD("Shadowmeld")) and (not localObj:HasBuff("Shadowmeld")) then
		if (CastSpellByName("Shadowmeld")) then
			return 0;
		end
	end

	if (localHealth < 95 and IsEating()) then
		self.message = "Resting to full hp/mana...";
		return true;
	end

	if (not IsEating()) then
		if (not IsStanding()) then
			JumpOrAscendStart();
		end
	end
	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(300, 850);

		if (IsMoving()) or (not IsInCombat()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom
		elseif (IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		end
	end

	-- No rest / buff needed
	return false;
end