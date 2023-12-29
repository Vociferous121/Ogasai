script_rogue = {
	message = 'Rogue Combat Script',
	rogueMenu = include("scripts\\combat\\script_rogueEX.lua"),
	mainhandPoison = "Instant Poison",
	offhandPoison = "Instant Poison",
	cpGenerator = 'Sinister Strike',
	throwName = "Heavy Throwing Dagger",
	stealthOpener = "Sinister Strike",
	eatHealth = 60,
	potionHealth = 7,
	cpGeneratorCost = 45,
	meleeDistance = 3.2,
	stealthRange = 100,
	waitTimer = 0,
	vanishHealth = 8,
	evasionHealth = 50,
	adrenRushComboHP = 40,
	throwOpener = false,
	isSetup = false,
	useStealth = true,
	usePoison = true,
	useSliceAndDice = true,
	stopIfMHBroken = true,
	adrenRushCombo = true,
	enableRotation = false,
	enableGrind = true,
	useKidneyShot = true,
	enableFaceTarget = true,
	enableBladeFlurry = true,
	enableAdrenRush = true,
	rotationTwo = false,
	followTargetDistance = 35,
	useBandage = true,
	hasBandages = false,
	riposteActionBarSlot = 8,
}

function script_rogue:setup()

	-- no more bugs first time we run the bot
	self.waitTimer = GetTimeEX(); 

	--set backstab as opener
	if (GetLocalPlayer():GetLevel() < 10) then
		self.stealthOpener = "Backstab";
	end
	if (not HasSpell("Ambush")) and (HasSpell("Garrote")) and (GetLocalPlayer():GetLevel() >= 10) then
		self.stealthOpener = "Garrote";
	end
	if (HasSpell("Ambush")) and (not HasSpell("Riposte") or HasSpell("Ghostly Strike")) then
		self.stealthOpener = "Ambush";
	end
	if (HasSpell("Riposte")) and (not HasSpell("Cheap Shot")) then
		self.stealthOpener = "Garrote";
	end
	if (HasSpell("Cheap Shot")) and (not HasSpell("Ghostly Strike")) then
		self.stealthOpener = "Cheap Shot";
	end

	if (not HasSpell("Adrenaline Rush")) then
		self.adrenRushCombo = false;
		self.enableAdrenRush = false;
	end

	if (not HasSpell("Blade Flurry")) then
		self.enableBladeFlurry = false;
	end

	-- Set Hemorrhage as default CP builder if we have it
	if (HasSpell("Hemorrhage")) then
		self.cpGenerator = "Hemorrhage";
	end
	if (HasSpell("Riposte")) then
		self.cpGeneratorCost = 40;
	end

	-- Set the energy cost for the CP builder ability (does not recognize talent e.g. imp. sinister strike)
	_, _, _, _, self.cpGeneratorCost = GetSpellInfo(self.cpGenerator);

	self.isSetup = true;
end

function script_rogue:spellAttack(spellName, target)
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

function script_rogue:equipThrow()
	if (not GetLocalPlayer():HasRangedWeapon() and HasItem(self.throwName)) then
		UseItem(self.throwName);
		return true;
	elseif (GetLocalPlayer():HasRangedWeapon()) then
		return true;
	end
	return false;
end

function script_rogue:checkPoisons()
	if (not IsInCombat() and not IsEating()) then
		hasMainHandEnchant, _, _, hasOffHandEnchant, _, _ = GetWeaponEnchantInfo();
		if (hasMainHandEnchant == nil and HasItem(self.mainhandPoison)) then 
			-- Check: Stop moving, sitting
			if (not IsStanding() or IsMoving()) then 
				StopMoving(); 
				return; 
			end
			-- Check: Dismount
			if (IsMounted()) then DisMount(); return true; end
			-- Apply poison to the main-hand
			self.message = "Applying poison to main hand..."
			UseItem(self.mainhandPoison); 
			PickupInventoryItem(16);  
			self.waitTimer = GetTimeEX() + 6000; 
			return true;
		end
		if (hasOffHandEnchant == nil and HasItem(self.offhandPoison)) then
			-- Check: Stop moving, sitting
			if (not IsStanding() or IsMoving()) then 
				StopMoving(); 
				return; 
			end 
			-- Check: Dismount
			if (IsMounted()) then DisMount(); return true; end
			-- Apply poison to the off-hand
			self.message = "Applying poison to off hand..."
			UseItem(self.offhandPoison); 
			PickupInventoryItem(17); 
			self.waitTimer = GetTimeEX() + 6000; 
			return true; 
		end
	end 
	return false;
end

function script_rogue:canRiposte()	-- use Riposte function
	local isUsable, _ = IsUsableAction(self.riposteActionBarSlot); 
	if (isUsable == 1 and not IsSpellOnCD("Riposte")) then 
		return true; 
	end 
	return false;
end

-- Run backwards if the target is within range
function script_rogue:runBackwards(targetObj, range) 
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
 			script_navEX:moveToTarget(localObj, moveX, moveY, moveZ);
			self.waitTimer = GetTimeEX() + 900;
 			return true;
 		end
	end
	return false;
end

function script_rogue:draw()
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

function script_rogue:run(targetGUID)

	if (not self.isSetup) then 
		script_rogue:setup(); 
	end

	local localObj = GetLocalPlayer();
	local localEnergy = localObj:GetEnergy();
	local localHealth = localObj:GetHealthPercentage();
	local localLevel = localObj:GetLevel();

	if (localObj:IsDead()) then 
		return 0; 
	end

	-- Check: If Mainhand is broken stop bot
	isMainHandBroken = GetInventoryItemBroken("player", 16);
	
	if (self.stopIfMHBroken and isMainHandBroken) then
		self.message = "The main hand weapon is broken...";
		return 6;
	end

	-- Assign the target 
	targetObj = GetGUIDObject(targetGUID);

	if(targetObj == 0 or targetObj == nil) then
		return 2;
	end

	-- Check: Do nothing if we are channeling or casting or wait timer
	if (IsChanneling() or IsCasting() or (self.waitTimer > GetTimeEX())) then
		return 4;
	end

	-- Apply poisons if we are not in combat
	if (not IsInCombat() and self.usePoison) then
		if (script_rogue:checkPoisons()) then
			return 4;
		end
	end

	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(256, 311);

		if (IsMoving()) or (not IsInCombat()) or (targetObj:IsFleeing()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) and (not targetObj:IsFleeing()) then
			script_grind.tickRate = tickRandom
		elseif (IsInCombat()) and (not IsMoving())and (not targetObj:IsFleeing()) then
			script_grind.tickRate = tickRandom;
		end
	end


	-- dismount before combat
	if (IsMounted()) then
		DisMount();
	end

	
	-- force auto attack in combat
	--if (IsInCombat()) and (PlayerHasTarget()) and (not IsAutoCasting("Attack")) then
	--	targetObj:AutoAttack();
	--end

	if (self.enableGrind) then

		--Valid Enemy
		if (targetObj ~= 0) and (not localObj:IsStunned()) then

		if (IsInCombat()) and (script_grind.skipHardPull) and (GetNumPartyMembers() == 0) then
			if (script_checkAdds:checkAdds()) then
				script_om:FORCEOM();
				return;
			end
		end

		-- Set Slice and Dice level 10 or greater
			if not (HasSpell("Slice and Dice")) then
				self.useSliceAndDice = false;
			end
			if (not HasSpell("Stealth")) then
				self.useStealth = false;
			end
		
			-- Cant Attack dead targets
			if (targetObj:IsDead() or not targetObj:CanAttack()) then
				return 0;
			end
		
			if (not IsStanding()) then
				JumpOrAscendStart();
			end

			-- pick pocket
			--if (HasSpell("Pick Pocket")) and (IsStealth()) and (not IsInCombat()) and (not IsAutoCasting("Attack")) then
			--	if (targetObj:GetCreatureType() == 'Humanoid') or (targetObj:GetCreatureType() == 'Undead') then
			--		if (targetObj:GetDistance() <= 5) and (IsStealth()) then
			--			CastSpellByName("Pick Pocket");
			--			if (IsLooting()) then
			--				LootTarget();
			--				script_grind.doLoot();
			--				return;
			--			end
			--			return;
			--		else
			--			return 3;
			--		end
			--	end
			--end

			targetHealth = targetObj:GetHealthPercentage();

			-- Don't attack if we should rest first
			if (localHealth < self.eatHealth and not script_grind:isTargetingMe(targetObj)
				and targetHealth > 99 and not targetObj:IsStunned()) then
				self.message = "Need rest...";
				return 4;
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

			--stuck in combat
			if (not PlayerHasTarget()) and (IsInCombat()) and (script_grind.enemiesAttackingUs() == 0) and (GetNumPartyMembers() < 1) then
				self.message = "Stuck in combat... Waiting...";
				return;
			end
		
			-- Opener
			if (not IsInCombat()) then
				self.targetObjGUID = targetObj:GetGUID();
				self.message = "Pulling " .. targetObj:GetUnitName() .. "...";

				-- Auto Attack
				if (targetObj:GetDistance() < 40) and (not IsMoving()) then
					targetObj:AutoAttack();
				-- stops spamming auto attacking while moving to target
				elseif (targetObj:GetDistance() <= 8) then
					targetObj:AutoAttack();
				end

				if (targetObj:IsInLineOfSight() and not IsMoving()) then
					if (targetObj:GetDistance() <= 10) and (targetObj:IsInLineOfSight()) then
						if (not targetObj:FaceTarget()) then
							targetObj:FaceTarget();
						end
					end
				end

				-- Stealth in range if enabled
				if (self.useStealth and targetObj:GetDistance() <= self.stealthRange) and (not script_checkDebuffs:hasPoison()) and (script_grind.lootObj == nil) then
					if (not IsStealth()) then
						CastStealth();
					end
					-- Use sprint (when stealthed for pull)
					if (HasSpell("Sprint")) and (not IsSpellOnCD("Sprint")) and (IsStealth()) then
						CastSpellByName("Sprint");
					end
				end

				-- Open with stealth opener
				if (targetObj:GetDistance() <= 5 and self.useStealth and HasSpell(self.stealthOpener) and IsStealth()) then
					if (script_rogue:spellAttack(self.stealthOpener, targetObj)) then
						return 0;
					end
				end

				if (targetObj:IsInLineOfSight() and not IsMoving()) then
					if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
						if (not targetObj:FaceTarget()) then
							targetObj:FaceTarget();
						end
					end
				end

				-- Check if we are in melee range
				if (targetObj:GetDistance() > self.meleeDistance) or (not targetObj:IsInLineOfSight()) and (PlayerHasTarget()) then
					return 3;
				end

				-- Use CP generator attack 
				if (localEnergy >= self.cpGeneratorCost) and (HasSpell(self.cpGenerator)) then
					script_rogue:spellAttack(self.cpGenerator, targetObj);
					return 0;
				end
 

				-- now in Combat
			else	

				self.message = "Killing " .. targetObj:GetUnitName() .. "...";

				local localCP = GetComboPoints("player", "target");


				-- Dismount
				if (IsMounted()) then
					DisMount();
				end

				-- Check if we are in melee range
				if (targetObj:GetDistance() > self.meleeDistance) or (not targetObj:IsInLineOfSight()) and (PlayerHasTarget()) then
					return 3;
				end

				if (targetObj:IsInLineOfSight() and not IsMoving()) then
					if (targetObj:GetDistance() <= 10) and (targetObj:IsInLineOfSight()) then
						if (not targetObj:FaceTarget()) then
							targetObj:FaceTarget();
						end
					end
				end

				if (HasSpell('Kidney Shot')) and (localCP >= 1) and (targetObj:IsCasting()) and (not IsSpellOnCD('Kidney Shot')) and (localEnergy >= 25) then
					if (Cast('Kidney Shot', targetObj)) then
						return 0;
					end
				end

				-- Check: Use Riposte whenever we can
				if (HasSpell("Riposte")) and (script_rogue:canRiposte() and not IsSpellOnCD("Riposte")) and (localEnergy >= 10) then 
					if (CastSpellByName("Riposte", targetObj)) then
						self.waitTimer = GetTimeEX() + 1500;
						return 0;					
					end
				end

				-- Check: Do we have the right target (in UI) ??
				if (GetTarget() ~= 0 and GetTarget() ~= nil) then
					if (GetTarget():GetGUID() ~= targetObj:GetGUID()) then
						ClearTarget();
						targetObj = 0;
						return 0;
					end
				end

				-- Run backwards if we are too close to the target
				if (targetObj:GetDistance() < .2) then 
					if (script_rogue:runBackwards(targetObj, 1)) then 
						script_grind.tickRate = 80;
						return 4; 
					end 
				end

				if (targetObj:IsInLineOfSight() and not IsMoving() and targetHealth <= 99) then
					if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
						if (not targetObj:FaceTarget()) then
							targetObj:FaceTarget();
						end
					end
				end		
				
				if (GetNumPartyMembers() >= 1) and (HasSpell("Feint")) and (script_grind:isTargetingMe(targetObj)) and (not IsSpellOnCD("Feint")) and (localEnergy >= 20) then
					CastSpellByName("Feint", targetObj);
					return 0;
				end

				-- run back if has vanish
				if (localObj:HasBuff("Vanish")) then
					script_navEX:moveToTarget(localObj, script_nav.savedLocations[script_nav.currentGoToLocation]['x'], script_nav.savedLocations[script_nav.currentGoToLocation]['y'], script_nav.savedLocations[script_nav.currentGoToLocation]['z']); 
					return;
				end

				-- Check: Use Vanish 
				if (HasSpell('Vanish')) and (HasItem('Flash Powder')) and (localHealth < self.vanishHealth) and (not IsSpellOnCD('Vanish')) then 
					if (CastSpellByName('Vanish')) then
						self.waitTimer = GetTimeEX() + 10000;
						ClearTarget();
						self.enemyObj = 0;
					end
				end

				if (HasSpell("Ghostly Strike")) and (not IsSpellOnCD("Ghostly Strike")) and (localEnergy >= 40) then
					CastSpellByName("Ghostly Strike", targetObj);
					return 0;
				end

				-- Check: Use Healing Potion 
				if (localHealth <= self.potionHealth) then 
					if (script_helper:useHealthPotion()) then 
						return 0; 
					end 
				end

				-- Check: Kick if the target is casting
				if (HasSpell("Kick")) and (targetObj:IsCasting()) and (not IsSpellOnCD("Kick")) and (localEnergy >= 25) then
					if (CastSpellByName("Kick", targetObj)) then
						self.waitTimer = GetTimeEX() + 900;
						return 0;
					end
				end

				-- Gouge if target casting
				if (HasSpell("Gouge")) and (not IsSpellOnCD("Gouge")) and (localEnergy >= 45) and (targetObj:IsCasting()) then
					if (CastSpellByName("Gouge", targetObj)) then
						self.waitTimer = GetTimeEX() + 250;
						return 0;
					end
				end

				if (not IsAutoCasting("Attack")) and (targetObj:HasDebuff("Gouge")) then
					targetObj:AutoAttack();
				end

				-- Gouge then bandage
				if (self.useBandages) and (not localObj:HasDebuff("Recently Bandaged")) then
					if (HasSpell("Gouge")) and (not IsSpellOnCD("Gouge")) and (localEnergy >= 45) and (localHealth < 35) and (script_grind:enemiesAttackingUs() < 2) then
						CastSpellByName("Gouge", targetObj);
						return 0;
					end

					if (targetObj:HasDebuff("Gouge")) and (not localObj:HasDebuff("Recently Bandaged")) then
					script_helper:useBandage();
						return;
					end
				end

				-- Set available skills variables
				hasEvasion = HasSpell('Evasion');
			
				-- Talent specific skills variables
				hasFlurry = HasSpell('Blade Flurry');  
				hasAdrenalineRush = HasSpell('Adrenaline Rush'); 

				-- Check: Use Riposte whenever we can
				if (HasSpell("Riposte")) and (script_rogue:canRiposte() and not IsSpellOnCD("Riposte")) and (localEnergy >= 10) then 
					if (CastSpellByName("Riposte", targetObj)) then
						self.waitTimer = GetTimeEX() + 1500;
						return 0; -- return until we cast Riposte
					end
				end
			
				-- Check: Use Evasion if low HP or more than one enemy attack us
				if ((localHealth < self.evasionHealth and localHealth < targetHealth) or (script_helper:enemiesAttackingUs(5) >= 2 and localHealth < self.evasionHealth)) and (not IsSpellOnCD("Evasion")) then 
					if (HasSpell('Evasion') and not IsSpellOnCD('Evasion')) then
						CastSpellByName('Evasion');
						return 0;
					end
				end 
			
				-- Check: Blade Flurry when 2 or more targets within 10 yards
				if (hasFlurry and script_helper:enemiesAttackingUs(10) >= 2 and not IsSpellOnCD('Blade Flurry')) then 
					if (targetObj:GetDistance() < 5 and targetHealth > 15 and localHealth > 20) then
						CastSpellByName('Blade Flurry');
						return 0;
					end
				end 

				 --Blade Flurry then use Adrenaline Rush on Low HP
				if (HasSpell('Adrenaline Rush') and not IsSpellOnCD('Adrenaline Rush') and localHealth < self.adrenRushComboHP and (self.adrenRushCombo)) then 
					if (targetObj:GetDistance() < 6) then 
						CastSpellByName('Adrenaline Rush');
						return 0;
					end 
				end
 
				-- Check: Adrenaline Rush if more than 2 enemies attacks us or we fight an elite enemy
				if (hasAdrenalineRush and (script_helper:enemiesAttackingUs(10) >= 3 or UnitIsPlusMob("target"))) then 
					if (targetObj:GetDistance() < 6) and (not IsSpellOnCD("Adrenaline Rush")) then 
						CastSpellByName('Adrenaline Rush');
						return 0;
					end 
				end 
			
				-- Check: Blade Flury if more than 2 enemies attacks us or we fight an elite enemy
				if (hasBladeFlurry and (script_helper:enemiesAttackingUs(10) >= 2 or UnitIsPlusMob("target"))) then 
					if (targetObj:GetDistance() < 6) and (not IsSpellOnCD("Blade Flurry")) then 
						CastSpellByName('Blade Flurry');
						return 0;
					end 
				end 

				-- Eviscerate with 5 CPs
				if (localCP > 4) and (localEnergy >= 35) then
					CastSpellByName("Eviscerate", targetObj);
					return 0; -- return until we use Eviscerate
				end

				-- Keep Slice and Dice up
				if (self.useSliceAndDice) and (not localObj:HasBuff('Slice and Dice')) and (targetHealth > 50) and (localCP > 0) and (localEnergy >= 25) then
					if (CastSpellByName("Slice and Dice", targetObj)) then
						self.waitTimer = GetTimeEX() + 1100;
						return 0;
					end	
				end

				-- Use CP generator attack 
				if (targetHealth > (10*localCP)) and (localCP < 5) then
					if (localEnergy >= self.cpGeneratorCost) and (HasSpell(self.cpGenerator)) then
						if (script_rogue:spellAttack(self.cpGenerator, targetObj)) then
							return 0;
						end
					end
				end
			
				-- Dynamic health check when using Eviscerate between 1 and 4 CP
				if (targetHealth <= (10*localCP)) and (localEnergy >= 35) then
					CastSpellByName("Eviscerate", targetObj);
					return 0; -- return until we use Eviscerate
				end

				-- Use CP generator attack 
				if (localEnergy >= self.cpGeneratorCost) and (HasSpell(self.cpGenerator)) then
					if (script_rogue:spellAttack(self.cpGenerator, targetObj)) then
						return 0;
					end
				end			
			end
		end
	end -- end of if self.enablegrind

	-- Rotation enabled

	--Valid Enemy

	if (self.enableRotation) then

		if (targetObj ~= 0) then

			-- Cant Attack dead targets
			if (targetObj:IsDead() or not targetObj:CanAttack()) then
				return 0;
			end
			
			-- if sitting then stand
			if (not IsStanding()) then
				StopMoving();
			end
		
			-- Auto Attack
			if (targetObj:GetDistance() < 40) and (not IsMoving()) then
				targetObj:AutoAttack();
			-- stops spamming auto attacking while moving to target
			elseif (targetObj:GetDistance() < self.meleeDistance) then
				targetObj:AutoAttack();
			end
			
			-- auto face target
			if (self.enableFaceTarget and not targetObj:FaceTarget() and targetObj:IsInLineOfSight()) then
				targetObj:FaceTarget();
			end

			-- set target health variable
			targetHealth = targetObj:GetHealthPercentage();

			-- Don't attack if we should rest first
			if (localHealth < self.eatHealth and not script_grind:isTargetingMe(targetObj)
				and targetHealth > 99 and not targetObj:IsStunned() and script_grind.lootobj == nil) then
				self.message = "Need rest...";
				return 4;
			end

			-- Check: if we target player pets/totems
			if (GetTarget() ~= nil and targetObj ~= nil) then
				if (UnitPlayerControlled("target") and GetTarget() ~= localObj) then 
					script_grind:addTargetToBlacklist(targetObj:GetGUID());
					return 5; 
				end
			end 

			-- Opener ROTATION
			
			if (not IsInCombat()) then
				self.targetObjGUID = targetObj:GetGUID();
				self.message = "Pulling " .. targetObj:GetUnitName() .. "...";
			
				-- Stealth in range if enabled
				if (self.useStealth and targetObj:GetDistance() <= self.stealthRange) and (not script_checkDebuffs:hasPoison()) and (script_grind.lootObj == nil) then
					if (not IsStealth() and not IsSpellOnCD("Stealth")) then
						CastStealth();
					end
					-- why break stealth??
					--elseif (not self.useStealth and IsStealth()) then
					--CastSpellByName("Stealth");
				end

				-- Open with stealth opener
				if (targetObj:GetDistance() < 6 and self.useStealth and HasSpell(self.stealthOpener) and IsStealth()) then
					if (script_rogue:spellAttack(self.stealthOpener, targetObj)) then
						return 0;
					end
						-- if we are stealthed for some reason
				elseif (targetObj:GetDistance() < 6) and (not self.useStealth) and (HasSpell(self.stealthOpener)) and (IsStealth()) then
					if (script_rogue:spellAttack(self.stealthOpener, targetObj)) then
						return 0;
					end
				end
			
				-- Check if we are in melee range
				if (targetObj:GetDistance() > self.meleeDistance or not targetObj:IsInLineOfSight()) and (PlayerHasTarget()) then
					return 3;
				end

				-- Use CP generator attack 
				if ((localEnergy >= self.cpGeneratorCost) and HasSpell(self.cpGenerator)) then
					if(CastSpellByName(self.cpGenerator, targetObj)) then
						return 0;
					end
				end
 
				-- Use CP generator attack  (in combat)
				if (IsInCombat()) then
					if (localEnergy >= self.cpGeneratorCost) and (HasSpell(self.cpGenerator)) then
						if(CastSpellByName(self.cpGenerator, targetObj)) then
							return 0;
						end
					end
				end

				-- Combat  ROTATION NOW IN COMBAT 

			else	

				local localCP = GetComboPoints("player", "target");

				script_checkRacials();
	
				-- Combat Rotation 2 COMBAT ROTATION 2
				if (self.rotationTwo) then
					self.message = "Using Combat Rotation 2!";

						-- Check: Kick if the target is casting
					if (HasSpell("Kick") and targetObj:IsCasting() and not IsSpellOnCD("Kick")) then
						self.message = "Waiting for Kick Energy Combat Rotation 2";
						if (localEnergy >= 25) then 
							return 0; 
						end
						if (Cast("Kick", targetObj)) then
						self.message = "Using Riposte Combat Rotation 2";

							return 0;
						end
					end

						-- check: Kidney shot if target is casting and kick is on cooldown
					if (self.useKidneyShot) then
						if (HasSpell('Kidney Shot')) and (localCP >= 1 ) and (targetObj:IsCasting()) and (not IsSpellOnCD('Kidney Shot')) then
							if (localEnergy >= 25) then
								self.message = "Waiting for Kidney Shot Energy Combat Rotation 2";
								return 0;
							end
							if (Cast('Kidney Shot', targetObj)) then
							self.message = "Using Kidney Shot Combat Rotation 2";
								return 0;
							end
						end
					end

				-- Gouge if target casting
					if (HasSpell("Gouge")) and (not IsSpellOnCD("Gouge")) and (localEnergy >= 45) and (targetObj:IsCasting()) then
						if (CastSpellByName("Gouge", targetObj)) then
							self.waitTimer = GetTimeEX() + 250;
							return 0;
						end
					end

					if (HasSpell("Ghostly Strike")) and (not IsSpellOnCD("Ghostly Strike")) and (localEnergy >= 40) and ( (targetHealth >= 25 and localHealth >= 25) or (localHealth <= 25) ) then
						if (CastSpellByName("Ghostly Strike", targetObj)) then
							self.waitTimer = GetTimeEX() + 1200;
							return 0;
						end
					end

					-- check riposte
					if (HasSpell("Riposte")) and (script_rogue:canRiposte() and not IsSpellOnCD("Riposte")) and (localEnergy >= 10) then
						if (CastSpellByName("Riposte", targetObj)) then
							self.message = "Using Riposte Combat Rotation 2";
							return 0;
						end
					end

					-- Use Blade Flurry on CD targets > 1
					if (self.enableBladeFlurry) then
						if (HasSpell("Blade Flurry")) and (not IsSpellOnCD("Blade Flurry")) and (targetHealth > 50) then
							if (script_helper:enemiesAttackingUs(5) >= 1) then
								CastSpellByName("Blade Flurry");
								self.message = "Using Blade Flurry Combat Rotation 2";
								return 0;
							end
						end
					end

					-- Use adrenaline Rush on CD targets > 1
					if (self.enableAdrenRush)then
						if (HasSpell("Adrenaline Rush")) and (not IsSpellOnCD("Adrenaline Rush")) and (targetHealth > 60) then
							if (script_helper:enemiesAttackingUs(5) >= 1) then
								CastSpellByName("Adrenaline Rush");
								self.message = "Using Adrenaline Rush Combat Rotation 2";
								return 0;
							end
						end
					end

					-- Slice and Dice at 2 combo points
					if (localCP > 2) and (HasSpell("Slice and Dice")) then
						if (not localObj:HasBuff('Slice and Dice')) and (targetHealth > 25) and (localEnergy >= 25) then
							CastSpellByName('Slice and Dice', targetObj);
							self.message = "Using Slice and Dice Combat Rotation 2";
							return 0;
						end
					end

					-- Eviscerate
					if (localCP > 1) and (targetHealth < 15) and (localEnergy >= 35) then
						CastSpellByName('Eviscerate', targetObj);
						self.messsage = "Using Eviscerate Combat Rotation 2";
						return 0; -- return until we use Eviscerate
					end

					-- eviscerate at 5 CP only
					if (localCP == 5) then
						if localObj:HasBuff('Slice and Dice') and (targetHealth > 25) and (localEnergy >= 35) then
							CastSpellByName('Eviscerate', targetObj);
							self.messsage = "Using Eviscerate 5 Combo Points Combat Rotation 2";
							return 0; -- return until we use Eviscerate
						end
					end

					-- Eviscerate
					if (localCP < 5) then
						if (localEnergy >= self.cpGeneratorCost) and (HasSpell(self.cpGenerator)) then
							if (script_rogue:spellAttack(self.cpGenerator, targetObj)) then
								self.waitTimer = GetTimeEX() + 250;
								self.message = "Using Combo Points Generator Attack Combat Rotation 2";
								return 0;
							end
						end
					end
				end

				-- Combat rotation 1
				if (not self.rotationTwo) then
					self.message = "Killing " .. targetObj:GetUnitName() .. "...";
					-- Dismount
					if (IsMounted()) then
						DisMount();
					end

					-- Check if we are in melee range
					if (targetObj:GetDistance() > self.meleeDistance or not targetObj:IsInLineOfSight()) and (PlayerHasTarget()) then
						return 3;
					end

					if (self.enableFaceTarget and not targetObj:FaceTarget() and targetObj:IsInLineOfSight()) then
						targetObj:FaceTarget();
					end

					-- Check: Use Healing Potion 
					if (localHealth < self.potionHealth) then 
						if (script_helper:useHealthPotion()) then 
							return 0; 
						end 
					end

					-- Check: Kick if the target is casting
					if (HasSpell("Kick") and targetObj:IsCasting() and not IsSpellOnCD("Kick")) and (localEnergy >= 25) then
						if (Cast("Kick", targetObj)) then
							return 0;
						end
					end

					-- check: Kidney shot if target is casting and kick is on cooldown
					if (self.useKidneyShot) then
						if (HasSpell('Kidney Shot')) and (localCP > 0) and (targetObj:IsCasting()) and (not IsSpellOnCD('Kidney Shot')) and (localEnergy >= 25) then
							if (Cast('Kidney Shot', targetObj)) then
								return 0;
							end
						end
					end

					-- Gouge if target casting
					if (HasSpell("Gouge")) and (not IsSpellOnCD("Gouge")) and (localEnergy >= 45) and (targetObj:IsCasting()) then
						if (CastSpellByName("Gouge", targetObj)) then
							self.waitTimer = GetTimeEX() + 250;
							return 0;
						end
					end

					-- Use Blade Flurry on CD targets > 1
					if (self.enableBladeFlurry) then
						if (HasSpell("Blade Flurry")) and (not IsSpellOnCD("Blade Flurry")) and (targetHealth >= 50) and (localEnergy >= 25) then
							if (script_helper:enemiesAttackingUs(5) >= 1) then
								CastSpellByName("Blade Flurry");
								return 0;
							end
						end
					end

					-- Use adrenaline Rush on CD targets > 1
					if (self.enableAdrenRush)then
						if (HasSpell("Adrenaline Rush")) and (not IsSpellOnCD("Adrenaline Rush")) and (targetHealth >= 60) then
							if (script_helper:enemiesAttackingUs(5) >= 1) then
								CastSpellByName("Adrenaline Rush");
								return 0;
								
							end
						end
					end

					if (HasSpell("Ghostly Strike")) and (not IsSpellOnCD("Ghostly Strike")) and (localEnergy >= 40) and ( (targetHealth >= 25 and localHealth >=25) or (localHealth <= 25) ) then
						CastSpellByName("Ghostly Strike", targetObj);
						return 0;
					end

					-- Check: Use Riposte whenever we can
					if (HasSpell("Riposte")) and (script_rogue:canRiposte() and not IsSpellOnCD("Riposte")) and (localEnergy >= 10) then 
						CastSpellByName("Riposte", targetObj);
						return 0; -- return until we cast Riposte 
					end
			
					-- Check: Use Evasion if low HP
					if (localHealth <= self.evasionHealth) then
						if (HasSpell('Evasion') and not IsSpellOnCD('Evasion')) then
							CastSpellByName('Evasion');
							return 0;
						end
					end 
 
					-- Eviscerate with 5 CPs
					if (localCP == 5) and (localEnergy >= 35) then
						CastSpellByName('Eviscerate', targetObj);
						return 0; -- return until we use Eviscerate
					end
			
					-- Keep Slice and Dice up
					if (HasSpell("Slice and Dice")) then
						if (self.useSliceAndDice and not localObj:HasBuff('Slice and Dice') and targetHealth > 50 and localCP > 0) and (localEnergy >= 25) then 
							CastSpellByName("Slice and Dice");
							return 0;
						end
					end

					-- Dynamic health check when using Eviscerate between 1 and 4 CP
					if (targetHealth < (10*localCP)) and (localEnergy >= 35) then
						CastSpellByName('Eviscerate', targetObj);
						return 0; -- return until we use Eviscerate
					end

					-- Use CP generator attack 
					if ((localEnergy >= self.cpGeneratorCost) and HasSpell(self.cpGenerator)) then
						if (CastSpellByName(self.cpGenerator, targetObj)) then
							return 0;
						end
					end
				end
			end	
		end
	end


	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(256, 311);

		if (IsMoving()) or (not IsInCombat()) or (targetObj:IsFleeing()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) and (not targetObj:IsFleeing()) then
			script_grind.tickRate = tickRandom
		elseif (IsInCombat()) and (not IsMoving())and (not targetObj:IsFleeing()) then
			script_grind.tickRate = tickRandom;
		end
	end

end

function script_rogue:rest()

	if(not self.isSetup) then
		script_rogue:setup();
	end

	local localObj = GetLocalPlayer();
	local localHealth = localObj:GetHealthPercentage();

	if (HasItem("Linen Bandage")) or 
		(HasItem("Heavy Linen Bandage")) or 
		(HasItem("Wool Bandage")) or 
		(HasItem("Heavy Wool Bandage")) or 
		(HasItem("Silk Bandage")) or 
		(HasItem("Heavy Silk Bandage")) or 
		(HasItem("Mageweave Bandage")) or 
		(HasItem("Heavy Mageweave Bandage")) or 
		(HasItem("Runecloth Bandage")) or 
		(HasItem("Heavy Runecloth Bandage")) then

		self.hasBandages = true;
	else
		self.hasBandages = false;
		self.useBandage = false;
	end

	if (IsMounted()) then
		Dismount();
	end

	-- if has bandage then use bandages
	if (self.eatHealth >= 35) and (self.hasBandages) and (self.useBandage) and (not IsMoving()) and (localHealth < self.eatHealth) then
		if (not script_checkDebuffs:hasPoison()) and (not IsEating()) and (not localObj:HasDebuff("Recently Bandaged")) then
		if (IsMoving()) then
			StopMoving();
		end
			self.waitTimer = GetTimeEX() + 1200;
			script_grind:setWaitTimer(1500);

		if (IsStanding()) and (not IsInCombat()) and (not IsMoving()) and (not localObj:HasDebuff("Recently Bandaged")) then
			if (script_helper:useBandage()) then	
				self.waitTimer = GetTimeEX() + 6000;
			end
		end
		return 0;
		end
	end

	-- set tick rate for script to run
	if (not script_grind.adjustTickRate) then

		local tickRandom = random(306, 692);

		if (IsMoving()) or (not IsInCombat()) then
			script_grind.tickRate = 135;
		elseif (not IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom
		elseif (IsInCombat()) and (not IsMoving()) then
			script_grind.tickRate = tickRandom;
		end
	end


	if (HasSpell("Cold Blood")) and (not IsSpellOnCD("Cold Blood")) and (not localObj:HasBuff("Cold Blood")) then
		CastSpellByName("Cold Blood");
		return 0;
	end

	-- Eat something
	if (not IsEating() and localHealth < self.eatHealth) then
		script_grind:setWaitTimer(1500);
		self.waitTimer = GetTimeEX() + 2000;
		self.message = "Need to eat...";
		if (IsInCombat()) then
			return false;
		end
			
		if (IsMoving()) then StopMoving(); return true; end

		if (script_helper:eat()) then 
			self.message = "Eating..."; 
			self.waitTimer = GetTimeEX() + 2000;
			script_grind:setWaitTimer(1500);
			return true; 
		else 
			self.message = "No food! (or food not included in script_helper)";
		end		
	end

	-- Stealth when we eat
	if (HasSpell("Stealth")) and (not IsSpellOnCD("Stealth")) and (not IsStealth()) and (IsEating())  and (not script_checkDebuffs:hasPoison()) and (localHealth < 45) then
		if (not IsStealth()) then
			CastStealth();
			return true;
		end
	end
	
	-- Continue eating until we are full
	if(localHealth < 98 and IsEating()) then
		self.message = "Resting up to full health...";
		self.waitTimer = GetTimeEX() + 2000;
		return true;
	end
		
	if (not IsDrinking()) and (not IsEating()) then
		if (not IsStanding()) then
			JumpOrAscendStart();
		end
	end

	local vendorStatus = script_vendor:getStatus();

	if (HasSpell("Stealth")) and (not IsStealth()) and (IsSpellOnCD("Stealth")) and (self.useStealth) and (not IsLooting()) and (script_grind.lootObj == nil) and (vendorStatus ~= 1) and (vendorStatus ~= 2) and (vendorStatus ~= 3) and (vendorStatus ~= 4) then
		self.message = "Waiting for Stealth cooldown...";
		return 4;
	end
	
	-- Don't need to eat
	return false;
end