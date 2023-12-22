script_followEX = {
	
	healsLoaded = include("scripts\\script_followHealsAndBuffs.lua"),

		drawUnits = false,
		drawAggro = false,
		drawAggroRange = 100,
}

function script_followEX:getDistanceDif()
	local x, y, z = GetLocalPlayer():GetPosition();
	local xV, yV, zV = self.myX-x, self.myY-y, self.myZ-z;
	return math.sqrt(xV^2 + yV^2 + zV^2);
end

function script_followEX:draw()
	script_followEX:drawStatus();	
end

function script_followEX:drawStatus()

	if (script_follow.drawPath) then
		script_drawData:drawPath(); 
	end

	if (script_followEX.drawUnits) then 
		script_drawData:drawUnitsDataOnScreen();
	end

	if (script_aggro.drawAggro) then 
		script_aggro:drawAggroCircles(self.drawAggroRange); 
	end
	-- color
		local r, g, b = 255, 255, 0;
	-- position
		local y, x, width = 120, 25, 370;
		local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
	if (onScreen) then
		y, x = tY-25, tX+75;
	end
		DrawRect(x - 10, y - 5, x + width, y + 80, 255, 255, 0,  1, 1, 1);
		DrawRectFilled(x - 10, y - 5, x + width, y + 80, 0, 0, 0, 160, 0, 0);
	if (script_follow:GetPartyLeaderObject()) and (GetNumPartyMembers() >= 1) then
		DrawText('Follower - Range: ' .. math.floor(script_follow.followLeaderDistance) .. ' yd. ' .. 
		'Master target: ' .. script_follow:GetPartyLeaderObject():GetUnitName(), x-5, y-4, r, g, b) y = y + 15;
	elseif (GetNumPartyMembers() >= 1) then
		DrawText('Follower - Follow range: ' .. math.floor(script_follow.followDistance) .. ' yd. ' .. 
		'Master target: ' .. '', x-5, y-4, r, g, b) y = y + 15;
	end 

		DrawText('Status: ', x, y, r, g, b); 
		y = y + 15; DrawText(script_follow.message or "error", x, y, 0, 255, 255);
		y = y + 20; DrawText('Combat script status: ', x, y, r, g, b); y = y + 15;
		RunCombatDraw();
end

function script_grindEX:doLoot(localObj)
		local _x, _y, _z = script_follow.lootObj:GetPosition();
		local dist = script_follow.lootObj:GetDistance();
	
	-- Loot checking/reset target
	if (GetTimeEX() > script_follow.lootCheck['timer']) then
		if (script_follow.lootCheck['target'] == script_follow.lootObj:GetGUID()) then
			script_follow.lootObj = nil; -- reset lootObj
			ClearTarget();
			script_follow.message = 'Reseting loot target...';
		end
			script_follow.lootCheck['timer'] = GetTimeEX() + 10000; -- 10 sec
		if (script_follow.lootObj ~= nil) then 
			script_follow.lootCheck['target'] = script_follow.lootObj:GetGUID();
		else
			script_follow.lootCheck['target'] = 0;
		end
		return;
	end

	if(dist <= script_follow.lootDistance) then
			script_follow.message = "Looting...";
		if(IsMoving() and not localObj:IsMovementDisabed()) then
			StopMoving();
			script_follow.waitTimer = GetTimeEX() + 450;
			return;
		end

		if(not IsStanding()) then
			StopMoving();
			script_follow.waitTimer = GetTimeEX() + 450;
			return;
		end
		
		-- If we reached the loot object, reset the nav path
			script_nav:resetNavigate();

		-- Dismount
		if (IsMounted()) then 
			DisMount(); script_follow.waitTimer = GetTimeEX() + 450;
			return; 
		end

		if(not script_follow.lootObj:UnitInteract() and not IsLooting()) then
			script_follow.waitTimer = GetTimeEX() + 950;
			return;
		end

		if (not LootTarget()) then
			script_follow.waitTimer = GetTimeEX() + 650;
			return;
		else
			script_follow.lootObj = nil;
			script_follow.waitTimer = GetTimeEX() + 450;
			return;
		end
	end

		script_follow.message = "Moving to loot...";		
		script_navEX:moveToTarget(localObj, _x, _y, _z);	
		script_grind:setWaitTimer(100);

	if (script_follow.lootObj:GetDistance() < 3) then
		script_follow.waitTimer = GetTimeEX() + 450; 
	end
end