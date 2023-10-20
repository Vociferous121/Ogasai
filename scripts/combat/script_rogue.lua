script_rogue = {
	message = 'Rogue Combat Script',
	rogueMenu = include("scripts\\combat\\script_rogueEX.lua"),
	mainhandPoison = "Instant Poison",
	offhandPoison = "Instant Poison",
	cpGenerator = 'Sinister Strike',
	throwName = "Heavy Throwing Dagger",
	stealthOpener = "Sinister Strike",
	eatHealth = 40,
	potionHealth = 15,
	cpGeneratorCost = 40,
	meeleDistance = 3.6,
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
	followTargetDistance = 100,
}

function script_rogue:setup()
	-- no more bugs first time we run the bot
	self.waitTimer = GetTimeEX(); 

	-- Set Cheap Shot as default opener if we have it
	if (HasSpell("Cheap Shot")) then
		self.stealthOpener = "Cheap Shot";
	end

	-- Set Hemorrhage as default CP builder if we have it
	if (HasSpell("Hemorrhage")) then
		self.cpGenerator = "Hemorrhage";
	end

	--set backstab as opener
	if (GetLocalPlayer():GetLevel() < 10) then
		self.stealthOpener = "Backstab";
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

function script_rogue:canRiposte()
	for i=1,132 do 
		local texture = GetActionTexture(i); 
		if texture ~= nil and string.find(texture,"Ability_Warrior_Challenge") then
			local isUsable, _ = IsUsableAction(i); 
			if (isUsable == 1 and not IsSpellOnCD(Riposte)) then 
				return true; 
			end 
		end
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
 			Move(moveX, moveY, moveZ);
			self.waitTimer = GetTimeEX() + 1500;
 			return true;
 		end
	end
	return false;
end

function script_rogue:draw()
	local tX, tY, onScreen = WorldToScreen(GetLocalPlayer():GetPosition());
	if (onScreen) then
		DrawText(self.message, tX+75, tY+40, 0, 255, 255);
	else
		DrawText(self.message, 25, 185, 0, 255, 255);
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
	targetObj =  GetGUIDObject(targetGUID);
	
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

	if (self.enableGrind) then
		--Valid Enemy
		if (targetObj ~= 0) then

		-- Set Slice and Dice level 10 or greater
			if not (HasSpell("Slice And Dice")) then
				useSliceAndDice = false;
			end
		
			-- Cant Attack dead targets
			if (targetObj:IsDead() or not targetObj:CanAttack()) then
				return 0;
			end
		
			if (not IsStanding()) then
				JumpOrAscendStart();
			end
		
			if (targetObj:IsInLineOfSight() and not IsMoving()) then
				if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
					if (not targetObj:FaceTarget()) then
						targetObj:FaceTarget();
						self.waitTimer = GetTimeEX() + 200;
					end
				end
			end

			-- Auto Attack
			if (targetObj:GetDistance() < 40) then
				targetObj:AutoAttack();
			end
	
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
		
			-- Opener
			if (not IsInCombat()) then
				self.targetObjGUID = targetObj:GetGUID();
				self.message = "Pulling " .. targetObj:GetUnitName() .. "...";

				if (targetObj:IsInLineOfSight() and not IsMoving()) then
					if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
						if (not targetObj:FaceTarget()) then
							targetObj:FaceTarget();
							self.waitTimer = GetTimeEX() + 0;
						end
					end
				end
	

				-- Stealth in range if enabled
				if (self.useStealth and targetObj:GetDistance() <= self.stealthRange) and (not localObj:HasDebuff("Poison")) then
					if (not localObj:HasBuff("Stealth") and not IsSpellOnCD("Stealth")) then
						CastSpellByName("Stealth");
						return 3;
					end
					-- Use sprint (when stealthed for pull)
					if (HasSpell("Sprint") and not IsSpellOnCD("Sprint")) then
						CastSpellByName("Sprint");
						return 3;
					end
				elseif (not self.useStealth and localObj:HasBuff("Stealth")) and (not localObj:HasDebuff("Poison")) then
					CastSpellByName("Stealth");
				end


				-- Open with stealth opener
				if (targetObj:GetDistance() < 6 and self.useStealth and HasSpell(self.stealthOpener) and localObj:HasBuff("Stealth")) then
					if (script_rogue:spellAttack(self.stealthOpener, targetObj)) then
						return 0;
					end
				end
			
				-- use throw if checked
				if (not self.useStealth and self.throwOpener and script_rogue:equipThrow()) then
					if (targetObj:GetDistance() > 30 or not targetObj:IsInLineOfSight()) then
						return 3;
					else
						-- Dismount
						if (IsMounted()) then 
							DisMount();
						end
						if (Cast("Throw", targetObj)) then
							self.waitTimer = GetTimeEX() + 4000;
							return 0;
						end
					end
				end

				if (targetObj:IsInLineOfSight() and not IsMoving()) then
					if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
						if (not targetObj:FaceTarget()) then
							targetObj:FaceTarget();
							self.waitTimer = GetTimeEX() + 0;
						end
					end
				end
			
				-- Check if we are in meele range
				if (targetObj:GetDistance() > self.meeleDistance or not targetObj:IsInLineOfSight()) then
					return 3;
				end

				-- Use CP generator attack 
				if ((localEnergy >= self.cpGeneratorCost) and HasSpell(self.cpGenerator)) then
					if(script_rogue:spellAttack(self.cpGenerator, targetObj)) then
						return 0;
					end
				end
 
				-- Use CP generator attack  (in combat)
				if (IsInCombat()) then
					if ((localEnergy >= self.cpGeneratorCost) and HasSpell(self.cpGenerator)) then
						if(script_rogue:spellAttack(self.cpGenerator, targetObj)) then
							return 0;
						end
					end
				end

				-- now in Combat
			else	

				self.message = "Killing " .. targetObj:GetUnitName() .. "...";

				-- Dismount
				if (IsMounted()) then
					DisMount();
				end

				if (targetObj:IsInLineOfSight() and not IsMoving()) then
					if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
						if (not targetObj:FaceTarget()) then
							targetObj:FaceTarget();
							self.waitTimer = GetTimeEX() + 0;
						end
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

				local localCP = GetComboPoints("player", "target");

				-- Run backwards if we are too close to the target
				if (targetObj:GetDistance() < .3) then 
					if (script_rogue:runBackwards(targetObj,4)) then 
						return 4; 
					end 
				end

				-- Check if we are in meele range
				if (targetObj:GetDistance() > self.meeleDistance or not targetObj:IsInLineOfSight()) then
					return 3;
				end

				if (targetObj:IsInLineOfSight() and not IsMoving() and targetHealth <= 99) then
					if (targetObj:GetDistance() <= self.followTargetDistance) and (targetObj:IsInLineOfSight()) then
						if (not targetObj:FaceTarget()) then
							targetObj:FaceTarget();
							self.waitTimer = GetTimeEX() + 0;
						end
					end
				end

				-- Check: Use Vanish 
				if (HasSpell('Vanish') and HasItem('Flash Powder') and localHealth < self.vanishHealth and not IsSpellOnCD('Vanish')) then 
					CastSpellByName('Vanish'); 
					ClearTarget(); 
					self.targetObj = 0;
					return 4;
				end 

				-- Check: Use Healing Potion 
				if (localHealth < self.potionHealth) then 
					if (script_helper:useHealthPotion()) then 
						return 0; 
					end 
				end

				-- Check: Kick if the target is casting
				if (HasSpell("Kick") and targetObj:IsCasting() and not IsSpellOnCD("Kick")) then
					if (localEnergy <= 25) then return 0; end
					if (Cast("Kick", targetObj)) then
						return 0;
					end
				end

				-- Set available skills variables
				hasEvasion = HasSpell('Evasion');
			
				-- Talent specific skills variables
				hasFlurry = HasSpell('Blade Flurry');  
				hasAdrenalineRush = HasSpell('Adrenaline Rush'); 

				if (not targetObj:FaceTarget() and targetObj:IsInLineOfSight()) then
					targetObj:FaceTarget();
				end

				-- Check: Use Riposte whenever we can
				if (script_rogue:canRiposte() and not IsSpellOnCD("Riposte")) then 
					if (localEnergy < 10) then 
						return 0; 
					end -- return until we have energy
					if (not script_rogue:spellAttack("Riposte", targetObj)) then 
						return 0; -- return until we cast Riposte
					end 
				end
			
				-- Check: Use Evasion if low HP or more than one enemy attack us
				if ((localHealth < self.evasionHealth and localHealth < targetHealth) or (script_helper:enemiesAttackingUs(5) >= 2 and localHealth < self.evasionHealth)) then 
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

				 --If Blade Flurry then use Adrenaline Rush on Low HP
				if (HasSpell('Evasion') and not IsSpellOnCD('Adrenaline Rush') and localHealth < self.adrenRushComboHP and (self.adrenRushCombo)) then 
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
				if (localCP > 4) then
					if (localEnergy < 35) then
						return 0; 
					end -- return until we have energy
					if (not script_rogue:spellAttack('Eviscerate', targetObj)) then 
						return 0; -- return until we use Eviscerate
					end 
				end
			
				-- Keep Slice and Dice up
				if (HasSpell("Slice And Dice")) then
					if (self.useSliceAndDice and not localObj:HasBuff('Slice and Dice') and targetHealth > 50 and localCP > 1) then
						if (localEnergy < 25) then 
							return 0;
						end -- return until we have energy
						if (not script_rogue:spellAttack('Slice and Dice', targetObj) or localEnergy <= 25) then
							return 0;
						end
					end
				end
			
				-- Dynamic health check when using Eviscerate between 1 and 4 CP
				if (targetHealth < (10*localCP)) then
					if (localEnergy < 35) then
						return 0; 
					end -- return until we have energy
					if (not script_rogue:spellAttack('Eviscerate', targetObj)) then 
						return 0; -- return until we use Eviscerate
					end
				end

				-- Use CP generator attack 
				if ((localEnergy >= self.cpGeneratorCost) and HasSpell(self.cpGenerator)) then
					if(script_rogue:spellAttack(self.cpGenerator, targetObj)) then
						return 0;
					end
				end
			return 0;
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
			if (targetObj:GetDistance() < 40) then
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
				if (self.useStealth and targetObj:GetDistance() <= self.stealthRange) and (not localObj:HasDebuff("Poison")) then
					if (not localObj:HasBuff("Stealth") and not IsSpellOnCD("Stealth")) then
						CastSpellByName("Stealth");
						return 3;
					end
					-- why break stealth??
					--elseif (not self.useStealth and localObj:HasBuff("Stealth")) then
					--CastSpellByName("Stealth");
				end

				-- Open with stealth opener
				if (targetObj:GetDistance() < 6 and self.useStealth and HasSpell(self.stealthOpener) and localObj:HasBuff("Stealth")) then
					if (script_rogue:spellAttack(self.stealthOpener, targetObj)) then
						return 0;
					end
						-- if we are stealthed for some reason
				elseif (targetObj:GetDistance() < 6) and (not self.useStealth) and (HasSpell(self.stealthOpener)) and (localObj:HasBuff("Stealth")) then
					if (script_rogue:spellAttack(self.stealthOpener, targetObj)) then
						return 0;
					end
				end
			
				-- Check if we are in meele range
				if (targetObj:GetDistance() > self.meeleDistance or not targetObj:IsInLineOfSight()) then
					return 3;
				end

				-- Use CP generator attack 
				if ((localEnergy >= self.cpGeneratorCost) and HasSpell(self.cpGenerator)) then
					if(script_rogue:spellAttack(self.cpGenerator, targetObj)) then
						return 0;
					end
				end
 
				-- Use CP generator attack  (in combat)
				if (IsInCombat()) then
					if (localEnergy >= self.cpGeneratorCost) and (HasSpell(self.cpGenerator)) then
						if(script_rogue:spellAttack(self.cpGenerator, targetObj)) then
							return 0;
						end
					end
				end

				-- Combat  ROTATION NOW IN COMBAT 

			else	

				local localCP = GetComboPoints("player", "target");
	
				-- Combat Rotation 2 COMBAT ROTATION 2
				if (self.rotationTwo) then
					self.message = "Using Combat Rotation 2!";

						-- Check: Kick if the target is casting
					if (HasSpell("Kick") and targetObj:IsCasting() and not IsSpellOnCD("Kick")) then
						self.message = "Waiting for Kick Energy Combat Rotation 2";
						if (localEnergy > 24) then 
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
							if (localEnergy > 24) then
								self.message = "Waiting for Kidney Shot Energy Combat Rotation 2";
								return 0;
							end
							if (Cast('Kidney Shot', targetObj)) then
							self.message = "Using Kidney Shot Combat Rotation 2";
								return 0;
							end
						end
					end

					-- check riposte
					if (script_rogue:canRiposte() and not IsSpellOnCD("Riposte")) then 
						self.message = "Waiting for Riposte Energy Combat Rotation 2";
						if (localEnergy < 10) then 
							return 0; 
						end -- return until we have energy
						if (not script_rogue:spellAttack("Riposte", targetObj)) then 
							self.message = "Using Riposte Combat Rotation 2";
							return 0; -- return until we cast Riposte
						end 
					end

					-- Use Blade Flurry on CD targets > 1
					if (self.enableBladeFlurry) then
						if (HasSpell("Blade Flurry")) and (not IsSpellOnCD("Blade Flurry")) and (targetHealth > 50) then
							if (script_helper:enemiesAttackingUs(5) >= 1) then
								if (CastSpellByName("Blade Flurry")) then
								self.message = "Using Blade Flurry Combat Rotation 2";
									return 0;
								end
							end
						end
					end

					-- Use adrenaline Rush on CD targets > 1
					if (self.enableAdrenRush)then
						if (HasSpell("Adrenaline Rush")) and (not IsSpellOnCD("Adrenaline Rush")) and (targetHealth > 60) then
							if (script_helper:enemiesAttackingUs(5) >= 1) then
								if(CastSpellByName("Adrenaline Rush")) then
									self.message = "Using Adrenaline Rush Combat Rotation 2";
									return 0;
								end
							end
						end
					end

					-- Slice and Dice at 2 combo points
					if (localCP > 2) and (HasSpell("Slice And Dice")) then
						if (not localObj:HasBuff('Slice and Dice')) and (targetHealth > 25) then
							if (localEnergy < 25) then 
								self.message = "waiting for 25 energy for Slice and Dice Combat Rotation 2";
								return 0; -- return until we have energy
							end
							if (not script_rogue:spellAttack('Slice and Dice', targetObj) or localEnergy <= 25) then
								self.message = "Using Slice and Dice Combat Rotation 2";
								return 0;
							end
						end
					end

					-- Eviscerate
					if (localCP > 1) and (targetHealth < 15) then
						if (localEnergy < 35) then
							self.message = "Waiting for 35 energy for Eviscerate Combat Rotation 2";
							return 0;
						end
						if (not script_rogue:spellAttack('Eviscerate', targetObj)) then 
							self.messsage = "Using Eviscerate Combat Rotation 2";
							return 0; -- return until we use Eviscerate
						end
					end

					-- eviscerate at 5 CP only
					if (localCP == 5) then
						if localObj:HasBuff('Slice and Dice') and (targetHealth > 25) and (localEnergy > 35) then
							if (not script_rogue:spellAttack('Eviscerate', targetObj)) then 
								self.messsage = "Using Eviscerate 5 Combo Points Combat Rotation 2";
								return 0; -- return until we use Eviscerate
							end
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

					-- Check: Do we have the right target (in UI) ??
					if (GetTarget() ~= 0 and GetTarget() ~= nil) then
						if (GetTarget():GetGUID() ~= targetObj:GetGUID()) then
							ClearTarget();
							targetObj = 0;
							return 0;
						end
					end

					-- Check if we are in meele range
					if (targetObj:GetDistance() > self.meeleDistance or not targetObj:IsInLineOfSight()) then
						return 3;
					else
						if (IsMoving()) then
							StopMoving();
						end
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
					if (HasSpell("Kick") and targetObj:IsCasting() and not IsSpellOnCD("Kick")) then
						if (localEnergy > 24) then 
							return 0; 
						end
						if (Cast("Kick", targetObj)) then
							return 0;
						end
					end

					-- check: Kidney shot if target is casting and kick is on cooldown
					if (self.useKidneyShot) then
						if (HasSpell('Kidney Shot')) and (localCP > 0) and (targetObj:IsCasting()) and (not IsSpellOnCD('Kidney Shot')) then
							if (localEnergy > 24) then
								return 0;
							end
							if (Cast('Kidney Shot', targetObj)) then
								return 0;
							end
						end
					end

					-- Use Blade Flurry on CD targets > 1
					if (self.enableBladeFlurry) then
						if (HasSpell("Blade Flurry")) and (not IsSpellOnCD("Blade Flurry")) and (targetHealth > 50) then
							if (script_helper:enemiesAttackingUs(5) >= 1) then
								if (CastSpellByName("Blade Flurry")) then
									return 0;
								end
							end
						end
					end

					-- Use adrenaline Rush on CD targets > 1
					if (self.enableAdrenRush)then
						if (HasSpell("Adrenaline Rush")) and (not IsSpellOnCD("Adrenaline Rush")) and (targetHealth > 60) then
							if (script_helper:enemiesAttackingUs(5) >= 1) then
								if(CastSpellByName("Adrenaline Rush")) then
									return 0;
								end
							end
						end
					end

					-- Check: Use Riposte whenever we can
					if (script_rogue:canRiposte() and not IsSpellOnCD("Riposte")) then 
						if (localEnergy < 10) then 
							return 0; 
						end -- return until we have energy
						if (not script_rogue:spellAttack("Riposte", targetObj)) then 
							return 0; -- return until we cast Riposte
						end 
					end
			
					-- Check: Use Evasion if low HP
					if (localHealth < self.evasionHealth) then
						if (HasSpell('Evasion') and not IsSpellOnCD('Evasion')) then
							CastSpellByName('Evasion');
							return 0;
						end
					end 
 
					-- Eviscerate with 5 CPs
					if (localCP == 5) then
						if (localEnergy < 35) then
							return 0; 
						end -- return until we have energy
						if (not script_rogue:spellAttack('Eviscerate', targetObj)) then 
							return 0; -- return until we use Eviscerate
						end 
					end
			
					-- Keep Slice and Dice up
					if (HasSpell("Slice And Dice")) then
						if (self.useSliceAndDice and not localObj:HasBuff('Slice and Dice') and targetHealth > 50 and localCP > 0) then
							if (localEnergy < 25) then 
								return 0;
							end -- return until we have energy
							if (not script_rogue:spellAttack('Slice and Dice', targetObj) or localEnergy <= 25) then
								return 0;
							end
						end
					end

					-- Dynamic health check when using Eviscerate between 1 and 4 CP
					if (targetHealth < (10*localCP)) then
						if (localEnergy < 35) then
							return 0; 
						end -- return until we have energy
						if (not script_rogue:spellAttack('Eviscerate', targetObj)) then 
							return 0; -- return until we use Eviscerate
						end
					end

					-- Use CP generator attack 
					if ((localEnergy >= self.cpGeneratorCost) and HasSpell(self.cpGenerator)) then
						if(script_rogue:spellAttack(self.cpGenerator, targetObj)) then
							return 0;
						end
					end
				end
			return 0;
			end	
		end
	end
end

function script_rogue:rest()
	if(not self.isSetup) then script_rogue:setup(); end

	local localObj = GetLocalPlayer();
	local localHealth = localObj:GetHealthPercentage();

	-- looting

	local lootObj = script_nav:getLootTarget(lootRadius);
	
	if (not AreBagsFull() and not script_grind.bagsFull and script_grind.lootObj ~= nil) then
		self.waitTimer = GetTimeEX() + 1800;
		script_grind:doLoot(localObj);
		script_grind:lootAndSkin();
		script_nav:resetNavigate();
		script_nav:resetNavPos();
		ClearTarget();
		return true;
	end

	-- skin after looting - won't stealth after skinning and bot stands still until resting is done????
	--if (not AreBagsFull() and not script_grind.bagsFull and script_grind.lootObj == nil) then
	--	local lootObj = script_grind:getSkinTarget();
	--	script_grind:doLoot();
	--	self.waitTimer = GetTimeEX() + 2200;
	--	return true;
	--end

	-- Eat something
	if (not IsEating() and localHealth < self.eatHealth) then
		self.waitTimer = GetTimeEX() + 2000;
		self.message = "Need to eat...";
		if (IsInCombat()) then
			return true;
		end
			
		if (IsMoving()) then StopMoving(); return true; end

		if (script_helper:eat()) then 
			self.message = "Eating..."; 
			return true; 
		else 
			self.message = "No food! (or food not included in script_helper)";

			if (HasSpell("Stealth") and not IsSpellOnCD("Stealth") and not localObj:HasDebuff("Touch of Zanzil")) and (not localObj:HasDebuff("Poison")) then
				if (not localObj:HasBuff("Stealth")) then
					CastSpellByName("Stealth");
				end
			end
			self.waitTimer = GetTimeEX() + 3000;
			return true; 
		end		
	end

	-- Stealth when we eat
	if (HasSpell("Stealth") and not IsSpellOnCD("Stealth") and IsEating() and not localObj:HasDebuff("Touch of Zanzil")) and (not localObj:HasDebuff("Poison")) then
		if (not localObj:HasBuff("Stealth")) then
			CastSpellByName("Stealth");
			return true;
		end
	end
	
	-- Continue eating until we are full
	if(localHealth < 98 and IsEating()) then
		self.message = "Resting up to full health...";
		return true;
	end
		
	-- Stand up if we are rested
	if (localHealth > 98 and (IsEating() or not IsStanding())) then
		StopMoving();
		return false;
	end
	
	-- Don't need to eat
	return false;
end