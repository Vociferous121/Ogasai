script_survivalProf = {

useTorch = false,	-- turtle wow making surival profession
dimTorchNum = 0,
survivalBookOpen = false,
}

function script_survivalProf:openMenu()
    if (not self.survivalBookOpen) then
        if (HasItem("Unlit Poor Torch")) then
            CastSpellByName("Survival");
            self.survivalBookOpen = true;
        end
    end
end

function script_survivalProf:closeMenu()
    if (not HasItem("Unlit Poor Torch")) and (self.survivalBookOpen) then  
        CloseTradeSkill();
        self.survivalBookOpen = false;
    end
end

function script_survivalProf:craftDimTorch()
    local name;
    for i=1,GetNumTradeSkills() do
       name, _, _, _, _ = GetTradeSkillInfo(i);
       if (name == "Dim Torch") then

            -- if has dim torch then delete from inventory
            if (HasItem("Dim Torch")) then
                DeleteItem("Dim Torch");
                self.waitTimer = GetTimeEX() + 1500;
                return 0;
            end

            -- if is carrying item unlit poor torch then craft dim torch
            if (self.useTorch) then
                if (HasItem("Unlit Poor Torch")) then	
                    DoTradeSkill(i, 1);
                end
            end
        end
    end
    return;
end