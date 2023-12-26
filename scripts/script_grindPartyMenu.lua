script_grindPartyMenu = {

}

function script_grindPartyMenu:menu()
if (GetNumPartyMembers() >= 1) then
		if (CollapsingHeader("Grind Party Options")) then
		wasClicked, script_grindParty.forceTarget = Checkbox("Force Attack Group Targets (can cause lag)", script_grindParty.forceTarget);
		wasClicked, script_grindParty.waitForGroup = Checkbox("Wait For Party Mana", script_grindParty.waitForGroup);
		wasClicked, script_grindParty.waitForMemberDistance = Checkbox("Stop if member leaves range", script_grindParty.waitForMemberDistance);
		wasClicked, script_grindParty.healGroup = Checkbox("Heal/Buff Party Members (Follower Heals)", script_grindParty.healGroup);


		end
	end


end