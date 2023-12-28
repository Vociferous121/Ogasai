script_followMove = {
	
	navFunctionsLoaded = include("scripts\\script_nav.lua"),
	navFunctions2Loaded = include("scripts\\script_navEX.lua"),
}

function script_followMove:followLeader()

	local leaderObj = GetPartyLeaderObject();
	local distance = script_follow.followLeaderDistance;
	local localObj = GetLocalPlayer();

	if (leaderObj ~= 0 and leaderObj ~= nil) then

		local myX, myY, myZ = localObj:GetPosition();
		local leadX, leadY, leadZ = leaderObj:GetPosition();

		if (leaderObj:GetDistance() >= distance or GetDistance3D(myX, myY, myZ, leadX, leadY, leadZ) >= distance) 
			and (not leaderObj:IsDead())
			and (not localObj:IsDead())
			and (not IsCasting())
			and (not IsChanneling())
			and (not IsDrinking())
			and (not IsEating())
		then

			local leadX, leadY, leadZ = leaderObj:GetPosition();

			if (script_followMoveToTarget:moveToTarget(localObj, leadX, leadY, leadZ)) then
				script_follow.message = "Following Party Leader...";
			end
		end
	end
return false;
end

function script_followMove:moveInLineOfSight(partyMember)
	
	for i = 1, GetNumPartyMembers() do

		local partyMember = GetPartyMember(i);
		leaderObj = GetPartyMember(GetPartyLeaderIndex());
		local localObj = GetLocalPlayer();
		local distance = script_follow.followLeaderDistance;

		if (leaderObj ~= 0) and (not script_follow.followMember)
			and (GetNumPartyMembers() > 0)
			and (not IsCasting())
			and (not IsChanneling())
			and (not IsEating())
			and (not IsDrinking())
			and (not leaderObj:IsDead())
			and (not localObj:IsDead())
		then

				local x, y, z = leaderObj:GetPosition();

			if (not leaderObj:IsInLineOfSight()) then

				if (script_followMoveToTarget:moveToTarget(GetLocalPlayer(), x, y, z)) then
	           			self.message = "Moving to Party Leader LoS";
				end
			end

		elseif (script_follow.followMember)
			and (GetNumPartyMembers() > 0)
			and (not IsCasting())
			and (not IsChanneling())
			and (not IsEating())
			and (not IsDrinking())
			and (not partyMember:IsDead())
			and (not localObj:IsDead())
		then
					local x, y, z = partyMember:GetPosition();

			if (not partyMember:IsInLineOfSight()) and (partyMember:GetDistance() < distance) then
			
				script_followMoveToTarget:moveToTarget(GetLocalPlayer(), x, y, z);
				self.message = "Moving to party member LoS";
				return;
			end
		end
	end
return false;
end