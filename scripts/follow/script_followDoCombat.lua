script_followDoCombat = {

}

function script_followDoCombat:run()

			-- reset the combat status
				script_follow.combatError = nil; 
				
			-- Run the combat script and retrieve combat script status if we have a valid target
			if (script_follow.enemyObj ~= nil and script_follow.enemyObj ~= 0) then
				script_follow.combatError = RunCombatScript(script_follow.enemyObj:GetGUID());
				local class = UnitClass('player');
				if (script_follow.enemyObj ~= nil) and (class == 'Priest' or class == 'Warlock' or class == 'mage')
					and (not localObj:HasRangedWeapon()) then
					if (script_follow.enemyObj:GetDistance() > script_follow.meleeDistance)
						or (not script_follow.enemyObj:IsInLineOfSight()) then
						local x, y, z = script_follow.enemyObj:GetPosition();
						script_navEX:moveToTarget(localObj, x, y, z);
					return;
					end
				elseif (script_follow.enemyObj ~= nil) and (not class == 'Druid') then
					if (script_follow.enemyObj:GetDistance() > script_follow.meleeDistance)
						or (not script_follow.enemyObj:IsInLineOfSight()) then
						local x, y, z = script_follow.enemyObj:GetPosition();
						script_navEX:moveToTarget(localObj, x, y, z);
					return;
					end
				end
			end
	
			if (script_follow.enemyObj ~= nil or IsInCombat()) then

				local class = UnitClass('player');


				if (script_follow.enemyObj ~= nil) and (class == 'Priest' or class == 'Warlock' or class == 'mage')
					and (not localObj:HasRangedWeapon()) then
					if (script_follow.enemyObj:GetDistance() > script_follow.meleeDistance)
						or (not script_follow.enemyObj:IsInLineOfSight()) then
						local x, y, z = script_follow.enemyObj:GetPosition();
						script_navEX:moveToTarget(localObj, x, y, z);
					return;
					end
				elseif (script_follow.enemyObj ~= nil) and (not class == 'Druid') then
					if (script_follow.enemyObj:GetDistance() > script_follow.meleeDistance)
						or (not script_follow.enemyObj:IsInLineOfSight()) then
						local x, y, z = script_follow.enemyObj:GetPosition();
						script_navEX:moveToTarget(localObj, x, y, z);
					return;
					end
				end

				script_follow.message = "Running the combat script...";
				-- In range: attack the target, combat script returns 0
				if(script_follow.combatError == 0) then
					script_nav:resetNavigate();
					if IsMoving() then
						StopMoving(); 
						return;
					end
				end
				-- Invalid target: combat script return 2
				if(script_follow.combatError == 2) then
					-- TODO: add blacklist GUID here
					script_follow.enemyObj = nil;
					ClearTarget();
					return;
				end
				-- Move in range: combat script return 3
				if (script_follow.combatError == 3) then
					script_follow.message = "Moving to target...";
					local _x, _y, _z = script_follow.enemyObj:GetPosition();
					script_navEX:moveToTarget(GetLocalPlayer(), _x, _y, _z);
					return;
				end
				-- Do nothing, return : combat script return 4
				if(script_follow.combatError == 4) then
					return;
				end	
				-- Stop bot, request from a combat script
				if(script_follow.combatError == 6) then
					script_follow.message = "Combat script request stop bot...";
					Logout();
					StopBot();
					return;
				end
			end

		if (IsInCombat()) then
			if (script_follow.enemyObj ~= nil) then
				script_follow.enemyObj:FaceTarget();
			end
		end
	return false;
	end