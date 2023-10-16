script_radar = {
    timer = 0,
    tickRate = 100,
    radarOffsetX = 800,
    radarOffsetY = 600,
    radiusOne = 60,
    radiusTwo = 150,
    radarScale = 35,
    showRadar = false,
    drawRadarFriendlyPlayer = true,
    drawRadarHostilePlayer = true,
    drawRadarMob = false,
    drawNavFriendlyPlayers = false,
    drawNavHostilePlayers = false,
    drawNavMonsters = false,
}

function script_radar:draw()    
    if (self.showRadar) then
        script_radar:Radar();
    end        
end

function script_radar:drawUnitOnRadar(aUnit, unitType)
    
    local red = 128; local green = 192; local blue = 128;
    local name = ''; local radarName = ''; local screenName = '';
    local me = GetLocalPlayer();
    local myTarget = GetTarget(); 

    if (unitType == 3 and aUnit:CanAttack() and not aUnit:IsCritter()) then -- draw the mob on radar
        name = '' .. aUnit:GetCreatureType() .. ' (' .. aUnit:GetLevel() .. ')';
        if (self.drawNavMonsters) then 
            screenName = name;
        end
        if (self.drawRadarMob) then
            radarName = name;
        end
        if (myTarget ~= 0 and myTarget:GetGUID() == aUnit:GetGUID()) then -- the mob is our target
            red = 255; green = 255; blue = 0;
        elseif (aUnit:IsDead()) then -- dead mob
            red = 64; green = 128; blue = 64;
        end   
    elseif (unitType == 4 and me:GetGUID() ~= aUnit:GetGUID()) then -- draw the player on radar
        name = ' ' .. aUnit:GetUnitName() .. ' ('.. aUnit:GetLevel() .. ')';
        unitTarget = aUnit:GetUnitsTarget();
        local unitIsHostilePlayer = false;
        if (aUnit:CanAttack()) then -- player is hostile
            unitIsHostilePlayer = true;
            if (unitTarget ~=0 and unitTarget:GetGUID() == me:GetGUID()) then -- hostile is targeting us
                red = 255; green = 0; blue = 0;
            elseif (aUnit:IsDead()) then -- dead hostile player
                red = 64; green = 64; blue = 128;
            else -- hostile player
                red = 202; green = 120; blue = 167;
            end
            if (self.drawNavHostilePlayers) then
                screenName = name;
            end
            if (self.drawRadarHostilePlayer) then
                radarName = name;
            end
        else
            if (myTarget ~= 0 and myTarget:GetGUID() == aUnit:GetGUID()) then -- friendly player in our target
                red = 255; green = 255; blue = 0;
            elseif (aUnit:IsDead()) then -- dead hostile player
                red = 64; green = 64; blue = 128;
            else -- friendly player
                red = 0; green = 255; blue = 0;
            end
            if (self.drawNavFriendlyPlayers) then
                screenName = name;
            end
            if (self.drawRadarFriendlyPlayer) then
                radarName = name;
            end
        end
    end
    
    if (radarName ~= '') then -- draw the recognised unit on radar
        -- Transform the game coordinates to 2D pixel coords.

        local cX, cY, __ = aUnit:GetPosition();

        local centerX, centerY, __ = me:GetPosition(); 
    
        -- X and Y coordinates are swapped dunno why
        local unitOffsetX = (centerY - cY) * (self.radarScale / 100);
        local unitOffsetY = (centerX - cX) * (self.radarScale / 100);
        local cross = 3;
        local uX = self.radarOffsetX + unitOffsetX;
        local uY = self.radarOffsetY + unitOffsetY;
        DrawLine(uX - cross, uY - cross, uX + cross, uY + cross, red, green, blue, 1);
        DrawLine(uX - cross, uY + cross, uX + cross, uY - cross, red, green, blue, 1);
        local distance = math.floor(aUnit:GetDistance());
        DrawText('' .. radarName, uX + 5, uY, red, green, blue);
        DrawText('  (' .. distance .. ' yd)', uX, uY + 10, red, green, blue);
    end

    if (screenName ~= '') then -- draw the recognised unit on screen (script_nav style)
        local distance = math.floor(aUnit:GetDistance());
        local tX, tY, onScreen = WorldToScreen(aUnit:GetPosition());
        if (onScreen) then
            DrawText(screenName, tX, tY-10, red, green, blue);
            DrawText('HP: ' .. math.floor(aUnit:GetHealthPercentage()) .. '%', tX, tY, 255, 64, 64);
            DrawText('' .. distance .. ' yd.', tX, tY+10, 255, 255, 255);
        end
    end 

end

function script_radar:Radar()
    
    local pi = 3.14;
    local numberOfValidTargets = 0; local localObj = GetLocalPlayer();
    local currentObj, typeObj = GetFirstObject();
    
    -- draw mobs and players
    while currentObj ~= 0 do 
        script_radar:drawUnitOnRadar(currentObj, typeObj)
        currentObj, typeObj = GetNextObject(currentObj);
    end

    -- Draw the radar's outline        
    local cx = self.radarOffsetX;
    local cy = self.radarOffsetY;
    local cross = 3;

    DrawLine(cx - cross, cy - cross, cx + cross, cy + cross, 192, 64, 192, 1);
    DrawLine(cx - cross, cy + cross, cx + cross, cy - cross, 192, 64, 192, 1);
    for i= 1, 360 do
        local cX = self.radarOffsetX + self.radiusOne * (self.radarScale / 100) * math.cos(i/(2*pi));
        local cY = self.radarOffsetY + self.radiusOne * (self.radarScale / 100) * math.sin(i/(2*pi));
        DrawLine(cX, cY, cX+1, cY+1, 128, 128, 128, 1);
        local cX = self.radarOffsetX + self.radiusTwo * (self.radarScale / 100) * math.cos(i/(2*pi));
        local cY = self.radarOffsetY + self.radiusTwo * (self.radarScale / 100) * math.sin(i/(2*pi));
        DrawLine(cX, cY, cX+1, cY+1, 128, 128, 128, 1);

        -- max scale
        local cX = self.radarOffsetX + 300 * (self.radarScale / 100) * math.cos(i/(2*pi));
        local cY = self.radarOffsetY + 300 * (self.radarScale / 100) * math.sin(i/(2*pi));
        DrawLine(cX, cY, cX+1, cY+1, 128, 128, 128, 1);
		
        local r, g, b = 0, 0, 0;
		
		DrawText('S', cx - 5 + (self.radarScale) / 100, cy - 10 + (self.radarScale), r+255, g+255, b+255);
		
		DrawText('N', cx - 2 - (self.radarScale) / 100, cy - 3 - (self.radarScale), r+255, g+255, b+255);

		DrawText('W', cx - (self.radarScale), cy - 5 + (self.radarScale) / 100, r+255, g+255, b+255);
		
		DrawText('E', cx - 10 + (self.radarScale), cy - 5 - (self.radarScale) / 100, r+255, g+255, b+255);
	end

end

function script_radar:run()
	if(GetTimeEX() > self.timer) then
		self.timer = GetTimeEX() + self.tickRate;
    end
    
end

function script_radar:menu()
  --  if (CollapsingHeader("Radar - EXPERIMENTAL")) then
        wasClicked, self.showRadar = Checkbox("Draw the radar", self.showRadar);
        Separator();

        wasClicked, self.drawRadarFriendlyPlayer = Checkbox("Draw Friendly Players On Radar", self.drawRadarFriendlyPlayer);
        wasClicked, self.drawRadarHostilePlayer = Checkbox("Draw Hostile Players On Radar", self.drawRadarHostilePlayer);
        wasClicked, self.drawRadarMob = Checkbox("Draw Mobs On Radar", self.drawRadarMob);
        Separator();
       -- wasClicked, self.drawNavFriendlyPlayers = Checkbox("Draw Friendly Players Unit Info style", self.drawNavFriendlyPlayers);
        --wasClicked, self.drawNavHostilePlayers = Checkbox("Draw hostile players script_nav style", self.drawNavHostilePlayers);
        --wasClicked, self.drawNavMonsters = Checkbox("Draw monsters script_nav style", self.drawNavMonsters);
        self.radarOffsetX = SliderInt("radarOffsetX", 1, 1920, self.radarOffsetX);
        self.radarOffsetY = SliderInt("radarOffsetY", 1, 1080, self.radarOffsetY);
		
		Text("Use Radius One and Two to track distances easily.");
		Text("Distance in Yards (yds)");
		self.radiusOne = SliderInt("radius #1", 1, 300, self.radiusOne);
		self.radiusTwo = SliderInt("radius #2", 1, 300, self.radiusTwo);
	
		Text("Size Of Radar");
        self.radarScale = SliderInt("Scaling factor", 0, 300, self.radarScale);
   -- end
end