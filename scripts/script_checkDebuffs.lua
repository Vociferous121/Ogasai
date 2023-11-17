script_checkDebuffs = {

}


-- use script_checkDebuffs:functionName(); as a boolean true or false.
-- returns true if player has debuff
-- returns false if player does not has debuff



function script_checkDebuffs:hasCurse()

	local localplayer = GetLocalPlayer();

	if (player:HasDebuff("Curse of Mending"))


	then

		return true;

	else

		return false;
	end

end

function script_checkDebuffs:hasPoison()

	local player = GetLocalPlayer();

	if (player:HasDebuff("Weak Poison"))
		or (player:HasDebuff("Corrosive Poison"))
		or (player:HasDebuff("Poison"))
		or (player:HasDebuff("Corrosive Poison"))
		or (player:HasDebuff("Slowing Poison"))
		or (player:HasDebuff("Poisoned Shot"))


		then

		return true;
	else

		return false;
	end
end

function script_checkDebuffs:hasDisease()

	local player = GetLocalPlayer();

	if (player:HasDebuff("Rabies"))
		or (player:HasDebuff("Fevered Fatigue"))
		or (player:HasDebuff("Dark Sludge"))
		or (player:HasDebuff("Infected Bite"))
		or (player:HasDebuff("Wandering Plague"))
		or (player:HasDebuff("Plague Mind"))
		or (player:HasDebuff("Fevered Fatigue"))
		or (player:HasDebuff("Tetanus")) 
		or (player:HasDebuff("Creeping Mold"))
	
		then

		return true;
	else

		return false;
	end
end

function script_checkDebuffs:hasMagic()


	local player = GetLocalPlayer();

	if (player:HasDebuff("Faerie Fire")) 

	
	then

		return true;

	else

		return false;
	end

end

function script_checkDebuffs:hasDisabledMovement()

	local player = GetLocalPlayer();

	if (player:HasDebuff("Web")) or
	(player:HasDebuff("Net")) or
	(player:HasDebuff("Frost Nova"))


	then
	
		return true;

	else 
	
		return false;
	end
end

-- pet debuff checks
function script_checkDebuffs:petDebuff()

		local class = UnitClass('player');

	if ((class == 'Hunter')) and (GetLocalPlayer():GetLevel() > 10) then
		local pet = GetPet();
	
		if (pet:HasDebuff("Web"))
	
	
		then
	
			return true;
		
		else
	
			return false;
		end
	end
end