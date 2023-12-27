script_debugMenu = {

}

function script_debugMenu:menu()

	-- show debug menu
	if (CollapsingHeader("Debug Info")) then

		-- debug info

		-- tickrate
		Text("Script Tick Rate - " ..script_grind.tickRate);

		-- are we indoors?
		if (IsIndoors()) then
			
			-- true we are indoors
			local a = "true";
			Text("Are we indoors? - " ..a);
	
		else

			-- false we are indoors
			local a = "false";
			Text("Are we indoors? - " ..a);
		end

		-- target has ranged weapon?
		if (GetLocalPlayer():GetUnitsTarget() ~= 0) then
			if (GetLocalPlayer():GetUnitsTarget():HasRangedWeapon()) then

				-- true target has weapon
				local b = "true";
				Text("Target has ranged weapon? - " ..b);
			else
			
				-- false target has weapon
				local b = "false";
				Text("Target has ranged weapon? - " ..b);
			end
		
			-- true target is casting
			if (GetLocalPlayer():GetUnitsTarget():IsCasting()) then

				-- true target is casting
				local c = "true";
				Text("Target is casting? - " ..c);
			else

				-- false target is casting
				local c = "false";
				Text("Target is casting? - " ..c);
			end
		else

			-- show the text is casting or has ranged weapon
			Text("Target has ranged weapon? - No Target!");
			Text("Target is casting? - No Target!");
		end

		-- show grinder enemy object name and distance
		if (script_grind.enemyObj ~= 0) and (script_grind.enemyObj ~= nil) then

			-- grinder object
			local d = script_grind.enemyObj:GetUnitName();

			-- grinder object distance
			local ee = script_grind.enemyObj;
			local e = math.floor(ee:GetDistance());

			-- show distance
			Text("Grinder enemyObj - " ..d.. " " ..e.. " (yds)");
			
		else

			-- else show no target text
			Text("Grinder enemyObj - No Target!");
		end

			-- show vendor status
			local f = script_vendor.status;
			Text("Vendor status - " ..f);

			-- show blacklist time/new target time out of combat
			local gg = script_grind.newTargetTime;
			local g = (GetTimeEX()-gg)/1000;
			Text("Blacklist time : " ..g.. " sec");

			-- separator for next menu - counter menu
		Separator();
	end
end