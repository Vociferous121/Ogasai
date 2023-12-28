script_followMove = {
	
	navFunctionsLoaded = include("scripts\\script_nav.lua"),
	navFunctions2Loaded = include("scripts\\script_navEX.lua"),
}

function script_followMove:followLeader()

	script_follow.tickRate = 0;

	local leaderObj = GetPartyLeaderObject();
	local distance = script_follow.followLeaderDistance;
	local localObj = GetLocalPlayer();

	if (leaderObj ~= 0 and leaderObj ~= nil) then

		if (leaderObj:GetDistance() > distance)
			and (not leaderObj:IsDead())
			and (not localObj:IsDead())
			and (not IsCasting())
			and (not IsChanneling())
			and (not IsDrinking())
			and (not IsEating())
		then

			local x, y, z = leaderObj:GetPosition();

			if (not script_follow.test) then
				if (script_followMoveToTarget:moveToTarget(localObj, x, y, z)) then
					script_follow.message = "Following Party Leader...";
					return true;
				end
			end

			if script_follow.test then
				if (Move(x, y, z)) then
					return true;
				end
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
					return;
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