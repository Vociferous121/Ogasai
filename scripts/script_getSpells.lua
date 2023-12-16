script_getSpells = {

	getSpellsStatus = 0,
	trainerTarget = nil,

}

-- spell status 2 is moving to trainer
-- spell status 3 is buying from trainer
-- spell status 4 is done buying from trainer
function script_getSpells:run()

		local x, y, r, g, b = 0, 0, 0, 0, 0;
		DrawText("Moving To Trainer level 1 gnome area... don't use this feature...: ",  x+800, y+500, r+255, g+255, b+0);

		-- works in oGasai lua menu
		local x, y, z = GetLocalPlayer():GetPosition();

		-- get trainer to go to
		self.trainerTarget = nil;

		-- get trainer position
		
		-- gnome warlock trainer level 1 area test subject

		local vX, vY, vZ = -6048.7900390625, 391.07900292969, 398.9580078125;
		
		-- gnome warlock trainer level 6 test subject

		local vX, vY, vZ = -5640, -528.80102539063, 404.29623413086;

		-- if position not close to trainer then move to trainer
		if (GetDistance3D(x, y, z, vX, vY, vZ) > 3.5) then
			script_navEX:moveToTarget(localObj, vX, vY, vZ);
			self.getSpellsStatus = 2;
		end

		-- if distance is close to trainer then
		if (GetDistance3D(x, y, z, vX, vY, vZ) <= 4) then
			
			-- target trainer
			if (self.trainerTarget == nil) then

				local level = GetLocalPlayer():GetLevel();
					if (level < 6) then
					TargetByName("Alamar Grimm");
					end
					if (level >= 6) and (level < 10) then
					TargetByName("Gimrizz Shadowcog");
					end

					-- get target
					self.trainerTarget = GetTarget();
			end
					-- interact with trainer
					if (not self.trainerTarget:UnitInteract()) then
					end
			
			
					-- select gossip
					if (not SelectGossipOption(1)) then
					end
			
			
		-- need to do check for spells? this just buys anything available
		for i=0, 100 do
				
			-- buy from trainer spell index
			if (not BuyTrainerService(i)) then
			
			end
			i = i+1;

		--self.getSpellsStatus = 3;

	
		end
	end

return false;
end