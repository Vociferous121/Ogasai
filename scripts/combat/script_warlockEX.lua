script_warlockEX = {

	warlockExtra2 = include("scripts\\combat\\script_warlockEX2.lua"),

}

function script_warlockEX:useHealthstones()

	if (HasItem("Major Healthstone")) then
		UseItem("Major Healthstone");
		return true;
	elseif (HasItem("Greater Healthstone")) then
		UseItem("Greater Healthstone");
		return true;
	elseif (HasItem("Healthstone")) then
		UseItem("Healthstone");
		return true;
	elseif (HasItem("Lesser Healthstone")) then
		UseItem("Lesser Healthstone");
		return true;
	elseif (HasItem("Minor Healthstone")) then
		UseItem("Minor Healthstone");
		return true;
	end

return false;
end

function script_warlockEX:checkHealthstones()

	if (HasSpell("Create Healthstone (Major)")) then
		if (not HasItem("Major Healthstone")) and (HasItem("Soul Shard")) then
			if (CastSpellByName("Create Healthstone (Major)()")) then
				script_warlock.hasHealthstone = true;
				script_grind:setWaitTimer(1750);
				script_warlock.waitTimer = GetTimeEX() + 1750;
				return true;
			end
		end
	elseif (HasSpell("Create Healthstone (Greater)")) then
		if (not HasItem("Greater Healthstone")) and (HasItem("Soul Shard")) then
			if (CastSpellByName("Create Healthstone (Greater)()")) then
				script_warlock.hasHealthstone = true;
				script_grind:setWaitTimer(1750);
				script_warlock.waitTimer = GetTimeEX() + 1750;
				return true;
			end
		end
	elseif (HasSpell("Create Healthstone")) then
		if (not HasItem("Healstone")) and (HasItem("Soul Shard")) then
			if (CastSpellByName("Create Healthstone ()")) then
				script_warlock.hasHealthstone = true;
				script_grind:setWaitTimer(1750);
				script_warlock.waitTimer = GetTimeEX() + 1750;
				return true;
			end
		end

	elseif (HasSpell("Create Healthstone (Lesser)")) then
		if (not HasItem("Lesser Healthstone")) and (HasItem("Soul Shard")) then
			if (CastSpellByName("Create Healthstone (Lesser)()")) then
				script_warlock.hasHealthstone = true;
				script_grind:setWaitTimer(1750);
				script_warlock.waitTimer = GetTimeEX() + 1750;
				return true;
			end
		end
	elseif (HasSpell("Create Healthstone (Minor)")) then
		if (not HasItem("Minor Healthstone")) and (HasItem("Soul Shard")) then
			if (CastSpellByName("Create Healthstone (Minor)()")) then
				script_warlock.hasHealthstone = true;
				script_grind:setWaitTimer(1750);
				script_warlock.waitTimer = GetTimeEX() + 1750;
				return true;
			end
		end
	end

return false;
end

function script_warlockEX:menu()

	-- select local player
	localObj = GetLocalPlayer();

	-- close menus on startup
	local wasClicked = false;

	-- show combat menu
	if (CollapsingHeader("Warlock Combat Options")) then

		wasClicked, script_warlock.waitAfterCombat = Checkbox("Wait After Combat", script_warlock.waitAfterCombat);
		SameLine();
		wasClicked, script_warlock.feelingLucky = Checkbox("Feeling Lucky?", script_warlock.feelingLucky);
	
		if (script_warlock.feelingLucky) then
			Text("Your Luck");
			script_warlock.howLucky = SliderInt("???", 1, 8, script_warlock.howLucky);
			script_warlock.fearAdds = false;
			script_grindEX.avoidBlacklisted = false;
			script_grind.skipHardPull = false;
		end
			
		-- if has spell summon imp then show summon imp button
		if (HasSpell("Summon Imp")) then

			-- summon imp button
			wasClicked, script_warlock.useImp = Checkbox("Use Imp", script_warlock.useImp);
			
			-- keep next summon demon on same line
			SameLine();

			-- if use Imp button was clicked then turn off other pets
			if (script_warlock.useImp) then
				
				-- turn off use voidwalker
				script_warlock.useVoid = false;
				
				-- turn off use succubus
				script_warlock.useSuccubus = false;
				
				-- turn off use felhunter
				script_warlock.useFelhunter = false;
			end
			
		end
		
		-- if has spell summon voidwalker then show use voidwalker button
		if (HasSpell("Summon Voidwalker")) then

			-- show use voidwalker button
			wasClicked, script_warlock.useVoid = Checkbox("Use Voidwalker", script_warlock.useVoid);
			
			-- keep next summon demon on same line
			SameLine();

			-- if use voidwalker button was clicked then turn off other pets
			if (script_warlock.useVoid) then
				
				-- turn off use imp
				script_warlock.useImp = false;
				
				-- turn off use succubus
				script_warlock.useSuccubus = false;
				
				-- turn off use felhunter
				script_warlock.useFelhunter = false;
			end
		end

		-- if has spell summon succubus then show use succubus button
		if (HasSpell("Summon Succubus")) then
			
			wasClicked, script_warlock.useSuccubus = Checkbox("Use Succubus", script_warlock.useSuccubus);

			if (script_warlock.useSuccubus) then
				
				script_warlock.useImp = false;
				
				script_warlock.useVoid = false;
				
				script_warlock.useFelhunter = false;
			end
		end

		if (HasSpell("Summon Felhunter")) then
			
			wasClicked, script_warlock.useFelhunter = Checkbox("Use Felhunter", script_warlock.useFelhunter);
			
			SameLine();

			if (script_warlock.useFelhunter) then
				
				script_warlock.useImp = false;
				
				script_warlock.useSuccubus = false;
				
				script_warlock.useVoid = false;
			end
		end
		
		if (HasSpell("Drain Soul")) then
			
			wasClicked, script_warlock.enableGatherShards = Checkbox("Gather Soul Shards", script_warlock.enableGatherShards);
		end

		Separator();

		Text('Drink below mana percentage');
		
		script_warlock.drinkMana = SliderFloat("M%", 1, 100, script_warlock.drinkMana);
		
		Text('Eat below health percentage');
		
		script_warlock.eatHealth = SliderFloat("H%", 1, 100, script_warlock.eatHealth);
			
		Text('Use health potions below percentage');
		
		script_warlock.potionHealth = SliderFloat("HP%", 1, 99, script_warlock.potionHealth);
		
		Text('Use mana potions below percentage');
		
		script_warlock.potionMana = SliderFloat("MP%", 1, 99, script_warlock.potionMana);
		
		Separator();

		Text('Skills options:');

		
		if (script_warlock.alwaysFear) then
			SameLine();
			wasClicked, script_warlock.followFeared = Checkbox("Follow Feared Target", script_warlock.followFeared);
		end

		-- always fear
		if (HasSpell("Fear")) and (not script_warlock.enableGatherShards) then

			wasClicked, script_warlock.alwaysFear = Checkbox("Fear Single Targets", script_warlock.alwaysFear);
		
			SameLine();
			
			if (script_warlock.alwaysFear) then
	
				script_warlock.fearAdds = false;
			end
		end
		
		-- fear only adds
		if (HasSpell("Fear")) then
	
			wasClicked, script_warlock.fearAdds = Checkbox("Fear Adds", script_warlock.fearAdds);

			if (script_warlock.fearAdds) then
	
				script_warlock.alwaysFear = false;
			end
		end

		-- use wand
		if (localObj:HasRangedWeapon()) then

			wasClicked, script_warlock.useWand = Checkbox("Use Wand", script_warlock.useWand);
			
			SameLine();

			if (script_warlock.useWand) then

				script_warlock.useShadowBolt = false;
			end
		end

		if (HasSpell("Death Coil")) then
		
			SameLine();

			wasClicked, script_warlock.useDeathCoil = Checkbox("Use Coil", script_warlock.useDeathCoil);
	
		end

		-- shadowbolt
		wasClicked, script_warlock.useShadowBolt = Checkbox("Shadowbolt instead of wand", script_warlock.useShadowBolt);
		
		if (not localObj:HasRangedWeapon()) then

			script_warlock.useShadowBolt = true;
		end
		if (script_warlock.useShadowBolt) then

			script_warlock.useWand = false;
		end

		-- unending breath
		if (HasSpell("Unending Breath")) then

			wasClicked, script_warlock.useUnendingBreath = Checkbox("Use Unending Breath", script_warlock.useUnendingBreath);
		end
		
		SameLine();

		if (HasSpell("Drain Mana")) then

			wasClicked, script_warlock.useDrainMana = Checkbox("Use Drain Mana", script_warlock.useDrainMana);
		end

		Separator();

		if (HasSpell("Drain Life")) then

			Text("Use Drain Life below self health percent");
			
			script_warlock.drainLifeHealth = SliderInt("DLH", 1, 80, script_warlock.drainLifeHealth);
			
			Separator();
		end

		if (HasSpell("Health Funnel")) then
			
			Separator();		
	
			Text("Heal Pet below pet health percent");
			
			script_warlock.healPetHealth = SliderInt("HPH", 1, 80, script_warlock.healPetHealth);
		end

		if (script_warlock.useVoid) and (script_warlock.hasSacrificeSpell) then
			
			wasClicked, script_warlock.sacrificeVoid = Checkbox("Sacrifice Voidwalker when low script_warlock health", script_warlock.sacrificeVoid);
			
			if (script_warlock.sacrificeVoid) then
				
				Text("Self Health OR Pet Health percent to Sacrifice Voidwalker")
				
				script_warlock.sacrificeVoidHealth = SliderInt("SVH", 1, 25, script_warlock.sacrificeVoidHealth);
				
				Separator();
			end
		end

		if (localObj:HasRangedWeapon()) and (script_warlock.useWand) then
			
			if (CollapsingHeader("|+| Wand Options")) then
				
				Text("Use Wand below target health percent");
				
				script_warlock.useWandHealth = SliderInt("WH", 1, 100, script_warlock.useWandHealth);
				
				Text("Use Wand below self mana percent");
				
				script_warlock.useWandMana = SliderInt("WM", 1, 100, script_warlock.useWandMana);
			end
		end

		if (CollapsingHeader("|+| DoT Options")) then
				
			if (HasSpell("Corruption")) and (script_warlock.enableCorruption) then
				
				Text("Corruption cast time - 14 is 1.4 seconds");	
				
				script_warlock.corruptionCastTime = SliderInt("CCT (ms)", 0, 20, script_warlock.corruptionCastTime);
				
				Separator();
			end
			
			if (HasSpell("Siphon Life")) then

				wasClicked, script_warlock.enableSiphonLife = Checkbox("Use Siphon Life", script_warlock.enableSiphonLife);
				
				SameLine();
			end

			if (HasSpell("Immolate")) then
				
				wasClicked, script_warlock.enableImmolate = Checkbox("Use Immolate",script_warlock.enableImmolate);
			end

			if (HasSpell("Curse of Agony")) then
				
				wasClicked, script_warlock.enableCurseOfAgony = Checkbox("Use Curse of Agony", script_warlock.enableCurseOfAgony);

				if (script_warlock.useCurseOfAgony) then
					script_warlock.useCurseOfWeakness = false;
					script_warlock.useCurseOfTongues = false;
				end
				
				SameLine();
			end

			if (HasSpell("Corruption")) then
				
				wasClicked, script_warlock.enableCorruption = Checkbox("Use Corruption", script_warlock.enableCorruption);
			end

		end		

		if (CollapsingHeader("|+| Curse Options")) then
			
			if (HasSpell("Curse of Weakness")) then
				wasClicked, script_warlock.useCurseOfWeakness = Checkbox("Weakness", script_warlock.useCurseOfWeakness);
				
				if (script_warlock.useCurseOfWeakness) then
					script_warlock.useCurseOfAgony = false;
					script_warlock.useCurseOfTongues = false;
				end
			end

			if (HasSpell("Curse of Tongues")) then
				wasClicked, script_warlock.useCurseOfTongues = Checkbox("Tongues", script_warlock.useCurseOfTongues);
				
				if (script_warlock.useCuroseOfTongues) then
					script_warlock.useCurseOfAgony = false;
					script_warlock.useCurseOfWeakness = false;
				end
			end
			
		end

		Separator();

		if (HasSpell("Life Tap")) then
			
			if (CollapsingHeader("|+| Life Tap Options")) then
				
				Text("Use Life Tap above this percent health");
				
				script_warlock.lifeTapHealth = SliderInt("LTH", 50, 90, script_warlock.lifeTapHealth);
				
				Text("Use Life Tap below this percent mana");
				
				script_warlock.lifeTapMana = SliderInt("LTM", 15, 80, script_warlock.lifeTapMana);
			end
		end
	end
end