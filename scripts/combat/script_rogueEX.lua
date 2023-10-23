script_rogueEX = {

}

function script_rogueEX:menu()
	Separator();
	if (CollapsingHeader("Temporary Grind/Rotation Buttons")) then
		if (not script_rogue.enableRotation) then -- if not showing rotation button
			wasClicked, script_rogue.enableGrind = Checkbox("Grinder", script_rogue.enableGrind); -- then show grind button
				SameLine();
		end
		
		if (not script_rogue.enableGrind) then -- if not showing grind button
			wasClicked, script_rogue.enableRotation = Checkbox("Rotation", script_rogue.enableRotation); -- then show rotation button
				SameLine();
		end	
	Separator();
	end

	if (script_rogue.enableGrind) then
		Separator();
		if (CollapsingHeader("Rogue Grind Options")) then
			local wasClicked = false;
			Text('Eat below health percent');
			script_rogue.eatHealth = SliderInt('EHP %', 1, 100, script_rogue.eatHealth);
			Text("Potion below health percent");
			script_rogue.potionHealth = SliderInt('PHP %', 2, 10, script_rogue.potionHealth);
			Separator();
			Text("Melee Range to target");
			script_rogue.meleeDistance = SliderFloat('MR (yd)', 1, 6, script_rogue.meleeDistance);
			Separator();
			wasClicked, script_rogue.stopIfMHBroken = Checkbox("Stop bot if main hand is broken", script_rogue.stopIfMHBroken);
			SameLine();
			wasClicked, script_rogue.useSliceAndDice = Checkbox("Use Slice & Dice", script_rogue.useSliceAndDice);
			wasClicked, script_rogue.useStealth = Checkbox("Use Stealth", script_rogue.useStealth);
			Text("Stealth range to target");
			script_rogue.stealthRange = SliderInt('SR (yd)', 1, 100, script_rogue.stealthRange);

			if (CollapsingHeader("--Combo Point Generator")) then
				Text("Combo Point ability");
				script_rogue.cpGenerator = InputText("CPA", script_rogue.cpGenerator);
				Text("Energy cost of CP-ability");
				script_rogue.cpGeneratorCost = SliderInt("Energy", 20, 50, script_rogue.cpGeneratorCost);
			end
			
			if (CollapsingHeader("--Stealth Ability Opener")) then
				Text("Stealth ability opener");
				script_rogue.stealthOpener = InputText("STO", script_rogue.stealthOpener);
			end

			if (CollapsingHeader("--Adrenaline Rush / Blade Flurry Options")) then
				Text("Use Adrenaline Rush with Blade Furry health percent");
				wasClicked, script_rogue.adrenRushCombo = Checkbox("Use Adren Blade Flurry combo", script_rogue.adrenRushCombo);
				script_rogue.adrenRushComboHP = SliderInt("Health below percent", 15, 75, script_rogue.adrenRushComboHP);
			end

			if (CollapsingHeader("--Throwing Weapon Options")) then
				wasClicked, script_rogue.throwOpener = Checkbox("Pull with throw (if stealth disabled)", script_rogue.throwOpener);	
				Text("Throwing weapon");
				script_rogue.throwName = InputText("TW", script_rogue.throwName);
			end
			
			if (CollapsingHeader("--Poisons Options")) then
				wasClicked, script_rogue.usePoison = Checkbox("Use poison on weapons", script_rogue.usePoison);
				Text("Poison on Main Hand");
				script_rogue.mainhandPoison = InputText("PMH", script_rogue.mainhandPoison);
				Text("Poison on Off Hand");
				script_rogue.offhandPoison = InputText("POH", script_rogue.offhandPoison);
			end
		end
	end
			-- rotation menu
	if (script_rogue.enableRotation) then
		Separator();
		if(CollapsingHeader("Rogue Talent Rotation Options")) then
			wasClicked, script_rogue.useSliceAndDice = Checkbox("Use Slice & Dice", script_rogue.useSliceAndDice);
			SameLine();
			wasClicked, script_rogue.useKidneyShot = Checkbox("Kidney Shot Interrupts", script_rogue.useKidneyShot);
			wasClicked, script_rogue.useStealth = Checkbox("Use Stealth", script_rogue.useStealth);
			SameLine();
			wasClicked, script_rogue.enableFaceTarget = Checkbox("Auto Face Target", script_rogue.enableFaceTarget);
			wasClicked, script_rogue.enableBladeFlurry = Checkbox("Blade Flurry on CD", script_rogue.enableBladeFlurry);
			SameLine();
			wasClicked, script_rogue.enableAdrenRush = Checkbox("Adren Rush on CD", script_rogue.enableAdrenRush);
			Text("Experimental Elite Target Rotation");
			wasClicked, script_rogue.rotationTwo = Checkbox("Rotation 2", script_rogue.rotationTwo);
		end
		if (CollapsingHeader("Rogue Rotation Combat Options")) then
			Separator();
			local wasClicked = false;
			Text('Eat below health percent');
			script_rogue.eatHealth = SliderInt('EHP %', 1, 50, script_rogue.eatHealth);
			Text("Potion below health percent");
			script_rogue.potionHealth = SliderInt('PHP %', 1, 50, script_rogue.potionHealth);

			if (CollapsingHeader("--Combo Point Generator Options")) then
				Text("Combo Point Generator Ability");
				script_rogue.cpGenerator = InputText("CPA", script_rogue.cpGenerator);
				Text("Energy cost of CP-ability");
				script_rogue.cpGeneratorCost = SliderInt("Energy", 20, 50, script_rogue.cpGeneratorCost);
			end

			if (CollapsingHeader("--Stealth Opener Options")) then
				Text("Stealth ability opener");
				script_rogue.stealthOpener = InputText("STO", script_rogue.stealthOpener);
				Text("Stealth - Distance to target"); 
				script_rogue.stealthRange = SliderInt('SR (yd)', 1, 50, script_rogue.stealthRange);
			end

			if (CollapsingHeader("--Poison Options")) then
				Text("Poison on Main Hand");
				script_rogue.mainhandPoison = InputText("PMH", script_rogue.mainhandPoison);
				Text("Poison on Off Hand");
				script_rogue.offhandPoison = InputText("POH", script_rogue.offhandPoison);
			end
		end
	end
end