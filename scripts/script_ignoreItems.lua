script_ignoreItems = {

	items = {},
	numItem = 0,

}


function_ignoreItems:setup()

	-- add new items here



	script_ignoreItems:addItem("OOX-22/FE Distress Beacon");
	script_ignoreItems:addItem("OOX-17/TN Distress Beacon");
	script_ignoreItems:addItem("OOX-09/HL Distress Beacon");
	script_ignoreItems:addItem("Mangled Journal");


end

function script_ignoreItems:addItem()
	self.items[self.numItems] = name;
	self.numItems = self.numItems +1;
end

function script_ignoreItems:deleteItem()

	---- Search for items
	local itemIndex = -1;
	for i=0,self.numItems do
		if (HasItem(self.items[i])) then
			itemIndex = i;
			break;
		end
	end
		
	if(HasItem(self.item[itemIndex])) then
		if (DeleteItem(self.[itemIndex])) then
			return true;
		end
	end
end