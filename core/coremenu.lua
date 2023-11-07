			---------------------------
			------GlobalVariables------
			---------------------------
	O_NAME = "oGasai";
	--MY_VERSION = "0.XXXX";
	--_G.MY_VERSION = string.match([[*<= Version '1.5.99+D20201231T235959' =>*]], "'.-'")

			----------------------------
			---------Load Libs----------
			----------------------------
	include("libs\\Libs3\\Ace3v\\LibStub\\LibStub.lua")
	include("libs\\Libs3\\Ace3v\\CallbackHandler-1.0\\CallbackHandler-1.0.lua")

	include("libs\\Libs3\\Ace3v\\AceCore-3.0\\AceCore-3.0.lua")
	include("libs\\Libs3\\Ace3v\\AceDB-3.0\\AceDB-3.0.lua")
	include("libs\\Libs3\\Ace3v\\AceDBOptions-3.0\\AceDBOptions-3.0.lua")
	include("libs\\Libs3\\Ace3v\\AceLocale-3.1\\AceLocale-3.1.lua")


	--[[
	include("libs\\Libs3\\Ace3v\\LibBabble-Class-3.0\\LibBabble-3.0.lua")
	include("libs\\Libs3\\Ace3v\\LibBabble-Class-3.0\\LibBabble-Class-3.0.lua")

	include("libs\\Libs3\\Ace3v\\LibBabble-Spell-3.0\\LibBabble-3.0.lua")
	include("libs\\Libs3\\Ace3v\\LibBabble-Spell-3.0\\LibBabble-Spell-3.0.lua")
	include("libs\\Libs3\\Ace3v\\LibBabble-Spell-3.0\\deDE.lua")
	include("libs\\Libs3\\Ace3v\\LibBabble-Spell-3.0\\esES.lua")
	include("libs\\Libs3\\Ace3v\\LibBabble-Spell-3.0\\frFR.lua")
	include("libs\\Libs3\\Ace3v\\LibBabble-Spell-3.0\\koKR.lua")
	include("libs\\Libs3\\Ace3v\\LibBabble-Spell-3.0\\zhCN.lua")
	include("libs\\Libs3\\Ace3v\\LibBabble-Spell-3.0\\zhTW.lua")
	include("libs\\Libs3\\Ace3v\\LibBabble-Spell-3.0\\ruRU.lua")
	include("libs\\Libs3\\Ace3v\\LibBabble-Spell-3.0\\Cleanup.lua")
	--]]

			----------------------------
			-----Load Localization------
			----------------------------
	include("locales\\Locale_enUS.lua")
	include("locales\\Locale_ruRU.lua")

			----------------------------
			---------Local--------------
			----------------------------
	local AceLocale = LibStub("AceLocale-3.1")
	local L = AceLocale:GetLocale(O_NAME, false)
	--local BC = AceLibrary("Babble-Class-2.2")
	--local BC = LibStub("LibBabble-Class-3.0")

coremenu = {
	--Setup
	isSetup = false,
}

function coremenu:reload()
	self.isSetup = false
	coremenu:draw()
end

function coremenu:draw()
	if self.isSetup == false then
		self.isSetup = true

	--DEFAULT_CHAT_FRAME:AddMessage(format(L["Loading Scripts! Your version "]) .. O_NAME .. " : " .. MY_VERSION)
	DEFAULT_CHAT_FRAME:AddMessage(L['Loading Scripts!']);


			----------------------------
			--------Core Files----------
			----------------------------

		include("core\\core.lua")

		-- Load DBs
		include("scripts\\db\\vendorDB.lua")
		include("scripts\\db\\hotspotDB.lua")


			----------------------------
			------Class Rotations-------
			----------------------------

		LoadScript("Mage", "scripts\\combat\\script_mage.lua")
		AddScriptToCombat(L["Mage"], "script_mage")

		LoadScript("Rogue", "scripts\\combat\\script_rogue.lua")
		AddScriptToCombat(L["Rogue"], "script_rogue")

		LoadScript("Hunter", "scripts\\combat\\script_hunter.lua")
		AddScriptToCombat(L["Hunter"], "script_hunter")

		LoadScript("Warlock", "scripts\\combat\\script_warlock.lua")
		AddScriptToCombat(L["Warlock"], "script_warlock")

		LoadScript("Warrior", "scripts\\combat\\script_warrior.lua")
		AddScriptToCombat(L["Warrior"], "script_warrior")

		LoadScript("Paladin", "scripts\\combat\\script_paladin.lua")
		AddScriptToCombat(L["Paladin"], "script_paladin")

		LoadScript("Priest", "scripts\\combat\\script_priest.lua")
		AddScriptToCombat(L["Priest"], "script_priest")

		LoadScript("Shaman", "scripts\\combat\\script_shaman.lua")
		AddScriptToCombat(L["Enhance - Shaman"], "script_shaman")

		LoadScript("Druid", "scripts\\combat\\script_druid.lua")
		AddScriptToCombat(L["Druid"], "script_druid")


			----------------------------
			----------Bot Types---------
			----------------------------

		LoadScript(L["Grinder"], "scripts\\script_grind.lua")
		AddScriptToMode(L["Grinder"], "script_grind")

		LoadScript(L["Follower"], "scripts\\script_follow.lua")
		AddScriptToMode(L["Follower"], "script_follow")

		LoadScript(L["Rotation"], "scripts\\script_rotation.lua")
		AddScriptToMode(L["Rotation"], "script_rotation")

		LoadScript(L["Fishing"], "scripts\\script_fish.lua")
		AddScriptToMode(L["Fishing"], "script_fish")

		-- Nav Mesh Runner by Rot, Improved by Logitech
		LoadScript(L["Runner"], "scripts\\script_runner.lua")
		AddScriptToMode(L["Runner"], "script_runner")

		--LoadScript("Unstuck Test", "scripts\\script_unstuck.lua");
		--AddScriptToMode("Unstuck Test", "script_unstuck");

		--LoadScript("Pather", "scripts\\script_pather.lua");
		--AddScriptToMode("Pather Debug", "script_pather");


			----------------------------
			-----Override Settings------
			----------------------------

		DrawPath(true)

		--NewTheme(false);
	end


		----------------------------
		------Append To Menu--------
		----------------------------

	-- Grind
	Separator()
	if CollapsingHeader(L["Grind options"]) then
		script_grindMenu:menu()
	end

	if CollapsingHeader(L["Follower options"]) then
		script_followEX:menu()
	end

	if CollapsingHeader(L["Fishing options"]) then
		script_fish:menu()
	end

	Separator()

	-- Add Combat scripts menus
	if CollapsingHeader(L["Combat options"]) then
		script_mageEX:menu()
		script_hunterEX:menu()
		script_warlockEX:menu()
		script_paladinEX:menu()
		script_druidEX:menu()
		script_priestEX:menu()
		script_warriorEX:menu()
		script_rogueEX:menu()
		script_shamanEX:menu()
	end
end
