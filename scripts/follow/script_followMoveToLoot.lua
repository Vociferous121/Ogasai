script_followMoveToLoot = {

	navFunctionsLoaded = include("scripts\\script_nav.lua"),
	navFunctions2Loaded = include("scripts\\script_navEX.lua"),
	moveTimer = GetTimeEX(),
	used = 0,
}

local localObj = GetLocalPlayer()
function script_followMoveToTarget:moveToLoot(localObj, _x, _y, _z) -- use when moving to moving targets

	script_follow.drawNav = true;

	local localObj = GetLocalPlayer();
	-- Fetch our current position
	local _lx, _ly, _lz = localObj:GetPosition();

	local _ix, _iy, _iz = GetPathPositionAtIndex(5, script_nav.lastnavIndex);	

	-- If the target moves more than 5 yard then make a new path
	if(GetDistance3D(_x, _y, _z, script_nav.navPosition['x'], script_nav.navPosition['y'], script_nav.navPosition['z']) > 5
		or GetDistance3D(_lx, _ly, _lz, _ix, _iy, _iz) > 60) then
		script_nav.navPosition['x'] = _x;
		script_nav.navPosition['y'] = _y;
		script_nav.navPosition['z'] = _z;
		GeneratePath(_lx, _ly, _lz, _x, _y, _z);
		script_nav.lastnavIndex = 1; -- start at index 1, index 0 is our position
		script_follow.message = "trying to find a path...";
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
	if (GetDistance3D(_lx, _ly, _lz, _ix, _iy, _iz) > 50) then
		GeneratePath(_lx, _ly, _lz, _lx, _ly, _lz);
		script_follow.message = "cannot find path...";
		return "Generating a new path...";
	end


	-- Move to the next destination in the path
	Move(_ix, _iy, _iz);
	if (not IsMoving()) and (GetLoadNavmeshProgress() ~= 0) and (GetTimeEX() > self.moveTimer) then
		collectgarbage(script_nav.navPosition['z']);
		collectgarbage(script_nav.navPosition['y']);
		collectgarbage(script_nav.navPosition['x']);
		script_followMoveToTarget.used = script_followMoveToTarget.used + 1;
		self.moveTimer = GetTimeEX() + 1000;
	end
	
	script_follow.message = "moving to loot...";
	return "Moving to loot...";
end