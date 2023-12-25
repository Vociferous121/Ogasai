script_follow = {

	useMount = false,
	disMountRange = 32,
	mountTimer = 0,
	enemyObj = nil,
	lootObj = nil,
	timer = GetTimeEX(),
	tickRate = 500,
	waitTimer = GetTimeEX(),
	pullDistance = 150,
	findLootDistance = 60,
	lootDistance = 3,
	skipLooting = false,
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
	message = "Starting the follower...",
	drawNav = true,
	objectAttackingUs = 0,
	meleeDistance = 3.5,
	navFunctionsLoaded = include("scripts\\script_nav.lua"),
	helperLoaded = include("scripts\\script_helper.lua"),
	drawDataLoaded = include("scripts\\script_drawData.lua"),
	drawStatusLoaded = include("scripts\\script_drawStatus.lua"),
	checkDebuffsLoaded = include("scripts\\script_checkDebuffs.lua"),
	unstuckLoaded = include("scripts\\script_unstuck.lua"),
	-- follow folder
	healsLoaded = include("scripts\\follow\\script_followHealsAndBuffs.lua"),
	moveToMemberLoaded = include("scripts\\follow\\script_followMoveToMember.lua"),
	doCombatLoaded = include("scripts\\follow\\script_followDoCombat.lua"),
	menuLoaded = include("scripts\\follow\\script_followMenu.lua"),
	extraFunctions = include("scripts\\follow\\script_followEX.lua"),
	followMasterLoaded = include("scripts\\follow\\script_followFollowMaster.lua"),
}

function script_follow:window()
	if (self.isChecked) then 
		EndWindow();
		if(NewWindow("Follower Options", 320, 360)) then 
			script_followMenu:menu();
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

function script_follow:setup()
	self.lootCheck['timer'] = 0;
	self.lootCheck['target'] = 0;
	script_helper:setup();
	self.isSetup = true;
	ClearTarget();
end

function script_follow:draw()
	script_followEX:drawStatus();
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
		script_drawData:drawPath();
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

	-- auto unstuck feature
	if (self.useUnStuck) and (IsMoving()) then
		if (not script_unstuck:pathClearAuto(2)) then
			self.message = script_unstuck.message;
			return true;
		end
	end	

	--if (IsMoving()) then
		self.tickRate = 135;
	--elseif (IsInCombat()) then
	--	self.tickRate = 1550;
	--end

	if(GetTimeEX() > self.timer) then
		self.timer = GetTimeEX() + self.tickRate;

		localObj = GetLocalPlayer();


		-- Wait out the wait-timer and/or casting or channeling
		if (self.waitTimer > GetTimeEX() or IsCasting() or IsChanneling()) then
			return;
		end

		-- Corpse-walk if we are dead
		if(localObj:IsDead()) then

			script_follow.tickRate = 100;

				self.message = "Walking to corpse...";
			-- Release body
			if(not IsGhost()) then
				RepopMe(); 
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

		-- get target attacking us
		if (IsInCombat()) and (self.enemyObj == nil) or (self.enemyObj == 0) then
			TargetNearestEnemy();
			if (localObj:GetUnitsTarget() ~= 0) then
				self.enemyObj = localObj:GetUnitsTarget();
			end
		end
				
		-- Rest
		if (not IsInCombat() and script_followEX2:enemiesAttackingUs() == 0 and not localObj:HasBuff('Feign Death')) then
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

		-- Loot
		if (not IsInCombat() and script_followEX2:enemiesAttackingUs() == 0 and not localObj:HasBuff('Feign Death')) then
			-- Loot if there is anything lootable and we are not in combat and if our bags aren't full
			if (not self.skipLooting and not AreBagsFull()) then 
				self.lootObj = script_nav:getLootTarget(self.findLootDistance);
			else
				self.lootObj = nil;
			end
			if (self.lootObj == 0) then
				self.lootObj = nil; 
			end
				local isLoot = not IsInCombat() and not (self.lootObj == nil);
			if (isLoot and not AreBagsFull()) and (self.lootObj ~= nil) then
				if (script_followEX:doLoot(localObj)) then
					return true;
				end
			elseif (AreBagsFull() and not hsWhenFull) then
				self.lootObj = nil;
				self.message = "Warning the bags are full...";
			end

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
		for i = 1, GetNumPartyMembers()+1 do
			local member = GetPartyMember(i);
			if (not member:IsDead()) and (not localObj:IsDead()) and (not IsMoving()) then
				if (member:GetDistance() > 40) or (not member:IsInLineOfSight()) then
					script_followMoveToMember:moveInLineOfSight(partyMember);
				end
				if (script_followHealsAndBuffs:healAndBuff()) then
					
					self.message = "Healing/buffing the party...";
					self.waitTimer = GetTimeEX() + 1000;
					ClearTarget();
					return true;
				end
			end
		end

		-- Assign the next valid target to be killed
		-- Check if anything is attacking us Priest
		if (script_followEX2:enemiesAttackingUs() >= 1) then
				local localMana = GetLocalPlayer():GetManaPercentage();
			if (localMana > 6 and HasSpell('Fade') and not IsSpellOnCD('Fade')) then
				CastSpellByName('Fade');
				return;
			end
		end
				
		-- Check if anything is attacking us Paladin
		if (script_followEX2:enemiesAttackingUs() >= 2) then
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
			elseif (script_followEX2:enemiesAttackingUs() == 0) then
				self.enemyObj = nil;
			end 
		else
			-- Healer check: heal/buff the party
			for i = 1, GetNumPartyMembers()+1 do
				local member = GetPartyMember(i);
				if (not member:IsDead()) and (not localObj:IsDead()) and (not IsMoving()) then
					if (member:GetDistance() > 40) or (not member:IsInLineOfSight()) then
					script_followMoveToMember:moveInLineOfSight(partyMember);
				end
				if (script_followHealsAndBuffs:healAndBuff()) then
					
					self.message = "Healing/buffing the party...";
					self.waitTimer = GetTimeEX() + 1000;
					ClearTarget();
					return true;
				end
			end
		end

		if (script_follow:GetPartyLeaderObject() ~= 0) then
			if (script_follow:GetPartyLeaderObject():GetUnitsTarget() ~= 0 and not script_follow:GetPartyLeaderObject():IsDead()) and (script_follow:GetPartyLeaderObject():GetDistance() < self.followLeaderDistance) then
				if (script_follow:GetPartyLeaderObject():GetUnitsTarget():GetHealthPercentage() <= self.dpsHP and self.assistInCombat) then
					self.enemyObj = script_follow:GetPartyLeaderObject():GetUnitsTarget();
					script_followMoveToMember:moveInLineOfSight(leaderObj);
				elseif (script_followEX2:enemiesAttackingUs() == 0) then
					self.enemyObj = nil;
					ClearTarget();
				end
			end
       		end
	end	

		-- Finish loot before we engage new targets or navigate
		if (self.lootObj ~= nil and not IsInCombat()) then
			return; 
		else

			-- Healer check: heal/buff the party
			for i = 1, GetNumPartyMembers()+1 do
				local member = GetPartyMember(i);
				if (not member:IsDead()) and (not localObj:IsDead()) and (not IsMoving()) then
					if (member:GetDistance() > 40) or (not member:IsInLineOfSight()) then
						script_followMoveToMember:moveInLineOfSight(partyMember);
					end
					if (script_followHealsAndBuffs:healAndBuff()) then
						
						self.message = "Healing/buffing the party...";
						self.waitTimer = GetTimeEX() + 1000;
						ClearTarget();
						return true;
					end
				end
			end

			if (not localObj:IsDead()) then
				script_followDoCombat:run();
			end
		
		end
		

	end -- set wait timer tick rate

	if (not IsCasting()) and (not IsChanneling()) and (not IsDrinking()) and (not IsEating()) and (not IsLooting()) and (self.lootObj == nil) then
		if (script_followFollowMaster:run()) then
			return true;
		end
	end
end