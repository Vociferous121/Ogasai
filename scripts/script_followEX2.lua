script_followEX2 = {

}

function script_followEX2:enemiesAttackingUs() -- returns number of enemies attacking us
		local unitsAttackingUs = 0; 
		local currentObj, typeObj = GetFirstObject(); 
	while currentObj ~= 0 do 
		if typeObj == 3 then
			if (currentObj:CanAttack() and not currentObj:IsDead()) then
				if (script_follow:isTargetingMe(currentObj)) then 
					unitsAttackingUs = unitsAttackingUs + 1; 
                		end 
           		 end 
       		end
      		currentObj, typeObj = GetNextObject(currentObj); 
	end
   		return unitsAttackingUs;
end

function script_followEX2:isTargetingMe(target) -- self.enemyObj
	local localPlayer = GetLocalPlayer();
	if (localPlayer ~= nil and localPlayer ~= 0 and not localPlayer:IsDead()) then
		if (target:GetUnitsTarget() ~= nil and target:GetUnitsTarget() ~= 0) then
			return target:GetUnitsTarget():GetGUID() == localPlayer:GetGUID();
		end
	end
	return false;
end

function script_followEX2:isTargetingMe2(currentObj) 
	local localPlayer = GetLocalPlayer();
	if (localPlayer ~= nil and localPlayer ~= 0 and not localPlayer:IsDead()) then
		if (currentObj:GetUnitsTarget() ~= nil and currentObj:GetUnitsTarget() ~= 0) then
			return currentObj:GetUnitsTarget():GetGUID() == localPlayer:GetGUID();
		end
	end
	return false;
end

function script_followEX2:playersTargetingUs() -- returns number of players attacking us
		local nrPlayersTargetingUs = 0; 
		local currentObj, typeObj = GetFirstObject(); 
	while currentObj ~= 0 do 
		if typeObj == 4 then
			if (script_follow:isTargetingMe(currentObj)) then 
               			nrPlayersTargetingUs = nrPlayersTargetingUs + 1; 
			end 
		end
        	currentObj, typeObj = GetNextObject(currentObj); 
	end
    return nrPlayersTargetingUs;
end