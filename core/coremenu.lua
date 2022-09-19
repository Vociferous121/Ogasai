coremenu = {
	--Setup
	isSetup = false,
}

function coremenu:reload()
	self.isSetup = false;
	coremenu:draw();
end

function coremenu:draw()

	if (self.isSetup == false) then
		
		self.isSetup = true;
		
		DEFAULT_CHAT_FRAME:AddMessage('Loading Scripts!');
		
		--[[
			----------------------------
			Core Files
			----------------------------
		]]--
		
		include("core\\core.lua");	
        
		-- Load DBs
		include("scripts\\db\\vendorDB.lua");
		include("scripts\\db\\hotspotDB.lua");


		--[[
			----------------------------
			Class Rotations
			----------------------------
		]]--
		
		LoadScript("Mage", "scripts\\combat\\script_mage.lua");
		AddScriptToCombat("Mage", "script_mage");

		LoadScript("Rogue", "scripts\\combat\\script_rogue.lua");
		AddScriptToCombat("Rogue", "script_rogue");

		LoadScript("Hunter", "scripts\\combat\\script_hunter.lua");
		AddScriptToCombat("Hunter", "script_hunter");
		
		LoadScript("Warlock", "scripts\\combat\\script_warlock.lua");
		AddScriptToCombat("Warlock", "script_warlock");

		LoadScript("Warrior", "scripts\\combat\\script_warrior.lua");
		AddScriptToCombat("Warrior", "script_warrior");

		LoadScript("Paladin", "scripts\\combat\\script_paladin.lua");
		AddScriptToCombat("Paladin", "script_paladin");

		LoadScript("Priest", "scripts\\combat\\script_priest.lua");
		AddScriptToCombat("Priest", "script_priest");

		LoadScript("Shaman", "scripts\\combat\\script_shaman.lua");
		AddScriptToCombat("Enhance - Shaman", "script_shaman");

		LoadScript("Druid", "scripts\\combat\\script_druid.lua");
		AddScriptToCombat("Druid", "script_druid");

		--[[
			----------------------------
			Bot Types
			----------------------------
		]]--
	
		LoadScript("Grinder", "scripts\\script_grind.lua");
		AddScriptToMode("Grinder", "script_grind");

		LoadScript("Follower", "scripts\\script_follow.lua");
		AddScriptToMode("Follower", "script_follow");

		LoadScript("Rotation", "scripts\\script_rotation.lua");
		AddScriptToMode("Rotation", "script_rotation");

		LoadScript("Fishing", "scripts\\script_fish.lua");
		AddScriptToMode("Fishing", "script_fish");

		-- Nav Mesh Runner by Rot, Improved by Logitech
		LoadScript("Runner", "scripts\\script_runner.lua");
		AddScriptToMode("Runner", "script_runner");

		--LoadScript("Unstuck Test", "scripts\\script_unstuck.lua");
		--AddScriptToMode("Unstuck Test", "script_unstuck");

		--LoadScript("Pather", "scripts\\script_pather.lua");
		--AddScriptToMode("Pather Debug", "script_pather");
		
		--[[
			----------------------------
			Override Settings
			----------------------------
		]]--
	
		DrawPath(true);
		
		--NewTheme(false);
		
	end

	--[[
		----------------------------
		Append To Menu
		----------------------------
	]]--

	-- Grind 
	Separator();
	if (CollapsingHeader("Grind options")) then
		script_grindMenu:menu();
	end

	if (CollapsingHeader("Follower options")) then
		script_followEX:menu();
	end

	if (CollapsingHeader("Fishing options")) then
		script_fish:menu();
	end
	
	Separator();

	-- Add Combat scripts menus
	if (CollapsingHeader("Combat options")) then
		script_mageEX:menu();
		script_hunterEX:menu();
		script_warlockEX:menu();
		script_paladinEX:menu();
		script_druidEX:menu();
		script_priestEX:menu();
		script_warriorEX:menu();
		script_rogueEX:menu();
		script_shamanEX:menu();
	end
	
end