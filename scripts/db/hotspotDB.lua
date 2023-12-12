hotspotDB = {
	hotspotList = {},
	selectionList = {},
	numHotspots = 0,
	isSetup = false,	
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

	-- You can set a hotspot for ALL races by setting the race to "ALL"
	-- You can set a hotspot to only Horde or "Alliance" by setting race to "Horde" or ""Alliance""



	-- "Alliance" only

	--------------------------------------------

	-- Teldrassil

	hotspotDB:addHotspot("Shadowglen 1 - 2", "Night Elf", 1, 3, 10463.98, 979.26, 1321.49);
	hotspotDB:addHotspot("Shadowglen 2 - 3", "Night Elf", 1, 3, 10540.92, 627.82, 1328.61);
	hotspotDB:addHotspot("Shadowglen 3 - 5", "Night Elf", 3, 5, 10729.28, 922.62, 1331.32);
	hotspotDB:addHotspot("Teldrassil 6 - 8", "Night Elf", 6, 8, 9873.64, 721.59, 1305.96);
	hotspotDB:addHotspot("Teldrassil 6 - 8", "Night Elf", 6, 8, 9672.04, 1014.01, 1287.04); 
	hotspotDB:addHotspot("Teldrassil 7 - 8", "Night Elf", 6, 8, 9681.1, 1195.13, 1268.12);
	hotspotDB:addHotspot("Teldrassil 7 - 9", "Night Elf", 7, 9, 9268.52, 1507.39, 1288.18);
	hotspotDB:addHotspot("Teldrassil 7 - 10", "Night Elf", 7, 9, 9877.98, 1856.31, 1317.36);
	hotspotDB:addHotspot("Teldrassil 9 - 11", "Night Elf", 9, 11, 10709.71, 1425.11, 1325.13);
	hotspotDB:addHotspot("Teldrassil 9 - 11", "Night Elf", 9, 10, 9411.51, 1121.82, 1249.81); 
	hotspotDB:addHotspot("The Oracle Glade 10 - 12", "Night Elf", 10, 12, 10888.36, 1739.92, 1318.92);
	hotspotDB:addHotspot("Teldrassil 10 - 12", "Night Elf", 11, 12, 9428.69, 1693.50, 1304.38);


	-- Darkshore

	hotspotDB:addHotspot("Darkshore 11 - 13", "Alliance", 11, 13, 6158.16, 400.18, 28.59);
	hotspotDB:addHotspot("Darkshore 11 - 13", "Alliance", 11, 13, 6466.85, 294.25, 36.86);
	hotspotDB:addHotspot("Darkshore 12 - 14", "Alliance", 12, 14, 6820.18, 186.21, 16.9);
	hotspotDB:addHotspot("Darkshore 12 - 14", "Alliance", 12, 14, 7208.56, 43.32, 10.5);
	hotspotDB:addHotspot("Darkshore 12 - 15", "Alliance", 12, 15, 6236.8, 40.65, 36.4);
	hotspotDB:addHotspot("Darkshore 14 - 16", "Alliance", 14, 16, 7077.33, -296.58, 39.9);
	hotspotDB:addHotspot("Mist's Edge 14 - 16", "Alliance", 14, 16, 7350.89, -493.95, 0.83);
	hotspotDB:addHotspot("Darkshore 16 - 18", "Alliance", 16, 18, 5314.11, 368.79, 28.98);
	hotspotDB:addHotspot("Twilight Vale 16 - 18", "Alliance", 16, 18, 5317.5, 150.43, 33.17);
	hotspotDB:addHotspot("Twilight Vale 17 - 19", "Alliance", 17, 19, 4731.28, 321.74, 52.64);
	hotspotDB:addHotspot("Twilight Vale 19 - 21", "Alliance", 19, 21, 4244.09, 489.34, 62.46);
	hotspotDB:addHotspot("Darkshore 19 - 21", "Alliance", 19, 21, 4832.35, 423.87, 36.13);


	-- elwynn forest

	hotspotDB:addHotspot('North Shire 1 - 2', "Human", 1, 2, -8903.322, -69.84078, 86.58018);
	hotspotDB:addHotspot('North Shire 3 - 4', "Human", 3, 4, -8724.425, -137.0334, 86.89613);
	hotspotDB:addHotspot('North Shire 5 - 6', "Human", 5, 6, -9005.23, -316.80, 74.46);
	hotspotDB:addHotspot('Elwynn Forest 7 - 9', "Alliance", 7, 9, -9202.76, 62.19, 77.55);
	hotspotDB:addHotspot("Northshire Valley 4 - 6", "Alliance", 4, 6, -9075.13, -216.88, 70.93);
	hotspotDB:addHotspot("Northshire Valley 1 - 3", "Human", 1, 3, -8900.33, -29.73, 90.25);
	hotspotDB:addHotspot("Echo Ridge Mine 2 - 4", "Alliance", 2, 4, -8721.64, -106.24, 86.92);
	hotspotDB:addHotspot("Northshire Valley 3 - 5", "Human", 3, 5, -8754.72, -303.78, 78.99);
	hotspotDB:addHotspot("Northshire Valley 5 - 7", "Human", 5, 7, -8863.01, -416.01, 66.07);
	hotspotDB:addHotspot("Crystal Lake 6 - 8", "Alliance", 6, 8, -9351.64, -382.51, 65.25);
	hotspotDB:addHotspot("Elwynn Forest 7 - 9", "Alliance", 7, 9, -9342.09, -832.4, 64.71);
	hotspotDB:addHotspot("Elwynn Forest 10 - 12", "Alliance", 10, 12, -9459.37, -1122.34, 52.69);
	hotspotDB:addHotspot("Ridgepoint Tower 10 - 12", "Alliance", 10, 12, -9866.62, -1350.71, 37.85);
	hotspotDB:addHotspot("Elwynn Forest 8 - 10", "Alliance", 8, 10, -9710.44, -562.66, 45.09);
	hotspotDB:addHotspot("The Stonefield Farm 6 - 8", "Alliance", 6, 8, -9994.89, 309.12, 34.82);


	-- Westfall

	hotspotDB:addHotspot('Westfall 10 - 12', "Alliance", 10, 12, -9799.12, 931.79, 29.87);
	hotspotDB:addHotspot('Westfall 13 - 15', "Alliance", 13, 15, -10254.38, 882.43, 36.67);
	hotspotDB:addHotspot('Westfall 16 - 17', "Alliance", 16, 17, -10630.80, 797.73, 51.10);
	hotspotDB:addHotspot('Westfall 18 - 20', "Alliance", 18, 20, -10874.41, 907.17, 37.3);
	hotspotDB:addHotspot("Westfall 11 - 13", "Alliance", 11, 13, -10182.11, 836.84, 34.3);
	hotspotDB:addHotspot("Westfall 15 - 17", "Alliance", 15, 17, -10040.32, 1157.56, 41.35);
	hotspotDB:addHotspot("Westfall 13 - 15", "Alliance", 13, 15, -10332.3, 1654.66, 35.71);
	hotspotDB:addHotspot("Alexston Farmstead 15 - 17", "Alliance", 15, 17, -10699.54, 1595.82, 45.62);
	hotspotDB:addHotspot("Westfall 13 - 15", "Alliance", 13, 15, -10798.02, 1077.98, 39.89);
	hotspotDB:addHotspot("The Dagger Hills 18 - 20", "Alliance", 18, 20, -11062.07, 1190.87, 45.56);
	hotspotDB:addHotspot("Westfall 12 - 14", "Alliance", 12, 14, -10283.32, 1946.14, 37.07);
	hotspotDB:addHotspot("Westfall 12 - 14", "Alliance", 12, 14, -9939.48, 1662.96, 33.26);


	-- Redridge Mountains

	hotspotDB:addHotspot("Lakeridge Highway 18 - 20", "Alliance", 18, 20, -9625.39, -2375.79, 60.54);
	hotspotDB:addHotspot("Redridge Mountains 19 - 21", "Alliance", 19, 21, -9638.33, -2888.98, 53.32);
	hotspotDB:addHotspot("Three Corners 15 - 17", "Alliance", 15, 17, -9699.48, -1812.51, 55.77);
	hotspotDB:addHotspot("Alther's Mill 20 - 22", "Alliance", 20, 22, -9163.35, -2803.23, 92.02);

	
	-- Loch Modan

	hotspotDB:addHotspot("Silver Stream Mine 10 - 12", "Alliance", 10, 12, -4851.7, -2829.11, 326.02);
	hotspotDB:addHotspot("Loch Modan 11 - 13", "Alliance", 11, 13, -5098.72, -2914.29, 326.14);
	hotspotDB:addHotspot("Loch Modan 11 - 13", "Alliance", 11, 13, -5522.93, -2807.16, 363.36);
	hotspotDB:addHotspot("Loch Modan 17 - 19", "Alliance", 17, 19, -4896.15, -3604.37, 301.81);
	hotspotDB:addHotspot("Loch Modan 15 - 17", "Alliance", 15, 17, -5310.1, -3762.13, 309.61);
	hotspotDB:addHotspot("Loch Modan 13 - 15", "Alliance", 13, 15, -5682.1, -3579.53, 309.62);
	hotspotDB:addHotspot("Grizzlepaw Ridge 14 - 16", "Alliance", 14, 16, -5659.24, -3217.88, 320.02);



	-- Duskwood

	hotspotDB:addHotspot("Duskwood 20 - 21", "Alliance", 19, 25, -10811, 522.47, 35.07);
	hotspotDB:addHotspot('Duskwood 21 - 25', "Alliance", 21, 25, -10759.08, 479.45, 35.19);	
	hotspotDB:addHotspot("Duskwood 22 - 24", "Alliance", 21, 25, -10029.30, -783.62, 33.81);
	hotspotDB:addHotspot("Duskwood 23 - 24", "Alliance", 23, 26, -10937.13, 1251.42, 49.95);
	hotspotDB:addHotspot("Duskwood 22 - 24", "Alliance", 22, 24, -11077.7, 370.85, 29.51);
	hotspotDB:addHotspot("The Darkened Bank 22 - 24", "Alliance", 22, 24, -10078.23, -1067.3, 28.1);
	hotspotDB:addHotspot("The Darkened Bank 20 - 22", "Alliance", 20, 22, -9962.79, -567.63, 35.56);
	hotspotDB:addHotspot("The Darkened Bank 20 - 22", "Alliance", 20, 22, -10173.69, 144.11, 24.73);
	hotspotDB:addHotspot("The Hushed Bank 20 - 22", "Alliance", 20, 22, -10656.7, 592.91, 21.97);
	hotspotDB:addHotspot("Addle's Stead 24 - 26", "Alliance", 24, 26, -11137.69, 192.9, 32.78);
	hotspotDB:addHotspot("Brightwood Grove 24 - 26", "Alliance", 24, 26, -10229.57, -996.97, 35.35);


	-- Dun Morogh

	hotspotDB:addHotspot("Coldridge Valley 1 - 3", "Dwarf", 1, 3, -6240.32, 331.03, 382.75);
	hotspotDB:addHotspot("Coldridge Valley 3 - 5", "Dwarf", 3, 5, -6426.68, 490.5, 384.05);
	hotspotDB:addHotspot("Coldridge Valley 2 - 4", "Dwarf", 2, 4, -6209.81, 722.07, 387.1);
	hotspotDB:addHotspot("Coldridge Valley 4 - 7", "Dwarf", 7, 9, -6537.13, 468.76, 386.5);
	hotspotDB:addHotspot("Dun Morogh 6 - 8", "Dwarf", 6, 8, -5874.11, -213.25, 360.58);
	hotspotDB:addHotspot("Dun Morogh 8 - 10", "Dwarf", 8, 10, -5630.72, 385.68, 383.5);
	hotspotDB:addHotspot("Chill Breeze Valley 7 - 9", "Dwarf", 7, 9, -5422.33, -145.01, 400.3);
	hotspotDB:addHotspot("The Tundrid Hills 8 - 10", "Dwarf", 8, 10, -5749.6, -1135.85, 381.56);
	hotspotDB:addHotspot("Dun Morogh 10 - 12", "Dwarf", 10, 12, -5593.85, -1674.8, 398.33);

	hotspotDB:addHotspot("Coldridge Valley 1 - 3", "Gnome", 1, 3, -6240.32, 331.03, 382.75);
	hotspotDB:addHotspot("Coldridge Valley 3 - 5", "Gnome", 3, 5, -6426.68, 490.5, 384.05);
	hotspotDB:addHotspot("Coldridge Valley 2 - 4", "Gnome", 2, 4, -6209.81, 722.07, 387.1);
	hotspotDB:addHotspot("Coldridge Valley 4 - 7", "Gnome", 7, 9, -6537.13, 468.76, 386.5);
	hotspotDB:addHotspot("Dun Morogh 6 - 8", "Gnome", 6, 8, -5874.11, -213.25, 360.58);
	hotspotDB:addHotspot("Dun Morogh 8 - 10", "Gnome", 8, 10, -5630.72, 385.68, 383.5);
	hotspotDB:addHotspot("Chill Breeze Valley 7 - 9", "Gnome", 7, 9, -5422.33, -145.01, 400.3);
	hotspotDB:addHotspot("The Tundrid Hills 8 - 10", "Gnome", 8, 10, -5749.6, -1135.85, 381.56);
	hotspotDB:addHotspot("Dun Morogh 10 - 12", "Gnome", 10, 12, -5593.85, -1674.8, 398.33);






	--------------------------------------------





	-- Horde only

	--------------------------------------------


	-- Mulgore
	
	hotspotDB:addHotspot("Red Cloud Mesa 1 - 3", "Tauren", 1, 3, -2889.91, -418.89, 48.47);
	hotspotDB:addHotspot("Red Cloud Mesa 2 - 4", "Tauren", 2, 4, -3488.8, -215.55, 87.16);
	hotspotDB:addHotspot("Red Cloud Mesa 3 - 5", "Tauren", 3, 5, -3385.37, -713.98, 72.89);
	hotspotDB:addHotspot("Red Cloud Mesa 4 - 6", "Tauren", 4, 6, -3271.87, -1050.56, 114.52);
	hotspotDB:addHotspot("Brambleblade Ravine 5 - 7", "Tauren", 5, 7, -2965.81, -947.1, 57.73);
	hotspotDB:addHotspot("Mulgore 6 - 8", "Tauren", 6, 8, -2617.18, -507.52, -4.55);
	hotspotDB:addHotspot("Mulgore 6 - 8", "Tauren", 6, 8, -2212.96, -3.77, 13.95);
	hotspotDB:addHotspot("Mulgore 8 - 10", "Tauren", 8, 10, -1714.66, 148.69, 3.22);
	hotspotDB:addHotspot("The Golden Plains 8 - 10", "Tauren", 8, 10, -1540.09, -302.32, -33.12);
	hotspotDB:addHotspot("The Golden Plains 9 - 11", "Tauren", 9, 11, -1202.89, -721.11, -55.54);
	hotspotDB:addHotspot("Mulgore 10 - 12", "Tauren", 10, 12, -743.25, -489.87, -25.12);
	hotspotDB:addHotspot("Mulgore 9 - 11", "Tauren", 9, 11, -2098.48, -965.92, 18.38);
	hotspotDB:addHotspot("Mulgore 10 - 12", "Tauren", 10, 12, -2311.24, -1396.28, 24.69);

	
	-- Durotar

	hotspotDB:addHotspot("Valley of Trials 1 - 3", "Troll", 1, 3, -462.48, -4245.62, 49.02);
	hotspotDB:addHotspot("Valley of Trials 4 - 6", "Troll", 4, 6, -198.38, -4281.58, 66.48);
	hotspotDB:addHotspot("Valley of Trials 2 - 4", "Troll", 2, 4, -727.41, -4294.46, 45.19);
	hotspotDB:addHotspot("Durotar 6 - 8", "Troll", 6, 8, -856.81, -4656.28, 33.61);
	hotspotDB:addHotspot("Kolkar Crag 8 - 10", "Troll", 8, 10, -969.67, -4605.44, 25.21);
	hotspotDB:addHotspot("Durotar 6 - 8", "Troll", 6, 8, -404.65, -4848.86, 37.59);
	hotspotDB:addHotspot("Tiragarde Keep 8 - 10", "Troll", 8, 10, -154.91, -5070.73, 21.32);
	hotspotDB:addHotspot("Durotar 6 - 8", "Troll", 6, 8, 271.78, -5073.19, 11.39);
	hotspotDB:addHotspot("Durotar 9 - 11", "Troll", 9, 11, 631.88, -4264.21, 15.26);
	hotspotDB:addHotspot("Southfury River 9 - 11", "Troll", 9, 11, 386.82, -3860.99, 29.52);
	hotspotDB:addHotspot("Durotar 10 - 12", "Troll", 10, 12, -154.7, -3894.87, 42.71);
	hotspotDB:addHotspot("Durotar 9 - 11", "Troll", 9, 11, 1219.31, -4056.61, 21.59);

	hotspotDB:addHotspot("Valley of Trials 1 - 3", "Orc", 1, 3, -462.48, -4245.62, 49.02);
	hotspotDB:addHotspot("Valley of Trials 4 - 6", "Orc", 4, 6, -198.38, -4281.58, 66.48);
	hotspotDB:addHotspot("Valley of Trials 2 - 4", "Orc", 2, 4, -727.41, -4294.46, 45.19);
	hotspotDB:addHotspot("Durotar 6 - 8", "Orc", 6, 8, -856.81, -4656.28, 33.61);
	hotspotDB:addHotspot("Kolkar Crag 8 - 10", "Orc", 8, 10, -969.67, -4605.44, 25.21);
	hotspotDB:addHotspot("Durotar 6 - 8", "Orc", 6, 8, -404.65, -4848.86, 37.59);
	hotspotDB:addHotspot("Tiragarde Keep 8 - 10", "Orc", 8, 10, -154.91, -5070.73, 21.32);
	hotspotDB:addHotspot("Durotar 6 - 8", "Orc", 6, 8, 271.78, -5073.19, 11.39);
	hotspotDB:addHotspot("Durotar 9 - 11", "Orc", 9, 11, 631.88, -4264.21, 15.26);
	hotspotDB:addHotspot("Southfury River 9 - 11", "Orc", 9, 11, 386.82, -3860.99, 29.52);
	hotspotDB:addHotspot("Durotar 10 - 12", "Orc", 10, 12, -154.7, -3894.87, 42.71);
	hotspotDB:addHotspot("Durotar 9 - 11", "Orc", 9, 11, 1219.31, -4056.61, 21.59);


	-- Tirisfal Glades

	hotspotDB:addHotspot("Deathknell 1 - 3", "Undead", 1, 3, 1920.98, 1656.87, 80.98);
	hotspotDB:addHotspot("Deathknell 2 - 4", "Undead", 2, 4, 2115.48, 1691.57, 73.04);
	hotspotDB:addHotspot("Deathknell 3 - 5", "Undead", 3, 5, 1888.2, 1299.41, 95.87);
	hotspotDB:addHotspot("Deathknell 4 - 6", "Undead", 4, 6, 1870.24, 1387.63, 78.07);
	hotspotDB:addHotspot("Night Web's Hollow 5 - 7", "Undead", 5, 7, 2049.17, 1819.51, 106.76);
	hotspotDB:addHotspot("Tirisfal Glades 8 - 10", "Undead", 8, 10, 2534.28, 1057.37, 84.39);
	hotspotDB:addHotspot("Stillwater Pond 7 - 9", "Undead", 7, 9, 2361.71, 763.79, 38.95);
	hotspotDB:addHotspot("Tirisfal Glades 6 - 8", "Undead", 6, 8, 2645, 221.65, 33.31);
	hotspotDB:addHotspot("Tirisfal Glades 8 - 10", "Undead", 8, 10, 1823.31, -559.25, 38.7);
	hotspotDB:addHotspot("Venomweb Vale 9 - 11", "Undead", 9, 11, 2250.96, -915.7, 75.42);


	
	-- Silverpine Forest

	hotspotDB:addHotspot("Silverpine Forest 16 - 18", "Horde", 16, 18, -522, 1323.19, 45.47);
	hotspotDB:addHotspot("Silverpine Forest 10 - 12", "Horde", 10, 12, 456.39, 1326.19, 83.7);
	hotspotDB:addHotspot("Silverpine Forest 10 - 12", "Horde", 10, 12, 740.58, 1458.97, 64.31);
	hotspotDB:addHotspot("Silverpine Forest 13 - 15", "Horde", 13, 15, 1049.6, 1364.06, 38.17);
	hotspotDB:addHotspot("North Tide's Hollow 14 - 16", "Horde", 14, 16, 806.7, 1827.12, 6.54);
	hotspotDB:addHotspot("Silverpine Forest 10 - 12", "Horde", 10, 12, 1533.23, 652.43, 44.5);



	-- Barrens

	hotspotDB:addHotspot("The Barrens 14 - 16", "Horde", 14, 16, -309.52, -3747.47, 30.29);
	hotspotDB:addHotspot("The Barrens 14 - 16", "Horde", 14, 16, -472.32, -3811.34, 29.41);
	hotspotDB:addHotspot("The Barrens 19 - 21", "Horde", 19, 21, -1476.2, -1976.99, 90.51);
	hotspotDB:addHotspot("The Barrens 12 - 14", "Horde", 12, 14, 257.04, -2593.1, 94.02);
	hotspotDB:addHotspot("The Barrens 12 - 14", "Horde", 12, 14, -480.23, -2883.45, 91.67);
	hotspotDB:addHotspot("The Barrens 10 - 12", "Horde", 10, 12, -506.16, -2507.57, 94.28);
	hotspotDB:addHotspot("The Barrens 12 - 14", "Horde", 12, 14, -75.67, -2105.67, 91.66);
	hotspotDB:addHotspot("The Barrens 10 - 12", "Horde", 10, 12, -611.31, -2775.74, 92.92);
	hotspotDB:addHotspot("The Barrens 12 - 14", "Horde", 12, 14, 217.77, -3269.73, 65.09);
	hotspotDB:addHotspot("The Barrens 17 - 19", "Horde", 17, 19, -1159.64, -3259.29, 91.68);
	hotspotDB:addHotspot("Southern Barrens 17 - 19", "Horde", 17, 19, -1747.7, -2894.05, 93.87);
	hotspotDB:addHotspot("Bramblescar 19 - 21", "Horde", 19, 21, -2088.87, -2442.84, 94.16);
	hotspotDB:addHotspot("Agama'gor 18 - 20", "Horde", 18, 20, -1720.4, -2053.41, 92.1);
	hotspotDB:addHotspot("Southern Barrens 20 - 22", "Horde", 20, 22, -2890.69, -2012.02, 91.69);
	hotspotDB:addHotspot("The Barrens 18 - 20", "Horde", 18, 20, -1505.87, -2075.98, 82.73);


	-- Swamp of Sorrows
	
	
	hotspotDB:addHotspot("Splinterspear Junction 36 - 38", "Horde", 36, 38, -10348.69, -2671.62, 22.52);
	hotspotDB:addHotspot("The Shifting Mire 36 - 38", "Horde", 36, 38, -10141.67, -3063.46, 21.31);
	hotspotDB:addHotspot("Swamp of Sorrows 40 - 42", "Horde", 40, 42, -10406.73, -3477.09, 21.03);
	hotspotDB:addHotspot("Swamp of Sorrows 40 - 42", "Horde", 40, 42, -10804.17, -3914.08, 23.41);
	hotspotDB:addHotspot("Swamp of Sorrows 42 - 44", "Horde", 42, 44, -9827.82, -4018.07, 18.32);
	hotspotDB:addHotspot("Swamp of Sorrows 36 - 38", "Horde", 36, 38, -10385.18, -2928.09, 23.48);


	-- stonetalon mountains
		
	hotspotDB:addHotspot("Stonetalon Peak 26 - 28", "Horde", 26, 28, 2729.55, 1291.17, 291.03);
	hotspotDB:addHotspot("Mirkfallon Lake 23 - 24", "Horde", 21, 23, 1720.85, 760.17, 137.51);
	hotspotDB:addHotspot("The Charred Vale 27 - 29", "Horde", 27, 29, 549.68, 1480.34, -2);
	hotspotDB:addHotspot("Windshear Crag 17 - 19", "Horde", 17, 19, 991.04, 186.08, 19.27);
	hotspotDB:addHotspot("Windshear Crag 20 - 22", "Horde", 20, 22, 1062.03, -215.35, 4.48);




	--------------------------------------------



	-- both factions

	--------------------------------------------



	-- Ashenvale

	hotspotDB:addHotspot("Ashenvale 22 - 24", "ALL", 22, 24, 2647.01, 168.43, 92.14);
	hotspotDB:addHotspot("Ashenvale 23 - 24", "ALL", 22, 27, 2873.68, -910.45, 197.96);
	hotspotDB:addHotspot("Ashenvale 25 - 26", "ALL", 24, 28, 2046.75, -1739.65, 75.40);
	hotspotDB:addHotspot("Ashenvale 25 - 30", "ALL", 25, 30, 3113.14, -1511.09, 195.10);
	hotspotDB:addHotspot("Ashenvale 20 - 22", "ALL", 20, 22, 3860.44, 737.77, 7.2);
	hotspotDB:addHotspot("Ashenvale 20 - 22", "ALL", 20, 22, 3483.87, 490.76, -0.07);
	hotspotDB:addHotspot("Ashenvale 21 - 23", "ALL", 21, 23, 2484.81, 48.37, 89.04);
	hotspotDB:addHotspot("Ashenvale 22 - 24", "ALL", 22, 24, 2199.11, -850.97, 101.92);
	hotspotDB:addHotspot("Ashenvale 23 - 25", "ALL", 23, 25, 1893.27, -1617.88, 60.79);
	hotspotDB:addHotspot("Night Run 26 - 28", "ALL", 26, 28, 2721.77, -2242.55, 197.35);
	hotspotDB:addHotspot("Falfarren River 26 - 28", "ALL", 26, 28, 2539, -2359.72, 152.31);
	hotspotDB:addHotspot("Nightsong Woods 28 - 30", "ALL", 28, 30, 2873.57, -1927.49, 162.57);
	hotspotDB:addHotspot("Moonwell 23 - 25", "ALL", 23, 25, 1871.35, -1755.21, 60.01);
	hotspotDB:addHotspot("Felfire Hill 31 - 33", "ALL", 31, 33, 2047.21, -2992.9, 106.93);

	
	-- Wetlands

	hotspotDB:addHotspot("Wetlands 22 - 23", "ALL", 22, 26, -3313.56, -964.93, 9.24);
	hotspotDB:addHotspot("Wetlands 24 - 25", "ALL", 23, 28, -2874.95, -2257.74, 26.42);
	hotspotDB:addHotspot("Wetlands 25 - 28", ALL, 25, 28, -3462.16, -1414.47, 9.38);
	hotspotDB:addHotspot("Wetlands 25 - 28", ALL, 25, 28, -3462.16, -1414.47, 9.38);
	hotspotDB:addHotspot("The Green Belt 27 - 29", "ALL", 27, 29, -3359.79, -3230.03, 22.16);
	hotspotDB:addHotspot("The Green Belt 27 - 29", "ALL", 27, 29, -3274.03, -3109.39, 21.82);
	hotspotDB:addHotspot("Direforge Hill 28 - 30", "ALL", 28, 30, -3192.38, -3017.26, 22.88);
	hotspotDB:addHotspot("Angerfang Encampment 28 - 30", "ALL", 28, 30, -3523.15, -2486.76, 50.68);
	hotspotDB:addHotspot("Angerfang Encampment 28 - 30", "ALL", 28, 30, -3478.35, -2414.66, 52.79);
	hotspotDB:addHotspot("Southfury River 27 - 30", "ALL", 28, 30, 2193.73, -3535.26, 45.96);
	hotspotDB:addHotspot("Black Channel Marsh 21 - 23", "Alliance", 21, 23, -3475.2, -1161.25, 8.91);
	hotspotDB:addHotspot("Saltspray Glen 29 - 31", "Alliance", 29, 31, -2590.45, -1742.05, 9.14);
	hotspotDB:addHotspot("The Green Belt 22 - 24", "Alliance", 22, 24, -3052.04, -2570.71, 11.63);
	hotspotDB:addHotspot("The Green Belt 28 - 30", "Alliance", 28, 30, -3260.3, -3113.92, 22.23);
	hotspotDB:addHotspot("Wetlands 21 - 23", "Alliance", 21, 23, -4082.11, -2812.67, 16.13);



	-- Thousand Needles

	hotspotDB:addHotspot("Mirage Raceway 29 - 32", "ALL", 30, 32, -5663.99, -3733.92, -58.76);
	hotspotDB:addHotspot("The Shimmering Flats 30 - 34", "ALL", 30, 34, -5619.01, -3753.61, -58.76);
	hotspotDB:addHotspot("The Shimmering Flats 31 - 33", "ALL", 31, 33, -6014.95, -4295.85, -58.76);
	hotspotDB:addHotspot("Thousand Needles 30 - 32", "ALL", 40, 42, -4365, -1010.72, -55.77);
	hotspotDB:addHotspot("Thousand Needles 30 - 32", "ALL", 30, 32, -5084.12, -1234.83, -50.74);
	hotspotDB:addHotspot("Windbreak Canyon 30 - 32", "ALL", 30, 32, -5328.81, -2867.38, -58.07);
	hotspotDB:addHotspot("Thousand Needles 30 - 32", "ALL", 30, 32, -5481.89, -3426.09, -41.26);
	hotspotDB:addHotspot("The Shimmering Flats 35 - 37", "ALL", 35, 37, -6499.72, -3674.14, -58.76);
	hotspotDB:addHotspot("The Shimmering Flats 33 - 35", "ALL", 33, 35, -5941.85, -3609.42, -58.76);
	
	
	-- Dustwallow Marsh


	hotspotDB:addHotspot("The Quagmire 39 - 41", "ALL", 39, 41, -4114.3, -3065.3, 37.51);
	hotspotDB:addHotspot("The Quagmire 37 - 39", "ALL", 37, 39, -3594.52, -3230.73, 34.07);
	hotspotDB:addHotspot("Dustwallow Marsh 36 - 38", "ALL", 36, 38, -3011.72, -3164.61, 30.22);
	hotspotDB:addHotspot("Dustwallow Marsh 38 - 40", "ALL", 38, 40, -2685.9, -3518.84, 34.24);


	-- Stranglethorn Vale

	hotspotDB:addHotspot("Stranglethorn Vale 30 - 32", "ALL", 30, 32, -11761.03, -141.24, 3.88);
	hotspotDB:addHotspot("Stranglethorn Vale 35 - 37", "ALL", 35, 37, -12021.73, -223.2, 14.43);
	hotspotDB:addHotspot("Stranglethorn Vale 38 - 40", "ALL", 38, 40, -12368.51, -449.79, 15.32);
	hotspotDB:addHotspot("Stranglethorn Vale 32 - 34", "ALL", 32, 34, -11663.33, -377.9, 15.89);
	hotspotDB:addHotspot("Stranglethorn Vale 34 - 36", "ALL", 34, 36, -11974.44, -70.5, 3.52);
	hotspotDB:addHotspot("Stranglethorn Vale 40 - 42", "ALL", 40, 42, -12872.79, -104.37, 5.92);
	hotspotDB:addHotspot("Southern Savage Coast 40 - 42", "ALL", 40, 42, -13266.87, 555.6, 0.35);


	-- Hillsbrad Foothills
	hotspotDB:addHotspot("Hillsbrad Foothills 23 - 25", "ALL", 23, 25, -256.12, -658.98, 55.77);
	hotspotDB:addHotspot("Nethander Stead 25 - 27", "ALL", 25, 27, -769.46, -1016, 41.12);
	hotspotDB:addHotspot("Nethander Stead 27 - 29", "ALL", 27, 29, -1025.12, -871.5, 35.51);
	hotspotDB:addHotspot("Hillsbrad Foothills 26 - 28", "ALL", 26, 28, -811.02, -1442.8, 60.7);
	hotspotDB:addHotspot("Hillsbrad Foothills 26 - 28", "ALL", 26, 28, -887.8, -5.65, 25.84);
	hotspotDB:addHotspot("Hillsbrad Fields 21 - 23", "ALL", 21, 23, -459.45, 309.12, 91.67);

	
	-- Arathi Highlands

	hotspotDB:addHotspot("Arathi Highlands 31 - 35", "ALL", 31, 35, -1084.77, -2679.63, 46.65);
	hotspotDB:addHotspot("Arathi Highlands 36 - 39", "ALL", 36, 39, -823.66, -2276.62, 54.24);
	hotspotDB:addHotspot("Arathi Highlands 33 - 35", "ALL", 33, 35, -1438.33, -3360.59, 41.4);
	hotspotDB:addHotspot("Arathi Highlands 37 - 39", "ALL", 37, 39, -2031.29, -2591.7, 74.95);
	hotspotDB:addHotspot("Circle of Inner Binding 33 - 35", "ALL", 33, 35, -1688.72, -2261.34, 36.89);
	hotspotDB:addHotspot("Arathi Highlands 33 - 35", "ALL", 33, 35, -1238.38, -1653.26, 55.42);
	hotspotDB:addHotspot("Arathi Highlands 31 - 33", "ALL", 31, 33, -571.23, -1943.66, 53.61);
	hotspotDB:addHotspot("Arathi Highlands 36 - 38", "ALL", 36, 38, -785.85, -2305.02, 57.52);
	hotspotDB:addHotspot("Dabyrie's Farmstead 33 - 35", "ALL", 33, 35, -1037.07, -2711.95, 45.24);
	hotspotDB:addHotspot("Arathi Highlands 31 - 33", "ALL", 31, 33, -1220, -3111.85, 40.31);


	-- Hinterlands

	hotspotDB:addHotspot("The Hinterlands 40 - 42", "ALL", 40, 42, 150.85, -2153.01, 102.81);
	hotspotDB:addHotspot("The Hinterlands 42 - 44", "ALL", 42, 44, 51.94, -2586.64, 113.11);
	hotspotDB:addHotspot("The Hinterlands 44 - 46", "ALL", 44, 46, 162.15, -2939.83, 114.46);
	hotspotDB:addHotspot("The Hinterlands 46 - 48", "ALL", 46, 48, 211.03, -3373.97, 115.04);
	hotspotDB:addHotspot("The Hinterlands 47 - 49", "ALL", 47, 49, 198.24, -3827.87, 134.85);
	hotspotDB:addHotspot("The Hinterlands 49 - 51", "ALL", 49, 51, 233.32, -4136.04, 117.11);
	hotspotDB:addHotspot("The Overlook Cliffs 50 - 52", "ALL", 50, 52, -33.56, -4622.9, 9.48);

	
	-- Blasted Lands

	hotspotDB:addHotspot("Blasted Lands 51 - 55", "ALL", 51, 55, -11397.15, -3005.28, -0.31);
	hotspotDB:addHotspot("Blasted Lands 53 - 56", "ALL", 53, 56, -11199.31, -2731.2, 15.01);
	hotspotDB:addHotspot("Dreadmaul Hold 50 - 52", "ALL", 50, 52, -10991.81, -2904.41, 9.95);
	hotspotDB:addHotspot("Blasted Lands 50 - 52", "ALL", 50, 52, -11458.4, -2962.95, 8.08);
	hotspotDB:addHotspot("Blasted Lands 52 - 54", "ALL", 52, 54, -11686.97, -2780.07, 6.81);
	hotspotDB:addHotspot("Rise of the Defiler 50 - 52", "ALL", 50, 52, -11195.1, -2739.34, 16.01);



	-- Eastern Plaguelands

	hotspotDB:addHotspot("Eastern Plaguelands SE 54 - 57", "ALL", 54, 57, 2126.67, -2817.96, 82.92);
	hotspotDB:addHotspot("Eastern Plaguelands Left S 54 - 58", "ALL", 54, 58, 1931.34, -4043.32, 92.43);
	hotspotDB:addHotspot("Eastern Plaguelands Left MID 55 - 59", "ALL", 55, 59, 2377.01, -4337.23, 79.88);
	hotspotDB:addHotspot("Eastern Plaguelands Left N 56 - 60", "ALL", 56, 60, 2778, -4142.87, 94.8);
	hotspotDB:addHotspot("Eastern Plaguelands MID MID 57 - 60", "ALL", 57, 60, 2768.05, -4019.93, 98.54);
	hotspotDB:addHotspot("Plaguewood East 58 - 60", "ALL", 58, 60, 3015.03, -3756.41, 129.21);
	hotspotDB:addHotspot("Plaguewood West 58 - 60", "ALL", 58, 60, 2796.4, -3338.75, 96.86);
	hotspotDB:addHotspot("Frostsaber Rock 58 - 61", "ALL", 58, 61, 8088, -3899.37, 697.41);
	

	-- Desolace

	hotspotDB:addHotspot("Desolace 30 - 32", "ALL", 30, 32, -388.74, 1051.17, 92.71);
	hotspotDB:addHotspot("Desolace 30 - 32", "ALL", 30, 32, -388.74, 1051.17, 92.71);
	hotspotDB:addHotspot("Desolace 36 - 38", "ALL", 36, 38, -939.96, 1585.19, 61.85);
	hotspotDB:addHotspot("Desolace 32 - 34", "ALL", 32, 34, -526.92, 2049.89, 89.35);
	hotspotDB:addHotspot("Desolace 36 - 38", "ALL", 36, 38, -1524.2, 1778.36, 60.93);


	-- Badlands
	
	hotspotDB:addHotspot("Badlands 36 - 38", "ALL", 36, 38, -6748.43, -3399.52, 241.98);
	hotspotDB:addHotspot("Dustwind Gulch 36 - 38", "ALL", 36, 38, -6346.24, -3582.4, 241.69);
	hotspotDB:addHotspot("Mirage Flats 40 - 42", "ALL", 40, 42, -7147.27, -2864.05, 245.25);
	hotspotDB:addHotspot("The Dustbowl 38 - 40", "ALL", 38, 40, -6635.92, -2939.97, 241.66);
	hotspotDB:addHotspot("Mirage Flats 39 - 41", "ALL", 39, 41, -6918.6, -3100.37, 255.48);
	hotspotDB:addHotspot("Apocryphan's Rest 39 - 41", "ALL", 39, 41, -6952.19, -2530.21, 242.57);


	-- Feralas
		
	hotspotDB:addHotspot("The Twin Colossals 50 - 52", "ALL", 50, 52, -3439.71, 2398.47, 46.15);
	hotspotDB:addHotspot("Dire Maul 45 - 47", "ALL", 45, 47, -4655.83, 1624.32, 116.8);
	hotspotDB:addHotspot("High Wilderness 43 - 45", "ALL", 43, 45, -5076.17, 1391.14, 44.07);
	hotspotDB:addHotspot("Frayfeather Highlands 45 - 47", "ALL", 45, 47, -5454.33, 1692.22, 57.43);
	hotspotDB:addHotspot("Ruins of Isildien 47 - 49", "ALL", 47, 49, -5851.54, 1514.73, 83.79);
	hotspotDB:addHotspot("Feralas 41 - 43", "ALL", 41, 43, -4435.83, 610.59, 61.46);
	hotspotDB:addHotspot("Lower Wilds 40 - 42", "ALL", 40, 42, -4482.63, -477.85, 21.37);


	-- Tanaris
		
	hotspotDB:addHotspot("Abyssal Sands 43 - 45", "ALL", 43, 45, -7435.5, -3323.16, 11.84);
	hotspotDB:addHotspot("Abyssal Sands 45 - 47", "ALL", 45, 47, -8091.8, -2924.75, 40.54);
	hotspotDB:addHotspot("Abyssal Sands 47 - 49", "ALL", 47, 49, -8182.55, -3524.42, 29.48);
	hotspotDB:addHotspot("Tanaris 45 - 47", "ALL", 45, 47, -8192.42, -4254.05, 10.52);
	hotspotDB:addHotspot("Valley of the Watchers 49 - 51", "ALL", 49, 51, -9274.65, -2824.96, 9.35);
	hotspotDB:addHotspot("Southbreak Shore 49 - 51", "ALL", 49, 51, -8454.05, -4959.63, 2.92);
	hotspotDB:addHotspot("Wavestrider Beach 41 - 43", "ALL", 41, 43, -7140.44, -4861.29, 0.56);
	hotspotDB:addHotspot("Land's End Beach 50 - 52", "ALL", 50, 52, -10205.85, -4013.27, 4.69);


	-- Searing Gorge
	
	
	hotspotDB:addHotspot("The Sea of Cinders 47 - 49", "All", 47, 49, -7145.73, -1370.6, 244.7);
	hotspotDB:addHotspot("Searing Gorge 49 - 51", "All", 49, 51, -6654.9, -1178.89, 244.01);
	hotspotDB:addHotspot("Firewatch Ridge 48 - 50", "All", 48, 50, -6717.13, -1022.43, 240.86);
	hotspotDB:addHotspot("Searing Gorge 50 - 52", "All", 50, 52, -7186.12, -984.78, 244.12);	


	-- Burning Steppes
	
	hotspotDB:addHotspot("Ruins of Thaurissan 56 - 58", "ALL", 56, 58, -7905.86, -2055.05, 133.16);


	-- Un'Goro Crater
	
	
	hotspotDB:addHotspot("The Marshlands 50 - 52", "ALL", 50, 52, -7805.23, -2000.97, -269.87);
	hotspotDB:addHotspot("Un'Goro Crater 52 - 54", "ALL", 52, 54, -7520.11, -1404.74, -268.48);
	hotspotDB:addHotspot("Lakkari Tar Pits 51 - 53", "ALL", 51, 53, -6739.94, -1578.5, -272.22);
	hotspotDB:addHotspot("Un'Goro Crater 55 - 57", "ALL", 55, 57, -6889.21, -943.42, -271.58);

	-- Azshara

	hotspotDB:addHotspot("Lake Mennar 52 - 54", "ALL", 52, 54, 2907.41, -5273.71, 131.52);
	hotspotDB:addHotspot("Thalassian Base Camp 52 - 54", "ALL", 52, 54, 4468.9, -6031.03, 96.7);
	hotspotDB:addHotspot("Tower of Eldara 54 - 56", "ALL", 54, 56, 4301.6, -7751.63, 7.79);


	-- Felwood
	hotspotDB:addHotspot("Ruins of Constellas 51 - 53", "ALL", 51, 53, 4606.56, -796.35, 290.43);
	hotspotDB:addHotspot("Felwood 50 - 52", "ALL", 50, 52, 5464.45, -524.04, 366.16);
	hotspotDB:addHotspot("Irontree Woods 53 - 55", "ALL", 53, 55, 6148.78, -1050.13, 384.48);
	hotspotDB:addHotspot("Irontree Woods 54 - 56", "ALL", 54, 56, 6296.06, -1591.36, 458.91);



	-- Winterspring
	hotspotDB:addHotspot("Winterspring 59 - 61", "ALL", 59, 61, 7835.21, -4586.09, 697.26);
	hotspotDB:addHotspot("Frostsaber Rock 59 - 61", "ALL", 59, 61, 7669.78, -3998.45, 703.34);
	hotspotDB:addHotspot("Winterspring 55 - 57", "ALL", 55, 57, 6576.39, -4684.11, 699.1);
	hotspotDB:addHotspot("Ice Thistle Hills 57 - 59", "ALL", 57, 59, 6404.35, -5016.44, 744.49);
	hotspotDB:addHotspot("Timbermaw Post 54 - 56", "ALL", 54, 56, 6488.25, -3396.57, 596.02);
	hotspotDB:addHotspot("Frostfire Hot Springs 54 - 56", "ALL", 54, 56, 6654.43, -2552.73, 527.89);


	-- Silithus

	hotspotDB:addHotspot("Silithus 58 - 60", "ALL", 58, 60, -7408.06, 937.24, 2.76);
	hotspotDB:addHotspot("Hive'Zora 57 - 59", "ALL", 57, 59, -7456.45, 1366.81, 4.1);
	hotspotDB:addHotspot("Silithus 57 - 59", "ALL", 57, 59, -7350.57, 660.99, -0.15);
	hotspotDB:addHotspot("Silithus 59 - 61", "ALL", 59, 61, -7971.08, 949.06, 3.76);
	hotspotDB:addHotspot("Hive'Ashi 55 - 57", "ALL", 55, 57, -6539.56, 1229.37, 4.43);
	hotspotDB:addHotspot("Silithus 59 - 61", "ALL", 59, 61, -6656.09, 1758.5, 3.19);

	
	-- Add new paths here above here
	
	self.isSetup = true;
end

function hotspotDB:getHotSpotByID(id)
	return self.hotspotList[id];
end

function hotspotDB:getHotspotID(race, level)
	local hotspotID = -1;

	for i=0, self.numHotspots - 1 do
		if (level >= self.hotspotList[i]['minLevel'] and level <= self.hotspotList[i]['maxLevel']) then

			local myX, myY, myZ = GetLocalPlayer():GetPosition();
 			
			local distanceX = (self.hotspotList[i]['pos']['x'] - myX); 
			local distanceY = (self.hotspotList[i]['pos']['y'] - myY);
			local distanceX2 = (myX - self.hotspotList[i]['pos']['x']); 
			local distanceY2 = (myY - self.hotspotList[i]['pos']['y']);
 			
			-- go to closest location if possible
			if (myX < 0) then
				if (distanceX < 1000 and distanceY < 1000) then			
					hotspotID = i;
				end
			elseif (myX > 0) then
				if (distanceX2 < 1000 and distanceY2 < 1000) then
					hotspotID = i;
				end
			end
				
			
		end
	end

	return hotspotID;
end