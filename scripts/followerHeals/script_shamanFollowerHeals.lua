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

                -- cure poison
                if (HasSpell("Cure Poison")) and (localMana > 20) then
                    if (partyMember:HasDebuff("Poison")) then
                        if (script_follow:moveInLineOfSight(partyMember)) then
                            return true;
                        end -- move to member
                        if (Cast("Cure Poison", partyMember)) then
                            self.waitTimer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                end

                -- cure disease
                if (HasSpell("Cure Disease")) and (localMana > 20) then
                    if (partyMember:HasDebuff("Disease")) then
                        if (script_follow:moveInLineOfSight(partyMember)) then
                            return true;
                        end -- move to member
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
                    if (HasSpell("Lesser Healing Wave")) and (partyMembersHP < self.lesserHealingWaveHealth) and (localMana > self.lesserHealingWaveMana) then
                        if (script_follow:moveInLineOfSight(partyMember)) then
                            return true;
                        end
                        if (CastSpellByName("Lesser Healing Wave", partyMember)) then
                            self.waitTimer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                end

                -- healing wave
                if (HasSpell("Healing Wave")) and (partyMembersHP < self.healingWaveHealth) and (localMana > self.healingWaveMana) then
                    if (script_follow:moveInLineOfSight(partyMember)) then
                        return true;
                    end
                    if (CastSpellByName("Healing Wave", partyMember)) then
                        self.waitTimer = GetTimeEX() + 1500;
                        return true;
                    end
                end

                -- chain heal
           --     if (self.useChainHeal) then
             --       if (HasSpell("Chain Heal")) and (partyMembersHP < self.chainHealHealth) and (localMana > self.chainHealMana) then
               --         if (script_follow:moveInLineOfSight(partyMember)) then
                 --           return true;
                   --     end
                     --   if (CastSpellByName("Chain Heal", partyMember)) then
                       --     self.waitTimer = GetTimeEX() + 1500;
               --             return true;
                 --       end
                   -- end
               -- end

                -- strength of earth totem
                if (self.useStrengthOfEarthTotem) and (not self.useStoneskinTotem) then
                    if (HasSpell("Strength of Earth Totem")) and (not partyMember:HasBuff("Strength of Earth")) and (partyMember:GetDistance() < 20) and (localMana > self.totemMana) then
                        if (script_follow:moveInLineOfSight(partyMember)) then
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
                        if (script_follow:moveInLineOfSight(partyMember)) then
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
                        if (script_follow:moveInLineOfSight(partyMember)) then
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
                        if (script_follow:moveInLineOfSight(partyMember)) then
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
                    if (script_follow:moveInLineOfSight(partyMember)) then
                        return true;
                    end
                    if (CastSpellByName("Mana Tide Totem")) then
                        self.waitTimer = GetTimeEX() + 1500;
                        return true;
                    end
                end
        end
    end
    return;
end