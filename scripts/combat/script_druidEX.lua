script_druidEX = {

}


function script_druidEX:menu()

	if (HasSpell("Bear Form")) or (HasSpell("Dire Bear Form")) then
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
		
		if (HasSpell("Entangling Roots")) and (not script_druid.useCat) and (not script_druid.useBear) then
			wasClicked, script_druid.useEntanglingRoots = Checkbox("Attempt to root after pull", script_druid.useEntanglingRoots);
		end
		
		wasClicked, script_druid.stopIfMHBroken = Checkbox("Stop bot if main hand is broken (red)...", script_druid.stopIfMHBroken);

		Separator();
			
		Text("Melee Range to target");
		script_druid.meleeDistance = SliderFloat("Melee range", 1, 6, script_druid.meleeDistance);

		if (HasSpell("Bear Form") or HasSpell("Cat Form") or HasSpell("Dire Bear Form")) then
			Text("Health to heal when shapeshifted");
			script_druid.healthToShift = SliderInt("Shapeshift to heal HP%", 0, 65, script_druid.healthToShift);
			Separator();
			Text("Controlled by drink mana percentage");
			wasClicked, script_druid.shiftToDrink = Checkbox("Leave Form To Drink", script_druid.shiftToDrink);
			Separator();
		end

		if (HasSpell("Bear Form")) or (HasSpell("Dire Bear Form")) then
			if (CollapsingHeader("|+| Bear Form Options")) then
				Text("Stuff to do !");
			end
		end

		if (HasSpell("Cat Form")) then
			if (CollapsingHeader("|+| Cat Form Options")) then
				wasClicked, script_druid.useStealth = Checkbox("Use Stealth", script_druid.useStealth);
				Text("Stealth Opener");
				script_druid.stealthOpener = InputText("Opener", script_druid.stealthOpener);
			end
		end


	end

	if (CollapsingHeader("Heal Options")) then
		Text('Rest options:');
		script_druid.eatHealth = SliderInt("Eat below HP%", 1, 100, script_druid.eatHealth);
		script_druid.drinkMana = SliderInt("Drink below Mana%", 1, 100, script_druid.drinkMana);
		script_druid.potionHealth = SliderInt("Potion below HP%", 5, 25, script_druid.potionHealth);
		script_druid.potionMana = SliderInt("Potion below Mana%", 5, 25, script_druid.potionMana);
		Text('You can add more food/drinks in script_helper.lua');

		Separator();

		if (HasSpell("Rejuvenation")) then
			Text("Rejuvenation below HP percentage");
			script_druid.rejuvenationHealth = SliderInt("RHP%", 25, 99, script_druid.rejuvenationHealth);
			Text("Rejuvenation above mana percentage");
			script_druid.rejuvenationMana = SliderInt("RMP%", 10, 99, script_druid.rejuvenationMana);
		end
		if (HasSpell("Regrowth")) then
			Text("Regrwoth below HP percentage");
			script_druid.regrowthHealth = SliderInt("Regrowth below HP%", 15, 99, script_druid.regrowthHealth);
		end

		Text("Healing Touch below HP percentage");
		script_druid.healingTouchHealth = SliderInt("Healing Touch HP%", 15, 99, script_druid.healingTouchHealth);
	end
end