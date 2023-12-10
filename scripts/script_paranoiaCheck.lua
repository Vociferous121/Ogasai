script_paranoiaCheck = {

}

function script_paranoiaCheck:playersWithinRange(range)
	local currentObj, typeObj = GetFirstObject(); 
	while currentObj ~= 0 do 
		if (typeObj == 4 and not currentObj:IsDead()) then
			if (currentObj:GetDistance() < range) then 
				local localObj = GetLocalPlayer();
				if (localObj:GetGUID() ~= currentObj:GetGUID()) and (currentObj:GetUnitName() ~= script_paranoia.ignoreTarget) then
						script_grind.tickRate = 0;
						script_grind.paranoidTargetDistance = currentObj:GetDistance();
						script_grind.paranoidTargetName = currentObj:GetUnitName();
					if (script_grind.useString) then
						if (currentObj:GetDistance() < script_grind.paranoidRange) and (typeObj == 4) then
							script_grind.otherName = currentObj;
							local playerString = ""..script_grind.playerName.."";
							script_grind.playerName = currentObj:GetUnitName();
							script_grind.playerPos = currentObj:GetPosition();
							local playerName = currentObj:GetUnitName();
							local playerDistance = currentObj:GetDistance();
							script_grind.playerParanoidDistance = currentObj:GetDistance();
							local playerTime = GetTimeStamp();
							local string ="" ..playerTime.. " - Player Name ("..playerName.. ") - Distance (yds) "..playerDistance.. " - added to log file for further implementation of paranoia. Logout Timer has been set!"
							DEFAULT_CHAT_FRAME:AddMessage(string);
							ToFile(string);
							script_grind.useString = false;
						end
				
					end
				return true;
				end
			end 
		end
		currentObj, typeObj = GetNextObject(currentObj); 
	end
	script_grind.useString = true;
	return false;
end

function script_paranoiaCheck:playersWithinRange2(range)
	local currentObj, typeObj = GetFirstObject(); 
	while currentObj ~= 0 do 
		if (typeObj == 4 and not currentObj:IsDead()) then
			if (currentObj:GetDistance() < range) then 
				local localObj = GetLocalPlayer();
				if (localObj:GetGUID() ~= currentObj:GetGUID()) and (currentObj:GetUnitName() ~= script_paranoia.ignoreTarget) and (currentObj:IsInLineOfSight() or script_grind:playersTargetingUs() >= 1) then
						script_grind.paranoidTargetDistance = currentObj:GetDistance();
						script_grind.paranoidTargetName = currentObj:GetUnitName();
					if (script_grind.useString) then
						if (currentObj:GetDistance() < script_grind.paranoidRange) and (typeObj == 4) then
							script_grind.otherName = currentObj;
							local playerString = ""..script_grind.playerName.."";
							script_grind.playerName = currentObj:GetUnitName();
							script_grind.playerPos = currentObj:GetPosition();
							local playerName = currentObj:GetUnitName();
							local playerDistance = currentObj:GetDistance();
							script_grind.playerParanoidDistance = currentObj:GetDistance();
						end
				
					end
				return true;
				end
			end 
		end
		currentObj, typeObj = GetNextObject(currentObj); 
	end
	script_grind.useString = true;
	return false;
end