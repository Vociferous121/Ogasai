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
	potionMana = 8,	-- use potion at mana %
	potionHealth = 6,	-- use potion at health %
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
	swpMana = 15, -- Use shadow word: pain above this mana %
	followTargetDistance = 100,
	rangeDistance = 28,
	openerRange = 25,
}

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
 			--\script_navEX:moveToTarget(localObj, moveX, moveY, moveZ);
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

	if (not HasSpell("Mind Blast")) then
		self.useSmite = true;
		self.useWandHealth = 65;
	end

	if (HasSpell("Vampiric Embrace")) then
		self.openerRange = 30;
	end

end

function script_priest:draw()
	local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
	if (onScreen) then
		if (script_grind.adjustText) and (script_grind.drawEnabled) then
			tX = tX + script_grind.adjustX;
			tY = tY + script_grind.adjustY;
		end

	DrawText(self.message, tX+230, tY+9, 255, 250, 205);
	else
		if (script_grind.adjustText) and (script_grind.drawEnabled) then
			tX = tX + script_grind.adjustX;
			tY = tY + script_grind.adjustY;
		end

	DrawText(self.message, 25, 185, 255, 250, 205);
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
	
	local localObj = GetLocalPlayer(); -- get player

	local localMana = localObj:GetManaPercentage(); -- get player mana percentage wow API

	local localHealth = localObj:GetHealthPercentage(); -- get player health percentage wow API

	local localLevel = localObj:GetLevel(); -- get player level wow API
	
	-- if no wand equipped then force using smite
	if (not localObj:HasRangedWeapon()) then
		self.useWand = false;
	elseif (localObj:HasRangedWeapon()) then
		self.useWand = true;
	end

	-- if target is dead then don't attack
	if (localObj:IsDead()) then
		self.message = "You have died";
		return 0;
	end

	if (script_priestEX:healsAndBuffs(localObj, localMana)) then
		return;
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

	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = math.random(300, 600);

		if (IsMoving()) or (not IsInCombat()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) or (localObj:IsCasting()) then
			script_grind.tickRate = tickRandom
		elseif (IsInCombat()) and (not IsMoving()) or (localObj:IsCasting()) then
			script_grind.tickRate = tickRandom;
		end
	end

	-- wand cast if silenced
	if (targetObj ~= 0) and (targetObj ~= nil) and (not localObj:IsStunned()) and (script_checkDebuffs:hasSilence()) and (localObj:HasRangedWeapon()) and (IsInCombat()) then
		if (not IsAutoCasting("Shoot")) and (self.useWand) then
			self.message = "Using wand...";
			targetObj:FaceTarget();
			targetObj:CastSpell("Shoot");
			return true; -- return true - if not AutoCasting then false
		end
		if (script_priestEX:healsAndBuffs(localObj, localMana)) then
			return;
		end
	end
	
	-- dismount before combat
	if (IsMounted()) then
		DisMount();
	end
	
	--Valid Enemy
	if (targetObj ~= 0) and (targetObj ~= nil) and (not localObj:IsStunned()) and (not script_checkDebuffs:hasSilence()) then


		if (IsInCombat()) and (script_grind.skipHardPull) and (GetNumPartyMembers() == 0) then
			if (script_checkAdds:checkAdds()) then
				script_om:FORCEOM();
				return true;
			end
		end

		-- Cant Attack dead targets
		if (targetObj:IsDead()) or (not targetObj:CanAttack()) then
			ClearTarget();
			return 2;
		end

		-- stand if sitting
		if (not IsStanding()) then
			JumpOrAscendStart();
		end

		-- Don't attack if we should rest first
		if (GetNumPartyMembers() < 1) and ((localHealth < self.eatHealth or localMana < self.drinkMana) and not script_grind:isTargetingMe(targetObj) and not targetObj:IsFleeing() and not targetObj:IsStunned()) then
				self.message = "Need rest...";
				return 4;
		end

		-- set target health
		targetHealth = targetObj:GetHealthPercentage();

		-- Auto Attack
		if (targetObj:GetDistance() <= 40) then
			targetObj:AutoAttack();
		end

		if (GetLocalPlayer():GetUnitsTarget() ~= 0) and (targetObj:GetDistance() <= 30) and (IsInCombat()) then
			if (not targetObj:FaceTarget()) then
				targetObj:FaceTarget();
			end
		end

		-- Check: if we target player pets/totems
		if (GetTarget() ~= 0) then
			if (GetTarget():GetGUID() ~= GetLocalPlayer():GetGUID()) then
				if (UnitPlayerControlled("target")) then 
					script_grind:addTargetToBlacklist(targetObj:GetGUID());
					return 5; 
				end
			end
		end  

		if (IsInCombat()) and (GetLocalPlayer():GetUnitsTarget() ~= 0) then
			if (targetObj:GetDistance() <= 15) then
				targetObj:FaceTarget();
				targetObj:AutoAttack();
			end
		end

		-- Opener - not in combat pulling target
		if (not IsInCombat()) then

			-- stand if sitting
			if (not IsStanding()) then
				JumpOrAscendStart();
			end

			-- Dismount
			if (IsMounted()) then
				DisMount();
			end

			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";
			
			-- Opener check range of ALL SPELLS
			if (targetObj:GetDistance() > self.openerRange) or (not targetObj:IsInLineOfSight()) then
				self.message = "Walking to spell range!";
				return 3;
			end

			-- forces bot to walk closer to enemy and adds some randomness
			if (targetObj:GetDistance() <= self.openerRange + 3) then
				self.openerRange = 31;
			end

			-- casts mind blast quicker
			if (HasSpell("Mind Blast")) and (targetObj:IsInLineOfSight()) and (not IsSpellOnCD("Mind Blast")) and (not IsMoving()) then
				if (not HasSpell("Vampiric Embrace")) or (not HasSpell("Devouring Plague")) then
					CastSpellByName("Mind Blast");
					targetObj:FaceTarget();
					self.waitTimer = GetTimeEX() + 1850;
					return 0;
				end
			end
			
			-- smite low level wouldn't cast for some reason kept defaulting to auto attack
			if (GetLocalPlayer():GetLevel() <= 3) and (targetObj:GetDistance() < 28) and (localMana > 10) then
				CastSpellByName("Smite", targetObj);
				targetObj:FaceTarget();
			end

			-- No Mind Blast but wand ? fixed!
			if (not HasSpell("Mind Blast")) and (localObj:HasRangedWeapon()) and (self.useWand) and (not self.useSmite) then
					if (not IsAutoCasting("Shoot")) and (self.useWand) then
						self.message = "Using wand...";
						if (not targetObj:FaceTarget()) then
							targetObj:FaceTarget();
						end
						targetObj:CastSpell("Shoot");
						return true; -- return true - if not AutoCasting then false
					end
				if (script_priestEX:healsAndBuffs(localObj, localMana)) then
					return;
				end
			end

			-- Devouring Plague to pull
			if (HasSpell("Devouring Plague")) and (localMana >= 25) and (not IsSpellOnCD("Devouring Plague")) and (not IsMoving()) then
				if (Cast("Devouring Plague", targetObj)) then
					targetObj:FaceTarget();
					self.waitTimer = GetTimeEX() + 200;
					self.message = "Casting Devouring Plague!";
					return 0; -- keep trying until cast
				end
			end

			-- Mind Blast to pull
			if (HasSpell("Mind Blast")) and (localMana >= self.mindBlastMana) and (not IsSpellOnCD("Mind Blast")) and (not IsMoving()) and (targetObj:IsInLineOfSight()) then
				if (Cast("Mind Blast", targetObj)) then	
					targetObj:FaceTarget();
					self.waitTimer = GetTimeEX() + 1850;
					self.message = "Casting Mind Blast!";
					return 0; -- keep trying until cast
				end

				-- vampiric embrace
			elseif (HasSpell("Vampiric Embrace")) and (not IsSpellOnCD("Vampiric Embrace")) and (not targetObj:HasDebuff("Vampiric Embrace")) and (not IsMoving()) and (targetObj:IsInLineOfSight()) then
				if (Cast("Vampiric Embrace", targetObj)) then	
					targetObj:FaceTarget();
					self.waitTimer = GetTimeEX() + 1850;
					self.message = "Casting Vampiric Embrace!";
					return 0; -- keep trying until cast
				end
				--shadow word pain if mindblast is on CD to pull if no wand
			elseif (HasSpell("Shadow Word: Pain")) and (not targetObj:HasDebuff("Shadow Word: Pain")) and (IsSpellOnCD("Mind Blast")) and (targetObj:IsInLineOfSight()) then
				if (Cast("Shadow Word: Pain", targetObj)) then
					targetObj:FaceTarget();
					self.waitTimer = GetTimeEX() + 1850;
					return 0; -- keep trying until cast
				end

			-- Use Smite and wand
			elseif (self.useSmite) and (localMana >= self.useWandMana) and (targetHealth >= self.useWandHealth) then
				if (not IsMoving()) then
					Cast("Smite", targetObj);
					targetObj:FaceTarget();
					self.waitTimer = GetTimeEX() + 750;
					self.message = "Smite is checked!";
					return 0; -- keep trying until cast
				end
				if (HasSpell("Holy Fire")) and (not targetObj:HasDebuff("Holy Fire")) and (localMana >= 25) then
					targetObj:FaceTarget();
					CastSpellByName("Holy Fire");
					self.waitTimer = GetTimeEX() + 750;
					return 0;
				end

			-- Use Smite if we have it
			elseif (self.useSmite) and (localMana >= 7) then
				if (Cast("Smite", targetObj)) then
					targetObj:FaceTarget();
					self.waitTimer = GetTimeEX() + 750;
					self.message = "Smite is checked!";
					return 0; -- keep trying until cast
				end
				if (HasSpell("Holy Fire")) and (not targetObj:HasDebuff("Holy Fire")) and (localMana >= 25) then
					targetObj:FaceTarget();
					CastSpellByName("Holy Fire");
					self.waitTimer = GetTimeEX() + 750;
					return 0;
				end
			end

			-- recheck line of sight on target
			if (not targetObj:IsInLineOfSight()) then
				return 3;
			end




		-- IN COMBAT

		-- Combat

		else	

			if (IsInCombat()) and (not localObj:HasRangedWeapon()) and (IsAutoCasting("Attack")) then
				if (targetObj:GetDistance() > 6) then
					return 3;
				end
			end

			if (targetObj:GetDistance() > 30) or (not targetObj:IsInLineOfSight()) then
				return 3;
			end

			self.message = "Killing.. " .. targetObj:GetUnitName() .. "...";

			-- Dismount
			if (IsMounted()) then DisMount(); end

			if (targetObj:IsInLineOfSight() and not IsMoving()) then
				if (targetObj:GetDistance() <= 32) and (targetObj:IsInLineOfSight()) and (script_grind:isTargetingMe(targetObj)) then
					targetObj:FaceTarget();
				end
			end

			-- Berserking Troll Racial
			if (HasSpell("Berserking")) and (not IsSpellOnCD("Berserking")) and (targetHealth > 30) then
				CastSpellByName("Berserking");
				return 0;
			end

			-- check heals and buffs
			if (script_priestEX:healsAndBuffs(localObj, localMana)) then
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

			-- Silence
			if (HasSpell("Silence")) and (targetObj:IsCasting()) and (localMana >= 15) and (targetHealth >= 25) then
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

			--hex of weakness troll
			if (HasSpell("Hex of Weakness")) then
				if (not targetObj:HasDebuff("Hex of Weakness")) and (localMana >= 25) then
					CastSpellByName("Hex of Weakness");
					self.waitTimer = GetTimeEX() + 1550;
					return 0;
				end
			end

			-- use mind blast on CD
			if (HasSpell("Mind Blast")) and (not IsSpellOnCD("Mind Blast")) then
				if (targetHealth >= 20) and (localMana >= self.mindBlastMana) then
					CastSpellByName("Mind Blast", targetObj);
					targetObj:FaceTarget();
					self.waitTimer = GetTimeEX() + 1550;
					return;
				end
			
			end

			-- Check: Keep Shadow Word: Pain up
			if (not targetObj:HasDebuff("Shadow Word: Pain")) and (HasSpell("Shadow Word: Pain")) and (localMana >= self.swpMana) and (targetHealth >= 20) then
				if (Cast("Shadow Word: Pain", targetObj)) then 
					self.waitTimer = GetTimeEX() + 1550;
					self.message = "Keeping DoT up!";
					return; -- keep trying until cast
				end
			end

			-- Check: keep vampiric embrace up
			if (HasSpell("Vampiric Embrace")) and (not IsSpellOnCD("Vampiric Embrace")) and (not targetObj:HasDebuff("Vampiric Embrace")) and (localMana >= 3) then
				if (Cast("Vampiric Embrace", targetObj)) then	
					self.waitTimer = GetTimeEX() + 1550;
					self.message = "Casting Vampiric Embrace!";
					return; -- keep trying until cast
				end
			end

			-- night elf Elune's Grace racial
			if (IsInCombat()) and (HasSpell("Elune's Grace")) and (not IsSpellOnCD("Elune's Grace")) and (not localObj:HasBuff("Elune's Grace")) and (localHealth < 75) then
				if (Buff("Elune's Grace", localObj)) then
					self.waitTimer = GetTimeEX() + 1550;
					return true;
				end
			end

			-- Check: Keep Inner Fire up
			if (not IsInCombat()) and (not localObj:HasBuff("Inner Fire")) and (HasSpell("Inner Fire")) and (localMana >= 25) then
				Buff("Inner Fire", localObj);
				self.waitTimer = GetTimeEX() + 1550;
				return; -- keep trying until cast
				-- check inner fire in combat
			elseif (IsInCombat()) and (not localObj:HasBuff("Inner Fire")) and (HasSpell("Inner Fire")) and (localMana >= 8) then
				if (localObj:HasBuff("Power Word: Shield")) then
					Buff("Inner Fire", localObj);
					self.waitTimer = GetTimeEX() + 1550;
					return; -- keep trying until cast
				end
			end

			-- Cast: Smite (last choice e.g. at level 1)
			if (self.useSmite) and (self.useWand) and (targetHealth >= self.useWandHealth) and (localMana >= 7) then
				if (Cast("Smite", targetObj)) then 
					self.waitTimer = GetTimeEX() + 750;
					return 0; -- keep trying until cast
				end
			elseif (self.useSmite) and (not localObj:HasRangedWeapon()) and (localMana >=7) then
				if (Cast("Smite", targetObj)) then 
					self.waitTimer = GetTimeEX() + 750;
					return 0; -- keep trying until cast
				end
			end

			-- check heal and buffs
			if (script_priestEX:healsAndBuffs(localObj, localMana)) then
				return; -- keep trying until cast
			end

			-- Mind flay 
			if (self.shadowForm or self.useMindFlay) and (IsSpellOnCD("Mind Blast") or localMana <= self.mindBlastMana) then
				if (HasSpell("Mind Flay")) and (not IsSpellOnCD("Mind Flay")) and (targetHealth >= self.mindFlayHealth) and
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

			if (self.useWand) and (targetObj:GetDistance() > 25) or (not targetObj:IsInLineOfSight()) then
				return 3;
			end

			--mind flay and then wand when set
			if (self.useMindFlay) and (self.useWand) and (not localObj:IsCasting() or not localObj:IsChanneling()) and
				(localMana <= self.mindFlayMana or targetHealth <= self.mindFlayHealth) or (targetObj:GetDistance() <= 25) then
				if (localObj:HasRangedWeapon()) then
					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target
					if (not IsAutoCasting("Shoot")) and (self.useWand) then
						self.message = "Using wand...";
						if (not targetObj:FaceTarget()) then
							targetObj:FaceTarget();
						end
						targetObj:CastSpell("Shoot");
						return true; -- return if not AutoCasting then false
					end
					if (script_priestEX:healsAndBuffs(localObj, localMana)) then
						return;
					end
				end
			end

			--Wand if set to use wand
			if (self.useWand and not self.useMindFlay) and (not localObj:IsCasting()) and (IsSpellOnCD("Mind Blast")) then
				if (localMana <= self.useWandMana) and (targetHealth <= self.useWandHealth) and (localObj:HasRangedWeapon()) then
					if (script_priestEX:healsAndBuffs(localObj, localMana)) then
						return;
					end
					
					-- use mind blast on CD
					if (HasSpell("Mind Blast")) and (not IsSpellOnCD("Mind Blast")) then
						if (targetHealth >= 20) and (localMana >= self.mindBlastMana) then
							CastSpellByName("Mind Blast", targetObj);
							targetObj:FaceTarget();
							self.waitTimer = GetTimeEX() + 1550;
							return;
						end
			
					end


					if (not targetObj:IsInLineOfSight()) then -- check line of sight
						return 3; -- target not in line of sight
					end -- move to target

					if (script_priestEX:healsAndBuffs(localObj, localMana)) then
						return;
					end
					
					-- use mind blast on CD
					if (HasSpell("Mind Blast")) and (not IsSpellOnCD("Mind Blast")) then
						if (targetHealth >= 20) and (localMana >= self.mindBlastMana) then
							CastSpellByName("Mind Blast", targetObj);
							targetObj:FaceTarget();
							self.waitTimer = GetTimeEX() + 1550;
						end
					end

					if (not IsAutoCasting("Shoot")) and (self.useWand) then
						self.message = "Using wand...";
						targetObj:CastSpell("Shoot");
					end
				end
			end

			if (not self.useMindFlay) and (self.useWand) and (targetHealth < 25) then
				if (not IsAutoCasting("Shoot")) and (self.useWand) then
						self.message = "Using wand...";
						targetObj:FaceTarget();
						targetObj:CastSpell("Shoot");
						return true; -- return true - if not AutoCasting then false
					end
			end

			-- No Mind Blast but wand ? fixed!
			if (not HasSpell("Mind Blast")) and (localObj:HasRangedWeapon()) and (self.useWand) then
					if (not IsAutoCasting("Shoot")) and (self.useWand) then
						self.message = "Using wand...";
						if (not targetObj:FaceTarget()) then
							targetObj:FaceTarget();
						end
						targetObj:CastSpell("Shoot");
						return true; -- return true - if not AutoCasting then false
					end
				if (script_priestEX:healsAndBuffs(localObj, localMana)) then
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

	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = math.random(1388, 2061);

		if (IsMoving()) or (not IsInCombat()) and (not localObj:IsCasting()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) or (localObj:IsCasting()) then
			script_grind.tickRate = tickRandom
		elseif (IsInCombat()) and (not IsMoving()) or (localObj:IsCasting()) then
			script_grind.tickRate = tickRandom;
		end
	end

	local localObj = GetLocalPlayer();

	local localMana = localObj:GetManaPercentage();

	local localHealth = localObj:GetHealthPercentage();

	-- dismount before combat
	if (IsMounted()) then
		DisMount();
	end

	-- Stop moving before we can rest
	if (localHealth <= self.eatHealth) or (localMana <= self.drinkMana) then
		if (IsMoving()) then
			self.waitTimer = GetTimeEX() + 1000;
			StopMoving();
			return true;
		end
	end

	-- check heals and buffs
	if (script_priestEX:healsAndBuffs(localObj, localMana)) then 
		return;
	end
	
	-- can buff nearby players. needs work. 
	--buff="Power Word: Fortitude(Rank " Sp={1,2,14,26,38,50};
	--if (UnitLevel("target") ~= nil and UnitIsFriend("player","target")) then
	--	for i=6, 1, -1 do 
	--		if (UnitLevel("target") >= Sp) then
	--			CastSpellByName(buff..i..")");
	--			return 0;
	--		end
	--	end
	--end 

	-- Eat and Drink
	if (not IsDrinking() and localMana < self.drinkMana) and (not localObj:HasBuff("Spirit Tap")) then

		ClearTarget();

		self.message = "Need to drink...";
		self.waitTimer = GetTimeEX() + 2200;

		-- Dismount
		if(IsMounted()) then 
			DisMount(); 
			return true; 
		end
		if (IsMoving()) then
			StopMoving();
			return true;
		end

		if (script_helper:drinkWater()) then 
			self.message = "Drinking..."; 
			self.waitTimer = GetTimeEX() + 1200;
			return true; 
		else 
			self.message = "No drinks! (or drink not included in script_helper)";
			return true; 
		end
	end

	-- drink with spirit tap
	if (not IsDrinking() and localMana <= (self.drinkMana/2)) and (localObj:HasBuff("Spirit Tap")) then

		ClearTarget();

		self.message = "Need to drink...";
		self.waitTimer = GetTimeEX() + 2200;

		-- Dismount
		if(IsMounted()) then 
			DisMount(); 
			return true; 
		end
		if (IsMoving()) then
			StopMoving();
			return true;
		end

		if (script_helper:drinkWater()) then 
			self.message = "Drinking..."; 
			self.waitTimer = GetTimeEX() + 1200;
			return true; 
		else 
			self.message = "No drinks! (or drink not included in script_helper)";
			return true; 
		end
	end
	if (not IsEating() and localHealth < self.eatHealth) then
		-- Dismount
		if(IsMounted()) then
			DisMount();
		end
		self.message = "Need to eat...";	
		if (IsMoving()) then
			self.waitTimer = GetTimeEX() + 900;
			StopMoving();
			return true;
		end
		
		if (script_helper:eat()) then 
			self.message = "Eating..."; 
			self.waitTimer = GetTimeEX() + 800;
			return true; 
		else 
			self.message = "No food! (or food not included in script_helper)";
			self.waitTimer = GetTimeEX() + 600;
			return true; 
		end	
	end
	
	if(localMana < self.drinkMana or localHealth < self.eatHealth) then
		if (IsMoving()) then
			StopMoving();
			self.waitTimer = GetTimeEX() + 500;
		end
		return true;
	end

	-- night elve stealth while resting
	if (IsDrinking() or IsEating()) and (HasSpell("Shadowmeld")) and (not IsSpellOnCD("Shadowmeld")) and (not localObj:HasBuff("Shadowmeld")) and (HasSpell("Shadowmeld")) then
		if (CastSpellByName("Shadowmeld")) then
			return;
		end
	end
	
	if((localMana < 98 and IsDrinking()) or (localHealth < 98 and IsEating())) then
		self.message = "Resting to full hp/mana...";
		return true;
	end

	if (not IsDrinking()) and (not IsEating()) then
		if (not IsStanding()) then
			JumpOrAscendStart();
		end
	end

	-- No rest / buff needed
	return false;
end

function script_priest:window()

	if (self.isChecked) then
	
		--Close existing Window
		EndWindow();

		if(NewWindow("Combat Options and Self Heals", 200, 200)) then
			script_priest:menuEX();
		end
	end
end