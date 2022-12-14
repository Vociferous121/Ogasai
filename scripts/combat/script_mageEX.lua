script_mageEX = {

}

function script_mageEX:menu()

	localObj = GetLocalPlayer();

	local wasClicked = false;

	if (not script_mage.fireMage) and (not script_mage.frostMage) then

		script_mage.message = "Select a talent Spec in options!";

	end

	if (CollapsingHeader("Choose Talent Spec")) then

		if (not script_mage.fireMage) then

			wasClicked, script_mage.frostMage = Checkbox("Frost Spec", script_mage.frostMage);
			
			SameLine();

		end

		if (not script_mage.frostMage) then

			wasClicked, script_mage.fireMage = Checkbox("Fire Spec", script_mage.fireMage);
			
			SameLine();

		end
	end

	Separator();

 	if (script_mage.frostMage) or (script_mage.fireMage) then

		if (CollapsingHeader("Mage Combat Options")) then

			local wasClicked = false;

			Text('Drink Below Mana Percentage');
			script_mage.drinkMana = SliderFloat("DM%", 1, 100, script_mage.drinkMana);

			Text('Eat Below Health Percentage');
			script_mage.eatHealth = SliderFloat("EH%", 1, 100, script_mage.eatHealth);

			Text('Use Health Potion Below Percentage');
			script_mage.potionHealth = SliderFloat("HP%", 1, 99, script_mage.potionHealth);

			Text('Use Mana Potion Below Percentage');
			script_mage.potionMana = SliderFloat("MP%", 1, 99, script_mage.potionMana);

			Separator();

			Text('Skills Options:');

			if (localObj:HasRangedWeapon()) then

				wasClicked, script_mage.useWand = Checkbox("Use Wand", script_mage.useWand);

				Text('Wand Attack Speed (1.1 = 1100)');
				script_mage.wandSpeed = InputText("WS", script_mage.wandSpeed);

			end
			
			if (HasSpell("Fire Blast")) then

				wasClicked, script_mage.useFireBlast = Checkbox("Use Fire Blast", script_mage.useFireBlast);

				SameLine();

			end

			if (HasSpell("Cone of Cold")) then

				wasClicked, script_mage.useConeOfCold = Checkbox("Use Cone of Cold", script_mage.useConeOfCold);

				SameLine();

			end

			if (HasSpell("Mana Shield")) then

				wasClicked, script_mage.useManaShield = Checkbox("Use Mana Shield", script_mage.useManaShield);

			end

			if (HasSpell("Polymorph")) then

				wasClicked, script_mage.polymorphAdds = Checkbox("Polymorph Adds", script_mage.polymorphAdds);

				SameLine();

			end
			
			if (HasSpell("Frost Nova")) then

				wasClicked, script_mage.useFrostNova = Checkbox("Use Frost Nova", script_mage.useFrostNova);

			end

			if (HasSpell("Quel'Dorei Meditation")) then

			SameLine();

			wasClicked, script_mage.useQuelDoreiMeditation = Checkbox("Use QuelDoreiMeditation", script_mage.useQuelDoreiMeditation);

			end

			if (HasSpell("Blink")) then

				wasClicked, script_mage.useBlink = Checkbox("Use Blink", script_mage.useBlink);

				SameLine();

			end

			if (HasSpell("Scorch")) and (script_mage.fireMage) and (GetLocalPlayer():GetLevel() >= 27) then

				wasClicked, script_mage.useScorch = Checkbox("Use Scorch", script_mage.useScorch);

			end

			if (HasSpell("Dampen Magic")) then

				wasClicked, script_mage.useDampenMagic = Checkbox("Use Dampen Magic", script_mage.useDampenMagic);

			end

			if (HasSpell("Frost Ward")) then

				wasClicked, script_mage.useFrostWard = Checkbox("Use Frost Ward", script_mage.useFrostWard);

				SameLine();

			end
			
			if (HasSpell("Fire Ward")) then

				wasClicked, script_mage.useFireWard = Checkbox("Use Fire Ward", script_mage.useFireWard);

			end
			
			if (localObj:HasRangedWeapon()) then
				
				if (CollapsingHeader("-- Wand Options")) then

					Text('Wand below script_mage mana percent');
					script_mage.useWandMana = SliderFloat("WM%", 1, 75, script_mage.useWandMana);

					Text('Wand below target HP percent');
					script_mage.useWandHealth = SliderFloat("WH%", 1, 75, script_mage.useWandHealth);

				end
			end

			if (script_mage.useScorch) and (script_mage.fireMage) then

				if (script_mage.fireMage) and (HasSpell("Scorch")) and (GetLocalPlayer():GetLevel() >= 27) then

					if (CollapsingHeader("-- Scorch Options")) then

						Text("How many Scorch debuff stacks on target?");
						script_mage.scorchStacks = SliderInt("ST", 1, 5, script_mage.scorchStacks);

					end
				end
			end

			if (script_mage.useConeOfCold) then

				if (HasSpell("Cone of Cold")) then

					if (CollapsingHeader("-- Cone of Cold Options")) then

						Text('Cone of Cold above script_mage mana percent');
						script_mage.coneOfColdMana = SliderFloat("CCM", 20, 75, script_mage.coneOfColdMana);

						Text('Cone of Cold above target health percent');
						script_mage.coneOfColdHealth = SliderFloat("CCH", 5, 50, script_mage.coneOfColdHealth);

					end
				end
			end
			
			if (HasSpell("Evocation")) then	

				if (CollapsingHeader("-- Evocation Options")) then

					Text('Evocation above health percent');
					script_mage.evocationHealth = SliderFloat("EH%", 1, 90, script_mage.evocationHealth);

					Text('Evocation below mana percent');
					script_mage.evocationMana = SliderFloat("EM%", 1, 90, script_mage.evocationMana);

					if (HasSpell("Quel'Dorei Meditation")) then

						Text('Queldorei Meditation below mana percent');
						script_mage.QuelDoreiMeditationMana = SliderFloat("QM%", 1, 90, script_mage.QuelDoreiMeditationMana);

					end
				end
			end

			if (script_mage.frostMage) and (HasSpell("Ice Block")) then

				if (CollapsingHeader("-- Ice Block Options")) then

					Text('Ice Block below health percent');
					script_mage.iceBlockHealth = SliderFloat("IBH%", 5, 90, script_mage.iceBlockHealth);

					Text('Ice Block below mana percent');
					script_mage.iceBlockMana = SliderFloat("IBM%", 5, 90, script_mage.iceBlockMana);

				end
			end

			if (script_mage.useManaShield) then

				if (HasSpell("Mana Shield")) then

					if (CollapsingHeader("-- Mana Shield Options")) then

						Text('Mana Shield below script_mage health percent');
						script_mage.manaShieldHealth = SliderFloat("MS%", 5, 99, script_mage.manaShieldHealth);

						Text('Mana Shield above script_mage mana percent');
						script_mage.manaShieldMana = SliderFloat("MM%", 10, 65, script_mage.manaShieldMana);

					end
				end
			end

			if (HasSpell("Conjure Mana Gem")) then

				if (CollapsingHeader("-- Mana Gem Options")) then

					script_mage.manaGemMana = SliderFloat("MG%", 1, 90, script_mage.manaGemMana);		

				end
			end
		end
	end
end