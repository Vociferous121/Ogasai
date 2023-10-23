script_druidEX = {

}

function script_druidEX:menu()
	if (CollapsingHeader("[Druid - Feral")) then
		local wasClicked = false;
		Text('Rest options:');
		script_druid.eatHealth = SliderFloat("Eat below HP%", 1, 100, script_druid.eatHealth);
		script_druid.drinkMana = SliderFloat("Drink below Mana%", 1, 100, script_druid.drinkMana);
		Text('You can add more food/drinks in script_helper.lua');
		Separator();
		Text('Combat options:');
		wasClicked, script_druid.stopIfMHBroken = Checkbox("Stop bot if main hand is broken (red)...", script_druid.stopIfMHBroken);
		script_druid.healHealthWhenShifted = SliderFloat("Shapeshift to heal HP%", 1, 99, script_druid.healHealthWhenShifted);
		script_druid.potionHealth = SliderFloat("Potion below HP%", 1, 99, script_druid.potionHealth);
		script_druid.potionMana = SliderFloat("Potion below Mana%", 1, 99, script_druid.potionMana);
		script_druid.healHealth = SliderFloat("Healing Touch HP% (in combat)", 1, 99, script_druid.healHealth);
		script_druid.regrowthHealth = SliderFloat("Regrowth HP% (in combat)", 1, 99, script_druid.regrowthHealth);
		script_druid.rejuHealth = SliderFloat("Rejuvenation HP% (in combat)", 1, 99, script_druid.rejuHealth);
		script_druid.meeleDistance = SliderFloat("Meele range", 1, 6, script_druid.meeleDistance);
	end
end
