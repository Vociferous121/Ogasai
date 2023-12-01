script_shamanEX = {

}

function script_shamanEX:menu()
	if (CollapsingHeader("Shaman Combat Options")) then
		local wasClicked = false;
		Text('Rest options:');
		script_shaman.eatHealth = SliderInt("Eat below HP%", 1, 100, script_shaman.eatHealth);
		script_shaman.drinkMana = SliderInt("Drink below Mana%", 1, 100, script_shaman.drinkMana);
		Text('You can add more food/drinks in script_helper.lua');
		Separator();
		Text('Combat options:');
		wasClicked, script_shaman.stopIfMHBroken = Checkbox("Stop bot if main hand is broken (red)...", script_shaman.stopIfMHBroken);
		script_shaman.potionHealth = SliderInt("Potion below HP%", 1, 99, script_shaman.potionHealth);
		script_shaman.potionMana = SliderInt("Potion below Mana%", 1, 99, script_shaman.potionMana);
		script_shaman.healHealth = SliderInt("Heal when below HP% (in combat)", 1, 99, script_shaman.healHealth);
		script_shaman.meleeDistance = SliderFloat("Melee range", 1, 6, script_shaman.meleeDistance);

		if (CollapsingHeader("|+| Totem Options")) then
			script_shaman.totem = InputText("Totem", script_shaman.totem);
		end
	end
end
