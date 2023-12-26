script_paladinEX = {


}

function script_paladinEX:healsAndBuffs(localObj, localMana)

	local localMana = GetLocalPlayer():GetManaPercentage();
	local localHealth = GetLocalPlayer():GetHealthPercentage();
	local localObj = GetLocalPlayer();

	if (not IsMounted()) then
		if (not IsDrinking()) and (not IsEating()) then
			if (not IsStanding()) then
				JumpOrAscendStart();
			end
		end
	end
	-- Set aura - cast aura
	if (script_paladin.aura ~= 0 and not IsMounted()) then
		if (not localObj:HasBuff(script_paladin.aura) and HasSpell(script_paladin.aura)) then
			CastSpellByName(script_paladin.aura);
			script_grind:setWaitTimer(1750);
		end
	end

	-- Buff with Blessing
	if (script_paladin.blessing ~= 0) and (HasSpell(script_paladin.blessing)) then
		if (localMana > 10) and (not localObj:HasBuff(script_paladin.blessing)) then
			Buff(script_paladin.blessing, localObj);
			script_grind:setWaitTimer(1750);
			return 0;
		end
	end

	if (IsInCombat()) and (localObj:HasBuff("Judgement")) and (not IsSpellOnCD("Judgement")) and (localObj:HasBuff("Seal of Righteousness")) then
		CastSpellByName("Judgement", targetObj);
		script_grind:setWaitTimer(1650);
		return 0;
	end

	-- Check: Use Lay of Hands
	if (localHealth < script_paladin.lohHealth) and (HasSpell("Lay on Hands")) and (not IsSpellOnCD("Lay on Hands")) then 
		if (Cast("Lay on Hands", localObj)) then 
			script_paladin.message = "Cast Lay on Hands...";
			return 0;
		end
	end

	-- bubble hearth on player engange

	if (script_paladin.useBubbleHearth) and (HasSpell("Divine Shield")) and (not IsSpellOnCD("Divine Shield")) then
		if (GetTarget() ~= nil) and (targetObj ~= nil) then
			if (UnitIsPlayer(targetObj)) and (UnitIsPVP(targetObj)) and (GetTarget() ~= localObj) then
				script_grind.tickRate = 50;
				CastSpellByName("Divine Shield");
				script_paladin.message = "Cast Divine Shield...";
				return 0;
			end
		end
	end

	if (script_paladin.useBubbleHearth) and (localObj:HasBuff("Divine Shiel")) then
		UseItem("Hearthstone");
		script_grind:setWaitTimer(12000);
		StopBot();
		return;
	end
			
	-- Check: Divine Protection if BoP on CD
	if(localHealth <= script_paladin.shieldHealth) and (not localObj:HasDebuff("Forbearance")) then
		if (HasSpell("Divine Shield")) and (not IsSpellOnCD("Divine Shield")) then
			CastSpellByName("Divine Shield");
			script_paladin.message = "Cast Divine Shield...";
			return 0;
		elseif (HasSpell("Divine Protection")) and (not IsSpellOnCD("Divine Protection")) then
			CastSpellByName("Divine Protection");
			script_paladin.message = "Cast Divine Protection...";
			return 0;
		elseif (HasSpell("Blessing of Protection")) and (not IsSpellOnCD("Blessing of Protection")) then
			CastSpellByName("Blessing of Protection");
			script_paladin.message = "Cast Blessing of Protection...";
			return 0;
		end
	end

	-- force cast heal when buffed with shield
	if (localObj:HasBuff("Divine Shield") or localObj:HasBuff("Divine Protection") or localObj:HasBuff("Blessing of Protection")) then
		if (localMana > 15) then
			if (IsMoving()) then
				StopMoving();
			end
			CastSpellByName("Holy Light", localObj);
			script_grind:setWaitTimer(2550);
			return 0;
		else
			if (localMana > 8) and (HasSpell("Flash of Light")) then
				if (IsMoving()) then
					StopMoving();
				end
				CastSpellByName("Flash of Light", localObj);
				script_grind:setWaitTimer(1550);
				return 0;
			end
		end
	end

	-- cleanse
	if (script_checkDebuffs:hasPoison()) or (script_checkDebuffs:hasDisease()) or (script_checkDebuffs:hasMagic()) then
		if (HasSpell("Cleanse")) and (localMana > 60) then
			if (Buff("Cleanse", localObj)) then 
				script_paladin.message = "Cleansing..."; 
					script_grind:setWaitTimer(1750); 
					return 0; 
			end
		end
	end

	-- remove disease with purify
	if (script_checkDebuffs:hasDisease()) or (script_checkDebuffs:hasPoison()) then
		if (HasSpell("Purify")) and (localMana > 60) then
			if (Buff("Purify", localObj)) then 
				script_paladin.message = "Cleansing..."; 
				script_grind:setWaitTimer(1750); 
				return 0; 
			end
		end
	end

	-- Check: Remove movement disables with Freedom
	if (localObj:IsMovementDisabed() or script_checkDebuffs:hasDisabledMovement()) and (HasSpell("Blessing of Freedom")) then
		Buff("Blessing of Freedom", localObj);
		return 0;
	end

	-- flash of light not in combat
	if (not IsInCombat()) and (localMana > script_paladin.drinkMana + 6) and (GetLocalPlayer():GetUnitsTarget() == 0) then
		if (HasSpell("Flash of Light")) and (localHealth >= script_paladin.holyLightHealth) and (localHealth <= 82) and (not IsLooting()) and (script_grind.lootObj == nil) then
			script_grind.tickRate = 100;
			if (IsMoving()) then
				StopMoving();
			end
			CastHeal("Flash of Light", localObj);
			ClearTarget();
			script_grind:setWaitTimer(1500);
		end
		return;
	end

	local checkHealth = GetLocalPlayer():GetHealthPercentage();

	-- holy light
	if (localMana > 18) and (checkHealth < script_paladin.holyLightHealth) and (not IsMoving()) then
		if (IsMoving()) then
			StopMoving();
		end
		CastHeal("Holy Light", localObj);
		script_grind:setWaitTimer(3250);
		return 0;
	end

	-- Flash of Light in combat
	if (script_paladin.useFlashOfLightCombat) then
		if (IsInCombat()) and (HasSpell("Flash of Light")) and (localHealth <= script_paladin.flashOfLightHP) and (localMana >= 10) then
			script_grind.tickRate = 100;
			if (IsMoving()) then
				StopMoving();
			end
			CastHeal("Flash of Light", localObj);
			script_grind:setWaitTimer(1500);
			script_paladin.message = "Flash of Light enabled - Healing!";
			if (localMana > 8) then
				CastSpellByName("Flash of Light", localObj);
			end			
		end
	return;	
	end

	--flash of light in combat very low health and mana
	if (HasSpell("Flash of Light")) and (IsInCombat()) and (localMana < 15) and (localMana > 5) and (localHealth < script_paladin.holyLightHealth) then
		script_grind.tickRate = 100;
		if (IsMoving()) then
			StopMoving();
		end

		CastHeal("Flash of Light", localObj);
		script_grind:setWaitTimer(1500);
		script_paladin.message = "We are dying - trying to save!";
		return;
	end

	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(550, 1100);

		if (IsMoving()) or (not IsInCombat()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom
		elseif (IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		end
	end
	
return false;
end

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

		script_paladin.meleeDistance = SliderFloat("Melee range", 1, 8, script_paladin.meleeDistance);
		if (HasSpell("Divine Shield")) then
			wasClicked, script_paladin.useBubbleHearth = Checkbox("Bubble/Hearth Enemy Player Combat", script_paladin.useBubbleHearth);
		end
		Separator();

		wasClicked, script_paladin.useJudgement = Checkbox("Use Judgement", script_paladin.useJudgement);

		if (HasSpell("Seal of the Crusader")) then
			SameLine();
			wasClicked, script_paladin.useSealOfCrusader = Checkbox("Use Crusader Seal", script_paladin.useSealOfCrusader);
		end

		if (HasSpell("Consecration")) then
			Text("Consecrate Mana when 2 or more adds");
			script_paladin.consecrationMana = SliderFloat("Consecration above Mana %", 1, 99, script_paladin.consecrationMana);
		end

		if (CollapsingHeader("|+| Auras and Blessings")) then

			Text("Aura and Blessing options:");
			script_paladin.aura = InputText("Aura", script_paladin.aura);
			script_paladin.blessing = InputText("Blessing", script_paladin.blessing);

		end

		if (CollapsingHeader("|+| Heal Options")) then

			Text("Heal Options:")

			if (HasSpell("Flash of Light")) then
				Text("Otherwise the bot will use Holy Light only");
				wasClicked, script_paladin.useFlashOfLightCombat = Checkbox("Flash of Light in Combat On/Off", script_paladin.useFlashOfLightCombat);
			end

			Separator();

			script_paladin.holyLightHealth = SliderInt("Holy Light when below HP % (in combat)", 1, 99, script_paladin.holyLightHealth);
			
			if (HasSpell("Flash of Light")) then
				script_paladin.flashOfLightHP = SliderInt("Flash of Light when below HP %", 1, 99, script_paladin.flashOfLightHP);
			end

			if (HasSpell("Lay on Hands")) then
				script_paladin.lohHealth = SliderInt("Lay on Hands below HP %", 5, 15, script_paladin.lohHealth);
			end

			if (HasSpell("Blessing of Protection")) then
				script_paladin.shieldHealth = SliderInt("Shield below HP %", 1, 20, script_paladin.shieldHealth);
			end
		end
	end
end
