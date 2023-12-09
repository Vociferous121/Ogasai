script_cleanedUpFunctions = {

}


-- new function in combat check range of other targets and move away before aggro range
	--while i=0 do
	--	if targettype is 3 and not dead and can attack and etc etc.. then
	--		if target is not my target and target is not targeting me	
	--			check distance of targets in range
	--				if target not targeting me is too close then
	--					new function navEX move away from enemy about 5 yards
	--					check unstuck feature to get angle to move
	--						recheck enemies range	
	--							return true or false
	-- 		



------------------------------------------------------------------------

		--if (script_grind:getTargetAttackingUs() == nil) then
			--if (GetLocalPlayer():HasBuff('Bloodrage')) then
			--	script_grind.message = "Waiting for bloodrage to fade...";
			--	return true;
			--end
		--	if (not IsInCombat() and self.avoidBlacklisted) then
		--		if (script_aggro:avoidBlacklistedTargets()) then
		--			script_grind.message = "Avoiding blacklisted targets...";
		--			return true;
		--		end
		--	end
		--	local groupMana = 0;
		--	local manaUsers = 0;
		--	for i = 1, GetNumPartyMembers() do
		--		local partyMember = GetPartyMember(i);
		--		if (partyMember:GetManaPercentage() > 0) then
		--			groupMana = groupMana + partyMember:GetManaPercentage();
		--			manaUsers = manaUsers + 1;
		--		end
		--	end
			--	if (partyMember:GetDistance() > 100 and not IsInCombat()) then
			--		if (IsMoving()) then StopMoving(); end
			--		script_grind.message = 'Waiting for group members...';
			--		ClearTarget();
			--		return true;
			--	end
			--end
			--if (groupMana/manaUsers < 25 and GetNumPartyMembers() >= 1 and not IsInCombat()) then
			--	if (IsMoving()) then
			--		StopMoving();
			--	end
			--	script_grind.message = 'Waiting for group to regen mana (25%+)...';
			--	ClearTarget();
			--	return true;
			--end
		--end


-------------------------------------

--function script_grind:mountUp()
--	local __, lastError = GetLastError();
--	if (lastError ~= 75 and self.mountTimer < GetTimeEX() and self.useMount) then
--		if(script_grind.useMount and not IsSwimming() and not IsIndoors() and not IsMounted()) then
--			self.message = "Mounting...";
--			if (not IsStanding()) then
--				StopMoving();
--			end
--			if (script_helper:useMount() and self.useMount) then
--				self.waitTimer = GetTimeEX() + 8000;
--				return true;
--			end
--		end
--	else
--		ClearLastError();
--		self.mountTimer = GetTimeEX() + 7000;
--		return false;
--	end
--end


--------------------------------------------------------

function script_grind:isTargetingGroup(y) 
	--for i = 1, GetNumPartyMembers() do
	--	local partyMember = GetPartyMember(i);
	--	if (partyMember ~= nil and partyMember ~= 0 and not partyMember:IsDead()) then
	--		if (y:GetUnitsTarget() ~= nil and y:GetUnitsTarget() ~= 0 and not script_grind:isTargetingPet(y)) then
	--			return y:GetUnitsTarget():GetGUID() == partyMember:GetGUID();
	--		end
	--	end
	--end

	return false;
end

