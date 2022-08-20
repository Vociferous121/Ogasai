script_druid = {
	message = 'Druid - Feral',
	eatHealth = 1,
	drinkMana = 20,
	healHealth = 3,
	rejuHealth = 4,
	regrowthHealth = 5,
	healHealthWhenShifted = 5,
	potionHealth = 12,
	potionMana = 20,
	isSetup = false,
	meeleDistance = 4,
	waitTimer = 0,
	stopIfMHBroken = false,
	cat = false,
	bear = false,
	stayCat = false,
	isChecked = true
}

function script_druid:setup()
	if (HasSpell('Dire Bear Form')) then
		self.bear = true;
	end
	
	self.waitTimer = GetTimeEX();	

	self.isSetup = true;
end

function script_druid:getSpellCost(spell)
	_, _, _, _, cost, _, _ = GetSpellInfo(spell);
	return cost;
end

function script_druid:spellAttack(spellName, target)
	if (HasSpell(spellName)) then
		if (target:IsSpellInRange(spellName)) then
			if (not IsSpellOnCD(spellName)) then
				if (not IsAutoCasting(spellName)) then
					target:FaceTarget();
					return target:CastSpell(spellName);
				end
			end
		end
	end
	return false;
end

function script_druid:enemiesAttackingUs(range) -- returns number of enemies attacking us within range
    local unitsAttackingUs = 0; 
    local currentObj, typeObj = GetFirstObject(); 
    while currentObj ~= 0 do 
    	if typeObj == 3 then
		if (currentObj:CanAttack() and not currentObj:IsDead()) then
                	if (script_grind:isTargetingMe(currentObj) and currentObj:GetDistance() <= range) then 
                		unitsAttackingUs = unitsAttackingUs + 1; 
                	end 
            	end 
       	end
        currentObj, typeObj = GetNextObject(currentObj); 
    end
    return unitsAttackingUs;
end

-- Run backwards if the target is within range
function script_druid:runBackwards(targetObj, range) 
	local localObj = GetLocalPlayer();
 	if targetObj ~= 0 then
 		local xT, yT, zT = targetObj:GetPosition();
 		local xP, yP, zP = localObj:GetPosition();
 		local distance = targetObj:GetDistance();
 		local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
 		local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 		local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;		
 		local moveX, moveY, moveZ = xT + xUV*5, yT + yUV*5, zT + zUV;		
 		if (distance < range) then 
 			Move(moveX, moveY, moveZ);
			self.waitTimer = GetTimeEX() + 1500;
 			return true;
 		end
	end
	return false;
end

function script_druid:draw()
	--script_druid:window();
	local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
	if (onScreen) then
		DrawText(self.message, tX+75, tY+40, 0, 255, 255);
	else
		DrawText(self.message, 25, 185, 0, 255, 255);
	end
end

--[[ error codes: 	0 - All Good , 
			1 - missing arg , 
			2 - invalid target , 
			3 - not in range, 
			4 - do nothing , 
			5 - targeted player pet/totem
			6 - stop bot request from combat script  ]]--

function script_druid:run(targetGUID)
	
	if(not self.isSetup) then
		script_druid:setup();
	end
	
	local localObj = GetLocalPlayer();
	local localHealth = localObj:GetHealthPercentage();
	local localMana = localObj:GetManaPercentage();
	local localLevel = localObj:GetLevel();

	if (localObj:IsDead()) then
		return 0; 
	end

	-- Assign the target 
	targetObj = GetGUIDObject(targetGUID);
	
	if(targetObj == 0 or targetObj == nil) then
		return 2;
	end

	-- Check: Do nothing if we are channeling or casting or wait timer
	if (IsChanneling() or IsCasting() or (self.waitTimer > GetTimeEX())) then
		return 4;
	end
	
	--Valid Enemy
	if (targetObj ~= 0) then
		
		-- Cant Attack dead targets
		if (targetObj:IsDead() or not targetObj:CanAttack()) then
			return 0;
		end
		
		if (not IsStanding()) then
			StopMoving();
		end

		-- Auto Attack
		if (targetObj:GetDistance() < 40) then
			targetObj:AutoAttack();
		end
	
		targetHealth = targetObj:GetHealthPercentage();

		-- Check: if we target player pets/totems
		if (GetTarget() ~= nil and targetObj ~= nil) then
			if (UnitPlayerControlled("target") and GetTarget() ~= localObj) then 
				script_grind:addTargetToBlacklist(targetObj:GetGUID());
				return 5; 
			end
		end 
		
		-- Opener
		if (not IsInCombat()) then
			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";

			-- Go Bear Form
			if (self.bear and not localObj:HasBuff('Dire Bear Form')) then
				-- Dismount
				if (IsMounted()) then 
					DisMount(); 
				end
				CastSpellByName('Dire Bear Form');
				self.stayBear = true;
				return 3;
			end

			if(targetObj:GetDistance() > 30 or not targetObj:IsInLineOfSight()) then
				return 3;
			end

			-- Pull with Faerie Fire
			if (HasSpell('Faerie Fire (Feral)') and localObj:HasBuff('Dire Bear Form')) then
				if (Cast('Faerie Fire (Feral)', targetObj)) then 
					self.message = "Pulling with Faerie Fire...";
					return 3;
				end
			end

			-- Pull with Swipe
			if (self.bear and localObj:HasBuff('Dire Bear Form') and targetObj:GetDistance() < 5) then
				if (Cast('Swipe', targetObj)) then
					return 0;
				end
			end

			-- Check move into meele range
			if (targetObj:GetDistance() > self.meeleDistance or not targetObj:IsInLineOfSight()) then
				return 3;
			end

		-- Combat
		else	
			self.message = "Killing " .. targetObj:GetUnitName() .. "...";
			
			-- Run backwards if we are too close to the target
			if (targetObj:GetDistance() < 0.5) then 
				if (script_druid:runBackwards(targetObj,3)) then 
					return 4; 
				end 
			end

			targetObj:FaceTarget();
			targetObj:AutoAttack();
				
			-- Shapeshift
			if (self.bear and not localObj:HasBuff('Dire Bear Form')) then
				CastSpellByName('Dire Bear Form');
				return 0;
			end

			-- Check if we are in meele range
			if (targetObj:GetDistance() > self.meeleDistance or not targetObj:IsInLineOfSight()) then
				return 3;
			else
				if (IsMoving()) then 
					StopMoving(); 
				end
			end

			-- Check: If we are in meele range, do meele attacks
			if (targetObj:GetDistance() < self.meeleDistance) then
				if (IsMoving()) then
					StopMoving();
				end

				-- Bear form
				if (self.bear) then

					local rage = GetLocalPlayer():GetRagePercentage();

					-- If we fight more than one target
					if (script_druid:enemiesAttackingUs(5) > 1) then
						-- Demoralizing roar
						if (not targetObj:HasDebuff('Demoralizing Roar') and HasSpell('Demoralizing Roar') and rage >= 10) then
							CastSpellByName('Demoralizing Roar');
							self.message = "Using Demoralizing Roar...";
							return 0;
						end
						
						-- Swipe
						if (HasSpell('Swipe') and rage >= 15) then
							CastSpellByName('Swipe');
							self.message = "Using Swipe...";
							return 0;
						elseif (rage < 20) then
							self.message = "Saving rage for Swipe...";
							return 0; -- save rage for swipe
						end
					end
				
					-- Maul
					if (not IsSpellOnCD('Maul') and rage >= 10) then
						if(Cast('Maul', targetObj)) then
							return 0;
						end
					end
					
				end

				-- Always face the target
				targetObj:FaceTarget(); 
				return 0; 
			end

			return 0;
		end
	end
end

	-- Buff
	--if (not IsMounted() and not localObj:HasBuff('Cat Form') and not localObj:HasBuff('Bear Form')) then
	--	if (not localObj:HasBuff('Mark of the Wild') and HasSpell('Mark of the Wild')) then
	--		if (not Buff('Mark of the Wild', localObj)) then
	--			return true;
	--		end
	--	end
		
		--if (not localObj:HasBuff('Thorns') and HasSpell('Thorns')) then
		--	if (not Buff('Thorns', localObj)) then
		--		return true;
		--	end
	--	end
	--end

function script_druid:window()

	if (self.isChecked) then
	
		--Close existing Window
		EndWindow();

		if(NewWindow("Class Combat Options", 200, 200)) then
			script_druid:menu();
		end
	end
end

function script_druid:menu()
	if (CollapsingHeader("[Druid - Tank")) then
		local wasClicked = false;
		Text('Rest options:');
		Separator();
		Text('Combat options:');
		self.meeleDistance = SliderFloat("Meele range", 1, 6, self.meeleDistance);
	end
end