script_paladinFollowerHeals = {

    enableHeals = true,
    holyLightMana = 20,
	partyHolyLightHealth = 60,
	flashOfLightMana = 3,
	partyFlashOfLightHealth = 80,
	layOnHandsHealth = 6,
	bopHealth = 10,
	clickFlashOfLight = true,
	clickHolyLight = true,

}

function script_paladinFollowerHeals:HealsAndBuffs()

	if (not IsStanding()) then 
		StopMoving();
	end
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
			script_follow:moveInLineOfSight(partyMember);		
		return;
		end
			
		-- Move in line of sight and in range of the party member
		if (partyMember:GetDistance() > 40) or (not partyMember:IsInLineOfSight()) then
			if (script_follow:moveInLineOfSight(partyMember)) then
			return true; 
			end
		end

                -- Cure Disease
                if (HasSpell("Cure Disease")) and (localMana > 10) then
                    if (partyMember:HasDebuff("Infected Wound")) then
                        if (CastHeal("Cure Disease", partyMember)) then
                            self.waitTimer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                end

                -- purify
                if (HasSpell("Purify")) and (localMana > 10) then
                    if (partyMember:HasDebuff("Irradiated")) or (partyMember:HasDebuff("Infected Wound")) then
                        if (CastHeal("Purify", partyMember)) then
                            self.waitTimer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                end

                -- blessing of might
                if (not partyMember:HasBuff("Strength of Earth")) and (not partyMember:HasBuff("Mana Spring")) then
                    if (not partyMember:HasBuff("Blessing of Wisdom")) and (not partyMember:HasBuff("Blessing of Might")) then
                        if (partyMember:GetRagePercentage() > 1) or (partyMember:GetEnergyPercentage() > 1) or (partyMember:HasBuff("Bear Form") or partyMember:HasBuff("Cat Form")) and (not partyMember:GetManaPercentage() > 1) then
                            if (script_follow:moveInLineOfSight(partyMember)) then
                                return true;
                            end -- move to member
                            if (Buff("Blessing of Might", partyMember)) then
                                        self.waitTimer = GetTimeEX() + 1500;
                                return true;	
                            end
                        end
                    end
                end

                -- blessing of wisdom
                if (partyMember:GetManaPercentage() > 1) and (HasSpell("Blessing of Wisdom")) and (not partyMember:HasBuff("Blessing of Wisdom")) and (not partyMember:HasBuff("Blessing of Might")) and (not partyMember:HasBuff("Mana Spring")) then
                    if (not partyMember:GetRagePercentage() > 1) and (not partyMember:GetEnergyPercentage() > 1) then
                        if (script_follow:moveInLineOfSight(partyMember)) then
                            return true;
                        end -- move to member
                        if (Buff("Blessing of Wisdom", partyMember)) then
                            self.waitTimer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                end

                -- Blessing of Protection
                if (localMana > 5) and (partyMembersHP < self.bopHealth) and (HasSpell("Blessing of Protection")) then
                    if (script_follow:moveInLineOfSight(partyMember)) then
                        return true;
                    end -- move to member
                    if (Cast("Blessing of Protection", partyMember)) then
                        self.waitTimer = GetTimeEX() + 1500;
                        return true;
                    end
                end

		-- paladin heals
		if (self.enableHeals) then

			-- Lay on Hands
                	if (localMana < 25) and (partyMembersHP < self.layOnHandsHealth) and (HasSpell("Lay on Hands")) then
				if (script_follow:moveInLineOfSight(partyMember)) then
					return true;
				end
				if (CastHeal("Lay on Hands", partyMember)) then
                        		self.waitTimer = GetTimeEX() + 1500;
                        		return true;
				end
			end

                	-- holy light party leader
                	leaderHealth = GetPartyMember(GetPartyLeaderIndex()):GetHealthPercentage();
                	if leaderHealth < 40 and HasSpell("Holy Light") then
                	    CastHeal("Holy Light", leaderObj);
                	    self.waitTimer = GetTimeEX() + 2000;
                	    return true;
                	end

                	-- Holy Light
                	if (localMana > self.holyLightMana) and (partyMembersHP < self.partyHolyLightHealth) and (HasSpell("Holy Light")) then
                	    if (script_follow:moveInLineOfSight(partyMember)) then
                	        return true;
                	    end -- move to member
                	    if (CastHeal("Holy Light", partyMember)) then
                	        self.waitTimer = GetTimeEX() + 2700;
                	        return true;
                	    end
                	end

                	-- Flash Of Light
                	if (localMana > self.flashOfLightMana) and (partyMembersHP < self.partyFlashOfLightHealth) and (HasSpell("Flash of Light")) then
                 	   if (script_follow:moveInLineOfSight(partyMember)) then
                 	       return true;
                 	   end -- move to member
                 	   if (CastHeal("Flash of Light", partyMember)) then
                 	       return true;
                 	   end
			end       
		end 
	end
    return;
end   