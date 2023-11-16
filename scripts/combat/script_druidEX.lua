script_druidEX = {

}


function script_druidEX:menu()

	if (HasSpell("Bear Form")) then
		if (CollapsingHeader("Druid Form Options - Experimental!")) then
			wasClicked, script_druid.useBear = Checkbox("Bear Form", script_druid.useBear);

			if (HasSpell("Cat Form")) then
				SameLine();
				wasClicked, script_druid.useCat = Checkbox("Cat Form", script_druid.useCat);
			end
		end
	end

	if (CollapsingHeader("Druid Combat Options")) then
		local wasClicked = false;
		Text('Combat options:');
		
		if (HasSpell("Entangling Roots")) then
			wasClicked, script_druid.useEntanglingRoots = Checkbox("Attempt to root after pull", script_druid.useEntanglingRoots);
		end
		
		wasClicked, script_druid.stopIfMHBroken = Checkbox("Stop bot if main hand is broken (red)...", script_druid.stopIfMHBroken);

		Separator();
			
		Text("Melee Range to target");
		script_druid.meleeDistance = SliderFloat("Melee range", 1, 6, script_druid.meleeDistance);
	end

	if (CollapsingHeader("Heal Options")) then
		Text('Rest options:');
		script_druid.eatHealth = SliderInt("Eat below HP%", 1, 100, script_druid.eatHealth);
		script_druid.drinkMana = SliderInt("Drink below Mana%", 30, 100, script_druid.drinkMana);
		script_druid.potionHealth = SliderInt("Potion below HP%", 1, 99, script_druid.potionHealth);
		script_druid.potionMana = SliderInt("Potion below Mana%", 1, 99, script_druid.potionMana);
		Text('You can add more food/drinks in script_helper.lua');

		Separator();
		if (HasSpell("Bear Form") or HasSpell("Cat Form") or HasSpell("Dire Bear Form")) then
			script_druid.healthToShift = SliderInt("Shapeshift to heal HP%", 1, 75, script_druid.healthToShift);
			Separator();
		end

		if (HasSpell("Rejuvenation")) then
			Text("Rejuvenation below HP percentage");
			script_druid.rejuvenationHealth = SliderInt("RHP%", 1, 99, script_druid.rejuvenationHealth);
			Text("Rejuvenation above mana percentage");
			script_druid.rejuvenationMana = SliderInt("RMP%", 1, 99, script_druid.rejuvenationMana);
		end
		if (HasSpell("Regrowth")) then
			Text("Regrwoth below HP percentage");
			script_druid.regrowthHealth = SliderInt("Regrowth below HP%", 1, 99, script_druid.regrowthHealth);
		end

		Text("Healing Touch below HP percentage");
		script_druid.healingTouchHealth = SliderInt("Healing Touch HP%", 1, 99, script_druid.healingTouchHealth);
	end
end