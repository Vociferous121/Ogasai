script_grindParty = {

	forceTarget = false,
	waitForGroup = false,
	waitForMemberDistance = false,

}

function script_grindParty:partyOptions()

	if (self.waitForGroup) then
		if (script_grind:getTargetAttackingUs() == nil) and (not IsInCombat()) then
		
			local groupMana = 0;
			local manaUsers = 0;
			local member = 0;
			local memberDistance = 0;

			for i = 1, GetNumPartyMembers()+1 do

					member = GetPartyMember(i);
					memberHealth = member:GetHealthPercentage();
					memberDistance = member:GetDistance();

				if (member:GetManaPercentage() > 0) then
					groupMana = groupMana + member:GetManaPercentage();
					manaUsers = manaUsers + 1;
					memberMana = member:GetManaPercentage();
				end

				if (member:GetRagePercentage() > 0) then
					memberRage = member:GetRagePercentage();
				end

				if (member:GetEnergyPercentage() > 0) then
					memberEnergy = member:GetEnergyPercentage();
				end

			end
			if (self.waitForMemberDistance) and (memberDistance > 100 and not IsInCombat()) then
				if (IsMoving()) then StopMoving(); end
				script_grind.message = 'Waiting for group members...';
				ClearTarget();
				return true;
			end
			if (memberDistance < 100) and (not IsInCombat()) 
			and ( (groupMana/manaUsers < 25)
			or (member:HasBuff("Drink") and memberMana < 90)
			or (member:HasBuff("Eat") and memberHealth < 90) )
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