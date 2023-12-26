script_druid = {

}

function script_druid:setup()

	local isBear = GetLocalPlayer():HasBuff("Bear Form");
	local isCat = GetLocalPlayer():HasBuff("Cat Form");
	if (GetLocalPlayer():GetLevel() >= 40) then
		isBear = GetLocalPlayer():HasBuff("Dire Bear Form");
	end
end

function script_druid:healsAndBuffs()

	local isBear = GetLocalPlayer():HasBuff("Bear Form");
	local isCat = GetLocalPlayer():HasBuff("Cat Form");
	if (GetLocalPlayer():GetLevel() >= 40) then
		isBear = GetLocalPlayer():HasBuff("Dire Bear Form");
	end

	-- shapeshift out of bear form to use regrowth, then use healing touch
	if (self.useBear and isBear) and (localHealth <= ) and (localMana >= ) then

	end


	-- shapeshift out of cat form to use regrowth, then use healing touch
	if (self.useCat and isCat) and (localHealth <= ) and (localMana >= ) then
	
	end

	if (not isBear) and (not isCat) and (IsStanding()) and (not IsEating()) and (not IsDrinking()) then

	end
				
return false;
end

function script_druid:run(targetGUID)

	local isBear = GetLocalPlayer():HasBuff("Bear Form");
	local isCat = GetLocalPlayer():HasBuff("Cat Form");
	if (GetLocalPlayer():GetLevel() >= 40) then
		isBear = GetLocalPlayer():HasBuff("Dire Bear Form");
	end


	--Valid Enemy
	if (targetObj ~= 0) and (not localObj:IsStunned()) then

		-- Opener
		if (not IsInCombat()) then
			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";

	
		
			-- if in bear form do these pulls
			if (self.useBear) and (isBear) and (not self.useCat) and (not isCat) then
			end


			-- if in cat form do these pulls	
			if (self.useCat) and (isCat) and (not self.useBear) and (not isBear) then
			end


			-- pull no form
			if (not self.useBear) and (not isBear) and (not self.useCat) and (not isCat) then
			end


		else	


			self.message = "Killing " .. targetObj:GetUnitName() .. "...";

			-- do these attacks only in bear form
			if (self.useBear) and (isBear) and (not isCat) and (not self.useCat) then

			end

			-- do these attacks only in cat form
			if (self.useCat) and (isCat) and (not self.useBear) and (not isBear) then

			end

			-- no form attacks
			if (not self.useBear) and (not isBear) and (not self.useCat) and (not isCat) then
			end

		end
	end 
end 

function script_druid:rest()
	return false;
end

function script_druid:mount()
	return false;
end

function script_druid:window()

	if (self.isChecked) then
	
		--Close existing Window
		EndWindow();

		if(NewWindow("Class Combat Options", 200, 200)) then
			script_druidEX:menu();
		end
	end
end
