script_warlockDOTS = {


}

--local localObj = GetLocalPlayer();
--local localMana = localObj:GetManaPercentage();
--local localHealth = localObj:GetHealthPercentage();
--local
--if (IsInCombat()) and (localMana

function script_warlockDOTS:getTargetNotDOT()

	local unitsAttackingUs = 0; 
   	local currentObj, typeObj = GetFirstObject(); 
   	while currentObj ~= 0 do 
   		if typeObj == 3 then
			if (currentObj:CanAttack() and not currentObj:IsDead()) then
               			if (script_grind:isTargetingMe(currentObj))
					or (script_grind:isTargetingPet(currentObj))
					then
					if (HasSpell("Corruption") and not currentObj:HasDebuff('Corruption'))
					or (HasSpell("Immolate") and not currentObj:HasDebuff("Immolate"))
					or (HasSpell("Curse of Agony") and not currentObj:HasDebuff("Curse of Agony"))
					then
           				return currentObj;
              	 			end 
				end
			end
           	end 
       	end
        currentObj, typeObj = GetNextObject(currentObj); 
return nil;
end

function script_warlockDOTS:corruption(targetObj) 
	local currentObj, typeObj = GetFirstObject(); 
	local localObj = GetLocalPlayer();
	local mana = localObj:GetManaPercentage();
	if (mana > 20) then
	while currentObj ~= 0 do 
		if typeObj == 3 then
			if (currentObj:CanAttack()) and (not currentObj:IsDead()) then
				if (currentObj:GetDistance() <= 40)
			--and (script_grind:isTargetingMe(currentObj) or script_grind:isTargetingPet(currentObj))
				then
					if (not currentObj:HasDebuff("Corruption")) and (currentObj:IsInLineOfSight()) then
						if (not script_grind.adjustTickRate) then
							script_grind.tickRate = 100;
							script_rotation.tickRate = 100;
						end
						if (script_warlock:cast('Corruption', currentObj)) then 
							script_grind:setWaitTimer(1000);
							return true; 
						end
					end 
				end 
			end 
		end
        currentObj, typeObj = GetNextObject(currentObj); 
	end
	end
return false;
end

function script_warlockDOTS:immolate(targetObj) 
	local currentObj, typeObj = GetFirstObject(); 
	local localObj = GetLocalPlayer();
	local mana = localObj:GetManaPercentage();
	if (mana > 40) then
	while currentObj ~= 0 do 
		if typeObj == 3 then
			if (currentObj:CanAttack()) and (not currentObj:IsDead()) then
				if (currentObj:GetDistance() <= 40)
			--and (script_grind:isTargetingMe(currentObj) or script_grind:isTargetingPet(currentObj))
				then
					if (not currentObj:HasDebuff("Immolate")) and (currentObj:IsInLineOfSight()) then
						if (not script_grind.adjustTickRate) then
							script_grind.tickRate = 100;
							script_rotation.tickRate = 100;
						end
						if (script_warlock:cast('Immolate', currentObj)) then 
							script_grind:setWaitTimer(1000);
							return true; 
						end
					end 
				end 
			end 
		end
        currentObj, typeObj = GetNextObject(currentObj); 
	end
	end
return false;
end

function script_warlockDOTS:curseOfAgony(targetObj) 
	local currentObj, typeObj = GetFirstObject(); 
	local localObj = GetLocalPlayer();
	local mana = localObj:GetManaPercentage();
	if (mana > 40) and (HasSpell("Curse of Agony")) then
	while currentObj ~= 0 do 
		if typeObj == 3 then
			if (currentObj:CanAttack()) and (not currentObj:IsDead()) then
				if (currentObj:GetDistance() <= 40)
			--and (script_grind:isTargetingMe(currentObj) or script_grind:isTargetingPet(currentObj))
				then
					if (not currentObj:HasDebuff("Curse of Agony")) and (currentObj:IsInLineOfSight()) then
						if (not script_grind.adjustTickRate) then
							script_grind.tickRate = 100;
							script_rotation.tickRate = 100;
						end
						if (script_warlock:cast('Curse of Agony', currentObj)) then 
							script_grind:setWaitTimer(1000);
							return true; 
						end
					end 
				end 
			end 
		end
        currentObj, typeObj = GetNextObject(currentObj); 
	end
	end
return false;
end