script_checkDebuffs = {

}


-- use script_checkDebuffs:functionName(); as a boolean true or false.
-- returns true if player has debuff
-- returns false if player does not has debuff

-- make check for not specific debuffs like rend

function script_checkDebuffs:hasCurse()

	local player = GetLocalPlayer();

	if (player:HasDebuff("Curse of Mending"))
		or (player:HasDebuff("Curse of the Shadowhorn"))
		or (player:HasDebuff("Curse of Recklessness"))


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
		or (player:HasDebuff("Slowing Poison"))
		or (player:HasDebuff("Poisoned Shot"))
		or (player:HasDebuff("Venom Spit"))
		or (player:HasDebuff("Bottle of Poison"))
		or (player:HasDebuff("Venom Sting"))


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
		or (player:HasDebuff("Diseased Slime"))
	
		then

		return true;
	else

		return false;
	end
end

function script_checkDebuffs:hasMagic()


	local player = GetLocalPlayer();

	if (player:HasDebuff("Faerie Fire")) 
		or (player:HasDebuff("Sleep"))
		or (player:HasDebuff("Sap Might"))
		or (player:HasDebuff("Frost Nova"))
		or (player:HasDebuff("Fear"))
		or (player:HasDebuff("Entangling Roots"))
		or (player:HasDebuff("Sonic Burst"))

	
	then

		return true;

	else

		return false;
	end

end

function script_checkDebuffs:hasDisabledMovement()

	local player = GetLocalPlayer();

	if (player:HasDebuff("Web"))
		or (player:HasDebuff("Net"))
		or (player:HasDebuff("Frost Nova"))
		or (player:HasDebuff("Entangling Roots"))
		or (player:HasDebuff("Slowing Poison"))


	then
	
		return true;

	else 
	
		return false;
	end
end

-- pet debuff checks
function script_checkDebuffs:petDebuff()

		local class = UnitClass('player');

	if (class == 'Hunter' or class == 'Warlock') and (GetLocalPlayer():GetLevel() >= 10) and (GetPet() ~= 0) then
		local pet = GetPet();
	
		if (pet:HasDebuff("Web"))
	
	
		then
	
			return true;
		
		else
	
			return false;
		end
	end
end

-- undead will of the forsaken
function script_checkDebuffs:undeadForsaken()
		
		local player = GetLocalPlayer();
	
	if (player:HasDebuff("Sleep"))
		or (player:HasDebuff("Fear"))
		or (player:HasDebuff("Mind Control"))

	then

		return true;

	else

		return false;

	end

end

function script_checkDebuffs:hasSilence()

		local player = GetLocalPlayer();

	if (player:HasDebuff("Silence"))
	or (player:HasDebuff("Sonic Burst"))
	or (player:HasDebuff("Overwhelming Stench"))

	then
	
		return true;
	
	else

		return false;
	end
end

function script_checkDebuffs:enemyBuff()
	
	local localObj = GetLocalPlayer();
	local hasTarget = localObj:GetUnitsTarget();
	
	if (script_grind.enemyObj ~= 0 and script_grind.enemyObj ~= nil) then
		if (hasTarget ~= 0) then

			local enemy = script_grind.enemyObj;
	
			if (enemy:HasBuff("Power Word:Shield")) 
			or (enemy:HasBuff("Quick Flame Ward"))
			or (enemy:HasBuff("Rejuvenation"))
			or (enemy:HasBuff("Regrowth"))
			or (enemy:HasBuff("Renew"))
			or (enemy:HasBuff("Mana Shield"))
			


			then
			
			return true;
	
			else
		return false;
			end
		end
	end
end