script_grindParty = {

	forceTarget = false,
	waitForGroup = false,

}

function script_grindParty:partyOptions()

	if (self.waitForGroup) then
		if (script_grind:getTargetAttackingUs() == nil) then
			if (GetLocalPlayer():HasBuff('Bloodrage')) then
				script_grind.message = "Waiting for bloodrage to fade...";
				return true;
			end
			
			local groupMana = 0;
			local manaUsers = 0;
			local member = 0;

			for i = 1, GetNumPartyMembers() do
				member = GetPartyMember(i);
				if (member:GetManaPercentage() > 0) then
					groupMana = groupMana + member:GetManaPercentage();
					manaUsers = manaUsers + 1;
				end
			end
			if (member:GetDistance() > 100 and not IsInCombat()) then
				if (IsMoving()) then StopMoving(); end
				script_grind.message = 'Waiting for group members...';
				ClearTarget();
				return true;
			end
			if (groupMana/manaUsers < 25
				or member:HasBuff("Drink")
				or member:HasBuff("Eat"))
				and (GetNumPartyMembers() >= 1) and (not IsInCombat())
			then
				if (IsMoving()) then
					StopMoving();
				end
				script_grind.message = 'Waiting for group to regen mana (25%+)...';
				ClearTarget();
				return true;
			end
		end
	end
return false;
end