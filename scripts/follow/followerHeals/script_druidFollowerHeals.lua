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

	local localObj = GetLocalPlayer();
	local localMana = localObj:GetManaPercentage();

	if (not IsStanding()) then 
		StopMoving();
	end

	if(GetTimeEX() > self.timer) then
		self.timer = GetTimeEX() + script_follow.tickRate;


	for i = 1, GetNumPartyMembers() do

		local partyMember = GetPartyMember(i);
		local localMana = GetLocalPlayer():GetManaPercentage();
		local localEnergy = GetLocalPlayer():GetEnergyPercentage();
		local partyMemberHP = partyMember:GetHealthPercentage();

		if (partyMemberHP > 0) then
				local partyMemberDistance = partyMember:GetDistance();
				leaderObj = GetPartyMember(GetPartyLeaderIndex());
				local localHealth = GetLocalPlayer():GetHealthPercentage();
		end
	
          	-- druid heals
          	if (self.enableHeals) and (partyMember:GetGUID() ~= localObj:GetGUID()) and (partyMemberHP > 4) then

			if (HasSpell("Mark of the Wild")) and (not IsSpellOnCD("Mark of the Wild")) then
				if (not partyMember:HasBuff("Mark of the Wild")) and (localMana >= 30) then
					if (Cast("Mark of the Wild", partyMember)) then
						return true;
					end
				end
			end

               		-- druid swiftmend
                	if (HasSpell("Swiftmend")) and (not IsSpellOnCD("Swiftmend")) then
                		if (partyMember:HasBuff("Regrowth")) or (partyMember:HasBuff("Rejuvenation")) then
					if (partyMemberHP < 30) then
                            			if (CastHeal("Swiftmend", partyMember)) then
                               				return true;
                         	 		end
                      			end
                		end
               		end
                
                	-- natures swiftness
                	if (HasSpell("Nature's Swiftness")) and (not localObj:HasBuff("Nature's Swiftness")) and (leaderObj:GetHealthPercentage() < 30) then
                		if (not IsSpellOnCD("Nature's Swiftness")) and (localMana > 10) then
                	        	if (script_followMoveToMember:moveInLineOfSight(partyMember)) then
                	        	    return true;
                	        	end -- move to member
                	        	if (Cast("Nature's Swiftness", localObj)) then
                	         		self.timer = GetTimeEX() + 1500;
                	         	  	return true;
                	        	end
                	    	end
                	end

                	-- regrowth
                	if (self.clickRegrowth) then
                		if (HasSpell("Regrowth")) and (not partyMember:HasBuff("Regrowth")) and (partyMemberHP < self.regrowthHealth) and (localMana > self.regrowthMana) then
                       			if (script_followMoveToMember:moveInLineOfSight(partyMember)) then
                        	    		return true;
                        		end -- move to member
                        		if (Cast("Regrowth", partyMember)) then
                        		    self.timer = GetTimeEX() + 1500;
                        		    return true;
                        		end
                    		end
                	end

                	-- rejuvenation
                	if (HasSpell("Rejuvenation")) and (not partyMember:HasBuff("Rejuvenation")) and (partyMemberHP < self.rejuvenationHealth) and (localMana > self.rejuvenationMana) then
                		if (script_followMoveToMember:moveInLineOfSight(partyMember)) then
                	                return true;
                	    	end -- move to member
                	    	if (Cast("Rejuvenation", partyMember)) then
                	        	self.timer = GetTimeEX() + 1500;
                	        	return true;
                	    	end
                	end

                	-- healing touch if has regrowth
			if (self.clickHealingTouch) then
				if (HasSpell("Healing Touch")) and (partyMember:HasBuff("Regrowth")) and (partyMemberHP < self.healingTouchHealth) and (localMana > self.healingTouchMana) then
					if (script_followMoveToMember:moveInLineOfSight(partyMember)) then
                	        	    return true;
					end -- move to member
                	       		if (Cast("Healing Touch", partyMember)) then
                	        	    self.timer = GetTimeEX() + 1500;
                       		 	    return true;
                        		end
				end
			end

			-- low level healing touch
			if (not HasSpell("Regrowth")) then
				if (partyMemberHP < self.healingTouchHealth) and (localMana > self.healingTouchMana) then
					if (script_followMoveToMember:moveInLineOfSight(partyMember)) then
                	        		return true;
					end -- move to member
                	       		if (Cast("Healing Touch", partyMember)) then
                	        		self.timer = GetTimeEX() + 1500;
                       		 		return true;
                        		end
				end
			end
		end
	end
	end	
    return false;
end