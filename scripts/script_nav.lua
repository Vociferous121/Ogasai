script_nav = {
	includeNavEX= include("scripts\\script_navEX.lua"),
	useNavMesh = true,
	nextNavNodeDistance = 1.5, -- for mobs and loot
	nextPathNodeDistance = 2.6, -- for walking paths
	lastPathIndex = 0,
	navPosition = {},
	navPathPosition = {},
	lastnavIndex = 0,
	lastpathnavIndex = 0,
	navPath = nil,
	savedLocations = {},
	numSavedLocation = 0,
	currentGoToLocation = 0,
	currentHotSpotX = 0,
	currentHotSpotY = 0,
	currentHotSpotZ = 0,
	currentHotSpotName = 0,
	hotSpotDist = 0,
	drawNav = true,
}

function script_nav:setup()

end

function script_nav:drawPullRange(range)
	local localObj = GetLocalPlayer();
end

function script_nav:resetPath()
	self.lastnavIndex = 0;
	self.navPosition['x'], self.navPosition['y'], self.navPosition['z'] = 0, 0, 0;
	local x, y, z = GetLocalPlayer():GetPosition();
	GeneratePath(x, y, z, x+1, y+1, z);
end

function script_nav:loadHotspotDB(id)
	local hotspot = hotspotDB:getHotSpotByID(id)

	if (hotspot ~= nil and hotspot ~= -1) then
		if (self.currentHotSpotName ~= hotspot['name']) then
			script_grind.hotspotReached = false;
			self.savedLocations = {};
			self.numSavedLocation = 0;
			self.currentGoToLocation = 0;
		end
		self.currentHotSpotX , self.currentHotSpotY, self.currentHotSpotZ, self.currentHotSpotName =
			hotspot['pos']['x'], hotspot['pos']['y'], hotspot['pos']['z'], hotspot['name'];
			
			return true;
	end

	return false;
end

function script_nav:updateHotSpot(currentLevel, factionNr, useStaticHotSpot)
	
	if (useStaticHotSpot) then 
		local race, level = UnitRace("player"), GetLocalPlayer():GetLevel();
		local id = hotspotDB:getHotspotID(race, level);

		if (script_nav:loadHotspotDB(id)) then 
			return true; 
		end
	end

	-- If there is no static hotspot and no hotspot loaded: Use our current position as a hot spot
	if (self.currentHotSpotName == 0) then
		local localObj = GetLocalPlayer();
		local x, y, z = localObj:GetPosition();
		self.currentHotSpotX , self.currentHotSpotY, self.currentHotSpotZ, self.currentHotSpotName =
		x, y, z, 'Change in path options';
		return true;
	end
end

function script_nav:newHotspot(name)
	local localObj = GetLocalPlayer();
	local x, y, z = localObj:GetPosition();
	self.currentHotSpotX , self.currentHotSpotY, self.currentHotSpotZ, self.currentHotSpotName =
	x, y, z, name;
end

function script_nav:getHotSpotName()
	return self.currentHotSpotName;
end

function script_nav:setHotSpotDistance(dist)
	self.hotSpotDist = dist;
end

function script_nav:isHotSpotLoaded()
	if (self.currentHotSpotName == 0) then return false; end
	return true;
end

function script_nav:getDistanceToHotspot()
	local localObj = GetLocalPlayer();
	local _lx, _ly, _lz = localObj:GetPosition();

	if (self.currentHotSpotName ~= '') and (not script_grind.hotspotReached) then
		return math.sqrt((self.currentHotSpotX-_lx)^2+(self.currentHotSpotY-_ly)^2);
	else
		return 0; -- no hot spot loaded
	end
end

function script_nav:moveToHotspot(localObj)
	if (self.currentHotSpotName ~= 0) and (not script_checkDebuffs:hasDisabledMovement()) then
		script_grind.tickRate = 135;

		script_navEX:moveToTarget(localObj, self.currentHotSpotX, self.currentHotSpotY, self.currentHotSpotZ); 

			if (not IsMounted() and not script_grind.useMount) and (HasSpell("Stealth") or HasSpell("Cat Form") or HasSpell("Travel Form") or HasSpell("Ghost Wolf")) then
				CastStealth();
				CastGhostWolf();
			end

			return "Moving to hotspot " .. self.currentHotSpotName .. '...';
	else
		return "No hotspot has been loaded...";
	end
end

function script_nav:saveTargetLocation(target, mobLevel)
	local _tx, _ty, _tz = target:GetPosition();

	-- Check: Don't save if we are outside the hotspot distance
	if (script_nav:getDistanceToHotspot() > self.hotSpotDist) then return; end

	-- Check: Don't save if we already saved a location within 60 yd
	local saveLocation = true;
	if (self.numSavedLocation > 0) then
		for i = 0,self.numSavedLocation-1 do
			local dist = math.sqrt((_tx-self.savedLocations[i]['x'])^2+(_ty-self.savedLocations[i]['y'])^2);
			if (dist < 40) then
				saveLocation = false;
			end
		end
	end
	
	if (saveLocation) then
		self.savedLocations[self.numSavedLocation] = {};
		self.savedLocations[self.numSavedLocation]['x'] = _tx;
		self.savedLocations[self.numSavedLocation]['y'] = _ty;
		self.savedLocations[self.numSavedLocation]['z'] = _tz;
		self.savedLocations[self.numSavedLocation]['level'] = mobLevel;
		self.numSavedLocation = self.numSavedLocation + 1;
	end
end

function script_nav:moveToSavedLocation(localObj, minLevel, maxLevel, useStaticHotSpot)
	-- Check: Load/update the hotspot
	if (self.currentHotSpotName ~= 0) then
		script_nav:updateHotSpot(localObj:GetLevel(), GetFaction(), useStaticHotSpot); 
	end
	
	-- Let's get at least 2 path nodes around the hot spot before we navigate through them
	if (self.numSavedLocation < 2) then
		return script_nav:moveToHotspot(localObj);
	end

	-- Check: If we reached the last location index
	if (self.currentGoToLocation > (self.numSavedLocation - 1)) then
		self.currentGoToLocation = 0;
	end
	
	-- Check: Move to the next location index
	local _lx, _ly, _lz = localObj:GetPosition();
	local currentDist = math.sqrt((_lx-self.savedLocations[self.currentGoToLocation]['x'])^2+(_ly-self.savedLocations[self.currentGoToLocation]['y'])^2);
	if (currentDist < 5 
		or self.savedLocations[self.currentGoToLocation]['level'] < minLevel
		or self.savedLocations[self.currentGoToLocation]['level'] > maxLevel) then
		self.currentGoToLocation = self.currentGoToLocation + 1;
		return "Changing go to location...";
	end

	script_grind.tickRate = 135;

	script_navEX:moveToTarget(localObj, self.savedLocations[self.currentGoToLocation]['x'], self.savedLocations[self.currentGoToLocation]['y'], self.savedLocations[self.currentGoToLocation]['z']);
	
	return "Moving to auto path node: " .. self.currentGoToLocation+1 .. "...";
end

function script_nav:setNextToNodeDist(distance)
	self.nextNavNodeDistance = distance;
	self.nextPathNodeDistance = distance;
end

function script_nav:getLootTarget(lootRadius)
	local targetObj, targetType = GetFirstObject();
	local bestDist = lootRadius;
	local bestTarget = nil;
	while targetObj ~= 0 do
		if (targetType == 3) then -- Unit
			if(targetObj:IsDead()) then
				if (targetObj:IsLootable()) then
					local dist = targetObj:GetDistance();
					if(dist < lootRadius and bestDist > dist) then
					local _x, _y, _z = targetObj:GetPosition();
						if(not IsNodeBlacklisted(_x, _y, _z, self.nextNavNodeDistance)) then
							bestDist = dist;
							bestTarget = targetObj;
						end
					end
				end
			end
		end
		targetObj, targetType = GetNextObject(targetObj);
	end

	return bestTarget;
end


function script_nav:moveToNav(localObj, _x, _y, _z)

	-- Please load and enable the nav mesh
	if (not IsUsingNavmesh() and self.useNavMesh) then
		return "Please load and and enable the nav mesh...";
	end
	
	self.drawNav = true;

	-- Fetch our current position
	local _lx, _ly, _lz = localObj:GetPosition();

	local _ix, _iy, _iz = GetPathPositionAtIndex(5, self.lastpathnavIndex);
			
	-- If we have a new destination, generate a new path to it
	if (not script_grind.gather) or (localObj:IsDead()) then
		if(self.navPathPosition['x'] ~= _x or self.navPathPosition['y'] ~= _y or self.navPathPosition['z'] ~= _z
		or GetDistance3D(_lx, _ly, _lz, _ix, _iy, _iz) > 25) then
		self.navPathPosition['x'] = _x;
		self.navPathPosition['y'] = _y;
		self.navPathPosition['z'] = _z;
		GeneratePath(_lx, _ly, _lz, _x, _y, _z);
		self.lastpathnavIndex = 1; 
		end
		
	elseif (script_grind.gather) and (not localObj:IsDead()) and (self.navPathPosition['x'] ~= _x) or (self.navPathPosition['y'] ~= _y) or (self.navPathPosition['z'] ~= _z)
		or (GetDistance3D(_lx, _ly, _lz, _ix, _iy, _iz) > 25) then
		self.navPathPosition['x'] = _x;
		self.navPathPosition['y'] = _y;
		self.navPathPosition['z'] = _z;
		GeneratePath(_lx, _ly, _lz, _x, _y, _z);
		self.lastpathnavIndex = -1; 
	end

	if (not script_grind.adjustTickRate) then
		script_grind.tickRate = 0;
	end	

	if (not IsPathLoaded(5)) then
		return "Generating path...";
	end
	
	-- Get the current path node's coordinates
	_ix, _iy, _iz = GetPathPositionAtIndex(5, self.lastpathnavIndex);

	-- When dead use 2D distance
	if (localObj:IsDead()) then
		if (math.sqrt((_lx - _ix)^2 + (_ly - _iy)^2) < self.nextNavNodeDistance) then
			self.lastpathnavIndex = self.lastpathnavIndex + 1;	
			if (GetPathSize(5) <= self.lastpathnavIndex + 1) then
				self.lastpathnavIndex = GetPathSize(5);
			end
		end
	else
		-- If we are close to the next path node, increase our nav node index
		if(GetDistance3D(_lx, _ly, _lz, _ix, _iy, _iz) < self.nextNavNodeDistance) then
			self.lastpathnavIndex = self.lastpathnavIndex + 1;	
			if (GetPathSize(5) <= self.lastpathnavIndex) then
				self.lastpathnavIndex = GetPathSize(5) - 1;
			end
		end
	end

	-- Check: If the move to coords are too far away, something wrong don't use those
	if (GetDistance3D(_lx, _ly, _lz, _ix, _iy, _iz) > 45) then
		return "Moving to target...";
	end

	-- Move to the next destination in the path
	Move(_ix, _iy, _iz);

	return "Navigating to location...";
end

function script_nav:resetNavPos() -- navPosition used for moveToTarget
	self.navPosition['x'] = 0;
	self.navPosition['y'] = 0;
	self.navPosition['z'] = 0;
end

function script_nav:resetNavigate() -- navPathPosition used for navigate
	self.navPathPosition['x'] = 0;
	self.navPathPosition['y'] = 0;
	self.navPathPosition['z'] = 0;
	self.lastPathIndex = 0;
end

function script_nav:findClosestPathNode(localObj, currentIndex, pathType, maxHeightLevel)
	local _bestDist = 9999;
	local pathSize = GetPathSize(pathType);	
	local bestIndex = 0; 

	if (pathSize-1 > currentIndex+1) then
		for index = currentIndex+1, pathSize - 1 do
			local _x, _y, _z = GetPathPositionAtIndex(pathType, index);
			local _lx, _ly, _lz = localObj:GetPosition();				
			for heightLevel = 0, maxHeightLevel do
				local isVis, _hx, _hy, _hz = Raycast(_x, _y, _z + heightLevel, _lx, _ly, _lz + heightLevel);			
				if(GetDistance3D(_x, _y, _z, _lx, _ly, _lz) < _bestDist) then
					_bestDist = GetDistance3D(_x, _y, _z, _lx, _ly, _lz);
					bestIndex = index;
				end
			end
		end
	else
		return pathSize -1;
	end
	return bestIndex;
end

function script_nav:navigate(localObj)
	-- Please load the nav mesh
	if (not IsUsingNavmesh() and self.useNavMesh) then
		return "Please load the nav mesh...";
	end
	
	if(IsPathLoaded(0)) then
		local pathSize = GetPathSize(0); -- walkPath = 0
		local _lx, _ly, _lz = localObj:GetPosition();

		-- At start get the closest walk path node
		if(self.lastPathIndex == -1) then
			self.lastPathIndex = script_nav:findClosestPathNode(localObj, -1, 0, 5);
		end

		local _x, _y, _z = GetPathPositionAtIndex(0, self.lastPathIndex);

		-- Check: If we are close to the next node in the walking path, hop to the next one		
		if(GetDistance3D(_x, _y, _z, _lx, _ly, _lz) < self.nextPathNodeDistance) then
			self.lastPathIndex = self.lastPathIndex + 1;
		end
			
		-- Check: If we reached the end node, start over at node 1
		if(self.lastPathIndex >= pathSize) then
			self.lastPathIndex = -1;
		end
			
		script_nav:moveToNav(localObj, _x, _y, _z);
		
		return "Navigating to path index: " .. self.lastPathIndex;
	else
		-- Please load a path...
		return "No walk path has been loaded...";
	end
end
