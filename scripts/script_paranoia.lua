script_paranoia = {

	stopOnLevel = false,		-- stop bot on level up on/off
	exitBot = false,		-- exit bot on level up
	targetedLevel = GetLocalPlayer():GetLevel() + 1,	-- target level to stop bot when we level up.
	deathCounterExit = true,	-- death counter until exit
	sitParanoid = false,		-- sit paranoid true/false
	paranoidOn = true,		-- paranoid on true/false
	--paranoidOnTargeted = false,	-- paranoid when targeted on/off
	counted = 5,
}

function script_paranoia:checkParanoia()

	-- Check: Paranoid feature

	localObj = GetLocalPlayer();

	if (script_grindEX.deathCounter >= self.counted) and (script_grindEX.deathCounter >= script_paranoia.counted) then
		StopBot();
		script_grindEX.deathCounter = 0;
		if (script_paranoia.deathCounterExit) then
			return 6;
		end
	end

	-- logout if level reached
	if (script_paranoia.stopOnLevel) then
			selfLevel = GetLocalPlayer():GetLevel();
		if (selfLevel >= self.targetedLevel) and (not IsInCombat()) then
			StopBot();
			self.targetedLevel = self.targetedLevel + 1;
			if (self.exitBot) then
				Exit();
			end
			return;
		end
	end

	-- don't allow sitting when paranoia range is too low
	if (script_grind.paranoidRange <= 200) then
		self.sitParanoid = false;
	end

	-- if paranoid turned on then do....
	if (not localObj:IsDead()) and (self.paranoidOn) and (not IsInCombat()) and (not IsLooting()) then 
		
		self.waitTimer = GetTimeEX() + 3500;

		-- players targeting us
		--if (self.paranoidOnTargeted and script_grind:playersTargetingUs() > 0) then
			--script_grind.message = "Player(s) targeting us, pausing...";
			--self.waitTimer = GetTimeEX() + 2000;
			--if IsMoving() then
			--	StopMoving();
			--end
			--self.waitTimer = GetTimeEX() + 19324;
			--return true;
		--end

		-- if players in range
		if (script_grind:playersWithinRange(script_grind.paranoidRange)) and (not IsLooting()) then
			script_grind.message = "Player(s) within paranoid range, pausing...";
			ClearTarget();
			if IsMoving() then
				StopMoving();
			end

			-- rogue stealth while paranoid
			if (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (not localObj:HasBuff("Stealth")) then
				if (CastSpellByName("Stealth")) then
					return 0;
				end
			end

			-- use shadowmeld on paranoia
			if (HasSpell("Shadowmeld")) and (not localObj:HasBuff("Stealth")) then
				if (not IsSpellOnCD("Shadowmeld")) and (not localObj:HasBuff("Shadowmeld")) and (not localObj:HasBuff("Bear Form")) and
					(not localObj:HasBuff("Dire Bear Form")) and (not localObj:HasBuff("Cat Form")) then
					if (CastSpellByName("Shadowmeld")) then
						return 0;
					end
				elseif (localObj:HasBuff("Bear Form")) then
					if (CastSpellByName("Bear Form")) then
						return 0;
					end
					if (CastSpellByName("Shadowmeld")) then
						return 0;
					end
				end
			end

			-- druid stealth while paranoid
			if (localObj:HasBuff("Cat Form")) and (HasSpell("Prowl")) and (not IsSpellOnCD("Prowl")) and (not localObj:HasBuff("Prowl")) then
				if (CastSpellByName("Prowl")) then
					return 0;
				end
			end

			-- sit when paranoid if enabled
			if (self.sitParanoid) and (IsStanding()) and (not IsInCombat()) then
				self.waitTimer = GetTimeEX() + 2521;
				if (IsMoving()) then
					StopMoving();
					self.waitTimer = GetTimeEX() + 2260;
				end
				if (not script_grind:playersWithinRange(150)) then
					SitOrStand();
					self.waitTimer = GetTimeEX() + 1820;
				end
			end
		return true;
		end
	end
end

function script_paranoia:menu()

	--grind script spend talent points is placed above here in grind menu script
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
			wasClicked, script_paranoia.sitParanoid = Checkbox("Sit When Paranoid", script_paranoia.sitParanoid);
		end

		-- paranoid on targeted button on/off
		--wasClicked, script_paranoia.paranoidOnTargeted = Checkbox("Paranoid When Targeted By Player", script_paranoia.paranoidOnTargeted);

		Separator();
	
		Text('Paranoia Range');
	
		-- main paranoia range
		script_grind.paranoidRange = SliderInt("P (yd)", 45, 300, script_grind.paranoidRange);

		--timer to wait after paranoia
		Text("Wait time after paranoid target leaves");
		script_grind.paranoidSetTimer = SliderInt("Time in Sec", 0, 120, script_grind.paranoidSetTimer);

	end

	Separator();

	-- stop bot when level reached button on/off
	wasClicked, script_paranoia.stopOnLevel = Checkbox("Stop Bot When Next Level Reached", script_paranoia.stopOnLevel);
		
	-- if stop on level button checked then...
	if (script_paranoia.stopOnLevel) then
	
		-- show exit bot on level up on/off button
		wasClicked, script_paranoia.exitBot = Checkbox("Exit Game On Level Up", script_paranoia.exitBot);
	end

	Separator();
	Text("The bot will force stop on x deaths or close the game.");
	Text("You can choose not to close the game.");
	--space looks better for wording
	Text("");
	
	Text("Stop Bot On "..script_paranoia.counted.. " Deaths    "); 

	SameLine(); 

	-- exit bot when death counter reached on/off
	wasClicked, script_paranoia.deathCounterExit = Checkbox("Exit Bot On "..script_paranoia.counted.." Deaths", script_paranoia.deathCounterExit);

	-- death counter 
	script_paranoia.counted = SliderInt("Deaths", 1, 9, script_paranoia.counted);
		
	Separator();

	wasClicked, script_grind.useLogoutTimer = Checkbox("Start Logout Timer", script_grind.useLogoutTimer);

	if (script_grind.useLogoutTimer) then
		SameLine();
		Text("-- Set In Hours");
		script_grind.logoutTime = SliderInt("Hours", 1, 5, script_grind.logoutTime);
	end

	Separator();
end