script_followMove = {
	
	navFunctionsLoaded = include("scripts\\script_nav.lua"),
	navFunctions2Loaded = include("scripts\\script_navEX.lua"),
	lastNavIndex = 0,
}

function script_followMove:followLeader()

	local leaderObj = GetPartyLeaderObject();
	local distance = script_follow.followLeaderDistance;
	local localObj = GetLocalPlayer();

	-- Follow our master
	if (not script_follow.skipLooting and script_follow.lootObj == nil) or (script_follow.skipLooting) then

		if (leaderObj ~= 0 and leaderObj ~= nil) then

			local x, y, z = leaderObj:GetPosition();


			if (leaderObj:GetDistance() > distance)
				and (not leaderObj:IsDead())
				and (not localObj:IsDead()) then


				if (not script_follow.test) then
					script_navEX:moveToTarget(localObj, x, y, z);
					script_follow.message = "Following Party Leader...";
					return;
				end

				if script_follow.test then
					Move(x, y, z);
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

			if (not leaderObj:IsInLineOfSight()) or (leaderObj:GetDistance() > distance) then

				script_navEX:moveToTarget(GetLocalPlayer(), x, y, z);
	           		self.message = "Moving to Party Leader LoS";
				return;
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
			
				script_navEX:moveToTarget()(GetLocalPlayer(), x, y, z);
				self.message = "Moving to party member LoS";
				return;
			end
		end
	end
return false;
end