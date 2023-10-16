script_firstAid = {

    bookOpen = false;
    showFirstAid = false;
    linenBandage = false;
    heavyLinenBandage = false;

}

function script_firstAid:openMenu()
    if (not self.bookOpen) then
        if (HasItem("Linen Cloth")) then
           if (CastSpellByName("First Aid")) then
            return 0;
           end
            self.bookOpen = true;
        end
    end
end

function script_firstAid:closeMenu()
    if (not HasItem("Linen Cloth")) and (self.bookOpen) then  
        CloseTradeSkill();
        self.bookOpen = false;
    end
end

function script_firstAid:craftBandages()
    local name;

    -- linen bandage
    if (HasItem("Linen Cloth")) then

        if (self.linenBandage) then
            script_firstAid:openMenu();
            for i=1,GetNumTradeSkills() do
                name, _, _, _, _ = GetTradeSkillInfo(i);


                -- use this way it works!
                
                if (name == "Linen Bandage") then
                DoTradeSkill(i, 1);
                self.waitTimer = GetTimeEX() + 1500;
                end
            end
        end

        if (self.heavyLinenBandage) then
            for i = 1, GetNumTradeSkills() do
                name, _, _, _, _ = GetTradeSkillInfo(i);
                if (name == "Heavy Linen Bandage") then
                    if (HasItem("Linen Cloth")) then
                        script_firstAid:openMenu();
                        DoTradeSkill(i, 2);
                        self.waitTimer = GetTimeEX() + 1500;
                        return 0;
                    end
                end   
            end
        end
    end
    return;
end

function script_firstAid:Menu()

    if (self.showFirstAid) then
        wasClicked, self.linenBandage = Checkbox("Craft Linen Bandage", self.linenBandage);
        if (self.linenBandage) then
            script_firstAid:craftBandages();
        end
        wasClicked, self.heavyLinenBandage = Checkbox("Craft Heavy Linen Bandage", self.heavyLinenBandage);
        if (self.heavyLinenBandage) then
            script_firstAid:craftBandages();
        end
    end
end