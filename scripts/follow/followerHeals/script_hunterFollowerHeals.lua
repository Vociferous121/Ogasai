script_hunterFollowerHeals = {

	timer = GetTimeEX(),

}

function script_hunterFollowerHeals:HealsAndBuffs()

	if (not IsStanding()) then 
		StopMoving();
	end

	if(GetTimeEX() > self.timer) then
		self.timer = GetTimeEX() + script_follow.tickRate;

		local localMana = GetLocalPlayer():GetManaPercentage();
		local localHealth = GetLocalPlayer():GetHealthPercentage();
	
	
		for i = 1, GetNumPartyMembers() do
	
			local partyMember = GetPartyMember(i);
	
			if (GetNumPartyMembers() > 0) then
	
				local partyMemberHP = partyMember:GetHealthPercentage();
				local partyMemberDistance = partyMember:GetDistance();
				leaderObj = GetPartyMember(GetPartyLeaderIndex());
				local px, py, pz = GetPartyMember(i):GetPosition();
	
					
				-- some buff here?
				-- return true!
			end
		end
	end
return false;
end