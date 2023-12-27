script_hunterFollowerHeals = {

	timer = GetTimeEX(),

}

function script_hunterFollowerHeals:HealsAndBuffs()

	if (not IsStanding()) then 
		StopMoving();
	end
	if(GetTimeEX() > self.timer) then
		self.timer = GetTimeEX() + script_follow.tickRate;


		for i = 1, GetNumPartyMembers() do

			local partyMember = GetPartyMember(i);

				local localMana = GetLocalPlayer():GetManaPercentage();
				local localEnergy = GetLocalPlayer():GetEnergyPercentage();
				local partyMemberHP = partyMember:GetHealthPercentage();

			if (partyMemberHP > 0) and (localMana > 1 or localEnergy > 1) then
					local partyMemberDistance = partyMember:GetDistance();
					leaderObj = GetPartyMember(GetPartyLeaderIndex());
					local localHealth = GetLocalPlayer():GetHealthPercentage();
			end

			
			-- Move in line of sight and in range of the party member
			if (partyMember:GetDistance() > 40) or (not partyMember:IsInLineOfSight()) then
				if (script_follow:moveInLineOfSight(partyMember)) then
					return true; 
				end
			end
		end
	end
return;
end