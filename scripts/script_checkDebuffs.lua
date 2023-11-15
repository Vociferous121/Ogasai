script_checkDebuffs = {

}

function script_checkDebuffs:hasPoison()

	local player = GetLocalPlayer();

	if (player:HasDebuff("Weak Poison"))
		or (player:HasDebuff("Corrosive Poison"))
		or (player:HasDebuff("Poison"))
		or (player:HasDebuff("Corrosive Poison"))
		or (player:HasDebuff("Slowing Poison"))


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

	if (player:HasDebuff("Web"))


	then
	
		return true;

	else 
	
		return false;
	end
end

-- pet debuff checks
function script_checkDebuffs:petDebuff()

	local pet = GetPet();

	if (pet:HasDebuff("Web"))


	then

		return true;
	
	else

		return false;
	end
end