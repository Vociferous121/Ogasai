hotspotDB = {
	hotspotList = {},
	selectionList = {},
	numHotspots = 0,
	isSetup = false	
}

function hotspotDB:addHotspot(name, race, minLevel, maxLevel, posX, posY, posZ)
	self.hotspotList[self.numHotspots] = {};
	self.hotspotList[self.numHotspots]['name'] = name;
	self.hotspotList[self.numHotspots]['race'] = race;
	self.hotspotList[self.numHotspots]['faction'] = faction;
	self.hotspotList[self.numHotspots]['minLevel'] = minLevel;
	self.hotspotList[self.numHotspots]['maxLevel'] = maxLevel;
	self.hotspotList[self.numHotspots]['pos'] = {};
	self.hotspotList[self.numHotspots]['pos']['x'] = posX;
	self.hotspotList[self.numHotspots]['pos']['y'] = posY;
	self.hotspotList[self.numHotspots]['pos']['z'] = posZ;

	self.selectionList[self.numHotspots] = name;

	self.numHotspots = self.numHotspots + 1;
end


function hotspotDB:setup()

	-- You can set a hotspot for all races by setting the race to 'All'
	-- You can set a hotspot to only Horde or Alliance by setting race to "Horde" or "Alliance"

	-- Human 1-25
	hotspotDB:addHotspot('North Shire 1 - 2', 'Human', 1, 2, -8903.322, -69.84078, 86.58018);
	hotspotDB:addHotspot('North Shire 3 - 4', 'Human', 3, 4, -8724.425, -137.0334, 86.89613);
	hotspotDB:addHotspot('North Shire 5 - 6', 'Human', 5, 6, -9005.23, -316.80, 74.46);
	hotspotDB:addHotspot('Elvynn Forest 7 - 9', 'Human', 7, 9, -9202.76, 62.19, 77.55);
	hotspotDB:addHotspot('Westfall 10-12', 'Human', 10, 12, -9799.12, 931.79, 29.87);
	hotspotDB:addHotspot('Westfall 13-15', 'Human', 13, 15, -10254.38, 882.43, 36.67);
	hotspotDB:addHotspot('Westfall 16-17', 'Human', 16, 17, -10630.80, 797.73, 51.10);
	hotspotDB:addHotspot('Westfall 18-20', 'Human', 18, 20, -10874.41, 907.17, 37.3);
	hotspotDB:addHotspot('Duskwood 21 - 25', 'Human', 21, 25, -10759.08, 479.45, 35.19);	

	-- Night Elf 1-25
	hotspotDB:addHotspot("Teldrassil 6-8", 'Night Elf', 6, 8, 9672.04, 1014.01, 1287.04); 
	hotspotDB:addHotspot("Teldrassil 9-10", 'Night Elf', 9, 10, 9411.51, 1121.82, 1249.81); 
	hotspotDB:addHotspot("Teldrassil 11-12", 'Night Elf', 11, 12, 9428.69, 1693.50, 1304.38);
	hotspotDB:addHotspot("Darkshore 12-15", 'Night Elf', 12, 15, 6236.8, 40.65, 36.4);
	hotspotDB:addHotspot("Darkshore 16-18", 'Night Elf', 16, 18, 5314.11, 368.79, 28.98);
	hotspotDB:addHotspot("Darkshore 19-21", 'Night Elf', 19, 21, 4832.35, 423.87, 36.13);
	hotspotDB:addHotspot("Ashenvale 22-24", 'Night Elf', 22, 24, 2647.01, 168.43, 92.14);
	hotspotDB:addHotspot("Duskwood 20", 'ALL', 19, 25, -10811, 522.47, 35.07);
	hotspotDB:addHotspot("Duskwood 22", 'ALL', 21, 25, -10029.30, -783.62, 33.81);
	hotspotDB:addHotspot("Duskwood 23", 'ALL', 23, 26, -10937.13, 1251.42, 49.95);
	hotspotDB:addHotspot("Wetlands 22", 'ALL', 22, 26, -3313.56, -964.93, 9.24);
	hotspotDB:addHotspot("Wetlands 24", 'ALL', 23, 28, -2874.95, -2257.74, 26.42);
	hotspotDB:addHotspot("Wetlands 25 - 28", 'Night Elf', 25, 28, -3462.16, -1414.47, 9.38);
	hotspotDB:addHotspot("Wetlands 25 - 28", 'Human', 25, 28, -3462.16, -1414.47, 9.38);
	hotspotDB:addHotspot("Ashenvale 23", 'ALL', 22, 27, 2873.68, -910.45, 197.96);
	hotspotDB:addHotspot("Ashenvale 25", 'ALL', 24, 28, 2046.75, -1739.65, 75.40);
	hotspotDB:addHotspot("Ashenvale 25-30", 'ALL', 25, 30, 3113.14, -1511.09, 195.10);
	hotspotDB:addHotspot("The Green Belt 27 - 29", 'ALL', 27, 29, -3359.79, -3230.03, 22.16);
	hotspotDB:addHotspot("The Green Belt 27 - 29", 'ALL', 27, 29, -3274.03, -3109.39, 21.82);
	hotspotDB:addHotspot("Direforge Hill 28 - 30", 'ALL', 28, 30, -3192.38, -3017.26, 22.88);
	hotspotDB:addHotspot("Angerfang Encampment 28 - 30", 'ALL', 28, 30, -3523.15, -2486.76, 50.68);
	hotspotDB:addHotspot("Angerfang Encampment 28 - 30", 'ALL', 28, 30, -3478.35, -2414.66, 52.79);
	hotspotDB:addHotspot("Warsong Lumber Camp 27 - 30", 'ALL', 28, 30, 2563.96, -3283.46, 130.11);
	hotspotDB:addHotspot("Warsong Lumber Camp 28 - 30", 'ALL', 28, 30, 2307.86, -3347.48, 100.37);
	hotspotDB:addHotspot("Southfury River 27 - 30", 'ALL', 28, 30, 2193.73, -3535.26, 45.96);
	hotspotDB:addHotspot("Mirage Raceway 29 - 32", 'ALL', 30, 32, -5663.99, -3733.92, -58.76);
	hotspotDB:addHotspot("The Shimmering Flats 30 - 34", 'ALL', 30, 34, -5619.01, -3753.61, -58.76);
	hotspotDB:addHotspot("The Shimmering Flats 31 - 33", 'ALL', 31, 33, -6014.95, -4295.85, -58.76);
	hotspotDB:addHotspot("Arathi Highlands 31-35", 'All', 31, 35, -1084.77, -2679.63, 46.65);
	hotspotDB:addHotspot("Arathi Highlands 36-39", 'All', 36, 39, -823.66, -2276.62, 54.24);
	hotspotDB:addHotspot("Blasted Lands 51 - 55", 'All', 51, 55, -11397.15, -3005.28, -0.31);
	hotspotDB:addHotspot("Blasted Lands 53 - 56", 'ALL', 53, 56, -11199.31, -2731.2, 15.01);
	hotspotDB:addHotspot("Eastern Plaguelands SE 54 - 57", 'ALL', 54, 57, 2126.67, -2817.96, 82.92);
	hotspotDB:addHotspot("Eastern Plaguelands Left S 54 - 58", 'ALL', 54, 58, 1931.34, -4043.32, 92.43);
	hotspotDB:addHotspot("Eastern Plaguelands Left MID 55 - 59", 'ALL', 55, 59, 2377.01, -4337.23, 79.88);
	hotspotDB:addHotspot("Eastern Plaguelands Left N 56 - 60", 'ALL', 56, 60, 2778, -4142.87, 94.8);
	hotspotDB:addHotspot("Eastern Plaguelands MID MID 57 - 60", 'ALL', 57, 60, 2768.05, -4019.93, 98.54);
	hotspotDB:addHotspot("Plaguewood East 58 - 60", 'ALL', 58, 60, 3015.03, -3756.41, 129.21);
	hotspotDB:addHotspot("Plaguewood West 58 - 60", 'ALL', 58, 60, 2796.4, -3338.75, 96.86);
	hotspotDB:addHotspot("Frostsaber Rock 58 - 61", 'ALL', 58, 61, 8088, -3899.37, 697.41);

	-- Tanaris
	

	DEFAULT_CHAT_FRAME:AddMessage('hotspotDB: loaded...');
	self.isSetup = true;
end

function hotspotDB:getHotSpotByID(id)
	return self.hotspotList[id];
end

function hotspotDB:getHotspotID(race, level)
	local hotspotID = -1;

	for i=0, self.numHotspots - 1 do
		if (level >= self.hotspotList[i]['minLevel'] and level <= self.hotspotList[i]['maxLevel']) then
			
			-- Race specific or all races or faction
			if (self.hotspotList[i]['race'] == race or 
				self.hotspotList[i]['race'] == 'All' or
				self.hotspotList[i]['race'] == UnitFactionGroup("player") ) then
				hotspotID = i;
			end
		end
	end

	return hotspotID;
end