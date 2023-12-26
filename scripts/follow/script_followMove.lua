script_followMove = {

}

function script_followMove:move(localObj, _x, _y, _z) -- use when moving to moving targets

	-- Please load and enable the nav mesh
	if (not IsUsingNavmesh() and script_nav.useNavMesh) then
		return "Please load and and enable the nav mesh...";
	end

	-- Fetch our current position
	localObj = GetLocalPlayer();
	local _lx, _ly, _lz = localObj:GetPosition();

	local _ix, _iy, _iz = GetPathPositionAtIndex(5, script_nav.lastnavIndex);	

	local test = script_follow.followLeaderDistance / 3;
	-- If the target moves more than 2 yard then make a new path
	if(GetDistance3D(_x, _y, _z, script_nav.navPosition['x'], script_nav.navPosition['y'], script_nav.navPosition['z']) > test
		or GetDistance3D(_lx, _ly, _lz, _ix, _iy, _iz) > 25) then
		script_nav.navPosition['x'] = _x;
		script_nav.navPosition['y'] = _y;
		script_nav.navPosition['z'] = _z;
		GeneratePath(_lx, _ly, _lz, _x, _y, _z);
		script_nav.lastnavIndex = 1; -- start at index 1, index 0 is our position
		script_follow:setWaitTimer(200);
	end	

	if (not IsPathLoaded(5)) then
		return "Generating path...";
	end

	-- Get the current path node's coordinates
	_ix, _iy, _iz = GetPathPositionAtIndex(5, script_nav.lastnavIndex);

	-- If we are close to the next path node, increase our nav node index
	if(GetDistance3D(_lx, _ly, _lz, _ix, _iy, _iz) < script_nav.nextNavNodeDistance) then
		script_nav.lastnavIndex = 1 + script_nav.lastnavIndex;		
		if (GetPathSize(5) <= script_nav.lastnavIndex) then
			script_nav.lastnavIndex = GetPathSize(5)+1;
		end
	end

	-- Move to the next destination in the path
	Move(_ix, _iy, _iz);

	return "Moving to target...";
end


function script_followMove:followLeader()

-- Follow our master
		if (not script_follow.skipLooting) and (script_follow.lootObj == nil) then
			if (script_follow.lootObj == nil or IsInCombat()) then
				if (script_follow:GetPartyLeaderObject() ~= 0) then
					if(script_follow:GetPartyLeaderObject():GetDistance() > script_follow.followLeaderDistance and not script_follow:GetPartyLeaderObject():IsDead()) and (not localObj:IsDead()) then
						local x, y, z = script_follow:GetPartyLeaderObject():GetPosition();
						if (not script_follow.test) then
							if (script_followMove:move(GetLocalPlayer(), x, y, z)) then
							--if (script_navEX:moveToTarget(GetLocalPlayer(), x, y, z)) then
							--if (script_nav:moveToNav(GetLocalPlayer(), x, y, z)) then
								script_follow.message = "Following Party Leader...";
								script_follow.timer = GetTimeEX() + 500;
							end
						end
						if script_follow.test then
							Move(x, y, z);
							script_follow.timer = GetTimeEX() + 500;
						end
					end
				end
			end
		elseif (script_follow.skipLooting) then
			if (script_follow:GetPartyLeaderObject() ~= 0) then
				if(script_follow:GetPartyLeaderObject():GetDistance() > script_follow.followLeaderDistance and not script_follow:GetPartyLeaderObject():IsDead()) and (not localObj:IsDead()) then
					local x, y, z = script_follow:GetPartyLeaderObject():GetPosition();
					if (not script_follow.test) then
						if (script_followMove:move(GetLocalPlayer(), x, y, z)) then
						--if (script_navEX:moveToTarget(GetLocalPlayer(), x, y, z)) then
						--if (script_nav:moveToNav(GetLocalPlayer(), x, y, z)) then
							script_follow.message = "Following Party Leader...";
							script_follow.timer = GetTimeEX() + 500;
						end
					end
					if script_follow.test then
						Move(x, y, z);
						script_follow.timer = GetTimeEX() + 300;
					end
				end
			end
		end
end

function script_followMove:moveInLineOfSight(partyMember)

	leaderObj = GetPartyMember(GetPartyLeaderIndex());

	for i = 1, GetNumPartyMembers()+1 do

		local partyMember = GetPartyMember(i);

	end

	if (not self.followMember) and (GetNumPartyMembers() > 1) and (not IsCasting()) and (not IsChanneling()) and (not IsEating()) and (not IsDrinking()) then
		if (not leaderObj:IsInLineOfSight() or leaderObj:GetDistance() > self.followLeaderDistance) then
			local x, y, z = leaderObj:GetPosition();
			script_followMove:move(GetLocalPlayer(), x, y, z);
			self.timer = GetTimeEX() + 200;
           		self.message = "Moving to Party Leader LoS";
		end
	end

	if (self.followMember) and (GetNumPartyMembers() > 1) and (not IsCasting()) and (not IsChanneling()) and (not IsEating()) and (not IsDrinking()) then
		if (not partyMember:IsInLineOfSight() and partyMember:GetDistance() < self.followLeaderDistance) then
			local x, y, z = partyMember:GetPosition();
			script_followMove:move(GetLocalPlayer(), x, y, z);
			self.timer = GetTimeEX() + 200;
			self.message = "Moving to party member LoS";
		end
	end
end