script_rotationMenu = {

	drawUnits = true,
	drawAggro = true,
	pause = true,
	adjustTickRate = false,


}

function script_rotationMenu:menu()
	if (not self.pause) then 
		if (Button("Pause")) then 
			self.pause = true; 
		end
	else 
		if (Button("Resume")) then 
			self.pause = false; 
		end 
	end

	SameLine(); 

	if (Button("Reload Scripts")) then 
		coremenu:reload(); 
	end

	SameLine(); 
	
	if (Button("Turn Off")) then 
		StopBot(); 
	end

	Separator();

	-- Load combat menu by class
	local class = UnitClass("player");
	if (class == 'Mage') then
		script_mageEX:menu();
	elseif (class == 'Hunter') then
		script_hunterEX:menu();
	elseif (class == 'Warlock') then
		script_warlockEX:menu();
	elseif (class == 'Paladin') then
		script_paladinEX:menu();
	elseif (class == 'Druid') then
		script_druidEX:menu();
	elseif (class == 'Priest') then
		script_priestEX:menu();
	elseif (class == 'Warrior') then
		script_warriorEX:menu();
	elseif (class == 'Rogue') then
		script_rogueEX:menu();
	elseif (class == 'Shaman') then
		script_shamanEX:menu();
	end	

	Separator();

	if (CollapsingHeader('Display options')) then
		if (CollapsingHeader("-- Radar - EXPERIMENTAL")) then
			script_radar:menu();
		end

		local wasClicked = false;

		wasClicked, script_rotation.drawEnabled = Checkbox('Show status window', script_rotation.drawEnabled);

		wasClicked, script_rotation.drawGather = Checkbox('Show gather nodes', script_rotation.drawGather);

		wasClicked, script_rotation.drawUnits = Checkbox("Show unit info on screen", script_rotation.drawUnits);

		wasClicked, script_rotation.drawAggro = Checkbox('Show aggro range circles', script_rotation.drawAggro);
		
		Separator();

	end
	if (CollapsingHeader("Script Tick Rate")) then
		wasClicked, script_rotation.adjustTickRate = Checkbox("Adjust Tick Rate !! Caution !!", script_rotation.adjustTickRate);
		Text('(ms) How Fast Bot Reacts');
		script_rotation.tickRate = SliderInt("TR", 50, 2000, script_rotation.tickRate);
	end
	if (script_rotation.drawAggro) then
		Text("Aggro Circle Range");
		script_rotation.aggroRangeTank = SliderInt("AR", 30, 300, script_rotation.aggroRangeTank);
	end
	
	if (HasItem("Unlit Poor Torch")) then
			Separator();
			wasClicked, script_survivalProf.useTorch = Checkbox("Use Torches to level Survival", script_survivalProf.useTorch);
		if (script_survivalProf.useTorch) then
			Text("Please open the trade skill window");
			script_survivalProf:openMenu();
		end
	end	

	if (HasSpell("Bright Campfire")) and (HasItem("Simple Wood")) and (HasItem("Flint and Tinder")) then
		wasClicked, script_survivalProf.useCampfire = Checkbox("Use Campfires", script_survivalProf.useCampfire);
	end

	-- FIRST AID WORKS PLANS TO IMPLEMENT MAKE BANADAGES WHILE BOTTING AND USE THEM
	--if (HasSpell("First Aid")) then
	--	Text("IN PROGRESS");
	--	wasClicked, script_firstAid.showFirstAid = Checkbox("Show First Aid Skill", script_firstAid.showFirstAid);
	--end
	--if (script_firstAid.showFirstAid) then
	--	script_firstAid:Menu();
	--end
end