script_counterMenu = {

}

function script_counterMenu:menu()

	Text("Counters Since Last Reload - ");

		local lastReloadDeathCounter = script_grindEX.deathCounter;
		Text("Deaths : " ..lastReloadDeathCounter);

		local monsterKillCount = script_grind.monsterKillCount;
		Text("Monster Kills : " ..monsterKillCount);



		-- get copper amount
		local moneyObtainedCount = script_grind.moneyObtainedCount;

		-- get silver amount from copper
		local moneyObtainedCountSilver = math.floor(moneyObtainedCount / 100);

		-- get gold amount from copper
		local moneyObtainedCountGold = math.floor(moneyObtainedCount / 10000);

		-- silver from copper when we have gold
		local test = (moneyObtainedCount - moneyObtainedCountSilver * 100);

		-- copper from gold when we have gold??

	
		-- less than 100 copper
		if (moneyObtainedCount < 100) then
			Text("Money Obtained : " ..moneyObtainedCount.. " Copper");

		-- more than 100 copper but less than 10000 copper
		elseif (moneyObtainedCount > 100) and (moneyObtainedCount < 10000) then

			Text("Money Obtained : " ..moneyObtainedCountSilver .. " Silver " ..test.. " Copper");

		-- more than 1000 copper then we have 1 gold!
		elseif (moneyObtainedCount >= 1000) then

			Text("Money Obtained : " ..moneyObtainedCountGold.. " Gold " ..test.. " Silver");
		end

	--Text("Paranoia Used : nothing here yet!");
end