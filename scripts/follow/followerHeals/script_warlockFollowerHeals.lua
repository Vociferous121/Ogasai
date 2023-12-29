script_warlockFollowerHeals = {
	
	timer = GetTimeEX(),
	waitTimer = GetTimeEX(),

}

function script_warlockFollowerHeals:HealsAndBuffs()

	local localMana = GetLocalPlayer():GetManaPercentage();
	local localHealth = GetLocalPlayer():GetHealthPercentage();

	if (not IsStanding()) then 
		StopMoving();
	end

	-- Wait out the wait-timer and/or casting or channeling
	if (waitTimer > GetTimeEX() or IsCasting() or IsChanneling()) then
		return;
	end

	-- set tick rate for scripts
	if (GetTimeEX() > timer) then
		timer = GetTimeEX() + script_follow.tickRate;

   		for i = 1, GetNumPartyMembers() do

			local partyMember = GetPartyMember(i);

			if (GetNumPartyMembers() > 0) then
				local partyMemberHP = partyMember:GetHealthPercentage();
				local partyMemberDistance = partyMember:GetDistance();
				leaderObj = GetPartyLeaderObject();

				-- Move in line of sight and in range of the party member
				if (partyMember:GetDistance() > 40) or (not partyMember:IsInLineOfSight()) then
					if (script_follow:moveInLineOfSight(partyMember)) then
						return true;
					end
				end
	
				if (HasSpell("Unending Breath")) and (script_warlock.useUnendingBreath) and (not partyMember:HasBuff("Unending Breath")) then
					CastSpellByName("Unending Breath", partyMember);
					return true;
				end
			end
		end
	end
end