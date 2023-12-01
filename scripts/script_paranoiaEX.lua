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