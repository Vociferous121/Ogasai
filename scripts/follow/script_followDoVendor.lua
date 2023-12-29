script_followDoVendor = {

	useVendor = true,
	sellVendor = 0,
}

function script_followDoVendor:sellStuff()

	if (script_vendor:sell()) then
		return true;
	end

return false;
end

-- are we close enough to vendor?
function script_followDoVendor:closeToVendor()

	local localObj = GetLocalPlayer();
	local x, y, z = localObj:GetPosition();
	local factionID = 1; -- horde
	local factionNr = GetFaction();
	if (factionNr == 1 or factionNr == 3 or factionNr == 4 or factionNr == 115) then
		factionID = 0; -- alliance
	end

	local vendor = nil;
	local vendorID = -1;

	if (self.sellVendor ~= 0) then
		vendor = self.sellVendor;
	else
		local vendorID = vendorDB:GetVendor(factionID, GetContinentID(), GetMapID(), false, false, false, false, false, x, y, z);
	
		if (vendorID ~= -1) then
			vendor = vendorDB:GetVendorByID(vendorID);
		else
			self.message = "No vendor found, see scripts\\VendorDB.lua...";
			return false;
		end
	end
	local leader = GetPartyLeaderObject();
	if (vendor ~= nil) and (leader ~= 0) then

		-- vendor distance
		local vX, vY, vZ = vendor['pos']['x'], vendor['pos']['y'], vendor['pos']['z'];
		
		-- leader distance
		local leadX, leadY, leadZ = leader:GetPosition();

		local distance = script_follow.followLeaderDistance;

	--and (leader:GetDistance() <= self.followLeaderDistance + 10)

		-- are we close enough to vendor to walk to it and sell?
		if (GetDistance3D(x, y, z, vX, vY, vZ) <= distance+10)
			and (GetDistance3D(leadX, leadY, leadZ, vX, vY, vZ) <= distance+10)
			and (GetDistance3D(x, y, z, leadX, leadY, leadZ) <= distance+10) then
			return true;
		end
	end
return false;
end

function script_followDoVendor:doSkinning()
-- Skin if there is anything skinnable within the loot radius
	if (HasSpell('Skinning') and HasItem('Skinning Knife')) and (not IsDrinking()) and (not IsEating()) and (IsStanding()) then
		self.lootObj = nil;
			-- get skin target
		self.lootObj = script_grind:getSkinTarget(script_follow.findLootDistance);
		if (not AreBagsFull() and self.lootObj ~= nil) and (not IsMoving()) then
			-- do loot
			if (script_followEX:doLoot(localObj)) then
				
			end
		end
	end
	return false;
end