--[[
Name: LibBabble-Class-3.0
Revision: $Rev: 63957 $
Author(s): ckknight (ckknight@gmail.com)
Website: http://ckknight.wowinterface.com/
Description: A library to provide localizations for classes.
Dependencies: None
License: MIT
]]

local MAJOR_VERSION = "LibBabble-Class-3.0"
local MINOR_VERSION = 63957

if not LibStub then error("LibBabble-Class-3.0 requires LibStub.") end
local lib = LibStub("LibBabble-3.0"):New(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

lib:SetBaseTranslations {
	Warlock = true,
	Warrior = true,
	Hunter = true,
	Mage = true,
	Priest = true,
	Druid = true,
	Paladin = true,
	Shaman = true,
	Rogue = true,
}

local l = GetLocale()
if l == "enUS" then
	lib:SetCurrentTranslations(true)
elseif l == "deDE" then
	lib:SetCurrentTranslations {
		Warlock = "Hexenmeister",
		Warrior = "Krieger",
		Hunter = "J\195\164ger",
		Mage = "Magier",
		Priest = "Priester",
		Druid = "Druide",
		Paladin = "Paladin",
		Shaman = "Schamane",
		Rogue = "Schurke",
	}
elseif l == "ruRU" then
	lib:SetCurrentTranslations {
		Warlock = "Чернокнижник",
		Warrior = "Воин",
		Hunter = "Охотник",
		Mage = "Маг",
		Priest = "Жрец",
		Druid = "Друид",
		Paladin = "Паладин",
		Shaman = "Шаман",
		Rogue = "Разбойник",
	}
elseif l == "frFR" then
	lib:SetCurrentTranslations {
		Warlock = "Démoniste",
		Warrior = "Guerrier",
		Hunter = "Chasseur",
		Mage = "Mage",
		Priest = "Prêtre",
		Druid = "Druide",
		Paladin = "Paladin",
		Shaman = "Chaman",
		Rogue = "Voleur",
	}
elseif l == "zhCN" then
	lib:SetCurrentTranslations {
		Warlock = "术士",
		Warrior = "战士",
		Hunter = "猎人",
		Mage = "法师",
		Priest = "牧师",
		Druid = "德鲁伊",
		Paladin = "圣骑士",
		Shaman = "萨满祭司",
		Rogue = "潜行者",
	}
elseif l == "zhTW" then
	lib:SetCurrentTranslations {
		Warlock = "術士",
		Warrior = "戰士",
		Hunter = "獵人",
		Mage = "法師",
		Priest = "牧師",
		Druid = "德魯伊",
		Paladin = "聖騎士",
		Shaman = "薩滿",
		Rogue = "盜賊",
	}
elseif l == "koKR" then
	lib:SetCurrentTranslations {
		Warlock = "흑마법사",
		Warrior = "전사",
		Hunter = "사냥꾼",
		Mage = "마법사",
		Priest = "사제",
		Druid = "드루이드",
		Paladin = "성기사",
		Shaman = "주술사",
		Rogue = "도적",
	}
elseif l == "esES" then
	lib:SetCurrentTranslations {
		Warlock = "Brujo",
		Warrior = "Guerrrero",
		Hunter = "Cazador",
		Mage = "Mago",
		Priest = "Sacerdote",
		Druid = "Druida",
		Paladin = "Palad\195\173n",
		Shaman = "Cham\195\161n",
		Rogue = "P\195\173caro",
	}
else
	error(string.format("%s: Locale %q not supported", MAJOR_VERSION, GAME_LOCALE))
end

