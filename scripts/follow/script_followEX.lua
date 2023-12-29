script_followEX = {
	
	healsLoaded = include("scripts\\follow\\script_followHealsAndBuffs.lua"),
	followEX2Loaded = include("scripts\\follow\\script_followEX2.lua"),


		drawUnits = false,
		drawAggro = false,
}

function script_followEX:getDistanceDif()
	local x, y, z = GetLocalPlayer():GetPosition();
	local xV, yV, zV = self.myX-x, self.myY-y, self.myZ-z;
	return math.sqrt(xV^2 + yV^2 + zV^2);
end

function script_followEX:drawStatus() if (script_follow.drawPath) then script_drawData:drawPath(); end 
if (script_followEX.drawUnits) then script_drawData:drawUnitsDataOnScreen(); end if (script_aggro.drawAggro) then 
script_aggro:drawAggroCircles(script_followMenu.drawAggroRange); end
-- color
local r, g, b = 255, 255, 0;
-- position
local y, x, width = 120, 25, 370; local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
if (onScreen) then y, x = tY+25, tX+50; end
--DrawRect(x - 10, y - 5, x + width, y + 80, 255, 255, 0,  1, 1, 1);
--DrawRectFilled(x - 10, y - 5, x + width, y + 80, 0, 0, 0, 160, 0, 0);
if (GetPartyLeaderObject() ~= 0) then if (GetPartyLeaderObject()) and (GetNumPartyMembers() > 0) then
			DrawText('Follower - Range: ' .. math.floor(script_follow.followLeaderDistance) .. ' yd. ' .. 
			'Master target: ' .. GetPartyLeaderObject():GetUnitName(), x-5, y-4, r, g, b) y = y + 15;
		elseif (GetNumPartyMembers() > 0) then
			DrawText('Follower - Follow range: ' .. math.floor(script_follow.followDistance) .. ' yd. ' .. 
			'Master target: ' .. '', x-5, y-4, r, g, b) y = y + 15;
end end
		DrawText('Status: ', x, y, r, g, b); 
		y = y + 15; DrawText(script_follow.message or "error", x, y, 0, 255, 255);
		y = y + 20; DrawText('Combat script status: ', x, y, r, g, b); y = y + 30;
		 x = x -20; RunCombatDraw();
end


function script_followEX:doLoot(localObj)

	if (script_follow.lootObj ~= nil) then
		local _x, _y, _z = script_follow.lootObj:GetPosition();
		local dist = script_follow.lootObj:GetDistance();
	
		-- Loot checking/reset target
		if (GetTimeEX() > script_follow.lootCheck['timer']) then
			if (script_follow.lootCheck['target'] == script_follow.lootObj:GetGUID()) then
				script_follow.lootObj = nil; -- reset lootObj
				ClearTarget();
				script_follow.message = 'Reseting loot target...';
			end
				script_follow.lootCheck['timer'] = GetTimeEX() + 10000; -- 5 sec
			if (script_follow.lootObj ~= nil) then 
				script_follow.lootCheck['target'] = script_follow.lootObj:GetGUID();
			else
				script_follow.lootCheck['target'] = 0;
			end
		return;
		end
	
		if(dist <= script_follow.lootDistance) then
				script_follow.message = "Trying to loot before we follow leader...";
			if (IsMoving() and not localObj:IsMovementDisabed()) then
				StopMoving();
				script_follow.timer = GetTimeEX() + 350;
				return;
			end
	
			if(not IsStanding()) then
				StopMoving();
				script_follow.timer = GetTimeEX() + 350;
				return;
			end
	
			-- Dismount
			if (IsMounted()) then 
				DisMount();
				script_follow.timer = GetTimeEX() + 350;
				return;
			end
	
			if(not script_follow.lootObj:UnitInteract() and not IsLooting()) then
				script_follow.timer = GetTimeEX() + 550;
				return;
			end
	
			if (not LootTarget()) then
				script_follow.timer = GetTimeEX() + 250;
				return;
			else
				script_follow.lootObj = nil;
				script_follow.timer = GetTimeEX() + 250;
			end
		else
			if(script_followMoveToTarget:moveToLoot(GetLocalPlayer(), _x, _y, _z)) then
				return;
			end
		end
	end
end