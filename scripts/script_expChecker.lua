    script_expChecker = {

    }

    -- check exp function top left of screen

    function script_expChecker:targetLevels()

        -- get rested exp info
    
        local restR = GetXPExhaustion();
        local restP = "player";
        local restX = UnitXP(p);
        local restM = UnitXPMax(p);
        local localLevel = GetLocalPlayer():GetLevel();
        local targetLevel = targetObj:GetLevel();
    
        -- exp per kill - same level -- base exp at same level is 247 exp a kill - turtle wow server
        local baseXP = GetLocalPlayer():GetLevel() * 5 + 102;
        
        -- exp needed to level
        local neededXP = restM - restX;
    
        -- total kills needed killing same level targets
        killsNeeded = math.floor(neededXP / baseXP);
    
        -- total kills with rested exp
        restedKillsNeeded = math.floor(neededXP / baseXP) / 2;
    
            -- rested exp calculation per mob targeted
        if (script_grind.enemyObj ~= 0) and (script_grind.enemyObj ~= nil) then
            if (GetXPExhaustion ~= nil) then
        
                -- same level mob
                if (localLevel == targetLevel) then
                    local XP = baseXP;
                    if (XP > 1) then
                        local lowXP = math.floor(neededXP / XP) / 2;
                        self.messageRest = ""..lowXP.." needed kills at target level "..targetLevel;
                    end
                end
                
                    -- lower level mobs
                if (localLevel - targetLevel == 1) then
                    local XP = math.floor(baseXP * (1 - 1/11));
                    if (XP > 1) then
                        local lowXP = math.floor(neededXP / XP) / 2;
                        self.messageRest = ""..lowXP.." needed rested kills at target level "..targetLevel;
                    end
                end
            
                if (localLevel - targetLevel == 2) then
                    local XP = math.floor(baseXP * (1 - 2/11));
                    if (XP > 1) then
                        local lowXP = math.floor(neededXP / XP) / 2;
                        self.messageRest = ""..lowXP.." needed rested kills at target level "..targetLevel;
                    end
                end
        
                if (localLevel - targetLevel == 3) then
                    local XP = math.floor(baseXP * (1 - 3/11));
                    if (XP > 1) then
                        local lowXP = math.floor(neededXP / XP) / 2;
                        self.messageRest = ""..lowXP.." needed rested kills at target level "..targetLevel;
                    end
                end
        
                if (localLevel - targetLevel == 4) then
                    local XP = math.floor(baseXP * (1 - 4/11));
                    if (XP > 1) then
                        local lowXP = math.floor(neededXP / XP) / 2;
                        self.messageRest = ""..lowXP.." needed rested kills at target level "..targetLevel;
                    end
                end
            
                if (localLevel - targetLevel == 5) then
                    local XP = math.floor(baseXP * (1 - 5/11));
                    if (XP > 1) then
                        local lowXP = math.floor(neededXP / XP) / 2;
                        self.messageRest = ""..lowXP.." needed rested kills at target level "..targetLevel;
                    end
                end
        
                -- higher level mobs
        
                if (localLevel - targetLevel == -1) then
                    local XP = math.floor(baseXP) * (1 + 0.05 * (targetLevel - localLevel));
                    if (XP > 1) then
                        local highXP = math.floor(neededXP / XP) / 2;
                        self.messageRest = ""..highXP.." needed rested kills at target level "..targetLevel;
                    end
                end

                if (localLevel - targetLevel == -2) then
                    local XP = math.floor(baseXP) * (1 + 0.05 * (targetLevel - localLevel));
                    if (XP > 1) then
                        local highXP = math.floor(neededXP / XP) / 2;
                        self.messageRest = ""..highXP.." needed rested kills at target level "..targetLevel;
                    end
                end

                if (localLevel - targetLevel == -3) then
                    local XP = math.floor(baseXP) * (1 + 0.05 * (targetLevel - localLevel));
                    if (XP > 1) then
                        local highXP = math.floor(neededXP / XP) / 2;
                        self.messageRest = ""..highXP.." needed rested kills at target level "..targetLevel;
                    end
                end

                if (localLevel - targetLevel == -4) then
                    local XP = math.floor(baseXP) * (1 + 0.05 * (targetLevel - localLevel));
                    if (XP > 1) then
                        local highXP = math.floor(neededXP / XP) / 2;
                        self.messageRest = ""..highXP.." needed rested kills at target level "..targetLevel;
                    end	
                end

                if (localLevel - targetLevel == -5) then
                    local XP = math.floor(baseXP) * (1 + 0.05 * (targetLevel - localLevel));
                    if (XP > 1) then
                        local highXP = math.floor(neededXP / XP) / 2;
                        self.messageRest = ""..highXP.." needed rested kills at target level "..targetLevel;
                    end
                end
            end
        
            -- not rested exp calculation per mob
            if (GetXPExhaustion == nil) then
        
                    -- same level mob
                if (localLevel == targetLevel) then
                    local XP = baseXP;
                    if (XP > 1) then
                        local lowXP = math.floor(neededXP / XP);
                        self.messageRest = ""..lowXP.." needed kills at target level "..targetLevel;
                    end
                end
                
                    -- lower level mobs
                if (localLevel - targetLevel == 1) then
                    local XP = math.floor(baseXP * (1 - 1/11));
                    if (XP > 1) then
                        local lowXP = math.floor(neededXP / XP);
                        self.messageRest = ""..lowXP.." needed kills at target level "..targetLevel;
                    end
                end
            
                if (localLevel - targetLevel == 2) then
                    local XP = math.floor(baseXP * (1 - 2/11));
                    if (XP > 1) then
                        local lowXP = math.floor(neededXP / XP);
                        self.messageRest = ""..lowXP.." needed kills at target level "..targetLevel;
                    end
                end
        
                if (localLevel - targetLevel == 3) then
                    local XP = math.floor(baseXP * (1 - 3/11));
                    if (XP > 1) then
                        local lowXP = math.floor(neededXP / XP);
                        self.messageRest = ""..lowXP.." needed kills at target level "..targetLevel;
                    end
                end
        
                if (localLevel - targetLevel == 4) then
                    local XP = math.floor(baseXP * (1 - 4/11));
                    if (XP > 1) then
                        local lowXP = math.floor(neededXP / XP);
                        self.messageRest = ""..lowXP.." needed kills at target level "..targetLevel;
                    end
                end
            
                if (localLevel - targetLevel == 5) then
                    local XP = math.floor(baseXP * (1 - 5/11));
                    if (XP > 1) then
                        local lowXP = math.floor(neededXP / XP);
                        self.messageRest = ""..lowXP.." needed kills at target level "..targetLevel;
                    end
                end
        
                if (localLevel - targetLevel == -1) then
                    local XP = math.floor(baseXP) * (1 + 0.05 * (targetLevel - localLevel));
                    if (XP > 1) then
                        local highXP = math.floor(neededXP / XP);
                        self.messageRest = ""..highXP.." needed kills at target level "..targetLevel;
                    end
                end

                if (localLevel - targetLevel == -2) then
                    local XP = math.floor(baseXP) * (1 + 0.05 * (targetLevel - localLevel));
                    if (XP > 1) then
                        local highXP = math.floor(neededXP / XP);
                        self.messageRest = ""..highXP.." needed kills at target level "..targetLevel;
                    end
                end

                if (localLevel - targetLevel == -3) then
                    local XP = math.floor(baseXP) * (1 + 0.05 * (targetLevel - localLevel));
                    if (XP > 1) then
                        local highXP = math.floor(neededXP / XP);
                        self.messageRest = ""..highXP.." needed kills at target level "..targetLevel;
                    end
                end

                if (localLevel - targetLevel == -4) then
                    local XP = math.floor(baseXP) * (1 + 0.05 * (targetLevel - localLevel));
                    if (XP > 1) then
                        local highXP = math.floor(neededXP / XP);
                        self.messageRest = ""..highXP.." needed kills at target level "..targetLevel;
                    end	
                end

                if (localLevel - targetLevel == -5) then
                    local XP = math.floor(baseXP) * (1 + 0.05 * (targetLevel - localLevel));
                    if (XP > 1) then
                        local highXP = math.floor(neededXP / XP);
                        self.messageRest = ""..highXP.." needed kills at target level "..targetLevel;
                    end
                end
            end
        end
    end