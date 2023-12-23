script_druidFollowerHeals = {

    	enableHeals = true,
    	healingTouchMana = 35,
	regrowthMana = 25, 
   	rejuvenationMana = 15,
	healingTouchHealth = 35,
   	regrowthHealth = 60,
   	rejuvenationHealth = 75,
	clickHealingTouch = true,
	clickRegrowth = true,
	swiftMendHealth = 40,
	timer = GetTimeEX(),

}

function script_druidFollowerHeals:HealsAndBuffs()

	if (not IsStanding()) then 
		StopMoving();
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
			script_follow:moveInLineOfSight(partyMember);		
		return;
		end
			
		-- Move in line of sight and in range of the party member
		if (partyMember:GetDistance() > 40) or (not partyMember:IsInLineOfSight()) then
			if (script_follow:moveInLineOfSight(partyMember)) then
			return true; 
			end
		end
	
          	-- druid heals
          	if (self.enableHeals) then

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
                	         		self.timer = GetTimeEX() + 1500;
                	         	  	return true;
                	        	end
                	    	end
                	end

                	-- regrowth
                	if (self.clickRegrowth) then
                		if (HasSpell("Regrowth")) and (not partyMember:HasBuff("Regrowth")) and (partyMembersHP < self.regrowthHealth) and (localMana > self.regrowthMana) then
                       			if (script_follow:moveInLineOfSight(partyMember)) then
                        	    		return true;
                        		end -- move to member
                        		if (CastSpellByName("Regrowth")) then
                        		    self.timer = GetTimeEX() + 1500;
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
                	        	self.timer = GetTimeEX() + 1500;
                	        	return true;
                	    	end
                	end

                	-- healing touch if has regrowth
			if (self.clickHealingTouch) then
				if (HasSpell("Healing Touch")) and (partyMember:HasBuff("Regrowth")) and (partyMembersHP < self.healingTouchHealth) and (localMana > self.healingTouchMana) then
					if (script_follow:moveInLineOfSight(partyMember)) then
                	        	    return true;
					end -- move to member
                	       		if (CastSpellByName("Healing Touch", partyMember)) then
                	        	    self.timer = GetTimeEX() + 1500;
                       		 	    return true;
                        		end
				end
			end
		end
	end
	end	
    return true;
end