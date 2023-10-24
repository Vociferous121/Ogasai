script_rotationMenu = {

	drawUnits = true,
	drawAggro = true,
	pause = true,


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

		wasClicked, self.drawEnabled = Checkbox('Show status window', self.drawEnabled);

		wasClicked, self.drawGather = Checkbox('Show gather nodes', self.drawGather);

		wasClicked, self.drawUnits = Checkbox("Show unit info on screen", self.drawUnits);

		wasClicked, self.drawAggro = Checkbox('Show aggro range circles', self.drawAggro);
		
		Separator();

	end
		Text('Script tic rate (ms)');
		self.tickRate = SliderInt("TR", 50, 2000, self.tickRate);

	if (self.drawAggro) then
		Text("Aggro Circle Range");
		self.aggroRangeTank = SliderInt("AR", 30, 300, self.aggroRangeTank);
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