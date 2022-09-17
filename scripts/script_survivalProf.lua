script_survivalProf = {

useTorch = false,	-- turtle wow making surival profession
dimTorchNum = 0,

}

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