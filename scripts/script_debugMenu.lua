script_debugMenu = {

}

function script_debugMenu:menu()

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
				local a = "true";
				Text("Target has ranged weapon? - " ..a);
			else
			
				-- false target has weapon
				local a = "false";
				Text("Target has ranged weapon? - " ..a);
			end
		
			-- true target is casting
			if (GetLocalPlayer():GetUnitsTarget():IsCasting()) then

				-- true target is casting
				local a = "true";
				Text("Target is casting? - " ..a);
			else

				-- false target is casting
				local a = "false";
				Text("Target is casting? - " ..a);
			end
		else

			-- show the text is casting or has ranged weapon
			Text("Target has ranged weapon? - No Target!");
			Text("Target is casting? - No Target!");
		end

		-- show grinder enemy object name and distance
		if (script_grind.enemyObj ~= 0) and (script_grind.enemyObj ~= nil) then
			local a = script_grind.enemyObj:GetUnitName();
			local b = math.floor(script_grind.enemyObj:GetDistance());
			Text("Grinder enemyObj - " ..a.. " " ..b.. " (yds)");
			
		else

			-- else show no target text
			Text("Grinder enemyObj - No Target!");
		end
		
		-- make local var
		if (1 == 1) then

			-- show vendor status
			local a = script_vendor.status;
			Text("Vendor status - " ..a);
		end

			-- separator for next menu - counter menu
		Separator();
	end
end