script_paranoiaMenu = {

}

function script_paranoiaMenu:menu()

		Separator();

	wasClicked, script_grind.jump = Checkbox("Random Jump", script_grind.jump);
	
	if (script_grind.jump) then
		SameLine();
		Text("- 100 = No Jumping");
		script_grind.jumpRandomFloat = SliderInt("Jump Rate", 92, 100, script_grind.jumpRandomFloat);
	end
		
	-- paranoid on/off button
	wasClicked, script_paranoia.paranoidOn = Checkbox("Enable Paranoia", script_paranoia.paranoidOn);
		
	SameLine();
		
	-- if paranoid on then show rest of paranoia features
	if (script_paranoia.paranoidOn) then

		-- hide and disable sit if paranoid range > x
		if (script_grind.paranoidRange >= 200) then
			Separator();
			wasClicked, script_paranoia.sitParanoid = Checkbox("Sit When Paranoid", script_paranoia.sitParanoid);
			if (script_paranoia.sitParanoid) then
				if (script_grind.afkActionSlot == "24") then
					Text("Add MACRO /afk to page 2 action slot 24 (= sign)");
				end
				script_grind.afkActionSlot = InputText("AFK Action Slot", script_grind.afkActionSlot);
			end

		end

		Separator();
	
		Text('Paranoia Range');
	
		script_grind.paranoidRange = SliderInt("P (yd)", 15, 300, script_grind.paranoidRange);

		Text("Wait time after paranoid target leaves");
		script_grind.paranoidSetTimer = SliderInt("Time in Sec", 0, 120, script_grind.paranoidSetTimer);

		Text("Logout Timer When Paranoid - 600 = 10 mintues!");
		script_grind.setParanoidTimer = SliderInt("Seconds", 10, 600, script_grind.setParanoidTimer);

		Text("Ignore Player Using Paranoia");
		script_paranoia.ignoreTarget = InputText("Player", script_paranoia.ignoreTarget);

	end

	Separator();

	wasClicked, script_paranoia.stopOnLevel = Checkbox("Stop Bot When Next Level Reached", script_paranoia.stopOnLevel);
		
	if (script_paranoia.stopOnLevel) then
	
		wasClicked, script_paranoia.exitBot = Checkbox("Exit Game On Level Up", script_paranoia.exitBot);
	end

	Separator();
	Text("The bot will force stop on x deaths or close the game.");
	
	Text("Stop Bot On "..script_paranoia.counted.. " Deaths    "); 

	SameLine(); 

	wasClicked, script_paranoia.deathCounterExit = Checkbox("Exit Bot On "..script_paranoia.counted.." Deaths", script_paranoia.deathCounterExit);

	script_paranoia.counted = SliderInt("Deaths", 1, 10, script_paranoia.counted);
		
	Separator();

	wasClicked, script_grind.useLogoutTimer = Checkbox("Start Logout Timer", script_grind.useLogoutTimer);

	if (script_grind.useLogoutTimer) then
		SameLine();
		Text("-- Set In Hours");
		script_grind.logoutTime = SliderInt("Hours", 1, 5, script_grind.logoutTime);
	end

	Separator();
end