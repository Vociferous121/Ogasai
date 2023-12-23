script_followHealsAndBuffs = {

	-- load the combat follower heal scripts
	shamanLoaded = include("scripts\\followerHeals\\script_shamanFollowerHeals.lua"),
	druidLoaded = include("scripts\\followerHeals\\script_druidFollowerHeals.lua"),
	priestLoaded = include("scripts\\followerHeals\\script_priestFollowerHeals.lua"),
	paladinLoaded = include("scripts\\followerHeals\\script_paladinFollowerHeals.lua"),
	warriorLoaded = include("scripts\\followerHeals\\script_warriorFollowerHeals.lua"),
	warlockLoaded = include("scripts\\followerHeals\\script_warlockFollowerHeals.lua"),
	hunterLoaded = include("scripts\\followerHeals\\script_hunterFollowerHeals.lua"),
	rogueLoaded = include("scripts\\followerHeals\\script_rogueFollowerHeals.lua"),
	mageLoaded = include("scripts\\followerHeals\\script_mageFollowerHeals.lua"),

	timer = GetTimeEX(),

}

		-- separated these files due to a limitation of file sizes.
	
		-- this is just the function to call heals and buffs based on class

		-- based on class to reduce CPU usage it will only cast spells if you are that class...

function script_followHealsAndBuffs:healAndBuff()

		if(GetTimeEX() > self.timer) then
			self.timer = GetTimeEX() + script_follow.tickRate;

	
			-- Move in range: combat script return 3
			if (script_follow.combatError == 3) then
				script_follow.message = "Moving to target...";
				script_follow:moveInLineOfSight(partyMember);		
				return true;
			end
			
			-- Move in line of sight and in range of the party member
			if (script_follow:moveInLineOfSight(partyMember)) then
				return true; 
			end
			
			local class = UnitClass('player');

			-- shaman heals and buffs
			if (class == 'Shaman') then
				if (script_shamanFollowerHeals:HealsAndBuffs()) then
					return true;
				end
			end

			-- priest heals and buffs
			if (class == 'Priest') then
				if (script_priestFollowerHeals:HealsAndBuffs()) then
					return true;
				end	
			end

			-- mage heals and buffs
			if (class == 'Mage') then
				if (script_mageFollowerHeals:HealsAndBuffs()) then
					return true;
				end
			end

			-- druid heals and buffs
			if (class == 'Druid') then
				if (script_druidFollowerHeals:HealsAndBuffs()) then
					return true;
				end
			end

			-- paladin heals and buffs
			if (class == 'Paladin') then
				if (script_paladinFollowerHeals:HealsAndBuffs()) then
					self.timer = GetTimeEX() + 2000;
					return true;
				end
			end

			-- hunter heals and buffs
			--if (class == 'Hunter') then
			--	if (script_hunterFollowerHeals:HealsAndBuffs()) then
			--		return true;
			--	end
			--end

			-- warlock heals and buffs
			--if (class == 'Warlock') then
			--	if (script_warlockFollowerHeals:HealsAndBuffs()) then
			--		return true;
			--	end
			--end

			-- rogue heals and buffs
			--if (class == 'Rogue') then
			--	if (script_rogueFollowerHeals:HealsAndBuffs()) then
			--		return true;
			--	end
			--end

			-- warrior heals and buffs
			--if (class == 'Warrior') then
			--	if (script_warriorFollowerHeals:HealsAndBuffs()) then
			--		return true;
			--	end
			--end
		end
	return;
end