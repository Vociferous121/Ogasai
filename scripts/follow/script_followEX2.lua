script_followEX2 = {

}


function script_followEX2:setup()

	vendorDB:setup();
	vendorDB:loadDBVendors();
	script_vendor:setup();

	local class = UnitClass('player');
	
	if class == "Mage" 
		or class == "Warlock"
		or class == "Rogue"
		or class == "Warrior"
		or class == "Hunter" then
		
		script_follow.assistInCombat = true;
	end
	if class == "Priest" or class == "Paladin" or class == "Shaman" or class == "Druid" then
		script_follow.assistInCombat = true;
		script_follow.dpsHP = 75;
	end

end

function script_followEX2:enemiesAttackingUs() -- returns number of enemies attacking us
		local unitsAttackingUs = 0; 
		local currentObj, typeObj = GetFirstObject(); 
	while currentObj ~= 0 do 
		if typeObj == 3 then
			if (currentObj:CanAttack() and not currentObj:IsDead()) then
				if (script_followEX2:IsTargetingMe(currentObj)) 
					or (script_followEX2:IsTargetingPet(currentObj)) then
					unitsAttackingUs = unitsAttackingUs + 1; 
                		end 
           		 end 
       		end
      		currentObj, typeObj = GetNextObject(currentObj); 
	end
   	return unitsAttackingUs;
end

function script_followEX2:IsTargetingMe(target)
	local localPlayer = GetLocalPlayer();
	if (localPlayer ~= nil and localPlayer ~= 0 and not localPlayer:IsDead()) then
		if (target:GetUnitsTarget() ~= nil and target:GetUnitsTarget() ~= 0) then
			return target:GetUnitsTarget():GetGUID() == localPlayer:GetGUID();
		end
	end
	return false;
end
function script_followEX2:IsTargetingPet(target)
	local localPlayer = GetLocalPlayer();
	if (GetPet() ~= nil and GetPet() ~= 0 and not localPlayer:IsDead()) then
		if (target:GetUnitsTarget() ~= nil and target:GetUnitsTarget() ~= 0) then
			return target:GetUnitsTarget():GetGUID() == GetPet:GetGUID();
		end
	end
	return false;
end

function script_followEX2:IsTargetingMe2(currentObj) 
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
			if (script_followEX2:IsTargetingMe(currentObj)) then 
               			nrPlayersTargetingUs = nrPlayersTargetingUs + 1; 
			end 
		end
        	currentObj, typeObj = GetNextObject(currentObj); 
	end
    return nrPlayersTargetingUs;
end

function script_followEX2:IsTargetingPet(i)
		local class = UnitClass("player");
	if (not class == 'Warlock') then
			local pet = GetPet();
		if (pet ~= nil and pet ~= 0 and not pet:IsDead()) then
			if (i:GetUnitsTarget() ~= nil and i:GetUnitsTarget() ~= 0) then
				return i:GetUnitsTarget():GetGUID() == pet:GetGUID();
			end
		end
		return false;
	end
return false;
end

function script_followEX2:IsTargetingMe(i) 
	local localPlayer = GetLocalPlayer();
	if (localPlayer ~= nil and localPlayer ~= 0 and not localPlayer:IsDead()) then
		if (i:GetUnitsTarget() ~= nil and i:GetUnitsTarget() ~= 0) then
			return i:GetUnitsTarget():GetGUID() == localPlayer:GetGUID();
		end
	end
	return false;
end

function script_followEX2:assignTarget() 
        -- Instantly return the last target if we attacked it and it's still alive and we are in combat
        if (script_follow.enemyObj ~= 0 and script_follow.enemyObj ~= nil and not script_follow.enemyObj:IsDead() and IsInCombat()) then
            if (script_followEX2:IsTargetingMe(script_follow.enemyObj) 
                or script_followEX2:IsTargetingPet(script_follow.enemyObj) 
                or script_follow.enemyObj:IsTappedByMe()) then
                return script_follow.enemyObj;
            end
        end

        -- Find the closest valid target if we have no target or we are not in combat
        local mobDistance = script_follow.pullDistance;
        local closestTarget = nil;
        local i, targetType = GetFirstObject();
        while i ~= 0 do
            if (targetType == 3 and not i:IsCritter() and not i:IsDead() and i:CanAttack()) then
                if (script_followEX2:enemyIsValid(i)) then
                    -- save the closest mob or mobs attacking us
                    if (mobDistance > i:GetDistance()) then
                        mobDistance = i:GetDistance();	
                        closestTarget = i;
                    end
                end
            end
            i, targetType = GetNextObject(i);
        end
        
        -- Check: If we are in combat but no valid target, kill the "unvalid" target attacking us
        if (closestTarget == nil and IsInCombat()) then
            if (GetTarget() ~= 0) then
                return GetTarget();
            end
        end

        -- Return the closest valid target or nil
        return closestTarget;
 end


function script_followEX2:enemyIsValid(i)
	if (i ~= 0) then
		-- Valid Targets: Tapped by us, or is attacking us or our pet
		if (script_followEX2:IsTargetingMe(i)
			or (script_followEX2:IsTargetingPet(i) and (i:IsTappedByMe() or not i:IsTapped())) 
			or (i:IsTappedByMe() and not i:IsDead())) then 
				return true; 
		end
		-- Valid Targets: Within pull range, levelrange, not tapped, not skipped etc
		if (not i:IsDead()) and (i:CanAttack()) and (not i:IsCritter())
			and (i:GetDistance() < 100) and (not i:IsTapped() or i:IsTappedByMe()) then
			return true;
		end
	end
	return false;
end


function script_followEX2:getTarget()
	return script_follow.enemyObj;
end

function script_followEX2:getTargetAttackingUs() 
   	local currentObj, typeObj = GetFirstObject(); 
   while currentObj ~= 0 do 
    	if typeObj == 3 then
			if (currentObj:CanAttack() and not currentObj:IsDead()) then
					local localObj = GetLocalPlayer();		
				if (currentObj:GetUnitsTarget() == localObj) then 
					script_follow.objectAttackingUs = currentObj;
                			return currentObj; 
				end 
			end
	end
        currentObj, typeObj = GetNextObject(currentObj); 
    end
    return nil;
end

function script_followEX2:isTargetAttackingMember() 
   	local currentObj, typeObj = GetFirstObject(); 
	local member = GetPartyMember(i);

	for i = 1, GetNumPartyMembers() do
		member = GetPartyMember(i);
	end

   	while currentObj ~= 0 do 
    	if typeObj == 3 then
			if (currentObj:CanAttack() and not currentObj:IsDead()) then
				if (currentObj:GetUnitsTarget() == member) then 
					script_follow.objectAttackingUs = currentObj;
                			return true; 
				end 
			end
	end
        currentObj, typeObj = GetNextObject(currentObj); 
    end
    return false;
end