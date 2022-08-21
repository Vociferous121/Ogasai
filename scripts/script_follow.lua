script_follow = {

-- PRIEST
	renewMana = 10,				-- Use renew above this mana %
	partyRenewHealth = 90,		-- Use renew below party member health %
	shieldMana = 25,			-- Use shield above this mana %
	partyShieldHealth = 80,		-- Use shield below party member health %
	lesserHealMana = 5,			-- Use renew above this mana %
	partyLesserHealHealth = 80,	-- use renew below party member health %
	healMana = 50,				-- Use heal above this mana %
	partyHealHealth = 75,		-- Use heal below party member health %
	greaterHealMana = 20,		-- Use greater heal above this mana %
	partyGreaterHealHealth = 30,-- Use greater heal below party member health %
	useGroupLesserHeal = false, -- Use Lesser Heal on startup yes or no
	flashHealMana = 15,			-- Use Flash Heal above this mana %
	partyFlashHealHealth = 80,	-- Use Flash Heal abelow party member health%
	clickRenew = true,
	clickShield = true,
	clickFlashHeal = true,
	clickGreaterHeal = true,
	clickHeal = false,
	clickLesserHeal = false,

-- PALADIN
	holyLightMana = 25,
	partyHolyLightHealth = 25,
	flashOfLightMana = 3,
	partyFlashOfLightHealth = 83,
	layOnHandsHealth = 6,
	bopHealth = 10,
--

-- DRUID
	clickHealingTouch = true,
	clickRegrowth = true,
--
	useMount = false,
	disMountRange = 32,
	mountTimer = 0,
	enemyObj = nil,
	lootObj = nil,
	timer = GetTimeEX(),
	tickRate = 150,
	waitTimer = GetTimeEX(),
	pullDistance = 150,
	findLootDistance = 60,
	lootDistance = 2.5,
	skipLooting = true,
	lootCheck = {},
	ressDistance = 25,
	combatError = 0,
	myX = 0,
	myY = 0,
	myZ = 0,
	myTime = GetTimeEX(),
	message = 'Starting the follower...',
	navFunctionsLoaded = include("scripts\\script_nav.lua"),
	helperLoaded = include("scripts\\script_helper.lua"),
	extraFunctions = include("scripts\\script_followEX.lua"),
	unstuckLoaded = include("scripts\\script_unstuck.lua"),
	nextToNodeDist = 4, -- (Set to about half your nav smoothness)
	isSetup = false,
	drawUnits = true,
	acceptTimer = GetTimeEX(),
	followDistance = 36,
	followTimer = GetTimeEX(),
	dpsHp = 0,
	isChecked = true,
	pause = false,
	enableHeals = true,
}

function script_follow:window()
	if (self.isChecked) then EndWindow();
		if(NewWindow("Follower Options", 320, 360)) then script_followEX:menu(); end
	end
end


function script_follow:moveInLineOfSight(partyMember)
	if (not partyMember:IsInLineOfSight() or partyMember:GetDistance() > self.followDistance) then
		local x, y, z = partyMember:GetPosition();
		script_nav:moveToTarget(GetLocalPlayer(), x , y, z);
		self.timer = GetTimeEX() + 200;
		return true;
	end

	return false;
end

function script_follow:healAndBuff()
	local localMana = GetLocalPlayer():GetManaPercentage();
	if (not IsStanding()) then StopMoving();
	end
	-- Heals and buffs
	for i = 1, GetNumPartyMembers()+1 do
		local partyMember = GetPartyMember(i);
		if (i == GetNumPartyMembers()+1) then partyMember = GetLocalPlayer();
		end
		local partyMembersHP = partyMember:GetHealthPercentage();
		if (partyMembersHP > 0 and partyMembersHP < 99 and localMana > 1) then
	
			-- Move in range: combat script return 3
			if (self.combatError == 3) then
				self.message = "Moving to target...";
				script_follow:moveInLineOfSight(partyMember);		
				return;
			end

				-- Move in line of sight and in range of the party member
			if (script_follow:moveInLineOfSight(partyMember)) then 
				return true; 
			end

			        -- PALADIN BUFFS

			 if (not IsInCombat() and localMana > 40) then -- buff
				if (not partyMember:HasBuff("Blessing of Might") and (not partyMember:HasBuff("Blessing of Wisdom") and HasSpell("Blessing of Might"))) then		
				  if (script_follow:moveInLineOfSight(partyMember)) then return true;
				  end -- move to member
                    if (Cast("Blessing of Might", partyMember)) then
                        return true;
                    end
                end
            end
				-- PRIEST BUFFS

			 if (not IsInCombat() and localMana > 40) then -- buff
				if (not partyMember:HasBuff("Power Word: Fortitude") and HasSpell("Power Word: Fortitude") and not partyMember:HasBuff("Power Word: Fortitude")) then
					if (script_follow:moveInLineOfSight(partyMember)) then return true;
					end -- move to member
						if (Cast("Power Word: Fortitude", partyMember)) then
							return true;
						end
				end	
			 end

    
			 -- Divine Spirit
			if (not IsInCombat() and localMana > 40) then
				if (not partyMember:HasBuff("Divine Spirit") and HasSpell("Divine Spirit")) then
					if (script_follow:moveInLineOfSight(partyMember)) then return true;
				    end -- move to member
					   if (Cast("Divine Spirit", partyMember)) then
						return true;
					  end	
				end
			end

			if (self.enableHeals) then

					----- .
					----- PRIEST SPELLS
					-----	.

					-- Renew
					if (self.clickRenew) then
						if (localMana > self.renewMana and partyMembersHP < self.partyRenewHealth and not partyMember:HasBuff("Renew") and HasSpell("Renew")) then
							if (CastHeal('Renew', partyMember)) then
							return true;
							end
						end
					end
					
					-- Shield
					if (self.clickShield) then
						if (localMana > self.shieldMana and partyMembersHP < self.partyShieldHealth and not partyMember:HasDebuff("Weakened Soul") and IsInCombat() and HasSpell("Power Word: Shield")) then
							if (CastHeal('Power Word: Shield', partyMember)) then 
								return true; 
							end
						end
					end
	
					-- Greater Heal
					if (self.clickGreaterHeal) then
						if (localMana > self.greaterHealMana and partyMembersHP < self.partyGreaterHealHealth and HasSpell("Greater Heal")) then
							if (CastHeal('Greater Heal', partyMember)) then
								self.waitTimer = GetTimeEX() + 5500;
								return true;
							end
						end					
					end

					-- Heal
					if (self.clickHeal) then
						if (localMana > self.healMana and partyMembersHP < self.partyHealHealth and HasSpell("Heal")) then
							if (CastHeal('Heal', partyMember)) then
								self.waitTimer = GetTimeEX() + 4500;
								return true;
							end
						end
					end

					 -- Flash Heal
					if (self.clickFlashHeal) then
 						if (localMana > self.flashHealMana and partyMembersHP < self.partyFlashHealHealth) then
							if (CastHeal('Flash Heal', partyMember)) then
								self.waitTimer = GetTimeEX() + 1500;
								return true;
							end
						end
					end

					-- Lesser Heal
					if (self.clickLesserHeal) then
						if (self.useGroupLesserHeal and localMana > self.lesserHealMana and partyMembersHP < self.partyLesserHealHealth) then
							if (CastHeal('Lesser Heal', partyMember)) then
								self.waitTimer = GetTimeEX() + 2500;
								return true;
							end
						end
					end

					----- .
					----- PALADIN SPELLS
					-----	.

					-- Blessing of Protection
					if (localMana > 5 and partyMembersHP < self.bopHealth and HasSpell("Blessing of Protection")) then
						if (CastHeal('Lay on Hands', partyMember)) then
							self.waitTimer = GetTimeEX() + 1000;
							return true;
						end
					end

					-- Lay on Hands
					if (localMana < 25 and partyMembersHP < self.layOnHandsHealth and HasSpell("Lay on Hands")) then
						if (CastHeal('Lay on Hands', partyMember)) then
							self.waitTimer = GetTimeEX() + 1000;
							return true;
						end
					end

					-- Holy Light
					if (localMana > self.holyLightMana and partyMembersHP < self.partyHolyLightHealth and HasSpell("Holy Light")) then
						if (CastHeal('Holy Light', partyMember)) then
							self.waitTimer = GetTimeEX() + 2500;
							return true;
						end
					end

					-- Flash Of Light
					if (localMana > self.flashOfLightMana and partyMembersHP < self.partyFlashOfLightHealth and HasSpell("Flash of Light")) then
						if (CastHeal('Flash of Light', partyMember)) then
							self.waitTimer = GetTimeEX() + 1500;
							return true;
						end
					end
			end
		end
    end
    return false;
end


function script_follow:setup()
	self.lootCheck['timer'] = 0;
	self.lootCheck['target'] = 0;
	script_helper:setup();
	self.isSetup = true;
end

function script_follow:setWaitTimer(ms)
	self.waitTimer = GetTimeEX() + ms;
end

function script_follow:GetPartyLeaderObject() 
	if GetNumPartyMembers() > 0 then -- are we in a party?
		leaderObj = GetPartyMember(GetPartyLeaderIndex());
		if (leaderObj ~= nil) then
			return leaderObj;
		end
	end
	return 0;
end

function script_follow:run()
	script_follow:window();
	-- Set next to node distance and nav-mesh smoothness to double that number
	if (IsMounted()) then
		script_nav:setNextToNodeDist(5); NavmeshSmooth(10);
	else
		script_nav:setNextToNodeDist(self.nextToNodeDist); NavmeshSmooth(self.nextToNodeDist*2);
	end
	
	if (not self.isSetup) then
		script_follow:setup();
	end
	
	if (not self.navFunctionsLoaded) then self.message = "Error script_nav not loaded...";
		return; 
	end

	if (not self.helperLoaded) then self.message = "Error script_helper not loaded...";
		return;
	end

	if (self.pause) then self.message = "Paused by user..."; 
		return; 
	end

	-- auto unstuck feature
	if (self.useUnStuck) then
		if (not script_unstuck:pathClearAuto(2)) then
			self.message = script_unstuck.message;
			return;
		end
	end

	localObj = GetLocalPlayer();

	if(GetTimeEX() > self.timer) then
		self.timer = GetTimeEX() + self.tickRate;

		-- Wait out the wait-timer and/or casting or channeling
		if (self.waitTimer > GetTimeEX() or IsCasting() or IsChanneling()) then 
			return; 
		end

		-- Automatic loading of the nav mesh
		if (not IsUsingNavmesh()) then UseNavmesh(true);
			return;
		end

		if (not LoadNavmesh()) then self.message = "Make sure you have mmaps-files...";
			return; 
		end

		if (GetLoadNavmeshProgress() ~= 1) then self.message = "Loading the nav mesh... ";
			return; 
		end

		-- Corpse-walk if we are dead
		if(localObj:IsDead()) then
			self.message = "Walking to corpse...";
			-- Release body
			if(not IsGhost()) then RepopMe(); self.waitTimer = GetTimeEX() + 5000;
				return;
			end
			-- Ressurrect within the ress distance to our corpse
			local _lx, _ly, _lz = localObj:GetPosition();
			if(GetDistance3D(_lx, _ly, _lz, GetCorpsePosition()) > self.ressDistance) then
				script_nav:moveToNav(localObj, GetCorpsePosition());
				return;
			else
				if (script_aggro:safeRess()) then
					script_follow.message = "Finding a safe spot to ress...";
					return true;
				end
				RetrieveCorpse();
			end
			return;
		end

		-- Check: Rogue only, If we just Vanished, move away from enemies within 30 yards
		if (localObj:HasBuff("Vanish")) then if (script_nav:runBackwards(1, 30)) then 
			ClearTarget(); self.message = "Moving away from enemies...";
			return; 
		end
		
		-- Rest
		if (not IsInCombat() and script_follow:enemiesAttackingUs() == 0 and not localObj:HasBuff('Feign Death')) then
			-- Move out of water before resting/mounting
			--if (IsSwimming()) then self.message = "Moving out of the water..."; script_nav:navigate(GetLocalPlayer()); return; end
			-- Rest before looting, fighting, pathing etc
			if(RunRestScript()) then
				self.message = "Resting...";
				-- Stop moving
				if (IsMoving() and not localObj:IsMovementDisabed()) then
					StopMoving();
					return; 
				end
				-- Dismount
				if (IsMounted()) then DisMount(); 
					return;
				end
				-- Add 2500 ms timer to the rest script rotations (timer could be set already)
				if ((self.waitTimer - GetTimeEX()) < 2500) then
					self.waitTimer = GetTimeEX()+2500;
				end;
			return;	
			end
		end

		-- If bags are full
		if (AreBagsFull() and not IsInCombat()) then
			self.message = 'Warning bags are full...';
		end

		-- Clear dead/tapped targets
		if (self.enemyObj ~= 0 and self.enemyObj ~= nil) then
			if ((self.enemyObj:IsTapped() and not self.enemyObj:IsTappedByMe()) or self.enemyObj:IsDead()) then
				self.enemyObj = nil;
				ClearTarget();
			end
		end

		-- Accept group invite
		if (GetNumPartyMembers() < 1 and self.acceptTimer < GetTimeEX()) then 
			self.acceptTimer = GetTimeEX() + 5000;
			AcceptGroup(); 
		end

		-- Healer check: heal/buff the party
		if (script_follow:healAndBuff() and (HasSpell('Smite') or HasSpell('Holy Light'))) then
			self.message = "Healing/buffing the party...";
			return;
		end

		-- Loot
		if (not IsInCombat() and script_follow:enemiesAttackingUs() == 0 and not localObj:HasBuff('Feign Death')) then
			-- Loot if there is anything lootable and we are not in combat and if our bags aren't full
			if (not self.skipLooting and not AreBagsFull()) then 
				self.lootObj = script_nav:getLootTarget(self.findLootDistance);
			else
				self.lootObj = nil;
			end
			if (self.lootObj == 0) then self.lootObj = nil;
			end
			local isLoot = not IsInCombat() and not (self.lootObj == nil);
			if (isLoot and not AreBagsFull()) then
				script_grindEX:doLoot(localObj);
				return;
			elseif (AreBagsFull() and not hsWhenFull) then
				self.lootObj = nil;
				self.message = "Warning the bags are full...";
			end
		end

		-- Randomize the follow range
		if (self.followTimer < GetTimeEX()) then 
			self.followTimer = GetTimeEX() + 20000;
		end

		-- Follow our master
		if (script_follow:GetPartyLeaderObject() ~= 0) then
			if(script_follow:GetPartyLeaderObject():GetDistance() > self.followDistance and not script_follow:GetPartyLeaderObject():IsDead()) then
				local x, y, z = script_follow:GetPartyLeaderObject():GetPosition();
				self.message = "Following our master...";
				script_nav:moveToTarget(GetLocalPlayer(), x, y, z);
			return;
			end
		end
			
		-- Assign the next valid target to be killed
		-- Check if anything is attacking us Priest
		if (script_follow:enemiesAttackingUs() >= 1) then
			local localMana = GetLocalPlayer():GetManaPercentage();
			if (localMana > 6 and HasSpell('Fade') and not IsSpellOnCD('Fade')) then
				CastSpellByName('Fade');
				return;
			end
		end
				
		-- Check if anything is attacking us Paladin
		if (script_follow:enemiesAttackingUs() >= 2) then
			local localMana = GetLocalPlayer():GetManaPercentage();
			if (localMana > 6 and HasSpell('Divine Protection') and not IsSpellOnCD('Divine Protection')) then
				CastSpellByName('Divine Protection');
				return;
			end
		end

		-- if no target then get target
		if (GetTarget() ~= 0 and GetTarget() ~= nil) then
			local target = GetTarget();
			if (target:CanAttack()) then
				self.enemyObj = target;
			else
				self.enemyObj = nil;
			end
		else -- else follow leader
			if (script_follow:GetPartyLeaderObject() ~= 0) then
				if (script_follow:GetPartyLeaderObject():GetUnitsTarget() ~= 0 and not script_follow:GetPartyLeaderObject():IsDead()) then
					if (script_follow:GetPartyLeaderObject():GetUnitsTarget():GetHealthPercentage() < self.dpsHp) then
						self.enemyObj = script_follow:GetPartyLeaderObject():GetUnitsTarget();
					else
						self.enemyObj = nil;
					end
				end
			end
		end

		-- Check: If we are a priest and we are at least 3 party members, dont do damage if mana below 70%
		--if (HasSpell('Smite') and GetNumPartyMembers() > 2 and GetLocalPlayer():GetManaPercentage() < 70) then
		--	self.enemyObj = nil;
		--end			

		-- Finish loot before we engage new targets or navigate
		if (self.lootObj ~= nil and not IsInCombat()) then 
			return; 
		else
			-- reset the combat status
			self.combatError = nil; 
			-- Run the combat script and retrieve combat script status if we have a valid target
			if (self.enemyObj ~= nil and self.enemyObj ~= 0) then
				self.combatError = RunCombatScript(self.enemyObj:GetGUID());
			end
		end

		if(self.enemyObj ~= nil or IsInCombat()) then
			self.message = "Running the combat script...";
			-- In range: attack the target, combat script returns 0
			if(self.combatError == 0) then
				script_nav:resetNavigate();
				if IsMoving() then 
					StopMoving(); 
					return; 
				end
			end
			-- Invalid target: combat script return 2
			if(self.combatError == 2) then
				-- TODO: add blacklist GUID here
				self.enemyObj = nil;
				ClearTarget();
				return;
			end
			-- Move in range: combat script return 3
			if (self.combatError == 3) then
				self.message = "Moving to target...";
				local _x, _y, _z = self.enemyObj:GetPosition();
				self.message = script_nav:moveToTarget(GetLocalPlayer(), _x, _y, _z);
				return;
			end

			-- Do nothing, return : combat script return 4
			if(self.combatError == 4) then 
				return;
			end

			-- Target player pet/totem: pause for 5 seconds, combat script should add target to blacklist
			if(self.combatError == 5) then
				self.message = "Targeted a player pet pausing 5s...";
				ClearTarget(); self.waitTimer = GetTimeEX()+5000;
				return;
			end

			-- Stop bot, request from a combat script
			if(self.combatError == 6) then self.message = "Combat script request stop bot...";
				Logout();
				StopBot();
				return;
			end
		end

		-- Pre checks before navigating
		if(IsLooting() or IsCasting() or IsChanneling() or IsDrinking() or IsEating() or IsInCombat()) then 
			return;
		end

		-- Mount before we follow our master
		--if (script_follow:mountUp()) then return; end		
		
		-- Follow our master
		if (script_follow:GetPartyLeaderObject() ~= 0) then
			if(script_follow:GetPartyLeaderObject():GetDistance() > self.followDistance and not script_follow:GetPartyLeaderObject():IsDead()) then
				local x, y, z = script_follow:GetPartyLeaderObject():GetPosition();
				self.message = "Following our master...";
				script_nav:moveToTarget(GetLocalPlayer(), x, y, z);
			return;
			end
		end
	end 
end
end

--function script_follow:mountUp()
--	local __, lastError = GetLastError();
--	if (lastError ~= 75 and self.mountTimer < GetTimeEX()) then
--		-- TODO: change in 2.1.11
--		-- local _, isSwimming = IsSwimming();
--		if(GetLocalPlayer():GetLevel() >= 40 and self.useMount and not IsIndoors() and not IsMounted() and self.lootObj == nil) then
--			self.message = "Mounting...";
--			if (not IsStanding()) then StopMoving(); end
--			if (script_helper:useMount()) then self.waitTimer = GetTimeEX() + 4000; return true; end
--		end
--	else
--		ClearLastError();
--		self.mountTimer = GetTimeEX() + 15000;
--		return false;
--	end
--end

function script_follow:getTarget()
	return self.enemyObj;
end

function script_follow:getTargetAttackingUs() 
    local currentObj, typeObj = GetFirstObject(); 
    while currentObj ~= 0 do 
    	if typeObj == 3 then
		if (currentObj:CanAttack() and not currentObj:IsDead()) then
			local localObj = GetLocalPlayer();		
                	if (currentObj:GetUnitsTarget() == localObj) then 
                		return currentObj;
                	end 
            	end 
       	end
        currentObj, typeObj = GetNextObject(currentObj); 
    end
    return nil;
end

function script_follow:assignTarget() 
	-- Instantly return the last target if we attacked it and it's still alive and we are in combat
	if (self.enemyObj ~= 0 and self.enemyObj ~= nil and not self.enemyObj:IsDead() and IsInCombat()) then
		if (script_follow:isTargetingMe(self.enemyObj) 
			or script_follow:isTargetingPet(self.enemyObj) 
			or self.enemyObj:IsTappedByMe()) then
			return self.enemyObj;
		end
	end

	-- Find the closest valid target if we have no target or we are not in combat
	local mobDistance = self.pullDistance;
	local closestTarget = nil;
	local i, targetType = GetFirstObject();
	while i ~= 0 do
		if (targetType == 3 and not i:IsCritter() and not i:IsDead() and i:CanAttack()) then
			if (script_follow:enemyIsValid(i)) then
				-- save the closest mob or mobs attacking us
				if (mobDistance > i:GetDistance()) then
					mobDistance = i:GetDistance();	
					closestTarget = i;
				end
			end
		end
		i, targetType = GetNextObject(i);
	end
	
	-- Check: If we are in combat but no valid target, kill the "unvalid" target attacking us
	if (closestTarget == nil and IsInCombat()) then
		if (GetTarget() ~= 0) then
			return GetTarget();
		end
	end

	-- Return the closest valid target or nil
	return closestTarget;
end

function script_follow:isTargetingPet(i) 
	local pet = GetPet();
	if (pet ~= nil and pet ~= 0 and not pet:IsDead()) then
		if (i:GetUnitsTarget() ~= nil and i:GetUnitsTarget() ~= 0) then
			return i:GetUnitsTarget():GetGUID() == pet:GetGUID();
		end
	end
	return false;
end

function script_follow:isTargetingMe(i) 
	local localPlayer = GetLocalPlayer();
	if (localPlayer ~= nil and localPlayer ~= 0 and not localPlayer:IsDead()) then
		if (i:GetUnitsTarget() ~= nil and i:GetUnitsTarget() ~= 0) then
			return i:GetUnitsTarget():GetGUID() == localPlayer:GetGUID();
		end
	end
	return false;
end

function script_follow:enemyIsValid(i)
	if (i ~= 0) then
		-- Valid Targets: Tapped by us, or is attacking us or our pet
		if (script_follow:isTargetingMe(i)
			or (script_follow:isTargetingPet(i) and (i:IsTappedByMe() or not i:IsTapped())) 
			or (i:IsTappedByMe() and not i:IsDead())) then 
				return true; 
		end
		-- Valid Targets: Within pull range, levelrange, not tapped, not skipped etc
		if (not i:IsDead() and i:CanAttack() and not i:IsCritter()
			and ((i:GetLevel() <= self.maxLevel and i:GetLevel() >= self.minLevel))
			and i:GetDistance() < self.pullDistance and (not i:IsTapped() or i:IsTappedByMe())
			and not script_follow:isTargetBlacklisted(i:GetGUID()) 
			and not (self.skipHumanoid and i:GetCreatureType() == 'Humanoid')
			and not (self.skipDemon and i:GetCreatureType() == 'Demon')
			and not (self.skipBeast and i:GetCreatureType() == 'Beast')
			and not (self.skipElemental and i:GetCreatureType() == 'Elemental')
			and not (self.skipUndead and i:GetCreatureType() == 'Undead') 
			and not (self.skipElites and (i:GetClassification() == 1 or i:GetClassification() == 2))
			) then
			return true;
		end
	end
	return false;
end

function script_follow:enemiesAttackingUs() -- returns number of enemies attacking us
	local unitsAttackingUs = 0; 
	local currentObj, typeObj = GetFirstObject(); 
	while currentObj ~= 0 do 
    		if typeObj == 3 then
			if (currentObj:CanAttack() and not currentObj:IsDead()) then
                		if (script_follow:isTargetingMe(currentObj)) then 
                			unitsAttackingUs = unitsAttackingUs + 1; 
                		end 
            		end 
       		end
      	currentObj, typeObj = GetNextObject(currentObj); 
	end
   	return unitsAttackingUs;
end

function script_follow:playersTargetingUs() -- returns number of players attacking us
	local nrPlayersTargetingUs = 0; 
	local currentObj, typeObj = GetFirstObject(); 
	while currentObj ~= 0 do 
	if typeObj == 4 then
		if (script_follow:isTargetingMe(currentObj)) then 
                	nrPlayersTargetingUs = nrPlayersTargetingUs + 1; 
                end 
       	end
        currentObj, typeObj = GetNextObject(currentObj); 
    end
    return nrPlayersTargetingUs;
end

function script_follow:playersWithinRange(range)
	local currentObj, typeObj = GetFirstObject(); 
	while currentObj ~= 0 do 
    	if (typeObj == 4 and not currentObj:IsDead()) then
		if (currentObj:GetDistance() < range) then 
			local localObj = GetLocalPlayer();
			if (localObj:GetGUID() ~= currentObj:GetGUID()) then
                		return true;
			end
                end 
       	end
        currentObj, typeObj = GetNextObject(currentObj); 
    end
    return false;
end

function script_follow:getDistanceDif()
	local x, y, z = GetLocalPlayer():GetPosition();
	local xV, yV, zV = self.myX-x, self.myY-y, self.myZ-z;
	return math.sqrt(xV^2 + yV^2 + zV^2);
end

function script_follow:draw()
	script_followEX:drawStatus();
	if (IsMoving()) then script_nav:drawPath() end
end