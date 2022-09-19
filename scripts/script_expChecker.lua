script_expChecker = {

messageRest = "Checking Exp...",

}

-- check exp function top left of screen

function script_expChecker:targetLevels()

    -- get rested exp info

	-- used to check rested exp, a little redundancy
	if (GetXPExhaustion() ~= nil) then

   		local restR = GetXPExhaustion();

	elseif (GetXPExhaustion() == nil) then

		local restR = 0;

	end
    
    local restX = UnitXP("player");
    
    local restM = UnitXPMax("player");
    
    local localLevel = GetLocalPlayer():GetLevel();
    
    -- exp per kill - same level -- base exp at same level is 102 exp a kill - turtle wow server (normal exp rate is 57 per kill)
    local baseXP = (GetLocalPlayer():GetLevel() * 5) + 45;
	local baseRestXP = ((GetLocalPlayer():GetLevel() * 5) + 45) * (2);
    
    -- exp needed to level
    local neededXP = restM - restX;

    -- total kills needed killing same level targets
    killsNeeded = math.floor(neededXP / baseXP);

    -- total kills with rested exp
    restedKillsNeeded = math.floor(neededXP / (baseRestXP));

	if (GetLocalPlayer():GetLevel() <= 7) then
		zeroDiff =  5;

	elseif (GetLocalPlayer():GetLevel() >= 8) and (GetLocalPlayer():GetLevel() <= 9) then
		zeroDiff =  6;

	elseif (GetLocalPlayer():GetLevel() >= 10) and (GetLocalPlayer():GetLevel() <= 11) then
		zeroDiff =  7;

	elseif (GetLocalPlayer():GetLevel() >= 12) and (GetLocalPlayer():GetLevel() <= 15) then
		zeroDiff =  8;

	elseif (GetLocalPlayer():GetLevel() >= 16) and (GetLocalPlayer():GetLevel() <= 19) then
		zeroDiff =  9;

	elseif (GetLocalPlayer():GetLevel() >= 20) and (GetLocalPlayer():GetLevel() <= 29) then
		zeroDiff = 11;

	elseif (GetLocalPlayer():GetLevel() >= 30) and (GetLocalPlayer():GetLevel() <= 39) then
		zeroDiff = 12;

	elseif (GetLocalPlayer():GetLevel() >= 40) and (GetLocalPlayer():GetLevel() <= 44) then
		zeroDiff = 13;

	elseif (GetLocalPlayer():GetLevel() >= 45) and (GetLocalPlayer():GetLevel() <= 49) then
		zeroDiff = 14;

	elseif (GetLocalPlayer():GetLevel() >= 50) and (GetLocalPlayer():GetLevel() <= 54) then
		zeroDiff = 15;

	elseif (GetLocalPlayer():GetLevel() >= 55) and (GetLocalPlayer():GetLevel() <= 59) then
		zeroDiff = 16;

	elseif (GetLocalPlayer():GetLevel() >= 60) then
		zeroDiff = 17;
	end

        -- rested exp calculation per mob targeted
    if (script_grind.enemyObj ~= 0) and (script_grind.enemyObj ~= nil) and (GetLocalPlayer():GetLevel() < 60) then

         -- bug in script trying to get targetObj when not having one "error can't find targetObj"
        targetObj = script_grind.enemyObj;

        -- if we have rested exp do the following.... else...
        if (GetXPExhaustion() ~= nil) then		   

            -- same level mob rested EXP
            if (GetLocalPlayer():GetLevel() == targetObj:GetLevel()) then
                if (GetLocalPlayer():GetLevel() > 0) then
                    self.messageRest = ""..restedKillsNeeded.." needed rested kills at target level "..targetObj:GetLevel();
                end
            end
            
            -- Lower level NPCs rested EXP

            -- lower level mobs rested EXP -1 level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == 1) then
                local XP = math.floor((baseRestXP) * (1 - 1/zeroDiff));
                if (XP > 1) then
                    local lowXP = math.floor(neededXP / XP);
                    self.messageRest = ""..lowXP.." needed rested kills at target level "..targetObj:GetLevel();
                end
            end
        
            -- lower level mobs rested EXP -2 level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == 2) then
                local XP = math.floor((baseRestXP) * (1 - 2/zeroDiff));
                if (XP > 1) then
                    local lowXP = math.floor(neededXP / XP);
                    self.messageRest = ""..lowXP.." needed rested kills at target level "..targetObj:GetLevel();
                end
            end
    
            -- lower level mobs rested EXP -3 level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == 3) then
                local XP = math.floor((baseRestXP) * (1 - 3/zeroDiff));
                if (XP > 1) then
                    local lowXP = math.floor(neededXP / XP);
                    self.messageRest = ""..lowXP.." needed rested kills at target level "..targetObj:GetLevel();
                end
            end
    
            -- lower level mobs rested EXP -4 level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == 4) then
                local XP = math.floor((baseRestXP) * (1 - 4/zeroDiff));
                if (XP > 1) then
                    local lowXP = math.floor(neededXP / XP);
                    self.messageRest = ""..lowXP.." needed rested kills at target level "..targetObj:GetLevel();
                end
            end
        
            -- lower level mobs rested EXP -5 level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == 5) then
                local XP = math.floor((baseRestXP) * (1 - 5/zeroDiff));
                if (XP > 1) then
                    local lowXP = math.floor(neededXP / XP);
                    self.messageRest = ""..lowXP.." needed rested kills at target level "..targetObj:GetLevel();
                end
            end
    
            -- higher level NPCs rested EXP
    
            -- Higher level mobs rested EXP +1 Level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == -1) then
                local XP = math.floor(baseRestXP) * (1 + 0.05 * (targetObj:GetLevel() - GetLocalPlayer():GetLevel()));
                if (XP > 1) then
                    local highXP = math.floor(neededXP / XP);
                    self.messageRest = ""..highXP.." needed rested kills at target level "..targetObj:GetLevel();
                end
            end

            -- Higher level mobs rested EXP +2 Level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == -2) then
                local XP = math.floor(baseRestXP) * (1 + 0.05 * (targetObj:GetLevel() - GetLocalPlayer():GetLevel()));
                if (XP > 1) then
                    local highXP = math.floor(neededXP / XP);
                    self.messageRest = ""..highXP.." needed rested kills at target level "..targetObj:GetLevel();
                end
            end

            -- Higher level mobs rested EXP +3 Level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == -3) then
                local XP = math.floor(baseRestXP) * (1 + 0.05 * (targetObj:GetLevel() - GetLocalPlayer():GetLevel()));
                if (XP > 1) then
                    local highXP = math.floor(neededXP / XP);
                    self.messageRest = ""..highXP.." needed rested kills at target level "..targetObj:GetLevel();
                end
            end

            -- Higher level mobs rested EXP +4 Level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == -4) then
                local XP = math.floor(baseRestXP) * (1 + 0.05 * (targetObj:GetLevel() - GetLocalPlayer():GetLevel()));
                if (XP > 1) then
                    local highXP = math.floor(neededXP / XP);
                    self.messageRest = ""..highXP.." needed rested kills at target level "..targetObj:GetLevel();
                end	
            end

            -- Higher level mobs rested EXP +5 Level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == -5) then
                local XP = math.floor(baseRestXP) * (1 + 0.05 * (targetObj:GetLevel() - GetLocalPlayer():GetLevel()));
                if (XP > 1) then
                    local highXP = math.floor(neededXP / XP);
                    self.messageRest = ""..highXP.." needed rested kills at target level "..targetObj:GetLevel();
                end
            end
        end
    
        -- not rested exp calculation per mob
        if (GetXPExhaustion() == nil or restR == 0) then

                -- same level mob No rested EXP
            if (GetLocalPlayer():GetLevel() == targetObj:GetLevel()) then
                if (GetLocalPlayer():GetLevel() > 1) then
                    self.messageRest = ""..killsNeeded.." needed kills at target level "..targetObj:GetLevel();
                end
            end
            
                -- Lower level NPCs NO rested EXP

            -- lower level mobs NO rested EXP -1 level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == 1) then
                local XP = math.floor((baseXP) * (1 - 1/zeroDiff));
                if (XP > 1) then
                    local lowXP = math.floor(neededXP / XP);
                    self.messageRest = ""..lowXP.." needed kills at target level "..targetObj:GetLevel();
                end
            end
        
            -- lower level mobs NO rested EXP -2 level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == 2) then
                local XP = math.floor((baseXP) * (1 - 2/zeroDiff));
                if (XP > 1) then
                    local lowXP = math.floor(neededXP / XP);
                    self.messageRest = ""..lowXP.." needed kills at target level "..targetObj:GetLevel();
                end
            end
    
            -- lower level mobs NO rested EXP -3 level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == 3) then
                local XP = math.floor((baseXP) * (1 - 3/zeroDiff));
                if (XP > 1) then
                    local lowXP = math.floor(neededXP / XP);
                    self.messageRest = ""..lowXP.." needed kills at target level "..targetObj:GetLevel();
                end
            end
    
            -- lower level mobs NO rested EXP -4 level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == 4) then
                local XP = math.floor((baseXP) * (1 - 4/zeroDiff));
                if (XP > 1) then
                    local lowXP = math.floor(neededXP / XP);
                    self.messageRest = ""..lowXP.." needed kills at target level "..targetObj:GetLevel();
                end
            end
        
            -- lower level mobs NO rested EXP -5 level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == 5) then
                local XP = math.floor((baseXP) * (1 - 5/zeroDiff));
                if (XP > 1) then
                    local lowXP = math.floor(neededXP / XP);
                    self.messageRest = ""..lowXP.." needed kills at target level "..targetObj:GetLevel();
                end
            end
    
			    -- higher level NPCs NO rested EXP

            -- Higher level mobs NO rested EXP +1 Level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == -1) then
                local XP = math.floor(baseXP) * (1 + 0.05 * (targetObj:GetLevel() - GetLocalPlayer():GetLevel()));
                if (XP > 1) then
                    local highXP = math.floor(neededXP / XP);
                    self.messageRest = ""..highXP.." needed kills at target level "..targetObj:GetLevel();
                end
            end

            -- Higher level mobs NO rested EXP +2 Level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == -2) then
                local XP = math.floor(baseXP) * (1 + 0.05 * (targetObj:GetLevel() - GetLocalPlayer():GetLevel()));
                if (XP > 1) then
                    local highXP = math.floor(neededXP / XP);
                    self.messageRest = ""..highXP.." needed kills at target level "..targetObj:GetLevel();
                end
            end

            -- Higher level mobs NO rested EXP +3 Level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == -3) then
                local XP = math.floor(baseXP) * (1 + 0.05 * (targetObj:GetLevel() - GetLocalPlayer():GetLevel()));
                if (XP > 1) then
                    local highXP = math.floor(neededXP / XP);
                    self.messageRest = ""..highXP.." needed kills at target level "..targetObj:GetLevel();
                end
            end

            -- Higher level mobs NO rested EXP +4 Level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == -4) then
                local XP = math.floor(baseXP) * (1 + 0.05 * (targetObj:GetLevel() - GetLocalPlayer():GetLevel()));
                if (XP > 1) then
                    local highXP = math.floor(neededXP / XP);
                    self.messageRest = ""..highXP.." needed kills at target level "..targetObj:GetLevel();
                end	
            end

            -- Higher level mobs NO rested EXP +5 Level
            if (GetLocalPlayer():GetLevel() - targetObj:GetLevel() == -5) then
                local XP = math.floor(baseXP) * (1 + 0.05 * (targetObj:GetLevel() - GetLocalPlayer():GetLevel()));
                if (XP > 1) then
                    local highXP = math.floor(neededXP / XP);
                    self.messageRest = ""..highXP.." needed kills at target level "..targetObj:GetLevel();
                end
            end
        end
    end
end

function script_expChecker:menu()

if (script_grind.useExpChecker) and (GetLocalPlayer():GetLevel() < 60) then

    -- color
	local r, g, b = 0, 0, 0;

	-- position
	local y, x, width = 120, 25, 370;
	local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
	if (onScreen) then
		y, x = tY-25, tX+75;
	end

	-- get rested exp info
	if (GetXPExhaustion() ~= nil) then
		local restR = GetXPExhaustion();
	end
	if (GetXPExhaustion() == nil) then
		local restR = 0;
	end

	local restX = UnitXP("player");

	local restM = UnitXPMax("player");

	local localLevel = GetLocalPlayer():GetLevel();

	-- get rested exp bubbles
	if (GetXPExhaustion() ~= nil) then
		local rest = math.floor(20*GetXPExhaustion()/UnitXPMax("player"));
	end

	-- exp per kill - same level -- base exp at same level is 247 exp a kill
	local baseXP = GetLocalPlayer():GetLevel() * 5 + 45;
	local baseRestXP = ((GetLocalPlayer():GetLevel() * 5) + 45) * (2);
	
	-- exp needed to level
	local neededXP = restM - restX;

	-- total kills needed killing same level targets
	killsNeeded = math.floor(neededXP / baseXP);

	-- total kills with rested exp
	restedKillsNeeded = math.floor(neededXP / (baseRestXP));

	-- draw kills to level
	if (GetXPExhaustion() ~= nil) and (script_grind.useExpChecker) then

		DrawText('Rested kills needed - '..restedKillsNeeded, x-740, y, r+255, g+255, b+255);
		DrawText('To level killing level '..localLevel.. ' targets', x-740, y+20, r+255, g+255, b+255);

	elseif (GetXPExhaustion() == nil or restR == 0) and (script_grind.useExpChecker) then

		DrawText('Kills needed - '..killsNeeded, x-740, y, r+255, g+255, b+255);
		DrawText('To level killing level '..localLevel.. ' targets', x-740, y+20, r+255, g+255, b+255);

	end

	-- draw rested exp
	if (GetXPExhaustion() ~= nil) and (script_grind.useExpChecker) then
		DrawText('Rested Exp: '..math.floor(20*GetXPExhaustion()/UnitXPMax("player")).. ' bubbles - '..GetXPExhaustion()..' Exp', x-740, y+40, r+255, g+255, b+255);
	end

	-- rest per kill messages
	if (script_grind.useExpChecker) and (GetXPExhaustion() ~= nil) then
		DrawText(script_expChecker.messageRest or '', x-740, y+60, r+255, g+255, b+255);
	elseif (script_grind.useExpChecker) and (GetXPExhaustion() == nil) then
		DrawText(script_expChecker.messageRest or '', x-740, y+40, r+255, g+255, b+255);
	end
end
end