script_om = {

}

-- move away from adds
function script_om:FORCEOM()

	local closestDist = 999;

	-- fuck this why won't you recognize closest target???

	while currentObj ~= 0 do
		if (typeObj == 3)
			and (currentObj:GetDistance() <= script_checkAdds.addsRange)
			and (currentObj:GetGUID() ~= self.enemyObj:GetGUID())
			and (not script_grind:isTargetingMe3(currentObj))
			and (not script_grind:isTargetingPet(currentObj))
			--and (currentObj:IsInLineOfSight())
			and (not currentObj:IsCritter())
		then
				script_checkAdds.closestEnemy = currentObj;
		else
		
			if (currentObj ~= 0)
				and (typeObj == 3)
				and (currentObj:GetGUID() ~= self.enemyObj:GetGUID())
				--and (currentObj:IsInLineOfSight())
				and (not currentObj:IsCritter())
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
			and (currentObj:GetGUID() ~= self.enemyObj:GetGUID())
			and (not script_grind:isTargetingMe3(currentObj))
			and (not script_grind:isTargetingPet(currentObj))
			--and (currentObj:IsInLineOfSight())
			and (not currentObj:IsCritter())
		then
				script_checkAdds.closestEnemy = currentObj;
		else
		
			if (currentObj ~= 0)
				and (typeObj == 3)
				and (currentObj:GetGUID() ~= self.enemyObj:GetGUID())
				--and (currentObj:IsInLineOfSight())
				and (not currentObj:IsCritter())
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

-- move away from adds
function script_om:FORCEOM2()

	while currentObj ~= 0 do
		script_grind.tickRate = 50;
		if (typeObj == 3) and (currentObj:GetDistance() < script_checkAdds.addsRange)
			and (currentObj:GetGUID() ~= self.enemyObj:GetGUID()) 
			and (not script_grind:isTargetingMe3(currentObj))
			and (not script_grind:isTargetingPet(currentObj)) then		
				script_checkAdds.closestEnemy = currentObj;
		typeObj = GetNextObject(currentObj);
		end
	currentObj, typeObj = GetNextObject(currentObj);
	end
end