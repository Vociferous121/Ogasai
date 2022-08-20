--- Comments under this tab -----
--[ Heals above combat or else the bot won't ever check for heals it will always do combat. this will stop the bot if
--		it needs to heal -then continues the code if nothing can run / player doesn't need to be healed

--   if you return something that is not TRUE the bot will stop and never read another line of code
---		so all heals must return true... until we need to use them to heal then they return false, run the code
----		return true, skip the code

--[ CHECK HEALS AND HEALTH]
--hammer of justice if target is casting or self hp < x or target hp < x - IN COMBAT
--seal of light if has spell and  if health < x overrides all other seal spells - IN COMBAT
--flash of light hp < x
--holy light hp< x
--lay on hands


-- same here all combat options must return true unless we run the code

--[COMBAT]
--seal of justice if has spell target hp < x  overrides all other seal spells - IN COMBAT
--seal of wisdom if has spell and mana < x and not has any seal buff - BUFFS ----------------
--get target move to target--   we have to make a function to work FOR ALL SPELLS
--start auto attack--     we have to make a function to work FOR ALL SPELLS
--crusader strike x3 if has spell -- IN COMBAT
--seal of crusader if has spell and target not has buff crusader force it to cast this if crusader on target is gone ???
--judgement if has spell and has seal and target does not have seal debuff -- BOTH IN AND OUT OF COMBAT---------------------------------
--seal of righteousness @ level < x or command @ level >
-- ]
--- Comments above this tab -----


script_paladin = {--- name of the TYPE script to call in other places! must place in core.lua and others!
                   -- thank logitech for that.. I have to change a lot to make seperate windows.... pain in the ass
                   -- normally this would just be the script name
                   -- but how it's setup is that this is the type of script so it calls other functions...
     
         --- place all variables you want to call in any function in the script. these are global variables!

   message = 'Paladin - Retribution Combat Script', -- text to use when calling message viarable
    bopHealth = 0,          -- we can set blessing of protection use health percent here
    lohHealth = 0,          -- we can set lay on hands use health percent here
    consecrationMana = 0,   -- we can set use concecration mana % here
    eatHealth = 0,          -- we can set health % when to eat for health
    drinkMana = 0,          -- we can set health % when to drink for mana
    healHealth = 0,         -- what health do we heal at? --- probably change this later and use sliders for health check
    potionHealth = 0,       -- use potion at what health
    potionMana = 0,         -- use potion at what mana
    isSetup = false,        -- do this at bot startup set as a function in the code snippet below
                         -- (function script_paladin:setup()) isSetup is false so it will always run that functions code until true
                         -- in the function paladin:setup() if that code runs once it then returns true...
                         -- isSetup now = true when the code is ran so it will always return true unless we tell it to return false again
                         -- it will never run that line again unless false
    meeleDistance = 0,      -- how far to stand when attcking enemy
    waitTimer = 0,          -- if we set a wait timer in ms (1000 = 1 second)
    stopIfMHBroken = true,  -- stops bot and logs off if main hand weapon is broken
    aura = Devotion Aura,   -- we can do a check later just set it here at start of bot
    blessing = Blessing of Might,  -- do check later to change this -- may cause error if has no spell?
    isChecked = true        -- used for checkboxes
}

function script_paladin:setup() -- the name of the function we can call it later and use the code below  
     -- this always sets sanc aura and buffs at startup unless changed by player
     -- the variable self.aura is calling the code abova 'aura = Devotion Aura,'     
-- Sort Aura
 -- if we don't have ret or sanc aura then use devotion aura
    if (not HasSpell('Retribution Aura') and not HasSpell('Sanctity Aura')) then
        self.aura = 'Devotion Aura';    
      
    -- else if we don't have sanc aura and do have ret aura then use ret aura
    elseif (not HasSpell('Sanctity Aura') and HasSpell('Retribution Aura')) then
        self.aura = 'Retribution Aura';

     -- else if we have sanc aura then use it
    elseif (HasSpell('Sanctity Aura')) then
        self.aura = 'Sanctity Aura';   
    end -- end of the first if
-- Sort Blessings
  -- if we don't have might then use wisdom else use might at start of bot. issetup still = false
  -- if has blessing of wisdom then cast it
      if (HasSpell('Blessing of Wisdom')) then
        self.blessing = 'Blessing of Wisdom';
        
        -- else if has blessing of might then cast it
        elseif (HasSpell("Blessing of Might")) then
        self.blessing = 'Blessing of Might';
    end -- end of sort blessings if statement
                  -- make self aura devotion
                  -- make self blessing wisdom
      self.aura = 'Devotion'
      self.blessing = 'Wisdom'
      self.isSetup = true; 
      -- change this later and make this a dynamic check 
                   -- if self mana < x use wisdom else if mana geater > x use might
 end -- end of the whole function
            -- ALWAYS HAS TO TURN TRUE OR THE BOT CANNOT CONTINUE THE CODE self is setup now equals true.. continue running code below
       -- now that function is ended we can then change the variables inside because they are global variables called up top


function script_paladin:spellAttack(spellName, target) 
        -- we need to be able to tell the bot how to cast a spell. 
        -- the arguments this function are looking for are spellName and target
        -- spellName is a variable we input later or another function will do for us
	if (HasSpell(spellName)) then
            -- if player has spell
		if (target:IsSpellInRange(spellName)) then
                 -- if target is in range of spell
			if (not IsSpellOnCD(spellName)) then
                    -- if spell is not on cooldown 
				if (not IsAutoCasting(spellName)) then
                        -- if spell is not already casting
					target:FaceTarget();
                            -- turn towards target we want to cast before casting
					--target:TargetEnemy();
					return target:CastSpell(spellName);
                                -- if all of this happens then RETURN this code to be used
                                    -- it returns true if the argument spellName returns true
				end -- end of if auto casting
			end -- end of if spell on cooldown
		end -- end of if is spell in range
      end -- end of if has spell
	return false; -- ELSE if it CANNOT return true then RETURN FALSE and re-run the code! cannot go passed false it must return true!
end -- end of the whole spellAttack function


function script_paladin:enemiesAttackingUs(range) 
            -- returns number of enemies attacking us within range
            -- argument is range
    local unitsAttackingUs = 0; 
        -- local means the variable stays in this function!
        -- unitsAttackingUs cannot be used anywhere else only if this whole function is called you can use the same variable name elsewhere. it's not a global variable!
        -- we set the variable to = 0
    local currentObj, typeObj = GetFirstObject(); 
        -- local means cannot this variable outside of this function if we use currentObj or typeObj. useful to get a different currentObj or type from the game
        -- this is just how a program reads another program... bot reading the game. variable to variable to variable...
        -- we now now that the in game currentObj and tpye Obj = GetFirstObject();
        -- if we now type GetFirstObject() it will know that we are asking the game for currentObj and type...
    while currentObj ~= 0 do 
        -- while statement means run a loop. run it until you tell it when to stop!
        -- while game currentObj is not equal to 0... 0 means nothing and this is just how the game works and how the bot gets the game functions
        -- what is currentObj? the function is enemies attacking us... so if something is attacking us we know that the currentObj (targeted NPC)
        -- will be anything but 0... while it's not 0 do
    	if typeObj == 3 then
            -- if the type of object equals exactly 3 ( == ) then do...
            -- typeObj is like currentObj. when the bot reads you have a currentObj it will ask for a type
            -- type == 3 means you have an NPC and not a plyer or totem or critter or etc
            -- if currentObj ~= 0 and if typeObj == 3 then...
		if (currentObj:CanAttack() and not currentObj:IsDead()) then
            -- if currentObj (NPC) can be attacked and it is not dead then...
               -- canAttack() is part of Ogasai and calls code to attack
                	if (script_grind:isTargetingMe(currentObj) and currentObj:GetDistance() <= range) then 
                            -- the script above is being called from the grind script and the function it is calling is named isTargetingMe
                            -- by now you should be able to read that if NPC is attacking you and NPC distance is in range then...
                            -- we would need to look at the grind script to see what the function does! you will see many of the same variables like
                            -- currentObj and typeObj. we used LOCAL.. variables if we did not then we would have to rename each NPC attacking us...
                            -- currentObj simply is the current targeted NPC
                		unitsAttackingUs = unitsAttackingUs + 1; 
                                --  we now make a variable unitsAttackingUs +1
                                -- this tells the bot that variable unitsAttackingUs (0 when not in combat) adds 1 if everything above is true
                                -- so units attacking us is 1 and not 0
                	end -- end of isTargetingMe
            	end  -- end of canAttack
       	end -- end of typeObj
        currentObj, typeObj = GetNextObject(currentObj); 
            -- we recall currentObj and typeObj and tell the bot to hold that variable as GetNextObject() with an argument if it can find currentObj
            -- if the code runs again enemiesAttackingUs it will know to use a new variable for that target and unitsAttackingUs gets another +1
    end -- end of while currentObj loop
    return unitsAttackingUs;
        -- return how many unitsAttackingUs so the bot can read it elsewhere
end -- end of the whole function


function script_paladin:draw() -- name of the function
	--script_paladin:window();
	local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
        --  creates a local variable to get player position x and y and display worldtoscreen, you are local player, and getposition is x y positions in game
	if (onScreen) then
        -- if onScreen variable above   -- remember everything still returns true so the code keeps going
		DrawText(self.message, tX+75, tY+40, 0, 255, 255);
           -- draw in self.message box your positions x y
	else
		DrawText(self.message, 25, 185, 0, 255, 255);
            -- else draw error ???? idk what 25, 185 is. 
	end -- end of onScreen
end -- end of whole function



---- combat phase here

function script_paladin:window() -- name of function

	if (self.isChecked) then
	    -- variable stated above and teturned true, so if self.isChecked = true then 
		--Close existing Window
		EndWindow();
            

		if(NewWindow("Class Combat Options", 200, 200)) then
            -- make new window
			script_paladin:menu();
                -- name of window / file being called
		end -- end of NewWindow
	end -- end of self is checked
end -- end of whole function

function script_paladin:menu() -- name of function
	if (CollapsingHeader("[Paladin - Retribution")) then
        -- make new collapsing header named ...
		local 
        
        
        = false;
         -- was the collapsing menu clicked already? does it automatically drop down into a new section
		Text('Aura and Blessing options:');
        -- display text in the menu
		self.aura = InputText("Aura", self.aura);
        -- change self.aura variable to input text display this in the menu....
		self.blessing = InputText("Blessing", self.blessing);
		Separator(); -- make a visable separator in the menu
		Text('Rest options:'); -- display text...
		self.eatHealth = SliderFloat("Eat below HP%", 1, 100, self.eatHealth); -- make a slider float arguments are ("name", number, number, tell it what variable to change)
		self.drinkMana = SliderFloat("Drink below Mana%", 1, 100, self.drinkMana);
		Text('You can add more food/drinks in script_helper.lua');
		Separator();
		Text('Combat options:');
		wasClicked, self.stopIfMHBroken = Checkbox("Stop bot if main hand is broken (red)...", self.stopIfMHBroken);
		self.potionHealth = SliderFloat("Potion below HP%", 1, 99, self.potionHealth);
		self.potionMana = SliderFloat("Potion below Mana%", 1, 99, self.potionMana);
		self.healHealth = SliderFloat("Heal when below HP% (in combat)", 1, 99, self.healHealth);
		self.meeleDistance = SliderFloat("Meele range", 1, 6, self.meeleDistance);
		self.lohHealth = SliderFloat("Lay on Hands below HP%", 1, 99, self.lohHealth);
		self.bopHealth = SliderFloat("BoP below HP%", 1, 99, self.bopHealth);
		self.consecrationMana = SliderFloat("Consecration above Mana%", 1, 99, self.consecrationMana);
	end
end

