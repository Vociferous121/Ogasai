-- place a bunch of unused or not needed functions here
	-- or written functions and these are the old ones


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

