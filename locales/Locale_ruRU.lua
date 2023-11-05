local L = LibStub("AceLocale-3.1"):NewLocale(O_NAME, "ruRU", false)
if not L then
	return
end

-- Russian localization
if L then
	-- CORE --
	L["Loading Scripts!"] = "Загрузка скриптов!"

	--Class Rotations NAMES (NOT CLASES)
	L["Mage"] = nil
	L["Rogue"] = nil
	L["Hunter"] = nil
	L["Warlock"] = nil
	L["Warrior"] = nil
	L["Paladin"] = nil
	L["Priest"] = nil
	L["Enhance - Shaman"] = nil
	L["Druid"] = nil

	-- deduplication
	L["Grinder"] = nil --"Гриндер"
	L["Follower"] = nil --"Следователь"
	L["Rotation"] = nil --"Ротация"
	L["Fishing"] = nil --"Рыбалка"
	L["Runner"] = nil --"Пробежка"
	L["Grind options"] = nil --"Настройки гринда"
	L["Follower options"] = nil --"Настройки следования"
	L["Fishing options"] = nil --"Настройки рыбалки"
	L["Combat options"] = nil --"Настройки боя"

end
