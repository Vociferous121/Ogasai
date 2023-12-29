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
	waitTimer = GetTimeEX(),

}

function script_paladinFollowerHeals:HealsAndBuffs()


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
	if (GetTimeEX() > self.timer) then
		timer = GetTimeEX() + script_follow.tickRate;

		-- Check if anything is attacking us Paladin
		if (script_followEX2:enemiesAttackingUs() >= 2) then
				local localMana = GetLocalPlayer():GetManaPercentage();
			if (localMana > 6 and HasSpell('Divine Protection') and not IsSpellOnCD('Divine Protection')) then
				CastSpellByName('Divine Protection');
			end
		end

		for i = 1, GetNumPartyMembers() do

		if (GetNumPartyMembers() > 0) then

			local member = GetPartyMember(i);
			local membersHP = member:GetHealthPercentage();
			local memberDistance = member:GetDistance();
			local leaderObj = GetPartyLeaderObject();
			local px, py, pz = GetPartyMember(i):GetPosition();

               		 -- Cure Disease
                	if (HasSpell("Cure Disease")) and (localMana > 10) then
                		if (member:HasDebuff("Infected Wound")) then
                        		if (CastHeal("Cure Disease", member)) then
                        		    script_follow.timer = GetTimeEX() + 1500;
                        		    return true;
                        		end
                    		end
                	end

                	-- purify
               		if (HasSpell("Purify")) and (localMana > 10) then
                    		if (member:HasDebuff("Irradiated")) or (member:HasDebuff("Infected Wound")) then
                        		if (CastHeal("Purify", member)) then
                            			script_follow.timer = GetTimeEX() + 1500;
                            			return true;
                        		end
                    		end
                	end

               		-- blessing of might
                	if (not member:HasBuff("Strength of Earth")) and (not member:HasBuff("Mana Spring")) then
                    		if (not member:HasBuff("Blessing of Wisdom")) and (not member:HasBuff("Blessing of Might")) then
                        		if (member:GetRagePercentage() > 1) or (member:GetEnergyPercentage() > 1) or (member:HasBuff("Bear Form") or member:HasBuff("Cat Form")) and (not member:GetManaPercentage() > 1) then
                            			if (not member:IsInLineOfSight() and memberDistance() < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       			end
                            			if (Buff("Blessing of Might", member)) then
                                        		script_follow.timer = GetTimeEX() + 1500;
                                			return true;	
                            			end
                        		end
                    		end
                	end

                	-- blessing of wisdom
                	if (member:GetManaPercentage() > 1) and (HasSpell("Blessing of Wisdom")) and (not member:HasBuff("Blessing of Wisdom")) and (not member:HasBuff("Blessing of Might")) and (not member:HasBuff("Mana Spring")) then
                    		if (not member:GetRagePercentage() > 1) and (not member:GetEnergyPercentage() > 1) then
                        		if (not member:IsInLineOfSight() and memberDistance() < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       			end
                        		if (Buff("Blessing of Wisdom", member)) then
                            			script_follow.timer = GetTimeEX() + 1500;
                            			return true;
                        		end
                    		end
                	end

                	-- Blessing of Protection
                	if (localMana > 5) and (membersHP < self.bopHealth) and (HasSpell("Blessing of Protection")) then
                    		if (not member:IsInLineOfSight() and memberDistance() < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       			end
                    		if (Cast("Blessing of Protection", member)) then
                        		script_follow.timer = GetTimeEX() + 1500;
                        		return true;
                    		end
                	end

			-- paladin heals

				-- Lay on Hands
                		if (localMana < 25) and (membersHP < self.layOnHandsHealth) and (HasSpell("Lay on Hands")) then
					if (not member:IsInLineOfSight() and memberDistance() < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       			end
					if (CastHeal("Lay on Hands", member)) then
                        			script_follow.timer = GetTimeEX() + 1500;
                        			return true;
					end
				end

                		-- holy light party leader
				--if (Getmember(GetPartyLeaderIndex()) ~= 0) then
                		--	leaderHealth = leaderObj:GetHealthPercentage();
                		--	if leaderHealth < 40 and HasSpell("Holy Light") then
                		--	    CastHeal("Holy Light", leaderObj);
                		--	    script_follow.timer = GetTimeEX() + 3000;
                		--	    return true;
				--	end
                		--end

                		-- Holy Light
                		if (localMana > self.holyLightMana) and (membersHP <= self.partyHolyLightHealth) and (HasSpell("Holy Light")) then
                			if (not member:IsInLineOfSight() and memberDistance() < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       			end
                			if (CastHeal("Holy Light", member)) then
                		        	script_follow.timer = GetTimeEX() + 3000;
                		        	return true;
                		    	end
                		end

                		-- Flash Of Light
                		if (localMana > self.flashOfLightMana) and (membersHP < self.partyFlashOfLightHealth) and (HasSpell("Flash of Light")) then
                 	   		if (not member:IsInLineOfSight() and memberDistance() < script_follow.followLeaderDistance and leaderObj:IsInLineOfSight()) then 											script_followMoveToTarget:moveToTarget(GetLocalPlayer(), px, py, pz);
							return true;
                       			end
                 	   		if (CastHeal("Flash of Light", member)) then
                 	       			return true;
                 	   		end
				end       
			end
		end
	end
return false;
end   