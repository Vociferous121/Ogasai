script_followDoVendor = {

	useVendor = false,
	sellVendor = 0,
}

function script_followDoVendor:sellStuff()

	if (script_vendor:sell()) then
		return true;
	end

return false;
end

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
	
	if (vendor ~= nil) then
		local vX, vY, vZ = vendor['pos']['x'], vendor['pos']['y'], vendor['pos']['z'];
	
		if (GetDistance3D(x, y, z, vX, vY, vZ) < script_follow.followLeaderDistance) then
			return true;
		end
	end
return false;
end