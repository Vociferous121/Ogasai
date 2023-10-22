script_priest = {
	message = 'Priest Combat Script',
	priestMenu = include("scripts\\combat\\script_priestEX.lua"),
	isSetup = false,	-- setup stuff
	isChecked = true,	-- setup stuff
	drinkMana = 45,	-- drink at health %
	eatHealth = 35,	-- eat at health %
	renewHP = 75,	-- renew at health %
	shieldHP = 85,	-- shield at health %
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
	useScream = false,	-- use fear yes/no
	shadowForm = false,	-- shadowform on/off (auto set on/off based on HP slider)
	mindFlayHealth = 18,	-- mind flay blow target health %
	mindFlayMana = 18,	-- mind flay above self mana %
	shadowFormHealth = 50,	-- shadowform change health
	useMindFlay = false,	-- use mind flay yes/no
	swpMana = 20, -- Use shadow word: pain above this mana %
	followTargetDistance = 100,
}

function script_priest:healAndBuff(targetObject, localMana)

	-- get target health percentage
	local targetHealth = targetObject:GetHealthPercentage();
	local localHealth = GetLocalPlayer():GetHealthPercentage();

	-- get self player level
	local localLevel = GetLocalPlayer():GetLevel();

	-- use mind blast on CD
			-- !! must be placed here to stop wand casting !!
	if (HasSpell("Mind Blast")) and (not IsSpellOnCD("Mind Blast")) and (IsInCombat()) then
		if (targetHealth >= 20) and (localMana >= self.mindBlastMana) then
			CastSpellByName("Mind Blast", targetObj);
			self.waitTimer = GetTimeEX() + 750;
			return;
		end
	end

	--Buff Inner Fire
	if (not IsInCombat()) and (not localObj:HasBuff("Inner Fire")) and (HasSpell("Inner Fire")) and (localMana >= 8) then
		if (Buff("Inner Fire", localObj)) then
			self.waitTimer = GetTimeEX() + 1250;
			return; -- keep trying until cast
		end
	end

	-- Buff Fortitude
	if (not self.shadowForm) then	-- if not in shadowform
		if (localMana >= 25) and (not IsInCombat()) and (not targetObject:HasBuff("Power Word: Fortitude")) then
			if (Buff("Power Word: Fortitude", targetObject)) then 
				self.waitTimer = GetTimeEX() + 1500;
				return; -- if buffed return true
			end
		end
	end
	
	-- Buff Divine Spirit
	if (not self.shadowForm) then	-- if not in shadowform
		if (localMana >= 25) and (not IsInCombat()) and (not targetObject:HasBuff("Divine Spirit")) then
			if (Buff("Divine Spirit", targetObject)) then
				return;  -- if buffed return true
			end
		end
	end

	-- Cast Renew
	if (not self.shadowForm) then	-- if not in shadowform
		if (localMana >= 12) and (localHealth <= self.renewHP) and (not targetObject:HasBuff("Renew")) then
			if (Buff("Renew", targetObject)) then
				return; -- if buffed return true
			end
		end
	end

	-- Cast Shield Power Word: Shield
	if (localMana >= 10) and (localHealth <= self.shieldHP) and (not targetObject:HasDebuff("Weakened Soul")) and (IsInCombat()) then
		if (Buff("Power Word: Shield", targetObject)) then 
			-- targetObj:FaceTarget();
			return;  -- if buffed return true
		end
	end

	-- Cast Greater Heal
	if (not self.shadowForm) then	-- if not in shadowform
		if (localMana >= 20) and (localHealth <= self.greaterHealHP) then
			if (CastHeal("Greater Heal", targetObject)) then
				return;	-- if cast return true
			end
		end
	end

	-- Cast Heal(spell)
	if (not self.shadowForm) then	-- if not in shadowform
		if (localMana >= 15) and (localHealth <= self.healHP) then
			if (CastHeal("Heal", targetObject)) then
				return;	-- if cast return true
			end
		end
	end

	-- Cast Flash Heal
	if (not self.shadowForm) then	-- if not in shadowform
		if (localMana >= 8) and (targetHealth <= self.flashHealHP) then
			if (CastHeal("Flash Heal", targetObject)) then
				return;	-- if cast return true
			end
		end
	end

	-- Cast Lesser Heal
	if (not self.shadowForm) then	-- if not in shadowform
		if (localLevel < 20) then	-- don't use this when we get flash heal ELSE very low mana
			if (localMana >= 10) and (targetHealth <= self.lesserHealHP) then
				if (CastHeal("Lesser Heal", targetObject)) then
					return;	-- if cast return true
				end
			end

		-- ELSE IF player level >= 20
		elseif (localLevel >= 20) then
			if (localMana <= 8) and (targetHealth <= self.flashHealHP) then
				if (CastHeal("Lesser Heal", targetObject)) then
					return;	-- if cast return true
				end
			end
		end
	end
	
	--Check Disease Debuffs -- cure disease
	if (localMana > 20) and (HasSpell("Cure Disease")) then
		script_priest:dispellDebuff();
		return;
	end

	-- use mind blast on CD
			-- !! must be placed here to stop wand casting !!
	if (HasSpell("Mind Blast")) and (not IsSpellOnCD("Mind Blast")) and (IsInCombat()) then
		if (targetHealth >= 20) and (localMana >= self.mindBlastMana) then
			CastSpellByName("Mind Blast", targetObj);
			self.waitTimer = GetTimeEX() + 750;
			return;
		end
	end
	return;
end

function script_priest:dispellDebuff(spellName, target)

	local localPlayer = GetLocalPlayer();
	
	if (HasSpell("Cure Disease")) then
		if (localPlayer:HasDebuff("Tetanus")) then
			CastSpellByName("Cure Disease", localplayer)
			self.waitTimer = GetTimeEX() + 1200;
		return;
		end
	end
	
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
    local unitsAttackingUs = 0; -- set variable
    local currentObj, typeObj = GetFirstObject();  -- get game target
    while currentObj ~= 0 do -- start loop
    	if typeObj == 3 then -- typeObj is NPC
			if (currentObj:CanAttack()) and (not currentObj:IsDead()) then -- if can attack and not dead
         	   if (script_grind:isTargetingMe(currentObj)) and (currentObj:GetDistance() <= range) then -- if being targeted and within range
                	unitsAttackingUs = unitsAttackingUs + 1; -- count how many units are attacking us
            	end 
        	end 
       	end
    	currentObj, typeObj = GetNextObject(currentObj); -- get next game target for each typeObj == 3
    end
    return unitsAttackingUs; -- return number of units attacking
end

-- Run backwards if the target is within range
function script_priest:runBackwards(targetObj, range) 

	local localObj = GetLocalPlayer(); -- get player

 	if targetObj ~= 0 then -- if we have any type of target
 		local xT, yT, zT = targetObj:GetPosition(); -- get target position
 		local xP, yP, zP = localObj:GetPosition(); -- get local position
 		local distance = targetObj:GetDistance(); -- get game distance
 		local xV, yV, zV = xP - xT, yP - yT, zP - zT;
 		local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 		local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;		
 		local moveX, moveY, moveZ = xT + xUV*10, yT + yUV*10, zT + zUV;	
	
 		if (distance <= range and targetObj:IsInLineOfSight()) then -- if in range and line of sight
 			--script_nav:moveToTarget(localObj, moveX, moveY, moveZ);
			Move(moveX, moveY, moveZ); -- move to calculated coords
 			return true; -- return true when done
 		end
	end
	return false; -- return false to continue loop if needed
end

function script_priest:setup()
	self.waitTimer = GetTimeEX(); -- set timer
	self.isSetup = true; -- setup variable run once
	if (HasSpell("Mind Flay")) then -- if has mind flay
		self.drinkMana = 35; -- set drinkMana variable
		self.shieldHP = 90;	-- set shieldHP variable
		self.renewHP = 80;	-- set renewHP variable
	end
	
	if (GetNumPartyMembers() > 1) then
		self.useScream = false;
	end
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
	
	local localObj = GetLocalPlayer(); -- get player

	local localMana = localObj:GetManaPercentage(); -- get player mana percentage wow API

	local localHealth = localObj:GetHealthPercentage(); -- get player health percentage wow API

	local localLevel = localObj:GetLevel(); -- get player level wow API
	
	-- if target is dead then don't attack
	if (localObj:IsDead()) then
		return 0;
	end

	-- tick rate
	if (not IsInCombat()) then
		script_grind.tickRate = 100;
	else
		script_grind.tickRate = 200;
	end
	
	-- Assign the target 
	targetObj =  GetGUIDObject(targetGUID); -- get guid of target and save it

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
			JumpOrAscendStart();
		end

		if (targetObj:IsInLineOfSight() and not IsMoving() and script_grind.lootObj == nil) then
			if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
				if (not targetObj:FaceTarget()) then
					targetObj:FaceTarget();
				end
			end
		end

		-- Don't attack if we should rest first
		if (GetNumPartyMembers() < 1) and ((localHealth < self.eatHealth or localMana < self.drinkMana) and not script_grind:isTargetingMe(targetObj)
				and not targetObj:IsFleeing() and not targetObj:IsStunned() and not script_mage:isAddPolymorphed()) then
				self.message = "Need rest...";
				return 4;
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
			if (targetObj:GetDistance() > 30) then
				self.message = "Walking to spell range!";
				return 3;
			end

			if (targetObj:IsInLineOfSight()) and (targetObj:GetDistance() <= 30) then
				if (IsMoving()) then
					StopMoving();
				end
			end

			-- stand if sitting
			if (not IsStanding()) then
				JumpOrAscendStart();
			end

			-- we are in spell range to pull then stop moving
			--if (targetObj:GetDistance() < 25) and (targetObj:IsInLineOfSight()) then
				--if (IsMoving()) then
				--	StopMoving();
				--end
			--end

			-- Dismount
			if (IsMounted()) then
				DisMount();
			end

			-- new follow target
			if (targetObj:IsInLineOfSight() and not IsMoving()) then
				if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
					if (not targetObj:FaceTarget()) then
						targetObj:FaceTarget();
					end
				end
			end

			-- Berserking Troll Racial
			if (HasSpell("Berserking")) and (not IsSpellOnCD("Berserking")) and (targetObj:GetDistance() < 31) then
				CastSpellByName("Berserking");
				self.waitTimer = GetTimeEX() + 500;
			end

			-- No Mind Blast but wand ? fixed!
			if (not HasSpell("Mind Blast")) and (localObj:HasRangedWeapon()) and (self.useWand) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
				end -- move to target
					if (not IsAutoCasting("Shoot")) then
						targetObj:CastSpell("Shadow Word: Pain");
						self.message = "Using wand...";
						targetObj:FaceTarget();
						targetObj:CastSpell("Shoot");
						self.waitTimer = GetTimeEX() + 250;
						return true; -- return true - if not AutoCasting then false
					end
				if (script_priest:healAndBuff(localObj, localMana)) then
					return;
				end
			end

			if (targetObj:IsInLineOfSight() and not IsMoving() and script_grind.lootObj == nil) then
				if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
					if (not targetObj:FaceTarget()) then
						targetObj:FaceTarget();
					end
				end
			end


			-- Devouring Plague to pull
			if (HasSpell("Devouring Plague")) and (localMana >= 25) and (not IsSpellOnCD("Devouring Plague")) and (not IsMoving()) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (Cast("Devouring Plague", targetObj)) then
					targetObj:FaceTarget();
					self.waitTimer = GetTimeEX() + 200;
					self.message = "Casting Devouring Plague!";
					return 0; -- keep trying until cast
				end
			end

			-- Mind Blast to pull
			if (HasSpell("Mind Blast")) and (localMana >= self.mindBlastMana) and (not IsSpellOnCD("Mind Blast")) and (not IsMoving()) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (IsMoving()) then
					StopMoving();
				end
				if (Cast("Mind Blast", targetObj)) then	
					targetObj:FaceTarget();
					self.waitTimer = GetTimeEX() + 750;
					self.message = "Casting Mind Blast!";
					return 0; -- keep trying until cast
				end

				-- vampiric embrace
			elseif (HasSpell("Vampiric Embrace")) and (not IsSpellOnCD("Vampiric Embrace")) and (not targetObj:HasDebuff("Vampiric Embrace")) and (not IsMoving()) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (Cast("Vampiric Embrace", targetObj)) then	
					targetObj:FaceTarget();
					self.waitTimer = GetTimeEX() + 750;
					self.message = "Casting Vampiric Embrace!";
					return 0; -- keep trying until cast
				end
				--shadow word pain if mindblast is on CD to pull if no wand
			elseif (HasSpell("Shadow Word: Pain")) and (not targetObj:HasDebuff("Shadow Word: Pain")) and (IsSpellOnCD("Mind Blast")) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (Cast("Shadow Word: Pain", targetObj)) then
					targetObj:FaceTarget();
					self.waitTimer = GetTimeEX() + 750;
					return 0; -- keep trying until cast
				end

			-- Use Smite if we have it
			elseif (self.useSmite) and (localMana >= 7) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (IsMoving()) then
					StopMoving();
				end
				if (Cast("Smite", targetObj)) then
					targetObj:FaceTarget();
					self.waitTimer = GetTimeEX() + 750;
					self.message = "Smite is checked!";
					return 0; -- keep trying until cast
				end
			end

			-- recheck line of sight on target
			if (not targetObj:IsInLineOfSight()) then
				return 3;
			end

		-- IN COMBAT

		-- Combat
		else	
		
			--set tick rate
			if (IsInCombat()) then
				script_grind.tickRate = 200;
			else
				script_grind.tickRate = 100;
			end

			self.message = "Killing.. " .. targetObj:GetUnitName() .. "...";

			-- Dismount
			if (IsMounted()) then DisMount(); end

			-- check heals and buffs
			if (script_priest:healAndBuff(localObj, localMana)) then
				return;
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

			-- new follow target
			if (targetObj:IsInLineOfSight() and not IsMoving() and targetHealth <= 99) then
				if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
					if (not targetObj:FaceTarget()) then
						targetObj:FaceTarget();
					end
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
					CastSpellByName("Mind Blast", targetObj);
					self.waitTimer = GetTimeEX() + 750;
					return;
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
					return; -- keep trying until cast
				end
			end

			-- Check: keep vampiric embrace up
			if (HasSpell("Vampiric Embrace")) and (not IsSpellOnCD("Vampiric Embrace")) and (not targetObj:HasDebuff("Vampiric Embrace")) and (localMana >= 3) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
					return 3; -- target not in line of sight
				end -- move to target
				if (Cast("Vampiric Embrace", targetObj)) then	
					self.waitTimer = GetTimeEX() + 750;
					self.message = "Casting Vampiric Embrace!";
					return; -- keep trying until cast
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
					self.waitTimer = GetTimeEX() + 1250;
					return; -- keep trying until cast
				end
				-- check inner fire in combat
			elseif (IsInCombat()) and (not localObj:HasBuff("Inner Fire")) and (HasSpell("Inner Fire")) and (localMana >= 8) then
				if (localObj:HasBuff("Power Word: Shield")) then
					if (Buff("Inner Fire", localObj)) then
						self.waitTimer = GetTimeEX() + 750;
						return; -- keep trying until cast
					end
				end
			end

			-- inner focus
			if (not localObj:HasBuff("Inner Focus")) and (HasSpell("Inner Focus")) then
				if (not IsSpellOnCD("Inner Focus")) then
					if (GetLocalPlayer():GetManaPercentage() <= 20) and (GetLocalPlayer():GetHealthPercentage() <= 20) then
						if (Buff("Inner Focus")) then
							self.waitTimer = GetTimeEX() + 1500;
							return; -- keep trying until cast
						end
					end
				end
				-- cast heal while inner focus active
			elseif (localObj:HasBuff("Inner Focus")) then
				if (Cast("Flash Heal", localObj)) then
					return; -- keep trying until cast
				end
			end

			-- Power Infusion low health 50% or targets >= 1
			if (HasSpell("Power Infusion")) and (not IsSpellOnCD("Power Infusion")) then
				if (localHealth <= 50) or (script_priest:enemiesAttackingUs(8) >= 2) then
					if (Buff("Power Infusion")) then
						return; -- keep trying until cast
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
				return; -- keep trying until cast
			end

			-- new follow target
			if (targetObj:IsInLineOfSight() and not IsMoving() and targetHealth <= 99) then
				if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
					if (not targetObj:FaceTarget()) then
						targetObj:FaceTarget();
					end
				end
			end

			-- Mind flay 
			if (self.shadowForm or self.useMindFlay) and (IsSpellOnCD("Mind Blast") or localMana <= self.mindBlastMana) then
				if (HasSpell("Mind Flay")) and (not IsSpellOnCD("Mind Flay")) and (localMana >= self.mindFlayMana) and (targetHealth >= self.mindFlayHealth) and
					(not localObj:IsChanneling() and targetObj:GetDistance() <= 20) then
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					if (Cast("Mind Flay", targetObj)) then
						self.waitTimer = GetTimeEX() + 1500
						return 0; -- keep trying until cast
					end
				end
			end

			--mind flay and then wand when set
			if (self.useMindFlay) and (not localObj:IsCasting() or not localObj:IsChanneling()) and
				(localMana <= self.mindFlayMana or targetHealth <= self.mindFlayHealth) or (targetObj:GetDistance() >= 25) then
				if (localObj:HasRangedWeapon()) then
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					if (not IsAutoCasting("Shoot")) then
						self.message = "Using wand...";
						targetObj:FaceTarget();
						targetObj:CastSpell("Shoot");
						self.waitTimer = GetTimeEX() + 250;
						return true; -- return if not AutoCasting then false
					end
					if (script_priest:healAndBuff(localObj, localMana)) then
						return;
					end
				end
			end

			--Wand if set to use wand
			if (self.useWand and not self.useMindFlay) and (not localObj:IsCasting()) and (IsSpellOnCD("Mind Blast")) or (localMana <= self.mindBlastMana) then
				if (localMana <= self.useWandMana) and (targetHealth <= self.useWandHealth) and (localObj:HasRangedWeapon()) then
					if (script_priest:healAndBuff(localObj, localMana)) then
						return;
					end
					
					-- use mind blast on CD
					if (HasSpell("Mind Blast")) and (not IsSpellOnCD("Mind Blast")) then
						if (targetHealth >= 20) and (localMana >= self.mindBlastMana) then
							CastSpellByName("Mind Blast", targetObj);
							self.waitTimer = GetTimeEX() + 750;
							return;
						end
			
					end


					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target

					if (script_priest:healAndBuff(localObj, localMana)) then
						return;
					end
					
					-- use mind blast on CD
					if (HasSpell("Mind Blast")) and (not IsSpellOnCD("Mind Blast")) then
						if (targetHealth >= 20) and (localMana >= self.mindBlastMana) then
							CastSpellByName("Mind Blast", targetObj);
							self.waitTimer = GetTimeEX() + 750;
						end
					end

					if (not IsAutoCasting("Shoot")) then
						self.message = "Using wand...";
						targetObj:FaceTarget();
						targetObj:CastSpell("Shoot");
						--self.waitTimer = GetTimeEX() + 250; 
					end
				end
			end

			-- No Mind Blast but wand ? fixed!
			if (not HasSpell("Mind Blast")) and (localObj:HasRangedWeapon()) and (self.useWand) then
				if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
				end -- move to target
					if (not IsAutoCasting("Shoot")) then
						self.message = "Using wand...";
						targetObj:FaceTarget();
						targetObj:CastSpell("Shoot");
						self.waitTimer = GetTimeEX() + 250; 
						return true; -- return true - if not AutoCasting then false
					end
				if (script_priest:healAndBuff(localObj, localMana)) then
					return;
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

	-- looting
	local lootRadius = 20;
	local lootObj = script_nav:getLootTarget(lootRadius);
	
	if (not AreBagsFull() and not script_grind.bagsFull and script_grind.lootObj ~= nil) then
		if (script_grind:doLoot(localObj)) then
			self.waitTimer = GetTimeEX() + 1500;
		end

		if (script_grind.skinning) then
			script_grind:lootAndSkin();
			self.waitTimer = GetTimeEX() + 1500;
		end

		script_nav:resetNavigate();
		script_nav:resetNavPos();
		ClearTarget();
		self.waitTimer = GetTimeEX() + 1000;
		return;
	end

	-- use scrolls
	if (script_helper:useScrolls()) then
		self.waitTimer = GetTimeEX() + 1500;
	end

	-- Stop moving before we can rest
	if (localHealth <= self.eatHealth) or (localMana <= self.drinkMana) then
		if (IsMoving()) then
			StopMoving();
			return true;
		end
	end

	-- check heals and buffs
	if (script_priest:healAndBuff(localObj, localMana)) then 
		return;
	end

	--buff="Power Word: Fortitude(Rank " Sp={1,2,14,26,38,50};
	--if (UnitLevel("target") ~= nil and UnitIsFriend("player","target")) then
	--	for i=6, 1, -1 do 
	--		if (UnitLevel("target") >= Sp) then
	--			CastSpellByName(buff..i..")");
	--			return;
	--		end
	--	end
	--end 

	-- Check: Drink
	if (not IsDrinking()) and (localMana <= self.drinkMana) and (not IsInCombat()) then
		self.waitTimer = GetTimeEX() + 2000;
		self.message = "Need to drink...";
		if (IsMoving()) then
			StopMoving();
			self.waitTimer = GetTimeEX() + 2000;
			return true;
		end

		if (script_helper:drinkWater()) then 
			self.message = "Drinking..."; 
			self.waitTimer = GetTimeEX() + 15000;
			return true; 
		else 
			self.message = "No drinks! (or drink not included in script_helper)";
			return true; 
		end
	end

	-- Check: Eat
	if (not IsEating()) and (localHealth <= self.eatHealth) and (not IsInCombat()) then
		self.waitTimer = GetTimeEX() + 2000;
		self.message = "Need to eat...";	
		if (IsMoving()) then
			StopMoving();
			self.waitTimer = GetTimeEX() + 2000;
			return true;
		end
		
		if (script_helper:eat()) then 
			self.message = "Eating..."; 
			self.waitTimer = GetTimeEX() + 15000;
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
			script_priest:menuEX();
		end
	end
end