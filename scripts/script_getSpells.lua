script_getSpells = {

	getSpellsStatus = 0,
	trainerTarget = nil,

}

-- spell status 1 is moving to trainer
-- spell status 2 is buying from trainer
-- spell status 3 is done buying from trainer
function script_getSpells:run()

		local x, y, r, g, b = 0, 0, 0, 0, 0;
		DrawText("Moving To Trainer level 1 gnome area... don't use this feature...: ",  x+800, y+500, r+255, g+255, b+0);

		-- works in oGasai lua menu
		local x, y, z = GetLocalPlayer():GetPosition();

		-- get trainer to go to
		self.trainerTarget = nil;

		-- get trainer position
		
		if (UnitClass('player') == "Warlock") then
		-- gnome warlock trainer level 1 area test subject

		local vX, vY, vZ = -6048.7900390625, 391.07900292969, 398.9580078125;
		self.trainerTarget = "Alamar Grimm";
		
		-- gnome warlock trainer level 6 test subject

		local vX, vY, vZ = -5640, -528.80102539063, 404.29623413086;
		self.trainerTarget = "Gimrizz Shadowcog";

		-- gnome warlock trainer level 10 ironforge test subject

		local vX, vY, vZ = -4599.080078125, -1111.6700439453, 504,93862915039;
		self.trainerTarget = "Briarthorn";
		
		-- human warlock trainer level 10 stormwind test subject
		--local vX, vY, vZ = -8980.01953125, 1041.0899658203, 101.4502166748;

		end

		--if (UnitClass('player') == 'Mage') then
		-- gnome mage trainer level 1 area test subject
		local vX, vY, vZ = -6056.08984375, 388.17498779297, 392.76116943359;
		self.trainerTarget = "Marryk Nurribit";

		--end







		-- from here on works fine - go to trainer and get spells and leave right away
		-- copy/paste vendoring logic and how it moves to and from vendor
		-- literally every vendor status apply a getSpellsStatus check


		-- if position not close to trainer then move to trainer
		if (GetDistance3D(x, y, z, vX, vY, vZ) > 3.5) then
			if (not script_unstuck:pathClearAuto(2)) then
				script_unstuck:unstuck();
				return true;
			end
			script_navEX:moveToTarget(localObj, vX, vY, vZ);
			self.getSpellsStatus = 1;
		end

		-- if distance is close to trainer then
		if (GetDistance3D(x, y, z, vX, vY, vZ) <= 4) then
			
			-- target trainer
			if (self.trainerTarget ~= nil) then	
					
					-- get target
					TargetByName(self.trainerTarget);

					self.trainerTarget = GetTarget();
			end
					-- interact with trainer
					if (not self.trainerTarget:UnitInteract()) then
					end
			
					
					-- select gossip
					SelectGossipOption(1);
					
			
			
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