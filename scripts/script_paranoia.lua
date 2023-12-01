script_paranoia = {

	paranoiaEXLoaded = include("scripts\\script_paranoiaEX.lua"),
	paranoiaCheckLoaded = include("scripts\\script_paranoiaCheck.lua"),
	stopOnLevel = false,
	exitBot = false,
	targetedLevel = GetLocalPlayer():GetLevel() + 1,
	deathCounterExit = false,
	sitParanoid = false,
	paranoidOn = true,
	counted = 5,
	ignoreTarget = "Player",
	currentTime = 0,
	doEmote = true,
	didEmote = false,
	paranoiaUsed = false,
	waitTimer = GetTimeEX(),
}

function script_paranoia:checkParanoia()

	localObj = GetLocalPlayer();

	if (script_grindEX.deathCounter >= script_paranoia.counted) and (script_grindEX.deathCounter >= script_paranoia.counted) then
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

			if (script_paranoiaCheck:playersWithinRange(script_grind.paranoidRange)) then
				script_paranoia.paranoiaUsed = true;
			end

			-- do emote. had to double check the variables or it was casting twice
			if (script_grind.playerParanoidDistance <= 30) and (script_paranoia.doEmote) and (not script_paranoia.didEmote) and (script_grind:playersTargetingUs() >= 1) then
				local randomEmote = math.random(0, 100);
				if (script_grind.playerParanoidDistance >= 12) and (randomEmote < 25) then

					self.waitTimer = GetTimeEX() + 1932;
					DoEmote("Wave", script_grind.paranoidTargetName);
					script_paranoia.doEmote = false;
					script_paranoia.didEmote = true;
				
				elseif (script_grind.playerParanoidDistance >= 12) and (randomEmote < 50) then

					self.waitTimer = GetTimeEX() + 1932;
					DoEmote("Dance", script_grind.paranoidTargetName);
					script_paranoia.doEmote = false;
					script_paranoia.didEmote = true;

				elseif (script_grind.playerParanoidDistance >= 12) and (randomEmote < 75) then

					self.waitTimer = GetTimeEX() + 1932;
					DoEmote("Salute", script_grind.paranoidTargetName);
					script_paranoia.doEmote = false;
					script_paranoia.didEmote = true;

				elseif (script_grind.playerParanoidDistance >= 12) and (randomEmote < 100) then

					self.waitTimer = GetTimeEX() + 1932;
					DoEmote("Moo", script_grind.paranoidTargetName);
					script_paranoia.doEmote = false;
					script_paranoia.didEmote = true;
				end

				if (script_grind.playerParanoidDistance <= 12) then
					local otherEmote = math.random(0, 100);

					if (otherEmote < 20) then
						DoEmote("Ponder", script_grind.paranoidTargetName);
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;
					elseif (otherEmote < 35) then
						SendChatMessage("need something?");
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;
					elseif (otherEmote < 50) then
						SendChatMessage("hello");
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;
					elseif (otherEmote < 65) then
						SendChatMessage("moo");
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;
					elseif (otherEmote < 85) then
						DoEmote("moo", script_grind.paranoidTargetName);
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;
					elseif (otherEmote < 100) then
						--SendChatMessage("yes?", "Whisper", nil, script_grind.paranoidTargetName);
						DoEmote("Flex", script_grind.paranoidTargetName);
						script_paranoia.doEmote = false;
						script_paranoia.didEmote = true;
					end
				end	
			end

			script_paranoia.currentTime = GetTimeEX() / 1000;
			script_grind.message = "Player(s) within paranoid range, pausing...";

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
			if (script_paranoia.sitParanoid) and (IsStanding()) and (not IsInCombat()) and (script_grind.playerParanoidDistance >= 180) then
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