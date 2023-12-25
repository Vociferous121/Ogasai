script_tools = {

	typeObj3List = {},
	typeObj3ListNum = 0,
	isSetup = false,

}


function script_tools:setup()

	if NewWindow("Toolbox", 350, 300) then
		script_tools:display();
	end

end

function script_tools:display()

	if (CollapsingHeader("typeObj == 3")) then
	--	for i = 1, self.typeObj3ListNum do 
  
	--		Text(self.typeObj3List[i]);
	--		DEFAULT_CHAT_FRAME:AddMessage("ABC");
   		 --do something
  
	--	end
	
	end
			

		

	if (CollapsingHeader("typeObj == 2")) then

	end
end

function script_tools:run()

	script_tools:getGUIDS();
script_tools:setup()

end
function script_tools:typeObj3(i)
	i = i:GetGUID();
	if (i ~= nil and i ~= 0 and i ~= '') then	
		self.typeObj3List[self.typeObj3ListNum] = i;
		self.typeObj3ListNum = self.typeObj3ListNum + 1;
	end
end
function script_tools:typeObj3Check(i)
	i = i:GetGUID();
	for i = 0, self.typeObj3ListNum do
		if (i == self.typeObj3List[i]) then
			return true;
		end
	end
	return false;
end


function script_tools:getGUIDS(i)
local i, targetType = GetFirstObject();
	
	while i ~= 0 do
		if typeObj == 3 then
			if (not script_tools:typeObj3Check(i)) then
				script_tools:typeObj3(i);
			end
		end
	i, typeObj = GetNextObject(i);
	end
end
				


		--if typeObj == 2 then
		
		--if typeObj == 3 then
	
		--if typeObj == 4 then

		--if typeObj == 5 then
		
		--if typeObj == 6 then
