script_survivalProf = {

useTorch = false,	-- turtle wow making surival profession
dimTorchNum = 0,
survivalBookOpen = false,
useCampfire = false,
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

function script_survivalProf:craftBrightCampfire()
	if (HasSpell("Bright Campfire")) and (HasItem("Simple Wood")) and
		(HasItem("Flint and Tinder")) and (not IsSpellOnCD("Bright Campfire")) and
		(not IsInCombat()) then
		if (CastSpellByName("Bright Campfire")) then
			self.waitTimer = GetTimeEX() + 2000;
			return 0;
		end
	end
end
