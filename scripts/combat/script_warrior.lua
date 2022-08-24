script_warrior = {
	message = 'Warrior Combat Script',
	eatHealth = 64,
	bloodRageHealth = 60,
	potionHealth = 10,
	isSetup = false,
	meeleDistance = 4.2,
	throwOpener = false,
	throwName = "Heavy Throwing Dagger",
	waitTimer = 0,
	stopIfMHBroken = true,
	overpowerActionBarSlot = 72+5, -- Default: Overpower in slot 5 on the default Battle Stance Bar
	revengeActionBarSlot = 82+8,  -- default at action bar 1 (82) slot 8 (82+8)
	enableRotation = false,
	enableGrind = true,
	enableCharge = true,
	chargeWalk = false,
	defensiveStance = false,
	battleStance = true,
	berserkerStance = false,
	autoStance = false,
	sunderStacks = 2,
	enableFaceTarget = true,
	enableShieldBlock = true,
	shieldBlockRage = 10,
	shieldBlockHealth = 65,
	sunderArmorRage = 15,
	enableRend = false,
	enableCleave = false,


}

function script_warrior:window()
	--Close existing Window
	EndWindow();

	if(NewWindow("Class Combat Options", 200, 200)) then
		script_warrior:menu();
	end
end

function script_warrior:setup()
	-- no more bugs first time we run the bot
	self.waitTimer = GetTimeEX(); 
	self.isSetup = true;
end

function script_warrior:spellAttack(spellName, target)
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

function script_warrior:addPotion(name)
	self.potion[self.numPotion] = name;
	self.numPotion = self.numPotion + 1;
end

function script_warrior:equipThrow()
	if (not GetLocalPlayer():HasRangedWeapon() and HasItem(self.throwName)) then
		UseItem(self.throwName);
		return true;
	elseif (GetLocalPlayer():HasRangedWeapon()) then
		return true;
	end
	return false;
end

function script_warrior:canOverpower()
	local isUsable, _ = IsUsableAction(self.overpowerActionBarSlot); 
	if (isUsable == 1 and not IsSpellOnCD('Overpower')) then 
		return true; 
	end 
	return false;
end

function script_warrior:canRevenge()
	local isUsable, _ = IsUsableAction(self.revengeActionBarSlot); 
	if (isUsable == 1 and not IsSpellOnCD('Revenge')) then 
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

function script_warrior:draw()
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

function script_warrior:run(targetGUID)

	-- let's use this for defensive stance setup?
	if (GetNumPartyMembers() >= 3) and (self.defensiveStance) then
		self.eatHealth = 7;
		self.enableCharge = false;
	end
	
	if(not self.isSetup) then
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
	
	if (self.stopIfMHBroken and isMainHandBroken) then
		self.message = "The main hand weapon is broken...";
		return 6;
	end

	-- Assign the target 
	targetObj =  GetGUIDObject(targetGUID);
	
	if(targetObj == 0 or targetObj == nil) then
		return 2;
	end

	-- Check: Do nothing if we are channeling or casting or wait timer
	if (IsChanneling() or IsCasting() or (self.waitTimer >= GetTimeEX())) then
		return 4;
	end
	
	--Valid Enemy
	if (targetObj ~= 0) then
		
		-- Cant Attack dead targets
		if (targetObj:IsDead() or not targetObj:CanAttack()) then
			return 0;
		end
		
		if (self.faceTarget) then
			if (not IsStanding()) then
				StopMoving();
			end
		end
		
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

		if (GetNumPartyMembers() >= 1) and (self.defensiveStance) then
			if (not localObj:HasBuff("Battle Shout")) then 
				if (localRage >= 10 and HasSpell("Battle Shout")) then 
					CastSpellByName('Battle Shout'); 
					return 0; 
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
						if (targetObj:GetDistance() >= 10) and (not IsInCombat()) then
							if (CastSpellByName("Battle Stance")) then
								self.waitTimer = GetTimeEX() + 1700;
							end
							if (targetObj:GetDistance() >= 8) and (targetObj:GetDistance() <= 28) and (CastSpellByName("Charge")) then
								self.waitTimer = GetTimeEX() + 2700;
							end
						end
					end
				CastSpellByName("Defensive Stance");
				end
			end

			-- Check: Charge if possible
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
						if (self.chargeWalk) then
							self.waitTimer = GetTimeEX() + 2700;
							return 0;
						end
						return 0;
					end
				end
			end	

			-- Check move into meele range
			if (targetObj:GetDistance() >= self.meeleDistance or not targetObj:IsInLineOfSight()) then
				return 3;
			end

			-- Combat
		else	
			self.message = "Killing " .. targetObj:GetUnitName() .. "...";
			-- Dismount
			if (IsMounted()) then 
				DisMount();
			end

			-- Run backwards if we are too close to the target
			if (targetObj:GetDistance() <= .2) then 
				if (script_warrior:runBackwards(targetObj,2)) then 
					return 4; 
				end 
			end

			-- Check if we are in meele range
			if (targetObj:GetDistance() >= self.meeleDistance or not targetObj:IsInLineOfSight()) then
				return 3;
			else
				if (IsMoving()) and (self.faceTarget) then
					StopMoving();
				end
			end

			if (self.enableFaceTarget) then
				targetObj:FaceTarget();
			end

			targetObj:AutoAttack();

			-- Check: Use Healing Potion 
			if (localHealth <= self.potionHealth) then 
				if (script_helper:useHealthPotion()) then 
					return 0; 
				end 
			end

			-- TEST DEFENSIVE STANCE RETALIATION
			if (not IsSpellOnCD("Retaliation")) then -- need this first or it will always cast defensive stance
				if (self.defensiveStance) and (localHealth <= 75 and script_warrior:enemiesAttackingUs(10) >= 5) then
					if (HasSpell("Retaliation")) then
						if (CastSpellByName("Battle Stance")) then
							self.waitTimer = GetTimeEX() + 1800;
						end
						if (targetObj:GetDistance() >= 8) and (targetObj:GetDistance() <= 28) and (CastSpellByName("Retaliation")) then
							self.waitTimer = GetTimeEX() + 2700;
						end
					end
				CastSpellByName("Defensive Stance");
				end
			end

			-- Sunder if possible as main threat source! this is most logical and easiest solution for the bot to handle
			if (self.defensiveStance) then 
				if (HasSpell("Sunder Armor")) and (localRage >= 15) then
					if (not targetObj:GetCreatureType() ~= 'Mechanical') and (not targetObj:GetCreatureType() ~= 'Elemental') then
						if (targetObj:GetDebuffStacks("Sunder Armor") <= 1) then
							if (Cast('Sunder Armor', targetObj)) then
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
					return 0;
					end
				end
			end

			-- TAUNT !
			if (HasSpell("Taunt")) and (not IsSpellOnCD("Taunt")) and (not targetObj:IsStunned()) then
				if (targetHealth <= 96 and targetHealth >= 8) and (targetObj:GetDebuffStacks("Sunder Armor") >= 1) 
					and (not script_warrior:canRevenge()) then
					if (not targetObj:IsTargetingMe()) and (localObj:GetDistance() <= 10) then
						if (CastSpellByName("Taunt")) then
							targetObj:FaceTarget();
							return 0;
						end
					end
					-- use taunt
				elseif (targetHealth <= 60 and targetHealth >= 8) and (not targetObj:IsTargetingMe()) and (not targetObj:IsStunned()) then
					if (CastSpellByName("Taunt")) then
						targetObj:FaceTarget();
						return 0;
					end
				end
			end 

			--Taunt last resort all else is on CD or no rage
			if (HasSpell("Taunt")) and (not IsSpellOnCD("Taunt")) and (not targetObj:IsStunned()) then
				if (targetHealth <= 99 and targetHealth >= 8) and (not IsSpellOnCD("Revenge")) and (localRage <= 15) then
					if (not targetObj:IsTargetingMe()) and (localObj:GetDistance() <= 10) then
						if (CastSpellByName("Taunt")) then
							targetObj:FaceTarget();
							return 0;
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
			
					-- waste rage on Revenge whenever possible
				elseif (script_warrior:canRevenge()) and (localRage >= 5) and (not IsSpellOnCD("Revenge")) then
						CastSpellByName("Revenge"); 
						self.message = "Using Revenge!";
				end  
			end
			
			-- shield bash						first thing in combat!
			-- TODO add if has shield
			if (self.defensiveStance) then
				if (HasSpell("Shield Bash")) and (not IsSpellOnCD("Shield Bash")) and (localRage >= 10)
					and (targetObj:IsCasting()) and (targetHealth >= 20) then
					CastSpellByName("Shield Bash");
					self.waitTimer = GetTimeEX() + 700;
					return 0;
				end
			end

			-- Disarm below selfHP and plent of rage to waste
			if (HasSpell("Disarm")) and (localHealth <= 51) and (targetHealth >= 41) and (localRage >= 50) then
				if (targetObj:GetDebuffStacks("Sunder Armor") >= 1) and (not IsSpellOnCD("Disarm")) then
					if (CastSpellByName("Disarm")) then
						return 0;
					end
				end
			end

			--Demoralizing shout if targets >= 1
			if (HasSpell("Demoralizing Shout")) and (script_warrior:enemiesAttackingUs(10) >= 2) then
				if (localRage >= 10) and (not localObj:HasBuff("Demoralizing Shout")) then 
					if CastSpellByName("Demoralizing Shout") then
						return 0;
					end
				return 0;
				end
			end

			-- sunder armor defensive stance
			if (self.defensiveStance) then
				if (not targetObj:GetCreatureType() ~= 'Mechanical') and (not targetObj:GetCreatureType() ~= 'Elemental') then
					if (HasSpell("Sunder Armor")) and (localRage >= 15) then
						if (targetObj:GetDebuffStacks("Sunder Armor") <= self.sunderStacks) then
							if (Cast('Sunder Armor', targetObj)) then
								self.waitTimer = GetTimeEX() + 1750;
							end
						return 0;
						end
					end
				end
			end

			-- Use Revenge as main threat gain when we can 
			-- check # 2
			if (self.defensiveStance) then
				if (script_warrior:canRevenge()) and (localRage >= 5) and (not IsSpellOnCD('Revenge')) then 
					CastSpellByName('Revenge'); 
					self.message = "Using Revenge!";
				end  
			end
	
			-- War Stomp Tauren
			if (HasSpell("War Stomp")) and (not IsSpellOnCD("War Stomp"))
				and (targetObj:IsCasting() or script_warrior:enemiesAttackingUs(5) >= 2)
				and (targetHealth >= 50) and (not IsMoving()) then
				CastSpellByName("War Stomp");
				self.waitTimer = GetTimeEX() + 200;
				return 0;
			end

			-- Check: Thunder clap if 2 mobs or more
			if (self.battleStance) or (self.defensiveStance) then
				if (script_warrior:enemiesAttackingUs(5) >= 2 and HasSpell('Thunder Clap') 
					and not IsSpellOnCD('Thunder Clap') and not targetObj:HasDebuff('Thunder Clap')) then 
					if (localRage <= 20) then
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

			-- Check: Use Bloodrage when we have more than 70% HP
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

			-- Always face target
			if (self.enableFaceTarget) then
				if (targetHealth <= 99) then
					targetObj:FaceTarget();
				end
			end

			-- Check: If we are in meele range, do meele attacks
			if (targetObj:GetDistance() <= self.meeleDistance) then

				-- shield block
				-- main rage user use only if target has at least 1 sunder for threat gain
				if (self.defensiveStance) and (self.enableShieldBlock) then
					if (HasSpell("Shield Block")) and (not IsSpellOnCD("Shield Block")) and (localRage >= self.shieldBlockRage) then
						if (targetObj:GetDebuffStacks("Sunder Armor") >= 1) or (localHealth <= self.shieldBlockHealth) then
							if (localHealth <= 85) and (IsInCombat()) then
								if (CastSpellByName("Shield Block")) then
									return 0;
								end
							end
						end
					end
				end

				-- Meele Skill: Overpower if possible battle stance
				if (self.battleStance) then
					if (script_warrior:canOverpower() and localRage >= 5 and not IsSpellOnCD('Overpower')) then 
						CastSpellByName('Overpower'); 
					end  
				end

				-- Meele skill Execute the target if possible battle or berserker stance
				if (self.battleStance) or (self.berserkerStance) then
					if (targetHealth <= 20 and HasSpell('Execute')) then 
						if (Cast('Execute', targetObj)) then 
							return 0; 
						else 
							return 0; -- save rage for execute
						end 
					end
				end

				-- Meele skill: Bloodthirst, save rage for this attack
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

				-- Meele Skill: Rend if we got more than 10 rage battle or bersker stance
				if (self.battleStance) or (self.defensiveStance and self.enableRend) then
					if (targetObj:GetCreatureType() ~= 'Mechanical' and targetObj:GetCreatureType() ~= 'Elemental' and HasSpell('Rend') and not targetObj:HasDebuff("Rend") 
						and targetHealth >= 30 and localRage >= 10) then 
						if (Cast('Rend', targetObj)) then 
							return; 
						end 
					end 
				end

				-- Meele Skill: Heroic Strike if we got 15 rage battle stance
				if (self.battleStance) then
					if (localRage >= 15) then 
						if (targetObj:GetDistance() <= 6) then
							if (Cast('Heroic Strike', targetObj)) then
								if (self.faceTarget) then
									targetObj:FaceTarget();
								end
								self.waitTimer = GetTimeEX() + 500;
								return 0;
							end 
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

	-- Eat something
	if (not IsEating() and localHealth <= self.eatHealth) then
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
			return true; 
		else 
			self.message = "No food! (or food not included in script_helper)";
			return true; 
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

function script_warrior:menu()
SameLine();
	if (not self.enableRotation) then -- if not showing rotation button
		wasClicked, self.enableGrind = Checkbox("Grinder", self.enableGrind); -- then show grind button
	end
		SameLine();
	if (not self.enableGrind) then -- if not showing grind button
		wasClicked, self.enableRotation = Checkbox("Rotation TODO", self.enableRotation); -- then show rotation button
		SameLine();
	end	
	Separator();
	if (self.enableGrind) then -- grind option menu
		Separator();
		if (CollapsingHeader("Choose Stance - Experimental")) then -- stance menu
			Text("Choose Stance - Experimental");
			if (not self.defensiveStance) and (not self.berserkerStance) then
				wasClicked, self.battleStance = Checkbox("Battle (DPS)", self.battleStance);
				SameLine();
			end
			if (not self.battleStance) and (not self.berserkerStance) then
				wasClicked, self.defensiveStance = Checkbox("Defensive (Tank)", self.defensiveStance);
				SameLine();
			end
			if (not self.battleStance) and (not self.defensiveStance) then
				wasClicked, self.berserkerStance = Checkbox("Berserker (DPS)", self.berserkerStance);
				SameLine();
			end
			Separator();
			if (self.battleStance) then -- batle stance menu
				if (CollapsingHeader("Battle Stance Options")) then
					Text("TODO!");
					Text("Overpower action bar slot");
					self.overpowerActionBarSlot = InputText("OPS", self.overpowerActionBarSlot);
					Text('72 is your action bar number.. slot 1 would be 73');
				end
			end
			if (self.defensiveStance) then -- defensive stance menu
				if (CollapsingHeader("Defensive Stance Options")) then
					wasClicked, self.enableFaceTarget = Checkbox("FaceTarget On/Off", self.enableFaceTarget);
						SameLine();
						wasClicked, self.enableShieldBlock = Checkbox("Shield Block On/Off", self.enableShieldBlock);
					if (self.enableShieldBlock) then
						self.shieldBlockHealth = SliderInt("Below % health", 10, 85, self.shieldBlockHealth);
						self.shieldBlockRage = SliderInt("Above % rage", 10, 50, self.shieldBlockRage);
					end
						Separator();
						Text("How many Sunder Armor Stacks?");
						self.sunderStacks = SliderInt("Sunder Stacks", 1, 5, self.sunderStacks);
						self.sunderArmorRage = SliderInt("Sunder rage cost", 10, 15, self.sunderArmorRage);
					if (CollapsingHeader("Revenge Skill Options")) then
						self.revengeActionBarSlot = InputText("RS", self.revengeActionBarSlot);
						Text("82 is spell bar number.. slot 1 would be 83");
					end
				end
			end
			if (self.berserkerStance) then -- berserker stance menu
				if (CollapsingHeader("Berserker Stance Options")) then
							Text("TODO!");	
				end
			end
		end
		if (CollapsingHeader("Warrior Grind Options")) then -- grind menu
			local wasClicked = false;
			wasClicked, self.enableCharge = Checkbox("Charge On/Off", self.enableCharge);
			SameLine();
			wasClicked, self.chargeWalk = Checkbox("Pull Back After Charge - Experimental", self.chargeWalk);
			Text('Eat below health percentage');
			self.eatHealth = SliderInt("EHP %", 1, 100, self.eatHealth);
			Text('Potion below health percentage');
			self.potionHealth = SliderInt("PHP %", 1, 99, self.potionHealth);
			Separator();
			wasClicked, self.stopIfMHBroken = Checkbox("Stop bot if main hand is broken.", self.stopIfMHBroken);
			Text("Use Bloodrage above health percentage");
			self.bloodRageHealth = SliderInt("BR%", 1, 99, self.bloodRageHealth);
			Text("Melee Range Distance");
			self.meeleDistance = SliderFloat("MR (yd)", 1, 8, self.meeleDistance);
			if (CollapsingHeader("Other Melee Skill Options")) then
				wasClicked, self.enableRend = Checkbox("Rend On/Off", self.enableRend);
				SameLine();
				wasClicked, self.enableCleave = Checkbox("Cleave On/Off TODO", self.enableCleave);
			end
			if (CollapsingHeader("Throwing Weapon Options")) then -- throwing weapon menu
				wasClicked, self.throwOpener = Checkbox("Pull with throw", self.throwOpener);
				Text("Throwing weapon");
				self.throwName = InputText("TW", self.throwName);
			end
		end
	end

	if (self.enableRotation) then -- rotation menu
		Separator();
		if (CollapsingHeader("Warrior Rotation Options")) then
		Text("Charge On/Off");
		Text("Turn off Face Target");
		Text("Rotation 2")
		end
	end
end