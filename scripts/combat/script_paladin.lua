script_paladin = {
	message = "Paladin Combat Script",
	paladinMenu = include("scripts\\combat\\script_paladinEX.lua"),
	isSetup = false,
	isChecked = true,
	stopIfMHBroken = true,
	useFlashOfLightCombat = true,
	aura = "Devotion Aura",
	blessing = "Blessing of Wisdom",
	waitTimer = 0,
	eatHealth = 30,
	drinkMana = 40,
	bopHealth = 20,
	lohHealth = 10,
	holyLightHealth = 55,
	flashOfLightHP = 65,
	potionHealth = 12,
	potionMana = 20,
	consecrationMana = 50,
	meleeDistance = 3.00,
	followTargetDistance = 100,
	useSealOfCrusader = false,

	-- turtle wow
	crusaderStacks = 3,
	crusaderStacksMana = 40,
	crusaderStacksHealth = 35,
}

function script_paladin:setup()

	-- Sort Aura  

	--use Devotion Aura if nothing else
	if (not HasSpell("Retribution Aura")) and (not HasSpell("Sanctity Aura")) and (not localObj:HasBuff("Stoneskin")) then
		self.aura = "Devotion Aura";	

		-- else use Ret aura if have it
	elseif (not HasSpell("Sanctity Aura")) and (HasSpell("Retribution Aura")) then
		self.aura = "Retribution Aura";

		-- else use Sanctity aura if have it
	elseif (HasSpell("Sanctity Aura")) then
		self.aura = "Sanctity Aura";	
	end

	-- Sort Blessing  

	-- Blessing of wisdom
	if (HasSpell("Blessing of Wisdom")) then
		self.blessing = "Blessing of Wisdom";
	
		--Blessing of might
	elseif (HasSpell("Blessing of Might")) then
		self.blessing = "Blessing of Might";
	end
	
	self.waitTimer = GetTimeEX();

	self.isSetup = true;

	-- Force setting devotion aura
	--self.aura = "Devotion Aura";

end

function script_paladin:spellAttack(spellName, target)
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

function script_paladin:enemiesAttackingUs(range) -- returns number of enemies attacking us within range
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
function script_paladin:runBackwards(targetObj, range) 
	local localObj = GetLocalPlayer();
 	if targetObj ~= 0 then
 		local xT, yT, zT = targetObj:GetPosition();
 		local xP, yP, zP = localObj:GetPosition();
 		local distance = targetObj:GetDistance();
 		local xV, yV, zV = xP - xT, yP - yT, zP - zT;	
 		local vectorLength = math.sqrt(xV^2 + yV^2 + zV^2);
 		local xUV, yUV, zUV = (1/vectorLength)*xV, (1/vectorLength)*yV, (1/vectorLength)*zV;		
 		local moveX, moveY, moveZ = xT + xUV*5, yT + yUV*5, zT + zUV;		
 		if (distance < range) then 
 			Move(moveX, moveY, moveZ);
			self.waitTimer = GetTimeEX() + 1500;
 			return true;
 		end
	end
	return false;
end

function script_paladin:draw()
	--script_paladin:window();

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
			5 - targeted player pet/totem
			6 - stop bot request from combat script  ]]--

function script_paladin:healAndBuff(targetObj)

	-- to do!!

	local localMana = GetLocalPlayer():GetManaPercentage();
	local localHealth = GetLocalPlayer():GetHealthPercentage();

	if (HasSpell("Holy Light")) and (localMana > 25) and (localHealth < self.holyLightHealth) then
		CastSpellByName("Holy Light")
		self.waitTimer = GetTimeEX() + 500;
		return;
	end
end

function script_paladin:run(targetGUID)
	
	local localObj = GetLocalPlayer();

	local localMana = localObj:GetManaPercentage();

	local localHealth = localObj:GetHealthPercentage();

	local localLevel = localObj:GetLevel();

	-- setup
	if (not self.isSetup) then
		script_paladin:setup();
	end

	-- if dead run rest of script
	if (localObj:IsDead()) then
		return 0; 
	end

	-- Check: If Mainhand is broken stop bot
	isMainHandBroken = GetInventoryItemBroken("player", 16);
	
	if (self.stopIfMHBroken) and (isMainHandBroken) then
		self.message = "The main hand weapon is broken...";
		return 6;
	end

	-- Assign the target 
		targetObj = GetGUIDObject(targetGUID);

	if(targetObj == 0) or (targetObj == nil) then
		return 2;
	end

	-- Check: Do nothing if we are channeling or casting or wait timer
	if (IsChanneling()) or (IsCasting()) or (self.waitTimer > GetTimeEX()) then
		return 4;
	end

	-- Buff with Blessing
	if (self.blessing ~= 0) and (HasSpell(self.blessing)) then
		if (not IsStanding()) then
			JumpOrAscendStart();
		end
		if (localMana > 10) and (not localObj:HasBuff(self.blessing)) then
			Buff(self.blessing, localObj);
			return 0;
		end
	end

	if (not script_grind.adjustTickRate) then
		if (not IsInCombat()) or (targetObj:GetDistance() > self.meleeDistance) then
			script_grind.tickRate = 100;
		elseif (IsInCombat()) then
			script_grind.tickRate = 750;
		end
	end
	
	--Valid Enemy
	if (targetObj ~= 0) then
		
		-- Cant Attack dead targets
		if (targetObj:IsDead()) or (not targetObj:CanAttack()) then
			self.waitTimer = GetTimeEX() + 1200;
			return 0;
		end
		
		if (not IsStanding()) then
			JumpOrAscendStart();
		end

		if (targetObj:IsInLineOfSight() and not IsMoving() and script_grind.lootObj == nil) then
			if (targetObj:GetDistance() <= self.followTargetDistance) then
				targetObj:FaceTarget();
			end
		end

		-- paladin wants to move passed target and not stop. due to slow attack speed??  STOP MOVING!
		if (targetObj:GetDistance() <= self.meleeDistance - 1) and (IsMoving()) and (not targetObj:IsFleeing()) and (targetObj:IsInLineOfSight()) then
			if (IsMoving()) then
				StopMoving();
			end
		end

		-- wait before looting!
		if (targetObj:IsDead() or script_grind.lootObj ~= nil) then
			self.waitTimer = GetTimeEX() + 1532;
			ClearTarget();
		end

		-- Auto Attack
		if (targetObj:GetDistance() <= 40) and (targetObj:IsInLineOfSight()) then
			targetObj:AutoAttack();
		end
	
		targetHealth = targetObj:GetHealthPercentage();

		-- Check: if we target player pets/totems
		if (GetTarget() ~= nil) and (targetObj ~= nil) then
			if (UnitPlayerControlled("target")) and (GetTarget() ~= localObj) then 
				script_grind:addTargetToBlacklist(targetObj:GetGUID());
				return 5; 
			end
		end 
		
		-- Opener

		-- buffs and stuff before we are in combat NOT IN COMBAT YET
		if (not IsInCombat()) then

			self.targetObjGUID = targetObj:GetGUID();

			self.message = "Pulling " .. targetObj:GetUnitName() .. "...";

			-- Dismount
			if (IsMounted()) and (targetObj:GetDistance() < 25) then
				DisMount(); 
				return 0;
			 end

			-- follow target
			if (targetObj:IsInLineOfSight() and not IsMoving() and script_grind.lootObj == nil) then
				if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
					targetObj:FaceTarget();
				end
			end

			-- Check move into melee range
			-- keep doing this return 3 until target is in melee range
			if (targetObj:GetDistance() > self.meleeDistance) or (not targetObj:IsInLineOfSight()) then
				return 3;
			end

			-- Check: Exorcism
			if (targetObj:GetCreatureType() == "Demon") or (targetObj:GetCreatureType() == "Undead") then
				if (targetObj:GetDistance() < 30) and (HasSpell("Exorcism")) and (not IsSpellOnCD("Exorcism")) then
					if (Cast("Exorcism", targetObj)) then 
						self.message = "Pulling with Exocism...";
						return 0;
					end
				end
			end

			-- Check: Seal of the Crusader until we use judgement
			if (self.useSealOfCrusader) and (not targetObj:HasDebuff("Judgement of the Crusader")) and (targetObj:GetDistance() < 15) and (not localObj:HasBuff("Seal of the Crusader")) and localMana > 15 and (not IsSpellOnCD("Judgement")) and (targetObj:GetHealthPercentage() > 25) then
				if (Cast("Seal of the Crusader", targetObj)) then
						return 3;
				end
			end

			if (targetObj:IsInLineOfSight() and not IsMoving()) then
				if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
						targetObj:FaceTarget();
				end
			end


			-- Check move into melee range
			-- keep doing this if target is not in melee range
			if (targetObj:GetDistance() > self.meleeDistance) or (not targetObj:IsInLineOfSight()) then
				return 3;
			end

			-- check if we are in combat?
			if (IsInCombat()) and (targetObj:GetDistance() < self.meleeDistance) and (targetHealth > 99) and (not IsAutoCasting("Attack")) then
				targetObj:AutoAttack();
				self.waitTimer = GetTimeEX() + 200;	
			end
				
		-- Combat WE ARE NOW IN COMBAT
		else	

		-- paladin wants to move passed target and not stop. due to slow attack speed??  STOP MOVING!
		if (targetObj:GetDistance() <= self.meleeDistance - 1) and (IsMoving()) and (not targetObj:IsFleeing()) and (targetObj:IsInLineOfSight()) then
			if (IsMoving()) then
				StopMoving();
				targetObj:FaceTarget();
			end
		end

			self.message = "Killing " .. targetObj:GetUnitName() .. "...";

			-- Dismount
			if (IsMounted()) then 
				DisMount();
			end

			--targetObj = GetGUIDObject(targetGUID);

			
			-- Run backwards if we are too close to the target
			if (targetObj:GetDistance() < .2) then 
				if (script_paladin:runBackwards(targetObj,2)) then 
					return 4; 
				end 
			end

			-- Check if we are in melee range
				if (targetObj:GetDistance() > self.meleeDistance) or (not targetObj:IsInLineOfSight()) then
					return 3;
				end

			if (targetObj:IsInLineOfSight() and not IsMoving()) then
				if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
						targetObj:FaceTarget();
				end
			end
			
			-- recheck auto attack
			if (targetObj:GetDistance() <= self.meleeDistance) and (not IsAutoCasting("Attack")) then
				targetObj:AutoAttack();
			end

			-- dwarf stone form racial
			if (HasSpell("Stoneform")) and (not IsSpellOnCD("Stoneform")) and (IsInCombat()) then
				CastSpellByName("Stoneform");
				return 0;
			end

			-- check health and heal -- holy light
			if (localHealth <= self.holyLightHealth) and (localMana >= 25) then
				if (Buff("Holy Light", localObj)) and (IsStanding()) then 
					self.waitTimer = GetTimeEX() + 4000;
					self.message = "Healing: Holy Light...";
					return 0;
				end
			end

			-- Holy strike
			if (HasSpell("Holy Strike")) and (localMana > 15) and (not IsSpellOnCD("Holy Strike")) then
				if (targetObj:GetDistance() <= self.meleeDistance) then
					targetObj:FaceTarget();
					Cast("Holy Strike", targetObj);
					return 0;
				end
			end

			-- Check: Use Lay of Hands
			if (localHealth < self.lohHealth) and (HasSpell("Lay on Hands")) and (not IsSpellOnCD("Lay on Hands")) then 
				if (Cast("Lay on Hands", localObj)) then 
					self.message = "Cast Lay on Hands...";
					return 0;
				end
			end
			
			-- Check: Divine Protection if BoP on CD
			if(localHealth < self.bopHealth) and (not localObj:HasDebuff("Forbearance")) then
				if (HasSpell("Divine Shield")) and (not IsSpellOnCD("Divine Shield")) then
					CastSpellByName("Divine Shield");
					self.message = "Cast Divine Shield...";
					return 0;
				elseif (HasSpell("Divine Protection")) and (not IsSpellOnCD("Divine Protection")) then
					CastSpellByName("Divine Protection");
					self.message = "Cast Divine Protection...";
					return 0;
				elseif (HasSpell("Blessing of Protection")) and (not IsSpellOnCD("Blessing of Protection")) then
					CastSpellByName("Blessing of Protection");
					self.message = "Cast Blessing of Protection...";
					return 0;
				end
			end

			-- Flash of Light
			if (self.useFlashOfLightCombat) and (IsInCombat()) and (HasSpell("Flash of Light")) then
				if (localHealth <= self.flashOfLightHP) and (localMana > 10) then
					if (CastHeal("Flash of Light", localObj)) then
						self.waitTimer = GetTimeEX() + 1500;
						self.message = "Flash of Light enabled - Healing!";
						return 0;
					end				
				end
			end

			-- Check: Heal ourselves if below heal health or we are immune to physical damage
			if (localHealth <= self.holyLightHealth) or (localObj:HasBuff("Blessing of Protection")) or (localObj:HasBuff("Divine Protection")) then 

				-- Check: If we have multiple targets attacking us, use BoP before healing

				-- use BoP on 3 or more adds
				if (script_paladin:enemiesAttackingUs(5) > 2) and (HasSpell("Blessing of Protection")) and
					(not IsSpellOnCD("Blessing of Protection")) and (not localObj:HasDebuff("Forbearance")) then
					if (Buff("Blessing of Protection", localObj)) then 
						self.message = "Cast Blessing of Protection...";
						return 0;
					end
				end

				-- use divine shield on 3 or more adds
				-- Check: If we have multiple targets attacking us, use Divine Shield before healing
				if (script_paladin:enemiesAttackingUs(5) > 2) and (localHealth < 25) and (HasSpell("Divine Shield")) and 
					(not localObj:HasDebuff("Forbearance")) and (not IsSpellOnCD("Divine Shield")) then
					CastSpellByName("Divine Shield");
					self.message = "Cast Divine Shield...";
					return 0;
				end

				-- use divine protection on 3 or more adds
				-- Check: If we have multiple targets attacking us, use Divine Protection before healing
				if (script_paladin:enemiesAttackingUs(5) > 2) and (localHealth < 40) and (HasSpell("Divine Protection")) and
					(not localObj:HasDebuff("Forbearance")) and (not IsSpellOnCD("Divine Protection")) then
					CastSpellByName("Divine Protection");
					self.message = "Cast Divine Protection...";
					return 0;
				end

				-- Check: Stun with HoJ before healing if available
				if (targetObj:GetDistance() <= self.meleeDistance) and (HasSpell("Hammer of Justice")) and (not IsSpellOnCD("Hammer of Justice")) then
					if (Cast("Hammer of Justice", targetObj)) then
						self.waitTimer = GetTimeEX() + 1750;
						return 0;
					end
				end
				
				--use holy light at the end of all the checks above
				if  (localMana > 25) and (localHealth <= self.holyLightHealth) and (Buff("Holy Light", localObj)) and (IsStanding()) then 
					self.waitTimer = GetTimeEX() + 4000;
					self.message = "Healing: Holy Light...";
					return 0;
				end
			end

			-- Check: Use Healing Potion 
			if (localHealth < self.potionHealth) then 
				if (script_helper:useHealthPotion()) then 
					return 0; 
				end 
			end

			-- Check: Use Mana Potion 
			if (localMana < self.potionMana) then 
				if (script_helper:useManaPotion()) then 
					return 0; 
				end 
			end

			-- Check: Remove desease or poison
			if (HasSpell("Cleanse")) then
				if (localObj:HasDebuff("Rabies")) or (localObj:HasDebuff("Corrosive Poison")) or (localObj:HasDebuff("Poison")) or (localObj:HasDebuff("Fevered Fatigue"))
					or (localObj:HasDebuff("Dark Sludge")) or (localObj:HasDebuff("Corrosive Poison")) or (localObj:HasDebuff("Slowing Poison"))
						or (localObj:HasDebuff("Infected Bite")) or (localObj:HasDebuff("Wandering Plague"))
							or (localObj:HasDebuff("Plague Mind")) or (localObj:HasDebuff("Fevered Fatigue")) then

				-- add some randomness to how quick the bot casts cleanse

						local cleanseRandom = random(1, 100);
					if (cleanseRandom > 90) then
						if (Buff("Cleanse", localObj)) then 
							self.message = "Cleansing..."; 
							self.waitTimer = GetTimeEX() + 1750; 
							return 0; 
						end
					end
				end
			end

			-- remove disease with purify
			if (HasSpell("Purify")) then
				if (localObj:HasDebuff("Rabies")) or (localObj:HasDebuff("Corrosive Poison")) or (localObj:HasDebuff("Poison")) or (localObj:HasDebuff("Fevered Fatigue"))
					or (localObj:HasDebuff("Dark Sludge")) or (localObj:HasDebuff("Corrosive Poison")) or (localObj:HasDebuff("Slowing Poison"))
						or (localObj:HasDebuff("Infected Bite")) or (localObj:HasDebuff("Wandering Plague"))
							or (localObj:HasDebuff("Plague Mind")) or (localObj:HasDebuff("Fevered Fatigue")) then

				-- add some randomness to how quick the bot casts cleanse

						local cleanseRandom = random(1, 100);
					if (cleanseRandom > 90) then
						if (Buff("Purify", localObj)) then 
							self.message = "Cleansing..."; 
							self.waitTimer = GetTimeEX() + 1750; 
							return 0; 
						end
					end
				end
			end


			-- Check: Remove movement disables with Freedom
			if (localObj:IsMovementDisabed() and HasSpell("Blessing of Freedom")) then
				Buff("Blessing of Freedom", localObj);
				return 0;
			end

			-- Check: Exorcism
			if (targetObj:GetCreatureType() == "Demon") or (targetObj:GetCreatureType() == "Undead") then
				if (targetObj:GetDistance() < 30) and (HasSpell("Exorcism")) and (not IsSpellOnCD("Exorcism")) and (localMana > 30) then
					if (Cast("Exorcism", targetObj)) then 
						return 0;
					end
				end
			end

			-- Check: If we are in melee range, do melee attacks ----- RETURN 0   ONLY USE IN MELEE RANGE
			if (targetObj:GetDistance() <= self.meleeDistance) then


				if (targetObj:IsInLineOfSight() and not IsMoving()) then
					if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
						targetObj:FaceTarget();	
					end
				end

				-- hammer of justice when fleeing
				if (targetObj:IsCasting()) or (targetObj:IsFleeing()) then
					if (HasSpell("Hammer of Justice")) and (not IsSpellOnCD("Hammer of Justice")) and (localMana > 8) then
						if (Cast("Hammer of Justice", targetObj)) then
							self.waitTimer = GetTimeEX() + 2000;
							return 0;
						end
					end
				end

				-- Stack Crusader Strike
				if (HasSpell("Crusader Strike")) and ((localObj:HasBuff("Seal of Righteousness")) or (localObj:HasBuff("Seal of Command"))) and (targetObj:HasDebuff("Judgement of the Crusader")) then
					if (targetObj:GetDebuffStacks("Crusader Strike") < self.crusaderStacks) and (targetHealth > self.crusaderStacksHealth) and (localMana > self.crusaderStacksMana) then
						if (Cast("Crusader Strike", targetObj)) then
							self.waitTimer = GetTimeEX() + 1750;
								return 0;
						end
					end
				end
						
				-- On low health do seal of light if targetHP > 50 and localMana < 15
				if (HasSpell("Seal of Light")) and (not localObj:HasBuff("Seal of Light")) and (localMana < 15) then
					if (targetHealth > 50) or (script_grind:enemiesAttackingUs(5) > 1) then
						if (Cast("Seal of Light", targetObj)) then
							self.waitTimer = GetTimeEX() + 1000;
						end
					end
				end

				-- on low mana do seal of wisdom if selfMana < 25 and targetHP > 50
				if (HasSpell("Seal of Wisdom")) and (not localObj:HasBuff("Seal of Light")) or (not localObj:HasBuff("Seal of Wisdom")) then
					if (localMana < 25) and (targetHealth > 50) then
						if (Cast("Seal of Wisdom", targetObj)) then
							self.waitTimer = GetTimeEX() + 1000;
						end
					end
				end

				-- Stun the target if target has seal of crusader debuff
				if (not IsSpellOnCD("Judgement")) and (localMana > 50) and (HasSpell("Hammer of Justice")) and (not IsSpellOnCD("Hammer of Justice")) then
					if (targetHealth > 50) and (targetObj:HasDebuff("Judgement of the Crusader")) and (localObj:HasBuff("Seal of Command") or localObj:HasBuff("Seal of Righteousness")) then
						if (Cast("Hammer of Justice", targetObj)) then
							self.waitTimer = GetTimeEX() + 1750; 
							return 0;
						end
					end
				end
		
				-- Use Judgement on the stunned target
				if (targetObj:HasDebuff("Hammer of Justice")) and (localObj:HasBuff("Seal of Command") or localObj:HasBuff("Seal of Righteousness")) then
					if (targetObj:GetDistance() <= self.meleeDistance) and (localMana > 15) then
						if (Cast("Judgement", targetObj)) then
							self.waitTimer = GetTimeEX() + 750;
							return 0;
						end
					end
				end

				-- Seal of the Crusader until we used judgement
				if (self.useSealOfCrusader) and (HasSpell("Seal of the Crusader")) and (localMana > 15) and (targetHealth > 45) then
					if (not targetObj:HasDebuff("Judgement of the Crusader")) and (not localObj:HasBuff("Seal of the Crusader")) and (not localObj:HasBuff("Seal of Light")) then
						if (Buff("Seal of the Crusader", localObj)) then
							self.waitTimer = GetTimeEX() + 1500; 
							return 0;
						 end
					end 
				end

				-- use Judgement when we have crusader buffed
				if (HasSpell("Judgement")) and (not IsSpellOnCD("Judgement")) and (localObj:HasBuff("Seal of the Crusader")) and (localMana > 15) then
					if (targetObj:GetDistance() < 10) and (not targetObj:HasDebuff("Judgement of the Crusader")) and (localObj:HasBuff("Seal of the Crusader")) then
						if (Cast("Judgement", targetObj)) then
							self.waitTimer = GetTimeEX() + 1500; 
							return 0;
						end 
					end
				end

				-- Check: Seal of Righteousness (before we have SoC)
				if (not localObj:HasBuff("Seal of Righteousness")) and (not localObj:HasBuff("Seal of the Crusader")) and (not HasSpell("Seal of Command")) and
					(not localObj:HasBuff("Seal of Light")) and (localMana > 15) then 
					if (Buff("Seal of Righteousness", localObj)) then
						self.waitTimer = GetTimeEX() + 1500;
						return 0;
					end
				end

				-- Check: Judgement with Righteousness or Command if we have a lot of mana
				if (localMana > 50) and (not IsSpellOnCD("Judgement")) then
					if (localObj:HasBuff("Seal of Righteousness") or localObj:HasBuff("Seal of Command")) then 
						if (Cast("Judgement", targetObj)) then self.waitTimer = GetTimeEX() + 750;
 							return 0;
						end 
					end
				end

				-- Check: Use judgement if we are buffed with Righteousness or Command and the target is low
				if (targetHealth < 10) and (HasSpell("Seal of Command") or HasSpell("Seal of Righteousness")) and (localMana > 15) then
					if (localObj:HasBuff("Seal of Righteousness") or localObj:HasBuff("Seal of Command")) and (targetObj:GetDistance() < 10) then
						if (Cast("Judgement", targetObj)) then self.waitTimer = GetTimeEX() + 1500;
 							return 0;
						end
					end
				end

				-- Check: Seal of Command
				if (HasSpell("Seal of Command")) and (not localObj:HasBuff("Seal of Command")) and (localMana > 15) then
					if (not localObj:HasBuff("Seal of the Crusader")) and (not localObj:HasBuff("Seal of Light")) then 
						if (Buff("Seal of Command", localObj)) then
							self.waitTimer = GetTimeEX() + 1500;
 							return 0;
						end
					end
				end

				-- Consecration when we have adds
				if (HasSpell("Consecration")) and (not IsSpellOnCD("Consecration")) and (localMana > self.consecrationMana) then
					if (script_grind:enemiesAttackingUs(4) >= 1) then
						CastSpellByName("Consecration"); self.waitTimer = GetTimeEX() + 1500;
 						return 0;	
					end
				end
			end
			return 0;
		end
	end
end

function script_paladin:rest()
	if(not self.isSetup) then
		script_paladin:setup();
	end

	local localObj = GetLocalPlayer();
	local localLevel = localObj:GetLevel();
	local localHealth = localObj:GetHealthPercentage();
	local localMana = localObj:GetManaPercentage();

	if (not script_grind.adjustTickRate) then
		if (not IsInCombat()) or (targetObj:GetDistance() > self.meleeDistance) then
			script_grind.tickRate = 100;
		elseif (IsInCombat()) then
			script_grind.tickRate = 750;
		end
	end

	-- heal before eating
	if (localHealth < self.holyLightHealth) or (localHealth < self.eatHealth) and (IsStanding()) then
		if (HasSpell("Holy Light")) and (not IsSpellOnCD("Holy Light")) and (localMana > 25) then
			if (CastSpellByName("Holy Light")) and (localHealth < self.holyLightHealth or localHealth < self.eatHealth) then
				return true;
			end
		end
	end

	-- Buff with Blessing
	if (self.blessing ~= 0 and HasSpell(self.blessing) and not IsMounted()) then
		if (localMana > 10 and not localObj:HasBuff(self.blessing)) then
			Buff(self.blessing, localObj);
			return false;
		end
	end

	-- Stop moving before we can rest
	if(localHealth < self.eatHealth or localMana < self.drinkMana) then
		if (IsMoving()) then
			StopMoving();
			return true;
		end
	end

	-- Heal up: Holy Light
	if (localMana >= 25 and localHealth <= self.eatHealth) and (IsStanding()) then
		if (Buff("Holy Light", localObj)) then
			script_grind:setWaitTimer(3500);
			self.message = "Healing: Holy Light...";
		end
		return true;
	end

	-- Heal up: Flash of Light
	if (localMana >= 10 and localHealth <= self.flashOfLightHP and HasSpell("Flash of Light") and IsStanding()) then
		if (Buff("Flash of Light", localObj)) then
			script_grind:setWaitTimer(1850);
			self.message = "Healing: Flash of Light...";
		end
		return true;
	end

	-- Drink something
	if (not IsDrinking() and localMana < self.drinkMana) then
		self.waitTimer = GetTimeEX() + 2000;
		self.message = "Need to drink...";
		if (IsMoving()) then
			StopMoving();
			return true;
		end

		if (script_helper:drinkWater()) then 
			self.message = "Drinking..."; 
			return true; 
		else 
			self.message = "No drinks! (or drink not included in script_helper)";
			return true; 
		end
	end

	-- Eat something
	if (not IsEating() and localHealth < self.eatHealth) then
		self.message = "Need to eat...";
		if (IsInCombat()) then
			return true;
		end
			
		if (IsMoving()) then
			StopMoving();
			return true;
		end

		if (script_helper:eat()) then 
			self.message = "Eating..."; 
			return true; 
		else 
			self.message = "No food! (or food not included in script_helper)";
			return true; 
		end		
	end

	-- Continue resting
	if(localHealth < 98 and IsEating() or localMana < 98 and IsDrinking()) then
		self.message = "Resting up to full HP/Mana...";
		self.waitTimer = GetTimeEX() + 10000;
		return true;
	end
		
	-- Stand up if we are rested
	if (localHealth > 98 and (IsEating() or not IsStanding()) 
	    and localMana > 98 and (IsDrinking() or not IsStanding())) then
		StopMoving();
		return false;
	end
	
	-- Set aura
	if (self.aura ~= 0 and not IsMounted()) then
		if (not localObj:HasBuff(self.aura) and HasSpell(self.aura)) then
			CastSpellByName(self.aura); 
		end
	end
		-- Don't need to rest
	return false;
end

function script_paladin:window()

	if (self.isChecked) then
	
		--Close existing Window
		EndWindow();

		if(NewWindow("Class Combat Options", 200, 200)) then
			script_paladin:menuEX();
		end
	end
end