script_followMoveToMember = {

}

function script_followMoveToMember:moveInLineOfSight(partyMember)

	leaderObj = GetPartyMember(GetPartyLeaderIndex());

	for i = 1, GetNumPartyMembers()+1 do

			local partyMember = GetPartyMember(i);

		if (i == GetNumPartyMembers()+1) then
			partyMember = GetLocalPlayer();
		end
	end

	if (not self.followMember) and (GetNumPartyMembers() > 1) then
		if (not leaderObj:IsInLineOfSight() or leaderObj:GetDistance() > self.followLeaderDistance) then
			local x, y, z = leaderObj:GetPosition();
			script_navEX:moveToTarget(GetLocalPlayer(), x , y, z);
			self.timer = GetTimeEX() + 200;
           		self.message = "Moving to Party Leader LoS";
			return true;
		end
	end

	if (self.followMember) then
		if (not partyMember:IsInLineOfSight() and partyMember:GetDistance() < self.followLeaderDistance) then
			local x, y, z = partyMember:GetPosition();
			script_navEX:moveToTarget(GetLocalPlayer(), x , y, z);
			self.timer = GetTimeEX() + 200;
			self.message = "Moving to party member LoS";
			return true;
		end
	end
return false;
end