script_rogueEX2 = {}

function script_rogueEX2:menu()

	if (HasSpell("Expose Armor")) and (script_rogue.useExposeArmor) then
		if (CollapsingHeader("|+| Expose Armor Options")) then
			Text("Combo Points To Apply Expose Armor");
			script_rogue.exposeArmorStacks = SliderInt("EAS", 1, 5, script_rogue.exposeArmorStacks);
		end
	end
	if (HasSpell("Rupture")) and (script_rogue.useRupture) then
		if (CollapsingHeader("|+| Rupture Options")) then
			Text("Combo Points To Apply Rupture");
			script_rogue.ruptureStacks = SliderInt("RUS", 1, 5, script_rogue.ruptureStacks);
		end
	end
end

function script_rogueEX2:rotationMenu()

		-- rotation menu
	if (script_rogue.enableRotation) then
		Separator();
		if(CollapsingHeader("Rogue Talent Rotation Options")) then
			Separator();
			if (HasSpell("Slice and Dice")) then
				wasClicked, script_rogue.useSliceAndDice = Checkbox("Use Slice & Dice", script_rogue.useSliceAndDice);
			end
			if (HasSpell("Kidney Shot")) then
				SameLine();
				wasClicked, script_rogue.useKidneyShot = Checkbox("Kidney Shot Interrupts", script_rogue.useKidneyShot);
			end
			if (HasSpell("Stealth")) then
				SameLine();
				wasClicked, script_rogue.useStealth = Checkbox("Use Stealth", script_rogue.useStealth);
			end
			wasClicked, script_rogue.enableFaceTarget = Checkbox("Auto Face Target", script_rogue.enableFaceTarget);
			if (HasSpell("Blade Flurry")) then
				SameLine();
				wasClicked, script_rogue.enableBladeFlurry = Checkbox("Blade Flurry on CD", script_rogue.enableBladeFlurry);
			end
			if (HasSpell("Adrenaline Rush")) then
				wasClicked, script_rogue.enableAdrenRush = Checkbox("Adren Rush on CD", script_rogue.enableAdrenRush);
			end
			Text("Experimental Elite Target Rotation");
			wasClicked, script_rogue.rotationTwo = Checkbox("Rotation 2 (In Groups - Elites)", script_rogue.rotationTwo);

			Separator();
			if (HasSpell("Expose Armor")) then
				wasClicked, script_rogue.useExposeArmor = Checkbox("Use Expose Armor", script_rogue.useExposeArmor);
			end
			if (HasSpell("Rupture")) then
				SameLine();
				wasClicked, script_rogue.useRupture = Checkbox("Use Rupture", script_rogue.useRupture);
			end
		end
		if (CollapsingHeader("Rogue Rotation Combat Options")) then
			Separator();
			local wasClicked = false;
			Text('Eat below health percent');
			script_rogue.eatHealth = SliderInt('EHP %', 1, 50, script_rogue.eatHealth);
			Text("Potion below health percent");
			script_rogue.potionHealth = SliderInt('PHP %', 1, 50, script_rogue.potionHealth);

			if (HasSpell("Riposte")) then
				if (CollapsingHeader("|+| Riposte Skill Options")) then
					script_rogue.riposteActionBarSlot = InputText("RS", script_rogue.riposteActionBarSlot);	-- riposte
					Text("Action Bar Slots 1-12");
				end
			end

			if (CollapsingHeader("|+|Combo Point Generator Options")) then
				Text("Combo Point Generator Ability");
				script_rogue.cpGenerator = InputText("CPA", script_rogue.cpGenerator);
				Text("Energy cost of CP-ability");
				script_rogue.cpGeneratorCost = SliderInt("Energy", 20, 50, script_rogue.cpGeneratorCost);
			end

			if (CollapsingHeader("|+|Stealth Opener Options")) then
				Text("Stealth ability opener");
				script_rogue.stealthOpener = InputText("STO", script_rogue.stealthOpener);
				Text("Stealth - Distance to target"); 
				script_rogue.stealthRange = SliderInt('SR (yd)', 1, 50, script_rogue.stealthRange);
			end
			if (GetLocalPlayer():GetLevel() >= 20) then
				if (CollapsingHeader("|+|Poison Options")) then
					Text("Poison on Main Hand");
					script_rogue.mainhandPoison = InputText("PMH", script_rogue.mainhandPoison);
					Text("Poison on Off Hand");
					script_rogue.offhandPoison = InputText("POH", script_rogue.offhandPoison);
				end
			end
			script_rogueEX2:menu();
		end
	end
end