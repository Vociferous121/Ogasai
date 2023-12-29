script_checkAdds = {

	addsRange = 35,	-- range circles from from adds
	checkAddsRange = 5,	-- safe margin move from adds

		-- these are global so we can rerun object manager from om script
	closestEnemy = 0,	-- set closest enemy
	intersectEnemy = nil,	-- set intersect enemy
}

-- requires target from grind script 'enemyObj'
function script_checkAdds:checkAdds()

	-- check if there are adds and avoid those adds. call this to run avoid adds
	if(script_grind:enemiesWithinRange() <= 3) then
		if (script_checkAdds:avoidToAggro(self.checkAddsRange)) then

			-- use unstuck script
			if (not script_unstuck:pathClearAuto(2)) then
				script_unstuck:unstuck();
				return true;
			end

			-- if we have a pet then pet follow
			if (GetPet() ~= 0) then
				PetFollow();
			end

			self.message = "Moving away from adds...";
	
		return;
		end
	end
return false;
end

-- avoid aggro 
function script_checkAdds:avoid(pointX,pointY,pointZ, radius, safeDist)
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

	-- get table of move to points around targets
	while theta <= 2*PI do
		point = point + 1 -- get next table slot, starts at 0 
		points[point] = { x = pointX + radius*cos(theta), y = pointY + radius*sin(theta) }
		pointsTwo[point] = { x = pointX + (self.addsRange+2)*cos(theta), y = pointY + (self.addsRange+2)*sin(theta) }
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

		-- we if have move points then do
		if points[firstPoint] and points[secondPoint] then

			-- my distance
			local myX, myY, myZ = GetLocalPlayer():GetPosition();

			-- target distance based on move to points
			local dist = math.sqrt((points[secondPoint].x-myX)^2 + (points[secondPoint].y-myY)^2);

			-- Set closest theta point to move to
			if (dist < closestDist) then
				closestDist = dist;
				closestPoint = i;
			end

			-- Calculate the point closest to our destination
			if (IsPathLoaded(5)) then
				local lastNodeIndex = GetPathSize(5);
				local destX, destY, destZ = GetPathPositionAtIndex(5, lastNodeIndex+1); 
				local destDist = math.sqrt((points[secondPoint].x-destX)^2 + (points[secondPoint].y-destY)^2);
				
				-- get closest point to us
				if (destDist < bestDestDist) then
					bestDestDist = destDist;
					closestPointToDest = i;
				end
			end
		end
	end


	-- Move just outside the aggro range
	local moveToPoint = closestPoint;
	local setPoint = 3;

	if (closestPointToDest ~= nil) then	
		local diffPoint = closestPointToDest - moveToPoint;
		if (diffPoint <= 0) then
			moveToPoint = closestPoint - setPoint;
		else
			moveToPoint = closestPoint + setPoint;
		end
	else
		moveToPoint = closestPoint + setPoint;
	end
	
	-- out of bound
	if (moveToPoint == 0 or moveToPoint == nil) then
		moveToPoint = setPoint;
	end

	if (moveToPoint ~= 0)
		and (moveToPoint ~= nil)
		and (points[point].x ~= nil)
		and (points[point].y ~= nil)
		and (pointsTwo[moveToPoint] ~= nil)
		and (pointZ ~= nil)
		and (point ~= nil)
		and (points[point] ~= nil)

		then 

		if (not script_unstuck:pathClearAuto(2)) then
			script_unstuck:unstuck();
			return true;
		end

		if (not IsMoving()) and (script_grind.enemyObj ~= 0 and script_grind.enemyObj ~= nil) then
			if (script_grind.enemyObj:GetDistance() <= 8) then
				script_grind.enemyObj:FaceTarget();
			end
		end
if (script_grind.enemyObj ~= nil and script_grind.enemyObj ~= 0) and (not script_grind.enemyObj:IsCasting()) then
			if (Move(pointsTwo[moveToPoint].x, pointsTwo[moveToPoint].y, pointZ)) then
				if (not script_grind.adjustTickRate) and (PlayerHasTarget()) then
					script_grind.tickRate = 350;
				end	
				script_grind.message = "Moving Away From Adds";
				self.closestEnemy = 0;
				self.intersectEnemy = nil;
				script_om:FORCEOM();
			return;
			end
		end
	end
end

function script_checkAdds:avoidToAggro(safeMargin) 
	
	local countUnitsInRange = 0;
	local currentObj, typeObj = GetFirstObject();
	local localObj = GetLocalPlayer();
	self.closestEnemy = 0;
	local closestDist = 999;
	local aggro = 0;
	local range = 0;
	local xT, yT, zT = 0, 0, 0;
	local xP, yP, zP = 0, 0, 0;
	local x, y, z = 0, 0, 0;
	local xx, yy, zz = 0, 0, 0;
	local centerX, centerY = 0, 0;
	local tarX, tarY, tarZ = 0;
	local myX, myY, myZ = 0;

	-- need to rewrite for quicker access to object manager
	-- need to do a run once at start of combat to gather mobs around player
	-- place those mobs in a table ~ 80 yard range? based on distance closest first
	-- call that table to find first entry which should be closest target

	-- avoid closest target
	while currentObj ~= 0 do
				local range = script_checkAdds.addsRange;
				local aggro = script_checkAdds.addsRange;
				--local myAggro = currentObj:GetLevel() - localObj:GetLevel() + 23;
				local myAggro = script_checkAdds.addsRange;
				
 		if (typeObj == 3)
			and (currentObj:GetDistance() <= self.addsRange)
			--and (currentObj:IsInLineOfSight())
		then
			if (script_grind.enemyObj ~= nil)
				and (currentObj:GetGUID() ~= script_grind.enemyObj:GetGUID())
				and (not script_grind:isTargetingMe(currentObj))
				and (not script_grind:isTargetingPet(currentObj))
				and (currentObj:CanAttack())
				and (not currentObj:IsDead())
				and (not currentObj:IsCritter())
				and (not currentObj:HasDebuff("Polymorph"))
				and (not currentObj:HasDebuff("Fear"))
			then
					local tarX, tarY, tarZ = currentObj:GetPosition();
					local myX, myY, myZ = localObj:GetPosition();
				if (currentObj:GetDistance() <= (range+1)
				or GetDistance3D(myX, myY, myZ, tarX, tarY, tarZ) <= myAggro)
				then
					self.closestEnemy = currentObj;	
				elseif (currentObj:GetGUID() ~= script_grind.enemyObj:GetGUID()) then

					local dist = currentObj:GetDistance();

					if (dist < closestDist) then
						closestDist = dist;
						script_checkAdds.closestEnemy = currentObj;
					end
				end
			typeObj = GetNextObject(currentObj);
			end
		end
	currentObj, typeObj = GetNextObject(currentObj);

		-- recheck closest target
		if (typeObj == 3)
			and (currentObj:GetDistance() <= self.addsRange)
			--and (currentObj:IsInLineOfSight())
		then
			if (script_grind.enemyObj ~= nil)
				and (currentObj:GetGUID() ~= script_grind.enemyObj:GetGUID())
				and (not script_grind:isTargetingMe(currentObj))
				and (not script_grind:isTargetingPet(currentObj))
				and (currentObj:CanAttack())
				and (not currentObj:IsDead())
				and (not currentObj:IsCritter())
				and (not currentObj:HasDebuff("Polymorph"))
				and (not currentObj:HasDebuff("Fear"))
			then
						local tarX, tarY, tarZ = currentObj:GetPosition();
					local myX, myY, myZ = localObj:GetPosition();
				if (currentObj:GetDistance() <= (range+1)
				or GetDistance3D(myX, myY, myZ, tarX, tarY, tarZ) <= myAggro)
				then
					self.closestEnemy = currentObj;	
				elseif (currentObj:GetGUID() ~= script_grind.enemyObj:GetGUID()) then

					local dist = currentObj:GetDistance();

					if (dist < closestDist) then
						closestDist = dist;
						script_checkAdds.closestEnemy = currentObj;
					end
				end
			typeObj = GetNextObject(currentObj);
			end
		end
	currentObj, typeObj = GetNextObject(currentObj);
				

		-- avoid the closest mob
			local range = self.addsRange;
						
		if (self.closestEnemy ~= 0) and (not script_checkDebuffs:hasDisabledMovement()) then

			local xT, yT, zT = self.closestEnemy:GetPosition();

 			local xP, yP, zP = localObj:GetPosition();

			local safeRange = safeMargin+1;
			self.intersectEnemy = script_checkAdds:aggroIntersect(self.closestEnemy);
			if (self.intersectEnemy ~= nil) then
				local aggroRange = self.addsRange; 
				local x, y, z = self.closestEnemy:GetPosition();
				local xx, yy, zz = self.intersectEnemy:GetPosition();
				local centerX, centerY = (x+xx)/2, (y+yy)/2;
			
				script_checkAdds:avoid(centerX, centerY, zP, aggroRange/3, self.checkAddsRange*2);
				PetFollow();
			else
				script_checkAdds:avoid(xT, yT, zP, aggro/3, self.checkAddsRange/2);
				PetFollow();
			end

		return;
		end
	currentObj, typeObj = GetNextObject(currentObj);


	end
	return false;
end




function script_checkAdds:aggroIntersect(target)
	local x, y, z = target:GetPosition();
	self.intersectEnemy = nil;
	while currentObj ~= 0 do
 		if (typeObj == 3)
			and (currentObj:GetDistance() <= 35)
			--and (currentObj:IsInLineOfSight())
		then
			if (currentObj:CanAttack())
				and (not currentObj:IsDead())
				and (not currentObj:IsCritter())
				and (not script_grind:isTargetingMe(currentObj))
				and (not script_grind:isTargetingPet(currentObj))
				and (self.closestEnemy ~= 0)
				and (currentObj:GetGUID() ~= self.closestEnemy:GetGUID())
				and (not currentObj:HasDebuff("Polymorph"))
				and (not currentObj:HasDebuff("Fear"))
			then
				
				local xx, yy, zz = currentObj:GetPosition();
				local dist = math.sqrt((x-xx)^2 +(y-yy)^2);
				local curDist = currentObj:GetDistance();
				local range = self.addsRange;

				if (curDist <= range) then
					return currentObj;
				end
 			end
		typeObj = GetNextObject(currentObj);
 		end

 		currentObj, typeObj = GetNextObject(currentObj);
 	end
return nil;
end




function script_checkAdds:avoid(pointX,pointY,pointZ, radius, safeDist)
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

	while theta <= 2*PI do
		point = point + 1 -- get next table slot, starts at 0 
		points[point] = { x = pointX + radius*cos(theta), y = pointY + radius*sin(theta) }
		pointsTwo[point] = { x = pointX + (self.addsRange+2)*cos(theta)*2, y = pointY + (self.addsRange+2)*sin(theta)*2 }
		theta = theta + 2*PI / quality -- get next theta
	end
	for i = 1, point do
		local firstPoint = i
		local secondPoint = i + 1

		if firstPoint == point then
			secondPoint = 1
		end

		if points[firstPoint] and points[secondPoint] then

			local myX, myY, myZ = GetLocalPlayer():GetPosition();

			local dist = math.sqrt((points[secondPoint].x-myX)^2 + (points[secondPoint].y-myY)^2);

			local distToDest = math.sqrt((points[secondPoint].x)^2 + (points[secondPoint].y)^2);

			-- Set target theta point
			if (distToDest < closestTargetDist) then
				closestTargetDist = distToDest;
				closestTargetPoint = i;
			end

			-- Set closest theta point to move to
			if (dist < closestDist) then
				closestDist = dist;
				closestPoint = i;
			end
		end
	end

	-- Move just outside the aggro range
	moveToPoint = closestPoint;
	local setPoint = 3;

	-- find direction to travel

	if (closestPoint ~= nil) then	
		local diffPoint = closestPoint - moveToPoint;
		if (diffPoint <= 0) then
			moveToPoint = closestPoint - setPoint;
		else
			moveToPoint = closestPoint + setPoint;
		end
	else
		moveToPoint = closestPoint + setPoint;
	end
	
	-- out of bound
	if (moveToPoint == 0 or moveToPoint == nil) then
		moveToPoint = setPoint;
	end

	if (moveToPoint ~= 0)
		and (moveToPoint ~= nil)
		and (points[point].x ~= nil)
		and (points[point].y ~= nil)
		and (pointsTwo[moveToPoint] ~= nil)
		and (pointZ ~= nil)
		and (point ~= nil)
		and (points[point] ~= nil)

		then 

		if (not script_unstuck:pathClearAuto(2)) then
			script_unstuck:unstuck();
			return true;
		end

		if (not IsMoving()) and (script_grind.enemyObj ~= 0 and script_grind.enemyObj ~= nil) then
			if (script_grind.enemyObj:GetDistance() < 8) then
				script_grind.enemyObj:FaceTarget();
			end
		end

		if (script_grind.enemyObj ~= nil and script_grind.enemyObj ~= 0) and (not script_grind.enemyObj:IsCasting()) then
			if (Move(pointsTwo[moveToPoint].x, pointsTwo[moveToPoint].y, pointZ)) then
				if (not script_grind.adjustTickRate) and (PlayerHasTarget()) then
					script_grind.tickRate = 135;
				end
				script_grind.message = "Moving Away From Adds";
				self.closestEnemy = 0;
				self.intersectEnemy = nil;
				script_om:FORCEOM();
			return;
			end
		end
	end
end

-- lazy attempt to avoid adds during resting
function script_checkAdds:avoidToAggro2(safeMargin) 

	local countUnitsInRange = 0;
	local currentObj, typeObj = GetFirstObject();
	local localObj = GetLocalPlayer();
	self.closestEnemy = 0;
	local closestDist = 999;
	local aggro = 0;
	local range = 0;
	local xT, yT, zT = 0, 0, 0;
	local xP, yP, zP = 0, 0, 0;
	local x, y, z = 0, 0, 0;
	local xx, yy, zz = 0, 0, 0;
	local centerX, centerY = 0, 0;

	while currentObj ~= 0 do
				local range = script_checkAdds.addsRange;
				local aggro = script_checkAdds.addsRange;
				--local myAggro = currentObj:GetLevel() - localObj:GetLevel() + 25;
				local myAggro = script_checkAdds.addsRange;
				
 		if (typeObj == 3)
			and (currentObj:GetDistance() <= self.addsRange)
			--and (currentObj:IsInLineOfSight())
		then
			if (not script_grind:isTargetingMe(currentObj))
				and (not script_grind:isTargetingPet(currentObj))
				and (currentObj:CanAttack())
				and (not currentObj:IsDead())
				and (not currentObj:IsCritter())
				and (not currentObj:HasDebuff("Polymorph"))
				and (not currentObj:HasDebuff("Fear"))
			then
					local tarX, tarY, tarZ = currentObj:GetPosition();
					local myX, myY, myZ = localObj:GetPosition();
				if (currentObj:GetDistance() <= (range+1))
				--or GetDistance3D(myX, myY, myZ, tarX, tarY, tarZ) <= (myAggro))
				then
					self.closestEnemy = currentObj;	
				end
					
 			end
		end
	currentObj, typeObj = GetNextObject(currentObj);
				

		-- avoid the closest mob
			local range = self.addsRange;
						
		if (self.closestEnemy ~= 0) and (not script_checkDebuff:hasDisabledMovement()) and (closestEnemy:GetDistance() < self.addsRange + 5) then

			local xT, yT, zT = self.closestEnemy:GetPosition();

 			local xP, yP, zP = localObj:GetPosition();

			local safeRange = safeMargin+1;
			self.intersectEnemy = script_checkAdds:aggroIntersect(self.closestEnemy);
			if (self.intersectEnemy ~= nil) then
				local aggroRange = self.addsRange; 
				local x, y, z = self.closestEnemy:GetPosition();
				local xx, yy, zz = self.intersectEnemy:GetPosition();
				local centerX, centerY = (x+xx)/2, (y+yy)/2;
			
				script_checkAdds:avoid(centerX, centerY, zP, aggroRange/3, self.checkAddsRange*2);
				PetFollow();

			else

				script_checkAdds:avoid(xT, yT, zP, aggro/3, self.checkAddsRange/2);
				PetFollow();
			end

		typeObj = GetNextObject(currentObj);

		return true;
		end
	currentObj, typeObj = GetNextObject(currentObj);


	end
	return false;
end