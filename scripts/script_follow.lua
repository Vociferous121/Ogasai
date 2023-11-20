script_follow = {

	useMount = false,
	disMountRange = 32,
	mountTimer = 0,
	enemyObj = nil,
	lootObj = nil,
	timer = GetTimeEX(),
	tickRate = 1200,
	waitTimer = GetTimeEX(),
	pullDistance = 150,
	findLootDistance = 40,
	lootDistance = 6,
	skipLooting = true,
	lootCheck = {},
	ressDistance = 25,
	combatError = 0,
	dpsHP = 95,
	myX = 0,
	myY = 0,
	myZ = 0,
	myTime = GetTimeEX(),
	nextToNodeDist = 3,
	isSetup = false,
	drawUnits = false,
	acceptTimer = GetTimeEX(),
	followLeaderDistance = 26,
	followTimer = GetTimeEX(),
	assistInCombat = false,
	isChecked = true,
	pause = true,
	autoGhost = false,
	message = "Starting the follower...",
	navFunctionsLoaded = include("scripts\\script_nav.lua"),
	helperLoaded = include("scripts\\script_helper.lua"),
	extraFunctions = include("scripts\\script_followEX.lua"),
	unstuckLoaded = include("scripts\\script_unstuck.lua"),
	healsLoaded = include("scripts\\script_followHealsAndBuffs.lua"),
	drawNav = true,

}

function script_follow:window()
	if (self.isChecked) then 
		EndWindow();
		if(NewWindow("Follower Options", 320, 360)) then 
			script_followEX:menu();
		end
	end
end

function getPartyMembers()
	for i = 1, GetNumPartyMembers()+1 do

			local partyMember = GetPartyMember(i);

		if (i == GetNumPartyMembers()+1) then
			partyMember = GetLocalPlayer();
		end

			local localMana = GetLocalPlayer():GetManaPercentage();
			local localEnergy = GetLocalPlayer():GetEnergyPercentage();
			local partyMemberHP = partyMember:GetHealthPercentage();

		if (partyMemberHP > 0) and (localMana > 1 or localEnergy > 1) then
				local partyMemberDistance = partyMember:GetDistance();
				leaderObj = GetPartyMember(GetPartyLeaderIndex());
				local localHealth = GetLocalPlayer():GetHealthPercentage();
		end
	end
end

function script_follow:moveInLineOfSight(partyMember)

	leaderObj = GetPartyMember(GetPartyLeaderIndex());

	for i = 1, GetNumPartyMembers()+1 do

			local partyMember = GetPartyMember(i);

		if (i == GetNumPartyMembers()+1) then
			partyMember = GetLocalPlayer();
		end
	end

	if (GetNumPartyMembers() > 1) then
		if (not leaderObj:IsInLineOfSight() or leaderObj:GetDistance() > self.followLeaderDistance) then
			local x, y, z = leaderObj:GetPosition();
			script_nav:moveToTarget(GetLocalPlayer(), x , y, z);
			self.timer = GetTimeEX() + 200;
           		self.message = "Moving to Party Leader LoS";
			return true;
		end
	end

	if (self.followMember) then
		if (not partyMember:IsInLineOfSight() and partyMember:GetDistance() < self.followLeaderDistance) then
			local x, y, z = partyMember:GetPosition();
			script_nav:moveToTarget(GetLocalPlayer(), x , y, z);
			self.timer = GetTimeEX() + 200;
			self.message = "Moving to party member LoS";
			return true;
		end
	end
return false;
end

function script_follow:setup()
	self.lootCheck['timer'] = 0;
	self.lootCheck['target'] = 0;
	script_helper:setup();
	self.isSetup = true;
	ClearTarget();
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
		
		if (IsUsingNavmesh()) and (self.drawPath) then
			script_nav:drawPath();
		end

	-- Set next to node distance and nav-mesh smoothness to double that number
	if (IsMounted()) then
		script_nav:setNextToNodeDist(6); NavmeshSmooth(14);
	else
		script_nav:setNextToNodeDist(self.nextToNodeDist);
		NavmeshSmooth(self.nextToNodeDist*3);
	end
	
	if (not self.isSetup) then
		script_follow:setup();
	end
	
	if (not self.navFunctionsLoaded) then
		self.message = "Error script_nav not loaded...";
		return;
	end

	if (not self.helperLoaded) then	
		self.message = "Error script_helper not loaded..."; 
		return;
	end

	if (self.pause) then 
		self.message = "Paused by user..."; 
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
		if (not IsUsingNavmesh()) then 
			UseNavmesh(true);
			return; 
		end

		if (not LoadNavmesh()) then 
			self.message = "Make sure you have mmaps-files...";
			return;
		end
		
		if (GetLoadNavmeshProgress() ~= 1) then
			self.message = "Loading the nav mesh... ";
			return; 
		end

		-- Corpse-walk if we are dead
		if(localObj:IsDead()) then

			script_follow.tickRate = 100;

				self.message = "Walking to corpse...";
			-- Release body
			if(not IsGhost()) and (self.autoGhost) then 
				RepopMe(); 
				self.waitTimer = GetTimeEX() + 5000;
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
		if (localObj:HasBuff("Vanish")) then
			if (script_nav:runBackwards(1, 30)) then 
				ClearTarget(); 
				self.message = "Moving away from enemies..."; 
				return; 
			end 
		end
		
		-- Rest
		if (not IsInCombat() and script_follow:enemiesAttackingUs() == 0 and not localObj:HasBuff('Feign Death')) then
			if(RunRestScript()) then
				self.message = "Resting...";
				-- Stop moving
				if (IsMoving() and not localObj:IsMovementDisabed()) then
					StopMoving(); 
					return; 
				end
				-- Dismount
				if (IsMounted()) then
					DisMount(); 
					return; 
				end
				-- Add 2500 ms timer to the rest script rotations (timer could be set already)
				if ((self.waitTimer - GetTimeEX()) < 2500) then
					self.waitTimer = GetTimeEX()+2500;
				end
				ClearTarget();
				return;	
			end
		end

		-- If bags are full
		if (AreBagsFull() and not IsInCombat()) then
			self.message = 'Warning bags are full...';
		end

		-- Clear dead/tapped targets
		if (self.enemyObj ~= 0 and self.enemyObj ~= nil) then
			if ((self.enemyObj:IsTapped() and not self.enemyObj:IsTappedByMe()) 
				or self.enemyObj:IsDead()) then
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
		if (script_followHealsAndBuffs:healAndBuff()) and (HasSpell("Smite") or HasSpell("Rejuvenation") or HasSpell("Healing Wave") or HasSpell("Holy Light")) then
			self.message = "Healing/buffing the party...";
			ClearTarget();
			return;
		end

		-- Loot
		if (not IsInCombat() and script_follow:enemiesAttackingUs() == 0 and not localObj:HasBuff('Feign Death')) then
			-- Loot if there is anything lootable and we are not in combat and if our bags aren't full
			if (not self.skipLooting and not AreBagsFull() and leaderObj:GetDistance() <= self.followLeaderDistance) then 
				self.lootObj = script_nav:getLootTarget(self.findLootDistance);
			else
				self.lootObj = nil;
			end
			if (self.lootObj == 0) then
				self.lootObj = nil; 
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

		-- Assign the next valid target to be killed
		-- Check if anything is attacking us Priest
		if (script_follow:enemiesAttackingUs() >= 1) then
				local localMana = GetLocalPlayer():GetManaPercentage();
			if (localMana > 6 and HasSpell('Fade') and not IsSpellOnCD('Fade')) then
				CastSpellByName('Fade');
				return;
			end
		end

		-- Healer check: heal/buff the party
		if (script_followHealsAndBuffs:healAndBuff()) and (HasSpell("Smite") or HasSpell("Rejuvenation") or HasSpell("Healing Wave") or HasSpell("Holy Light")) then
			self.message = "Healing/buffing the party...";
			ClearTarget();
			return;
		end
				
		-- Check if anything is attacking us Paladin
		if (script_follow:enemiesAttackingUs() >= 2) then
				local localMana = GetLocalPlayer():GetManaPercentage();
			if (localMana > 6 and HasSpell('Divine Protection') and not IsSpellOnCD('Divine Protection')) then
				CastSpellByName('Divine Protection');
				return;
			end
		end
        
		if  (GetNumPartyMembers() > 1) and (GetTarget() ~= 0 and GetTarget() ~= nil) and (script_follow:GetPartyLeaderObject():GetDistance() < self.followLeaderDistance) then
            			local target = GetTarget();
			if (target:CanAttack() and self.assistInCombat) then
				self.enemyObj = target;
			else
				self.enemyObj = nil;
			end 

		else

		-- Healer check: heal/buff the party
			if (script_followHealsAndBuffs:healAndBuff()) and (HasSpell("Smite") or HasSpell("Rejuvenation") or HasSpell("Healing Wave") or HasSpell("Holy Light")) then
				self.message = "Healing/buffing the party...";
				ClearTarget();
				return;
			end
		end

		if (script_follow:GetPartyLeaderObject() ~= 0) then
			if (script_follow:GetPartyLeaderObject():GetUnitsTarget() ~= 0 and not script_follow:GetPartyLeaderObject():IsDead()) and (script_follow:GetPartyLeaderObject():GetDistance() < self.followLeaderDistance) then
				if (script_follow:GetPartyLeaderObject():GetUnitsTarget():GetHealthPercentage() <= self.dpsHP and self.assistInCombat) then
					self.enemyObj = script_follow:GetPartyLeaderObject():GetUnitsTarget();
					script_follow:moveInLineOfSight(leaderObj);
				else
					self.enemyObj = nil;
					ClearTarget();
				end
			end
       		end
	end	

		-- Finish loot before we engage new targets or navigate
		if (self.lootObj ~= nil and not IsInCombat()) and (script_follow:GetPartyLeaderObject():GetDistance() < self.followLeaderDistance) then
			return; 
		else
			-- reset the combat status
				self.combatError = nil; 
			-- Run the combat script and retrieve combat script status if we have a valid target
			if (self.enemyObj ~= nil and self.enemyObj ~= 0) then
				self.combatError = RunCombatScript(self.enemyObj:GetGUID());
			end
		end

			if (self.enemyObj ~= nil or IsInCombat()) then
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
					ClearTarget();
					self.waitTimer = GetTimeEX()+5000;
					return;
				end

				-- Stop bot, request from a combat script
				if(self.combatError == 6) then
					self.message = "Combat script request stop bot...";
					Logout();
					StopBot();
					return;
				end
			end
		

		-- Pre checks before navigating
		if(IsLooting() or IsCasting() or IsChanneling() or IsDrinking() or IsEating() or IsInCombat()) then 
			return;
		end	

		-- Follow our master
		if (script_follow:GetPartyLeaderObject() ~= 0) then
			if(script_follow:GetPartyLeaderObject():GetDistance() > self.followLeaderDistance and not script_follow:GetPartyLeaderObject():IsDead()) and (not localObj:IsDead()) then
				local x, y, z = script_follow:GetPartyLeaderObject():GetPosition();
				self.message = "Following Party Leader...";
				script_nav:moveToTarget(GetLocalPlayer(), x, y, z);
				return;
			end
		end

		-- Healer check: heal/buff the party
		if (script_followHealsAndBuffs:healAndBuff()) and (HasSpell("Smite") or HasSpell("Rejuvenation") or HasSpell("Healing Wave") or HasSpell("Holy Light")) then
			self.message = "Healing/buffing the party...";
			ClearTarget();
			return;
		end
end -- end of function 

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
		local class = UnitClass("player");
	if (not class == 'Warlock') then
			local pet = GetPet();
		if (pet ~= nil and pet ~= 0 and not pet:IsDead()) then
			if (i:GetUnitsTarget() ~= nil and i:GetUnitsTarget() ~= 0) then
				return i:GetUnitsTarget():GetGUID() == pet:GetGUID();
			end
		end
		return false;
	end
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
end