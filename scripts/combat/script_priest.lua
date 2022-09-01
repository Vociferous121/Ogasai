script_priest = {
	message = 'Priest Combat Script',
	isSetup = false,	-- setup stuff
	isChecked = true,	-- setup stuff
	drinkMana = 45,	-- drink at health %
	eatHealth = 35,	-- eat at health %
	renewHP = 70,	-- renew at health %
	shieldHP = 80,	-- shield at health %
	flashHealHP = 65,	-- fleash heal at health %
	lesserHealHP = 55,	-- lesser heal health
	healHP = 40,	-- heal(spell) health
	greaterHealHP = 23, -- greater heal health
	potionMana = 10,	-- use potion at mana %
	potionHealth = 10,	-- use potion at health %
	waitTimer = 0,	-- set timer	
	useWand = true,	-- use wand yes/no
	useWandMana = 100,	-- use wand at mana %
	useWandHealth = 100, -- use wand at target health %
	useSmite = false,	-- smite on/off (force enabled level < 10)
	mindBlastMana = 30,	-- use mind blast mana %
	wandSpeed = 16,	-- wand attack speed
	useScream = true,	-- use fear yes/no
	shadowForm = false,	-- shadowform on/off (auto set on/off based on HP slider)
	mindFlayHealth = 25,	-- mind flay blow target health %
	mindFlayMana = 30,	-- mind flay above self mana %
	shadowFormHealth = 50,	-- shadowform change health
	useMindFlay = false,	-- use mind flay yes/no
	swpMana = 20, -- Use shadow word: pain above this mana %
}

function script_priest:healAndBuff(targetObject, localMana)

	local targetHealth = targetObject:GetHealthPercentage();

	local localLevel = GetLocalPlayer():GetLevel();

	-- Buff Fortitude
	if (not self.shadowForm) then	-- if not in shadowform
		if (localMana >= 25) and (not IsInCombat()) and (not targetObject:HasBuff("Power Word: Fortitude")) then
			if (Buff("Power Word: Fortitude", targetObject)) then 
				return true; -- if buffed return true
			end
		end
	end
	
	-- Buff Divine Spirit
	if (not self.shadowForm) then	-- if not in shadowform
		if (localMana >= 25) and (not IsInCombat()) and (not targetObject:HasBuff("Divine Spirit")) then
			if (Buff("Divine Spirit", targetObject)) then
				return true;  -- if buffed return true
			end
		end
	end

	-- Renew
	if (not self.shadowForm) then	-- if not in shadowform
		if (localMana >= 12) and (targetHealth <= self.renewHP) and (not targetObject:HasBuff("Renew")) then
			if (Buff("Renew", targetObject)) then
				return true; -- if buffed return true
			end
		end
	end

	-- Shield
	if (localMana >= 10) and (targetHealth <= self.shieldHP) and (not targetObject:HasDebuff("Weakened Soul")) and (IsInCombat()) then
		if (Buff("Power Word: Shield", targetObject)) then 
			targetObj:FaceTarget();
			return true;  -- if buffed return true
		end
	end

	-- Greater Heal
	if (not self.shadowForm) then	-- if not in shadowform
		if (localMana >= 20) and (targetHealth <= self.greaterHealHP) then
			if (CastHeal("Greater Heal", targetObject)) then
				return true;	-- if cast return true
			end
		end
	end

	-- Heal
	if (not self.shadowForm) then	-- if not in shadowform
		if (localMana >= 15) and (targetHealth <= self.healHP) then
			if (CastHeal("Heal", targetObject)) then
				return true;	-- if cast return true
			end
		end
	end

	-- Flash Heal
	if (not self.shadowForm) then	-- if not in shadowform
		if (localMana >= 8) and (targetHealth <= self.flashHealHP) then
			if (CastHeal("Flash Heal", targetObject)) then
				return true;	-- if cast return true
			end
		end
	end

	---- Lesser Heal
	if (not self.shadowForm) then	-- if not in shadowform
		if (localLevel < 20) then	-- don't use this when we get flash heal ELSE very low mana
			if (localMana >= 10) and (targetHealth <= self.lesserHealHP) then
				if (CastHeal("Lesser Heal", targetObject)) then
					return true;	-- if cast return true
				end
			end

		-- lesser heal level 20+ very low mana
		elseif (localLevel >= 20) then
			if (localMana <= 8) and (targetHealth <= self.flashHealHP) then
				if (CastHeal("Lesser Heal", targetObject)) then
					return true;	-- if cast return true
				end
			end
		end
	end
	
	return false; -- return false to end script when done
end

function script_priest:heal(spellName, target)

	if (HasSpell(spellName)) then 
		if (target:IsSpellInRange(spellName)) then 
			if (not IsSpellOnCD(spellName)) then 
				if (not IsAutoCasting(spellName)) then
					target:TargetEnemy(); 
					CastSpellByName(spellName); 

					-- Wait for global CD before next spell cast
					local CastTime, MaxRange, MinRange, PowerType, Cost, SpellId, SpellObj = GetSpellInfo(spellName); 
					self.waitTimer = GetTimeEX() + CastTime + 1800;
					return true; 
				end 
			end 
		end 
	end
	return false;
end

function script_priest:cast(spellName, target)
	if (HasSpell(spellName)) then
		if (target:IsSpellInRange(spellName)) then
			if (not IsSpellOnCD(spellName)) then
				if (not IsAutoCasting(spellName)) then
					target:FaceTarget();
					--target:TargetEnemy();
					return target:CastSpell(spellName);
				end
			end
		end
	end
	return false;
end

function script_priest:enemiesAttackingUs(range) -- returns number of enemies attacking us within range
    local unitsAttackingUs = 0; 
    local currentObj, typeObj = GetFirstObject(); 
    while currentObj ~= 0 do 
    	if typeObj == 3 then
			if (currentObj:CanAttack()) and (not currentObj:IsDead()) then
         	   if (script_grind:isTargetingMe(currentObj)) and (currentObj:GetDistance() <= range) then 
                	unitsAttackingUs = unitsAttackingUs + 1; 
            	end 
        	end 
       	end
    	currentObj, typeObj = GetNextObject(currentObj); 
    end
    return unitsAttackingUs;
end

-- Run backwards if the target is within range
function script_priest:runBackwards(targetObj, range) 

	local localObj = GetLocalPlayer();

 	if targetObj ~= 0 then
 		local xT, yT, zT = targetObj:GetPosition();
 		local xP, yP, zP = localObj:GetPosition();
 		local distance = targetObj:GetDistance();
 		local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
 		local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 		local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;		
 		local moveX, moveY, moveZ = xT + xUV*10, yT + yUV*10, zT + zUV;	
	
 		if (distance <= range and targetObj:IsInLineOfSight()) then 
 			--script_nav:moveToTarget(localObj, moveX, moveY, moveZ);
			Move(moveX, moveY, moveZ);
 			return true;
 		end
	end
	return false;
end

function script_priest:setup()
	self.waitTimer = GetTimeEX();
	self.isSetup = true;
end

function script_priest:draw()
	--script_priest:window();
	local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
	if (onScreen) then
		DrawText(self.message, tX+75, tY+40, 0, 255, 255);
	else
		DrawText(self.message, 25, 185, 0, 255, 255);
	end
end

--[[ error codes: 	0 - All Good , 
			1 - missing arg , 
			2 - invalid target , 
			3 - not in range, 
			4 - do nothing , 
			5 - targeted player pet/totem  ]]--

function script_priest:run(targetGUID)
	
	-- setup function finished
	if(not self.isSetup) then
		script_priest:setup();
	end

	-- if no wand equipped then force using smite
	if (not localObj:HasRangedWeapon()) then
		self.useSmite = true;
	end
	
	local localObj = GetLocalPlayer();

	local localMana = localObj:GetManaPercentage();

	local localHealth = localObj:GetHealthPercentage();

	local localLevel = localObj:GetLevel();
	
	-- if target is dead then don't attack
	if (localObj:IsDead()) then
		return 0;
	end
	
	-- Assign the target 
	targetObj =  GetGUIDObject(targetGUID);

	-- clear target
	if(targetObj == 0) or (targetObj == nil) or (targetObj:IsDead()) then
		ClearTarget();
		return 2;
	end

	-- Check: Do nothing if we are channeling, casting or Ice Blocked
	if (IsChanneling()) or (IsCasting()) or (self.waitTimer >= GetTimeEX()) then
		return 4;
	end

	-- set shadow form true
	if (GetLocalPlayer():HasBuff("Shadowform")) then
		self.shadowForm = true;

	else	-- else false if not buffed with shadowform

		 self.shadowForm = false;
	end

	-- shadowform control slider health variable
	shadowFormHealth = GetLocalPlayer():GetHealthPercentage();

	-- remove shadow form if need to heal or buff
	--shadow form is controlled through slider health percent
	if (GetLocalPlayer():HasBuff("Shadowform")) and (GetLocalPlayer():GetHealthPercentage() <= self.shadowFormHealth) then
		if (not localObj:HasBuff("Renew")) and (localHealth >= (self.shadowFormHealth - 300)) then	-- if has renew try not to keep switching between shadowform
			if (CastSpellByName("Shadowform")) then
				self.waitTimer = GetTimeEX() + 2000;
				return 0;
			end
		end
	end

	-- else stay in shadowform
	if (HasSpell("Shadowform")) and (not GetLocalPlayer():HasBuff("Shadowform")) and (localHealth >= (self.shadowFormHealth - 300)) then
		if (CastSpellByName("Shadowform")) then
			self.waitTimer = GetTimeEX() + 2000;
			return 0;
		end
	end
	
	--Valid Enemy
	if (targetObj ~= 0) and (targetObj ~= nil) then
		
		-- Cant Attack dead targets
		if (targetObj:IsDead()) or (not targetObj:CanAttack()) then
			ClearTarget();
			return 2;
		end

		-- stand if sitting
		if (not IsStanding()) then
			StopMoving();
		end

		-- set target health
		targetHealth = targetObj:GetHealthPercentage();

		-- Auto Attack
		if (targetObj:GetDistance() <= 40) then
			targetObj:AutoAttack();
		end

		-- Check: if we target player pets/totems and then blacklist them
		if (GetTarget() ~= nil) and (targetObj ~= nil) then
			if (UnitPlayerControlled("target")) and (GetTarget() ~= localObj) then 
				script_grind:addTargetToBlacklist(targetObj:GetGUID());
				return 5; 
			end
		end 
		
		-- START OF COMBAT PHASE

		-- Opener - not in combat pulling target
		if (not IsInCombat()) then

			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";
			
			-- Opener check range of ALL SPELLS
			if(not targetObj:IsSpellInRange('Smite'))  then
				self.message = "Use Smite as range check!";
				return 3;
			end

			-- Dismount
			if (IsMounted()) then DisMount(); end

			-- Devouring Plague to pull
			if (HasSpell("Devouring Plague")) and (localMana >= 25) and (not IsSpellOnCD("Devouring Plague")) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (Cast("Devouring Plague", targetObj)) then
					self.waitTimer = GetTimeEX() + 200;
					self.message = "Casting Devouring Plague!";
					return 0; -- keep trying until cast
				end
			end

			-- Mind Blast to pull
			if (HasSpell("Mind Blast")) and (localMana >= self.mindBlastMana) and (not IsSpellOnCD("Mind Blast")) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (IsMoving()) then
					StopMoving();
				end
				if (Cast("Mind Blast", targetObj)) then	
					self.waitTimer = GetTimeEX() + 750;
					self.message = "Casting Mind Blast!";
					return 0; -- keep trying until cast
				end
			end

			-- vampiric embrace
			if (HasSpell("Vampiric Embrace")) and (not IsSpellOnCD("Vampiric Embrace")) and (not targetObj:HasDebuff("Vampiric Embrace")) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (Cast("Vampiric Embrace", targetObj)) then	
					self.waitTimer = GetTimeEX() + 750;
					self.message = "Casting Vampiric Embrace!";
					return 0; -- keep trying until cast
				end
			end

			-- shadow word pain if mindblast is on CD to pull if no wand
			if (HasSpell("Shadow Word: Pain")) and (not targetObj:HasDebuff("Shadow Word: Pain")) and (IsSpellOnCD("Mind Blast")) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (Cast("Shadow Word: Pain", targetObj)) then
					self.waitTimer = GetTimeEX() + 750;
					return 0; -- keep trying until cast
				end
			end

			-- Use Smite if we have it
			if (self.useSmite) and (localMana >= 7) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (IsMoving()) then
					StopMoving();
				end
				if (Cast("Smite", targetObj)) then
					self.waitTimer = GetTimeEX() + 750;
					self.message = "Smite was checked, we are using it!";
					return 0; -- keep trying until cast
				end
			end

			
			if (not targetObj:IsInLineOfSight()) then -- check line of sight
				return 3;
			end

		-- Combat
		else	

			self.message = "Killing.. now in combat" .. targetObj:GetUnitName() .. "...";

			-- Dismount
			if (IsMounted()) then DisMount(); end

			-- check heals and buffs
			if (script_priest:healAndBuff(localObj, localMana)) then
				return 0;
			end

			-- Check: Use Healing Potion 
			if (localHealth <= self.potionHealth) then 
				if (script_helper:useHealthPotion()) then 
					self.waitTimer = GetTimeEX() + 1000; -- timer to stop spam drinking
					return 0; -- keep trying until cast
				end 
			end

			-- Check: Use Mana Potion 
			if (localMana <= self.potionMana) then 
				if (script_helper:useManaPotion()) then 
					self.waitTimer = GetTimeEX() + 1000; -- timer to stop spam drinking
					return 0; -- keep trying until cast
				end 
			end

			-- Silence if talent obtained
			if (HasSpell("Silence")) and (targetObj:IsCasting()) and (localMana >= 15) and (targetHealth >= 25) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (Cast("Silence", targetObj)) then
					self.waitTimer = GetTimeEX() + 1500;
					return 0; -- keep trying until cast
				end
			end

			-- fear
			if (self.useScream) and (script_priest:enemiesAttackingUs(9) >= 1) and (targetHealth >= 20) and (localMana >= 10) then
				if (HasSpell("Psychic Scream")) and (not IsSpellOnCD("Psychic Scream")) then
					CastSpellByName("Psychic Scream");
					self.message = 'Adds close, use Psychic Scream...';
					return 0; -- keep trying until cast
				end
			end

			-- use mind blast on CD
			if (HasSpell("Mind Blast")) and (not IsSpellOnCD("Mind Blast")) then
				if (targetHealth >= 20) and (localMana >= self.mindBlastMana) then
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					if (Cast("Mind Blast", targetObj)) then
						self.waitTimer = GetTimeEX() + 750;
						return 0; -- keep trying until cast
					end
				end
			end

			-- Check: Keep Shadow Word: Pain up
			if (not targetObj:HasDebuff("Shadow Word: Pain")) and (HasSpell("Shadow Word: Pain")) and (localMana >= self.swpMana) and (targetHealth >= 25) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (Cast("Shadow Word: Pain", targetObj)) then 
					self.waitTimer = GetTimeEX() + 750;
					self.message = "Keeping DoT up!";
					return 0; -- keep trying until cast
				end
			end

			-- Check: keep vampiric embrace up
			if (HasSpell("Vampiric Embrace")) and (not IsSpellOnCD("Vampiric Embrace")) and (not targetObj:HasDebuff("Vampiric Embrace")) and (localMana >= 5) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (Cast("Vampiric Embrace", targetObj)) then	
					self.waitTimer = GetTimeEX() + 750;
					self.message = "Casting Vampiric Embrace!";
					return 0; -- keep trying until cast
				end
			end

			-- night elf Elune's Grace racial
			if (IsInCombat()) and (HasSpell("Elune's Grace")) and (not IsSpellOnCD("Elune's Grace")) and (not localObj:HasBuff("Elune's Grace")) and (localHealth < 75) then
				if (Buff("Elune's Grace", localObj)) then
					self.waitTimer = GetTimeEX() + 1500;
					return true;
				end
			end

			-- Check: Keep Inner Fire up
			if (not IsInCombat()) and (not localObj:HasBuff("Inner Fire")) and (HasSpell("Inner Fire")) and (localMana >= 8) then
				if (Buff("Inner Fire", localObj)) then
					self.waitTimer = GetTimeEX() + 750;
					return 0; -- keep trying until cast
				end
				-- check inner fire in combat
			elseif (IsInCombat()) and (not localObj:HasBuff("Inner Fire")) and (HasSpell("Inner Fire")) and (localMana >= 8) then
				if (localObj:HasBuff("Power Word: Shield")) then
					if (Buff("Inner Fire", localObj)) then
						self.waitTimer = GetTimeEX() + 750;
						return 0; -- keep trying until cast
					end
				end
			end

			-- inner focus
			if (not localObj:HasBuff("Inner Focus")) and (HasSpell("Inner Focus")) then
				if (not IsSpellOnCD("Inner Focus")) then
					if (GetLocalPlayer():GetManaPercentage() <= 20) and (GetLocalPlayer():GetHealthPercentage() <= 20) then
						if (Buff("Inner Focus")) then
							self.waitTimer = GetTimeEX() + 1500;
							return 0; -- keep trying until cast
						end
					end
				end
				-- cast heal while inner focus active
			elseif (localObj:HasBuff("Inner Focus")) then
				if (Cast("Flash Heal", localObj)) then
					return 0; -- keep trying until cast
				end
			end

			-- Power Infusion low health 50% or targets >= 1
			if (HasSpell("Power Infusion")) and (not IsSpellOnCD("Power Infusion")) then
				if (localHealth <= 50) or (script_priest:enemiesAttackingUs(8) >= 2) then
					if (Buff("Power Infusion")) then
						return 0; -- keep trying until cast
					end
				end
			end

			-- Cast: Smite (last choice e.g. at level 1)
			if (self.useSmite) and (localMana >= 7) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (Cast("Smite", targetObj)) then 
					self.waitTimer = GetTimeEX() + 750;
					return 0; -- keep trying until cast
				end
			end

			-- check heal and buffs
			if (script_priest:healAndBuff(localObj, localMana)) then
				return 0; -- keep trying until cast
			end

			-- Mind flay 
			if (self.shadowForm and self.useMindFlay ) or (self.useMindFlay) and (IsSpellOnCD("Mind Blast") or localMana <= self.mindBlastMana) then
				if (HasSpell("Mind Flay")) and (not IsSpellOnCD("Mind Flay")) and (localMana >= self.mindFlayMana) and (targetHealth >= self.mindFlayHealth) and
				 (not localObj:IsChanneling()) and (targetObj:GetDistance() <= 20) then
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					if (Cast("Mind Flay", targetObj)) then
						self.waitTimer = GetTimeEX() + 1500
						return 0; -- keep trying until cast
					end
				end
			end

			-- new wand variable to adjust speed in UI
			wandSpeed = self.wandSpeed;

			--mind flay and then wand when set
			if (self.useMindFlay) and (not localObj:IsCasting() or not localObj:IsChanneling()) and (localMana <= self.mindFlayMana) or (targetHealth <= self.mindFlayHealth) then
				if (localObj:HasRangedWeapon()) then
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					if (not IsAutoCasting("Shoot")) then
						self.message = "Using wand...";
						targetObj:FaceTarget();
						targetObj:CastSpell("Shoot");
						self.waitTimer = GetTimeEX() + ((self.wandSpeed / 10) + 150); 
						return false; -- return if not AutoCasting then false
					end
				end
			end

			--Wand if set to use wand
			if (self.useWand) and (not self.useMindFlay) and (not localObj:IsCasting()) and (IsSpellOnCD("Mind Blast") or localMana <= self.mindBlastMana) then
				if (localMana <= self.useWandMana) and (targetHealth <= self.useWandHealth) and (localObj:HasRangedWeapon()) then
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					if (not IsAutoCasting("Shoot")) then
						self.message = "Using wand...";
						targetObj:FaceTarget();
						targetObj:CastSpell("Shoot");
						self.waitTimer = GetTimeEX() + ((self.wandSpeed / 10) + 150); 
						return true; -- return if not AutoCasting then false
						end
				end
			end
		end
	end
end


function script_priest:rest()

	-- check setup
	if (not self.isSetup) then
		script_priest:setup();
	end

	local localObj = GetLocalPlayer();

	local localMana = localObj:GetManaPercentage();

	local localHealth = localObj:GetHealthPercentage();

	-- Stop moving before we can rest
	if (localHealth <= self.eatHealth) or (localMana <= self.drinkMana) then
		if (IsMoving()) then
			StopMoving();
			return true;
		end
	end

	-- check heals and buffs
	if (script_priest:healAndBuff(localObj, localMana)) then 
		return true;
	end

	-- Check: Drink
	if (not IsDrinking()) and (localMana <= self.drinkMana) then
		self.message = "Need to drink...";
		if (IsMoving()) then
			StopMoving();
			self.waitTimer = GetTimeEX() + 2000;
			return true;
		end

		if (script_helper:drinkWater()) then 
			self.message = "Drinking..."; 
			self.waitTimer = GetTimeEX() + 2000;
			return true; 
		else 
			self.message = "No drinks! (or drink not included in script_helper)";
			return true; 
		end
	end

	-- Check: Eat
	if (not IsEating()) and (localHealth <= self.eatHealth) then
		self.message = "Need to eat...";	
		if (IsMoving()) then
			StopMoving();
			self.waitTimer = GetTimeEX() + 2000;
			return true;
		end
		
		if (script_helper:eat()) then 
			self.message = "Eating..."; 
			self.waitTimer = GetTimeEX() + 2000;
			return true; 	
		else 
			self.message = "No food! (or food not included in script_helper)";
			return true; 
		end	
	end
	-- night elve stealth while resting
	if (IsDrinking() or IsEating()) and (HasSpell("Shadowmeld")) and (not IsSpellOnCD("Shadowmeld")) and (not localObj:HasBuff("Shadowmeld")) then
		if (CastSpellByName("Shadowmeld")) then
			return 0;
		end
	end
	
	-- Check: Keep resting
	if (localMana <= 98) and (IsDrinking()) or (localHealth <= 98 and IsEating()) then
		self.message = "Resting to full hp/mana...";
		return true;
	end
	-- No rest / buff needed
	return false;
end

--function script_priest:mount()
--
--	if(not IsMounted() and not IsSwimming() and not IsIndoors() 
--		and not IsLooting() and not IsCasting() and not IsChanneling() 
--			and not IsDrinking() and not IsEating()) then
--		
--		if(IsMoving()) then
--			return true;
--		end
--		
--		return UseItem(self.mountName);
--	end
--	
--	return false;
--end

function script_priest:window()

	if (self.isChecked) then
	
		--Close existing Window
		EndWindow();

		if(NewWindow("Combat Options and Self Heals", 200, 200)) then
			script_priest:menu();
		end
	end
end


function script_priest:menu()

	-- obtain class from game using wow api
	local class = UnitClass("player");

	-- if we are priest then show menu
	if (class == 'Priest') then

		local wasClicked = false;

		-- priest combat options all COMBAT spells under here. skills spells talents
		if (CollapsingHeader("Priest Combat Options")) then

			-- MIND BLAST
			-- hide spell if not obtained yet
			if (HasSpell("Mind Blast")) then
				Text('Mind Blast above self mana percent');
				self.mindBlastMana = SliderInt("MBM%", 10, 100, self.mindBlastMana);
			end

			Separator();

			-- SHADOW WORD PAIN
			-- hide spell if not obtained yet
			if (HasSpell("Shadow Word: Pain")) then
				Text("Shadow Word: Pain above self mana percent");
				self.swpMana = SliderInt("SPM", 10, 100, self.swpMana)
			end

			Separator();

			-- MIND FLAY
			-- hide spell if not obtained yet
			if (self.useMindFlay) then
				Text("Use Mind Flay above target health percent")
				self.mindFlayHealth = SliderInt("MFH", 1, 100, self.mindFlayHealth);
				Text("Use Mind Flay above self mana percent");
				self.mindFlayMana = SliderInt("MFM", 1, 100, self.mindFlayMana);
			end	

			-- shadowform appears in menu if has the spell
			if (HasSpell("Shadowform")) then

				Text("Health to exit Shadowform to Heal!");
				self.shadowFormHealth = SliderInt("SFH", 1, 70, self.shadowFormHealth);

				Separator();

			end

			-- hide spell if not obtained yet
			if (HasSpell("Psychic Scream")) then
				wasClicked, self.useScream = Checkbox("Fear On/Off", self.useScream);
			end

			SameLine();

			wasClicked, self.useSmite = Checkbox("Smite On/Off", self.useSmite);
			
			-- mind flay appears in menu if has the spell
			if (HasSpell("Mind Flay")) then
				
				SameLine();

				wasClicked,	self.useMindFlay = Checkbox("Mind Flay vs Wand", self.useMindFlay);
				
				-- if mind flay is clicked then set useWand to false/unclicked
				if self.useMindFlay then

					self.useWand = false;

				end

			end
			
			-- if mind flay is being used then hide wand menu
			if (not self.useMindFlay) then

				-- hide wand menu if no ranged weapon equipped
				if (localObj:HasRangedWeapon()) then

					-- wand options menu
					if (CollapsingHeader("-- Wand Options")) then

						Text('Wand options:');
						wasClicked, self.useWand = Checkbox("Use Wand", self.useWand);
						
						Text('Wand below self mana percent');
						self.useWandMana = SliderInt("WM%", 10, 100, self.useWandMana);

						Text('Wand below target HP percent');
						self.useWandHealth = SliderInt("WH%", 10, 100, self.useWandHealth);

						Text('Wand Attack Speed (15 = 1.50 Attack Speed)');
						--self.wandSpeed = InputText("WS", self.wandSpeed);
						self.wandSpeed = SliderInt("WS", 5, 40, self.wandSpeed);
					end
				end
			end
		end

		if (CollapsingHeader("Priest Self Heals - Combat Script")) then

			Text('Drink below mana percentage');
			self.drinkMana = SliderInt("DM%", 10, 99, self.drinkMana);

			Text('Eat below health percentage');
			self.eatHealth = SliderInt("EH%", 10, 99, self.eatHealth);

			Separator();

			Text('Self Heals');

			-- if level >= 20 then hide lesser heal
			if (GetLocalPlayer():GetLevel() <= 20) then
				self.lesserHealHP = SliderInt("Lesser heal HP%", 1, 99, self.lesserHealHP);	
			end
			
			-- hide spell if not obtained yet
			if (HasSpell("Renew")) then
				self.renewHP = SliderInt("Renew HP%", 1, 99, self.renewHP);	
			end

			-- hide spell if not obtained yet
			if (HasSpell("Power Word: Shield")) then
				self.shieldHP = SliderInt("Shiled HP%", 1, 99, self.shieldHP);
			end

			-- hide spell if not obtained yet
			if (HasSpell("Flash Heal")) then
				self.flashHealHP = SliderInt("Flash heal HP%", 1, 99, self.flashHealHP);
			end

			-- hide spell if not obtained yet
			if (HasSpell("Heal")) then
				self.healHP = SliderInt("Heal HP%", 1, 99, self.healHP);	
			end

			-- hide spell if not obtained yet
			if (HasSpell("Greater Heal")) then
				self.greaterHealHP = SliderInt("Greater Heal HP%", 1, 99, self.greaterHealHP);
			end

			self.potionHealth = SliderInt("Potion HP%", 1, 99, self.potionHealth);
			self.potionMana = SliderInt("Potion Mana%", 1, 99, self.potionMana);

		end
	end
end