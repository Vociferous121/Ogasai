script_paranoia = {

	paranoiaEXLoaded = include("scripts\\script_paranoiaEX.lua"),
	paranoiaCheckLoaded = include("scripts\\script_paranoiaCheck.lua"),
	stopOnLevel = false,
	exitBot = false,
	targetedLevel = GetLocalPlayer():GetLevel() + 1,
	deathCounterExit = false,
	sitParanoid = false,
	paranoidOn = true,
	counted = 10,
	ignoreTarget = "Player",
	currentTime = 0,
	doEmote = true,
	didEmote = false,
	paranoiaUsed = false,
	waitTimer = GetTimeEX(),
}

function script_paranoia:checkParanoia()

	localObj = GetLocalPlayer();

	-- death counter logout when reached
	if (script_grindEX.deathCounter >= script_paranoia.counted) and (script_grindEX.deathCounter >= script_paranoia.counted) then
		DEFAULT_CHAT_FRAME:AddMessage("Stopping - Death counter reached...");
		StopBot();
		script_grindEX.deathCounter = 0;
		if (script_paranoia.deathCounterExit) then
			return 6;
		end
	end

	-- logout if level reached
	if (script_paranoia.stopOnLevel) then
			selfLevel = GetLocalPlayer():GetLevel();
		if (selfLevel >= script_paranoia.targetedLevel) and (not IsInCombat()) then
			StopBot();
			script_paranoia.targetedLevel = script_paranoia.targetedLevel + 1;
			if (script_paranoia.exitBot) then
				Exit();
			end
			return;
		end
	end

	-- don't allow sitting when paranoia range is too low
	if (script_grind.paranoidRange <= 200) then
		script_paranoia.sitParanoid = false;
	end

	-- if paranoid turned on then do....
	if (script_paranoia.paranoidOn) and (not IsLooting()) then

		-- if players in range
		if (script_paranoiaCheck:playersWithinRange(script_grind.paranoidRange)) and (not IsLooting()) then

			-- set paranoia used variable to stop double casting stuff on a return loop
			if (script_paranoiaCheck:playersWithinRange(script_grind.paranoidRange)) then
				script_paranoia.paranoiaUsed = true;
			end

			-- do emote. had to double check the variables or it was casting twice
			if (script_grind.playerParanoidDistance <= 40) and (script_paranoia.doEmote) and (not script_paranoia.didEmote) and (script_grind:playersTargetingUs() >= 1) then

				local randomEmote = math.random(0, 100);

				-- if within range >= 12 but less than 40
					-- do wave
				if (script_grind.playerParanoidDistance >= 12) and (randomEmote < 25) then

					self.waitTimer = GetTimeEX() + 1932;
					DoEmote("Wave", script_grind.paranoidTargetName);
					script_paranoia.doEmote = false;
					script_paranoia.didEmote = true;

					-- do dance
				elseif (script_grind.playerParanoidDistance >= 20) and (randomEmote < 50) then

					self.waitTimer = GetTimeEX() + 1932;
					DoEmote("Dance", script_grind.paranoidTargetName);
					script_paranoia.doEmote = false;
					script_paranoia.didEmote = true;

					-- do salute
				elseif (script_grind.playerParanoidDistance >= 20) and (randomEmote < 75) then

					self.waitTimer = GetTimeEX() + 1932;
					DoEmote("Salute", script_grind.paranoidTargetName);
					script_paranoia.doEmote = false;
					script_paranoia.didEmote = true;

					-- do moo
				elseif (script_grind.playerParanoidDistance >= 20) and (randomEmote < 100) then

					self.waitTimer = GetTimeEX() + 1932;
					DoEmote("Moo", script_grind.paranoidTargetName);
					script_paranoia.doEmote = false;
					script_paranoia.didEmote = true;
				end

				-- distance <= 20 then do
				if (script_grind.playerParanoidDistance <= 20) then

					local otherEmote = math.random(0, 100);

						-- do ponder
					if (otherEmote < 20) then
						DoEmote("Ponder", script_grind.paranoidTargetName);
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;

						-- send message in chat
					elseif (otherEmote < 35) then
						SendChatMessage("need something?");
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;

						-- send message in chat
					elseif (otherEmote < 50) then
						SendChatMessage("hello");
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;

						-- send message in chat
					elseif (otherEmote < 65) then
						SendChatMessage("moo");
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;
						
						-- do emote moo
					elseif (otherEmote < 85) then
						DoEmote("moo", script_grind.paranoidTargetName);
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;

						-- send whisper
					elseif (otherEmote < 100) then
						--SendChatMessage("yes?", "Whisper", nil, script_grind.paranoidTargetName);
						DoEmote("Flex", script_grind.paranoidTargetName);
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;
					end
				end	
			end

			-- start paranoid timer
			script_paranoia.currentTime = GetTimeEX() / 1000;
			script_grind.message = "Player(s) within paranoid range, pausing...";

			-- check stealth for paranoia
			if (not IsMounted()) then
				script_paranoiaEX:checkStealth2();
			end

			-- sit when paranoid if enabled
			if (script_paranoia.sitParanoid) and (IsStanding()) and (not IsInCombat()) and (script_grind.playerParanoidDistance >= 180) and (not IsMounted()) then
				script_paranoia.waitTimer = GetTimeEX() + 2521;
				if (IsMoving()) then
					StopMoving();
					script_paranoia.waitTimer = GetTimeEX() + 2260;
				end

				-- afk when paranoid and sitting
				if (IsStanding()) and (not IsInCombat()) and (GetLocalPlayer():GetUnitsTarget() == 0) then
				SitOrStand();
					if (not IsStanding()) and (not IsInCombat()) then
						UseAction(script_grind.afkActionSlot, 0, 0);
						script_paranoia.waitTimer = GetTimeEX() + 2500;
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