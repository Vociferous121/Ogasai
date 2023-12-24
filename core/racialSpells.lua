racialSpells = {

}

function CheckRacialSpells()

	Berserking();
	EscapeArtist();
	WarStomp();
	StoneForm();
	ElunesGrace();
	BloodFury();

return false;
end

function Berserking()

	if (HasSpell("Berserking")) and (not IsSpellOnCD("Berserking")) and (not GetLocalPlayer():HasBuff("Berserking")) then
		if (not IsCasting()) and (not IsChanneling()) and (not IsStunned()) then
			CastSpellByName("Berserking", GetLocalPlayer());
			return true;
		end
	end

return false;
end

function EscapeArtist()

	if (HasSpell("Escape Artsist")) and (not IsSpellOnCD("Escape Artist")) and (script_checkDebuffs:hasDisabledMovement()) then
		if (not IsCasting()) and (not IsChanneling()) and (not IsStunned()) then
			CastSpellByName("Escape Artist", GetLocalPlayer());
			return true;
		end
	end

return false;
end

function WarStomp()

	if (HasSpell("War Stomp")) and (not IsSpellOnCD("War Stomp")) then
		if (GetLocalPlayer():GetUnitsTarget() ~= 0) then
			if (not IsCasting()) and (not IsChanneling()) and (not IsStunned()) then
				CastSpellByName("War Stomp", GetLocalPlayer());
				return true;
			end
		end
	end

return false;
end

function Shadowmeld()

	if (HasSpell("Shadowmeld")) and (not IsSpellOnCD("Shadowmeld")) and (not GetLocalPlayer():HasBuff("Shadowmeld")) and (not IsInCombat()) then
		if (not IsCasting()) and (not IsChanneling()) and (not IsStunned()) then
			CastSpellByName("Shadowmeld", GetLocalPlayer());
			return true;
		end
	end

return false;
end

function StoneForm()

	if (HasSpell("Stone Form")) and (not IsSpellOnCD("Stone Form")) and (not GetLocalPlayer():HasBuff("Stone Form")) then
		if (not IsCasting()) and (not IsChanneling()) and (not IsStunned()) then
			CastSpellByName("Stone Form", GetLocalPlayer());
			return true;
		end
	end

return false;
end

function ElunesGrace()

	if (HasSpell("Elune's Grace")) and (not IsSpellOnCD("Elune's Grace")) and (not GetLocalPlayer():HasBuff("Elune's Grace")) then
		if (not IsCasting()) and (not IsChanneling()) and (not IsStunned()) then
			CastSpellByName("Elune's Grace", GetLocalPlayer());
			return true;
		end
	end

return false;
end

function BloodFury()

	if (HasSpell("Blood Fury")) and (not IsSpellOnCD("Blood Fury")) and (not GetLocalPlayer():HasBuff("Blood Fury")) then
		if (not IsCasting()) and (not IsChanneling()) and (not IsStunned()) then
			CastSpellByName("Blood Fury", GetLocalPlayer());
			return true;
		end
	end

return false;
end

function Canabalize()

	if (HasSpell("Canablize")) and (not IsSpellOnCD("Canabalize")) and (not GetLocalPlayer():HasBuff("Canablize")) then
		if (not IsCasting()) and (not IsChanneling()) and (not IsStunned()) then
			CastSpellByName("Canablize");
			return true;
		end
	end

return false;
end