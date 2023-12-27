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


function GetPartyMembers()
	for i = 1, GetNumPartyMembers() do

		local partyMember = GetPartyMember(i);

		local localMana = GetLocalPlayer():GetManaPercentage();
		local localEnergy = GetLocalPlayer():GetEnergyPercentage();
		local partyMemberHP = partyMember:GetHealthPercentage();

		if (partyMemberHP > 0) and (localMana > 1 or localEnergy > 1) then
				local partyMemberDistance = partyMember:GetDistance();
				leaderObj = GetPartyMember(GetPartyLeaderIndex());
				local localHealth = GetLocalPlayer():GetHealthPercentage();
		end
	end
end

function script_followHealsAndBuffs:healAndBuff()

			local class = UnitClass('player');

			-- shaman heals and buffs
			if (class == 'Shaman') then
				if (script_shamanFollowerHeals:HealsAndBuffs()) then
					--return true;
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
					--return true;
				end
			end

			-- druid heals and buffs
			if (class == 'Druid') then
				if (script_druidFollowerHeals:HealsAndBuffs()) then
					--return true;
				end
			end

			-- paladin heals and buffs
			if (class == 'Paladin') then
				if (script_paladinFollowerHeals:HealsAndBuffs()) then
					self.timer = GetTimeEX() + 2000;
					--return true;
				end
			end

			-- hunter buffs
			if (class == 'Hunter') then
				if (script_hunterFollowerHeals:HealsAndBuffs()) then
			--		return true;
				end
			end

			-- warlock buffs
			if (class == 'Warlock') then
				if (script_warlockFollowerHeals:HealsAndBuffs()) then
			--		return true;
				end
			end

			-- rogue buffs??
			if (class == 'Rogue') then
				if (script_rogueFollowerHeals:HealsAndBuffs()) then
			--		return true;
				end
			end

			-- warrior heals... and buffs
			if (class == 'Warrior') then
				if (script_warriorFollowerHeals:HealsAndBuffs()) then
			--		return true;
				end
			end
	return false;
end