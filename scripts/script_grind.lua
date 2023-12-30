script_grind = {
	navFunctionsLoaded = include("scripts\\script_nav.lua"),
	helperLoaded = include("scripts\\script_helper.lua"),
	checkAddsLoaded = include("scripts\\script_checkAdds.lua"),
	talentLoaded = include("scripts\\script_talent.lua"),
	includeDrawData = include("scripts\\script_drawData.lua"),
	vendorLoaded = include("scripts\\script_vendor.lua"),
	gatherLoaded = include("scripts\\script_gather.lua"),
	grindExtra = include("scripts\\script_grindEX.lua"),
	extraFunctionsLoaded = include("scripts\\script_extraFunctions.lua"),
	grindMenu = include("scripts\\script_grindMenu.lua"),
	getSpellsLoaded = include("scripts\\script_getSpells.lua"),
	getSpells = false,
	aggroLoaded = include("scripts\\script_aggro.lua"),
	grindPartyOptionsLoaded = include("scripts\\script_grindParty.lua"),
	expExtra = include("scripts\\script_expChecker.lua"),
	unstuckLoaded = include("scripts\\script_unstuck.lua"),
	paranoiaLoaded = include("scripts\\script_paranoia.lua"),
	paranoiaMenuLoaded = include("scripts\\script_paranoiaMenu.lua"),
	radarLoaded = include("scripts\\script_radar.lua"),
	debuffCheck = include("scripts\\script_checkDebuffs.lua"),
	drawStatusScript = include("scripts\\script_drawStatus.lua"),
	omLoaded = include("scripts\\script_om.lua"),
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
	lootDistance = 2.8,
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
	nextToNodeDist = 3.8, -- (Set to about half your nav smoothness)
	blacklistedTargets = {},	-- GUID table of blacklisted targets
	blacklistedNum = 0,	-- number of blacklisted targets
	hardBlacklistedTargets = {},	-- GUID table of blacklisted targets
	hardBlacklistedNum = 0,	-- number of blacklisted targets
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
	hardBlacklistedNameNum = 0,	-- number of blacklisted targets
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
	extraSafe = true,
	monsterKillCount = 0,
	useAnotherVar = false,
	currentMoney = GetMoney(),
	moneyObtainedCount = 0,
	lastAvoidTarget = GetLocalPlayer(),
	paranoiaCounter = 0,
	usedParanoiaCounter = false,
	omTimer = GetTimeEX(),
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

	-- grind party or in a group using grind for some other reason?
	if (GetNumPartyMembers() >= 1) then
		script_paranoia.paranoidOn = false;
		self.skipHardPull = false;
		script_grindEX.avoidBlacklisted = false;
		script_grindParty.forceTarget = true;
		script_grindParty.waitForGroup = true;
		self.drawEnabled = false;
		self.drawUnits = false;
		self.useExpChecker = false;
		
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
	if (GetLocalPlayer():GetLevel() <= 5) then
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
	-- turn on herbs
	if (HasSpell("Find Herbs")) then
		self.gather = true;
	end
	-- turn on mining
	if (HasSpell("Find Minerals")) then
		self.gather = true;
	end

	-- change some values to random
	local randomLogout = math.random(30, 65);
	self.setParanoidTimer = randomLogout;

	local randomHotspot = math.random(550, 1500);
	self.distToHotSpot = randomHotspot;

	local randomSetTimer = math.random(3, 10);
	self.paranoidSetTimer = randomSetTimer;

	local randomRange = math.random(50, 90);
	self.paranoidRange = randomRange;

	-- why was this not iterated before?
	local level = GetLocalPlayer():GetLevel();
	if (level < 10) then
		script_checkAdds.addsRange = 15;
	end
	if (level >= 10) and (level < 20) then
		script_checkAdds.addsRange = 18;
	end
	if (level >= 20) and (level < 40) then
		script_checkAdds.addsRange = 21;
	end
	if (level > 40) then
		script_checkAdds.addsRange = 24;
	end
	if (level == 60) then
		script_checkAdds.addsRange = 27;
	end

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

-- add target to hard blacklist table by GUID
function script_grind:addTargetToHardBlacklist(targetGUID)
	if (targetGUID ~= nil and targetGUID ~= 0 and targetGUID ~= '') then	
		self.hardBlacklistedTargets[self.hardBlacklistedNum] = targetGUID;
		self.hardBlacklistedNum = self.hardBlacklistedNum + 1;
	end
end

-- check if target is hard blacklisted by table GUID
function script_grind:isTargetHardBlacklisted(targetGUID) 
	for i=0,self.hardBlacklistedNum do
		if (targetGUID == self.hardBlacklistedTargets[i]) then
			return true;
		end
	end
	return false;
end

-- run grinder
function script_grind:run()
	-- show grinder window
	script_grind:window();

	if (self.getSpells) then
	if (script_getSpells.getSpellsStatus ~= 3) then
	if (script_getSpells:run()) then
	end
	end
	end
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
		script_nav:setNextToNodeDist(14); NavmeshSmooth(26);
	else
		-- else set to preset variable
		script_nav:setNextToNodeDist(self.nextToNodeDist); NavmeshSmooth(self.nextToNodeDist*2.5);
	end

		localObj = GetLocalPlayer();
	-- sprint or dash or aspect or cheetah or cat form
	if (localObj:HasBuff("Sprint")) or (localObj:HasBuff("Aspect of the Cheetah")) or (localObj:HasBuff("Dash")) or (localObj:HasBuff("Cat Form")) then
		script_nav:setNextToNodeDist(10); NavmeshSmooth(26);
	else
		-- else set to preset variable
		script_nav:setNextToNodeDist(self.nextToNodeDist); NavmeshSmooth(self.nextToNodeDist*3);
	end

	-- night elf whisp
		local race = UnitRace('player');
	if (race == 'Night Elf') and (localObj:IsDead()) then
		script_nav:setNextToNodeDist(8);
		NavmeshSmooth(18);
	else
		-- else set to preset variable
		script_nav:setNextToNodeDist(self.nextToNodeDist);
		NavmeshSmooth(self.nextToNodeDist*4);
	end
	
	-- player is dead
	if (localObj:IsDead() or IsGhost()) then
		script_nav:setNextToNodeDist(8);
		NavmeshSmooth(16);
		self.tickRate = 100;
	else
		-- else set to preset variable
		script_nav:setNextToNodeDist(self.nextToNodeDist);
		NavmeshSmooth(self.nextToNodeDist*4);
	end

	if (IsIndoors()) then
		script_nav:setNextToNodeDist(4); NavmeshSmooth(16);
	else
		script_nav:setNextToNodeDist(self.nextToNodeDist); NavmeshSmooth(self.nextToNodeDist*2.5);
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
	if (self.useUnstuck) and (IsMoving()) and (not self.pause) then
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


	if (not IsUsingNavmesh()) then UseNavmesh(true);
		return true;
	end
	if (not LoadNavmesh()) then script_grind.message = "Make sure you have mmaps-files...";
		return true;
	end
	if (GetLoadNavmeshProgress() ~= 1) then
		script_grind.message = "Loading Nav Mesh! Please Wait!";
		return true;
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


	if (IsInCombat()) and (GetLocalPlayer():GetHealthPercentage() >= 1) and (self.skipHardPull) and (self.enemyObj ~= nil) then
		script_om:FORCEOM();
	end

	-- check paranoia	
		-- jump when player in range in combat
	if (IsInCombat()) and (not script_grind.undoAFK) and (script_paranoia.paranoidOn) then
		if (script_paranoiaCheck:playersWithinRange2(60)) and (script_grind.playersTargetingUs() >= 1) 
			or (script_paranoiaCheck:playersWithinRange2(38)) then
			if (not IsCasting()) and (not IsChanneling()) then
				local moreJumping = math.random(0, 701);
				if (moreJumping >= 700) then
					JumpOrAscendStart();
					
				end
			end
		end
	end

	if (not script_paranoia.paranoiaUsed) then
		script_paranoiaCheck:playersWithinRange2(self.paranoidRange);
	end
	if (script_paranoia.paranoiaUsed) and (not self.usedParanoiaCounter) then
		self.paranoiaCounter = self.paranoiaCounter + 1
		self.usedParanoiaCounter = true;
	end


	-- do paranoia
	if (not IsLooting()) and (not IsInCombat()) and (not IsMounted()) and (not IsCasting()) and (not IsChanneling()) and (script_grind.playerName ~= "Unknown") and (script_grind.otherName ~= "Unknown") then	
				-- set paranoid used as true
		if (script_paranoia:checkParanoia()) and (not self.pause) then
				script_paranoia.paranoiaUsed = true;
				script_grind:setWaitTimer(3850);
			
			-- if player is within distance <= 30 then do this
			if (script_grind.playerParanoidDistance <= 30) and (script_grind:playersTargetingUs() >= 1) and (not IsInCombat()) then
				-- target player targeting us
				if (not PlayerHasTarget()) then	
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
			self.usedParanoiaCounter = false;
			script_paranoia.doEmote = true;
			script_paranoia.didEmote = false;
			self.useAnotherVar = false;
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

		if (IsInCombat()) and (GetTimeEX() > self.omTimer) then
			script_om:FORCEOM();
			self.omTimer = GetTimeEX() + 5000;
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

		-- check party members
		if (GetNumPartyMembers() >= 1) then
			if (script_grindParty:partyOptions()) then
				return true;
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
		and (not IsMounted()) and (not IsIndoors()) and (not HasForm()) and (script_grind.useMount)
		then
			if (IsMoving()) then
				StopMoving();
				return true;
			end
			if (not IsIndoors()) and (not IsMoving()) then
				if (script_helper:mountUp()) then
					script_grind:setWaitTimer(4500);
				end
			end
		return true;
		end
		
		-- Gather
		if (self.gather and not IsInCombat() and not AreBagsFull() and not self.bagsFull) then
			if (script_gather:gather()) then
				if (not script_grind.adjustTickRate) then
					script_grind.tickRate = 135;
				end

				self.message = 'Gathering ' .. script_gather:currentGatherName() .. '...';
				return;
			end
		end

		-- hotspot reached distance
		if (script_nav:getDistanceToHotspot() <= 45) then
			self.hotspotReached = true;
		end

		-- Auto path: keep us inside the distance to the current hotspot, if mounted keep running even if in combat
		if (not script_grind.hotspotReached) and ((not IsInCombat() or IsMounted()) and (self.autoPath) and (script_vendor:getStatus() == 0) and
			(script_nav:getDistanceToHotspot() > self.distToHotSpot or self.hotSpotTimer > GetTimeEX())) then
			if (not (self.hotSpotTimer > GetTimeEX())) then
				self.hotSpotTimer = GetTimeEX() + 20000;
			end

			--Mount up
			if (not self.hotspotReached or script_vendor:getStatus() >= 1) and (not IsInCombat())
			and (not IsMounted()) and (not IsIndoors()) and (not HasForm())
			and (script_grind.useMount)
			then
				if (IsMoving()) then
					StopMoving();
					return true;
				end
				if (not IsIndoors()) and (not IsMoving()) then
					if (script_helper:mountUp()) then
						script_grind:setWaitTimer(4500);
						self.waitTimer = GetTimeEX() + 4500;
					end
				end
			return true;
			end

			-- Druid travel form
			--if (not IsIndoors()) then
			--	if (not IsMounted()) and (not script_paranoia:checkParanoia()) and (not IsSwimming()) and (not self.useMount) then
			--		if (script_druidEX:travelForm()) then
			--			self.waitTimer = GetTimeEX() + 1000;
			--		end
			--	end
			--end

			-- druid cat form
			if (not IsMounted()) and (not self.useMount) and (not HasSpell("Travel Form")) and (HasSpell("Cat Form")) and (not localObj:HasBuff("Cat Form")) and (not localObj:IsDead()) and (GetLocalPlayer():GetHealthPercentage() >= 95) then
				if (CastSpellByName("Cat Form")) then
					self.waitTimer = GetTimeEX() + 500;
					return 0;
				end
			end

			-- rogue stealth
			--if (not IsMounted()) and (not self.useMount) and (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (not localObj:IsDead()) and (GetLocalPlayer():GetHealthPercentage() >= 95) and (not script_checkDebuffs:hasPoison()) then
			--	if (CastSpellByName("Stealth", localObj)) then
			--		self.waitTimer = GetTimeEX() + 1200;
			--	end
			--end

			-- Shaman Ghost Wolf 
			if (not IsMounted()) and (not self.useMount) and (not script_grind.useMount) and (HasSpell('Ghost Wolf')) and (not localObj:HasBuff('Ghost Wolf')) and (not localObj:IsDead()) then
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

		-- check party members
		if (GetNumPartyMembers() >= 1) then
			if (script_grindParty:partyOptions()) then
				return true;
			end
		end

		-- use kills to level tracker
		if (self.useExpChecker) then
			script_expChecker:targetLevels();
		end
		
		-- Assign the next valid target to be killed within the pull range
		if (self.enemyObj ~= 0 and self.enemyObj ~= nil) then
			self.lastTarget = self.enemyObj:GetGUID();
		end

		self.enemyObj = script_grind:assignTarget();

		
		if (self.enemyObj ~= 0 and self.enemyObj ~= nil) then
			if (not PlayerHasTarget()) and (not IsMoving()) and (not script_grind:isTargetHardBlacklisted(self.enemyObj)) then
				self.enemyObj:AutoAttack();
			end
			-- Fix bug, when not targeting correctly
			if (self.lastTarget ~= self.enemyObj:GetGUID()) then
				self.newTargetTime = GetTimeEX();
				ClearTarget();
			-- blacklist the target if we had it for a long time and hp is high
			elseif (((GetTimeEX()-self.newTargetTime)/1000) > self.blacklistTime and self.enemyObj:GetHealthPercentage() > 92) then
				script_grind:addTargetToHardBlacklist(self.enemyObj:GetGUID());
				ClearTarget();
				return;
			elseif (IsInCombat()) and (self.enemyObj ~= nil and self.enemyObj ~= 0) and (self.enemyObj:IsInLineOfSight()) and (self.lastTarget == self.enemyObj:GetGUID()) then
				self.newTargetTime = GetTimeEX();
			end

			if (not IsMoving()) and (not IsInCombat()) and (((GetTimeEX()-self.newTargetTime)/1000) > self.blacklistTime) then
			local mx, my, mz = GetLocalPlayer():GetPosition();
			Move(mx+5, my+5, mz);
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

		-- Dont pull if more than 1 add will be pulled check SafePull aggro
		if (self.enemyObj ~= nil and self.enemyObj ~= 0 and self.skipHardPull) then
			if (not script_aggro:safePull(self.enemyObj)) and (not IsInCombat())
			and (not script_grind:isTargetingMe2(self.enemyObj)) then
				script_grind:addTargetToBlacklist(self.enemyObj:GetGUID());
			end
		end

		-- move away from adds script conditions
		if (IsInCombat()) and (self.safePull)
			and (GetLocalPlayer():GetHealthPercentage() >= 1)
			and (script_grind.skipHardPull)
			and (script_grind:isTargetingMe2(self.enemyObj))
			and (self.enemyObj:IsInLineOfSight())
			and (not self.enemyObj:IsCasting())
			and (not self.enemyObj:IsFleeing())
		 then
		
			-- force reset of closestEnemy
			if (self.enemyObj ~= nil) then
			script_om:FORCEOM2();
			end

			-- check and do move away from adds during combat
			if (script_checkAdds:checkAdds()) then
				script_om:FORCEOM();
				return;
			end
		end
		
		-- Finish loot before we engage new targets or navigate - return
		if (self.lootObj ~= nil and not IsInCombat()) then
			return; 
		else

			-- blacklist loot message
			self.messageOnce = true;

			-- blacklist loot timer
			self.timerSet = false;

			-- reset the combat status
			self.combatError = nil; 

			-- avoid blacklisted and avoided targets
			if (script_grindEX.avoidBlacklisted) then

				-- check blacklisted targets around me
				if (script_aggro:closeToBlacklistedTargets()
					or script_aggro:closeToHardBlacklistedTargets()) then
					self.message = "Close To Blacklisted Target.. Moving...";

					-- do blacklist avoid
					if (not IsEating()) and (not IsDrinking()) then
						if (script_runner:avoidToBlacklist(5)) then
							return true;
						end

					-- avoid if we are drinking or eating
					elseif (IsEating() or IsDrinking()) then
						if (script_runner:avoidToBlacklist(13)) then
							return true;
						end
					end
				return true;
				end	
			end

	-- Run the combat script and retrieve combat script status if we have a valid target

			if (self.enemyObj ~= nil and self.enemyObj ~= 0) then
				self.combatError = RunCombatScript(self.enemyObj:GetGUID());
			end
		end



	-- in combat phase or we have an enemy
		if (self.enemyObj ~= nil or IsInCombat()) then

			-- don't avoid our current target check adds script
			self.lastAvoidTarget = self.enemyObj;


			-- pet stays in combat on some server cores while returning to player
				-- force bot to finish combat...
			if (UnitClass('player') == "Warlock") or (UnitClass('player') == "Hunter") and (GetNumPartyMembers() == 0) then

				-- force bot to attack pets target
				if (script_warlock.waitAfterCombat or script_hunter.waitAfterCombat)
					and (IsInCombat())
					and (GetPet() ~= 0
						and GetPet():GetHealthPercentage() > 1
						and not PetHasTarget())
					and (not PlayerHasTarget())
					and (script_warlock.hasPet or script_hunter.hasPet)
				then

					-- if pet has a target then assist and do combat
						-- recall pet for safety
			 		if (PetHasTarget()) then
						if (GetPet():GetDistance() > 10) then
							AssistUnit("pet");
							PetFollow();
						end

						-- if pet doesn't have a target then return until out of combat phase
					elseif (not PlayerHasTarget()) then
						AssistUnit("pet");
						self.message = "Stuck in combat! WAITING!";
						return 4;
					end
				end
			end

			-- reset object manager and check adds enemies
			script_checkAdds.closestEnemy = 0;
			script_checkAdds.intersectEnemy = nil;

			-- if we have a valid enemy
			if (self.enemyObj ~= nil) then

				-- if enemy distance is melee range then face the target
				if (self.enemyObj:GetDistance() <= 8) and (not IsMoving()) and (PlayerHasTarget()) then
					self.enemyObj:FaceTarget();
				end
			else
				-- else assign a target
				script_grind:assignTarget();
			end

			-- combat script message
			self.message = "Running the combat script...";

			-- death counter turning variable on and off for 2 or more enemies attacking us
			if (self.enemyObj ~= 0 and self.enemyObj ~= nil) then
				if (IsInCombat()) and (self.enemyObj:GetHealthPercentage() > 20) then
					self.useAnotherVar = false;
				end
			end

			-- monster kill variable on and off
			if (self.enemyObj ~= nil) and (not self.useAnotherVar) then
				if (self.enemyObj:GetHealthPercentage() <= 20 or self.enemyObj:IsDead()) then
					self.monsterKillCount = self.monsterKillCount + 1;
					self.useAnotherVar = true;
				end
			end

		-- check return combat errors
			
			-- In range: attack the target, combat script returns 0 STOP MOVING
			if (self.combatError == 0) then

				-- we stopped moving so reset navigate
				script_nav:resetNavigate();

				-- return 0 stops movement
				if IsMoving() then StopMoving();
					return;
				end
			end

			-- Invalid target: combat script return 2
			if (self.combatError == 2) then

				-- add target to blacklist
				script_grind.addTargetToBlacklist(self.enemyObj:GetGUID());
	
				-- reset enemyObj
				self.enemyObj = nil;
				ClearTarget();
				return;
			end

			-- Move in range: combat script return 3
			if (self.combatError == 3) and (not localObj:IsMovementDisabed())
				and (not script_checkDebuffs:hasDisabledMovement()) then
				self.message = "Moving to target...";
				--if (self.enemyObj:GetDistance() < self.disMountRange) then
				--end

				-- check positions
				local _x, _y, _z = self.enemyObj:GetPosition();
				local localObj = GetLocalPlayer();

				-- adjust tick rate to make targeting and movement quicker
				if (not script_grind.adjustTickRate) and (PlayerHasTarget()) then
					script_grind.tickRate = 135;
				end

				-- if we have a valid position coordinates
				if (_x ~= 0 and x ~= 0) then

					-- add some randomness to movement
					local moveBuffer = math.random(-2, 2);

				-- move to target
				self.message = script_navEX:moveToTarget(localObj, _x+moveBuffer, _y+moveBuffer, _z);

					-- set wait timer to move clicks
					script_grind:setWaitTimer(110);

					return;
				end
				return;
			end

			-- Do nothing, return : combat script return 4
			if (self.combatError == 4) then
				return;
			end
			
			-- Target player : pause for 5 seconds, combat script should add target to blacklist
			if (self.combatError == 5) then
		
				-- reset target
				ClearTarget();
				self.message = "Targeted a player pet pausing 3s...";
				self.waitTimer = GetTimeEX()+3000;
				return;
			end
			
			-- Stop bot, request from a combat script
			if (self.combatError == 6) then 
				self.message = "Combat script request stop bot...";
			
				-- stop and loglout
		 		Logout();
				StopBot();
				return;
			end

			-- attempt to run away from adds in combat
			if (IsInCombat()) and (self.safePull)
				and (GetLocalPlayer():GetHealthPercentage() >= 1)
				and (script_grind.skipHardPull)
				and (script_grind:isTargetingMe2(self.enemyObj))
				and (self.enemyObj:IsInLineOfSight())
				and (not self.enemyObj:IsCasting())
				and (not self.enemyObj:IsFleeing())
			then

				if (self.enemyObj ~= nil) then
				-- force reset or closestEnemy
				script_om:FORCEOM2();
				end
				-- check and avoid adds
				if (script_checkAdds:checkAdds()) then
					script_om:FORCEOM();
					return;
				end

				-- try unstuck script
				if (not script_unstuck:pathClearAuto(2)) then
					script_unstuck:unstuck();
					return true;
				end
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
		and (not IsMounted()) and (not IsIndoors()) and (not HasForm()) and (self.useMount) then
			if (IsMoving()) then
				StopMoving();
				return true;
			end

			-- use helper mount function
			if (not IsIndoors()) and (not IsMoving()) then
				if (script_helper:mountUp()) then
					script_grind:setWaitTimer(4500);
				end
			end
		return true;
		end

		-- travel forms
		if (not self.hotspotReached or script_vendor:getStatus() >= 1) and (not IsInCombat())
		and (not IsMounted()) and (not IsIndoors()) and (not HasForm()) and (not self.useMount) then
			if (HasSpell("Ghost Wolf")) or (HasSpell("Travel Form")) then
				if (IsMoving()) then
					StopMoving();
					return true;
				end

				-- use travel form function
				if (HasSpell("Travel Form")) then
					if (script_druidEX:travelForm()) then
						script_grind:setWaitTimer(2500);
					end
				end

				-- use ghost wolf function
				if (HasSpell("Ghost Wolf")) then
					if (script_shamanEX2:ghostWolf()) then
						script_grind:setWaitTimer(4000);
					end
				end
			end
		end

		-- Use auto pathing or walk paths
		if (self.autoPath) then

			-- continue to hotspot until we find a valid enemy...
				-- move to a diff location if no valid enemies around?
					-- run autopath nodes?
			if (script_nav:getDistanceToHotspot() < 20 and not self.hotspotReached) then
				self.message = "Hotspot reached... (No targets around?)";
				self.hotspotReached = true;
				return;
			else

				-- move to saved locations
				self.message = script_nav:moveToSavedLocation(localObj, self.minLevel, self.maxLevel, self.staticHotSpot);
				script_grind:setWaitTimer(85);


				-- check stealth rogue
				if (script_rogue.useStealth) and (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (not localObj:IsDead()) and (GetLocalPlayer():GetHealthPercentage() >= 95) and (script_grind.lootObj == nil or script_grind.lootObj == 0) then
					CastSpellByName("Stealth", localObj);
					self.waitTimer = GetTimeEX() + 1200;
				end
			end
		else
			-- Check: Load/Refresh the walk path
			if (self.pathName ~= self.pathLoaded) then

				-- return no path loaded
				if (not LoadPath(self.pathName, 0)) then
					self.message = "No walk path has been loaded...";
					return;
				end

				-- else pathloaded
				self.pathLoaded = self.pathName;
			end


			-- Navigate
			self.message = script_nav:navigate(localObj);
		end
	end 
end


-- just return enemyObj
function script_grind:getTarget()
	return self.enemyObj;
end


-- get a target attacking us returns a currentObj:GetGUID()
function script_grind:getTargetAttackingUs() 

	local currentObj, typeObj = GetFirstObject(); 

	-- run object manager
	while currentObj ~= 0 do 
		
		-- NPC type 3
    		if typeObj == 3 then
	
			-- acceptable targets
			if (currentObj:CanAttack() and not currentObj:IsDead()) and (currentObj:IsInLineOfSight()) then

			-- get targets target - target of target
			local localObj = GetLocalPlayer();
			local targetTarget = currentObj:GetUnitsTarget();

				-- target has a target and distance less than 50 (limit object manager by distance)
				if (targetTarget ~= 0 and targetTarget ~= nil) and (currentObj:GetDistance() < 50) then

					-- if target is targeting me then
					if (targetTarget:GetGUID() == localObj:GetGUID()) then
	
						-- return target
						return currentObj:GetGUID();
					end
				end	

				-- acceptable target is targeting our group members (limited by distance)
				if (currentObj:GetDistance() < 50) and (currentObj:IsInLineOfSight()) and (script_grindParty.forceTarget) then

					-- run another object manager script to get a different target 
                			if (script_grind:isTargetingGroup(currentObj)) then 
					
						-- return target
                				return currentObj:GetGUID();
                			end
				end
            		end 
       		end

	-- get next target
	currentObj, typeObj = GetNextObject(currentObj); 
	end

	-- return nil if no target
	return nil;
end

-- assign a valid target
function script_grind:assignTarget() 

	-- Return a target attacking our group
	local i, targetType = GetFirstObject();

	-- run object manager
	while i ~= 0 do
	
		-- NPC type 3
		if (targetType == 3) then
		
			-- acceptable targets limited check by range
			if (i:GetDistance() < 50) and (i:IsInLineOfSight()) and (script_grindParty.forceTarget) then
				
				-- run another object manager
				if (script_grind:isTargetingGroup(i)) then

					-- return target
					return i;
				end
			end
		end

		-- get next target
		i, targetType = GetNextObject(i);
	end

	-- Instantly return the last target if we attacked it and it's still alive and we are in combat
	if (self.enemyObj ~= 0 and self.enemyObj ~= nil and not self.enemyObj:IsDead() and IsInCombat()) then

		-- check if enemyObj is targeting me
		if (script_grind:isTargetingMe2(self.enemyObj) 

			-- or tareting pet
			or script_grind:isTargetingPet(self.enemyObj) 

			-- or is tapped by me
			or self.enemyObj:IsTappedByMe()) then

			-- return target
			return self.enemyObj;
		end
	end

	-- Find the closest valid target if we have no target or we are not in combat
	local mobDistance = self.pullDistance;
	local closestTarget = nil;
	local i, targetType = GetFirstObject();

	-- run object manager
	while i ~= 0 do

		-- acceptable targets
		if (targetType == 3 and not i:IsCritter() and not i:IsDead() and i:CanAttack()) then

			-- if that enemy is valid
			if (script_grind:enemyIsValid(i)) then

				-- save the closest mob or mobs attacking us
				if (mobDistance > i:GetDistance()) then

					-- get taret position
					local _x, _y, _z = i:GetPosition();

					-- is nav node valid?
					if(not IsNodeBlacklisted(_x, _y, _z, self.nextNavNodeDistance)) then

						-- return closest target
						mobDistance = i:GetDistance();	
						closestTarget = i;
					end
				end
			end
		end

		-- get next target
		i, targetType = GetNextObject(i);
	end
	
	-- Check: If we are in combat but no valid target, kill the "unvalid" target attacking us
	if (closestTarget == nil and IsInCombat()) then

		-- make sure we have a target
		if (GetTarget() ~= 0) then

			-- need to check for loot first...
			--script_grind.tickRate = 100;

			-- return target
			return GetTarget();
		end
	end

	-- Return the closest valid target or nil
	return closestTarget;
end

function script_grind:isTargetingPet(i) 
	local pet = GetPet();

	-- if we have a pet
	if (pet ~= nil and pet ~= 0 and not pet:IsDead()) then

		-- if target is targeting pet then
		if (i:GetUnitsTarget() ~= nil and i:GetUnitsTarget() ~= 0) then

			-- return true
			return i:GetUnitsTarget():GetGUID() == pet:GetGUID();
		end
	end
	return false;
end

function script_grind:isTargetingGroup(y) 
	local partyMember = 0;

	-- get partymembers
	for i = 1, GetNumPartyMembers()+1 do
		local partyMember = GetPartyMember(i);
	end
		
	-- if we have party members and conditions valid (limited object manager by range)
	if (partyMember ~= nil and partyMember ~= 0 and not partyMember:IsDead() and partyMember:GetDistance() < 50) then

		local y, typeObj = GetFirstObject(); 

		-- run object manager
		while y ~= 0 do 

			-- acceptable targets
    			if (typeObj == 3)
				and (y:GetDistance() < 50)
				and (not y:IsCritter())
				and (not y:IsDead())
				and (y:CanAttack())
				and (y:IsInLineOfSight())
			then
				-- if target has a target then
				if (y:GetUnitsTarget() ~= nil and y:GetUnitsTarget() ~= 0) then

					-- if target is targeting a party member then
					if (y:GetUnitsTarget():GetGUID() == partyMember:GetGUID()) then

						-- return target
						self.enemyObj = y;
					end
				end
			end

		-- get next target
		y, typeObj = GetNextObject(y); 
		end
	end
return false;
end

-- if any enemy is targeting group true or false
function script_grind:isTargetingGroupBool()

	local partyMember = GetPartyMember();

	-- get party members 
	for i = 1, GetNumPartyMembers() do

		local partyMember = GetPartyMember(i);
	end

	-- if we have valid party members
	if (partyMember ~= nil and partyMember ~= 0 and not partyMember:IsDead()) then

		local unitsAttackingUs = 0; 
		local currentObj, typeObj = GetFirstObject(); 

		-- run object manager
		while currentObj ~= 0 do 

			-- NPC type 3
    			if typeObj == 3 then
				
				-- acceptable targets
				if (currentObj:CanAttack() and not currentObj:IsDead()) then

					-- if target has a target
                			if (currentObj:GetUnitsTarget() ~= nil and currentObj:GetUnitsTarget() ~= 0) then

						-- is target targeting party member
						if (currentObj:GetUnitsTarget():GetGUID() == partyMember:GetGUID()) then
							return true;
						end
					end
	                	end
			end

		-- get next target
		currentObj, typeObj = GetNextObject(currentObj); 
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
function script_grind:isTargetingMe3(currentObj) 
	local localPlayer = GetLocalPlayer();
	if (localPlayer ~= nil and localPlayer ~= 0 and not localPlayer:IsDead()) then
		if (currentObj:GetUnitsTarget() ~= nil and currentObj:GetUnitsTarget() ~= 0) then
			return currentObj:GetUnitsTarget():GetGUID() == localPlayer:GetGUID();
		end
	end
	return false;
end
function script_grind:isTargetingMe2(target) -- self.enemyObj
	local localPlayer = GetLocalPlayer();
	local target = script_grind.enemyObj;
	if (script_grind.enemyObj ~= 0) and (script_grind.enemyObj ~= nil) and (localPlayer ~= nil and localPlayer ~= 0 and not localPlayer:IsDead()) then
		if (target:GetUnitsTarget() ~= nil and target:GetUnitsTarget() ~= 0) then
			return target:GetUnitsTarget():GetGUID() == localPlayer:GetGUID();
		end
	end
	return false;
end

function script_grind:enemyIsValid(i)

	-- we have a valid enemy in object manager
	if (i ~= 0) then

	-- if target distance is close enough and in line of sight and is targeting group then return target
		if (i:GetDistance() < 50) and (i:IsInLineOfSight()) and (script_grindParty.forceTarget) then
			if (script_grind:isTargetingGroup(i)) then
				return true;
			end
		end

	-- add target to blacklist not a safe pull from aggro script
		if (self.skipHardPull) and (not script_aggro:safePull(i)) and (not script_grind:isTargetBlacklisted(i:GetGUID())) and (not script_grind:isTargetingMe(i)) then	
			script_grind:addTargetToBlacklist(i:GetGUID());
		end
		
	-- add elite to blacklist
		if (self.skipElites) and (i:GetClassification() == 1 or i:GetClassification() == 2) and (not script_grind:isTargetHardBlacklisted(i:GetGUID())) and (not script_grind:isTargetingMe(i)) then	
			script_grind:addTargetToHardBlacklist(i:GetGUID());
		end

	-- add above maxLevel to blacklist
		if (self.skipHardPull) and (not script_grind:isTargetHardBlacklisted(i:GetGUID())) and (not script_grind:isTargetingMe(i)) and (i:GetLevel() > self.maxLevel) then
			script_grind:addTargetToHardBlacklist(i:GetGUID());
		end

	-- try to skip units below us or above us (in water or structure)
		-- has bugs
		--if (self.skipHardPull) and (not script_grind:isTargetBlacklisted(i:GetGUID())) and (not script_grind:isTargetingMe(i)) then
		--	local tarPosX, tarPosY, tarPosZ = i:GetPosition();
		--	local myPosX, myPosY, myPosZ = GetLocalPlayer():GetPosition();
		--	local posZ = tarPosZ - myPosZ;
		--	if (posZ > 9) then
		--		script_grind:addTargetToBlacklist(i:GetGUID());
		--	end
		--	if (posZ < -9) then
		--		script_grind:addTargetToBlacklist(i:GetGUID());
		--	end
		--end

	-- Valid Targets: Tapped by us, or is attacking us or our pet
		if (script_grind:isTargetingMe(i)
			or (script_grind:isTargetingPet(i) and (i:IsTappedByMe() or not i:IsTapped())) 
			or (script_grindParty.forceTarget and script_grind:isTargetingGroup(i) and (i:IsTappedByMe() or not i:IsTapped())) 
			or (i:IsTappedByMe() and not i:IsDead())) then 
				return true; 
		end

	-- avoided target is attacking us
		if (script_grind:isTargetBlacklisted(i:GetGUID())) and (script_grind:isTargetingMe(i)) then
			return true;
		end

	-- blacklisted target is attacking us
		if (script_grind:isTargetHardBlacklisted(i:GetGUID())) and (script_grind:isTargetingMe(i)) and (i:IsInLineOfSight()) then
			return true;
		end

	-- blacklisted target is polymorphed or feared
		-- bot tries to skip poly and feared targets...	
		--if (script_grind:isTargetBlacklisted(i:GetGUID())) and (i:HasDebuff("Polymorph") or i:HasDebuff("Fear")) then
		--	return true;
		--end

	-- attacking pet
		if (script_grind:isTargetingPet(i)) and (i:IsInLineOfSight()) then
			return true;
		end

	-- don't use avoid targets and don't recheck aggro range targets only skip hard pulls
		-- normal targeting logitechs style
		if (self.skipHardPull) and (not self.extraSafe) and (not script_grindEX.avoidBlacklisted)
			and (not script_grind:isTargetBlacklisted(i:GetGUID()))
			and (not script_grind:isTargetHardBlacklisted(i:GetGUID())) then
			if (not i:IsDead() and i:CanAttack() and not i:IsCritter()
			and ((i:GetLevel() <= self.maxLevel and i:GetLevel() >= self.minLevel))
			and i:GetDistance() < self.pullDistance and (not i:IsTapped() or i:IsTappedByMe())
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
		
	-- don't skip blacklisted or avoid targets - attack these targets
		if (not self.skipHardPull) then
			if (not i:IsDead() and i:CanAttack() and not i:IsCritter()
			and ((i:GetLevel() <= self.maxLevel and i:GetLevel() >= self.minLevel))
			and i:GetDistance() < self.pullDistance and (not i:IsTapped() or i:IsTappedByMe())
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

	-- RECHECK TARGETS
	-- target blacklisted moved away from other targets
	-- bot can target blacklisted targets under these conditions
		if (self.skipHardPull)
			and (self.extraSafe)
			and (script_grind:isTargetBlacklisted(i:GetGUID())
			and script_aggro:safePullRecheck(i)) then
			if (not script_grind:isTargetHardBlacklisted(i:GetGUID()))
				and (not i:IsDead() and i:CanAttack() and not i:IsCritter()
				and ((i:GetLevel() <= self.maxLevel and i:GetLevel() >= self.minLevel))
				and i:GetDistance() < self.pullDistance and (not i:IsTapped() or i:IsTappedByMe())
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
				--local tarPosX, tarPosY, tarPosZ = i:GetPosition();
				--local myPosX, myPosY, myPosZ = GetLocalPlayer():GetPosition();
				--local posZ = tarPosZ - myPosZ;
				--if (posZ < 9) and (posZ > -9) then
				) then
					-- force bot to keep this target and not recheck safepull over and over again
					script_grind.enemyObj = currentObj;
			return true;
			end
		end

	-- RECHECK TARGETS - these are targets that are not avoided or blacklisted
	-- valid enemies if we skip hard pulls and recheck targets
		if (self.skipHardPull) and (self.extraSafe)
			and (not script_grind:isTargetBlacklisted(i:GetGUID()))
			and (not script_grind:isTargetHardBlacklisted(i:GetGUID()))
			and (not i:IsDead() and i:CanAttack() and not i:IsCritter()
			and ((i:GetLevel() <= self.maxLevel and i:GetLevel() >= self.minLevel))
			and i:GetDistance() < self.pullDistance and (not i:IsTapped() or i:IsTappedByMe())
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
			--local tarPosX, tarPosY, tarPosZ = i:GetPosition();
			--local myPosX, myPosY, myPosZ = GetLocalPlayer():GetPosition();
			--local posZ = tarPosZ - myPosZ;
			--if (posZ < 9) and (posZ > -9) then
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

function script_grind:enemiesWithinRange() -- returns number of enemies within range
	local unitsInRange = 0; 
	local currentObj, typeObj = GetFirstObject(); 
	while currentObj ~= 0 do 
    	if (typeObj == 3) and (PlayerHasTarget()) then
		if (currentObj:CanAttack()) and (not currentObj:IsDead()) then
                	if (currentObj:GetDistance() < GetLocalPlayer():GetUnitsTarget():GetDistance() + script_checkAdds.addsRange) then 
                		unitsInRange = unitsInRange + 1; 
                	end 
            	end 
       	end
        currentObj, typeObj = GetNextObject(currentObj); 
    end
    return unitsInRange;
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

		if (not self.adjustTickRate) then
			script_grind.tickRate = 135;
		end


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
		--script_nav:resetNavigate();
		--self.waitTimer = GetTimeEX() + 550;
		
	end

	-- Blacklist loot target if swimming or we are close to aggro blacklisted targets and not close to loot target
	if (self.lootObj ~= nil) then
		if (IsSwimming()) and (not script_grindEX.allowSwim) and (script_aggro:closeToBlacklistedTargets() and self.lootObj:GetDistance() > 5) then
			script_grind:addTargetToHardBlacklist(self.lootObj:GetGUID());
			return;
		end
	end

	-- blacklisting loot after x time
	if (IsStanding()) and (not IsInCombat()) then
		if (GetTimeEX() >= self.blacklistLootTime) then
			-- add to blacklist
			script_grind:addTargetToHardBlacklist(self.lootObj:GetGUID());
			-- variable on/off to stop spamming message
			if (self.messageOnce) then
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
		if (script_grind:isTargetHardBlacklisted(self.lootObj:GetGUID()) and self.lootObj:GetDistance() > 10) then
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

		local myMoney = GetMoney();
		if (myMoney ~= self.currentMoney) then
			self.moneyObtainedCount = myMoney - self.currentMoney;
		end

		-- check for pet to stop bugs
		local pet = GetPet();
		if (pet ~= 0) then
			if (not PetHasTarget()) then
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
		if (not script_grind.adjustTickRate) then
			local randomRestTick = math.random(1200, 1600);
			script_grind.tickRate = randomRestTick;
		end

		self.message = "Resting...";

		-- set new target time
		if (not IsInCombat() and not IsMoving()) then
			self.newTargetTime = GetTimeEX();
			
			if (IsDrinking() or IsEating()) and (not IsInCombat()) then
		
			end
		end

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