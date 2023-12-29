script_shamanFollowerHeals = {

	enableHeals = true,
	lesserHealingWaveHealth = 30,
	lesserHealingWaveMana = 30,
	healingWaveHealth = 60,
	healingWaveMana = 20,
	chainHealHealth = 45,
	chainHealMana = 60,
	useStrengthOfEarthTotem = true,
	useStoneskinTotem = false,
	useHealingStreamTotem = false,
	useManaSpringTotem = true,
	useLesserHealingWave = true,
	useChainHeal = true,

}

function script_shamanFollowerHeals:HealsAndBuffs()

	if (not IsStanding()) then 
		StopMoving();
	end

		local localMana = GetLocalPlayer():GetManaPercentage();
		local localHealth = GetLocalPlayer():GetHealthPercentage();

	for i = 1, GetNumPartyMembers() do
		
		if (GetNumPartyMembers() > 0) then
			local partyMember = GetPartyMember(i);
			local partyMemberHP = partyMember:GetHealthPercentage();
			local px, py, pz = GetPartyMember(i):GetPosition();

	
                	-- cure poison
                	if (HasSpell("Cure Poison")) and (localMana > 20) then
                	    if (partyMember:HasDebuff("Poison")) then
                	      if (not partyMember:IsInLineOfSight() and partyMemberDistance() < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       			end
                	        if (Cast("Cure Poison", partyMember)) then
                	            self.waitTimer = GetTimeEX() + 1500;
                	            return true;
                	        end
                	    end
                	end
	
	                -- cure disease
	                if (HasSpell("Cure Disease")) and (localMana > 20) then
	                    if (partyMember:HasDebuff("Disease")) then
	                       if (not partyMember:IsInLineOfSight() and partyMemberDistance() < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       			end
	                        if (Cast("Cure Disease", partyMember)) then
	                            self.waitTimer = GetTimeEX() + 1500;
		                            return true;
		                        end
	                    end	
	                end
	
	            -- shaman heals
	            if (self.enableHeals) then
	
	                -- lesser healing wave
	                if (self.useLesserHealingWave) then
	                    if (HasSpell("Lesser Healing Wave")) and (partyMemberHP < self.lesserHealingWaveHealth) and (localMana > self.lesserHealingWaveMana) then
                       if (not partyMember:IsInLineOfSight() and partyMemberDistance() < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       			end
                        if (CastSpellByName("Lesser Healing Wave", partyMember)) then
                            self.waitTimer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                end

                -- healing wave
                if (HasSpell("Healing Wave")) and (partyMemberHP < self.healingWaveHealth) and (localMana > self.healingWaveMana) then
                   if (not partyMember:IsInLineOfSight() and partyMemberDistance() < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       			end
                    if (CastSpellByName("Healing Wave", partyMember)) then
                        self.waitTimer = GetTimeEX() + 1500;
                        return true;
                    end
                end

                -- strength of earth totem
                if (self.useStrengthOfEarthTotem) and (not self.useStoneskinTotem) then
                    if (HasSpell("Strength of Earth Totem")) and (not partyMember:HasBuff("Strength of Earth")) and (partyMember:GetDistance() < 20) and (localMana > self.totemMana) then
                        if (not partyMember:IsInLineOfSight() and partyMemberDistance() < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       			end
                        if (CastSpellByName("Strength of Earth Totem")) then
                            self.waitTimer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                    if (HasSpell("Windfury Totem")) then
                        if (CastSpellByName("Windfury Totem")) then
                            self.waitTimer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                end

                -- stoneskin totem
                if (not self.useStrengthOfEarthTotem) and (self.useStoneskinTotem) then
                    if (HasSpell("Stoneskin Totem")) and (not partyMember:HasBuff("Stoneskin")) and (partyMember:GetDistance() < 20) and (localMana > self.totemMana) then
                         if (not partyMember:IsInLineOfSight() and partyMemberDistance() < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       			end
                        if (CastSpellByName("Strength of Earth Totem")) then
                            self.waitTimer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                    if (HasSpell("Windfury Totem")) then
                        if (CastSpellByName("Windfury Totem")) then
                            self.waitTimer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                end

                -- healing stream totem
                if (self.useHealingStreamTotem) and (not self.useManaSpringTotem) and (not localObj:HasBuff("Mana Tide")) then
                    if (HasSpell("Healing Stream Totem")) and (not partyMember:HasBuff("Healing Stream")) and (partyMember:GetDistance() < 20) and (localMana > self.totemMana) then
                        if (not partyMember:IsInLineOfSight() and partyMemberDistance() < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       			end
                        if (CastSpellByName("Healing Stream Totem")) then
                            self.waitTimer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                end

                -- mana spring totem
                if (not self.useHealingStreamTotem) and (self.useManaSpringTotem) and (not localObj:HasBuff("Mana Tide")) then
                    if (HasSpell("Mana Spring Totem")) and (not partyMember:HasBuff("Mana Spring")) and (partyMember:GetDistance() < 20) and (localMana > self.totemMana) then
                        if (not partyMember:IsInLineOfSight() and partyMemberDistance() < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       			end
                        if (CastSpellByName("Mana Spring Totem")) then
                            self.waitTimer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                end

                -- mana tide totem
                if (HasSpell("Mana Tide Totem")) and (not partyMember:HasBuff("Mana Tide")) and (partyMember:GetDistance() < 20) and (localMana < self.useManaTideTotem) then
                     if (not partyMember:IsInLineOfSight() and partyMemberDistance() < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       			end
                    if (CastSpellByName("Mana Tide Totem")) then
                        self.waitTimer = GetTimeEX() + 1500;
                        return true;
                    end
                end
	    end
        end
    end
    return false;
end