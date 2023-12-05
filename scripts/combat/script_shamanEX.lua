script_shamanEX = {

		healsMenuLoaded = include("scripts\\combat\\script_shamanEX2.lua"),

}

function script_shamanEX:menu()
	if (CollapsingHeader("Shaman Combat Options")) then

		local wasClicked = false;

		
		Text('Combat options:');
		SameLine();
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

				if (script_shaman.useEarthTotem) then
					Text("Earth Totem");
						script_shaman.totem = InputText("Earth", script_shaman.totem);
				end

				if (script_shaman.useFireTotem) then
					Separator();
					Text("Fire Totem");
						if (HasItem("Fire Totem")) then
						script_shaman.totem2 = InputText("Fire", script_shaman.totem2);	
						end
				end
		
				if (script_shaman.useWaterTotem) then
					Text("Water Totem");
						if (HasItem("Water Totem")) then
						script_shaman.totem3 = InputText("Water", script_shaman.totem3);
						end
				end
			end
		end
		
	end

	-- load heal menu
	script_shamanEX2:menu();
end