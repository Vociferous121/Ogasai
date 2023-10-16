function script_druidEX:menu()

	if (CollapsingHeader("Druid Form Options - Experimental!")) then
		wasClicked, script_druid.bear = Checkbox("Bear Form", script_druid.bear);
		SameLine();
		wasClicked, script_druid.cat = Checkbox("Cat Form", script_druid.cat);
	end

	if (CollapsingHeader("Druid Combat Options")) then
		local wasClicked = false;
		Text('Combat options:');
		
		if (not script_druid.pullWithMoonfire) then
			wasClicked, script_druid.pullWithWrath = Checkbox("Pull With Wrath On/Off - Bear and Cat form too!", script_druid.pullWithWrath);
			if (script_druid.pullWithWrath) then
				script_druid.pullWithMoonfire = false;
			end
		end

		if (not script_druid.pullWithWrath) and (HasSpell("Moonfire")) then
			wasClicked, script_druid.pullWithMoonfire = Checkbox("Pull With Moonfire On/Off - Bear and Cat form too!", script_druid.pullWithMoonfire);
			if (script_druid.pullWithMoonfire) then
				script_druid.pullWithWrath = false;
			end
		end

		if (HasSpell("Entangling Roots")) then
			wasClicked, script_druid.useEntanglingRoots = Checkbox("Attempt to root after pull On/Off", script_druid.useEntanglingRoots);
		end
		
		wasClicked, script_druid.stopIfMHBroken = Checkbox("Stop bot if main hand is broken (red)...", script_druid.stopIfMHBroken);

		Separator();
			
		Text("Melee Range to target");
		script_druid.meeleDistance = SliderFloat("Meele range", 1, 6, script_druid.meeleDistance);
	end

	if (CollapsingHeader("Druid script_druid Heals - Combat Script")) then
		Text('Rest options:');
		script_druid.eatHealth = SliderInt("Eat below HP%", 1, 100, script_druid.eatHealth);
		script_druid.drinkMana = SliderInt("Drink below Mana%", 30, 100, script_druid.drinkMana);
		Text('You can add more food/drinks in script_helper.lua');

		Separator();
		if (HasSpell("Bear Form") or HasSpell("Cat Form") or HasSpell("Dire Bear Form")) then
			script_druid.healHealthWhenShifted = SliderInt("Shapeshift to heal HP%", 1, 99, script_druid.healHealthWhenShifted);
			Separator();
		end

		script_druid.rejuvenationHealth = SliderInt("Rejuvenation below HP%", 1, 99, script_druid.rejuvenationHealth);
		script_druid.rejuvenationMana = SliderInt("Rejuvenation above Mana %", 1, 99, script_druid.rejuvenationMana);
		script_druid.regrowthHealth = SliderInt("Regrowth below HP%", 1, 99, script_druid.regrowthHealth);
		script_druid.healingTouchHealth = SliderInt("Healing Touch HP%", 1, 99, script_druid.healingTouchHealth);
		script_druid.potionHealth = SliderInt("Potion below HP%", 1, 99, script_druid.potionHealth);
		script_druid.potionMana = SliderInt("Potion below Mana%", 1, 99, script_druid.potionMana);
	end
end