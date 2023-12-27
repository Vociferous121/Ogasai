script_aggro = {
        currentRessAngle = 0,	-- res angle
	rX = 0,			-- res position
	rY = 0,			-- res position
	rZ = 0,			-- res position
	rTime = 0,		-- res time
	adjustAggro = 3,	-- adjust blacklist distance range
	tarDist = 0,		-- target distance checked with run away from adds range
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

	-- draw points
	for i = 1, point do
		local firstPoint = i
		local secondPoint = i + 1

		-- do next point
		if firstPoint == point then
			secondPoint = 1
		end

		-- draw points
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

	-- run object manager
	while currentObj ~= 0 do
	
		-- NPC type 3
 		if (typeObj == 3)  then

			-- target aggro based on level
			aggro = currentObj:GetLevel() - localObj:GetLevel() + (script_aggro.adjustAggro + 19.5);

			-- acceptable targets
			if (currentObj:CanAttack()) and (not currentObj:IsDead()) and (not currentObj:IsCritter()) then

				-- currentObj position
				cx, cy, cz = currentObj:GetPosition();

				-- acceptable range
				if (GetDistance3D(tx, ty, tz, cx, cy, cz) <= aggro) then	

					-- accpetable targets in range
					countUnitsInRange = countUnitsInRange + 1;
				end
 			end
 		end

		-- get next target
 		currentObj, typeObj = GetNextObject(currentObj);
 	end

	-- avoid pull if more than 1 add
	if (countUnitsInRange > 1) then
		return false;
	end

return true;
end

-- check for aggro range around other targets based on current level
function script_aggro:enemiesNearMe() 
	local localObj = GetLocalPlayer();
	local countUnitsInRange = 0;
	local currentObj, typeObj = GetFirstObject();
	local aggro = 0;
	local cx, cy, cz = 0, 0, 0;

	-- run object manager
	while currentObj ~= 0 do
		
		-- NPC type 3
 		if (typeObj == 3) then

			-- acceptable targets
			if (not currentObj:GetGUID() == target:GetGUID()) then
				if (currentObj:CanAttack()) and (not currentObj:IsDead())
					and (not currentObj:IsCritter()) then

					-- acceptable target aggro based on level
					aggro = currentObj:GetLevel() - localObj:GetLevel() + (script_aggro.adjustAggro + 19.5);		
					-- acceptable target aggro based on distance
					cx, cy, cz = currentObj:GetPosition();

					-- check distance
					if (GetDistance3D(tx, ty, tz, cx, cy, cz) <= aggro)
					or (currentObj:GetDistance() <= 25) then

						-- acceptable targets in range	
						countUnitsInRange = countUnitsInRange + 1;
					end
 				end
 			end
		end

		-- get next target
 		currentObj, typeObj = GetNextObject(currentObj);
 	end

	-- avoid pull if more than 1 add
	if (countUnitsInRange > 1) then
		return true;
	end

return false;
end


-- used to recheck a blacklisted target and their range - attack target if they moved far enough away
function script_aggro:safePullRecheck(target) 
	local localObj = GetLocalPlayer();
	local countUnitsInRange = 0;
	local currentObj, typeObj = GetFirstObject();
	local aggro = 0;
	local cx, cy, cz = 0, 0, 0;
	local tx, ty, tz = target:GetPosition();

	-- run object manager
	while currentObj ~= 0 do

		-- NPC type 3
 		if (typeObj == 3) then

			-- acceptable targets
			if (currentObj:CanAttack()) and (not currentObj:IsDead()) and (not currentObj:IsCritter()) then	

				-- aggro range is aggro addsRange slider
				aggro = script_checkAdds.addsRange - 5;

				-- currentObj position
				cx, cy, cz = currentObj:GetPosition();

				-- acceptable range
				if (GetDistance3D(tx, ty, tz, cx, cy, cz) <= aggro) then

					-- acceptable targets in range
					countUnitsInRange = countUnitsInRange + 1;
				end
 			end
 		end

		-- get next object
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

	-- run object manager
	while currentObj ~= 0 do

		-- NPC type 3
 		if typeObj == 3 then

			-- acceptable targets
			if currentObj:CanAttack() and not currentObj:IsDead() and not currentObj:IsCritter() then

				-- set safe res distances based on level
				aggro = currentObj:GetLevel() - localObj:GetLevel() + 21;

				-- extra safe range add 5 yards
				local range = aggro + 5;

				-- acceptable range to run avoid during ressurection
				if currentObj:GetDistance() <= range then
		
					-- set closest enemy
					if (closestEnemy == 0) then
						closestEnemy = currentObj;
						aggroClosest = currentObj:GetLevel() - localObj:GetLevel() + 21;
				else
						-- get nearest enemy from closest enemy position
						local dist = currentObj:GetDistance();
						local closestDist = 999

						-- rerun object manager until you find closest target in range
						if (dist < closestDist) then
		
							-- make that enemy the closest target
							closestDist = dist;

							-- closest enemy to avoid
							closestEnemy = currentObj;
						end
					end
				end
 			end
 		end

		-- get next target
 		currentObj, typeObj = GetNextObject(currentObj);
 	end

	-- avoid the closest mob
	if (closestEnemy ~= 0) then

			-- set res angle each return
			self.currentRessAngle = self.currentRessAngle + 0.05;

			-- set position to move each return
			rX, rY, rZ = corpseX+ressRadius*math.cos(self.currentRessAngle), corpseY+ressRadius*math.sin(self.currentRessAngle), corpseZ;

			-- set res time
			rTime = GetTimeEX();

			-- move to point
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

	-- run object manager
	while currentObj ~= 0 do
		
		-- acceptable targets
		if (currentObj:CanAttack())
			and (not currentObj:IsDead())
			and (not currentObj:IsCritter())
			and (not script_grind:isTargetingMe(currentObj))
			and (not currentObj:HasDebuff("Polymorph"))
			and (not currentObj:HasDebuff("Fear"))
			and (currentObj:GetGUID() ~= script_grind.lastAvoidTarget:GetGUID())
		then
			-- set aggro range based on current level
			aggro = currentObj:GetLevel() - localObj:GetLevel() + 23.5;
			local range = aggro;

			-- acceptable range
			if (currentObj:GetDistance() <= range) then
	
				-- set closest enemy from currentObj
				if (closestEnemy == 0) then
					closestEnemy = currentObj;
					aggroClosest = currentObj:GetLevel() - localObj:GetLevel() + 24;
				else
	
					-- get closest enemy to player
					local dist = currentObj:GetDistance();
	
					-- check distance and get any enemy closer
					if (dist < closestDist) then
						closestDist = dist;
						closestEnemy = currentObj;
					end
				end
	 		end
		end

	-- avoid the closest mob
	if (closestEnemy ~= 0) then
		return true;
	end

	-- get next target
	currentTargetNr = currentTargetNr + 1;
 	currentObj = GetGUIDObject(script_grind.blacklistedTargets[currentTargetNr]);
 	end

return false;
end

-- if we are close to blacklisted target true or false
function script_aggro:closeToHardBlacklistedTargets() 
	local countUnitsInRange = 0;
	local currentTargetNr = 0;
	local currentObj = GetGUIDObject(script_grind.hardBlacklistedTargets[currentTargetNr]);
	local localObj = GetLocalPlayer();
	local closestEnemy = 0;
	local closestDist = 999;
	local aggro = 0;
	local aggroClosest = 0;
	local enemy = GetLocalPlayer();

	-- run object manager
	while currentObj ~= 0 do
	
		-- NPC type 3
		if (typeObj == 3) then

			-- acceptable targets
			if (currentObj:CanAttack())
				and (not currentObj:IsDead())
				and (not currentObj:IsCritter())
				and (not script_grind:isTargetingMe(currentObj))
				and (not currentObj:HasDebuff("Polymorph"))
				and (not currentObj:HasDebuff("Fear"))
			then

				-- set range based on current level
				aggro = currentObj:GetLevel() - localObj:GetLevel() + 21;
				local range = aggro + 1;
		
				-- acceptable range
				if (currentObj:GetDistance() <= range) then

					-- set closest enemy	
					if (closestEnemy == 0) then
						closestEnemy = currentObj;
						aggroClosest = currentObj:GetLevel() - localObj:GetLevel() + 22;
					else
			
						-- set closest enemy distance
						local dist = currentObj:GetDistance();

						-- check closest enemy
						if (dist < closestDist) then
							closestDist = dist;
							closestEnemy = currentObj;
						end
					end
				end
			end
 		end

	-- get next target
	currentTargetNr = currentTargetNr + 1;
 	currentObj = GetGUIDObject(script_grind.hardBlacklistedTargets[currentTargetNr]);
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
	local quality = 250;

	-- start move points table of safe distances around targets
	while theta <= 2*PI do
		point = point + 1 -- get next table slot, starts at 0 
		points[point] = { x = pointX + radius*cos(theta), y = pointY + radius*sin(theta) }
		pointsTwo[point] = { x = pointX + (safeDist+radius)*cos(theta), y = pointY + (safeDist+radius)*sin(theta) }
		theta = theta + 2*PI / quality -- get next theta
	end
	
	local closestPointToDest = nil;
	local bestDestDist = 10000;

	-- get points
	for i = 1, point do
		local firstPoint = i
		local secondPoint = i + 1

		-- get next point
		if firstPoint == point then
			secondPoint = 1
		end

		if points[firstPoint] and points[secondPoint] then

			-- my position
			local myX, myY, myZ = GetLocalPlayer():GetPosition();

			-- distance of points
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

				-- get closest target distsance
				if (destDist < bestDestDist) then
					bestDestDist = destDist;
					closestPointToDest = i;
				end
			end
		end
	end


	-- Move just outside the aggro range
	local moveToPoint = closestPoint;

	-- how many points to move at a time
	local setPoint = 2;

	-- set closest point direction to choose
	if (closestPointToDest ~= nil) then	
		local diffPoint = closestPointToDest - moveToPoint;
		if (diffPoint <= 0) then
			moveToPoint = closestPoint - setPoint;
		else
			moveToPoint = closestPoint + setPoint;
		end
	else
		-- need to assign blacklisted target only closest target
		script_grind:assignTarget();
		--moveToPoint = closestPoint + setPoint;
	end
	
	-- out of bound / can't find a movetopoint
	if (moveToPoint > point or moveToPoint == 0) then
		moveToPoint =  - setPoint;
		-- need to assign blacklisted target only closest target
		--script_grind:assignTarget();
	end

	-- make sure we have targets around us and acceptable move to points
	if (moveToPoint ~= 0)
		and (moveToPoint ~= nil)
		and (points[point].x ~= nil)
		and (points[point].y ~= nil)
		and (pointsTwo[moveToPoint] ~= nil)
		and (pointZ ~= nil)
		and (point ~= nil)
		and (points[point] ~= nil)

		then

		-- use unstuck script
		if (self.useUnstuck and IsMoving()) then
			if (not script_unstuck:pathClearAuto(2)) then
				script_unstuck:unstuck();
				return true;
			end
		end

		-- move to avoid points
		if (Move(pointsTwo[moveToPoint].x, pointsTwo[moveToPoint].y, pointZ)) then

			-- reset navigation for next target
			script_nav:resetNavPos();
			script_nav:resetNavigate();
			script_nav:resetPath();
		end
	else
			-- reset navigation for next target
			script_nav:resetNavPos();
			script_nav:resetNavigate();
			script_nav:resetPath();
	end
end


-- draw the actual aggro circles on the screen based on target and range
function script_aggro:drawAggroCircles(maxRange)
	local countUnitsInRange = 0;
	local currentObj, typeObj = GetFirstObject();
	local localObj = GetLocalPlayer();
	local closestEnemy = 0;

	-- run object manager
	while currentObj ~= 0 do
		
		-- acceptable targets
 		if typeObj == 3 and currentObj:GetDistance() < maxRange and not currentObj:IsDead() and currentObj:CanAttack() and not currentObj:IsCritter() then

			-- set conditions
			local aggro = currentObj:GetLevel() - localObj:GetLevel() + 21.5;
			local cx, cy, cz = currentObj:GetPosition();
			local px, py, pz = localObj:GetPosition();
		
			-- run draw circles based on currenyObj
			script_aggro:DrawCircles(cx, cy, cz, aggro);
 		end

		-- get next target
 		currentObj, typeObj = GetNextObject(currentObj);
 	end
end