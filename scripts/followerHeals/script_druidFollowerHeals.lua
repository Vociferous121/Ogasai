script_druidFollowerHeals = {

    enableHeals = true;
    healingTouchMana = 35,
	regrowthMana = 25, 
   	rejuvenationMana = 15,
	healingTouchHealth = 35,
   	regrowthHealth = 60,
   	rejuvenationHealth = 75,
	clickHealingTouch = true,
	clickRegrowth = true,

}
function script_druidFollowerHeals:HealsAndBuffs()

    local localMana = GetLocalPlayer():GetManaPercentage();
	if (not IsStanding()) then 
		StopMoving();
	end
	-- Heals and buffs
	for i = 1, GetNumPartyMembers()+1 do
		local partyMember = GetPartyMember(i);
		if (i == GetNumPartyMembers()+1) then
			partyMember = GetLocalPlayer();
		end
		local partyMembersHP = partyMember:GetHealthPercentage();
		if (partyMembersHP > 0 and partyMembersHP < 99 and localMana > 1) then
			local partyMemberDistance = partyMember:GetDistance();
			leaderObj = GetPartyMember(GetPartyLeaderIndex());
			local localHealth = GetLocalPlayer():GetHealthPercentage();					

			-- Move in range: combat script return 3
			if (script_follow.combatError == 3) then
				script_follow.message = "Moving to target...";
				script_follow:moveInLineOfSight(partyMember);		
				return;
			end
			
			-- Move in line of sight and in range of the party member
			if (script_follow:moveInLineOfSight(partyMember)) then
				return true; 
			end

            -- druid buffs
            if (class == 'Druid') then

                -- druid swiftmend
                if (HasSpell("Swiftmend")) and (not IsSpellOnCD("Swiftmend")) then
                    if (partyMember:HasBuff("Regrowth")) or (partyMember:HasBuff("Rejuvenation")) then
                        if (partyMembersHP < 30) then
                            if (CastHeal("Swiftmend", partyMember)) then
                                return true;
                            end
                        end
                    end
                end
                
                -- natures swiftness
                if (HasSpell("Nature's Swiftness")) and (not localObj:HasBuff("Nature's Swiftness")) and (leaderObj:GetHealthPercentage() < 30) then
                    if (not IsSpellOnCD("Nature's Swiftness")) and (localMana > 10) then
                        if (script_follow:moveInLineOfSight(partyMember)) then
                            return true;
                        end -- move to member
                        if (CastSpellByName("Nature's Swiftness", localObj)) then
                            self.waitTimer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                end
            end

            -- druid heals
            if (class == ('Druid')) and (self.enableHeals) then

                -- regrowth
                if (self.clickRegrowth) then
                    if (HasSpell("Regrowth")) and (not partyMember:HasBuff("Regrowth")) and (partyMembersHP < self.regrowthHealth) and (localMana > self.regrowthMana) then
                        if (script_follow:moveInLineOfSight(partyMember)) then
                            return true;
                        end -- move to member
                        if (CastSpellByName("Regrowth")) then
                            self.waitTimer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                end

                -- rejuvenation
                if (HasSpell("Rejuvenation")) and (not partyMember:HasBuff("Rejuvenation")) and (partyMembersHP < self.rejuvenationHealth) and (localMana > self.rejuvenationMana) then
                    if (script_follow:moveInLineOfSight(partyMember)) then
                                return true;
                    end -- move to member
                    if (CastSpellByName("Rejuvenation")) then
                        self.waitTimer = GetTimeEX() + 1500;
                        return true;
                    end
                end

                -- healing touch if has regrowth
                if (self.clickHealingTouch) then
                    if (HasSpell("Healing Touch")) and (partyMember:HasBuff("Regrowth")) and (partyMembersHP < self.healingTouchHealth) and (localMana > self.healingTouchMana) then
                        if (script_follow:moveInLineOfSight(partyMember)) then
                            return true;
                        end -- move to member
                        if (CastSpellByName("Healing Touch")) then
                            self.waitTimer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                end
            end
        end
    end
    return;
end