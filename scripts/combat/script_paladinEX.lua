script_paladinEX = {


}

function script_paladinEX:menu()

	if (CollapsingHeader("Paladin Combat Options")) then

		local wasClicked = false;

		Text("Rest options:");
		Text("You can add more food/drinks in script_helper.lua");
		script_paladin.eatHealth = SliderInt("Eat below HP%", 1, 100, script_paladin.eatHealth);
		script_paladin.drinkMana = SliderInt("Drink below Mana%", 1, 100, script_paladin.drinkMana);
		script_paladin.potionHealth = SliderInt("Potion below HP %", 1, 99, script_paladin.potionHealth);
		script_paladin.potionMana = SliderInt("Potion below Mana %", 1, 99, script_paladin.potionMana);

		Separator();

		wasClicked, script_paladin.stopIfMHBroken = Checkbox("Stop bot if main hand is broken (red)...", script_paladin.stopIfMHBroken);
		
		Separator();

		script_paladin.meleeDistance = SliderFloat("Melee range", 1, 6, script_paladin.meleeDistance);

		Separator();

		if (HasSpell("Consecration")) then
			Text("Consecrate Mana when 2 or more adds");
			script_paladin.consecrationMana = SliderFloat("Consecration above Mana %", 1, 99, script_paladin.consecrationMana);
		end

		if (CollapsingHeader("-- Auras and Blessings")) then

			Text("Aura and Blessing options:");
			script_paladin.aura = InputText("Aura", script_paladin.aura);
			script_paladin.blessing = InputText("Blessing", script_paladin.blessing);

		end
		
		if (HasSpell("Crusader Strike")) then
			if (CollapsingHeader("-- Crusader Strike Options")) then

				Text("How many Crusader Strike Stacks on target?");
				script_paladin.crusaderStacks = SliderInt("Stacks", 0, 5, script_paladin.crusaderStacks);
				script_paladin.crusaderStacksMana = SliderInt("Use above mana %", 10, 99, script_paladin.crusaderStacksMana);
				script_paladin.crusaderStacksHealth = SliderInt("Use above target health %", 20, 80, script_paladin.crusaderStacksHealth);
			
			end
		end

		if (CollapsingHeader("-- Heal Options")) then

			Text("Heal Options:")

			if (HasSpell("Flash of Light")) then
				wasClicked, script_paladin.useFlashOfLightCombat = Checkbox("Flash of Light in Combat On/Off", script_paladin.useFlashOfLightCombat);
			end

			Separator();

			script_paladin.holyLightHealth = SliderInt("Holy Light when below HP % (in combat)", 1, 99, script_paladin.holyLightHealth);
			
			if (HasSpell("Flash of Light")) then
				script_paladin.flashOfLightHP = SliderInt("Flash of Light when below HP %", 1, 99, script_paladin.flashOfLightHP);
			end

			if (HasSpell("Lay on Hands")) then
				script_paladin.lohHealth = SliderInt("Lay on Hands below HP %", 5, 50, script_paladin.lohHealth);
			end

			if (HasSpell("Blessing of Protection")) then
				script_paladin.bopHealth = SliderInt("Shield below HP %", 1, 99, script_paladin.bopHealth);
			end
		end
	end
end
