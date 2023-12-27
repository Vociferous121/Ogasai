script_followDoCombat = {

}

function script_followDoCombat:run()

			-- reset the combat status
			script_follow.combatError = nil; 

			-- local enemy var
			local enemy = script_follow.enemyObj;

			-- Run the combat script and retrieve combat script status if we have a valid target
			if (enemy ~= nil and enemy ~= 0) then
				script_follow.combatError = RunCombatScript(enemy:GetGUID());

				-- set combat conditions by class
				local class = UnitClass('player');

				-- no wand equipped then use melee - priest/warlock/mage
				if (enemy ~= nil) and (class == 'Priest' or class == 'Warlock' or class == 'mage')
					and (not localObj:HasRangedWeapon()) and (not enemy:HasDebuff("Frost Nova")) then

					-- move to melee distance
					if (enemy:GetDistance() > script_follow.meleeDistance)
						or (not enemy:IsInLineOfSight()) then
						local x, y, z = enemy:GetPosition();
						script_navEX:moveToTarget(localObj, x, y, z);
					return;
					end

				-- else if we are a melee class then move into range except druid
					-- special conditions set in driud combat script
				elseif (enemy ~= nil) and (not class == 'Druid') then

					-- move to melee distance
					if (enemy:GetDistance() > script_follow.meleeDistance)
						or (not enemy:IsInLineOfSight()) then
						local x, y, z = enemy:GetPosition();
						script_navEX:moveToTarget(localObj, x, y, z);
					return;
					end
				end
	

			
			if (enemy ~= nil or IsInCombat()) then

			-- get combat errors from combat scripts
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
					enemy = nil;
					ClearTarget();
					return;
				end
				-- Move in range: combat script return 3
				if (script_follow.combatError == 3) then
					script_follow.message = "Moving to target...";
					local _x, _y, _z = enemy:GetPosition();
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

		-- face enemy target
		if (IsInCombat()) then
			if (enemy ~= nil) then
				enemy:FaceTarget();
			end
		end
	end
	return false;
	end