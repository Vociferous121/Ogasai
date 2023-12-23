script_functions = {

}

player = GetLocalPlayer();
pet = GetPet();

function IsStealth()

	if (player:HasBuff("Stealth"))
		or (player:HasBuff("Prowl"))
	
	then
		return true;
	end
return false;
end


-- druid or shaman check forms
function HasForm()

	if (player:HasBuff("Bear Form"))
		or (player:HasBuff("Dire Bear Form"))
		or (player:HasBuff("Cat Form"))
		or (player:HasBuff("Aquatic Form"))
		or (player:HasBuff("Travel Form"))
		or (player:HasBuff("Moonkin Form"))
		or (player:HasBuff("Ghost Wolf"))
	then
		return true;
	end
return false;
end

-- druid has cat form
function IsCatForm()

	if (player:HasBuff("Cat Form"))
	
	then
		return true;
	end
return false;
end

-- druid has bear form
function IsBearForm()
	
	if (player:HasBuff("Bear Form"))
		or (player:HasBuff("Dire Bear Form"))
	
	then
		return true;

	end
return false;
end

-- druid has travel form
function IsTravelForm()
	
	if (player:HasBuff("Travel Form"))

	then
		return true;
	end
return false;
end

-- druid has aquatic form
function IsAquaticForm()
	
	if (player:HasBuff("Aquatic Form"))

	then
		return true;
	end
return false;
end

-- shaman has ghost wolf form
function IsGhostWolf()
	
	if (player:HasBuff("Ghost Wolf"))

	then
		return true;
	end
return false;
end

function PetHasTarget()
	
	if (pet ~= 0) then
		if (pet:GetUnitsTarget() ~= 0) then
			return true;
		end
	end
return false;
end

function PlayerHasTarget()
	
	if (player:GetUnitsTarget() ~= 0) then
		return true;
	end
return false;
end

function CallPet()

	if (pet == 0) then
		script_hunter.message = "Pet is missing, calling pet...";
		CastSpellByName("Call Pet");
		return true;
	end
return false;
end

