script_paranoiaEX = {


}



function script_paranoiaEX:checkStealth()

	local localObj = GetLocalPlayer();
	local localMana = localObj:GetManaPercentage();

	if (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (not localObj:HasBuff("Stealth")) and (not IsInCombat()) and (script_paranoia.currentTime < script_grind.currentTime2 - 190) then
		CastSpellByName("Stealth");
	end

	if (not localObj:HasBuff("Bear Form")) and (not localObj:HasBuff("Dire Bear Form")) and (not localObj:HasBuff("Moonkin Form")) and (not localObj:HasBuff("Cat Form")) and (localObj:HasBuff("Cat Form")) and (not localObj:HasBuff("Travel Form")) and (HasSpell("Prowl")) and (localMana >= script_druid.shapeshiftMana) then
		CastSpellByName("Cat Form");
	end

	if (HasSpell("Cat Form")) and (localObj:HasBuff("Cat Form")) and (HasSpell("Prowl")) and (not localObj:HasBuff("Prowl")) and (not IsSpellOnCD("Prowl")) and (not IsInCombat()) and (script_paranoia.currentTime < script_grind.currentTime2 - 190) then
		CastSpellByName("Prowl");
	end
end




function script_paranoiaEX:checkStealth2()

	local localObj = GetLocalPlayer();

	if (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (not localObj:HasBuff("Stealth")) then
		if (CastSpellByName("Stealth")) then
			return 0;
		end
	end

	-- use shadowmeld on paranoia
	if (HasSpell("Shadowmeld")) and (not localObj:HasBuff("Stealth")) then
		if (not IsSpellOnCD("Shadowmeld")) and (not localObj:HasBuff("Shadowmeld")) and (not localObj:HasBuff("Bear Form")) and (not localObj:HasBuff("Dire Bear Form")) and (not localObj:HasBuff("Cat Form")) then
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
	if (not localObj:HasBuff("Cat Form")) and (not localObj:HasBuff("Bear Form")) and (HasSpell("Cat Form")) and (GetLocalPlayer():GetManaPercentage() >= 40) and (IsStanding()) then
		if (CastSpellByName("Cat Form")) then
			return 0;
		end
	end
	if (localObj:HasBuff("Cat Form")) and (HasSpell("Prowl")) and (not IsSpellOnCD("Prowl")) and (not localObj:HasBuff("Prowl")) then
		if (CastSpellByName("Prowl")) then
			return 0;
		end
	end
end