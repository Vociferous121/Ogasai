script_warlockFollowerHeals = {
	
	timer = GetTimeEX(),
	waitTimer = GetTimeEX(),

}

function script_warlockFollowerHeals:HealsAndBuffs()

	local localMana = GetLocalPlayer():GetManaPercentage();
	local localHealth = GetLocalPlayer():GetHealthPercentage();

	if (not IsStanding()) then 
		StopMoving();
	end

	-- Wait out the wait-timer and/or casting or channeling
	if (waitTimer > GetTimeEX() or IsCasting() or IsChanneling()) then
		return;
	end

	-- set tick rate for scripts
	if (GetTimeEX() > timer) then
		timer = GetTimeEX() + script_follow.tickRate;

   		for i = 1, GetNumPartyMembers() do

			local partyMember = GetPartyMember(i);

			if (GetNumPartyMembers() > 0) then
				local partyMemberHP = partyMember:GetHealthPercentage();
				local partyMemberDistance = partyMember:GetDistance();
				leaderObj = GetPartyLeaderObject();
	
				if (HasSpell("Unending Breath")) and (script_warlock.useUnendingBreath) and (not partyMember:HasBuff("Unending Breath")) then
 					if (not partyMember:IsInLineOfSight() and partyMemberDistance() < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       			end
					if (CastSpellByName("Unending Breath", partyMember)) then
						return true;
					end
				end
			end
		end
	end
return false;
end