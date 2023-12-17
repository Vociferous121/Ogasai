script_checkAdds = {

	addsRange = 35,	-- range circles from from adds
	checkAddsRange = 5,	-- safe margin "runner script" move from adds
	closestEnemy = 0,
	intersectEnemy = nil,
}


-- should we move or not
-- requires target from combat script 'targetObj'
function script_checkAdds:checkAdds()

	-- if we should move away from targetObj
	if (not script_checkAdds:moveAwayFromAdds(targetObj)) then
	-- avoid target
		if (script_checkAdds:avoidToAggro(self.checkAddsRange)) then
	-- try unstuck script
		script_grind.tickRate = 0;
		self.intersectEnemy = nil;
		self.closestEnemy = 0;

			if (not script_unstuck:pathClearAuto(2)) then
				script_unstuck:unstuck();
			end
	-- if we have a pet then pet follow
			if (GetPet() ~= 0) then
				PetFollow();
			end
			self.message = "Moving away from adds...";			
		end
	return true;
	end

return false
end

-- used to check distance of aggro of adds around target and player using my and their distance
-- should we move true or false
function script_checkAdds:moveAwayFromAdds(target) 
	local localObj = GetLocalPlayer();
	local countUnitsInRange = 0;
	local currentObj, typeObj = GetFirstObject();
	local aggro = 0;
	local range = self.addsRange;

	script_grind.tickRate = 0;
	while currentObj ~= 0 do
 		if (typeObj == 3)
		and (script_grind.enemyObj ~= nil and currentObj:GetGUID() ~= script_grind.enemyObj:GetGUID())
		and (not script_grind:isTargetingMe(currentObj))
		and (not currentObj:HasDebuff("Polymorph"))
		and (not currentObj:HasDebuff("Fear"))
		--and (currentObj:IsInLineOfSight())
		and (not script_grind:isTargetingPet(currentObj))	
		and (currentObj:CanAttack())
		and (not currentObj:IsDead())
		and (not currentObj:IsCritter())
		and (not script_grind:isTargetingMe(currentObj)) then
		--	local range = self.addsRange;
			--if (currentObj:GetDistance() <= range+15) then
				countUnitsInRange = countUnitsInRange + 1;
 			--end
 		end	
	currentObj, typeObj = GetNextObject(currentObj);
 	end


	-- avoid if more than 1 add
	if (countUnitsInRange > 1) then
		return false;
	end
	return true;
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
			moveToPoint = closestPoint - 10;
		else
			moveToPoint = closestPoint + 10;
		end
	else
		moveToPoint = closestPoint + 10;
	end
	
	-- out of bound
	if (moveToPoint > point or moveToPoint == 0) then
		moveToPoint = 1;
	end

	Move(pointsTwo[moveToPoint].x, pointsTwo[moveToPoint].y, pointZ);

	self.closestEnemy = 0;
	self.intersectEnemy = nil;
end

function script_checkAdds:avoidToAggro(safeMargin) 
	script_grind.tickRate = 50;
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
 		if (typeObj == 3) and (currentObj:GetGUID() ~= script_grind.enemyObj:GetGUID()) and (not script_grind:isTargetingMe(currentObj)) and (not script_grind:isTargetingPet(currentObj)) and currentObj:CanAttack() and not currentObj:IsDead() and not currentObj:IsCritter() and (currentObj:GetDistance() <= range+5) then
				self.closestEnemy = currentObj;
				if (self.closestEnemy:GetDistance() > currentObj:GetDistance()) then
					self.closestEnemy = currentObj;
				end	
 		end
	currentObj, typeObj = GetNextObject(currentObj);


		-- avoid the closest mob
			local range = self.addsRange;
		if (self.closestEnemy ~= 0) then

			local xT, yT, zT = self.closestEnemy:GetPosition();

 			local xP, yP, zP = localObj:GetPosition();

			local safeRange = safeMargin+1;
			self.intersectEnemy = script_checkAdds:aggroIntersect(self.closestEnemy);
			if (self.intersectEnemy ~= nil) then
				local aggroRange = self.addsRange; 
				local x, y, z = self.closestEnemy:GetPosition();
				local xx, yy, zz = self.intersectEnemy:GetPosition();
				local centerX, centerY = (x+xx)/2, (y+yy)/2;

				SpellStopCasting();

			
				script_checkAdds:avoid(centerX, centerY, zP, aggroRange*10, self.addsRange*10);
				PetFollow();
				self.closestEnemy = 0;
				self.intersectEnemy = nil;

			else
				SpellStopCasting();

				script_checkAdds:avoid(xT, yT, zP, aggro*10, self.addsRange*10);
				PetFollow();
				self.closestEnemy = 0;
				self.intersectEnemy = nil;
			end

			self.closestEnemy = 0;
			self.intersectEnemy = nil;
			return true;


		end
	currentObj, typeObj = GetNextObject(currentObj);


	end
	return false;
end

function script_checkAdds:aggroIntersect(target)
	local x, y,z = target:GetPosition();
	self.intersectEnemy = nil;
	while currentObj ~= 0 do
 		if typeObj == 3 then
			--aggro = currentObj:GetLevel() - localObj:GetLevel() + 21.5;
			--local range = aggro + 35;
			if currentObj:CanAttack() and not currentObj:IsDead() and not currentObj:IsCritter() and not script_grind:isTargetingMe(currentObj) and (not script_grind:isTargetingPet(currentObj)) and (currentObj:GetGUID() ~= self.closestEnemy:GetGUID()) then	
				local xx, yy, zz = currentObj:GetPosition();
				local dist = math.sqrt((x-xx)^2 +(y-yy)^2);
				local curDist = currentObj:GetDistance();
				local range = self.addsRange+5;
				if (curDist < range) then
					return currentObj;
				end
 			end
 		end
 		currentObj, typeObj = GetNextObject(currentObj);
		self.intersectEnemy = nil;
		self.closestEnemy = 0;
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
		pointsTwo[point] = { x = pointX + (self.addsRange)*cos(theta)*2, y = pointY + (self.addsRange)*sin(theta)*2 }
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

	-- TODO use closestPoint and closestTargetPoint to calculate direction to travel
			

	-- Move just outside the aggro range
	local moveToPoint = closestPoint;
	
	moveToPoint = closestPoint + 20;
	
	if (moveToPoint > point) then
		moveToPoint = 1;
	end

	if (moveToPoint == 0) then
		moveToPoint = 1;
	end

	Move(pointsTwo[moveToPoint].x, pointsTwo[moveToPoint].y, pointZ);

	if (not script_unstuck:pathClearAuto(2)) then
			script_unstuck:unstuck();
		end
	self.closestEnemy = 0;
	self.intersectEnemy = nil;


end

-- old defunct attempt to move away from target
function script_checkAdds:movingFromAdds(targetObj, range) 
	local localObj = GetLocalPlayer();
 	if targetObj ~= 0 and (not script_checkDebuffs:hasDisabledMovement()) then
 		local xT, yT, zT = targetObj:GetPosition();
 		local xP, yP, zP = localObj:GetPosition();
 		local distance = targetObj:GetDistance();
 		local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
 		local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 		local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;	
 		local moveX, moveY, moveZ = xT + xUV*35, yT + yUV*35, zT + zUV;		
 		if (distance < range and targetObj:IsInLineOfSight()) then 
			script_navEX:moveToTarget(localObj, moveX, moveY, moveZ);
 			return true;
 		end
	end
	return false;
end