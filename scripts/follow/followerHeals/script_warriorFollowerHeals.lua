script_warriorFollowerHeals = {

	timer = GetTimeEX(),
	waitTimer = GetTimeEX(),

}

function script_warriorFollowerHeals:HealsAndBuffs()

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
				local localHealth = GetLocalPlayer():GetHealthPercentage();
				leaderObj = GetPartyLeaderObject();
				local partyMemberDistance = partyMember:GetDistance();
			
				-- Move in line of sight and in range of the party member
				if (partyMember:GetDistance() > 40) or (not partyMember:IsInLineOfSight()) then
					if (script_follow:moveInLineOfSight(partyMember)) then
						return true; 
					end
				end
			end
		end
	end
end