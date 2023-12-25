script_rotation = {
	useMount = false,
	disMountRange = 25,
	timer = GetTimeEX(),
	tickRate = 500,
	combatError = 0,
	message = 'Rotation',
	enemyObj = 0,
	useExpChecker = true,
	aggroLoaded = include("scripts\\script_aggro.lua"),
	gatherLoaded = include("scripts\\script_gather.lua"),
	navFunctionsLoaded = include("scripts\\script_nav.lua"),
	helperLoaded = include("scripts\\script_helper.lua"),
	radarLoaded = include("scripts\\script_radar.lua"),
	menuLoaded = include("scripts\\script_rotationMenu.lua"),
	expExtra = include("scripts\\script_expChecker.lua"),
	drawEnabled = false,
	drawAggro = false,
	drawGather = false,
	drawUnits = false,
	isSetup = false,
	pullDistance = 150,
	showClassOptions = true,
	meleeDistance = 4,
	aggroRangeTank = 50,
	adjustTickRate = false,
}

function script_rotation:setup()
	script_helper:setup();
	script_gather:setup();
	self.isSetup = true;
end

function script_rotation:window()

	EndWindow();

	if(NewWindow("Rotation", 320, 300)) then 
		script_rotationMenu:menu(); 
	end
end

function script_rotation:run()
	
	if (not self.isSetup) then 
		script_rotation:setup(); 
	end

	if (script_rotationMenu.pause) then 
		self.message = "Paused by user..."; 
		return; 
	end

	if (self.useExpChecker) then
		script_expChecker:menu();
	end
	
	local partyMana = GetLocalPlayer():GetManaPercentage();
	local partyHealth = GetLocalPlayer():GetHealthPercentage();
	for i = 1, GetNumPartyMembers()+1 do
		local partyMember = GetPartyMember(i);
		if (i == GetNumPartyMembers()+1) 
			then partyMember = GetLocalPlayer();
		end
	end
	
	localObj = GetLocalPlayer();

	if (IsCasting() or IsChanneling()) then 
		return; 
	end
	
	if(self.timer > GetTimeEX()) then
		return;
	end

	self.timer = GetTimeEX() + self.tickRate;
	
	if (not self.adjustTickRate) then
			local tickRotationRandom = random(400, 1200);
		if (not GetLocalPlayer():GetUnitsTarget() == 0) or (IsMoving()) then
			script_rotation.tickRate = 135;

		elseif (not IsMoving()) and (IsInCombat()) then
			script_rotation.tickRate = tickRotationRandom;
		end
	end

	if (GetTarget() ~= 0 and GetTarget() ~= nil) then
		local target = GetTarget();
		if (target:CanAttack()) then
			self.enemyObj = target;
		else
			self.enemyObj = nil;
		end
	end
	
	if (not localObj:IsDead()) then
		
		self.enemyObj = GetTarget();		

		if(self.enemyObj ~= 0) then

			-- Auto dismount if in range
			if (IsMounted()) then 
				
				self.message = "Auto dismount if in range...";

				if (self.enemyObj:GetDistance() <= self.disMountRange) then
					DisMount(); 
					return; 
				end
			end

			if (self.enemyObj:GetDistance() <= 38) then
				-- Attack the target
				self.message = "Running the combat script on target...";
				RunCombatScript(self.enemyObj:GetGUID());
			return;
			end
		else
			-- Rest
			if (script_rotation:runRest()) then
				return;
			end

			self.message = "Waiting for a target...";
			return;
		end
	else
	-- Auto ress?
	end
end

function script_rotation:isTargetingMe(i) 
	local localPlayer = GetLocalPlayer();
	if (localPlayer ~= nil and localPlayer ~= 0 and not localPlayer:IsDead()) then
		if (i:GetUnitsTarget() ~= nil and i:GetUnitsTarget() ~= 0) then
			return i:GetUnitsTarget():GetGUID() == localPlayer:GetGUID();
		end
	end
	return false;
end

function script_rotation:enemyIsValid(i)
	if (i ~= 0) then
		-- Valid Targets: Tapped by us, or is attacking us or our pet
		if (script_rotation:isTargetingMe(i) or script_rotation:getTargetAttackingUs()) or (i:IsTappedByMe() or not i:IsTapped()) or (i:IsTappedByMe()) and (not i:IsDead()) then 
			return true; 
		end
		-- Valid Targets: Within pull range, levelrange, not tapped, not skipped etc
		if (not i:IsDead() and i:CanAttack() and not i:IsCritter()
			and ((i:GetLevel() <= self.maxLevel and i:GetLevel() >= self.minLevel))
			and i:GetDistance() < self.pullDistance and (not i:IsTapped() or i:IsTappedByMe())
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

function script_rotation:getTargetAttackingUs() 
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

function script_rotation:assignTarget() 
	-- Instantly return the last target if we attacked it and it's still alive and we are in combat
	if (self.enemyObj ~= 0 and self.enemyObj ~= nil and not self.enemyObj:IsDead() and IsInCombat()) then
		if (script_rotation:isTargetingMe(self.enemyObj) 
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
			if (script_rotation:enemyIsValid(i)) then
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

function script_rotation:draw()

	script_rotation:window();

	if (script_radar.showRadar) then
		script_radar:draw()
	end

	if (self.drawAggro) then 
		script_aggro:drawAggroCircles(self.aggroRangeTank); 
	end

	if (self.drawGather) then 
		script_gather:drawGatherNodes(); 
	end

	if (self.drawUnits) then 
		script_drawData:drawUnitsDataOnScreen(); 
	end

	if (not self.drawEnabled) then 
		return; 
	end

	-- color
	local r, g, b = 255, 55, 55;

	-- position
	local y, x, width = 120, 25, 370;
	local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
	if (onScreen) then
		y, x = tY-25, tX+75;
	end

	-- info
	if (not script_rotation.pause) then
		--DrawRect(x - 10, y - 5, x + width, y + 120, 255, 255, 0,  1, 1, 1);
		--DrawRectFilled(x - 10, y - 5, x + width, y + 80, 0, 0, 0, 60, 0, 0);
		--DrawText('Rotation', x-5, y-4, r, g, b) y = y + 15;
		DrawText('Script Idle: ' .. math.max(0, math.floor(self.timer-GetTimeEX())) .. ' ms.', x+255, y, 255, 255, 255); y = y + 20;
		--DrawText('Rotation status: ', x+255, y, r, g, b); y = y + 20;
		DrawText(self.message or "error", x+255, y, 100, 255, 255);
		DrawText('Status: ', x+255, y+30, r, g, b);
	end
end

function script_rotation:runRest()
	if(RunRestScript()) then
		self.message = "Resting...";

		-- Stop moving
		if (IsMoving() or IsMounted()) then 
			return true; 
		end

		-- Add 2500 ms timer to the rest script rotations (timer could be set already)
		if ((self.timer - GetTimeEX()) < 2500) then 
			self.timer = GetTimeEX() + 2500;
		end
	return true;	
	end
return false;
end