script_grind = {
	navFunctionsLoaded = include("scripts\\script_nav.lua"),
	helperLoaded = include("scripts\\script_helper.lua"),
	talentLoaded = include("scripts\\script_talent.lua"),
	vendorLoaded = include("scripts\\script_vendor.lua"),
	gatherLoaded = include("scripts\\script_gather.lua"),
	grindExtra = include("scripts\\script_grindEX.lua"),
	extraFunctionsLoaded = include("scripts\\script_extraFunctions.lua"),
	grindMenu = include("scripts\\script_grindMenu.lua"),
	aggroLoaded = include("scripts\\script_aggro.lua"),
	expExtra = include("scripts\\script_expChecker.lua"),
	unstuckLoaded = include("scripts\\script_unstuck.lua"),
	paranoiaLoaded = include("scripts\\script_paranoia.lua"),
	paranoiaMenuLoaded = include("scripts\\script_paranoiaMenu.lua"),
	radarLoaded = include("scripts\\script_radar.lua"),
	debuffCheck = include("scripts\\script_checkDebuffs.lua"),
	drawStatusScript = include("scripts\\script_drawStatus.lua"),
	jump = true,	-- enable jumping out of combat
	jumpRandomFloat = 96,	-- jump > than 
	useVendor = false,	-- use vendor
	repairWhenYellow = false,	-- repair when yellow
	stopWhenFull = false,	-- stop when bags are full
	hsWhenFull = false,	-- hearthstone when bags are full
	useMount = false,	-- use mount
	disMountRange = 32,	-- defunct setting
	mountTimer = GetTimeEX(),	-- defunct setting
	enemyObj = nil,	-- enemyObj stops a bug
	lootObj = nil,	-- lootObj stops a bug
	timer = GetTimeEX(),	-- blacklist timer
	tickRate = 100,		-- reaction time / speed of scripts
	waitTimer = GetTimeEX(),	-- wait timer
	pullDistance = 225,	-- find target distance
	avoidElite = true,	-- avoid elites ( currently not working )
	avoidRange = 40,	-- aboid elites range
	findLootDistance = 45,
	lootDistance = 3.1,
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
	skipUnknown = false, -- skip not specified npc - ooze, etc
	skipHumanoid = false,
	skipElemental = false,
	skipUndead = false,
	skipDemon = false,
	skipBeast = false,
	skipAberration = false,
	skipDragonkin = false,
	skipGiant = false,
	skipMechanical = false,	
	skipElites = true,	-- skip elites (currently disabled)
	paranoidRange = 75,	-- paranoia range
	nextToNodeDist = 4.4, -- (Set to about half your nav smoothness)
	blacklistedTargets = {},	-- GUID table of blacklisted targets
	blacklistedNum = 0,	-- number of blacklisted targets
	isSetup = false,	-- is setup function run
	drawUnits = true,	-- draw unit data on screen
	Name = "", -- set to e.g. "paths\1-5 Durator.xml" for auto load at startup
	pathLoaded = "",	-- path that is loaded
	drawPath = false,	-- draw path
	autoPath = true,	-- use nav 
	drawAutoPath = true,	-- draw walk path
	distToHotSpot = 500,	-- distance to target enemies from hotspot
	staticHotSpot = true,	-- use hotspots
	hotSpotTimer = GetTimeEX(),	-- timer to hotspot
	currentLevel = GetLocalPlayer():GetLevel(),	-- current player level
	skinning = false,	-- use skinning
	gather = false,		-- use gatherer script
	lastTarget = 0,		-- last target targeted
	newTargetTime = GetTimeEX(),	-- set new target wait time
	blacklistTime = 45,	-- time to blacklist mobs
	drawEnabled = true,	-- draw on screen menus
	showClassOptions = true,	-- setup function to show menu
	pause = true,		-- pause script
	bagsFull = false,	-- are bags full
	vendorRefill = false,	-- refill at vendor
	useMana = true,		-- does player use mana
	drawGather = false,	-- draw gather nodes
	hotspotReached = false,	-- is hotspot reached
	drawAggro = false,	-- draw aggro range circles
	safeRess = true,	-- ressurect in safe area
	skipHardPull = true,	-- skip adds
	useUnstuck = true,	-- use unstuck script
	blacklistAdds = 1,	-- blacklist targets when there are x adds
	blacklistedNameNum = 0,	-- number of blacklisted targets
	useExpChecker = true,	-- run exp checker
	paranoidSetTimer = 22,	-- time to wait after paranoia has needed
	useString = true,	-- message to send to log players in range run once
	useOtherString = true,	-- message to send to log players targeting us run once
	useLogoutTimer = false,	-- use logout timer true/false
	logoutSetTime = GetTimeEX() / 1000,	-- set the logout time in seconds
	logoutTime = 2,	-- logout time in hours
	adjustTickRate = false,	-- adjust script tick rate
	lootCheckTime = 0,	-- loot check time
	afkActionSlot = "24",	-- /afk slot for paranoia
	playerParanoidDistance = 0,	-- paranoid player check their distance
	adjustText = true,	-- adjust info box
	adjustY = 0,	-- adjust info box
	adjustX = 0,	-- adjust info box
	paranoidTarget = "",	-- name of paranoid players
	currentTime2 = GetTimeEX() / 1000,	-- paranoia logout timer
	setParanoidTimer = 213,		-- time added to paranoid logout timer
	playerName = "",	-- paranoid player name
	otherName = player,	-- paranoid player name
	playerPos = 0,	-- paranoid player pos
	blacklistLootTime = GetTimeEX() + 25000,	-- blacklist loot time
	timerSet = false,	-- blacklist loot timer set
	messageOnce = true,	-- message once blacklist loot obj
	perHasTarget = false,	-- used to check pet target during rest
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

	-- don't refill water or food on start of bot
	if (GetLocalPlayer():GetLevel() < 3) then
		self.vendorRefill = false;
	end

	-- don't skip hard pulls when we are at starter zones
	if (GetLocalPlayer():GetLevel() < 8) then
		self.skipHardPull = false;
	end

	-- enable drawing unit info on screen
	self.drawEnabled = true;
	
	-- setup helper script
	script_helper:setup();
	
	-- setup talent script
	script_talent:setup();

	-- setup vendor script
	script_vendor:setup();

	-- setup gather script
	script_gather:setup();

	-- vendor database script loaded
	vendorDB:setup();

	-- hotspot database script loaded
	hotspotDB:setup();

	-- auto load sell vendors
	vendorDB:loadDBVendors();

	-- navigation script loaded
	script_nav:setup();

	-- we are setup don't reload these items here
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

	-- change some values to random
	local randomLogout = math.random(30, 65);
	self.setParanoidTimer = randomLogout;

	local randomHotspot = math.random(550, 1000);
	self.distToHotSpot = randomHotspot;

	local randomSetTimer = math.random(3, 10);
	self.paranoidSetTimer = randomSetTimer;

	local randomRange = math.random(50, 90);
	self.paranoidRange = randomRange;

	-- add chat frame message grinder is loaded
	DEFAULT_CHAT_FRAME:AddMessage('script_grind: loaded...');
		
end

-- draw grinder window
function script_grind:window()
	EndWindow();
	if(NewWindow("Grinder", 320, 300)) then
		script_grindMenu:menu();
	end
end

-- set timer for grind script to run
function script_grind:setWaitTimer(ms)
	self.waitTimer = (GetTimeEX() + (ms));
end

-- add target to blacklist table by GUID
function script_grind:addTargetToBlacklist(targetGUID)
	if (targetGUID ~= nil and targetGUID ~= 0 and targetGUID ~= '') then	
		self.blacklistedTargets[self.blacklistedNum] = targetGUID;
		self.blacklistedNum = self.blacklistedNum + 1;
	end
end

-- check if target is blacklisted by table GUID
function script_grind:isTargetBlacklisted(targetGUID) 
	for i=0,self.blacklistedNum do
		if (targetGUID == self.blacklistedTargets[i]) then
			return true;
		end
	end
	return false;
end


-- run grinder
function script_grind:run()
	-- show grinder window
	script_grind:window();
	
	-- display radar
	if (script_radar.showRadar) then
		script_radar:draw()
	end

	-- display exp checker
	if (self.useExpChecker) and (IsInCombat()) then
		script_expChecker:menu();
	end

	-- logout timer
	if (self.useLogoutTimer) then

		-- set logout time
		local currentTime = GetTimeEX() / 1000;

		-- logout when timer is set
		if (currentTime >= self.logoutSetTime + self.logoutTime * 3600) then
			Exit();
		end
	end

	-- if bags full then set true
	if (AreBagsFull()) then
		self.bagsFull = true;
	end

	 -- Set next to node distance and nav-mesh smoothness to double that number
	if (IsMounted()) then
		script_nav:setNextToNodeDist(12); NavmeshSmooth(24);
	else
		-- else set to preset variable
		script_nav:setNextToNodeDist(self.nextToNodeDist); NavmeshSmooth(self.nextToNodeDist*2.5);
	end

		localObj = GetLocalPlayer();
	-- sprint or dash or aspect or cheetah or cat form
	if (localObj:HasBuff("Sprint")) or (localObj:HasBuff("Aspect of the Cheetah")) or (localObj:HasBuff("Dash")) or (localObj:HasBuff("Cat Form")) then
		script_nav:setNextToNodeDist(8); NavmeshSmooth(24);
	else
		-- else set to preset variable
		script_nav:setNextToNodeDist(self.nextToNodeDist); NavmeshSmooth(self.nextToNodeDist*3);
	end

	-- night elf whisp
		local race = UnitRace('player');
	if (race == 'Night Elf') and (localObj:IsDead()) then
		script_nav:setNextToNodeDist(6);
		NavmeshSmooth(18);
	else
		-- else set to preset variable
		script_nav:setNextToNodeDist(self.nextToNodeDist);
		NavmeshSmooth(self.nextToNodeDist*4);
	end
	
	-- player is dead
	if (localObj:IsDead() or IsGhost()) then
		script_nav:setNextToNodeDist(4);
		NavmeshSmooth(14);
		self.tickRate = 100;
	else
		-- else set to preset variable
		script_nav:setNextToNodeDist(self.nextToNodeDist);
		NavmeshSmooth(self.nextToNodeDist*4);
	end
	
	-- run setup function if not ran yet
	if (not self.isSetup) then
		script_grind:setup();
	end

	--check nav function loaded
	if (not self.navFunctionsLoaded) then
		self.message = "Error script_nav not loaded...";
		return;
	end

	-- check if helper is loaded
	if (not self.helperLoaded) then
		self.message = "Error script_helper not loaded...";
		return;
	end

	-- use unstuck feature ----and (not self.pause) 
	if (self.useUnstuck and IsMoving()) and (not self.pause) then
		if (not script_unstuck:pathClearAuto(2)) then
			script_unstuck:unstuck();
			return true;
		end
	end

	-- pause bot
	if (self.pause) then self.message = "Paused by user...";
		-- set paranoid used to off to reset paranoia
		script_paranoia.paranoiaUsed = false;
		--reset new target time for blacklisting
		script_grind.newTargetTime = GetTimeEX();
		return;
	end

	-- Check: Spend talent points
	if (not IsInCombat() and not GetLocalPlayer():IsDead() and self.autoTalent) then
		if (script_talent:learnTalents()) then
			self.message = "Checking/learning talent: " .. script_talent:getNextTalentName();
			return;
		end
	end

	-- delete items
	if (script_helper:deleteItem()) then
		self.waitTimer = GetTimeEX() + 1500;
		return;
	end

	-- check paranoia	
		-- jump when player in range in combat
	if (IsInCombat() and not script_grind.undoAFK) then
		if (script_paranoiaCheck:playersWithinRange2(60) and script_grind.playersTargetingUs() >= 1) 
			or (script_paranoiaCheck:playersWithinRange2(38)) then
			if (not IsCasting()) and (not IsChanneling()) then
				local moreJumping = math.random(0, 701);
				if (moreJumping >= 700) then
					JumpOrAscendStart();
					
				end
			end
		end
	end
	-- do paranoia
	if (not IsLooting()) and (not IsInCombat()) and (not IsMounted()) and (not IsCasting()) and (not IsChanneling()) then	
				-- set paranoid used as true
		if (script_paranoia:checkParanoia()) and (not self.pause) then
				script_paranoia.paranoiaUsed = true;
				script_grind:setWaitTimer(2750);
			
			-- if player is within distance <= 30 then do this
			if (script_grind.playerParanoidDistance <= 30) and (script_grind:playersTargetingUs() >= 1) and (not IsInCombat()) then
				-- target player targeting us
				if (GetLocalPlayer():GetUnitsTarget() == 0) then	
					TargetByName(script_grind.playerName);
				end
			end

			-- try to target player if they are attacking you
			if (IsInCombat()) and (script_grind.playerParanoidDistance <= 8) then
				local pX, pY, pZ = script_grind.playerPos;
				FacePosition(pX, pY, pZ);
			return;
			end
	
			-- logout timer reached then logout
			if (script_paranoia.currentTime >= script_grind.currentTime2 + script_grind.setParanoidTimer) then
					-- reset paranoia timer
				script_paranoia.currentTime = GetTimeEX() + (45*1000);
				StopBot();
				Logout();
				return 4;
			end

			-- do stealth
			if (not IsMounted()) then
				script_paranoiaEX:checkStealth();
			end

			-- set timer to stop after paranoid player leaves
			self.waitTimer = GetTimeEX() + (self.paranoidSetTimer * 1000) + 2000;
		return true;

			-- else reset all conditions
		else
			script_paranoia.currentTime = 0;
			script_grind.currentTime2 = GetTimeEX() / 1000;
			script_paranoia.paranoiaUsed = false;
			script_paranoia.doEmote = true;
			script_paranoia.didEmote = false;
		end
	end

	-- undo /afk when pressed during paranoid and sitting
	if (self.undoAFK) and (IsStanding()) and (not localObj:IsDead()) and (localHealth >= 85) then
		UseAction(script_grind.afkActionSlot, 0, 0);
		self.waitTimer = GetTimeEX() + 2500;
		script_grind:setWaitTimer(2500);
		script_grind.undoAFK = false;
		return true;
	end

	-- delete items 
	if (script_helper:deleteItem()) then
		return;
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

		--Mount up
		if (not self.hotspotReached or script_vendor:getStatus() >= 1) and (not IsInCombat())
		and (not IsMounted()) and (not IsIndoors()) and (not localObj:HasBuff("Cat Form"))
		and (not localObj:HasBuff("Bear Form")) and (not localObj:HasBuff("Travel Form"))
		and (not localObj:HasBuff("Dire Bear Form")) and (not localObj:HasBuff("Moonkin Form"))
		and (script_grind.useMount)
		then
			if (IsMoving()) then
				StopMoving();
				return true;
			end
			if (not IsIndoors()) then
				if (script_helper:mountUp()) then
					script_grind:setWaitTimer(4500);
				end
			return true;
			end
		end
		
		-- Gather
		if (self.gather and not IsInCombat() and not AreBagsFull() and not self.bagsFull) then
			if (script_gather:gather()) then
				script_grind.tickRate = 100;
				self.message = 'Gathering ' .. script_gather:currentGatherName() .. '...';
				return;
			end
		end

		-- hotspot reached distance
		if (script_nav:getDistanceToHotspot() <= 45) then
			self.hotspotReached = true;
		end

		-- Auto path: keep us inside the distance to the current hotspot, if mounted keep running even if in combat
		if ((not IsInCombat() or IsMounted()) and (self.autoPath) and (script_vendor:getStatus() == 0) and
			(script_nav:getDistanceToHotspot() > self.distToHotSpot or self.hotSpotTimer > GetTimeEX())) then
			if (not (self.hotSpotTimer > GetTimeEX())) then
				self.hotSpotTimer = GetTimeEX() + 20000;
			end

			--Mount up
			if (not self.hotspotReached or script_vendor:getStatus() >= 1) and (not IsInCombat())
			and (not IsMounted()) and (not IsIndoors()) and (not localObj:HasBuff("Cat Form"))
			and (not localObj:HasBuff("Bear Form")) and (not localObj:HasBuff("Travel Form"))
			and (not localObj:HasBuff("Dire Bear Form")) and (not localObj:HasBuff("Moonkin Form"))
			and (script_grind.useMount)
			then
				if (IsMoving()) then
					StopMoving();
					return true;
				end
				if (not IsIndoors()) then
					if (script_helper:mountUp()) then
						script_grind:setWaitTimer(4500);
						self.waitTimer = GetTimeEX() + 4500;
					end
				end
			end

			-- Druid travel form
			if (not IsMounted()) and (not script_paranoia:checkParanoia()) and (not IsSwimming()) and (not script_grind.useMount) then
				if (script_druidEX:travelForm()) then
					self.waitTimer = GetTimeEX() + 1000;
				end
			end

			-- druid cat form
			if (not IsMounted()) and (not HasSpell("Travel Form")) and (HasSpell("Cat Form")) and (not localObj:HasBuff("Cat Form")) and (not localObj:IsDead()) and (GetLocalPlayer():GetHealthPercentage() >= 95) then
				if (CastSpellByName("Cat Form")) then
					self.waitTimer = GetTimeEX() + 500;
					return 0;
				end
			end

			-- rogue stealth
			if (not IsMounted()) and (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (not localObj:IsDead()) and (GetLocalPlayer():GetHealthPercentage() >= 95) and (not script_checkDebuffs:hasPoison()) then
				if (CastSpellByName("Stealth", localObj)) then
					self.waitTimer = GetTimeEX() + 1200;
					return 0;
				end
			end

			-- Shaman Ghost Wolf 
			if (not IsMounted()) and (not script_grind.useMount) and (HasSpell('Ghost Wolf')) and (not localObj:HasBuff('Ghost Wolf')) and (not localObj:IsDead()) then
					CastSpellByName('Ghost Wolf');
					self.waitTimer = GetTimeEX() + 1500;
					script_grind:setWaitTimer(1500);
					return;
				
			end

		-- move to hotspot location
		self.message = script_nav:moveToHotspot(localObj);
		script_grind:setWaitTimer(65);
		return;
		end
		
		-- Assign the next valid target to be killed within the pull range
		if (self.enemyObj ~= 0 and self.enemyObj ~= nil) and self.lootObj == nil then
			self.waitTimer = GetTimeEX() + 200;
			self.lastTarget = self.enemyObj:GetGUID();
		end

		-- get target
		self.enemyObj = script_grind:assignTarget();

		-- use kills to level tracker
		if (self.useExpChecker) then
			script_expChecker:targetLevels();
		end

		-- blacklist target time
		if (self.enemyObj ~= 0 and self.enemyObj ~= nil) then
			-- Fix bug, when not targeting correctly
			if (self.lastTarget ~= self.enemyObj:GetGUID()) then
				self.newTargetTime = GetTimeEX() + 500;
				ClearTarget();
			elseif (self.lastTarget == self.enemyObj:GetGUID() and not IsStanding() and not IsInCombat()) then
				self.blaclistLootTime = GetTimeEX();
				self.newTargetTime = GetTimeEX(); -- reset time if we rest
			-- blacklist the target if we had it for a long time and hp is high
			elseif (((GetTimeEX()-self.newTargetTime)/1000) > self.blacklistTime and self.enemyObj:GetHealthPercentage() > 92 and not self.enemyObj:IsInLineOfSight()) then 
				script_grind:addTargetToBlacklist(self.enemyObj:GetGUID());
				ClearTarget();
				return;
			end
		end

		-- distance to hotspot
		if (script_nav:getDistanceToHotspot() <= 45) then
			self.hotspotReached = true;
		end

		-- Dont pull mobs before we reached our hotspot
		if (not IsInCombat() and not self.hotspotReached) then
			self.enemyObj = nil;
		end

		-- Dont pull if more than 1 add will be pulled
		if (self.enemyObj ~= nil and self.enemyObj ~= 0 and self.skipHardPull) then
			if (not script_aggro:safePull(self.enemyObj)) and (not IsInCombat())
			and (not script_grind:isTargetingMe(self.enemyObj)) then
				script_grind:addTargetToBlacklist(self.enemyObj:GetGUID());
				DEFAULT_CHAT_FRAME:AddMessage('script_grind: Blacklisting ' .. self.enemyObj:GetUnitName() .. ', too many adds... change blacklist options in "Target Menu"');
				self.enemyObj = nil;
			end
		end

		-- Finish loot before we engage new targets or navigate
		if (self.lootObj ~= nil and not IsInCombat()) then

			return; 
		else
			-- blacklist loot message
			self.messageOnce = true;
			-- blacklist loot timer
			self.timerSet = false;
			-- reset the combat status
			self.combatError = nil; 
			-- Run the combat script and retrieve combat script status if we have a valid target

			if (self.enemyObj ~= nil and self.enemyObj ~= 0) then
				self.combatError = RunCombatScript(self.enemyObj:GetGUID());
			end
		end

		if (self.enemyObj ~= nil or IsInCombat()) then

			if (self.enemyObj ~= nil) then
				if (self.enemyObj:GetDistance() <= 8) and (not IsMoving()) then
					self.enemyObj:FaceTarget();
				end
			else
				script_grind:assignTarget();
			end

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
				script_grind.addTargetToBlacklist(self.enemyObj:GetGUID());
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

				script_grind.tickRate = 0;

				if (_x ~= 0 and x ~= 0) then
					local moveBuffer = math.random(-3, 3);
					self.message = script_navEX:moveToTarget(localObj, _x+moveBuffer, _y+moveBuffer, _z);
					script_grind:setWaitTimer(110);
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
				ClearTarget(); self.waitTimer = GetTimeEX()+15000; return;
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
		if (script_grind.useMount) and (not IsMounted()) then
			if (script_druidEX:removeCatForm()) or (script_druidEX:removeBearForm())
			or (script_druidEX:removeTravelForm()) or (script_druidEX:removeMoonkinForm()) then
				return;
			end
		end

		--Mount up
		if (not self.hotspotReached or script_vendor:getStatus() >= 1) and (not IsInCombat())
		and (not IsMounted()) and (not IsIndoors()) and (not localObj:HasBuff("Cat Form"))
		and (not localObj:HasBuff("Bear Form")) and (not localObj:HasBuff("Travel Form"))
		and (not localObj:HasBuff("Dire Bear Form")) and (not localObj:HasBuff("Moonkin Form")) and (self.useMount) then
			if (IsMoving()) then
				StopMoving();
				return true;
			end
			if (not IsIndoors()) then
				if (script_helper:mountUp()) then
					script_grind:setWaitTimer(4500);
				end
			return true;
			end
		end

		-- travel forms
		if (not self.hotspotReached or script_vendor:getStatus() >= 1) and (not IsInCombat())
		and (not IsMounted()) and (not IsIndoors()) and (not localObj:HasBuff("Cat Form"))
		and (not localObj:HasBuff("Bear Form")) and (not localObj:HasBuff("Travel Form"))
		and (not localObj:HasBuff("Dire Bear Form")) and (not localObj:HasBuff("Moonkin Form")) and (not localObj:HasBuff("Ghost Wolf")) then
			if (HasSpell("Ghost Wolf")) or (HasSpell("Travel Form")) or (self.useMount) then
				if (IsMoving()) then
					StopMoving();
					return true;
				end
				if (HasSpell("Travel Form")) then
					if (script_druidEX:travelForm()) then
						script_grind:setWaitTimer(2500);
					end
				return true;
				end
				if (HasSpell("Ghost Wolf")) then
					if (script_shamanEX2:ghostWolf()) then
						script_grind:setWaitTimer(4000);
					end
				return true;
				end
			end
		end

		-- Use auto pathing or walk paths
		if (self.autoPath) then
			if (script_nav:getDistanceToHotspot() < 20 and not self.hotspotReached) then
				self.message = "Hotspot reached... (No targets around?)";
				self.hotspotReached = true;
				return;
			else
				self.message = script_nav:moveToSavedLocation(localObj, self.minLevel, self.maxLevel, self.staticHotSpot);
				script_grind:setWaitTimer(85);

				if (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (not localObj:IsDead()) and (GetLocalPlayer():GetHealthPercentage() >= 95) and (script_grind.lootObj == nil or script_grind.lootObj == 0) then
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
			script_grind.tickRate = 50;
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
		-- blacklisted target is attacking us
		if (script_grind:isTargetBlacklisted(i:GetGUID())) and (script_grind:isTargetingMe(i))
		and (i:IsInLineOfSight()) then
			return true;
		end
		-- blacklisted target is polymorphed or feared
		if (script_grind:isTargetBlacklisted(i:GetGUID())) and (i:HasDebuff("Polymorph") or i:HasDebuff("Fear")) then
			return true;
		end
		--attacking pet
		if (script_grind:isTargetingPet(i)) and (i:IsInLineOfSight()) then
			return true;
		end

		-- Valid Targets: Within pull range, levelrange, not tapped, not skipped etc
		if (self.skipHardPull) then
			if (not script_aggro:safePull(i)) and (not script_grind:isTargetBlacklisted(i:GetGUID()))
			and (not script_grind:isTargetingMe(i)) then
			local myTime = GetTimeStamp();
			script_grind:addTargetToBlacklist(i:GetGUID());
			DEFAULT_CHAT_FRAME:AddMessage('' ..myTime.. ': Blacklisting "' .. i:GetUnitName() .. '", too many adds...');
			end

			if (not i:IsDead() and i:CanAttack() and not i:IsCritter()
			and ((i:GetLevel() <= self.maxLevel and i:GetLevel() >= self.minLevel))
			and i:GetDistance() < self.pullDistance and (not i:IsTapped() or i:IsTappedByMe())
			and (not script_grind:isTargetBlacklisted(i:GetGUID()))
			and not (self.skipUnknown and i:GetCreatureType() == 'Not specified')
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

		elseif (not self.skipHardPull) then	
			if (not i:IsDead() and i:CanAttack() and not i:IsCritter()
			and ((i:GetLevel() <= self.maxLevel and i:GetLevel() >= self.minLevel))
			and i:GetDistance() < self.pullDistance and (not i:IsTapped() or i:IsTappedByMe())
			and (not script_grind:isTargetBlacklisted(i:GetGUID()))
			and not (self.skipUnknown and i:GetCreatureType() == 'Not specified')
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
			end 
		end
		currentObj, typeObj = GetNextObject(currentObj); 
	end
	return nrPlayersTargetingUs;
end

function script_grind:getDistanceDif()
	local x, y, z = GetLocalPlayer():GetPosition();
	local xV, yV, zV = self.myX-x, self.myY-y, self.myZ-z;
	return math.sqrt(xV^2 + yV^2 + zV^2);
end

function script_grind:drawStatus()
	script_drawStatus:drawSetup();
	script_drawStatus:draw();
end

function script_grind:draw()
	script_grind:drawStatus();
end

function script_grind:doLoot(localObj)
	local _x, _y, _z = self.lootObj:GetPosition();
	local dist = self.lootObj:GetDistance();
	local localObj = GetLocalPlayer();

		if (not self.timerSet) and (not IsEating()) and (not IsDrinking()) and (IsStanding()) and (not IsInCombat()) then
			self.blacklistLootTime = GetTimeEX() + 25000;
			self.timerSet = true;
		end

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

	-- close enough to loot range then do these
	if(dist <= self.lootDistance) then
		self.message = "Looting...";
		
		-- stop moving
		if(IsMoving() and not localObj:IsMovementDisabed()) then
			StopMoving();
			return;
		end

		-- stand if we are sitting
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

		-- interact with object if we are not looting
		if(not self.lootObj:UnitInteract() and not IsLooting()) then
			self.waitTimer = GetTimeEX() + 1050;
			return;
		end
	
		-- if looting and not moving then wait
		if (not LootTarget()) and (not IsMoving()) then
			script_grind:setWaitTimer(400);
			self.waitTimer = GetTimeEX() + 450;
			return;
		else
			-- we looted so reset variables
			self.waitTimer = GetTimeEX() + 600;
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

	-- blacklisting loot after x time
	if (IsStanding()) and (not IsInCombat()) then
		if (GetTimeEX() >= self.blacklistLootTime) then
			-- add to blacklist
			script_grind:addTargetToBlacklist(self.lootObj:GetGUID());
			-- variable on/off to stop spamming message
			if (self.messageOnce) then
			DEFAULT_CHAT_FRAME:AddMessage('Blacklisting Loot Target - Spent Too Long Looting!');
			self.blacklistLootTime = GetTimeEX() + 25000;
			self.messageOnce = false;
			end
		end
	end

	-- move to loot object
	self.message = "Moving to loot...";		
	script_navEX:moveToTarget(localObj, _x, _y, _z);	
	script_grind:setWaitTimer(80);

	-- wait momentarily once we reached lootObj / stop moving / etc
	if (self.lootObj:GetDistance() <= self.lootDistance) then
		self.waitTimer = GetTimeEX() + 750;
	end
		
end

function script_grind:getSkinTarget(lootRadius)
	local targetObj, targetType = GetFirstObject();
	local bestDist = lootRadius;
	local bestTarget = nil;
	while targetObj ~= 0 do
		if (targetType == 3) then -- Unit type NPC
			if(targetObj:IsDead()) then
					-- if is skinnable and is tapped by me (I killed it)
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
	-- do loot if there is anything lootable
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
	if (HasSpell('Skinning') and self.skinning and HasItem('Skinning Knife')) and (not IsDrinking()) and (not IsEating()) and (IsStanding()) then
		self.lootObj = nil;
			-- get skin target
		self.lootObj = script_grind:getSkinTarget(self.findLootDistance);
		if (not AreBagsFull() and not self.bagsFull and self.lootObj ~= nil) and (not IsMoving()) then
			-- do loot
			if (script_grind:doLoot(localObj)) then
				-- check for skinning error (probably doesn't work)
				local __, lastError = GetLastError();
				if (lastError ~= 77) then
					self.waitTimer = GetTimeEX() + 1200;
					return false;
				end
				return;
			end
		end
	end
	return false;
end

function script_grind:runRest()

		local localObj = GetLocalPlayer();
		local localHealth = localObj:GetHealthPercentage();
		local localMana = localObj:GetManaPercentage();

		-- check for pet to stop bugs
		local pet = GetPet();
		if (pet ~= 0) then
			if (GetPet():GetUnitsTarget() == 0) then
				script_grind.petHasTarget = false;
			end
		else
			script_grind.petHasTarget = false;
		end

	-- run the rest script for grind/combat
	if(RunRestScript()) then
		-- reset blacklist looting time
		script_grind.blacklistLootTime = GetTimeEX() + 30000;

		-- set tick rate for resting
		script_grind.tickRate = 1500;

		self.message = "Resting...";

		-- set new target time
		self.newTargetTime = GetTimeEX();

		-- Stop moving
		if (IsMoving()) and (not localObj:IsMovementDisabed()) then
			StopMoving();
			return true;
		end

		-- not in combat and pet doesn't have target then stop to rest if needed
		if (not IsInCombat()) and (not petHasTarget) then
			if (IsEating() and localHealth < 95)
				or (IsDrinking() and localMana < 95)
			then
				self.waitTimer = GetTimeEX() + 3500;
				return true;
			end
		end
	
		-- if done resting then stand up
		if (IsEating() and localHealth >= 95 and IsDrinking() and localMana >= 95) 
		or (not IsDrinking() and IsEating() and localHealth >= 95)
		or (not IsEating() and IsDrinking() and localMana >= 95)
		then
			if (not IsStanding()) then
				JumpOrAscendStart();
				return false;
			end
		end

		-- Dismount
		if (IsMounted()) then
			DisMount();
			return true;
		end
	return true;	
	end
return false;
end