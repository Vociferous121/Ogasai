script_followDoVendor = {

	useVendor = false,
}

function script_followDoVendor:sellStuff()

	if (script_vendor:sell()) then
		return true;
	end

return false;
end