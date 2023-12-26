script_drawStatus = {

}

-- draw status text and display boxes on screen
	-- self.message follow.message grind.message etc

function script_drawStatus:draw()
	-- color
	local r, g, b = 0, 0, 0;

	-- position
	local y, x, width = 120, 25, 370;
	local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
	if (onScreen) then
		y, x = tY-25, tX+75;
	end

	-- info
	if (not script_grind.pause) then

	if (script_grind.adjustText) and (script_grind.drawEnabled) then
		x = x + script_grind.adjustX;
		y = y + script_grind.adjustY;
	end

	if (script_grind.drawEnabled) then
		--DrawRect(x - 10, y - 7, x + width, y + 140, 255, 255, 0, 10, 77, 0);
		--DrawRectFilled(x - 10, y - 7, x + width, y + 140, 0, 0, 0, 80, 10, 77);
		DrawText('Grinder : Pull range : ' .. math.floor(script_grind.pullDistance) .. ' yd. ' .. 
			 	'Level range : ' .. script_grind.minLevel .. ' - ' .. script_grind.maxLevel, x, y-4, r+255, g+255, b+0) y = y + 15;
	
		DrawText('Grinder Status:', x, y, r+255, g+255, b+0);
		DrawText(script_grind.message or "error", x + 115, y, 255, 255, 255);
		DrawText("_______________", x, y+3, r+255, g+255, b);
		y = y + 20; DrawText('Combat Script Status:', x, y, r+255, g+255, b+0); y = y + 15;
		if (script_grind.showClassOptions) then RunCombatDraw(); end
		DrawText("_____________________", x, y-12, r+255, g+255, b);
	
		if (script_grind.useVendor) then
			DrawText('Vendor - ' .. script_vendorMenu:getInfo(), x, y, r+255, g+255, b+0); y = y + 15;
			DrawText('Vendor Status: ', x, y, r+255, g+255, b+0);
			DrawText(script_vendor:getMessage(), x+105, y, 0, 255, 255);
		end
	
		local time = math.floor(((GetTimeEX()-script_grind.newTargetTime)/1000)); 
	
		if (script_grind.enemyObj ~= 0 and script_grind.enemyObj ~= nil and not script_grind.enemyObj:IsDead()) then
	
			if (script_grind.useVendor) then
				y = y + 20;
			end
	
			--DrawRect(x - 10, y + 19, x + width, y + 45, 255, 255, 0,  1, 1, 1);
			--DrawRectFilled(x-10, y+20, x + width, y + 45, 0, 0, 0, 100, 0, 0);
			DrawText('Blacklist-timer: ' .. script_grind.enemyObj:GetUnitName() .. ': ' .. time .. ' s.', x, y+3, 0, 255, 120); 
			DrawText('Blacklisting target after ' .. script_grind.blacklistTime .. " s. (If above 92% HP.)", x, y+18, 0, 255, 120);
		end
			
	end
	end
		if (script_grind.pause) then
			if (script_grind.adjustText) and (script_grind.drawEnabled) then
				x = x + script_grind.adjustX;
				y = y + script_grind.adjustY;
			end
			DrawText('Grinder paused by user...', x-5, y-4, r+255, g+122, b+122);
		end
end

function script_drawStatus:drawSetup()

	if (script_grind.drawAggro) then
		script_aggro:drawAggroCircles(45);
	end
	if (script_grind.drawAggro2) then
		script_aggro:drawAggroCircles2(script_aggro.addsRange);
	end
	if (script_grind.autoPath and script_grind.drawAutoPath) then
		script_drawData:drawSavedTargetLocations();
	end
	if (script_grind.drawGather) then
		script_gather:drawGatherNodes();
	end
	if (script_grind.drawPath) then
		if (IsMoving()) then
			script_drawData:drawPath();
		end
	end
	if (script_grind.drawUnits) then
		script_drawData:drawUnitsDataOnScreen();
	end
	if (not script_grind.drawEnabled and script_grind.showClassOptions) then
		RunCombatDraw();
	end
	if (not script_grind.drawEnabled) then
		return;
	end
end