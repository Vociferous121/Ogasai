script_followEX = {
	
		drawUnits = false,
		drawAggro = false,
		drawAggroRange = 100,
}

function script_followEX:drawStatus()
	if (script_follow.drawPath) then
		script_nav:drawPath(); 
	end

	if (script_follow.drawUnits) then 
		script_nav:drawUnitsDataOnScreen();
	end

	if (script_aggro.drawAggro) then 
		script_aggro:drawAggroCircles(self.drawAggroRange); 
	end
	-- color
	local r, g, b = 255, 255, 0;
	-- position
	local y, x, width = 120, 25, 370;
	local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
	if (onScreen) then
		y, x = tY-25, tX+75;
	end
	DrawRect(x - 10, y - 5, x + width, y + 80, 255, 255, 0,  1, 1, 1);
	DrawRectFilled(x - 10, y - 5, x + width, y + 80, 0, 0, 0, 160, 0, 0);
	if (script_follow:GetPartyLeaderObject()) then
		DrawText('Follower - Range: ' .. math.floor(script_follow.followLeaderDistance) .. ' yd. ' .. 
		'Master target: ' .. script_follow:GetPartyLeaderObject():GetUnitName(), x-5, y-4, r, g, b) y = y + 15;
	else
		DrawText('Follower - Follow range: ' .. math.floor(script_follow.followDistance) .. ' yd. ' .. 
		'Master target: ' .. '', x-5, y-4, r, g, b) y = y + 15;
	end 

	DrawText('Status: ', x, y, r, g, b); 
	y = y + 15; DrawText(script_follow.message or "error", x, y, 0, 255, 255);
	y = y + 20; DrawText('Combat script status: ', x, y, r, g, b); y = y + 15;
	RunCombatDraw();
end

function script_grindEX:doLoot(localObj)
	local _x, _y, _z = script_follow.lootObj:GetPosition();
	local dist = script_follow.lootObj:GetDistance();
	
	-- Loot checking/reset target
	if (GetTimeEX() > script_follow.lootCheck['timer']) then
		if (script_follow.lootCheck['target'] == script_follow.lootObj:GetGUID()) then
			script_follow.lootObj = nil; -- reset lootObj
			ClearTarget();
			script_follow.message = 'Reseting loot target...';
		end
		script_follow.lootCheck['timer'] = GetTimeEX() + 10000; -- 10 sec
		if (script_follow.lootObj ~= nil) then 
			script_follow.lootCheck['target'] = script_follow.lootObj:GetGUID();
		else
			script_follow.lootCheck['target'] = 0;
		end
		return;
	end

	if(dist <= script_follow.lootDistance) then
		script_follow.message = "Looting...";
		if(IsMoving() and not localObj:IsMovementDisabed()) then
			StopMoving();
			script_follow.waitTimer = GetTimeEX() + 450;
			return;
		end
		if(not IsStanding()) then
			StopMoving();
			script_follow.waitTimer = GetTimeEX() + 450;
			return;
		end
		
		-- If we reached the loot object, reset the nav path
		script_nav:resetNavigate();

		-- Dismount
		if (IsMounted()) then 
			DisMount(); script_follow.waitTimer = GetTimeEX() + 450;
			return; 
		end

		if(not script_follow.lootObj:UnitInteract() and not IsLooting()) then
			script_follow.waitTimer = GetTimeEX() + 950;
			return;
		end
		if (not LootTarget()) then
			script_follow.waitTimer = GetTimeEX() + 650;
			return;
		else
			script_follow.lootObj = nil;
			script_follow.waitTimer = GetTimeEX() + 450;
			return;
		end
	end
	script_follow.message = "Moving to loot...";		
	script_nav:moveToTarget(localObj, _x, _y, _z);	
	script_grind:setWaitTimer(100);
	if (script_follow.lootObj:GetDistance() < 3) then
		script_follow.waitTimer = GetTimeEX() + 450; 
	end
end

function script_followEX:menu()
	if (not script_follow.pause) then 
		if (Button("Pause Bot")) then
			script_follow.pause = true; 
		end
	elseif (Button("Resume Bot")) then 
		script_follow.pause = false; 
		script_follow.myTime = GetTimeEX(); 
	end
	
	SameLine();
	if (Button("Reload Scripts")) then 
		coremenu:reload(); 
	end
	SameLine();
	if (Button("Exit Bot")) then
		StopBot();
	end

	Separator();
	
	if (CollapsingHeader("Group Options")) then

		Text("Distance to follow Party Leader     ");
			SameLine();
			wasClicked, script_follow.followMember = Checkbox("Follow Party Member", script_follow.followMember);
			script_follow.followLeaderDistance = SliderInt("Follow Leader Distance (yd)", 6, 40, script_follow.followLeaderDistance);
			
			if (script_follow.followMember) then
				Text("This is the issue with the follower. It will attempt to follow");
				Text("party members AND the party leader at the same time... ");
				Text("use with caution");
			end

			Separator();

			Text("Assist in combat?   ")
			SameLine();
			wasClicked, script_follow.assistInCombat = Checkbox("Assist Party Leader", script_follow.assistInCombat);
			Separator();

			wasClicked, script_follow.useUnStuck = Checkbox("Turn On/Off Buggy unStuck Script", script_follow.useUnStuck);
			Separator();

			Text("Loot options:");
			wasClicked, script_follow.skipLooting = Checkbox("Skip Looting", script_follow.skipLooting);
			script_follow.findLootDistance = SliderInt("Find Loot Distance (yd)", 1, 100, script_follow.findLootDistance);	
			script_follow.lootDistance = SliderInt("Loot Distance (yd)", 1, 6, script_follow.lootDistance);
	end
			-- Load combat menu by class
	local class = UnitClass("player");


	if (class == 'Mage') then
		script_mage:menu();
	elseif (class == 'Hunter') then
		script_hunter:menu();
	elseif (class == 'Warlock') then
		script_warlock:menu();
	elseif (class == 'Paladin') then
		script_paladin:menu();
	elseif (class == 'Druid') then
		script_druid:menu();
	elseif (class == 'Priest') then
		script_priest:menu();
	elseif (class == 'Warrior') then
		script_warrior:menu();
	elseif (class == 'Rogue') then
		script_rogue:menu();
	elseif (class == 'Shaman') then
		script_shaman:menu();
	end	

	if (class == 'Priest') and (CollapsingHeader("Priest Group Heals - Follower Script")) then


		-- turn ALL heals on/off for group
		wasClicked, script_follow.enableHeals = Checkbox("Turn On/Off all heals for the group!", script_follow.enableHeals);

		-- Lesser Heal
		if (GetLocalPlayer():GetLevel() < 20) then
			Text("Lesser Heal Options -"); SameLine(); Text("Turn On/Off above");
			script_follow.lesserHealMana = SliderInt("Lesser Heal Mana%", 1, 99, script_follow.lesserHealMana);
			script_follow.partyLesserHealHealth = SliderInt("Lesser Heal Health%", 1, 99, script_follow.partyLesserHealHealth);
			Separator();
		end

		-- Renew
		Text("Renew Options -"); SameLine(); 
		wasClicked, script_follow.clickRenew = Checkbox("Renew On/Off", script_follow.clickRenew);
		script_follow.renewMana = SliderInt("Renew Mana%", 1, 99, script_follow.renewMana);
		script_follow.partyRenewHealth = SliderInt("Renew Health%", 1, 99, script_follow.partyRenewHealth);

		-- Shield
		Text("Shield Options -"); SameLine(); 
		wasClicked, script_follow.clickShield = Checkbox("Shield On/Off", script_follow.clickShield);
		script_follow.shieldMana = SliderInt("Shield Mana%", 1, 99, script_follow.shieldMana);
		script_follow.partyShieldHealth = SliderInt("Shield Health%", 1, 99, script_follow.partyShieldHealth);

		-- Flash Heal
		Text("Flash Heal Options -"); SameLine();
		wasClicked, script_follow.clickFlashHeal = Checkbox("Flash Heal On/Off", script_follow.clickFlashHeal);
		script_follow.flashHealMana = SliderInt("Flash Heal Mana%", 1, 99, script_follow.flashHealMana);
		script_follow.partyFlashHealHealth = SliderInt("Flash Heal Health%", 1, 99, script_follow.partyFlashHealHealth);
		
		-- Greater Heal
		Text("Greater Heal Options -"); SameLine();
		wasClicked, script_follow.clickGreaterHeal = Checkbox("Greater Heal On/Off", script_follow.clickGreaterHeal);
		script_follow.greaterHealMana = SliderInt("Greater Heal Mana%", 1, 99, script_follow.greaterHealMana);
		script_follow.partyGreaterHealHealth = SliderInt("Greater Heal Health%", 1, 99, script_follow.partyGreaterHealHealth);	

		-- Heal(spell)
		Text("Heal(spell) Options -"); SameLine();
		wasClicked, script_follow.clickHeal = Checkbox("Heal(spell) On/Off", script_follow.clickHeal);
		script_follow.healMana = SliderInt("Heal Mana%", 1, 99, script_follow.healMana);
		script_follow.partyHealHealth = SliderInt("Heal Health%", 1, 99, script_follow.partyHealHealth);
	end

	if  (class == 'Paladin') and (CollapsingHeader("Paladin Group Heals Follower Script")) then

		-- turn ALL heals on/off for group
		wasClicked, script_follow.enableHeals = Checkbox("Turn On/Off all heals for the group!", script_follow.enableHeals);

		-- Holy Light
		Text("Holy Light Options -"); SameLine();
		wasClicked, script_follow.clickHolyLight = Checkbox("Holy Light On/Off", script_follow.clickHolyLight);
		script_follow.holyLightMana = SliderInt("Holy Light Mana%", 1, 99, script_follow.holyLightMana);
		script_follow.partyHolyLightHealth = SliderInt("Holy Light Health%", 1, 99, script_follow.partyHolyLightHealth);
		Separator();

		-- Flash of Light
		Text("Flash of Light Options -"); SameLine();
		wasClicked, script_follow.clickFlashOfLight = Checkbox("Flash of Light On/Off", script_follow.clickFlashOfLight);
		script_follow.flashOfLightMana = SliderInt("Flash of Light mana%", 1, 99, script_follow.flashOfLightMana);
		script_follow.partyFlashOfLightHealth = SliderInt("Flash of Light Health%", 1, 99, script_follow.partyFlashOfLightHealth);
		script_follow.layOnHandsHealth = SliderInt("Lay On Hands Health %", 5, 20, script_follow.layOnHandsHealth);
		script_follow.bopHealth = SliderInt("Blessing of Protection Health %", 1, 25, script_follow.bopHealth);
	end

	if (class == 'Druid') and (CollapsingHeader("Druid Group Heals Follower Script")) then

		-- turn ALL heals on/off for group
		wasClicked, script_follow.enableHeals = Checkbox("Turn On/Off all heals for the group!", script_follow.enableHeals);

		-- Healing Touch
		Text("Healing Touch Options -"); SameLine();
		wasClicked, script_follow.clickHealingTouch = Checkbox("Healing Touch On/Off", script_follow.clickHealingTouch);
		script_follow.healingTouchMana = SliderInt("Healing Touch Mana%", 1, 99, script_follow.healingTouchMana);
		script_follow.healingTouchHealth = SliderInt("Healing Touch Health%", 1, 99, script_follow.healingTouchHealth);
		Separator();

		-- Regrowth
		Text("Regrwoth Options -"); SameLine();
		wasClicked, script_follow.clickRegrowth = Checkbox("Regrowth On/Off", script_follow.clickRegrowth);
		script_follow.regrowthMana = SliderInt("Regrowth Mana%", 1, 99, script_follow.regrowthMana);
		script_follow.regrowthHealth = SliderInt("Regrowth Health%", 1, 99, script_follow.regrowthHealth);
		Separator();

		-- Rejuvenation
		Text("Rejuvenation Options -");
		script_follow.rejuvenationMana = SliderInt("Rejuvenation Mana%", 1, 99, script_follow.rejuvenationMana);
		script_follow.rejuvenationHealth = SliderInt("Rejuvenation Health%", 1, 99, script_follow.rejuvenationHealth);
		Separator();	
	end

	if (class == 'Shaman') and (CollapsingHeader("Shaman Group Heals Follower Script")) then

		-- turn ALL heals on/off for group
		wasClicked, script_follow.enableHeals = Checkbox("Turn On/Off all heals for the group!", script_follow.enableHeals);

		Text("TODO!");
	end

	if (CollapsingHeader("Display Options")) then
		
		if (script_aggro.drawAggro) then
			Text("Draw Aggro Range");
			self.drawAggroRange = SliderInt("AR", 50, 300, self.drawAggroRange);
		end
		wasClicked, script_follow.drawUnits = Checkbox("Show unit info on screen", script_follow.drawUnits);
		wasClicked, script_aggro.drawAggro = Checkbox('Show aggro range', script_aggro.drawAggro);
	end
end