script_om = {

}

-- move away from adds
function script_om:FORCEOM()

	currentObj, typeObj = GetFirstObject();

	local closestDist = 999;

	-- fuck this why won't you recognize closest target???
if (script_grind.enemyObj ~= nil and script_grind.enemyObj ~= 0) then
	while currentObj ~= 0 do
		if (typeObj == 3)
			and (currentObj:GetDistance() <= script_checkAdds.addsRange)
			and (currentObj:GetGUID() ~= script_grind.enemyObj:GetGUID())
			and (not script_grind:isTargetingMe3(currentObj))
			and (not script_grind:isTargetingPet(currentObj))
			--and (currentObj:IsInLineOfSight())
			and (not currentObj:IsCritter())
			and (not currentObj:IsDead())
			and (currentObj:CanAttack())
		then
				script_checkAdds.closestEnemy = currentObj;
		else
		
			if (currentObj ~= 0)
				and (typeObj == 3)
				and (currentObj:GetGUID() ~= script_grind.enemyObj:GetGUID())
				--and (currentObj:IsInLineOfSight())
				and (not currentObj:IsCritter())
				and (not currentObj:IsDead())
				and (currentObj:CanAttack())
				and (not script_grind:isTargetingMe3(currentObj))
				and (not script_grind:isTargetingPet(currentObj))
			then
	
				local dist = currentObj:GetDistance();
	
				if (dist < closestDist) then
					closestDist = dist;
					script_checkAdds.closestEnemy = currentObj;
				end
			end
		typeObj = GetNextObject(currentObj);
		end
	currentObj, typeObj = GetNextObject(currentObj);
	end

	while currentObj ~= 0 do
		if (typeObj == 3)
			and (currentObj:GetDistance() <= script_checkAdds.addsRange)
			and (currentObj:GetGUID() ~= script_grind.enemyObj:GetGUID())
			and (not script_grind:isTargetingMe3(currentObj))
			and (not script_grind:isTargetingPet(currentObj))
			--and (currentObj:IsInLineOfSight())
			and (not currentObj:IsCritter())
			and (not currentObj:IsDead())
			and (currentObj:CanAttack())
		then
				script_checkAdds.closestEnemy = currentObj;
		else
		
			if (currentObj ~= 0)
				and (typeObj == 3)
				and (currentObj:GetGUID() ~= script_grind.enemyObj:GetGUID())
				--and (currentObj:IsInLineOfSight())
				and (not currentObj:IsCritter())
				and (not currentObj:IsDead())
				and (currentObj:CanAttack())
				and (not script_grind:isTargetingMe3(currentObj))
				and (not script_grind:isTargetingPet(currentObj))
			then

				local dist = currentObj:GetDistance();

				if (dist < closestDist) then
					closestDist = dist;
					script_checkAdds.closestEnemy = currentObj;
				end
			end
		typeObj = GetNextObject(currentObj);
		end
	currentObj, typeObj = GetNextObject(currentObj);
	end
end
end

-- move away from adds
function script_om:FORCEOM2()

	currentObj, typeObj = GetFirstObject();
if (script_grind.enemyObj ~= nil and script_grind.enemyObj ~= 0) then
	while currentObj ~= 0 do
		if (not script_grind.adjustTickRate) and (IsInCombat()) then
			script_grind.tickRate = 50;
		end
		if (typeObj == 3) and (currentObj:GetDistance() < script_checkAdds.addsRange)
			and (currentObj:GetGUID() ~= script_grind.enemyObj:GetGUID()) 
			and (not script_grind:isTargetingMe3(currentObj))
			and (not script_grind:isTargetingPet(currentObj))
			and (not currentObj:IsCritter())
			and (not currentObj:IsDead())
			and (currentObj:CanAttack())
		then		
				script_checkAdds.closestEnemy = currentObj;
		typeObj = GetNextObject(currentObj);
		end
	currentObj, typeObj = GetNextObject(currentObj);
	end
end
end