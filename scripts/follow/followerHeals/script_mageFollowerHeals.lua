script_mageFollowerHeals = {

	timer = GetTimeEX(),
	waitTimer = GetTimeEX(),

}

function script_mageFollowerHeals:HealsAndBuffs()

	if (not IsStanding()) then 
		StopMoving();
	end

	-- Wait out the wait-timer and/or casting or channeling
	if (self.waitTimer > GetTimeEX() or IsCasting() or IsChanneling()) then
		return;
	end

	-- set wait timer for spells and global cooldown
	if(GetTimeEX() > self.timer) then
		self.timer = GetTimeEX() + script_follow.tickRate;

		local localHealth = GetLocalPlayer():GetHealthPercentage();
		local localMana = GetLocalPlayer():GetManaPercentage();

		-- get party members
		for i = 1, GetNumPartyMembers() do

			if (GetNumPartyMembers() > 0) then
				local partyMember = GetPartyMember(i);
				local partyMemberHP = partyMember:GetHealthPercentage();
				local partyMemberDistance = partyMember:GetDistance();
				leaderObj = GetPartyLeaderObject();
				local px, py, pz = GetPartyMember(i):GetPosition();

				-- Move in line of sight and in range of the party member
				if (partyMember:GetDistance() > 40) or (not partyMember:IsInLineOfSight()) then
					script_followMoveToTarget:moveToTarget(localObj, px, py, pz);
					return true;
				end

				-- Arcane Intellect
				if (HasSpell("Arcane Intellect")) and (localMana > 40) and (not partyMember:HasBuff("Arcane Intellect")) and (not partyMember:IsDead()) and (partyMemberHP > 5) then
					if (not partyMember:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
						return true;
					end
					if (Buff("Arcane Intellect", partyMember)) then
						self.waitTimer = GetTimeEX() + 1500;
						return true;
					end
				end
		
				-- dampen magic
				if (HasSpell("Dampen Magic")) and (not partyMember:HasBuff("Dampen Magic")) and (script_mage.useDampenMage) and (localMana >= 40) and (not partyMember:IsDead()) and (partyMemberHP > 5) then
					if (not partyMember:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
						return true;
					end
					if (Buff("Dampen Magic", partyMember)) then
						self.waitTimer = GetTimeEX() + 1500;
						return true;
					end
				end
			end -- end getnumpartymembers
		end -- end for loop
	end -- wait timer
return false;
end -- end function