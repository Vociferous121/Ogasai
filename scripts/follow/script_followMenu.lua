script_followMenu = {

		drawAggroRange = 100,

}

function script_followMenu:menu()

	local pg = math.floor(GetLoadNavmeshProgress()*100); if pg ~= 100 then Text("Navmesh Loading "..pg.."  "); end
	local mt = script_followMoveToTarget.used; SameLine(); Text(""..mt.." Nav Resets Used....");
	if (not script_follow.pause) then if (Button("Pause Bot")) then	script_follow.pause = true; end elseif	(Button("Resume Bot")) then script_follow.pause = false; script_follow.myTime = GetTimeEX(); end SameLine();
	if (Button("Reload Scripts")) then coremenu:reload(); end SameLine(); if (Button("Exit Bot")) then StopBot(); end

	Separator();
	
	if (CollapsingHeader("Group Options")) then

		wasClicked, script_followDoVendor.useVendor = Checkbox("Use Vendoring", script_followDoVendor.useVendor);
			Text("Assist in combat? ")
			
			wasClicked, script_follow.assistInCombat = Checkbox("Assist Party Leader", script_follow.assistInCombat);

			Separator();

			if (script_follow.assistInCombat) then
				local this = script_follow.followLeaderDistance;
				wasClicked, script_follow.limitAttackDist = Checkbox("Limit Attack Range To Follow Distance "..this.. "yds", script_follow.limitAttackDist);

				Text("Target Health to begin attacking");
				script_follow.dpsHP = SliderInt("Health", 0, 100, script_follow.dpsHP);
			
				
			end
			
			Separator();

			Text("Distance to follow Party Leader  ");
			script_follow.followLeaderDistance = SliderInt("Follow Leader Distance (yd)", 5, 45, script_follow.followLeaderDistance);

			SameLine();

			wasClicked, script_follow.followMember = Checkbox("Follow Party Member", script_follow.followMember);
			wasClicked, script_follow.unstuck = Checkbox("Use UnStuck Script", script_follow.unstuck);
			wasClicked, script_follow.randomFollow = Checkbox("Randomly Adjust Follow Distance", script_follow.randomFollow);
			if (UnitClass('player') == "Hunter") then
				script_follow.randomFollow = false;
			end
			if (script_follow.randomFollow) then
				local followTimer = math.floor((GetTimeEX() - script_follow.followTimer) / 1000);
				SameLine();
				Text(followTimer);
			end
			
			Separator();
			
			if (script_follow.followMember) then
				Text("This is the issue with the follower. It will attempt to follow");
				Text("party members AND the party leader at the same time... ");
				Text("use with caution");
				Separator();
			end

			if (CollapsingHeader("|+| Loot Options")) then
				Text("Loot options:");
				wasClicked, script_follow.skipLooting = Checkbox("Skip Looting", script_follow.skipLooting);
				script_follow.findLootDistance = SliderInt("Find Loot Distance (yd)", 5, 40, script_follow.findLootDistance);	
				script_follow.lootDistance = SliderInt("Loot Distance (yd)", 1, 6, script_follow.lootDistance);
			end
	
		end
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
	elseif (class == 'Druid') and (script_follow.assistInCombat) then
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

	if (class == 'Priest') and (CollapsingHeader("Priest Group Heals - Follower Script")) then


		-- turn ALL heals on/off for group
		wasClicked, script_priestFollowerHeals.enableHeals = Checkbox("Turn On/Off all heals for the group!", script_priestFollowerHeals.enableHeals);

		-- Lesser Heal
		if (GetLocalPlayer():GetLevel() < 20) then
			Text("Lesser Heal Options -"); SameLine(); Text("Turn On/Off above");
			script_priestFollowerHeals.lesserHealMana = SliderInt("LH Above Mana %", 1, 99, script_priestFollowerHeals.lesserHealMana);
			script_priestFollowerHeals.partyLesserHealHealth = SliderInt("LH Below Health %", 1, 99, script_priestFollowerHeals.partyLesserHealHealth);
			Separator();
		end

		-- Renew
		Text("Renew Options -"); SameLine(); 
		wasClicked, script_priestFollowerHeals.clickRenew = Checkbox("Renew On/Off", script_priestFollowerHeals.clickRenew);
		script_priestFollowerHeals.renewMana = SliderInt("Renew Above Mana %", 1, 99, script_priestFollowerHeals.renewMana);
		script_priestFollowerHeals.partyRenewHealth = SliderInt("Renew Below Health %", 1, 99, script_priestFollowerHeals.partyRenewHealth);

		-- Shield
		Text("Shield Options -"); SameLine(); 
		wasClicked, script_priestFollowerHeals.clickShield = Checkbox("Shield On/Off", script_priestFollowerHeals.clickShield);
		script_priestFollowerHeals.shieldMana = SliderInt("Shield Above Mana %", 1, 99, script_priestFollowerHeals.shieldMana);
		script_priestFollowerHeals.partyShieldHealth = SliderInt("Shield Below Health %", 1, 99, script_priestFollowerHeals.partyShieldHealth);

		-- Flash Heal
		if (HasSpell("Flash Heal")) then
		Text("Flash Heal Options -"); SameLine();
		wasClicked, script_priestFollowerHeals.clickFlashHeal = Checkbox("Flash Heal On/Off", script_priestFollowerHeals.clickFlashHeal);
		script_priestFollowerHeals.flashHealMana = SliderInt("FH Above Mana %", 1, 99, script_priestFollowerHeals.flashHealMana);
		script_priestFollowerHeals.partyFlashHealHealth = SliderInt("FH Below Health %", 1, 99, script_priestFollowerHeals.partyFlashHealHealth);
		end
		
		-- Greater Heal
		if (HasSpell("Greater Heal")) then
		Text("Greater Heal Options -"); SameLine();
		wasClicked, script_priestFollowerHeals.clickGreaterHeal = Checkbox("Greater Heal On/Off", script_priestFollowerHeals.clickGreaterHeal);
		script_priestFollowerHeals.greaterHealMana = SliderInt("GH Above Mana %", 1, 99, script_priestFollowerHeals.greaterHealMana);
		script_priestFollowerHeals.partyGreaterHealHealth = SliderInt("GH Below Health %", 1, 99, script_priestFollowerHeals.partyGreaterHealHealth);	
		end

		-- Heal(spell)
		Text("Heal(spell) Options -"); SameLine();
		wasClicked, script_priestFollowerHeals.clickHeal = Checkbox("Heal(spell) On/Off", script_priestFollowerHeals.clickHeal);
		script_priestFollowerHeals.healMana = SliderInt("Heal Above Mana %", 1, 99, script_priestFollowerHeals.healMana);
		script_priestFollowerHeals.partyHealHealth = SliderInt("Heal Below Health %", 1, 99, script_priestFollowerHeals.partyHealHealth);
	end

	if  (class == 'Paladin') and (CollapsingHeader("Paladin Group Heals Follower Script")) then

		-- turn ALL heals on/off for group
		wasClicked, script_paladinFollowerHeals.enableHeals = Checkbox("Turn On/Off all heals for the group!", script_paladinFollowerHeals.enableHeals);

		-- Holy Light
		Text("Holy Light Options -"); SameLine();
		wasClicked, script_paladinFollowerHeals.clickHolyLight = Checkbox("Holy Light On/Off", script_paladinFollowerHeals.clickHolyLight);
		script_paladinFollowerHeals.holyLightMana = SliderInt("HL Above Mana %", 1, 99, script_paladinFollowerHeals.holyLightMana);
		script_paladinFollowerHeals.partyHolyLightHealth = SliderInt("Holy Light Health%", 1, 99, script_paladinFollowerHeals.partyHolyLightHealth);
		Separator();

		-- Flash of Light
		Text("Flash of Light Options -"); SameLine();
		wasClicked, script_paladinFollowerHeals.clickFlashOfLight = Checkbox("Flash of Light On/Off", script_paladinFollowerHeals.clickFlashOfLight);
		script_paladinFollowerHeals.flashOfLightMana = SliderInt("FoL Above Mana %", 1, 99, script_paladinFollowerHeals.flashOfLightMana);
		script_paladinFollowerHeals.partyFlashOfLightHealth = SliderInt("FoL Below Health %", 1, 99, script_paladinFollowerHeals.partyFlashOfLightHealth);
		script_paladinFollowerHeals.layOnHandsHealth = SliderInt("LoH Below Health %", 5, 20, script_paladinFollowerHeals.layOnHandsHealth);
		script_paladinFollowerHeals.bopHealth = SliderInt("BoP Below Health %", 1, 25, script_paladinFollowerHeals.bopHealth);
	end

	if (class == 'Druid') and (CollapsingHeader("Druid Group Heals Follower Script")) then

		-- turn ALL heals on/off for group
		wasClicked, script_druidFollowerHeals.enableHeals = Checkbox("Turn On/Off all heals for the group!", script_druidFollowerHeals.enableHeals);

		-- Healing Touch
		Text("Healing Touch Options -"); SameLine();
		wasClicked, script_druidFollowerHeals.clickHealingTouch = Checkbox("Healing Touch On/Off", script_druidFollowerHeals.clickHealingTouch);
		script_druidFollowerHeals.healingTouchMana = SliderInt("HT Mana%", 1, 99, script_druidFollowerHeals.healingTouchMana);
		script_druidFollowerHeals.healingTouchHealth = SliderInt("HT Health%", 1, 99, script_druidFollowerHeals.healingTouchHealth);
		Separator();

		-- Regrowth
		Text("Regrwoth Options -"); SameLine();
		wasClicked, script_druidFollowerHeals.clickRegrowth = Checkbox("Regrowth On/Off", script_druidFollowerHeals.clickRegrowth);
		script_druidFollowerHeals.regrowthMana = SliderInt("Re Mana%", 1, 99, script_druidFollowerHeals.regrowthMana);
		script_druidFollowerHeals.regrowthHealth = SliderInt("Re Health%", 1, 99, script_druidFollowerHeals.regrowthHealth);
		Separator();

		-- Rejuvenation
		Text("Rejuvenation Options -");
		script_druidFollowerHeals.rejuvenationMana = SliderInt("R Mana%", 1, 99, script_druidFollowerHeals.rejuvenationMana);
		script_druidFollowerHeals.rejuvenationHealth = SliderInt("R Health%", 1, 99, script_druidFollowerHeals.rejuvenationHealth);
		Separator();	

		-- Swiftmend
		Text("Swiftmend Options");
		script_druidFollowerHeals.swiftMendHealth = SliderInt("Swiftmend Health", 1, 80, script_druidFollowerHeals.swiftMendHealth);
		Separator();
	end

	if (class == 'Shaman') and (CollapsingHeader("Shaman Group Heals Follower Script")) then

		Text("CURRENTLY BROKEN UNKNOWN ISSUE");
		-- turn ALL heals on/off for group
		wasClicked, script_shamanFollowerHeals.enableHeals = Checkbox("Turn On/Off all heals for the group!", script_shamanFollowerHeals.enableHeals);
		
		Text("Healing Wave Health");
		script_shamanFollowerHeals.healingWaveHealth = SliderInt("party member HP", 1, 100, script_shamanFollowerHeals.healingWaveHealth);
		
		Text("Healing Wave Mana");
		script_shamanFollowerHeals.healingWaveMana = SliderInt("selfmana", 1, 100, script_shamanFollowerHeals.healingWaveMana);
		
		Text("Lesser Healing Wave Health");
		script_shamanFollowerHeals.lesserHealingWaveHealth = SliderInt("Party member HP", 1, 100, script_shamanFollowerHeals.lesserHealingWaveHealth);
		
		Text("Lesser Healing Wave Mana");
		script_shamanFollowerHeals.lesserHealingWaveMana = SliderInt("Self Mana", 1, 100, script_shamanFollowerHeals.lesserHealingWaveMana);
		
		Text("Totems");
		wasClicked, script_shamanFollowerHeals.useStrengthOfEarthTotem = Checkbox("Strength of Earth", script_shamanFollowerHeals.useStrengthOfEarthTotem);
		wasClicked, script_shamanFollowerHeals.useStoneskinTotem = Checkbox("Stoneskin", script_shamanFollowerHeals.useStoneskinTotem);
		wasClicked, script_shamanFollowerHeals.useHealingStreamTotem = Checkbox("Healing Stream", script_shamanFollowerHeals.useHealingStreamTotem);
		wasClicked, script_shamanFollowerHeals.useManaSpringTotem = Checkbox("Mana Spring", script_shamanFollowerHeals.useManaSpringTotem);
	end

	if (script_followDoVendor.useVendor) then
		if (CollapsingHeader("Vendor Options")) then
			script_vendorMenu:menu();
		end
	end

	if (CollapsingHeader("Display Options")) then
		
		if (script_aggro.drawAggro) then
			Text("Draw Aggro Range");
			self.drawAggroRange = SliderInt("AR", 50, 300, self.drawAggroRange);
		end
		wasClicked, script_followEX.drawUnits = Checkbox("Show unit info on screen", script_followEX.drawUnits);
		wasClicked, script_aggro.drawAggro = Checkbox('Show aggro range', script_aggro.drawAggro);
		wasClicked, script_follow.drawPath = Checkbox("Draw Move Path", script_follow.drawPath);
	end
end