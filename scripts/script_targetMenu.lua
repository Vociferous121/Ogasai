script_targetMenu = {
}

function script_targetMenu:menu()

	local wasClicked = false;

	if (CollapsingHeader("Target Options")) then

		Text(" !! Blacklisting resets when script is reloaded !! ");

		wasClicked, script_grindEX.allowSwim = Checkbox("Allow Swimming (Has Bugs)", script_grindEX.allowSwim);

		wasClicked, script_grindEX.avoidBlacklisted = Checkbox("Avoid Blacklisted Targets (Has Bugs)", script_grindEX.avoidBlacklisted);

		wasClicked, script_grind.skipHardPull = Checkbox("Blacklist Target With More Than 1 Add", script_grind.skipHardPull);
		if (script_grind.skipHardPull) then
			Text("Adjust Blacklist Aggro Range (~10yds per tick)");
			script_aggro.adjustAggro = SliderInt("Adjust Aggro", 3, 10, script_aggro.adjustAggro);
		end

		Separator();
		
		if (Button("BlackList By GUID")) then
			if UnitExists("target") then
				DEFAULT_CHAT_FRAME:AddMessage('Blacklisted "'..GetTarget():GetUnitName()..'" GUID: "'..GetTarget():GetGUID()..'"');
				script_grind:addTargetToBlacklist(GetTarget():GetGUID());
			end
		end
		
		Text('Blacklist Time'); 
		script_grind.blacklistTime = SliderInt("BT (s)", 1, 120, script_grind.blacklistTime);

		Separator();

		Text("Search For Target Distance");
		script_grind.pullDistance = SliderFloat("PD (yd)", 1, 300, script_grind.pullDistance); 
		
		Separator();
		
		Text('Target Level');
		script_grind.minLevel = SliderInt("Min lvl", 1, 60, script_grind.minLevel);
		script_grind.maxLevel = SliderInt("Max lvl", 1, 60, script_grind.maxLevel); 

		Separator();
	
		--wasClicked, script_nav.avoidElite = Checkbox("Avoid Elites (current not working)", script_nav.avoidElite);
		
		--if (script_grind.avoidElite) then
		--	Text("Avoid Elite Range"); 
		--	script_grind.avoidRange = SliderInt("ER (yd)", 1, 100, script_grind.avoidRange);
		--end

		Separator();
		
		if (CollapsingHeader("|+| Skip Creature By Type")) then

			wasClicked, script_grind.skipElites = Checkbox("Skip Elite", script_grind.skipElites);
			SameLine(); wasClicked, script_grind.skipHumanoid = Checkbox("Skip Humanoid", script_grind.skipHumanoid);
			wasClicked, script_grind.skipElemental = Checkbox("Skip Elemental", script_grind.skipElemental);
			SameLine(); wasClicked, script_grind.skipUndead = Checkbox("Skip Undead", script_grind.skipUndead);
			wasClicked, script_grind.skipDemon = Checkbox("Skip Demon", script_grind.skipDemon);
			SameLine(); wasClicked, script_grind.skipBeast = Checkbox("Skip Beast", script_grind.skipBeast);
			wasClicked, script_grind.skipAberration = Checkbox("Skip Abberation", script_grind.skipAberration);
			SameLine(); wasClicked, script_grind.skipDragonkin = Checkbox("Skip Dragonkin", script_grind.skipDragonkin);
			wasClicked, script_grind.skipGiant = Checkbox("Skip Giant", script_grind.skipGiant);
			SameLine(); wasClicked, script_grind.skipMechanical = Checkbox("Skip Mechanical", script_grind.skipMechanical);
			wasClicked, script_grind.skipUnknown = Checkbox("Skip Not specified", script_grind.skipUnknown);
		end
	end
end