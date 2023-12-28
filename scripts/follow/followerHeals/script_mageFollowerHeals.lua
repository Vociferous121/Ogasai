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

	if(GetTimeEX() > self.timer) then
		self.timer = GetTimeEX() + script_follow.tickRate;


	for i = 1, GetNumPartyMembers()+1 do

			local partyMember = GetPartyMember(i);

		if (i == GetNumPartyMembers()+1) then
			partyMember = GetLocalPlayer();
		end

			local localMana = GetLocalPlayer():GetManaPercentage();
			local localEnergy = GetLocalPlayer():GetEnergyPercentage();
			local partyMemberHP = partyMember:GetHealthPercentage();

		if (partyMemberHP > 0) and (localMana > 1 or localEnergy > 1) then
				local partyMemberDistance = partyMember:GetDistance();
				leaderObj = GetPartyMember(GetPartyLeaderIndex());
				local localHealth = GetLocalPlayer():GetHealthPercentage();
		end

		-- Move in range: combat script return 3
		if (script_follow.combatError == 3) then
			script_follow.message = "Moving to target...";
			script_followMove:moveInLineOfSight(partyMember);		
		return;
		end
			
		-- Move in line of sight and in range of the party member
		if (partyMember:GetDistance() > 40) or (not partyMember:IsInLineOfSight()) then
			if (script_followMove:moveInLineOfSight()) then
			return true; 
			end
		end

		-- Arcane Intellect
		if (HasSpell("Arcane Intellect")) and (localMana > 40) and (not partyMember:HasBuff("Arcane Intellect")) and (not partyMember:IsDead()) and (partyMemberHP > 5) then
			if (script_followMove:moveInLineOfSight()) then
				return true;
			end
			if (Buff("Arcane Intellect", partyMember)) then
				self.waitTimer = GetTimeEX() + 1500;
				return true;
			end
		end

		-- dampen magic
		if (HasSpell("Dampen Magic")) and (script_mage.useDampenMage) and (localMana >= 40) and (not partyMember:IsDead()) and (partyMemberHP > 5) then
			if (script_followMove:moveInLineOfSight()) then
				return true;
			end
			if (Buff("Dampen Magic", partyMember)) then
				self.waitTimer = GetTimeEX() + 1500;
				return true;
			end
		end
	end
	end
return false;
end