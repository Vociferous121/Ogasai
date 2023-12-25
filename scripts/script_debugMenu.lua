script_debugMenu = {

}

function script_debugMenu:menu()

	if (CollapsingHeader("Debug Info")) then

		-- debug info

		-- tickrate
		Text("Script Tick Rate - " ..script_grind.tickRate);

		-- are we indoors?
		if (IsIndoors()) then
			local a = "true";
			Text("Are we indoors? - " ..a);
	
		else
			local a = "false";
			Text("Are we indoors? - " ..a);
		end

		-- target has ranged weapon?
		if (GetLocalPlayer():GetUnitsTarget() ~= 0) then
			if (GetLocalPlayer():GetUnitsTarget():HasRangedWeapon()) then
				local a = "true";
				Text("Target has ranged weapon? - " ..a);
			else
				local a = "false";
				Text("Target has ranged weapon? - " ..a);
			end
			if (GetLocalPlayer():GetUnitsTarget():IsCasting()) then
				local a = "true";
				Text("Target is casting? - " ..a);
			else
				local a = "false";
				Text("Target is casting? - " ..a);
			end
		else
			Text("Target has ranged weapon? - No Target!");
			Text("Target is casting? - No Target!");
		end

		if (script_grind.enemyObj ~= 0) and (script_grind.enemyObj ~= nil) then
			local a = script_grind.enemyObj:GetUnitName();
			local b = math.floor(script_grind.enemyObj:GetDistance());
			Text("Grinder enemyObj - " ..a.. " " ..b.. " (yds)");
			
		else
			Text("Grinder enemyObj - No Target!");
		end
		
		-- make local var
		if (1 == 1) then
			local a = script_vendor.status;
			Text("Vendor status - " ..a);
		end

		Separator();
	end
end