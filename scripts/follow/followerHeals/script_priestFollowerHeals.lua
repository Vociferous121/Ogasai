script_priestFollowerHeals = {

    	enableHeals = true,
    	renewMana = 25,
	partyRenewHealth = 85,
	shieldMana = 55,
	partyShieldHealth = 39,
	lesserHealMana = 5,
	partyLesserHealHealth = 80,
	healMana = 10,
	partyHealHealth = 60,
	greaterHealMana = 20,
	partyGreaterHealHealth = 28,
	flashHealMana = 7,
	partyFlashHealHealth = 54,
	clickRenew = true,
	clickShield = true,
	clickFlashHeal = true,
	clickGreaterHeal = true,
	clickHeal = true,
	waitTimer = GetTimeEX(),
	timer = GetTimeEX(),
    
}

function script_priestFollowerHeals:HealsAndBuffs()
	
	local localMana = GetLocalPlayer():GetManaPercentage();
	local localHealth = GetLocalPlayer():GetHealthPercentage();

	if (not IsStanding()) then 
		StopMoving();
	end

	local waitTimer = self.waitTimer
	local timer = self.timer;


	-- Wait out the wait-timer and/or casting or channeling
	if (waitTimer > GetTimeEX() or IsCasting() or IsChanneling()) then
		return;
	end

	-- set tick rate for scripts
	if (GetTimeEX() > timer) then
		timer = GetTimeEX() + script_follow.tickRate;

	for i = 1, GetNumPartyMembers()+1 do

		local partyMember = GetPartyMember(i);

		local localMana = GetLocalPlayer():GetManaPercentage();
		local localEnergy = GetLocalPlayer():GetEnergyPercentage();
		local partyMembersHP = partyMember:GetHealthPercentage();

		if (partyMembersHP > 0) then
			local partyMemberDistance = partyMember:GetDistance();
			local leaderObj = GetPartyMember(GetPartyLeaderIndex());
			local localHealth = GetLocalPlayer():GetHealthPercentage();
		end

		if (not partyMember:IsDead()) and (not IsCasting()) and (not IsChanneling()) then
                -- Dispel Magic
                if (HasSpell("Dispel Magic")) and (localMana > 20) and (GetNumPartyMembers() >= 1) then 
                    if (partyMember:HasDebuff("Sleep")) or (partyMember:HasDebuff("Druid's Slumber")) or (partyMember:HasDebuff("Terrify")) or (leaderObj:HasDebuff("Frost Nova")) or 
                    (partyMember:HasDebuff("Screams of the Past")) or (partyMember:HasDebuff("Wavering Will")) or (partyMember:HasDebuff("Slow")) or
                    (leaderObj:HasDebuff("Frostbolt")) or (partyMember:HasDebuff("Dominate Mind")) then
		local dispellRandom = random(1, 100);
				if (dispellRandom > 90) then
                       			if (CastHeal("Dispel Magic", partyMember)) then
                           			waitTimer = GetTimeEX() + 1500;
                           			return true;
                       			end
                   		end				
               		end
		end

		-- Cure Disease
		if (HasSpell("Cure Disease")) and (localMana > 75) and (GetNumPartyMembers() >= 1) then 
			if (partyMember:HasDebuff("Infected Wound")) then
					local cureRandom = random(1, 100);
				if (cureRandom > 90) then
					if (CastHeal("Cure Disease", partyMember)) then
						waitTimer = GetTimeEX() + 1500;
						return true;
					end
				end
			end
		end
                    
                -- Power word Fortitude
                if (HasSpell("Power Word: Fortitude")) and (localMana > 40) and (not partyMember:HasBuff("Power Word: Fortitude")) then -- buff
                    if (script_followMoveToMember:moveInLineOfSight(partyMember)) then
                        return true;
                    end -- move to member
                    if (Cast("Power Word: Fortitude", partyMember)) then
                                waitTimer = GetTimeEX() + 1500;
                        return true;
                    end
                end	

                -- Divine Spirit
                if (HasSpell("Divine Spirit")) and (localMana > 30) and (not partyMember:HasBuff("Divine Spirit")) then
                    if (script_followMoveToMember:moveInLineOfSight(partyMember)) then
                        return true;
                    end -- move to member
                    if (Cast("Divine Spirit", partyMember)) then
                            waitTimer = GetTimeEX() + 1500;
                        return true;
                    end	
                end

                -- Inner Fire
                if (HasSpell("Inner Fire")) and (localMana > 30) and (not localObj:HasBuff("Inner Fire")) then
                    if (Buff("Inner Fire", localObj)) then
                        waitTimer = GetTimeEX() + 1500;
                        return true;
                    end
                end

                -- priest fear
                if (script_followEX2:enemiesAttackingUs(5) > 3) and (HasSpell("Psychic Scream")) then
                    if (CastSpellByName("Psychic Scream")) then
                        return true;
                    end
                end

                -- inner focus
                if (HasSpell("Inner Focus")) and (not IsSpellOnCD("Inner Focus")) then
                    if (localMana < self.flashHealMana and leaderObj:GetHealthPercentage() < self.partyFlashHealHealth) then
                        if (Buff("Inner Focus", localObj)) then 
                            waitTimer = GetTimeEX() + 1400;
                            return true; 
                        end
                        if (CastHeal("Flash Heal", partyMember)) then
                            waitTimer = GetTimeEX() + 1600;
                            return true;
                        end
                    end
                end
                
                -- Power Infusion
                if (HasSpell("Power Infusion")) and (not IsSpellOnCD("Power Infusion")) then
                    if (partyMembersHP< 50) or (script_priest:enemiesAttackingUs(8) > 1) then
                            if (Buff("Power Infusion")) then
                            waitTimer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                end

            if (self.enableHeals) then

                -- flash heal 
                if (self.clickFlashHeal) then
                    if (localMana > self.flashHealMana) and (partyMembersHP < self.partyFlashHealHealth) then
                        if (script_followMoveToMember:moveInLineOfSight(partyMember)) then
                            return true;
                        end -- move to member
                        if (CastHeal("Flash Heal", partyMember)) then
                            waitTimer = GetTimeEX() + 2000;
				return true;
                        end
                    end
                end

                -- Greater Heal
                if (self.clickGreaterHeal) then
                    if (localMana > self.greaterHealMana) and (partyMembersHP < self.partyGreaterHealHealth) and (HasSpell("Greater Heal")) then
                        if (script_followMoveToMember:moveInLineOfSight(partyMember)) then
                            return true;
                        end -- move to member
                        if (CastHeal("Greater Heal", partyMember)) then
                            waitTimer = GetTimeEX() + 2000;
                            return true;
                        end
                    end
                end

                -- Heal
                if (self.clickHeal) then
                    if (localMana > self.healMana) and (partyMembersHP < self.partyHealHealth) and (HasSpell("Heal")) then
                        if (script_followMoveToMember:moveInLineOfSight(partyMember)) then
                            return true;
                        end -- move to member
                        if (CastHeal("Heal", partyMember)) then
                            waitTimer = GetTimeEX() + 3200;
                            return true;
                        end
                    end
                end

                -- Lesser Heal
                    -- level 20+ at very low mana
                if (localObj:GetLevel() >= 20) then
                    if (localMana <= 8) and (partyMembersHP <= 20) then
                        if (script_followMoveToMember:moveInLineOfSight(partyMember)) then
                            return true;
                        end -- move to member	
                        if (CastHeal("Lesser Heal", partyMember)) then
                            waitTimer = GetTimeEX() + 2000;
                        end
                    end
                    -- below level 20 cast lesser heal
                elseif (localObj:GetLevel() <= 20) then
                    if (localMana > self.lesserHealMana) and (partyMembersHP < self.partyLesserHealHealth) and (HasSpell("Lesser Heal")) then
                        if (script_followMoveToMember:moveInLineOfSight(partyMember)) then
                            return true;
                        end -- move to member
                        if (CastHeal("Lesser Heal", partyMember)) then
                            waitTimer = GetTimeEX() + 2000;
                            return true;
                        end
                    end
                end

                -- Renew
                if (self.clickRenew) then
                    if (localMana > self.renewMana) and (partyMembersHP < self.partyRenewHealth) and (not partyMember:HasBuff("Renew")) and (HasSpell("Renew")) then
                        if (script_followMoveToMember:moveInLineOfSight(partyMember)) then
                            return true;
                        end -- move to member
                        if (CastHeal("Renew", partyMember)) then
                            waitTimer = GetTimeEX() + 1650;
                            return true;
                        end
                    end
                end

                -- Shield
                if (self.clickShield) then
                    if (localMana > self.shieldMana) and (partyMembersHP < self.partyShieldHealth) and (not partyMember:HasDebuff("Weakened Soul")) and (HasSpell("Power Word: Shield")) then
                        if (script_followMoveToMember:moveInLineOfSight(partyMember)) then
                            return true;
                        end -- move to member
                        if (CastHeal("Power Word: Shield", partyMember)) then 
                            waitTimer = GetTimeEX() + 1550;
                            return true; 
                        end
                    end
                end
        end
    end
end
end
return false;
end