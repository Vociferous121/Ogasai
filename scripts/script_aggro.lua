script_aggro = {
        currentRessAngle = 0,
	rX = 0,
	rY = 0,
	rZ = 0,
	rTime = 0,
	adjustAggro = 4,	-- adjust blacklist distance range
	tarDist = 0,		-- target distance checked with run away from adds range
	tarX = 0,		-- move away from adds
	tarY = 0,		-- move away from adds
	tarZ = 0,		-- move away from adds
}


-- function to draw aggro circles on screen around targets
function script_aggro:DrawCircles(pointX,pointY,pointZ,radius)
	-- thx benjamin
	local r = 255;
	local g = 255;
	local b = 0;
	-- position
	local x = 25;

	-- we will go by radians, not degrees
	local sqrt, sin, cos, PI, theta, points, point = math.sqrt, math.sin, math.cos,math.pi, 0, {}, 0;
	while theta <= 2*PI do
		point = point + 1 -- get next table slot, starts at 0 
		points[point] = { x = pointX + radius*cos(theta), y = pointY + radius*sin(theta) }
		theta = theta + 2*PI / 50 -- get next theta
	end
	for i = 1, point do
		local firstPoint = i
		local secondPoint = i + 1
		if firstPoint == point then
			secondPoint = 1
		end
		if points[firstPoint] and points[secondPoint] then
			local x1, y1, onScreen1 = WorldToScreen(points[firstPoint].x, points[firstPoint].y, pointZ)
			
			local x2, y2, onScreen2 = WorldToScreen(points[secondPoint].x, points[secondPoint].y, pointZ)
			-- make boolean string so i can post it to console
			onScreen1String = tostring(onScreen1);
			
			--ToConsole('x1 inside draw cirlces: ' .. x1 .. 'onScreen1: ' .. onScreen1String .. y1 .. x2 .. y2 .. redVar .. greenVar .. blueVar .. lineThickness);
			if onScreen1 == true and onScreen2 == true then
				DrawLine(x1, y1, x2, y2, r, g, b, 1)
				
			end
		end
	end
end

-- check for aggro range around other targets based on current level
function script_aggro:safePull(target) 
	local localObj = GetLocalPlayer();
	local countUnitsInRange = 0;
	local currentObj, typeObj = GetFirstObject();
	local aggro = 0;
	local cx, cy, cz = 0, 0, 0;
	local tx, ty, tz = target:GetPosition();

	while currentObj ~= 0 do
 		if (typeObj == 3) and (currentObj:GetGUID() ~= target:GetGUID()) then
			aggro = currentObj:GetLevel() - localObj:GetLevel() + (script_aggro.adjustAggro + 21);
			cx, cy, cz = currentObj:GetPosition();
			if (currentObj:CanAttack()) and (not currentObj:IsDead()) and (not currentObj:IsCritter()) and (GetDistance3D(tx, ty, tz, cx, cy, cz) <= aggro) then	
				countUnitsInRange = countUnitsInRange + 1;
 			end
 		end
 		currentObj, typeObj = GetNextObject(currentObj);
 	end

	-- avoid pull if more than 1 add
	if (countUnitsInRange > 1) then
		return false;
	end

	return true;
end


-- used to recheck a blacklisted target and their range - attack target if they moved far enough away
function script_aggro:safePullRecheck(target) 
	local localObj = GetLocalPlayer();
	local countUnitsInRange = 0;
	local currentObj, typeObj = GetFirstObject();
	local aggro = 0;
	local tx, ty, tz = target:GetPosition();
	local cx, cy, cz = 0, 0, 0;
	local curDist = 0;
	local tarDist = target:GetDistance();

	while currentObj ~= 0 do
 		if (typeObj == 3) and (currentObj:GetGUID() ~= target:GetGUID()) then
			aggro = currentObj:GetLevel() - localObj:GetLevel() + (script_aggro.adjustAggro + script_checkAdds.addsRange);
			cx, cy, cz = currentObj:GetPosition();
			local curDist = currentObj:GetDistance();
			local tarDist = target:GetDistance();

			
			if (currentObj:CanAttack()) and (not currentObj:IsDead()) and (not currentObj:IsCritter()) 			and ( (GetDistance3D(tx, ty, tz, cx, cy, cz) <= aggro)  
			    ) then	
				countUnitsInRange = countUnitsInRange + 1;
 			end
 		end
 		currentObj, typeObj = GetNextObject(currentObj);
 	end

	-- avoid pull if more than 1 add
	if (countUnitsInRange > 1) then
		return false;
	end

	return true;
end

-- find a safe spot to ressurect
function script_aggro:safeRess(corpseX, corpseY, corpseZ, ressRadius) 
	local countUnitsInRange = 0;
	local currentObj, typeObj = GetFirstObject();
	local localObj = GetLocalPlayer();
	local closestEnemy = 0;
	local closestDist = 999;
	local aggro = 0;
	local aggroClosest = 0;

	while currentObj ~= 0 do
 		if typeObj == 3 then
			aggro = currentObj:GetLevel() - localObj:GetLevel() + 21;
			local range = aggro + 5;
			if currentObj:CanAttack() and not currentObj:IsDead() and not currentObj:IsCritter() and currentObj:GetDistance() <= range then	
				if (closestEnemy == 0) then
					closestEnemy = currentObj;
					aggroClosest = currentObj:GetLevel() - localObj:GetLevel() + 21;
				else
					local dist = currentObj:GetDistance();
					if (dist < closestDist) then
						closestDist = dist;
						closestEnemy = currentObj;
					end
				end
 			end
 		end
 		currentObj, typeObj = GetNextObject(currentObj);
 	end

	-- avoid the closest mob
	if (closestEnemy ~= 0) then

			self.currentRessAngle = self.currentRessAngle + 0.05;
			rX, rY, rZ = corpseX+ressRadius*math.cos(self.currentRessAngle), corpseY+ressRadius*math.sin(self.currentRessAngle), corpseZ;
			rTime = GetTimeEX();
			Move (rX, rY, rZ);			

			return true;
	end

	return false;
end

-- if we are close to blacklisted target true or false
function script_aggro:closeToBlacklistedTargets() 
	local countUnitsInRange = 0;
	local currentTargetNr = 0;
	local currentObj = GetGUIDObject(script_grind.blacklistedTargets[currentTargetNr]);
	local localObj = GetLocalPlayer();
	local closestEnemy = 0;
	local closestDist = 999;
	local aggro = 0;
	local aggroClosest = 0;

	while currentObj ~= 0 do
		aggro = currentObj:GetLevel() - localObj:GetLevel() + 26;
		local range = aggro + 5;
		if currentObj:CanAttack() and not currentObj:IsDead() and not currentObj:IsCritter() and currentObj:GetDistance() <= range and not script_grind:isTargetingMe(currentObj) then	
			if (closestEnemy == 0) then
				closestEnemy = currentObj;
				aggroClosest = currentObj:GetLevel() - localObj:GetLevel() + 23;
			else
				local dist = currentObj:GetDistance();
				if (dist < closestDist) then
					closestDist = dist;
					closestEnemy = currentObj;
				end
			end
 		end
		currentTargetNr = currentTargetNr + 1;
 		currentObj = GetGUIDObject(script_grind.blacklistedTargets[currentTargetNr]);
 	end

	-- avoid the closest mob
	if (closestEnemy ~= 0) then
		return true;
	end

	return false;
end

function script_aggro:closeToBlacklistedTargetsEnemyValid() 
	local countUnitsInRange = 0;
	local currentTargetNr = 0;
	local currentObj = GetGUIDObject(script_grind.blacklistedTargets[currentTargetNr]);
	local localObj = GetLocalPlayer();
	local closestEnemy = 0;
	local closestDist = 999;
	local aggro = 0;
	local aggroClosest = 0;

	while currentObj ~= 0 do
		aggro = currentObj:GetLevel() - localObj:GetLevel() + 26;
		local range = aggro + 5;
		if currentObj:CanAttack() and not currentObj:IsDead() and not currentObj:IsCritter() and currentObj:GetDistance() <= range and not script_grind:isTargetingMe(currentObj) and (GetLocalPlayer():GetUnitsTarget() ~= 0 and GetLocalPlayer():GetUnitsTarget():GetGUID() ~= currentObj:GetGUID()) then	
			if (closestEnemy == 0) then
				closestEnemy = currentObj;
				aggroClosest = currentObj:GetLevel() - localObj:GetLevel() + 23;
			else
				local dist = currentObj:GetDistance();
				if (dist < closestDist) then
					closestDist = dist;
					closestEnemy = currentObj;
				end
			end
 		end
		currentTargetNr = currentTargetNr + 1;
 		currentObj = GetGUIDObject(script_grind.blacklistedTargets[currentTargetNr]);
 	end

	-- avoid the closest mob
	if (closestEnemy ~= 0) then
		return true;
	end

	return false;
end

-- avoid aggro 
function script_aggro:avoid(pointX,pointY,pointZ, radius, safeDist)
	-- thx benjamin
	local r = 255;
	local g = 255;
	local b = 0;
	-- position
	local x = 25;

	-- we will go by radians, not degrees
	local sqrt, sin, cos, PI, theta, points, pointsTwo, point = math.sqrt, math.sin, math.cos,math.pi, 0, {}, {}, 0;
	
	local closestDist = 999;
	local closestPoint = 0;
	local closestTargetPoint = 0;
	local closestTargetDist = 999;
	local quality = 120;

	while theta <= 2*PI do
		point = point + 1 -- get next table slot, starts at 0 
		points[point] = { x = pointX + radius*cos(theta), y = pointY + radius*sin(theta) }
		pointsTwo[point] = { x = pointX + (safeDist+radius)*cos(theta), y = pointY + (safeDist+radius)*sin(theta) }
		theta = theta + 2*PI / quality -- get next theta
	end
	
	local closestPointToDest = nil;
	local bestDestDist = 10000;

	for i = 1, point do
		local firstPoint = i
		local secondPoint = i + 1

		if firstPoint == point then
			secondPoint = 1
		end

		if points[firstPoint] and points[secondPoint] then

			local myX, myY, myZ = GetLocalPlayer():GetPosition();

			local dist = math.sqrt((points[secondPoint].x-myX)^2 + (points[secondPoint].y-myY)^2);

			-- Set closest theta point to move to
			if (dist < closestDist) then
				closestDist = dist;
				closestPoint = i;
			end

			-- Calculate the point closest to our destination
			if (IsPathLoaded(5)) then
				local lastNodeIndex = GetPathSize(5);
				local destX, destY, destZ = GetPathPositionAtIndex(5, lastNodeIndex); 
				local destDist = math.sqrt((points[secondPoint].x-destX)^2 + (points[secondPoint].y-destY)^2);
				if (destDist < bestDestDist) then
					bestDestDist = destDist;
					closestPointToDest = i;
				end
			end
		end
	end


	-- Move just outside the aggro range
	local moveToPoint = closestPoint;

	if (closestPointToDest ~= nil) then	
		local diffPoint = closestPointToDest - moveToPoint;
		if (diffPoint <= 0) then
			moveToPoint = closestPoint - 4;
		else
			moveToPoint = closestPoint + 4;
		end
	else
		moveToPoint = closestPoint + 4;
	end
	
	-- out of bound
	if (moveToPoint > point or moveToPoint == 0) then
		moveToPoint = 1;
	end

	Move(pointsTwo[moveToPoint].x, pointsTwo[moveToPoint].y, pointZ);
end


-- draw the actual aggro circles on the screen based on target and range
function script_aggro:drawAggroCircles(maxRange)
	local countUnitsInRange = 0;
	local currentObj, typeObj = GetFirstObject();
	local localObj = GetLocalPlayer();
	local closestEnemy = 0;

	while currentObj ~= 0 do
 		if typeObj == 3 and currentObj:GetDistance() < maxRange and not currentObj:IsDead() and currentObj:CanAttack() and not currentObj:IsCritter() then
			local aggro = currentObj:GetLevel() - localObj:GetLevel() + 21.5;
			local cx, cy, cz = currentObj:GetPosition();
			local px, py, pz = localObj:GetPosition();
			script_aggro:DrawCircles(cx, cy, cz, aggro);
 		end
 		currentObj, typeObj = GetNextObject(currentObj);
 	end
end