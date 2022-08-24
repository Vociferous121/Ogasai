script_rotationMenu = {

	drawUnits = true,
	drawAggro = true,

}

function script_rotationMenu:drawStatus()
	if (script_follow.drawPath) then 
		script_nav:drawPath(); 
	end

	if (script_follow.drawUnits) then 
		script_nav:drawUnitsDataOnScreen(); 
	end

	-- color
	local r, g, b = 255, 255, 0;

	-- position
	local y, x, width = 120, 25, 370;
	local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
	if (onScreen) then
	y, x = tY-25, tX+75;
	end
	--DrawRect(x - 10, y - 5, x + width, y + 80, 255, 255, 0,  1, 1, 1);
	--DrawRectFilled(x - 10, y - 5, x + width, y + 80, 0, 0, 0, 160, 0, 0);
	if (script_follow:GetPartyLeaderObject()) then
		DrawText('Follower - Range: ' .. math.floor(script_follow.followDistance) .. ' yd. ' .. 
			 	'Master target: ' .. script_follow:GetPartyLeaderObject():GetUnitName(), x+255, y-4, r, g, b) y = y + 15;
	else
		DrawText('Follower - Follow range: ' .. math.floor(script_follow.followDistance) .. ' yd. ' .. 
			 	'Master target: ' .. '', x+255, y-4, r, g, b) y = y + 15;
	end 

	DrawText('Status: ', x+255, y, r, g, b); 
	y = y + 15; DrawText(script_follow.message or "error", x+255, y, 0, 255, 255);
	y = y + 20; DrawText('Combat script status: ', x+255, y, r, g, b); y = y + 15;
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
			DisMount(); 
			script_follow.waitTimer = GetTimeEX() + 450; 
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

function script_rotationMenu:menu()
	local wasClicked = false;
	local class, classFileName = UnitClass("player");
	if (strfind("Warrior", class) or strfind("Rogue", class)) then
		self.useMana = false; 
		self.restMana = 0;
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

				-- rotation menu
	if (self.enableRotation) then
		Separator();
		if(CollapsingHeader("Clickable Rotation Options")) then
			wasClicked, self.useSliceAndDice = Checkbox("Use Slice & Dice", self.useSliceAndDice);
			SameLine();
			wasClicked, self.useKidneyShot = Checkbox("Kidney Shot Interrupts", self.useKidneyShot);
			wasClicked, self.useStealth = Checkbox("Use Stealth", self.useStealth);
			SameLine();
			wasClicked, self.enableFaceTarget = Checkbox("Auto Face Target", self.enableFaceTarget);
			wasClicked, self.enableBladeFlurry = Checkbox("Blade Flurry on CD", self.enableBladeFlurry);
			SameLine();
			wasClicked, self.enableAdrenRush = Checkbox("Adren Rush on CD", self.enableAdrenRush);
		end
		if (CollapsingHeader("Rogue Rotation Options")) then
			Separator();
			local wasClicked = false;
			Text('Eat below health percent');
			self.eatHealth = SliderInt('EHP %', 1, 50, self.eatHealth);
			Text("Potion below health percent");
			self.potionHealth = SliderInt('PHP %', 1, 50, self.potionHealth);
			Separator();
			Text("Combo Point Generator Ability");
			self.cpGenerator = InputText("CPA", self.cpGenerator);
			Text("Energy cost of CP-ability");
			self.cpGeneratorCost = SliderInt("Energy", 20, 50, self.cpGeneratorCost);
			Separator();
			Text("Stealth ability opener");
			self.stealthOpener = InputText("STO", self.stealthOpener);
			Text("Stealth - Distance to target"); 
			self.stealthRange = SliderInt('SR (yd)', 1, 50, self.stealthRange);
			Separator();		
			if (CollapsingHeader("Poison Options")) then
				Text("Poison on Main Hand");
				self.mainhandPoison = InputText("PMH", self.mainhandPoison);
				Text("Poison on Off Hand");
				self.offhandPoison = InputText("POH", self.offhandPoison);
			end
		end
	end


end