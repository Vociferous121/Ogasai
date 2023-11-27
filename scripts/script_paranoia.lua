script_paranoia = {

	stopOnLevel = false,		-- stop bot on level up on/off
	exitBot = false,		-- exit bot on level up
	targetedLevel = GetLocalPlayer():GetLevel() + 1,	-- target level to stop bot when we level up.
	deathCounterExit = false,	-- death counter until exit
	sitParanoid = false,		-- sit paranoid true/false
	paranoidOn = true,		-- paranoid on true/false
	--paranoidOnTargeted = false,	-- paranoid when targeted on/off
	counted = 5,
	ignoreTarget = "Player",
	currentTime = 0,
	doEmote = true,
	didEmote = false,
	paranoiaUsed = false,
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
	if (self.paranoidOn) and (not IsInCombat()) and (not IsLooting()) then

		self.waitTimer = GetTimeEX() + 3500;

		-- if players in range
		if (script_grind:playersWithinRange(script_grind.paranoidRange)) and (not IsLooting()) then

			if (script_grind:playersWithinRange(script_grind.paranoidRange)) then
				self.paranoiaUsed = true;
			end

			-- do wave emote. had to double check the variables or it was casting twice
			if (script_grind.playerParanoidDistance <= 15) and (self.doEmote) and (not self.didEmote) then
				DoEmote("Wave", script_grind.paranoidTargetName);
				self.doEmote = false;
				self.didEmote = true;
			end

			script_paranoia.currentTime = GetTimeEX() / 1000;
			
			self.waitTimer = GetTimeEX() + 4100;
			script_grind:setWaitTimer(2700);

			script_grind.message = "Player(s) within paranoid range, pausing...";
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

			-- druid cat form and stealth while paranoid
			if (not localObj:HasBuff("Cat Form")) and (not localObj:HasBuff("Bear Form")) and (HasSpell("Cat Form")) and (GetLocalPlayer():GetManaPercentage() >= 40) and (IsStanding()) then
				if (CastSpellByName("Cat Form")) then
					return 0;
				end
			end
			if (localObj:HasBuff("Cat Form")) and (HasSpell("Prowl")) and (not IsSpellOnCD("Prowl")) and (not localObj:HasBuff("Prowl")) then
				if (CastSpellByName("Prowl")) then
					return 0;
				end
			end

			-- sit when paranoid if enabled
			if (self.sitParanoid) and (IsStanding()) and (not IsInCombat()) and (script_grind.playerParanoidDistance >= 180) then
				self.waitTimer = GetTimeEX() + 2521;
				if (IsMoving()) then
					StopMoving();
					self.waitTimer = GetTimeEX() + 2260;
				end

				-- afk when paranoid and sitting
				if (IsStanding()) and (not IsInCombat()) and (GetLocalPlayer():GetUnitsTarget() == 0) then
				SitOrStand();
					if (not IsStanding()) and (not IsInCombat()) then
						UseAction(script_grind.afkActionSlot, 0, 0);
						self.waitTimer = GetTimeEX() + 2500;
						script_grind:setWaitTimer(2500);
						script_grind.undoAFK = true;
						return true;
					end
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
			Separator();
			wasClicked, script_paranoia.sitParanoid = Checkbox("Sit When Paranoid", script_paranoia.sitParanoid);
			if (script_paranoia.sitParanoid) then
				if (script_grind.afkActionSlot == "24") then
					Text("Add MACRO /afk to page 2 action slot 24 (= sign)");
				end
				script_grind.afkActionSlot = InputText("AFK Action Slot", script_grind.afkActionSlot);
			end

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

		--logout timer
		Text("Logout Timer When Paranoid - 600 = 10 mintues!");
		script_grind.setParanoidTimer = SliderInt("Seconds", 10, 600, script_grind.setParanoidTimer);

		-- ignore target
		Text("Ignore Player Using Paranoia");
		script_paranoia.ignoreTarget = InputText("Player", script_paranoia.ignoreTarget);

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