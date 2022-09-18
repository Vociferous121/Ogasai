script_grindMenu = {
	selectedHotspotID = 0,
	targetMenu = include("//scripts//script_targetMenu.lua"),
}

function script_grindMenu:printHotspot()
	DEFAULT_CHAT_FRAME:AddMessage('script_grind: Add this hotspot to your database by adding the following line in the setup-function in hotspotDB.lua:');
	DEFAULT_CHAT_FRAME:AddMessage('You can copy the line from logs//.txt');
	local race, level = UnitRace("player"), GetLocalPlayer():GetLevel();
	local x, y, z = GetLocalPlayer():GetPosition();
	local hx, hy, hz = math.floor(x*100)/100, math.floor(y*100)/100, math.floor(z*100)/100;
	local addString = 'hotspotDB:addHotspot("' .. GetMinimapZoneText() .. ' ' .. level .. ' - ' .. level+2 .. '", "' .. race
					.. '", ' .. level .. ', ' .. level+2 .. ', ' .. hx .. ', ' .. hy .. ', ' .. hz .. ');'	
	DEFAULT_CHAT_FRAME:AddMessage(addString);
	ToFile(addString);
end

function script_grindMenu:menu()
	if (not script_grind.pause) then if (Button("Pause Bot")) then script_grind.pause = true; end
	else if (Button("Resume Bot")) then script_grind.myTime = GetTimeEX(); script_grind.pause = false; end end
	SameLine(); if (Button("Reload Scripts")) then coremenu:reload(); end
	SameLine(); if (Button("Exit Bot")) then StopBot(); end
	local wasClicked = false;
	-- Load combat menu by class
	local class = UnitClass("player");
	if (class == 'Mage') then
		script_mage:menu();
	elseif (class == 'Hunter') then
		script_hunter:menu();
	elseif (class == 'Warlock') then
		script_warlock:menu();
	elseif (class == 'Paladin') then
		script_paladin:menu();
	elseif (class == 'Druid') then
		script_druid:menu();
	elseif (class == 'Priest') then
		script_priest:menu();
	elseif (class == 'Warrior') then
		script_warrior:menu();
	elseif (class == 'Rogue') then
		script_rogue:menu();
	elseif (class == 'Shaman') then
		script_shaman:menu();
	end	
	if (CollapsingHeader("Talents, Paranoia & Misc Options")) then
		wasClicked, script_grind.jump = Checkbox("Jump On/Off", script_grind.jump);

	
		if (script_grind.jump) then
			SameLine();
			Text("- Jump Rate 100 = No Jumping!");
			script_grind.jumpRandomFloat = SliderInt("Jump Rate", 86, 100, script_grind.jumpRandomFloat);
		end

		--wasClicked, script_grind.useMount = Checkbox("Use Mount", script_grind.useMount); Text('Dismount range');
		--script_grind.disMountRange = SliderInt("DR (yd)", 1, 100, script_grind.disMountRange); Separator();
		wasClicked, script_grind.autoTalent = Checkbox("Spend Talent Points  ", script_grind.autoTalent);
		SameLine();
		Text("Change Talents In script_talent.lua");
		if (script_grind.autoTalent) then
			Text("Spending Next Talent Point In: " .. (script_talent:getNextTalentName() or " "));
			Separator();
		end
		wasClicked, script_grind.paranoidOn = Checkbox("Enable Paranoia", script_grind.paranoidOn);
		SameLine();
		if (script_grind.paranoidRange > 149) then
			wasClicked, script_grind.sitParanoid = Checkbox("Sit When Paranoid", script_grind.sitParanoid);
		end
		wasClicked, script_grind.paranoidOnTargeted = Checkbox("Paranoid When Targeted By Player", script_grind.paranoidOnTargeted);
	 		
		if (HasSpell("Bright Campfire")) and (HasItem("Simple Wood")) then
			wasClicked, script_grind.useCampfire = Checkbox("Use Bright Campfire When Paranoid", script_grind.useCampfire);
		end

		wasClicked, script_grind.stopOnLevel = Checkbox("Stop Bot When Next Level Reached", script_grind.stopOnLevel);
		
		if (script_grind.stopOnLevel) then
			SameLine();
			wasClicked, script_grind.exitBot = Checkbox("Exit Bot On Level Up", script_grind.exitBot);
		end
		
		Text("Stop Bot On "..script_grind.deathCounterLogout.. " Deaths    "); 
		SameLine(); 
		wasClicked, script_grind.deathCounterExit = Checkbox("Exit Bot On "..script_grind.deathCounterLogout.." Deaths", script_grind.deathCounterExit);
		script_grind.deathCounterLogout = SliderInt("Deaths", 1, 5, script_grind.deathCounterLogout);
		Text('Paranoia Range'); script_grind.paranoidRange = SliderInt("P (yd)", 50, 300, script_grind.paranoidRange);
		
		Separator();

		Text("Script Tick Rate - How Fast The Scripts Run"); script_grind.tickRate = SliderFloat("TR (ms)", 0, 2000, script_grind.tickRate);		
	end

	if (CollapsingHeader("Vendor Options")) then
		wasClicked, script_grind.useVendor = Checkbox("Vendoring On/Off", script_grind.useVendor);
		if (script_grind.useVendor) then 
			script_vendorMenu:menu(); Separator();
		else
			Separator(); Text("If Inventory Is Full - ");
			wasClicked, script_grind.hsWhenFull = Checkbox("Use Hearthstone", script_grind.hsWhenFull); SameLine();
			wasClicked, script_grind.stopWhenFull = Checkbox("Stop The Bot", script_grind.stopWhenFull); Separator();
		end
	end
	if (CollapsingHeader("Path Options")) then
		local wasClicked = false;
		wasClicked, script_grind.autoPath = Checkbox("Auto Pathing (Disable To Use Walk Paths)", script_grind.autoPath);
		if (script_grind.autoPath) then
			wasClicked, script_grind.staticHotSpot = Checkbox("Auto Load Hotspots From - HotspotDB.lua", script_grind.staticHotSpot);

			Text("Select A Hotspot From Database:");

			wasClicked, self.selectedHotspotID = 
				ComboBox("", self.selectedHotspotID, unpack(hotspotDB.selectionList));
			SameLine();

			if Button("Load") then script_grind.staticHotSpot = false; script_nav:loadHotspotDB(self.selectedHotspotID+1); end
			if (Button("Save Current Location As Hotspot")) then script_nav:newHotspot(GetMinimapZoneText() .. ' ' .. GetLocalPlayer():GetLevel() .. ' - ' .. GetLocalPlayer():GetLevel()+2); script_grind.staticHotSpot = false; script_grindMenu:printHotspot(); end
			Text('Distance To Hotspot');
			script_grind.distToHotSpot = SliderInt("DHS (yd)", 1, 1000, script_grind.distToHotSpot); Separator();
		else
			Separator();
			Text("Current Walk Path"); Text("E.g. paths\\1-5 Durotar.xml"); script_grind.pathName = InputText(' ', script_grind.pathName); Separator();
			Text('Next Node Distance'); script_grind.nextToNodeDist = SliderFloat("ND (yd)", 1, 10, script_grind.nextToNodeDist); Separator();
		end
		wasClicked, script_grind.useUnstuck = Checkbox("Use Unstuck Feature (script_unstuck)", script_grind.useUnstuck);
		Separator()
		wasClicked, script_grind.safeRess = Checkbox("Ressurect In Safe Area", script_grind.safeRess);
		Text('Ressurect To Corpse Distance'); script_grind.ressDistance = SliderFloat("RD (yd)", 1, 35, script_grind.ressDistance); Separator();
	end

	script_targetMenu:menu();

	if (CollapsingHeader("Loot Options")) then
		local wasClicked = false;
		wasClicked, script_grind.skipLooting = Checkbox("Skip Looting", script_grind.skipLooting);
		wasClicked, script_grind.skinning = Checkbox("Use Skinning", script_grind.skinning);
		Text('Search For Loot Distance'); script_grind.findLootDistance = SliderFloat("SFL (yd)", 1, 100, script_grind.findLootDistance); Text('Loot Corpse Distance');	 script_grind.lootDistance = SliderFloat("LCD (yd)", 1, 5, script_grind.lootDistance);
	end

	script_gather:menu();

	if (CollapsingHeader('Display Options')) then
		local wasClicked = false;
		wasClicked, script_grind.drawEnabled = Checkbox('Display Status Window', script_grind.drawEnabled);
		wasClicked, script_grind.useExpChecker = Checkbox("Display Exp Tracker", script_grind.useExpChecker);
		wasClicked, script_grind.drawUnits = Checkbox("Display Unit Info On Screen", script_grind.drawUnits);
		wasClicked, script_grind.drawAutoPath = Checkbox('Display Auto-Path Nodes', script_grind.drawAutoPath);
		wasClicked, script_grind.drawPath = Checkbox('Display Move Path', script_grind.drawPath);
		wasClicked, script_grind.drawGather = Checkbox('Display Gather Nodes', script_grind.drawGather);
		wasClicked, script_grind.drawAggro = Checkbox('Display Aggro Range', script_grind.drawAggro);
		end
end