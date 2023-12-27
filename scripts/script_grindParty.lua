script_grindParty = {

	forceTarget = false,
	waitForGroup = false,	--wait for group mana / health
	waitForMemberDistance = false,	-- wait for group distance
	healGroup = true,
	partyHealsLoaded = include("scripts\\follow\\script_followHealsAndBuffs.lua"),


}

function script_grindParty:partyOptions()
	
	local groupMana = 0;
	local manaUsers = 0;
	local member = 0;
	local memberDistance = 0;

	for i = 1, GetNumPartyMembers() do

		if (GetNumPartyMembers() > 0) then
			member = GetPartyMember(i);
			memberHealth = member:GetHealthPercentage();
			SmemberDistance = member:GetDistance();
		end	
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
	
		if (self.waitForGroup) and (script_grind:getTargetAttackingUs() == nil) and (not IsInCombat()) then
			if (member:HasBuff("Drink") and memberMana < 90) or (member:HasBuff("Eat") and memberHealth < 90) then
				if (member:GetDistance() < 10) then
					local x, y, z = member:GetDistance();
					if (script_navEX:moveToTarget(localObj, x, y, z)) then
						return true;
					end
				end
				
				script_grind.message = 'Waiting for group to regen mana (25%+)...';
				ClearTarget();
			return true;
			end
		end

		if (self.waitForMemberDistance) and (memberDistance > 100) and (not IsInCombat()) and (not script_grindParty:isAttackingGroup()) then

			if (IsMoving()) then
				StopMoving();
			end

			script_grind.message = 'Waiting for group members...';
			ClearTarget();
			return true;
		end

		if (self.healGroup) then
			if (member:GetDistance() <= 40) then
				if (script_followHealsAndBuffs:healAndBuff()) then
					return true;
				end
			end
		end
	end -- end for loop

return false;
end

function script_grindParty:isAttackingGroup()

	local members = 0;
	local i, typeObj = GetFirstObject();
	local unitsInRange = 0;

	for p = 1, GetNumPartyMembers() do
		members = GetPartyMember(p);
	end
	
	while i ~= 0 do
		if (typeObj == 3) and (i:GetDistance() < 60) then
			if (i:GetUnitsTarget():GetGUID() == members:GetGUID()) then
				return true;
			end
		end
	i, typeObj = GetNextObject(i);
	end
return false;
end
