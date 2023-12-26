script_druidEX = {

}

function script_druidEX:removeTravelForm()

	if (GetLocalPlayer():HasBuff("Travel Form")) then
		CastSpellByName("Travel Form");
		script_grind:setWaitTimer(1500);
		return true;
	end

return false;
end

function script_druidEX:removeBearForm()

	if (GetLocalPlayer():HasBuff("Bear Form")) then
		CastSpellByName("Bear Form");
		script_grind:setWaitTimer(1500);
		return true;
	end
	if (GetLocalPlayer():HasBuff("Dire Bear Form")) then
		CastSpellByName("Dire Bear Form");
		script_grind:setWaitTimer(1500);
		return true;
	end

return false;
end

function script_druidEX:removeCatForm()

	if (GetLocalPlayer():HasBuff("Cat Form")) then
		CastSpellByName("Cat Form");
		script_grind:setWaitTimer(1500);
		return true;
	end

return false
end

function script_druidEX:removeMoonkinForm()

	if (GetLocalPlayer():HasBuff("Moonkin Form")) then
		CastSpellByName("Moonkin Form");
		script_grind:setWaitTimer(1500);
		return true;
	end

return false;
end

function script_druidEX:travelForm()

	localObj = GetLocalPlayer();
	if (not IsMounted()) and (not script_grind.useMount) and (not IsIndoors()) then
		if (HasSpell("Travel Form")) then
			if (localObj:HasBuff("Bear Form")) then
				if (CastSpellByName("Bear Form")) then
					self.waitTimer = GetTimeEX() + 1500;
					return 0;
				end
			end
			if (localObj:HasBuff("Dire Bear Form")) then
				if (CastSpellByName("Dire Bear Form")) then
					self.waitTimer = GetTimeEX() + 1500;
				end
			end
			if (localObj:HasBuff("Cat Form")) then
				if (CastSpellByName("Cat Form")) then
					self.waitTimer = GetTimeEX() + 1500;
					return 0;
				end
			end
		end
	end
	
	if (not IsMounted()) and (not script_grind.useMount) and (not IsIndoors()) then
		if (HasSpell("Travel Form")) and (not localObj:HasBuff("Travel Form")) and (not IsIndoors()) then
			if (CastSpellByName("Travel Form")) then
				self.waitTimer = GetTimeEX() + 1500;
				return 0;
			end
		end
	end

return true;
end


function script_druidEX:bearForm()

	local localObj = GetLocalPlayer();
	local locallevel = localObj:GetLevel();
	
	if (not IsMounted()) then
		if (not HasSpell("Dire Bear Form")) then
			if (HasSpell("Bear Form")) then
				if (CastSpellByName("Bear Form")) then
					self.waitTimer = GetTimeEX() + 1500;
					return 0;
				end
			end
		elseif (HasSpell("Dire Bear Form")) then
			if (CastSpellByName("Dire Bear Form")) then
				self.waitTimer = GetTimeEX() + 1500;
				return 0;
			end
		end
	end

return true;
end	

function script_druidEX:moonkinForm()

return true;
end

function script_druidEX:menu()


	if (script_grind.useBear) then
		script_druid.useCat = false;
		script_druid.useMoonkin = false;
	end
	if (script_grind.useCat) then
		script_druid.useBear = false;
		script_druid.useMoonkin = false;
	end

	if (HasSpell("Bear Form")) or (HasSpell("Dire Bear Form")) then

		if (CollapsingHeader("Choose Form For Combat")) then
Separator();

			if (not script_druid.useCat) and (not script_druid.useMoonkin) and (HasSpell("Bear Form") or HasSpell("Dire Bear Form")) then
				wasClicked, script_druid.useBear = Checkbox("Bear Form", script_druid.useBear);
			end


			if (not script_druid.useBear) and (not script_druid.useMoonkin) and (HasSpell("Cat Form")) then
				SameLine();
				wasClicked, script_druid.useCat = Checkbox("Cat Form", script_druid.useCat);
			end

			if (not script_druid.useBear) and (not script_druid.useCat) and (HasSpell("Cat Form")) then
				SameLine();
				wasClicked, script_druid.useMoonkin = Checkbox("Moonkin Form", script_druid.useMoonkin);
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
		script_druid.meleeDistance = SliderFloat("Melee range", 1, 8, script_druid.meleeDistance);

		Separator();

		if (script_druid.useBear) or (script_druid.useCat) then
			if (HasSpell("Bear Form") or HasSpell("Cat Form") or HasSpell("Dire Bear Form")) then
				Text("Health perecent to heal when shapeshifted");
				script_druid.healthToShift = SliderInt("Shapeshift to heal HP%", 0, 65, script_druid.healthToShift);
				Separator();
				Text("Controlled by drink mana percentage");
				wasClicked, script_druid.shiftToDrink = Checkbox("Leave Form To Drink", script_druid.shiftToDrink);
				WasClicked, script_druid.useRest = Checkbox("Rest On Low Mana/HP - Shapeshifted", script_druid.useRest);
				Separator();
				Text("Cost of Shapeshift - Mana Percent");
				script_druid.shapeshiftMana = SliderInt("SSMP%", 15, 35, script_druid.shapeshiftMana);
			end
		end

		if (script_druid.useBear) and (HasSpell("Bear Form") or HasSpell("Dire Bear Form")) then
			if (CollapsingHeader("|+| Bear Form Options")) then
				Text("Maul Rage Cost");
				script_druid.maulRage = SliderInt("Rage", 10, 15, script_druid.maulRage);
				if (HasSpell("Feral Charge")) then
					wasClicked, script_druid.useCharge = Checkbox("Use Charge", script_druid.useCharge);
				end
			end
		end

		if (script_druid.useCat) and (HasSpell("Cat Form")) then
			if (CollapsingHeader("|+| Cat Form Options")) then
				wasClicked, script_druid.useStealth = Checkbox("Use Stealth", script_druid.useStealth);
				Text("Stealth Opener");
				script_druid.stealthOpener = InputText("Opener", script_druid.stealthOpener);
			end
		end

		if (script_druid.useMoonkin) and (HasSpell("Moonkin Form")) then
				if (CollapsingHeader("|+| Moonkin Form Options")) then
					Text("Nothing here yet!");
					Text("To DO!");
				end
		end

	end

	if (CollapsingHeader("Druid Heal Options")) then
		Text('Rest options:');
		script_druid.eatHealth = SliderInt("Eat below HP%", 1, 100, script_druid.eatHealth);
		script_druid.drinkMana = SliderInt("Drink below Mana%", 1, 100, script_druid.drinkMana);
		script_druid.potionHealth = SliderInt("Potion below HP%", 5, 25, script_druid.potionHealth);
		script_druid.potionMana = SliderInt("Potion below Mana%", 5, 25, script_druid.potionMana);
		Text('You can add more food/drinks in script_helper.lua');

		Separator();

		if (HasSpell("Rejuvenation")) then
			Text("Rejuvenation below HP percentage");
			script_druid.rejuvenationHealth = SliderInt("RHP%", 25, 100, script_druid.rejuvenationHealth);
		end
		if (HasSpell("Regrowth")) then
			Text("Regrwoth below HP percentage");
			script_druid.regrowthHealth = SliderInt("Regrowth below HP%", 15, 99, script_druid.regrowthHealth);
		end

		Text("Healing Touch below HP percentage");
		script_druid.healingTouchHealth = SliderInt("Healing Touch HP%", 15, 99, script_druid.healingTouchHealth);
	end
end