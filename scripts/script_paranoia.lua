script_paranoia = {

	stopOnLevel = true,		-- stop bot on level up on/off
	exitBot = false,		-- exit bot on level up
	targetedLevel = GetLocalPlayer():GetLevel() + 1,	-- target level to stop bot when we level up.
	deathCounterLogout = 3,	-- death counter until forced logout
	deathCounterExit = true,	-- death counter until exit
	sitParanoid = true,		-- sit paranoid true/false
	paranoidOn = true,		-- paranoid on true/false
	paranoidOnTargeted = true,	-- paranoid when targeted on/off
	useCampfire = true,		-- use bright campfire when paranoid on/off

}


function script_paranoia:checkParanoia()

	-- Check: Paranoid feature

	localObj = GetLocalPlayer();
    		
	-- logout if death counter reached
	if (script_grindEX.deathCounter >= 1) and (script_grindEX.deathCounter >= script_paranoia.deathCounterLogout) then
		StopBot();
		script_grindEX.deathCounter = 0;
		if (script_paranoia.deathCounterExit) then
			Exit();
		end
	end

	-- logout if level reached
	if (script_paranoia.stopOnLevel) then
			selfLevel = GetLocalPlayer():GetLevel();
		if (selfLevel >= self.targetedLevel) then
			StopBot();
			self.targetedLevel = self.targetedLevel + 1;
			if (self.exitBot) then
				Exit();
			end
		end
	end

	-- don't allow sitting when paranoia range is too low
	if (script_grind.paranoidRange <= 149) then
		self.sitParanoid = false;

	elseif (script_grind.paranoidRange >= 150) then

 		self.sitParanoid = true;
	end

	-- if paranoid turned on then do....
		-- paranoid on
	if (not localObj:IsDead() and self.paranoidOn and not IsInCombat()) then 
		if (self.paranoidOnTargeted and script_grind:playersTargetingUs() > 0) then
			script_grind.message = "Player(s) targeting us, pausing...";
			ClearTarget();
			if IsMoving() then
				StopMoving();
			end
			self.waitTimer = GetTimeEX() + 5000;
			return;
		end

		-- if targeted by other players
		if (script_grind:playersWithinRange(script_grind.paranoidRange)) then
			script_grind.message = "Player(s) within paranoid range, pausing...";
			ClearTarget();
			if IsMoving() then
				StopMoving();
			end

			-- use turtle wow server bright campfire on paranoia
			if (HasSpell("Bright Campfire")) and (not IsInCombat()) and (self.useCampfire) then
				if (GetXPExhaustion() == nil) and (not IsInCombat()) and (not localObj:HasBuff("Stealth")) and (not localObj:HasBuff("Bear Form")) and (not localObj:HasBuff("Cat Form")) and (not localObj:HasBuff("Shadowmeld")) then
					if (HasSpell("Bright Campfire")) and (HasItem("Simple Wood")) and (HasItem("Flint and Tinder")) and (not IsSpellOnCD("Bright Campfire")) then
						if (not IsStanding()) then
							JumpOrAscendStart();
						end
						if (not IsSpellOnCD("Bright Campfire")) then
							CastSpellByName("Bright Campfire");
							if (IsStanding()) and (self.sitParanoid) then
								SitOrStand();
							end
							-- wait 2+ mins
							self.waitTimer = GetTimeEX() + 123241;
							return 0;
						end
					end
				end
			end

			-- use shadowmeld on paranoia
			if (HasSpell("Shadowmeld")) then
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
	

			-- rogue stealth while paranoid
			if (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (not localObj:HasBuff("Stealth")) then
				if (CastSpellByName("Stealth")) then
					return 0;
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
				SitOrStand();
				self.waitTimer = GetTimeEX() + 1500;
			end
		return true;
		end
	end
end

function script_paranoia:menu()
		
	-- paranoid on/off button
	wasClicked, script_paranoia.paranoidOn = Checkbox("Enable Paranoia", script_paranoia.paranoidOn);
	
	SameLine();
		
	-- if paranoid on then show rest of paranoia features
	if (script_paranoia.paranoidOn) then

		-- hide and disable sit if paranoid range > x
		if (script_grind.paranoidRange > 149) then
			wasClicked, script_paranoia.sitParanoid = Checkbox("Sit When Paranoid", script_paranoia.sitParanoid);
		end

		-- paranoid on targeted button on/off
		wasClicked, script_paranoia.paranoidOnTargeted = Checkbox("Paranoid When Targeted By Player", script_paranoia.paranoidOnTargeted);

		-- turtle wow server bright campfire button on/off
		if (HasSpell("Bright Campfire")) and (HasItem("Simple Wood")) then
			wasClicked, script_paranoia.useCampfire = Checkbox("Use Bright Campfire When Paranoid", script_paranoia.useCampfire);
		end
		
		Separator();
	
		Text('Paranoia Range');
	
		-- main paranoia range
		script_grind.paranoidRange = SliderInt("P (yd)", 50, 300, script_grind.paranoidRange);
	end

	Separator();

	-- stop bot when level reached button on/off
	wasClicked, script_paranoia.stopOnLevel = Checkbox("Stop Bot When Next Level Reached", script_paranoia.stopOnLevel);
		
	-- if stop on level button checked then...
	if (script_paranoia.stopOnLevel) then
	
		SameLine();
	
		-- show exit bot on level up on/off button
		wasClicked, script_paranoia.exitBot = Checkbox("Exit Bot On Level Up", script_paranoia.exitBot);
	
	end
	
	Text("Stop Bot On "..script_paranoia.deathCounterLogout.. " Deaths    "); 

	SameLine(); 

	-- exit bot when death counter reached on/off
	wasClicked, script_paranoia.deathCounterExit = Checkbox("Exit Bot On "..script_paranoia.deathCounterLogout.." Deaths", script_paranoia.deathCounterExit);

	-- death counter 
	script_paranoia.deathCounterLogout = SliderInt("Deaths", 1, 5, script_paranoia.deathCounterLogout);
		
	Separator();

end