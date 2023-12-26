script_paranoiaEX = {


}



function script_paranoiaEX:checkStealth()

	local localObj = GetLocalPlayer();
	local localMana = localObj:GetManaPercentage();

	-- rogue stealth
	if (not IsMounted() and not script_grind.useMount) and (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (not IsStealth()) and (not IsInCombat()) and (script_paranoia.currentTime < script_grind.currentTime2 - 190) then
		script_grind:setWaitTimer(1500);
		CastSpellByName("Stealth");
	end

	-- druid cat form
	if (not IsMounted() and not script_grind.useMount) and (not HasForm()) and (HasSpell("Prowl")) and (localMana >= script_druid.shapeshiftMana) then

		script_grind:setWaitTimer(1500);
		CastSpellByName("Cat Form");
	end

	-- druid cat form prowl
	if (not IsMounted() and not script_grind.useMount) and (HasSpell("Cat Form")) and (IsCatForm()) and (HasSpell("Prowl")) and (not IsStealth()) and (not IsSpellOnCD("Prowl")) and (not IsInCombat()) and (script_paranoia.currentTime < script_grind.currentTime2 - 190) then

		script_grind:setWaitTimer(1500);
		CastSpellByName("Prowl");
	end
end


function script_paranoiaEX:checkStealth2()

	local localObj = GetLocalPlayer();

	-- rogue stealth
	if (not IsMounted()) and (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (not IsStealth()) then
		if (CastSpellByName("Stealth")) then
		script_grind:setWaitTimer(1500);
			return 0;
		end
	end

	-- use shadowmeld on paranoia
	if (not IsMounted()) and (HasSpell("Shadowmeld")) and (not IsStealth()) then
		if (not IsSpellOnCD("Shadowmeld")) and (not localObj:HasBuff("Shadowmeld")) and (not HasForm()) then
			script_grind:setWaitTimer(1500);
			if (CastSpellByName("Shadowmeld")) then
				return 0;
			end
		elseif (localObj:HasBuff("Bear Form")) then
			if (CastSpellByName("Bear Form")) then
				return 0;
			end
			if (CastSpellByName("Shadowmeld")) then
				return 0;
			end
		end
	end

	-- druid cat form and stealth while paranoid
	if (not IsMounted()) and (not HasForm()) and (HasSpell("Cat Form")) and (GetLocalPlayer():GetManaPercentage() >= 40) and (IsStanding()) then
		script_grind:setWaitTimer(1500);
		if (CastSpellByName("Cat Form")) then
			return 0;
		end
	end
	if (not IsMounted()) and (IsCatForm()) and (HasSpell("Prowl")) and (not IsSpellOnCD("Prowl")) and (not IsStealth()) then
		script_grind:setWaitTimer(1500);
		if (CastSpellByName("Prowl")) then
			return 0;
		end
	end
end