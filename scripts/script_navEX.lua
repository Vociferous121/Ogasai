script_navEX = {

}

function script_navEX:moveToTarget(localObj, _x, _y, _z) -- use when moving to moving targets

	-- Please load and enable the nav mesh
	if (not IsUsingNavmesh() and script_nav.useNavMesh) then
		return "Please load and and enable the nav mesh...";
	end

	script_nav.drawNav = false;

	-- Fetch our current position
	localObj = GetLocalPlayer();
	local _lx, _ly, _lz = localObj:GetPosition();

	local _ix, _iy, _iz = GetPathPositionAtIndex(5, script_nav.lastnavIndex);	

	-- If the target moves more than 2 yard then make a new path
	if(GetDistance3D(_x, _y, _z, script_nav.navPosition['x'], script_nav.navPosition['y'], script_nav.navPosition['z']) > 2
		or GetDistance3D(_lx, _ly, _lz, _ix, _iy, _iz) > 25) then
		script_nav.navPosition['x'] = _x;
		script_nav.navPosition['y'] = _y;
		script_nav.navPosition['z'] = _z;
		GeneratePath(_lx, _ly, _lz, _x, _y, _z);
		script_nav.lastnavIndex = 1; -- start at index 1, index 0 is our position
		script_grind:setWaitTimer(135);
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
			script_nav.lastnavIndex = GetPathSize(5);
		end
	end

	-- Check: If move to coords are too far away, something wrong, dont move... BUT WHY ?!
	if (GetDistance3D(_lx, _ly, _lz, _ix, _iy, _iz) > 25) then
		GeneratePath(_lx, _ly, _lz, _lx, _ly, _lz);
		return "Generating a new path...";
	end

	-- Move to the next destination in the path
	Move(_ix, _iy, _iz);

	return "Moving to target...";
end