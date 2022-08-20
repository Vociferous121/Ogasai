

		-- this runs when you click a button....


function script_follow:selectTank() -- we need some argument here
		partyTank =  -- we need to find out how to get current target GUID or ingame name?
						-- get partmemberindex(tank) set that party index as follower
		--for i = 1, GetNumPartyMembers()+1 do -- if number number of party members are +1 or +2... till no more +
		--local partyMember = GetPartyMember(i);
		for i = 1, GetPartyMember()+1 do
		
				
local partyTank = GetGUIDObject(targetGUID);


				-- we need to set localpartymember as an argument to call in another function?
			
			-- if button pushed then we want that party member INDEX to be follower...
		    -- pushing the button is done elsewhere... when button is pushed... do

		  -- if current targeted partymember is index # then run script?
		-- we are already selecting the target ingame... we just need to tell the bot that target is the tank!
		
	if button clicked then --run this but don't really do anything
							--we are setting variables more

		if	targetobj  partyMemberA == 1  -- if party member 1 is selected
			  then partyMemberA = partyTank;
			  return true;
		end
		if partyMemberB == 2
			then partyMemberB = partyTank;
			return true;
		end
													-- we have set known variables to use later
		if partyMemberC == 3
			then partyMemberC = partyTank;
			return true;
		end

		if partyMemberD == 4
		then partyMemberD = partyTank;
			return true;
		end

	end		-- based on the numnbers returned 1-4 

	if 



	if (i == GetNumPartyMembers()+1) then partyMember = GetLocalPlayer();
		end




		return partyTank








	-- button to add to intferface
	if Button("Set Tank Target!") then  -- if button clicked
		script_follow:selectTank();   --  set current target as tank
			return true;				-- it will need to have anrugment of targetGUID
	end
