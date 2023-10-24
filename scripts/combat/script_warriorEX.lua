script_warriorEX = {

}

function script_warriorEX:menu()

	local wasClicked = false;

	if (not script_warrior.battleStance) and (not script_warrior.defensiveStance) and (not script_warrior.berserkerStance) then
		script_warrior.message = "Select a Warrior Stance!";
	end

	if (CollapsingHeader("Choose Stance - Experimental")) then -- stance menu
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
			if (CollapsingHeader("Battle Stance Options")) then

				-- charge
				if (HasSpell("Charge")) then
					wasClicked, script_warrior.enableCharge = Checkbox("Charge On/Off", script_warrior.enableCharge);
				end

				-- rend
				if (HasSpell("Rend")) then
					wasClicked, script_warrior.enableRend = Checkbox("Rend On/Off", script_warrior.enableRend);
				end

				SameLine();
				
				-- cleave
				if (HasSpell("Cleave")) then
					wasClicked, script_warrior.enableCleave = Checkbox("Cleave On/Off TODO", script_warrior.enableCleave)					end
			
				-- battle stance sunder	
				if (HasSpell("Sunder Armor")) then
					wasClicked, script_warrior.enableSunder = Checkbox("Use Sunder x1", script_warrior.enableSunder);					end
				
				if (HasSpell("Overpower")) then
					if (CollapsingHeader("-- Overpower Options")) then	-- overpower
						Text("Overpower action bar slot");
						script_warrior.overpowerActionBarSlot = InputText("OPS", script_warrior.overpowerActionBarSlot);
						Text("72 is your action bar number.. slot 1 would be 73");
					end
				end

				if (HasSpell("Mocking Blow")) then
					if (CollapsingHeader("-- Mocking Blow Options")) then
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
			if (CollapsingHeader("Defensive Stance Options")) then	-- defensive stance
				Text("Face Target off for easier manual control");
				wasClicked, script_warrior.enableFaceTarget = Checkbox("Face Target On/Off", script_warrior.enableFaceTarget);	-- facing target
					SameLine();
					wasClicked, script_warrior.enableShieldBlock = Checkbox("Shield Block On/Off", script_warrior.enableShieldBlock);	-- shield block
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
			
				if (CollapsingHeader("-- Revenge Skill Options")) then
					script_warrior.revengeActionBarSlot = InputText("RS", script_warrior.revengeActionBarSlot);	-- revenge
					Text("82 is spell bar number.. slot 1 would be 83");
				end
			end
		end
		if (script_warrior.berserkerStance) then -- berserker stance menu
			if (CollapsingHeader("Berserker Stance Options")) then
						Text("TODO!");	
			end
		end
	end
	if (CollapsingHeader("Warrior Combat Options")) then -- grind menu plans to hide this menu once rotation is complete
		Text('Eat below health percentage');
		script_warrior.eatHealth = SliderInt("EHP %", 1, 100, script_warrior.eatHealth);	-- use food health
		Text('Potion below health percentage');
		script_warrior.potionHealth = SliderInt("PHP %", 5, 15, script_warrior.potionHealth);	-- use potion health
		Separator();
		wasClicked, script_warrior.stopIfMHBroken = Checkbox("Stop bot if main hand is broken.", script_warrior.stopIfMHBroken);
		
		if (HasSpell("Bloodrage")) then
			Text("Use Bloodrage above health percentage");
			script_warrior.bloodRageHealth = SliderInt("BR%", 1, 99, script_warrior.bloodRageHealth);	-- bloodrage health
		end
		Text("Melee Range Distance");
		script_warrior.meleeDistance = SliderFloat("MR (yd)", 1, 8, script_warrior.meleeDistance);	-- melee distance range
		if (CollapsingHeader("-- Throwing Weapon Options")) then -- throwing weapon menu
			wasClicked, script_warrior.throwOpener = Checkbox("Pull with throw", script_warrior.throwOpener);
			Text("Throwing weapon");
			script_warrior.throwName = InputText("TW", script_warrior.throwName);
		end
	end
end