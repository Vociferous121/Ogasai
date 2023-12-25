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
	timer = GetTimeEX(),

}

function script_paladinFollowerHeals:HealsAndBuffs()

	if (not IsStanding()) then 
		StopMoving();
	end
	if(GetTimeEX() > self.timer) then
		self.timer = GetTimeEX() + script_follow.tickRate;

	for i = 1, GetNumPartyMembers()+1 do

			local member = GetPartyMember(i);

			local localMana = GetLocalPlayer():GetManaPercentage();
			local localEnergy = GetLocalPlayer():GetEnergyPercentage();
			local memberHP = member:GetHealthPercentage();

		if (memberHP > 0) then
			local memberDistance = member:GetDistance();
			local leaderObj = GetPartyMember(GetPartyLeaderIndex());
			local localHealth = GetLocalPlayer():GetHealthPercentage();
		end

		-- Move in range: combat script return 3
		if (script_follow.combatError == 3) then
			script_follow.message = "Moving to target...";
			script_follow:moveInLineOfSight(member);		
		return;
		end
			
		-- Move in line of sight and in range of the party member
		if (member:GetDistance() > 40) or (not member:IsInLineOfSight()) then
			if (script_follow:moveInLineOfSight(member)) then
			return true; 
			end
		end

                -- Cure Disease
                if (HasSpell("Cure Disease")) and (localMana > 10) then
                    if (member:HasDebuff("Infected Wound")) then
                        if (CastHeal("Cure Disease", member)) then
                            self.timer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                end

                -- purify
                if (HasSpell("Purify")) and (localMana > 10) then
                    if (member:HasDebuff("Irradiated")) or (member:HasDebuff("Infected Wound")) then
                        if (CastHeal("Purify", member)) then
                            self.timer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                end

                -- blessing of might
                if (not member:HasBuff("Strength of Earth")) and (not member:HasBuff("Mana Spring")) then
                    if (not member:HasBuff("Blessing of Wisdom")) and (not member:HasBuff("Blessing of Might")) then
                        if (member:GetRagePercentage() > 1) or (member:GetEnergyPercentage() > 1) or (member:HasBuff("Bear Form") or member:HasBuff("Cat Form")) and (not member:GetManaPercentage() > 1) then
                            if (script_follow:moveInLineOfSight(member)) then
                                return true;
                            end -- move to member
                            if (Buff("Blessing of Might", member)) then
                                        self.timer = GetTimeEX() + 1500;
                                return true;	
                            end
                        end
                    end
                end

                -- blessing of wisdom
                if (member:GetManaPercentage() > 1) and (HasSpell("Blessing of Wisdom")) and (not member:HasBuff("Blessing of Wisdom")) and (not member:HasBuff("Blessing of Might")) and (not member:HasBuff("Mana Spring")) then
                    if (not member:GetRagePercentage() > 1) and (not member:GetEnergyPercentage() > 1) then
                        if (script_follow:moveInLineOfSight(member)) then
                            return true;
                        end -- move to member
                        if (Buff("Blessing of Wisdom", member)) then
                            self.timer = GetTimeEX() + 1500;
                            return true;
                        end
                    end
                end

                -- Blessing of Protection
                if (localMana > 5) and (memberHP < self.bopHealth) and (HasSpell("Blessing of Protection")) then
                    if (script_follow:moveInLineOfSight(member)) then
                        return true;
                    end -- move to member
                    if (Cast("Blessing of Protection", member)) then
                        self.timer = GetTimeEX() + 1500;
                        return true;
                    end
                end

		-- paladin heals
		if (self.enableHeals) then

			-- Lay on Hands
                	if (localMana < 25) and (memberHP < self.layOnHandsHealth) and (HasSpell("Lay on Hands")) then
				if (script_follow:moveInLineOfSight(member)) then
					return true;
				end
				if (CastHeal("Lay on Hands", member)) then
                        		self.timer = GetTimeEX() + 1500;
                        		return true;
				end
			end

                	-- holy light party leader
                	leaderHealth = leaderObj:GetHealthPercentage();
                	if leaderHealth < 40 and HasSpell("Holy Light") then
                	    CastHeal("Holy Light", leaderObj);
                	    self.timer = GetTimeEX() + 3000;
                	    return true;
                	else

                	-- Holy Light
                	if (localMana > self.holyLightMana) and (memberHP < self.partyHolyLightHealth) and (HasSpell("Holy Light")) then
                	    if (script_follow:moveInLineOfSight(member)) then
                	        return true;
                	    end -- move to member
                	    if (CastHeal("Holy Light", member)) then
                	        self.timer = GetTimeEX() + 3000;
                	        return true;
                	    end
                	end
			end

                	-- Flash Of Light
                	if (localMana > self.flashOfLightMana) and (memberHP < self.partyFlashOfLightHealth) and (HasSpell("Flash of Light")) then
                 	   if (script_follow:moveInLineOfSight(member)) then
                 	       return true;
                 	   end -- move to member
                 	   if (CastHeal("Flash of Light", member)) then
                 	       return true;
                 	   end
			end       
		end 
	end
	end
    return;
end   