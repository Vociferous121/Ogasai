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