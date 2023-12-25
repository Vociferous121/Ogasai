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
	end
end

		-- separated these files due to a limitation of file sizes.
	
		-- this is just the function to call heals and buffs based on class

		-- based on class to reduce CPU usage it will only cast spells if you are that class...

function script_followHealsAndBuffs:healAndBuff()

			if (IsInCombat()) and (script_follow.enemyObj ~= nil) then
				if (script_follow.enemyObj:GetDistance() > 40) or (not script_follow.enemyObj:IsInLineOfSight()) then
			
				local _x, _y, _z = script_follow.enemyObj:GetPosition();
				script_navEX:moveToTarget(GetLocalPlayer(), _x, _y, _z);
				return;
				end
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
					self.timer = GetTimeEX() + 2000;
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