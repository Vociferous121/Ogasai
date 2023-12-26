script_warriorEX = {

}

function script_warriorEX:menu()

	if (HasItem("Linen Bandage")) or 
		(HasItem("Heavy Linen Bandage")) or 
		(HasItem("Wool Bandage")) or 
		(HasItem("Heavy Wool Bandage")) or 
		(HasItem("Silk Bandage")) or 
		(HasItem("Heavy Silk Bandage")) or 
		(HasItem("Mageweave Bandage")) or 
		(HasItem("Heavy Mageweave Bandage")) or 
		(HasItem("Runecloth Bandage")) or 
		(HasItem("Heavy Runecloth Bandage")) then
		
		self.menuBandages = true;
	else
		self.menuBandages = false;
	end
	
	local localObj = GetLocalPlayer();

	local wasClicked = false;

	if (not script_warrior.battleStance) and (not script_warrior.defensiveStance) and (not script_warrior.berserkerStance) then
		script_warrior.message = "Select a Warrior Stance!";
	end

	if (CollapsingHeader("Choose Stance For Combat")) then -- stance menu
		Text("Choose Stance - ");
		SameLine();
		Text("You must enable stance in-game!");
		
		if (not script_warrior.defensiveStance) and (not script_warrior.berserkerStance) then	-- hide all but battle stance
			wasClicked, script_warrior.battleStance = Checkbox("Battle (DPS)", script_warrior.battleStance);
			SameLine();
		end

		if (not script_warrior.battleStance) and (not script_warrior.berserkerStance) then	-- hide all but defensive stance
			wasClicked, script_warrior.defensiveStance = Checkbox("Defensive (Tank)", script_warrior.defensiveStance);

			SameLine();

		end

		if (not script_warrior.battleStance) and (not script_warrior.defensiveStance) then	-- hide all but berserker stance
			wasClicked, script_warrior.berserkerStance = Checkbox("Berserker (DPS)", script_warrior.berserkerStance);

			SameLine();

		end

		Separator();

		if (script_warrior.battleStance) then -- batle stance menu

			wasClicked = true;
			if (CollapsingHeader("|+| Battle Stance Options")) then

				-- rend
				if (HasSpell("Rend")) then
					wasClicked, script_warrior.enableRend = Checkbox("Use Rend", script_warrior.enableRend);
				end
				
				-- cleave
				if (HasSpell("Cleave")) then
					SameLine();
					wasClicked, script_warrior.enableCleave = Checkbox("Use Cleave TODO", script_warrior.enableCleave)					end
			
				-- battle stance sunder	
				if (HasSpell("Sunder Armor")) then
				Separator();
					Text("How many Sunder Armor Stacks?");
					script_warrior.sunderStacks = SliderInt("Sunder Stacks", 0, 5, script_warrior.sunderStacks);					end
				
				if (HasSpell("Overpower")) then
					if (CollapsingHeader("|+| Overpower Options")) then	-- overpower
						Text("Overpower action bar slot");
						script_warrior.overpowerActionBarSlot = InputText("OPS", script_warrior.overpowerActionBarSlot);
						Text("73 is Battle Stance Action Slot 1");
					end
				end

				if (HasSpell("Mocking Blow")) then
					if (CollapsingHeader("|+| Mocking Blow Options")) then
						Text("Mocking Blow action bar slot");
						wasClicked, script_warrior.useMockingBlow = Checkbox("Use Mocking Blow", script_warrior.useMockingBlow);
						script_warrior.mockingBlowActionBarSlot = InputText("MBS", script_warrior.mockingBlowActionBarSlot);
						Text("72 is your action bar number.. slot 1 would be 73");
					end
				end
			end
		end

			Separator();

		if (script_warrior.defensiveStance) then -- defensive stance menu
			if (CollapsingHeader("|+| Defensive Stance Options")) then	-- defensive stance
				Text("Face Target off for easier manual control");
				wasClicked, script_warrior.enableFaceTarget = Checkbox("Auto Face Target", script_warrior.enableFaceTarget);	-- facing target
					SameLine();
					wasClicked, script_warrior.enableShieldBlock = Checkbox("Use Shield Block", script_warrior.enableShieldBlock);	-- shield block
				if (script_warrior.enableShieldBlock) then
					Text("Shield Block Options");
					script_warrior.shieldBlockHealth = SliderInt("Below % health", 50, 95, script_warrior.shieldBlockHealth);
					script_warrior.shieldBlockRage = SliderInt("Above % rage", 10, 30, script_warrior.shieldBlockRage);
				end
					Separator();
					Text("How many Sunder Armor Stacks?");
					script_warrior.sunderStacks = SliderInt("Sunder Stacks", 1, 5, script_warrior.sunderStacks);	-- sunder armor
					script_warrior.sunderArmorRage = SliderInt("Sunder rage cost", 12, 15, script_warrior.sunderArmorRage);
					script_warrior.demoShoutRage = SliderInt("Demo shout above % rage", 10, 50, script_warrior.demoShoutRage);
					script_warrior.challengingShoutAdds = SliderInt("Challenging Shout Add Count", 3, 10, script_warrior.challengingShoutAdds);
			
				if (CollapsingHeader("|+| Revenge Skill Options")) then
					script_warrior.revengeActionBarSlot = InputText("RS", script_warrior.revengeActionBarSlot);	-- revenge
					Text("83 is Defensive Stance Action Slot 1");
				end
			end
		end
		if (script_warrior.berserkerStance) then -- berserker stance menu
			if (CollapsingHeader("|+| Berserker Stance Options")) then
						Text("TO DO!");	
			end
		end
	end

if (script_warrior.battleStance) or (script_warrior.defensiveStance) or (script_warrior.berserkerStance) then
	if (CollapsingHeader("Warrior Combat Options")) then -- grind menu plans to hide this menu once rotation is complete
		Separator();
		
		if (self.menuBandages) then
			wasClicked, script_warrior.useBandage = Checkbox("Use Bandages", script_warrior.useBandage);
		end

		if (localObj:HasRangedWeapon()) then
		SameLine();
			wasClicked, script_warrior.useBow = Checkbox("Use Bow", script_warrior.useBow);
		end

		if (HasSpell("Charge")) then
		SameLine();
			wasClicked, script_warrior.enableCharge = Checkbox("Use Charge", script_warrior.enableCharge);
		end

		Text('Eat below health percentage');
		script_warrior.eatHealth = SliderInt("EHP %", 15, 100, script_warrior.eatHealth);	-- use food health

		Text('Potion below health percentage');
		script_warrior.potionHealth = SliderInt("PHP %", 5, 15, script_warrior.potionHealth);	-- use potion health

		if (HasSpell("Last Stand")) then
			Text("Last Stand Health");
			script_warrior.lastStandHealth = SliderInt("LSH %", 5, 15, script_warrior.lastStandHealth);
		end

		Separator();
		wasClicked, script_warrior.stopIfMHBroken = Checkbox("Stop bot if main hand is broken.", script_warrior.stopIfMHBroken);
		
		if (HasSpell("Bloodrage")) then
			Text("Use Bloodrage above health percentage");
			script_warrior.bloodRageHealth = SliderInt("BR%", 1, 99, script_warrior.bloodRageHealth);	-- bloodrage health
		end
		Text("Melee Range Distance");
		script_warrior.meleeDistance = SliderFloat("MR (yd)", 1, 8, script_warrior.meleeDistance);	-- melee distance range
	end
end
end