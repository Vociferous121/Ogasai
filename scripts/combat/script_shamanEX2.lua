script_shamanEX2 = {


}

function script_shamanEX2:setTotemBuffs()

	if (script_shaman.totem == "Stoneskin Totem") then
		script_shaman.totemBuff = "Stoneskin";
	end
	if (script_shaman.totem == "Strength of Earth Totem") then
		script_shaman.totemBuff = "Strength of Earth";
	end

	if (script_shaman.totem3 == "Healing Stream Totem") then
		script_shaman.totemBuff3 = "Healing Stream";
	end
return false;
end

function script_shamanEX2:useTotem()

	local localMana = GetLocalPlayer():GetManaPercentage();
	local hasTarget = GetLocalPlayer():GetUnitsTarget();

	-- remove ghost wolf before combat
	if (localObj:HasBuff("Ghost Wolf")) then
		CastSpellByName("Ghost Wolf");
	end

	if (hasTarget ~= 0) then
		if (not IsAutoCasting("Attack")) then
			targetObj:AutoAttack();
			if (not IsMoving()) then
				targetObj:FaceTarget();
			end
		end
	end


	-- Totem 1
	if (script_shaman.useEarthTotem) and (targetHealth >= 30) and (hasTarget ~= 0) and (not localObj:HasBuff(script_shaman.totemBuff)) then
		if (targetObj:GetDistance() <= 20) and (localMana >= 20) and (targetObj:IsTargetingMe()) and (HasSpell(script_shaman.totem)) then
			if (CastSpellByName(script_shaman.totem)) then
				script_shaman.waitTimer = GetTimeEX() + 1750;
				script_grind:setWaitTimer(1750);
				return true;
			end
			return true;
		end
	end

	-- totem 3
	if (script_shaman.useWaterTotem) and (not localObj:HasBuff(script_shaman.totem3Buff)) and (hasTarget ~= 0) then
		if (targetObj:GetDistance() <= 20) and (targetObj:IsTargetingMe()) and (localMana >= 20) and (HasSpell(script_shaman.totem3)) then
			if (CastSpellByName(script_shaman.totem3)) then
				script_shaman.waitTimer = GetTimeEX() + 1750;
				script_grind:setWaitTimer(1750);
				return true;
			end
			return true;
		end
	end

return false;
end

function script_shamanEX2:ghostWolf()
	-- Shaman Ghost Wolf 
	if (not IsMounted()) and (not script_grind.useMount) and (HasSpell('Ghost Wolf')) and (not localObj:HasBuff('Ghost Wolf')) and (not localObj:IsDead()) then
		if (IsMoving()) then
			StopMoving();
			return false;
		else
			CastSpellByName('Ghost Wolf');
			self.waitTimer = GetTimeEX() + 2500;
			script_grind:setWaitTimer(2500);
			return true;
		end
	return true;
	end
return false;
end

function script_shamanEX2:menu()

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
		Text("Mana Cost Of Healing Spell Percent")
		script_shaman.healMana = SliderInt("Heal Mana %", 5, 99, script_shaman.healMana);
		Text("Healing Spell");
		script_shaman.healingSpell = InputText("Heal Spell", script_shaman.healingSpell);

	end

end
