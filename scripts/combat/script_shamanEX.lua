script_shamanEX = {

}

function script_shamanEX:menu()

	if (CollapsingHeader("Shaman Combat Options")) then

		local wasClicked = false;

		
		Text('Combat options:');
		wasClicked, script_shaman.stopIfMHBroken = Checkbox("Stop bot if main hand is broken (red)...", script_shaman.stopIfMHBroken);

		-- melee distance
		script_shaman.meleeDistance = SliderFloat("Melee range", 1, 6, script_shaman.meleeDistance);

		Separator();

		-- lightning bolt
		wasClicked, script_shaman.pullLightningBolt = Checkbox("Pull With Lightning Bolt", script_shaman.pullLightningBolt);
		Text("Use Lightning Bolt Above Mana");
		script_shaman.lightningBoltMana = SliderInt("LBM%", 5, 90, script_shaman.lightningBoltMana);

		Separator();

		-- shock mana sliders
		if (HasSpell("Earth Shock")) then
			Text("Use Earth Shock Above Mana");
			script_shaman.earthShockMana = SliderInt("ES%", 5, 100, script_shaman.earthShockMana);
		end
		if (HasSpell("Flame Shock")) then
			Text("Use Flame Shock Above Mana");
			script_shaman.flameShockMana = SliderInt("FS%", 5, 100, script_shaman.flameShockMana);
		end


		Separator();


		-- use totems
		if (HasItem("Earth Totem")) then
			wasClicked, script_shaman.useEarthTotem = Checkbox("Use Earth Totems", script_shaman.useEarthTotem);
		end
		if (HasItem("Fire Totem")) then
			SameLine();
			wasClicked, script_shaman.useFireTotem = Checkbox("Use Fire Totems", script_shaman.useFireTotem);
		end


		-- totem menu
		if (HasItem("Earth Totem")) then

			if (CollapsingHeader("|+| Totem Options")) then

				script_shaman.totem = InputText("Earth Totem", script_shaman.totem);

				Separator();

				if (HasItem("Fire Totem")) then
					Text("Use Fire Totem Above Mana");
					script_shaman.fireTotemMana = SliderInt("FTM%", 5, 100, script_shaman.fireTotemMana);
					script_shaman.totem2 = InputText("Fire Totem", script_shaman.totem2);
				end
			end
		end
		
	end

	if (CollapsingHeader("Shaman Heal Options")) then
		Text('Rest options:');
		script_shaman.eatHealth = SliderInt("Eat below HP%", 1, 100, script_shaman.eatHealth);
		script_shaman.drinkMana = SliderInt("Drink below Mana%", 1, 100, script_shaman.drinkMana);
		Text('You can add more food/drinks in script_helper.lua');

		Separator();

		script_shaman.potionHealth = SliderInt("Potion below HP%", 1, 99, script_shaman.potionHealth);
		script_shaman.potionMana = SliderInt("Potion below Mana%", 1, 99, script_shaman.potionMana);

		Separator();

		Text("Heal Below Health In Combat");
		script_shaman.healHealth = SliderInt("Heal when below HP% (in combat)", 1, 99, script_shaman.healHealth);

	end

end
