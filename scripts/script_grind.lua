script_grind = {
	jump = true,	-- jump on/off
	jumpRandomFloat = 99,
	useVendor = false,
	repairWhenYellow = false,
	stopWhenFull = false,
	hsWhenFull = false,
	useMount = false,
	disMountRange = 32,
	mountTimer = GetTimeEX(),
	enemyObj = nil,
	lootObj = nil,
	timer = GetTimeEX(),
	tickRate = 100,
	waitTimer = GetTimeEX(),
	pullDistance = 225,
	avoidElite = true,
	avoidRange = 40,
	findLootDistance = 60,
	lootDistance = 2.6,
	skipLooting = false,
	lootCheck = {},
	minLevel = GetLocalPlayer():GetLevel()-5,
	maxLevel = GetLocalPlayer():GetLevel()+2,
	ressDistance = 34,
	combatError = 0,
	autoTalent = false,
	myX = 0,
	myY = 0,
	myZ = 0,
	myTime = GetTimeEX(),
	message = 'Starting the grinder...',
	skipHumanoid = false,
	skipElemental = false,
	skipUndead = false,
	skipDemon = false,
	skipBeast = false,
	skipAberration = false,
	skipDragonkin = false,
	skipGiant = false,
	skipMechanical = false,
	skipElites = true,
	paranoidRange = 137,
	navFunctionsLoaded = include("scripts\\script_nav.lua"),
	helperLoaded = include("scripts\\script_helper.lua"),
	talentLoaded = include("scripts\\script_talent.lua"),
	vendorLoaded = include("scripts\\script_vendor.lua"),
	gatherLoaded = include("scripts\\script_gather.lua"),
	grindExtra = include("scripts\\script_grindEX.lua"),
	grindMenu = include("scripts\\script_grindMenu.lua"),
	aggroLoaded = include("scripts\\script_aggro.lua"),
	expExtra = include("scripts\\script_expChecker.lua"),
	unstuckLoaded = include("scripts\\script_unstuck.lua"),
	SensitiveUnstuckLoaded = include("scripts\\script_unstuck_highSensitivity.lua"),
	paranoiaLoaded = include("scripts\\script_paranoia.lua"),
	radarLoaded = include("scripts\\script_radar.lua"),
	debuffCheck = include("scripts\\script_checkDebuffs.lua"),
	nextToNodeDist = 3.8, -- (Set to about half your nav smoothness)
	blacklistedTargets = {},
	blacklistedNum = 0,
	isSetup = false,
	drawUnits = true,
	Name = "", -- set to e.g. "paths\1-5 Durator.xml" for auto load at startup
	pathLoaded = "",
	drawPath = false,
	autoPath = true,
	drawAutoPath = true,
	distToHotSpot = 325,
	staticHotSpot = true,
	hotSpotTimer = GetTimeEX(),
	currentLevel = GetLocalPlayer():GetLevel(),
	skinning = false,
	gather = false,
	lastTarget = 0,
	newTargetTime = GetTimeEX(),
	blacklistTime = 45,
	drawEnabled = true,
	showClassOptions = true,
	pause = true,
	bagsFull = false,
	vendorRefill = false,
	useMana = true,
	drawGather = false,
	hotspotReached = false,
	drawAggro = false,
	safeRess = true,
	skipHardPull = true,
	useUnstuck = true,
	blacklistAdds = 1,
	blacklistedNameNum = 0,
	useExpChecker = true,
	paranoidSetTimer = 16,
	useString = true,	-- message to send to log players in range run once
	useOtherString = true,	-- message to send to log players targeting us run once
	useLogoutTimer = false,	-- use logout timer true/false
	logoutSetTime = GetTimeEX() / 1000,	-- set the logout time in seconds
	logoutTime = 2,	-- logout time in hours
	adjustTickRate = false,
	useUnstuckTwo = true,
	lootCheckTime = 0,
	afkActionSlot = "24",
}

function script_grind:setup()
	self.lootCheck['target'] = 0;
	self.lootCheck['timer'] = GetTimeEX();

	-- Classes that don't use mana
	local class, classFileName = UnitClass("player");
	if (strfind("Warrior", class) or strfind("Rogue", class)) then
		self.useMana = false;
		self.restMana = 0;
	end
	
	-- No refill as mage or at level 1
	if (strfind("Mage", class)) then
		self.vendorRefill = false;
	end

	if (GetLocalPlayer():GetLevel() < 3) then
		self.vendorRefill = false;
	end

	if (GetLocalPlayer():GetLevel() < 8) then
		self.skipHardPull = false;
	end

	self.drawEnabled = true;
	script_helper:setup();
	script_talent:setup();
	script_vendor:setup();
	script_gather:setup();
	DEFAULT_CHAT_FRAME:AddMessage('script_grind: loaded...');
	vendorDB:setup();
	hotspotDB:setup();
	vendorDB:loadDBVendors();
	script_nav:setup();

	self.isSetup = true;

	-- safer min level for low level botting
	if (GetLocalPlayer():GetLevel() < 20) then
		script_grind.minLevel = GetLocalPlayer():GetLevel() - 3;
	end
	
	-- don't stop bot on next level if level is under 10
	if (GetLocalPlayer():GetLevel() < 10) then
		script_paranoia.stopOnLevel = false;
	end

	-- turn on skinning if have
	if (HasSpell("Skinning")) then
		self.skinning = true;
	end
		
end

function script_grind:window()
	EndWindow();
	if(NewWindow("Grinder", 320, 300)) then
		script_grindMenu:menu();
	end
end

function script_grind:setWaitTimer(ms)
	self.waitTimer = (GetTimeEX() + ms);
end

function script_grind:addTargetToBlacklist(targetGUID)
	if (targetGUID ~= nil and targetGUID ~= 0 and targetGUID ~= '') then	
		self.blacklistedTargets[self.blacklistedNum] = targetGUID;
		self.blacklistedNum = self.blacklistedNum + 1;
	end
end

function script_grind:isTargetBlacklisted(targetGUID) 
	for i=0,self.blacklistedNum do
		if (targetGUID == self.blacklistedTargets[i]) then
			return true;
		end
	end
	return false;
end

--IS TARGET BLACKLISTED BY NAME - thank you Coin
--function script_grind:isTargetNameBlacklisted(name) 
--	for i=0,self.blacklistedNameNum do
--		if (name == self.blacklistedNameTargets[i]) then
--			return true;
--		end
--	end
--	return false;
--end

--ADD BLACKLIST BY NAME - thank you Coin
--function script_grind:addTargetToNameBlacklist(name) 
--	if (name ~= nil and name ~= 0 and name ~= '') then	
--		self.blacklistedNameTargets[self.blacklistedNameNum] = name;
--		self.blacklistedNameNum = self.blacklistedNameNum + 1;
--	end
--end

function script_grind:run()
	script_grind:window();
	
	if (script_radar.showRadar) then
		script_radar:draw()
	end

	if (self.useExpChecker) and (IsInCombat()) then
		script_expChecker:menu();
	end

	-- logout timer
	if (self.useLogoutTimer) then

		-- set logout time
		local currentTime = GetTimeEX()/ 1000;

		if (currentTime >= self.logoutSetTime + self.logoutTime * 3600) then
			Exit();
		end
	end

	if (AreBagsFull()) then
		self.bagsFull = true;
	end

	 -- Set next to node distance and nav-mesh smoothness to double that number
	if (self.useMount and IsMounted()) then
		script_nav:setNextToNodeDist(12); NavmeshSmooth(24);
	else
		script_nav:setNextToNodeDist(self.nextToNodeDist); NavmeshSmooth(self.nextToNodeDist*3);
	end

		localObj = GetLocalPlayer();
	-- sprint
	if (localObj:HasBuff("Sprint")) or (localObj:HasBuff("Aspect of the Cheetah")) then
		script_nav:setNextToNodeDist(8); NavmeshSmooth(24);
	else
		script_nav:setNextToNodeDist(self.nextToNodeDist); NavmeshSmooth(self.nextToNodeDist*4);
	end

	-- night elf whisp
		local race = UnitRace('player');
	if (race == 'Night Elf') and (localObj:IsDead()) then
		script_nav:setNextToNodeDist(6);
		NavmeshSmooth(18);
	else
		script_nav:setNextToNodeDist(self.nextToNodeDist);
		NavmeshSmooth(self.nextToNodeDist*4);
	end
	
	-- player is dead
	if (localObj:IsDead() or IsGhost()) then
		script_nav:setNextToNodeDist(3);
		NavmeshSmooth(12);
		self.tickRate = 100;
	else
		script_nav:setNextToNodeDist(self.nextToNodeDist);
		NavmeshSmooth(self.nextToNodeDist*4);
	end

	if (not self.isSetup) then
		script_grind:setup();
	end

	if (not self.navFunctionsLoaded) then
		self.message = "Error script_nav not loaded...";
		return;
	end
	if (not self.helperLoaded) then
		self.message = "Error script_helper not loaded...";
		return;
	end

	if (not self.useUnstuckTwo) and (self.useUnstuck and IsMoving()) and (not self.pause) then
		if (not script_unstuck:pathClearAuto(2)) then
			script_unstuck:unstuck();
			return true;
		end
	end

	if (self.useUnstuckTwo) and (self.useUnstuck and IsMoving()) and (not self.pause) then
		if (not script_unstuck_highSensitivity:pathClearAuto(2)) then
			script_unstuck_highSensitivity:unstuck();
			return true;
		end
	end

	if (self.pause) then self.message = "Paused by user...";
		return;
	end

	-- Check: Spend talent points
	if (not IsInCombat() and not GetLocalPlayer():IsDead() and self.autoTalent) then
		if (script_talent:learnTalents()) then
			self.message = "Checking/learning talent: " .. script_talent:getNextTalentName();
			return;
		end
	end
	
	-- check paranoia
		
	if (not IsInCombat()) and (not IsLooting()) then
		if (script_paranoia:checkParanoia()) then
			self.waitTimer = GetTimeEX() + (self.paranoidSetTimer * 1000) + 2000;
			return;
		end
	end

	if (self.undoAFK) and (IsStanding()) then
		UseAction(script_grind.afkActionSlot, 0, 0);
		self.waitTimer = GetTimeEX() + 2500;
		script_grind:setWaitTimer(2500);
		script_grind.undoAFK = false;
		return true;
	end
		
	
	-- set tick rate for scripts
	if (GetTimeEX() > self.timer) then
		self.timer = GetTimeEX() + self.tickRate;

		-- Do all checks
		if (script_grindEX:doChecks()) then
			return;
		end

		-- Check: If our gear is yellow
		for i = 1, 16 do
		local status = GetInventoryAlertStatus('' .. i);
			if (status ~= nil) then 
				if (status >= 3 and script_grind.repairWhenYellow and script_grind.useVendor and script_vendor.repairVendor ~= 0 and not IsInCombat()) then
					script_vendor:repair(); 
					return true;
				end
			end
		end

		-- Jump
		if (self.jump) then
			local jumpRandom = random(1, 100);
			if (jumpRandom > self.jumpRandomFloat and IsMoving() and not IsInCombat()) then
				JumpOrAscendStart();
			end
		end

		-- Gather
		if (self.gather and not IsInCombat() and not AreBagsFull() and not self.bagsFull) then
			script_grind.tickRate = 100;
			if (script_gather:gather()) then
				self.message = 'Gathering ' .. script_gather:currentGatherName() .. '...';
				return;
			end
		end
		
		-- Auto path: keep us inside the distance to the current hotspot, if mounted keep running even if in combat
		if ((not IsInCombat() or IsMounted()) and self.autoPath and script_vendor:getStatus() == 0 and
			(script_nav:getDistanceToHotspot() > self.distToHotSpot or self.hotSpotTimer > GetTimeEX())) then
			if (not (self.hotSpotTimer > GetTimeEX())) then
				self.hotSpotTimer = GetTimeEX() + 20000;
			end

			if (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) then
				CastSpellByName("Stealth", localObj);
				self.waitTimer = GetTimeEX() + 1200;
			end
			--if (script_grind:mountUp() and self.useMount) then
			--	return; 
			--end
			-- Druid cat form is faster if you specc talents
			if (self.currentLevel < 40 and HasSpell('Cat Form') and not localObj:HasBuff('Cat Form')) then
				CastSpellByName('Cat Form');
			end
			-- Shaman Ghost Wolf 
			if (self.currentLevel < 40 and HasSpell('Ghost Wolf') and not localObj:HasBuff('Ghost Wolf')) then
				CastSpellByName('Ghost Wolf');
			end
			self.message = script_nav:moveToHotspot(localObj);
			script_grind:setWaitTimer(80);
			return;
		end
		
		-- Assign the next valid target to be killed within the pull range
		if (self.enemyObj ~= 0 and self.enemyObj ~= nil) and self.lootobj == nil then
			self.waitTimer = GetTimeEX() + 200;
			self.lastTarget = self.enemyObj:GetGUID();
		end

		self.enemyObj = script_grind:assignTarget();

		if (self.useExpChecker) then
			script_expChecker:targetLevels();
		end

		if (self.enemyObj ~= 0 and self.enemyObj ~= nil) then
			-- Fix bug, when not targeting correctly
			if (self.lastTarget ~= self.enemyObj:GetGUID()) then
				self.newTargetTime = GetTimeEX() + 1000;
				ClearTarget();
			elseif (self.lastTarget == self.enemyObj:GetGUID() and not IsStanding() and not IsInCombat()) then
				self.newTargetTime = GetTimeEX(); -- reset time if we rest
			-- blacklist the target if we had it for a long time and hp is high
			elseif (((GetTimeEX()-self.newTargetTime)/1000) > self.blacklistTime and self.enemyObj:GetHealthPercentage() > 92) then 
				script_grind:addTargetToBlacklist(self.enemyObj:GetGUID());
				ClearTarget();
				return;
			end
		end

		-- Dont pull mobs before we reached our hotspot
		if (not IsInCombat() and not self.hotspotReached) then
			self.enemyObj = nil;
		end

		-- Dont pull if more than 1 add will be pulled
		if (self.enemyObj ~= nil and self.enemyObj ~= 0 and self.skipHardPull) and (UnitReaction("targetObj", "player") == 2) then
			if (not script_aggro:safePull(self.enemyObj) and not IsInCombat()) then
				script_grind:addTargetToBlacklist(self.enemyObj:GetGUID());
				DEFAULT_CHAT_FRAME:AddMessage('script_grind: Blacklisting ' .. self.enemyObj:GetUnitName() .. ', too many adds...');
				self.enemyObj = nil;
			end
		end

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
				if IsMoving() then StopMoving();
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
			if (self.combatError == 3) and (not localObj:IsMovementDisabed()) then
				self.message = "Moving to target...";
				--if (self.enemyObj:GetDistance() < self.disMountRange) then
				--end

				local _x, _y, _z = self.enemyObj:GetPosition();
				local localObj = GetLocalPlayer();

				if (_x ~= 0 and x ~= 0) then
					local moveBuffer = math.random(-2, 2);
					self.message = script_nav:moveToTarget(localObj, _x+moveBuffer, _y+moveBuffer, _z);
					script_grind:setWaitTimer(80);
					return;
				end
				return;
			end

			-- Do nothing, return : combat script return 4
			if (self.combatError == 4) then
				return;
			end
			
			-- Target player pet/totem: pause for 5 seconds, combat script should add target to blacklist
			if(self.combatError == 5) then
				self.message = "Targeted a player pet pausing 5s...";
				ClearTarget(); self.waitTimer = GetTimeEX()+5000; return;
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
		if (IsLooting() or IsCasting() or IsChanneling() or IsDrinking() or IsEating() or IsInCombat()) then
			script_grind:setWaitTimer(1500);
			return;
		end

		-- Mount before we navigate through the path, error check to get around indoors
		--if (script_grind:mountUp() and self.useMount) then
		--	return;
		--end

		if (IsInCombat()) then
			script_grind:setWaitTimer(1000);	
		end

		-- Use auto pathing or walk paths
		if (self.autoPath) then
			if (script_nav:getDistanceToHotspot() < 10 and not self.hotspotReached) then
				self.message = "Hotspot reached... (No targets around?)";
				self.hotspotReached = true;
				return;
			else
				self.message = script_nav:moveToSavedLocation(localObj, self.minLevel, self.maxLevel, self.staticHotSpot);
				script_grind:setWaitTimer(50);
				if (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) then
					CastSpellByName("Stealth", localObj);
					self.waitTimer = GetTimeEX() + 1200;
				end
			end
		else
			-- Check: Load/Refresh the walk path
			if (self.pathName ~= self.pathLoaded) then
				if (not LoadPath(self.pathName, 0)) then
					self.message = "No walk path has been loaded...";
					return;
				end
				self.pathLoaded = self.pathName;
			end
			-- Navigate
			self.message = script_nav:navigate(localObj);
		end
	end 
end

--function script_grind:mountUp()
--	local __, lastError = GetLastError();
--	if (lastError ~= 75 and self.mountTimer < GetTimeEX() and self.useMount) then
--		if(GetLocalPlayer():GetLevel() >= 40 and not IsSwimming() and not IsIndoors() and not IsMounted()) then
--			self.message = "Mounting...";
--			if (not IsStanding()) then
--				StopMoving();
--			end
--			if (script_helper:useMount() and self.useMount) then
--				self.waitTimer = GetTimeEX() + 8000;
--				return true;
--			end
--		end
--	else
--		ClearLastError();
--		self.mountTimer = GetTimeEX() + 7000;
--		return false;
--	end
--end

function script_grind:getTarget()
	return self.enemyObj;
end

function script_grind:getTargetAttackingUs() 
    local currentObj, typeObj = GetFirstObject(); 
    while currentObj ~= 0 do 
    	if typeObj == 3 then
		if (currentObj:CanAttack() and not currentObj:IsDead()) then
			local localObj = GetLocalPlayer();
			local targetTarget = currentObj:GetUnitsTarget();
			if (targetTarget ~= 0 and targetTarget ~= nil) then
				if (targetTarget:GetGUID() == localObj:GetGUID()) then
					return currentObj:GetGUID();
				end
			end	
                	if (script_grind:isTargetingGroup(currentObj)) then 
                		return currentObj:GetGUID();
                	end 
            	end 
       	end
        currentObj, typeObj = GetNextObject(currentObj); 
    end
    return nil;
end

function script_grind:assignTarget() 
	-- Return a target attacking our group
	local i, targetType = GetFirstObject();
	while i ~= 0 do
		if (script_grind:isTargetingGroup(i)) then
			return i;
		end
		i, targetType = GetNextObject(i);
	end

	-- Instantly return the last target if we attacked it and it's still alive and we are in combat
	if (self.enemyObj ~= 0 and self.enemyObj ~= nil and not self.enemyObj:IsDead() and IsInCombat()) then
		if (script_grind:isTargetingMe(self.enemyObj) 
			or script_grind:isTargetingPet(self.enemyObj) 
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
			if (script_grind:enemyIsValid(i)) then
				-- save the closest mob or mobs attacking us
				if (mobDistance > i:GetDistance()) then
					local _x, _y, _z = i:GetPosition();
					if(not IsNodeBlacklisted(_x, _y, _z, self.nextNavNodeDistance)) then
						mobDistance = i:GetDistance();	
						closestTarget = i;
					end
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

function script_grind:isTargetingPet(i) 
	local pet = GetPet();
	if (pet ~= nil and pet ~= 0 and not pet:IsDead()) then
		if (i:GetUnitsTarget() ~= nil and i:GetUnitsTarget() ~= 0) then
			return i:GetUnitsTarget():GetGUID() == pet:GetGUID();
		end
	end
	return false;
end

function script_grind:isTargetingGroup(y) 
	for i = 1, GetNumPartyMembers() do
		local partyMember = GetPartyMember(i);
		if (partyMember ~= nil and partyMember ~= 0 and not partyMember:IsDead()) then
			if (y:GetUnitsTarget() ~= nil and y:GetUnitsTarget() ~= 0 and not script_grind:isTargetingPet(y)) then
				return y:GetUnitsTarget():GetGUID() == partyMember:GetGUID();
			end
		end
	end

	return false;
end

function script_grind:isTargetingMe(i) 
	local localPlayer = GetLocalPlayer();
	if (localPlayer ~= nil and localPlayer ~= 0 and not localPlayer:IsDead()) then
		if (i:GetUnitsTarget() ~= nil and i:GetUnitsTarget() ~= 0) then
			return i:GetUnitsTarget():GetGUID() == localPlayer:GetGUID();
		end
	end
	return false;
end

function script_grind:enemyIsValid(i)
	if (i ~= 0) then
		-- Valid Targets: Tapped by us, or is attacking us or our pet
		if (script_grind:isTargetingMe(i)
			or (script_grind:isTargetingPet(i) and (i:IsTappedByMe() or not i:IsTapped())) 
			or (script_grind:isTargetingGroup(i) and (i:IsTappedByMe() or not i:IsTapped())) 
			or (i:IsTappedByMe() and not i:IsDead())) then 
				return true; 
		end
		-- Valid Targets: Within pull range, levelrange, not tapped, not skipped etc
		if (not i:IsDead() and i:CanAttack() and not i:IsCritter()
			and ((i:GetLevel() <= self.maxLevel and i:GetLevel() >= self.minLevel))
			and i:GetDistance() < self.pullDistance and (not i:IsTapped() or i:IsTappedByMe())
			and (not script_grind:isTargetBlacklisted(i:GetGUID()) and not script_grind:isTargetingMe(i)) 
			and not (self.skipHumanoid and i:GetCreatureType() == 'Humanoid')
			and not (self.skipDemon and i:GetCreatureType() == 'Demon')
			and not (self.skipBeast and i:GetCreatureType() == 'Beast')
			and not (self.skipElemental and i:GetCreatureType() == 'Elemental')
			and not (self.skipUndead and i:GetCreatureType() == 'Undead') 
			and not (skipAberration and i:GetCreatureType() == 'Abberration') 
			and not (skipDragonkin and i:GetCreatureType() == 'Dragonkin') 
			and not (skipGiant and i:GetCreatureType() == 'Giant') 
			and not (skipMechanical and i:GetCreatureType() == 'Mechanical') 
			and not (self.skipElites and (i:GetClassification() == 1 or i:GetClassification() == 2))
			) then
			return true;
		end
	end
	return false;
end

function script_grind:enemiesAttackingUs() -- returns number of enemies attacking us
	local unitsAttackingUs = 0; 
	local currentObj, typeObj = GetFirstObject(); 
	while currentObj ~= 0 do 
    	if typeObj == 3 then
		if (currentObj:CanAttack() and not currentObj:IsDead()) then
                	if (script_grind:isTargetingMe(currentObj) or script_grind:isTargetingPet(currentObj)) then 
                		unitsAttackingUs = unitsAttackingUs + 1; 
                	end 
            	end 
       	end
        currentObj, typeObj = GetNextObject(currentObj); 
    end
    return unitsAttackingUs;
end

function script_grind:playersTargetingUs() -- returns number of players attacking us
	local nrPlayersTargetingUs = 0; 
	local currentObj, typeObj = GetFirstObject(); 
	while currentObj ~= 0 do 
		if typeObj == 4 then
			if (script_grind:isTargetingMe(currentObj)) then 
                	nrPlayersTargetingUs = nrPlayersTargetingUs + 1;
				if (self.useOtherString) then
					local playerDistance = currentObj:GetDistance();
					local playerName = currentObj:GetUnitName();
					local playerTime = GetTimeStamp();
					local string ="" ..playerTime.. " - Player Name ("..playerName.. ") - Distance(yds) "..playerDistance.. " - Targeted Us! - added to log file for further implementation of paranoia."
					DEFAULT_CHAT_FRAME:AddMessage(string);
					ToFile(string);
					self.useOtherString = false;
				end
			end 
		end
		currentObj, typeObj = GetNextObject(currentObj); 
	end
	self.useOtherString = true;
	return nrPlayersTargetingUs;
end

function script_grind:playersWithinRange(range)
	local currentObj, typeObj = GetFirstObject(); 
	while currentObj ~= 0 do 
		if (typeObj == 4 and not currentObj:IsDead()) then
			if (currentObj:GetDistance() < range) then 
				local localObj = GetLocalPlayer();
				if (localObj:GetGUID() ~= currentObj:GetGUID()) and (currentObj:GetUnitName() ~= script_paranoia.ignoreTarget) then
					if (self.useString) then
						if (currentObj:GetDistance() < self.paranoidRange) and (typeObj == 4) then
							local playerName = currentObj:GetUnitName();
							local playerDistance = currentObj:GetDistance();
							local playerTime = GetTimeStamp();
							local string ="" ..playerTime.. " - Player Name ("..playerName.. ") - Distance (yds) "..playerDistance.. " - added to log file for further implementation of paranoia."
							DEFAULT_CHAT_FRAME:AddMessage(string);
							ToFile(string);
							self.useString = false;
						end
				
					end
				return true;
				end
			end 
		end
		currentObj, typeObj = GetNextObject(currentObj); 
	end
	self.useString = true;
	return false;
end

function script_grind:getDistanceDif()
	local x, y, z = GetLocalPlayer():GetPosition();
	local xV, yV, zV = self.myX-x, self.myY-y, self.myZ-z;
	return math.sqrt(xV^2 + yV^2 + zV^2);
end

function script_grind:drawStatus()
	if (self.drawAggro) then
		script_aggro:drawAggroCircles(45);
	end
	if (self.autoPath and self.drawAutoPath) then
		script_nav:drawSavedTargetLocations();
	end
	if (self.drawGather) then
		script_gather:drawGatherNodes();
	end
	if (self.drawPath) then
		if (IsMoving()) then
			script_nav:drawPath();
		end
	end
	if (self.drawUnits) then
		script_nav:drawUnitsDataOnScreen();
	end
	if (not self.drawEnabled and self.showClassOptions) then
		RunCombatDraw();
	end
	if (not self.drawEnabled) then
		return;
	end

	-- color
	local r, g, b = 0, 0, 0;

	-- position
	local y, x, width = 120, 25, 370;
	local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
	if (onScreen) then
		y, x = tY-25, tX+75;
	end

	-- info
	if (not self.pause) then

	--DrawRect(x - 10, y - 7, x + width, y + 140, 255, 255, 0, 10, 77, 0);
	--DrawRectFilled(x - 10, y - 7, x + width, y + 140, 0, 0, 0, 80, 10, 77);
	DrawText('Grinder - Pull range: ' .. math.floor(self.pullDistance) .. ' yd. ' .. 
			 	'Level range: ' .. self.minLevel .. '-' .. self.maxLevel, x, y-4, r+255, g+255, b+0) y = y + 15;
	
	DrawText('Grinder status: ', x, y, r+255, g+255, b+0); y = y + 15;
	DrawText(self.message or "error", x, y, 255, 255, 255);
	y = y + 20; DrawText('Combat script status: ', x, y, r+255, g+255, b+0); y = y + 15;
	if (self.showClassOptions) then RunCombatDraw(); end
	 y = y + 20;
	--if (self.autoPath) then 
	--	DrawText('Auto path: ON! Hotspot: ' .. script_nav:getHotSpotName(), x, y, 255, 255, 205); y = y + 20;
	--else
	--	DrawText('Auto path: OFF!', x, y, 255, 255, 205); y = y + 20;
	--end

	if (script_grind.useVendor) then
		DrawText('Vendor - ' .. script_vendorMenu:getInfo(), x, y, r+255, g+255, b+0); y = y + 15;
		DrawText('Vendor Status: ', x, y, r+255, g+255, b+0);
		DrawText(script_vendor:getMessage(), x+105, y, 0, 255, 255);
	end

	local time = ((GetTimeEX()-self.newTargetTime)/1000); 

	if (self.enemyObj ~= 0 and self.enemyObj ~= nil and not self.enemyObj:IsDead()) then
		--DrawRect(x - 10, y + 19, x + width, y + 45, 255, 255, 0,  1, 1, 1);
		--DrawRectFilled(x-10, y+20, x + width, y + 45, 0, 0, 0, 100, 0, 0);
		DrawText('Blacklist-timer: ' .. self.enemyObj:GetUnitName() .. ': ' .. time .. ' s.', x, y+20, 0, 255, 120); 
		DrawText('Blacklisting target after ' .. self.blacklistTime .. " s. (If above 92% HP.)", x, y+35, 0, 255, 120);
	end
	else
		DrawText('Grinder paused by user...', x-5, y-4, r+255, g+122, b+122);
	end
end

function script_grind:draw()
	script_grind:drawStatus();
end

function script_grind:doLoot(localObj)
	local _x, _y, _z = self.lootObj:GetPosition();
	local dist = self.lootObj:GetDistance();
	local localObj = GetLocalPlayer();
	
	-- Loot checking/reset target
	if (GetTimeEX() > self.lootCheck['timer']) then
		if (self.lootCheck['target'] == self.lootObj:GetGUID()) then
			self.lootObj = nil; -- reset lootObj
			ClearTarget();
			self.message = 'Reseting loot target...';
		end
		self.lootCheck['timer'] = GetTimeEX() + 10000; -- 10 sec
		if (self.lootObj ~= nil) then 
			self.lootCheck['target'] = self.lootObj:GetGUID();
		else
			self.lootCheck['target'] = 0;
		end
		return;
	end

	if(dist <= self.lootDistance) then
		self.message = "Looting...";
		if(IsMoving() and not localObj:IsMovementDisabed()) then
			StopMoving();
			return;
		end
		if(not IsStanding()) then
			StopMoving();
			self.waitTimer = GetTimeEX() + 550;
			return;
		end

		-- Dismount
		if (IsMounted()) then
			DisMount();
			self.waitTimer = GetTimeEX() + 450;
			return;
		end

		if(not self.lootObj:UnitInteract() and not IsLooting()) then
			self.waitTimer = GetTimeEX() + 1050;
			return;
		end
	
		if (not LootTarget()) then
			script_grind:setWaitTimer(1200);
			return;
		else
			self.waitTimer = GetTimeEX() + 500;
			self.lootCheckTime = 0;
			self.lootObj = nil;
			return;
		end

		-- If we reached the loot object, reset the nav path
		script_nav:resetNavigate();
		self.waitTimer = GetTimeEX() + 550;
		
	end

	-- Blacklist loot target if swimming or we are close to aggro blacklisted targets and not close to loot target
	if (self.lootObj ~= nil) then
		if (IsSwimming()) and (not script_grindEX.allowSwim) and (script_aggro:closeToBlacklistedTargets() and self.lootObj:GetDistance() > 5) then
			script_grind:addTargetToBlacklist(self.lootObj:GetGUID());
			DEFAULT_CHAT_FRAME:AddMessage('script_grind: Blacklisting loot target to avoid aggro/swimming...');
			return;
		end
	end
	self.message = "Moving to loot...";		
	script_nav:moveToTarget(localObj, _x, _y, _z);	
	--script_grind:setWaitTimer(300);

	if (self.lootObj:GetDistance() < 3) then
		self.waitTimer = GetTimeEX() + 750;
	end
		
end

function script_grind:getSkinTarget(lootRadius)
	local targetObj, targetType = GetFirstObject();
	local bestDist = lootRadius;
	local bestTarget = nil;
	while targetObj ~= 0 do
		if (targetType == 3) then -- Unit
			if(targetObj:IsDead()) then
				if (targetObj:IsSkinnable() and targetObj:IsTappedByMe() and not targetObj:IsLootable()) then
					local dist = targetObj:GetDistance();
					if(dist < lootRadius and bestDist > dist) then
						bestDist = dist;
						bestTarget = targetObj;
					end
				end
			end
		end
		targetObj, targetType = GetNextObject(targetObj);
	end
	return bestTarget;
end

function script_grind:lootAndSkin()
	-- Loot if there is anything lootable and we are not in combat and if our bags aren't full
	if (not self.skipLooting and not AreBagsFull() and not self.bagsFull) then 
		self.lootObj = script_nav:getLootTarget(self.findLootDistance);
	else
		self.lootObj = nil;
	end
	if (self.lootObj == 0) then
		self.lootObj = nil;
	end
	if (self.lootObj ~= nil) then
		if (script_grind:isTargetBlacklisted(self.lootObj:GetGUID()) and self.lootObj:GetDistance() > 5) then
			self.lootObj = nil; -- don't loot blacklisted targets	
		end
	end
	local isLoot = not IsInCombat() and not (self.lootObj == nil);
	if (isLoot and not AreBagsFull() and not self.bagsFull) and (not IsEating() or not IsDrinking()) then
		script_grind:doLoot(localObj);
		
		return true;
	elseif ((self.bagsFull or AreBagsFull()) and not hsWhenFull) then
		self.lootObj = nil;
		self.message = "Warning the bags are full...";
		return false;
	end
	-- Skin if there is anything skinnable within the loot radius
	if (HasSpell('Skinning') and self.skinning and HasItem('Skinning Knife')) then
		self.lootObj = nil;
		self.lootObj = script_grind:getSkinTarget(self.findLootDistance);
		if (not AreBagsFull() and not self.bagsFull and self.lootObj ~= nil) then
			script_grind:doLoot(localObj);
			self.waitTimer = GetTimeEX() + 1200;
			return;
		end
	end
	return false;
end

function script_grind:runRest()
	if(RunRestScript()) then
		self.message = "Resting...";
		self.newTargetTime = GetTimeEX();

		-- Stop moving
		if (IsMoving()) and (not localObj:IsMovementDisabed()) then
			StopMoving();
			return true;
		end

		-- Dismount
		if (IsMounted()) then
			DisMount();
			return true;
		end

		-- Add 2500 ms timer to the rest script rotations (timer could be set already)
		if ((self.waitTimer - GetTimeEX()) < 2500) then
			self.waitTimer = GetTimeEX() + 2500;
		end
	return true;	
	end

return false;
end