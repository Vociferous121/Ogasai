script_extraFunctions = {

}



function script_extraFunctions:runBackwards(count, range) -- Run backwards if there is atleast count of monsters within range
	local countUnitsInRange = 0;
	local currentObj, typeObj = GetFirstObject();
	local localObj = GetLocalPlayer();
	local closestEnemy = 0;
	while currentObj ~= 0 do
 		if typeObj == 3 or typeObj == 4 then
			if currentObj:CanAttack() and not currentObj:IsCritter() and currentObj:GetDistance() <= range and not currentObj:IsDead() then	
				countUnitsInRange = countUnitsInRange + 1;
				if (closestEnemy ~= 0) then
					if (currentObj:GetDistance() < closestEnemy:GetDistance()) then			
						closestEnemy = currentObj;
					end
				else
					closestEnemy = currentObj;
				end
 			end
 		end
 		currentObj, typeObj = GetNextObject(currentObj);
 	end
 	
 	if closestEnemy ~= 0 then
 			local xT, yT, zT = closestEnemy:GetPosition();
 			local xP, yP, zP = localObj:GetPosition();
 			local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
 			local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 			local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;	
			local moveX, moveY, moveZ = xT + xUV*35, yT + yUV*35, zT + zUV;		
 		if countUnitsInRange >= count then
			script_navEX:moveToTarget(localObj, moveX, moveY, moveZ);
			return true;
		end
	end
end

function script_extraFunctions:avoidElite() -- Runs away if there is atleast one elite within range
	local currentObj, typeObj = GetFirstObject();
	local localObj = GetLocalPlayer();
	while currentObj ~= 0 do
 		if (typeObj == 3) and (currentObj:GetClassification() == 1 or currentObj:GetClassification() == 2) then
			if (currentObj:CanAttack()) and (currentObj:GetDistance() <= script_grind.avoidRange) and (not currentObj:IsDead()) then	
				local xT, yT, zT = currentObj:GetPosition();
 				local xP, yP, zP = localObj:GetPosition();
 				local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
 				local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 				local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;		
 				local moveX, moveY, moveZ = xT + xUV*40, yT + yUV*40, zT + zUV;			
				script_nav:moveToNav(localObj, moveX, moveY, moveZ);
				script_grind:setWaitTimer(15000);
			return;
 			end
	 	end
 	currentObj, typeObj = GetNextObject(currentObj);
 	end
return false;
end