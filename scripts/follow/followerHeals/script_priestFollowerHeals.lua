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
	isSetup = false,
    
}

function script_priestFollowerHeals:setup()
	
	local level = GetLocalPlayer():GetLevel();
	if (level < 10) then
		self.lesserHealMana = 30;
	end
end

function script_priestFollowerHeals:HealsAndBuffs()

	if (not self.isSetup) then
		script_priestFollowerHeals:setup();
		self.isSetup = true;
	end
	
	local localMana = GetLocalPlayer():GetManaPercentage();
	local localHealth = GetLocalPlayer():GetHealthPercentage();

	if (not IsStanding()) then 
		StopMoving();
	end


	-- Wait out the wait-timer and/or casting or channeling
	if (self.waitTimer > GetTimeEX() or IsCasting() or IsChanneling()) then
		return;
	end

	-- set tick rate for scripts
	if (GetTimeEX() > self.waitTimer) then
		waitTimer = GetTimeEX() + script_follow.tickRate;

		-- Check if anything is attacking us Priest
		if (script_followEX2:enemiesAttackingUs() >= 1) then
				local localMana = GetLocalPlayer():GetManaPercentage();
			if (localMana > 6 and HasSpell('Fade') and not IsSpellOnCD('Fade')) then
				CastSpellByName('Fade');
			end
		end

		for i = 1, GetNumPartyMembers() do

				local partyMember = GetPartyMember(i);

			if (GetNumPartyMembers() > 0) then

				local partyMembersHP = partyMember:GetHealthPercentage();
				local partyMemberDistance = partyMember:GetDistance();
				local leaderObj = GetPartyLeaderObject();
				local px, py, pz = GetPartyMember(i):GetPosition();
				local localObj = GetLocalPlayer();
	
				-- Dispel Magic
				if (HasSpell("Dispel Magic")) and (localMana > 20) then 
					if (partyMember:HasDebuff("Sleep"))
						or (partyMember:HasDebuff("Druid's Slumber"))
						or (partyMember:HasDebuff("Terrify"))
						or (leaderObj:HasDebuff("Frost Nova"))
						or (partyMember:HasDebuff("Screams of the Past"))
						or (partyMember:HasDebuff("Wavering Will"))
						or (partyMember:HasDebuff("Slow"))
							or (leaderObj:HasDebuff("Frostbolt"))
						or (partyMember:HasDebuff("Dominate Mind"))
				then
						local dispellRandom = random(1, 100);
						if (dispellRandom > 90) then
		                       			if (CastHeal("Dispel Magic", partyMember)) then
                          					self.waitTimer = GetTimeEX() + 1500;
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
								self.waitTimer = GetTimeEX() + 1500;
								return true;
							end
						end
					end	
				end
                    
                		-- Power word Fortitude
                		if (HasSpell("Power Word: Fortitude")) and (localMana > 40)
					and (not partyMember:HasBuff("Power Word: Fortitude")) then
					if (not partyMember:IsInLineOfSight() and partyMemberDistance < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       			end
					if (Cast("Power Word: Fortitude", partyMember)) then
						self.waitTimer = GetTimeEX() + 1500;
						return true;
					end
				end	
	
				-- Divine Spirit
				if (HasSpell("Divine Spirit")) and (localMana > 30)
					and (not partyMember:HasBuff("Divine Spirit")) then
					if (not partyMember:IsInLineOfSight() and partyMemberDistance < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       				end
					if (Cast("Divine Spirit", partyMember)) then
						self.waitTimer = GetTimeEX() + 1500;
						return true;
	 				end	
				end
	
				-- Inner Fire
				if (HasSpell("Inner Fire")) and (localMana > 30)
					and (not localObj:HasBuff("Inner Fire")) then
					if (Buff("Inner Fire", localObj)) then
						self.waitTimer = GetTimeEX() + 1500;
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
					if (localMana < self.flashHealMana)
						and (leaderObj:GetHealthPercentage() < self.partyFlashHealHealth) then
						if (Buff("Inner Focus", localObj)) then 
							self.waitTimer = GetTimeEX() + 1400;
							return true; 
						end
						if (CastHeal("Flash Heal", partyMember)) then
							self.waitTimer = GetTimeEX() + 1600;
							return true;
						end
					end
				end
	                
				-- Power Infusion
				if (HasSpell("Power Infusion")) and (not IsSpellOnCD("Power Infusion")) then
					if (partyMembersHP< 50) or (script_priest:enemiesAttackingUs(8) > 1) then
						if (Buff("Power Infusion")) then
							self.waitTimer = GetTimeEX() + 1500;
							return true;
						end
					end
				end

			if (self.enableHeals) and (GetNumPartyMembers() > 0) then
			local localMana = GetLocalPlayer():GetManaPercentage();
	                	-- flash heal 
	                	if (self.clickFlashHeal) then
                			if (localMana > self.flashHealMana)
						and (partyMembersHP < self.partyFlashHealHealth) then
               	        			if (not partyMember:IsInLineOfSight() and partyMemberDistance < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       				end
                	        		if (CastHeal("Flash Heal", partyMember)) then
                	            			self.waitTimer = GetTimeEX() + 2000;
							return true;
                        			end
               	    			end
               			end
	
	                	-- Greater Heal
	               		if (self.clickGreaterHeal) then
	               	    		if (localMana > self.greaterHealMana)
						and (partyMembersHP < self.partyGreaterHealHealth)
						and (HasSpell("Greater Heal")) then
         		               		if (not partyMember:IsInLineOfSight() and partyMemberDistance < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       				end
         	        	       		if (CastHeal("Greater Heal", partyMember)) then
         	        	       			self.waitTimer = GetTimeEX() + 2000;
         	                   			return true;
         	               			end
					end
				end
	
                		-- Heal
                		if (self.clickHeal) then
                    			if (localMana > self.healMana) and (partyMembersHP < self.partyHealHealth)
						and (HasSpell("Heal")) then
                        			if (not partyMember:IsInLineOfSight() and partyMemberDistance < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       				end
                        			if (CastHeal("Heal", partyMember)) then
                        	    			self.waitTimer = GetTimeEX() + 3200;
                        	    			return true;
       	 	        	        	end
       	 	        	    	end
	                	end
	
	                	-- Lesser Heal
	                	-- level 20+ at very low mana
	                	if (localObj:GetLevel() >= 20) then
	                    		if (localMana <= 8) and (partyMembersHP <= 20) then
	                        		if (not partyMember:IsInLineOfSight() and partyMemberDistance < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       				end	
	                        		if (CastHeal("Lesser Heal", partyMember)) then
	                        			self.waitTimer = GetTimeEX() + 2500;
	                        		end
	                    		end
	                    	-- below level 20 cast lesser heal
	                	elseif (localObj:GetLevel() <= 20) then
	                    		if (localMana > self.lesserHealMana)
					and (partyMembersHP < self.partyLesserHealHealth)
						and (HasSpell("Lesser Heal")) then
	                        		if (not partyMember:IsInLineOfSight() and partyMemberDistance < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       				end
	                        		if (Cast("Lesser Heal", partyMember)) then
	                            			self.waitTimer = GetTimeEX() + 2500;
							script_follow:setWaitTimer(2500);
	                            			return true;
	                        		end
	                    		end
	                	end
	
                		-- Renew
                		if (self.clickRenew) then
                    			if (localMana > self.renewMana) and (partyMembersHP < self.partyRenewHealth)
						and (not partyMember:HasBuff("Renew")) and (HasSpell("Renew")) then
                        			if (not partyMember:IsInLineOfSight() and partyMemberDistance < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       				end
                        			if (CastHeal("Renew", partyMember)) then
                        	    			self.waitTimer = GetTimeEX() + 1650;
                        	    			return true;
                        			end
                    			end
                		end

                		-- Shield
                		if (self.clickShield) then
                    			if (localMana > self.shieldMana) and (partyMembersHP < self.partyShieldHealth)
						and (not partyMember:HasDebuff("Weakened Soul"))
						and (HasSpell("Power Word: Shield")) then
                        			if (not partyMember:IsInLineOfSight() and partyMemberDistance < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       				end
                        			if (CastHeal("Power Word: Shield", partyMember)) then 
                        	    			self.waitTimer = GetTimeEX() + 1550;
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