script_followHealsAndBuffs = {

	-- load the combat follower heal scripts
	shamanLoaded = include("scripts\\follow\\followerHeals\\script_shamanFollowerHeals.lua"),
	druidLoaded = include("scripts\\follow\\followerHeals\\script_druidFollowerHeals.lua"),
	priestLoaded = include("scripts\\follow\\followerHeals\\script_priestFollowerHeals.lua"),
	paladinLoaded = include("scripts\\follow\\followerHeals\\script_paladinFollowerHeals.lua"),
	warriorLoaded = include("scripts\\follow\\followerHeals\\script_warriorFollowerHeals.lua"),
	warlockLoaded = include("scripts\\follow\\followerHeals\\script_warlockFollowerHeals.lua"),
	hunterLoaded = include("scripts\\follow\\followerHeals\\script_hunterFollowerHeals.lua"),
	rogueLoaded = include("scripts\\follow\\followerHeals\\script_rogueFollowerHeals.lua"),
	mageLoaded = include("scripts\\follow\\followerHeals\\script_mageFollowerHeals.lua"),

	timer = GetTimeEX(),

}


function getPartyMembers()
	local numPartyMembers = 0;
	for i = 1, GetNumPartyMembers() do

		local numPartyMembers = numPartyMembers + 1;

		if (GetNumPartyMembers() > 0) then
			local partyMember = GetPartyMember(i);
			local leader = GetPartyMember(GetPartyLeaderIndex());
		end
	return numPartyMembers;	
	end
end

		-- separated these files due to a limitation of file sizes.
	
		-- this is just the function to call heals and buffs based on class

		-- based on class to reduce CPU usage it will only cast spells if you are that class...

function script_followHealsAndBuffs:healAndBuff()

			-- if self.follow member? don't know if needed here... defaults to follow leader
			--for i = 1, GetNumPartyMembers() do
			--	partyMember = GetPartyMember(i);
			---	leader = get leader
			--	if member distance > x then
			--		but not if leaderdistasnce > member?
			--		get 3d dist and compare?
			--	end
			--end
				

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

			-- mage buffs
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
					return true;
				end
			end

			-- hunter buffs
			--if (class == 'Hunter') then
			--	if (script_hunterFollowerHeals:HealsAndBuffs()) then
			--		return true;
			--	end
			--end

			-- warlock buffs
			--if (class == 'Warlock') then
			--	if (script_warlockFollowerHeals:HealsAndBuffs()) then
			--		return true;
			--	end
			--end

			-- rogue buffs??
			--if (class == 'Rogue') then
			--	if (script_rogueFollowerHeals:HealsAndBuffs()) then
			--		return true;
			--	end
			--end

			-- warrior heals... and buffs
			--if (class == 'Warrior') then
			--	if (script_warriorFollowerHeals:HealsAndBuffs()) then
			--		return true;
			--	end
			--end
	return false;
end