script_firstAid = {

    bookOpen = false;

}

function script_firstAid:openMenu()
    if (not self.bookOpen) then
        if (HasItem("Linen Cloth")) then
            CastSpellByName("FirstAid");
            self.bookOpen = true;
        end
    end
end

function script_firstAid:craftBandages()
    local name;

    if (self.craftLinenBandage) and (HasItem("Linen Cloth")) then

        for i=1,GetNumTradeSkills() do
        name, _, _, _, _ = GetTradeSkillInfo(i);
        if (name == "Linen Bandage") then

                -- if is carrying item unlit poor torch then craft dim torch
                if (self.useTorch) then
                    if (HasItem("Unlit Poor Torch")) then	
                        DoTradeSkill(i, 1);
                    end
                end
            end
        end
    end
end