script_warrior = {
	message = 'Warrior Combat Script',
	warriorMenu = include("scripts\\combat\\script_warriorEX.lua"),
	eatHealth = 55, -- health to use food
	bloodRageHealth = 50, -- health to use bloodrage
	potionHealth = 10, -- health to use potion
	isSetup = false, -- setup check
	meleeDistance = 3.5, -- melee distance
	throwOpener = false, -- use throw as opener
	throwName = "Heavy Throwing Dagger", -- opener throw item name
	waitTimer = 0, -- set wait time for script
	stopIfMHBroken = true, -- stop if main hand is broken
	overpowerActionBarSlot = 72+6, -- Default: Overpower in slot 5 on the default Battle Stance Bar
	revengeActionBarSlot = 82+8,  -- default at action bar 1 (82) slot 8 (82+8)
	enableRotation = false, -- enable/disable rotation settings
	enableGrind = true, -- enable/disable grind settings
	enableCharge = false, -- enable/disable charge
	defensiveStance = false, -- enable/disable defensive stance settings
	battleStance = false, -- enable/disable battle stance settings
	berserkerStance = false, -- enable/disable berskerer stance settings
	autoStance = false, -- auto stance changed -- not in use
	sunderStacks = 2, -- how many stacks of sunder armor
	enableFaceTarget = true, -- enable/disable auto facing target
	enableShieldBlock = true, -- enable/disable shield block
	shieldBlockRage = 10,  -- use shield block at this rage
	shieldBlockHealth = 90, -- use shield block at this health
	sunderArmorRage = 15,	-- use sunder armor at this rage
	enableRend = false, -- enable/disable rend
	enableCleave = false, -- enable/disable cleave
	demoShoutRage = 15, -- set higher than sunder armor due to needed threat gain -- rage to use demo shout
	enableSunder = true, -- enable/disable sunder armor in battle stance
	challengingShoutAdds = 5, -- how many adds to use challenging shout. depends on dungeon/raid
	mockingBlowActionBarSlot = 72+4,
	useMockingBlow = true,
	followTargetDistance = 100,

	-- note. the checkbox in the menu controls battle, defensive, berserker stance. all spells have arguments for which
	-- stance they apply to and can be used in. if the palyer does not click defensive stance in-game then the bot
	--will assume you are not using defensive stance. 

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
	
	if (GetLocalPlayer():GetLevel() < 10) then
		self.battleStance = true;
	end

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
					if (self.faceTarget) then
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

function script_warrior:equipThrow() -- use throwing weapon function
	if (not GetLocalPlayer():HasRangedWeapon() and HasItem(self.throwName)) then
		UseItem(self.throwName);
		return true;
	elseif (GetLocalPlayer():HasRangedWeapon()) then
		return true;
	end
	return false;
end

function script_warrior:canOverpower()	-- use overpower function
	local isUsable, _ = IsUsableAction(self.overpowerActionBarSlot); 
	if (isUsable == 1 and not IsSpellOnCD('Overpower')) then 
		return true; 
	end 
	return false;
end

function script_warrior:canRevenge()	-- use revenge function
	local isUsable, _ = IsUsableAction(self.revengeActionBarSlot); 
	if (isUsable == 1 and not IsSpellOnCD("Revenge")) then 
		self.waitTimer = GetTimeEX() + 500;
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

function script_warrior:draw()	-- draw warrior window and status text
	local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
	if (onScreen) then
		DrawText(self.message, tX+75, tY+40, 0, 255, 255);
	else
		DrawText(self.message, 25, 185, 0, 255, 255);
	end
	--script_warrior:window();
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
	
	if(not self.isSetup) then	-- check setup stuff
		script_warrior:setup();
	end
	
	local localObj = GetLocalPlayer();
	local localRage = localObj:GetRagePercentage();
	local localHealth = localObj:GetHealthPercentage();
	local localLevel = localObj:GetLevel();

	if (localObj:IsDead()) then
		return 0; 
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

	-- Check: Do nothing if we are channeling or casting or wait timer
	if (IsChanneling()) or (IsCasting()) or (self.waitTimer >= GetTimeEX()) then
		return 4;
	end
	
	--Valid Enemy
	if (targetObj ~= 0) then
		
		-- Cant Attack dead targets
		if (targetObj:IsDead()) or (not targetObj:CanAttack()) then
			return 0;
		end

		if (not IsStanding()) then
			JumpOrAscendStart();
		end

	--	if (targetObj:IsInLineOfSight() and not IsMoving() and self.faceTarget) then
	--		if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
	--			if (not targetObj:FaceTarget()) then
	--				targetObj:FaceTarget();
	--				self.waitTimer = GetTimeEX() + 0;
	--			end
	--		end
	--	end
		
		-- Auto Attack
		if (targetObj:GetDistance() <= 40) then
			targetObj:AutoAttack();
		end
	
		targetHealth = targetObj:GetHealthPercentage();

		-- Check: if we target player pets/totems
		if (GetTarget() ~= nil and targetObj ~= nil) then
			if (UnitPlayerControlled("target") and GetTarget() ~= localObj) then 
				script_grind:addTargetToBlacklist(targetObj:GetGUID());
				return 5; 
			end
		end 

		-- Use bloodrage in party as rage gain before combat
		if (GetNumPartyMembers() >= 1) and (self.defensiveStance) then
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
			
			-- Check: Open with throw weapon
			if (self.rangeOpener) then
				if (targetObj:GetDistance() >= 30 or not targetObj:IsInLineOfSight()) then
					return 3;
				else
					-- Dismount
					if (IsMounted()) then DisMount(); 
						return 0; 
					end
					-- cast throw
					if (Cast("Throw", targetObj)) then
						self.waitTimer = GetTimeEX() + 4000;
						return 0;
					end
				end
			end

			-- Charge in Defensive Stance
			if (self.enableCharge and self.defensiveStance) then
				if (HasSpell("Charge")) and (targetHealth >= 99 or (not script_grind:isTargetingMe(currentObj))) then
					if (not IsSpellOnCD("Charge")) then
						if (targetObj:GetDistance() >= 10 and targetObj:GetDistance() <= 28) and (not IsInCombat()) then
							if (CastSpellByName("Battle Stance")) then
								self.waitTimer = GetTimeEX() + 2000;
							end
							if (targetObj:GetDistance() >= 8) and (targetObj:GetDistance() <= 28) and (CastSpellByName("Charge")) then
								self.waitTimer = GetTimeEX() + 2800;
							end
						end
					end
				CastSpellByName("Defensive Stance");
				end
			end

			-- Check: Charge if possible in battle stance
			if (self.enableCharge and self.battleStance) then
				if (HasSpell("Charge")) and (not IsSpellOnCD("Charge")) and (targetObj:GetDistance() <= 25) 
					and (targetObj:GetDistance() >= 12) and (targetObj:IsInLineOfSight()) then
					targetObj:FaceTarget();
					-- Dismount
					if (IsMoving()) then
							StopMoving();
					end
					if (Cast("Charge", targetObj)) then 
						targetObj:AutoAttack();
						if (IsMoving()) then
							StopMoving();
						end
					return 0;
					end
				end
			end	

			--if (targetObj:IsInLineOfSight() and not IsMoving() and self.faceTarget) then
			--	if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
			--		if (not targetObj:FaceTarget()) then
			--			targetObj:FaceTarget();
			--			self.waitTimer = GetTimeEX() + 0;
			--		end
			--	end
			--end

			-- Check move into melee range
			if (targetObj:GetDistance() >= self.meleeDistance or not targetObj:IsInLineOfSight()) then
				return 3;
			end
		
			if (targetObj:GetDistance() <= self.meleeDistance) and (not targetObj:IsFleeing()) then
					targetObj:FaceTarget();
				if (IsMoving()) then
					StopMoving();
				end
			end

			-- Combat

		else	

			self.message = "Killing " .. targetObj:GetUnitName() .. "...";
			
			-- Dismount
			if (IsMounted()) then 
				DisMount();
			end

			-- if not in line of sight then force facing target
			if (targetObj:IsInLineOfSight() and not IsMoving() and self.faceTarget and targetHealth < 99) then
				if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
					if (not targetObj:FaceTarget()) then
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 0;
					end
				end
			end
	
			-- Run backwards if we are too close to the target
			if (targetObj:GetDistance() <= .5) then 
				if (script_warrior:runBackwards(targetObj,4)) then 
					return 4; 
				end 
			end

			-- Check if we are in melee range
			if (targetObj:GetDistance() >= self.meleeDistance or not targetObj:IsInLineOfSight()) then
				return 3;
			end

			if (targetObj:IsInLineOfSight() and not IsMoving() and self.faceTarget and targetHealth < 99) then
				if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
					if (not targetObj:FaceTarget()) then
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 0;
					end
				end
			end

			targetObj:AutoAttack();

			-- Check: Use Healing Potion 
			if (localHealth <= self.potionHealth) then 
				if (script_helper:useHealthPotion()) then 
					UseItem("Arena Grand Master");
					return 0; 
				end 
			end

			-- TEST DEFENSIVE STANCE RETALIATION
			--if (not IsSpellOnCD("Retaliation")) then -- need this first or it will always cast defensive stance
			--	if (self.defensiveStance) and (localHealth <= 75 and script_warrior:enemiesAttackingUs(10) >= 5) then
			--		if (HasSpell("Retaliation")) then
			--			if (CastSpellByName("Battle Stance")) then
			--				self.waitTimer = GetTimeEX() + 1800;
			--			end
			--			if (targetObj:GetDistance() >= 8) and (targetObj:GetDistance() <= 28) and (CastSpellByName("Retaliation")) then
			--				self.waitTimer = GetTimeEX() + 2700;
			--			end
			--		end
			--	CastSpellByName("Defensive Stance");
			--	end
			--end

			-- shield block
			-- main rage user use only if target has at least 1 sunder for threat gain
			if (self.defensiveStance) and (self.enableShieldBlock) then
				if (HasSpell("Shield Block")) and (not IsSpellOnCD("Shield Block")) and (localRage >= self.shieldBlockRage) and (localHealth <= self.shieldBlockHealth) then
					if (targetObj:GetDebuffStacks("Sunder Armor") >= 1) then
						if (CastSpellByName("Shield Block")) then
							return 0;
						end
					end
				end
			end

			-- Sunder if possible as main threat source! this is most logical and easiest solution for the bot to handle
			if (self.defensiveStance) then 
				if (HasSpell("Sunder Armor")) and (localRage >= self.sunderArmorRage) then
					if (not targetObj:GetCreatureType() ~= 'Mechanical') and (not targetObj:GetCreatureType() ~= 'Elemental') then
						if (targetObj:GetDebuffStacks("Sunder Armor") < self.sunderStacks) then
							if (Cast("Sunder Armor", targetObj)) then
								self.waitTimer = GetTimeEX() + 1750;
							return 0;
							end
						end
					end

					-- shield bash first
				elseif (targetObj:IsCasting()) and (HasSpell("Shield Bash")) and (not IsSpellOnCD("Shield Bash")) then
					if (localRage >= 10) and (targetHealth >= 10) then
						CastSpellByName("Shield Bash");
						self.waitTimer = GetTimeEX() + 700;
					end
				
					-- else get sunder out!
				elseif (localRage > self.sunderArmorRage) and (targetObj:GetDebuffStacks("Sunder Armor") < self.sunderStacks) then
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
					if (targetHealth <= 96 and targetHealth >= 10) and (targetObj:GetDebuffStacks("Sunder Armor") >= 1) then
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
						self.waitTimer = GetTimeEX() + 2500;
					end
				end
			end
			
			-- shield bash	first thing in combat!
			-- TODO add if has shield
			if (self.defensiveStance) then
				if (HasSpell("Shield Bash")) and (not IsSpellOnCD("Shield Bash")) and (localRage >= 10)
					and (targetObj:IsCasting()) and (targetHealth >= 20) then
					CastSpellByName("Shield Bash");
					self.waitTimer = GetTimeEX() + 700;
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
			if (HasSpell("Demoralizing Shout")) and (script_warrior:enemiesAttackingUs(10) >= 2) and (not targetObj:HasDebuff("Demoralizing Shout")) then
				if (localRage >= self.demoShoutRage) then 
					if CastSpellByName("Demoralizing Shout") then
						return 0;
					end
				end
			end

			-- shield block
			-- main rage user use only if target has at least 1 sunder for threat gain
			if (self.defensiveStance) and (self.enableShieldBlock) then
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
				if (script_warrior:canRevenge() and not IsSpellOnCD("Revenge")) and (localRage >= 10) then 
					CastSpellByName("Revenge"); 
					self.message = "Using Revenge!";
					self.waitTimer = GetTimeEX() + 2550;
				end  
			end
	
			-- War Stomp Tauren Racial
			if (HasSpell("War Stomp")) and (not IsSpellOnCD("War Stomp"))
				and (targetObj:IsCasting() or script_warrior:enemiesAttackingUs() >= 2)
				and (targetHealth >= 50) and (not IsMoving()) then
				CastSpellByName("War Stomp");
				self.waitTimer = GetTimeEX() + 200;
				return 0;
			end

			-- Stone Form Dwarf Racial
			if (HasSpell("Stone Form")) and (not IsSpellOnCD("Stone Form")) and (script_warrior:enemiesAttackingUs() >= 2) and (localHealth <= 60) then
				CastSpellByName("Stone Form");
				self.waitTimer = GetTimeEX() + 200;
				return 0;
			end

			-- Check: Thunder clap if 2 mobs or more
			if (self.battleStance) or (self.defensiveStance) then
				if (script_warrior:enemiesAttackingUs(5) >= 2 and HasSpell('Thunder Clap') 
					and not IsSpellOnCD('Thunder Clap') and not targetObj:HasDebuff('Thunder Clap')) then 
					if (localRage >= 20) then
						return 0;
					end
					CastSpellByName('Thunder Clap'); 
					self.waitTimer = GetTimeEX() + 550;
					return 0;
				end
			end

			-- Check: Use Retaliation if we have three or more mobs on us
			if (self.battleStance) then
				if (script_warrior:enemiesAttackingUs(10) >= 3 and HasSpell('Retaliation') and not IsSpellOnCD('Retaliation')) then 
					CastSpellByName('Retaliation');
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
					return 0;
				end
			end

			-- Check: Keep Battle Shout up
			if (not localObj:HasBuff("Battle Shout")) then 
				if (localRage >= 10 and HasSpell("Battle Shout")) then 
					CastSpellByName('Battle Shout'); 
					return 0; 
				end 
			end

			if (targetObj:IsInLineOfSight() and not IsMoving() and self.faceTarget and targetHealth < 99) then
				if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
					if (not targetObj:FaceTarget()) then
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 0;
					end
				end
			end

			-- Check: If we are in melee range, do melee attacks
			if (targetObj:GetDistance() <= self.meleeDistance) then

				-- shield block
				-- main rage user use only if target has at least 1 sunder for threat gain
				if (self.defensiveStance) and (self.enableShieldBlock) then
					if (HasSpell("Shield Block")) and (not IsSpellOnCD("Shield Block")) and (localRage >= self.shieldBlockRage) and (localHealth <= self.shieldBlockHealth) then
						if (CastSpellByName("Shield Block")) then
							return 0;
						end
					end
				end

				-- sunder armor in battle stance x1
				if (self.battleStance) then
					if (HasSpell("Sunder Armor")) and (localRage > 30) then
						if (targetHealth > 30) and (targetObj:GetDistance() < self.meleeDistance) then
							if (targetObj:GetDebuffStacks("Sunder Armor") < 1) then
								if (Cast("Sunder Armor", targetObj)) then
									self.waitTimer = GetTimeEX() + 1500;
									return 0;
								end
							end
						end
					end
				end

				-- melee Skill: Overpower if possible battle stance
				if (self.battleStance) then
					if (script_warrior:canOverpower() and localRage >= 5 and not IsSpellOnCD('Overpower')) then 
						CastSpellByName('Overpower'); 
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

				-- melee skill Execute the target if possible battle or berserker stance
				if (self.battleStance) or (self.berserkerStance) then
					if (targetHealth <= 20 and HasSpell('Execute')) then 
						if (Cast('Execute', targetObj)) then 
							return 0; 
						else 
							return 0; -- save rage for execute
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
					if (targetObj:GetCreatureType() == 'Humanoid' and localRage >= 10 and not targetObj:HasDebuff('Hamstring')) then 
						if (Cast('Hamstring', targetObj)) then
							return 0; 
						end 
					end 
				end

				-- melee Skill: Rend if we got more than 10 rage battle or bersker stance
				if (self.battleStance or self.defensiveStance) and (self.enableRend) then
					if (targetObj:GetCreatureType() ~= 'Mechanical' and targetObj:GetCreatureType() ~= 'Elemental' and HasSpell('Rend') and not targetObj:HasDebuff("Rend") 
						and targetHealth >= 30 and localRage >= 10) then 
						if (Cast('Rend', targetObj)) then 
							return 0; 
						end 
					end 
				end

				-- move heroic strike
				if (localObj:IsCasting()) and (targetObj:GetDistance() > 6) then
					script_nav:moveToTarget(localObj, targetObj);
				end
				if (not targetObj:FaceTarget()) then
					targetObj:FaceTarget();
				end

				-- melee Skill: Heroic Strike if we got 15 rage battle stance
				if (self.battleStance) then
					if (localRage >= 15) then 
						if (not targetObj:FaceTarget()) then
							targetObj:FaceTarget();
						end
						if (targetObj:GetDistance() <= 6) and (localRage >= 15) then
							CastSpellByName('Heroic Strike', targetObj);
							targetObj:FaceTarget();
							return 0;
						
						end
					end 
				end

				-- wait to heroic strike in defensive stance for sunder armor >= 1
				if (self.defensiveStance) then
					if (not targetObj:GetCreatureType() ~= 'Mechanical') and (not targetObj:GetCreatureType() ~= 'Elemental') then
						if (localRage >= 35) and (targetObj:GetDebuffStacks("Sunder Armor") >= self.sunderStacks) then 
							if (targetObj:GetDistance() <= 6) then
								if (Cast('Heroic Strike', targetObj)) then
									if (self.faceTarget) then
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
					if (localRage >= 50) then 
						if (targetObj:GetDistance() <= 6) then
							if (Cast('Heroic Strike', targetObj)) then
								if (self.faceTarget) then
									targetObj:FaceTarget();
									return 0;
								end
							end 
						end
					end 
				end

				-- Always face target
				if (self.enableFaceTarget) then
					if (targetHealth <= 99) then
						targetObj:FaceTarget();
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

	-- looting

	local lootObj = script_nav:getLootTarget(lootRadius);
	
	if (not AreBagsFull() and not script_grind.bagsFull and script_grind.lootObj ~= nil) then
		self.waitTimer = GetTimeEX() + 1800;
		script_grind:doLoot(localObj);
		script_grind:lootAndSkin();
		script_nav:resetNavigate();
		script_nav:resetNavPos();
		ClearTarget();
		return true;
	end

	-- Eat something
	if (not IsEating() and localHealth <= self.eatHealth) then
		self.waitTimer = GetTimeEX() + 2000;
		self.message = "Need to eat...";
		if (IsInCombat()) then
			return true;
		end
			
		if (IsMoving()) then
			StopMoving();
			return true;
		end

		if (script_helper:eat()) then 
			self.message = "Eating..."; 
			self.waitTimer = GetTimeEX() + 10000;
			return true;
		else 
			self.message = "No food! (or food not included in script_helper)";
			return true; 
		end		
	end
	-- night elve stealth while resting
	if (IsDrinking() or IsEating()) and (HasSpell("Shadowmeld")) and (not IsSpellOnCD("Shadowmeld")) and (not localObj:HasBuff("Shadowmeld")) then
		if (CastSpellByName("Shadowmeld")) then
			return 0;
		end
	end

	-- Continue eating until we are full
	if(localHealth <= 98 and IsEating()) then
		self.message = "Resting up to full health...";
		return true;
	end
		
	-- Stand upp if we are rested
	if (localHealth >= 98 and (IsEating() or not IsStanding())) then
		StopMoving();
		return false;
	end
	
	-- Don't need to eat
	return false;
end