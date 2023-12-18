script_priestEX = {

}

function script_priestEX:healsAndBuffs(localObj, localMana)

	if (GetLocalPlayer():GetUnitsTarget() ~= 0) then
		-- attempt to run away from adds - don't pull them
		if (IsInCombat() and script_grind.skipHardPull)
			and (script_grind:isTargetingMe(targetObj))
			and (targetObj:IsInLineOfSight())
			and (not targetObj:IsCasting()) then		
			if (script_checkAdds:checkAdds()) then
			end
		end
	end

	-- get target health percentage
	if (GetLocalPlayer():GetUnitsTarget() ~= 0) and (IsInCombat()) then
		local targetHealth = targetObj:GetHealthPercentage();
	end
	local localHealth = GetLocalPlayer():GetHealthPercentage();

	local localObj = GetLocalPlayer();

	-- get self player level
	local localLevel = GetLocalPlayer():GetLevel();

	-- dismount before combat
	if (IsMounted()) then
		DisMount();
	end

	if (not IsMounted()) then
		-- inner focus
		if (not localObj:HasBuff("Inner Focus")) and (HasSpell("Inner Focus")) then
			if (not IsSpellOnCD("Inner Focus")) then
				if (GetLocalPlayer():GetManaPercentage() <= 20) and (GetLocalPlayer():GetHealthPercentage() <= 20) then
					if (Buff("Inner Focus", localObj)) then
						script_grind:setWaitTimer(1550);
						return; -- keep trying until cast
					end
				end
			end
	
			-- cast heal while inner focus active
		elseif (localObj:HasBuff("Inner Focus")) then
			if (Cast("Flash Heal", localObj)) then
				script_grind:setWaitTimer(1550);
				return; -- keep trying until cast
			end
		end
	
		-- Power Infusion low health 50% or targets >= 1
		if (HasSpell("Power Infusion")) and (not IsSpellOnCD("Power Infusion")) then
			if (localHealth <= 50) or (script_priest:enemiesAttackingUs(8) >= 2) then
				if (Buff("Power Infusion")) then
					return; -- keep trying until cast
				end
			end
		end
	
		-- Buff Inner Fire
		if (not IsInCombat()) and (not localObj:HasBuff("Inner Fire")) and (HasSpell("Inner Fire")) and (localMana >= 8) then
			Buff("Inner Fire", localObj);
			script_grind:setWaitTimer(1250);
			return 0; -- keep trying until cast
		end
	
		-- Buff Fortitude
		if (not script_priest.shadowForm) then	-- if not in shadowform
			if (localMana >= 25) and (not IsInCombat()) and (not localObj:HasBuff("Power Word: Fortitude")) and (HasSpell("Power Word: Fortitude")) then
				Buff("Power Word: Fortitude", localObj);
				script_grind:setWaitTimer(1550);
				return 0; -- if buffed 
			end
		end
		
		-- Buff Divine Spirit
		if (not script_priest.shadowForm) then	-- if not in shadowform
			if (localMana >= 25) and (not IsInCombat()) and (not localObj:HasBuff("Divine Spirit")) and (HasSpell("Divine Spririt")) then
				if (Buff("Divine Spirit", localObj)) then
					script_grind:setWaitTimer(1500);
					return 0;  -- if buffed 
				end
			end
		end
	
		-- Cast Renew
		if (not script_priest.shadowForm) then	-- if not in shadowform
			if (localMana >= 12) and (localHealth <= script_priest.renewHP) and (not localObj:HasBuff("Renew")) and (HasSpell("Renew")) then
				if (Buff("Renew", localObj)) then
					script_grind:setWaitTimer(1700);
					return 0; -- if buffed 
				end
			end
		end
	
			-- Cast Shield Power Word: Shield
		if (localMana >= 10) and (localHealth <= script_priest.shieldHP) and (not localObj:HasDebuff("Weakened Soul")) and (IsInCombat()) and (HasSpell("Power Word: Shield")) then
			if (Buff("Power Word: Shield", localObj)) then 
				script_grind:setWaitTimer(1600);
				script_priest.waitTimer = GetTimeEX() + 1600;
				return 0;  -- if buffed 
			end
		end

		-- Cast Greater Heal
		if (not script_priest.shadowForm) then	-- if not in shadowform
			if (localMana >= 20) and (localHealth <= script_priest.greaterHealHP) then
				if (CastHeal("Greater Heal", localObj)) then
					script_grind:setWaitTimer(1500);
					return 0;	-- if cast 
				end
			end
		end	
	
		-- Cast Heal(spell)
		if (not script_priest.shadowForm) then	-- if not in shadowform
			if (localMana >= 15) and (localHealth <= script_priest.healHP) then
				if (CastHeal("Heal", localObj)) then
					script_grind:setWaitTimer(1500);
					return 0;	-- if cast 
				end
			end
		end
	
		-- Cast Flash Heal
		if (not script_priest.shadowForm) then	-- if not in shadowform
			if (localMana >= 8) and (localHealth <= script_priest.flashHealHP) then
				if (CastHeal("Flash Heal", localObj)) then
					script_grind:setWaitTimer(1700);
					return 0;	-- if cast 
				end
			end
		end
	
		-- Cast Lesser Heal
		if (not script_priest.shadowForm) then	-- if not in shadowform
			if (localLevel < 20) then	-- don't use this when we get flash heal ELSE very low mana
				if (localMana >= 10) and (localHealth <= script_priest.lesserHealHP) then
					if (CastHeal("Lesser Heal", localObj)) then
						script_grind:setWaitTimer(1700);
						return 0;	-- if cast return true
					end
				end
	
			-- ELSE IF player level >= 20
			elseif (localLevel >= 20) then
				if (localMana <= 8) and (localHealth <= script_priest.flashHealHP) then
					if (CastHeal("Lesser Heal", localObj)) then
						script_grind:setWaitTimer(1700);
						return 0;	-- if cast return true
					end
				end
			end
		end
	
		--Check Disease Debuffs -- cure disease
		if (script_checkDebuffs:hasDisease()) then
			if (localMana > 20) and (HasSpell("Cure Disease")) then
				CastSpellByName("Cure Disease", localObj);
				script_grind:setWaitTimer(1750);
				return 0;
			end
		end
	
		-- check magic debuffs - dispel magic
		if (script_checkDebuffs:hasMagic()) then
			if (localMana > 20) and (HasSpell("Dispel Magic")) then
				CastSpellByName("Dispel Magic", localObj);
				script_grind:setWaitTimer(1750);
				return 0;
			end
		end
	
		-- use mind blast on CD
				-- !! must be placed here to stop wand casting !!
		if (GetLocalPlayer():GetUnitsTarget() ~= 0) and (IsInCombat()) then
			if (HasSpell("Mind Blast")) and (not IsSpellOnCD("Mind Blast")) and (IsInCombat()) then
				if (targetHealth >= 20) and (localMana >= script_priest.mindBlastMana) and (GetLocalPlayer():GetUnitsTarget() ~= 0) then
					targetObj:FaceTarget();
					CastSpellByName("Mind Blast", targetObj);
					script_grind:setWaitTimer(1550);
					return 0;
				end
			end
		end
	end
return false;
end

function script_priestEX:menu()

	-- obtain class from game using wow api
	local class = UnitClass("player");

	-- if we are priest then show menu
	if (class == 'Priest') then

		local wasClicked = false;

		-- priest combat options all COMBAT spells under here. skills spells talents
		if (CollapsingHeader("Priest Combat Options")) then

			-- MIND BLAST
			-- hide spell if not obtained yet
			if (HasSpell("Mind Blast")) then
				Text('Mind Blast above Self mana percent');
				script_priest.mindBlastMana = SliderInt("MBM%", 10, 100, script_priest.mindBlastMana);
			end

			Separator();

			-- SHADOW WORD PAIN
			-- hide spell if not obtained yet
			if (HasSpell("Shadow Word: Pain")) then
				Text("Shadow Word: Pain above Self mana percent");
				script_priest.swpMana = SliderInt("SPM", 10, 100, script_priest.swpMana)
			end

			Separator();

			-- MIND FLAY
			-- hide spell if not obtained yet
			if (script_priest.useMindFlay) then
				Text("Use Mind Flay above target health percent")
				script_priest.mindFlayHealth = SliderInt("MFH", 1, 100, script_priest.mindFlayHealth);
				Text("Use Mind Flay above Self mana percent");
				script_priest.mindFlayMana = SliderInt("MFM", 1, 100, script_priest.mindFlayMana);
			end	

			-- shadowform appears in menu if has the spell
			if (HasSpell("Shadowform")) then

				Text("Health to exit Shadowform to Heal!");
				script_priest.shadowFormHealth = SliderInt("SFH", 1, 70, script_priest.shadowFormHealth);

				Separator();

			end

			-- hide spell if not obtained yet
			if (HasSpell("Psychic Scream")) then
				wasClicked, script_priest.useScream = Checkbox("Use Fear", script_priest.useScream);
			end

			SameLine();

			wasClicked, script_priest.useSmite = Checkbox("Use Smite", script_priest.useSmite);
			
			-- mind flay appears in menu if has the spell
			if (HasSpell("Mind Flay")) then
				
				SameLine();

				wasClicked,	script_priest.useMindFlay = Checkbox("Mind Flay instead of Wand", script_priest.useMindFlay);
				
				-- if mind flay is clicked then set useWand to false/unclicked
				if script_priest.useMindFlay then
					
					script_priest.useWand = false;

				end

			end
			
			-- if mind flay is being used then hide wand menu
			if (not script_priest.useMindFlay) then
				localObj = GetLocalPlayer();


				-- hide wand menu if no ranged weapon equipped
				if (localObj:HasRangedWeapon()) then

					-- wand options menu
					if (CollapsingHeader("|+| Wand Options")) then

						Text('Wand options:');
						wasClicked, script_priest.useWand = Checkbox("Use Wand", script_priest.useWand);
						
						Text('Wand below Self mana percent');
						script_priest.useWandMana = SliderInt("WM%", 10, 100, script_priest.useWandMana);

						Text('Wand below target HP percent');
						script_priest.useWandHealth = SliderInt("WH%", 10, 100, script_priest.useWandHealth);

					end
				end
			end
		end

		if (CollapsingHeader("Priest Heal Options - Self")) then

			Text('Drink below mana percentage');
			script_priest.drinkMana = SliderInt("DM%", 10, 99, script_priest.drinkMana);

			Text('Eat below health percentage');
			script_priest.eatHealth = SliderInt("EH%", 10, 99, script_priest.eatHealth);

			Separator();

			Text('Self Heals');

			-- if level >= 20 then hide lesser heal
			if (GetLocalPlayer():GetLevel() <= 20) then
				script_priest.lesserHealHP = SliderInt("Lesser heal HP%", 1, 99, script_priest.lesserHealHP);	
			end
			
			-- hide spell if not obtained yet
			if (HasSpell("Renew")) then
				script_priest.renewHP = SliderInt("Renew HP%", 1, 99, script_priest.renewHP);	
			end

			-- hide spell if not obtained yet
			if (HasSpell("Power Word: Shield")) then
				script_priest.shieldHP = SliderInt("Shield HP%", 1, 99, script_priest.shieldHP);
			end

			-- hide spell if not obtained yet
			if (HasSpell("Flash Heal")) then
				script_priest.flashHealHP = SliderInt("Flash heal HP%", 1, 99, script_priest.flashHealHP);
			end

			-- hide spell if not obtained yet
			if (HasSpell("Heal")) then
				script_priest.healHP = SliderInt("Heal HP%", 1, 99, script_priest.healHP);	
			end

			-- hide spell if not obtained yet
			if (HasSpell("Greater Heal")) then
				script_priest.greaterHealHP = SliderInt("Greater Heal HP%", 1, 99, script_priest.greaterHealHP);
			end

			script_priest.potionHealth = SliderInt("Potion HP%", 1, 99, script_priest.potionHealth);
			script_priest.potionMana = SliderInt("Potion Mana%", 1, 99, script_priest.potionMana);

		end
	end
end