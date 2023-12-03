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
		SameLine();
		wasClicked, script_shaman.useLightningBolt = Checkbox("Lightning Bolt In Combat", script_shaman.useLightningBolt);

		if (script_shaman.useLightningBolt) then
			Text("Use Lightning Bolt Above Mana");
			script_shaman.lightningBoltMana = SliderInt("LBM%", 5, 90, script_shaman.lightningBoltMana);
		end
		Separator();

		-- shock mana sliders
		if (HasSpell("Earth Shock")) and (script_shaman.useEarthShock) then
			Text("Use Earth Shock Above Mana");
			script_shaman.earthShockMana = SliderInt("ES%", 5, 100, script_shaman.earthShockMana);
		end
		if (HasSpell("Flame Shock")) and (script_shaman.useFlameShock) then
			Text("Use Flame Shock Above Mana");
			script_shaman.flameShockMana = SliderInt("FS%", 5, 100, script_shaman.flameShockMana);
		end

		Separator();

		-- shock spells on/off

		Text("Use Shock Spells:");
	
		-- earth shock
		if (HasSpell("Earth Shock")) then
		wasClicked, script_shaman.useEarthShock = Checkbox("Earth Shock", script_shaman.useEarthShock);
		end

		-- flame shock
		if (HasSpell("Flame Shock")) then
		SameLine();
		wasClicked, script_shaman.useFlameShock = Checkbox("Flame Shock", script_shaman.useFlameShock);
		end

		-- frost shock
		if (HasSpell("Frost Shock")) then
		SameLine();
		wasClicked, script_shaman.useFrostShock = Checkbox("Frost Shock", script_shaman.useFrostShock);
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

		if (HasItem("Water Totem")) then
			SameLine();
			wasClicked, script_shaman.useWaterTotem = Checkbox("Use Water Totems", script_shaman.useWaterTotem);
		end

		-- weapon enhancement menu
		if (HasSpell("Rockbiter Weapon")) then
			if (CollapsingHeader("|+| Weapon Enhancement Options")) then
				Text("Weapon Enhancement");
				script_shaman.enhanceWeapon = InputText("Enhancement", script_shaman.enhanceWeapon);
			end
		end

		-- totem menu
		if (HasItem("Earth Totem")) then

			if (CollapsingHeader("|+| Totem Options")) then

				Text("Earth Totem");
					script_shaman.totem = InputText("Earth", script_shaman.totem);

				Separator();
				
				Text("Fire Totem");
					if (HasItem("Fire Totem")) then
						script_shaman.totem2 = InputText("Fire", script_shaman.totem2);
					end

				Text("Water Totem");
					if (HasItem("Water Totem")) then
						script_shaman.totem3 = InputText("Water", script_shaman.totem3);
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
