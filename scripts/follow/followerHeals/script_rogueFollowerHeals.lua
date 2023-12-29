script_rogueFollowerHeals = {

}

function script_rogueFollowerHeals:HealsAndBuffs()

	local localEnergy = GetLocalPlayer():GetEnergyPercentage();
	local localHealth = GetLocalPlayer():GetHealthPercentage();

    for i = 1, GetNumPartyMembers() do

		local partyMember = GetPartyMember(i);


		if (GetNumPartyMembers() > 0) then
			local partyMemberHP = partyMember:GetHealthPercentage();
			local partyMemberDistance = partyMember:GetDistance();
			leaderObj = GetPartyLeaderObject();
			local px, py, pz = GetPartyMember(i):GetPosition();

			-- some buff here?
			-- return true!
		end
	end
return false;
end