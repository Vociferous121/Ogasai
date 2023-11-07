local major = "LegoBlock-Beta1"
local minor = 39

if( not LibStub ) then
	error(string.format("%s requires LibStub.", major))
end

local LegoBlock, oldRevision = LibStub:NewLibrary(major, minor)
local tinsert, tconcat, tremove, tgetn = table.insert, table.concat, table.remove, table.getn

-- No upgrade needed
if( not LegoBlock ) then
	return
end

-- Re-use or create new members.
LegoBlock.legos = LegoBlock.legos or {}
LegoBlock.restorePositions = LegoBlock.restorePositions or {}
LegoBlock.stickiedFrames = LegoBlock.stickiedFrames or {}
LegoBlock.frameLinks = LegoBlock.frameLinks or {}
LegoBlock.onUpdateFuncs = LegoBlock.onUpdateFuncs or {}
LegoBlock.frameStrata = LegoBlock.frameStrata or {}
LegoBlock.savingPositions = LegoBlock.savingPositions or {}
LegoBlock.totalLegos = LegoBlock.totalLegos or 0

-- Locals for easier access
local abs, string_sub, sqrt = math.abs, string.sub, math.sqrt
local pairs = pairs

-- The actual savings for this appears to be pretty much close to nil however
local legos = LegoBlock.legos
local restorePositions = LegoBlock.restorePositions
local stickiedFrames = LegoBlock.stickiedFrames
local frameLinks = LegoBlock.frameLinks
local onUpdateFuncs = LegoBlock.onUpdateFuncs
local frameStrata = LegoBlock.frameStrata
local savingPositions = LegoBlock.savingPositions
local OnDragStart, OnDragStop, restoreFramePosition, saveFramePosition, reheadFrames

local methods = {"SetText", "SetIcon", "HideText", "HideIcon", "ShowText", "ShowIcon", "SetDB"}

local function print(text)
	ChatFrame3:AddMessage(text)
end

local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

-- Update positioning of all lego blocks when we log in, if not already logged in
if( not LegoBlock.frame ) then
	LegoBlock.frame = CreateFrame("Frame")
	LegoBlock.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	LegoBlock.frame:SetScript("OnEvent", function(self, event)
		if( event == "PLAYER_LOGIN" ) then
			for lego in pairs(legos) do
				restoreFramePosition(lego)
			end

			self:UnregisterEvent("PLAYER_LOGIN")
		elseif( event == "PLAYER_REGEN_DISABLED" and LegoBlock.movingFrame ) then
			OnDragStop(LegoBlock.movingFrame)
		end
	end)

	--if( not IsLoggedIn() ) then
		LegoBlock.frame:RegisterEvent("PLAYER_LOGIN")
	--end
	
end

--[[ Positioning, code taken with permission from WindowLib by Mikk]]--
local function GetPoints(frame)
	local s = frame:GetScale()
	local x, y = frame:GetCenter()
	local right, left = frame:GetRight()*s, frame:GetLeft()*s
	local top, bottom = frame:GetTop()*s, frame:GetBottom()*s
	local pwidth, pheight = UIParent:GetWidth(), UIParent:GetHeight()

	x, y = x*s, y*s

	local xOff, yOff, anchor
	if( left < (pwidth - right) and left < abs(x - pwidth/2) ) then
		xOff = left
		anchor = "LEFT"
	elseif( (pwidth - right) < abs(x - pwidth/2) ) then
		xOff = right - pwidth
		anchor = "RIGHT"
	else
		xOff = x - pwidth/2
		anchor = ""
	end

	if( bottom < (pheight - top) and bottom < abs(y - pwidth/2) ) then
		yOff = bottom
		anchor = "BOTTOM"..anchor
	elseif( (pheight - top) < abs(y - pheight/2) ) then
		yOff = top - pheight
		anchor = "TOP"..anchor
	else
		yOff = y - pheight/2
	end

	if( anchor == "" ) then
		anchor = "CENTER"
	end

	return xOff, yOff, anchor
end

-- FLYPAPER
-- Handles sticking frames to eachother using relative positioning
-- credit to Tuller for this
local FlyPaper = {}

local function FrameIsDependentOnFrame(frame, otherFrame)
	if( frame and otherFrame ) then
		if( frame == otherFrame ) then
			return true
		end

		local points = frame:GetNumPoints()
		for i = 1, points do
			local _, parent =  frame:GetPoint(i)
			if FrameIsDependentOnFrame(parent, otherFrame) then
				return true
			end
		end
	end

	return nil
end

--returns true if its actually possible to attach the two frames without error
local function CanAttach(frame, otherFrame)
	if( not frame and not otherFrame ) then
		return nil
	elseif( frame:GetWidth() == 0 or frame:GetHeight() == 0 or otherFrame:GetWidth() == 0 or otherFrame:GetHeight() == 0 ) then
		return nil
	elseif( FrameIsDependentOnFrame(otherFrame, frame) ) then
		return nil
	end

	return true
end

local function AttachToTop(frame, otherFrame, distLeft, distRight, distCenter, offset)
	--closest to the left
	if( distLeft < distCenter and distLeft < distRight ) then
		frame:SetPoint("BOTTOMLEFT", otherFrame, "TOPLEFT", 0, offset)
		return "TL"

	--closest to the right
	elseif( distRight < distCenter and distRight < distLeft ) then
		frame:SetPoint("BOTTOMRIGHT", otherFrame, "TOPRIGHT", 0, offset)
		return "TR"
	--closest to the center
	else
		frame:SetPoint("BOTTOM", otherFrame, "TOP", 0, offset)
		return "TC"
	end
end

local function AttachToBottom(frame, otherFrame, distLeft, distRight, distCenter, offset)
	--bottomleft
	if( distLeft < distCenter and distLeft < distRight ) then
		frame:SetPoint("TOPLEFT", otherFrame, "BOTTOMLEFT", 0, -offset)
		return "BL"
	--bottomright
	elseif( distRight < distCenter and distRight < distLeft ) then
		frame:SetPoint("TOPRIGHT", otherFrame, "BOTTOMRIGHT", 0, -offset)
		return "BR"
	--bottom
	else
		frame:SetPoint("TOP", otherFrame, "BOTTOM", 0, -offset)
		return "BC"
	end
end

local function AttachToLeft(frame, otherFrame, distTop, distBottom, distCenter, offset)
	--bottomleft
	if( distBottom < distTop and distBottom < distCenter ) then
		frame:SetPoint("BOTTOMRIGHT", otherFrame, "BOTTOMLEFT", -offset, 0)
		return "LB"
	--topleft
	elseif( distTop < distBottom and distTop < distCenter ) then
		frame:SetPoint("TOPRIGHT", otherFrame, "TOPLEFT", -offset, 0)
		return "LT"
	--left
	else
		frame:SetPoint("RIGHT", otherFrame, "LEFT", -offset, 0)
		return "LC"
	end
end

local function AttachToRight(frame, otherFrame, distTop, distBottom, distCenter, offset)
	--bottomright
	if( distBottom < distTop and distBottom < distCenter ) then
		frame:SetPoint("BOTTOMLEFT", otherFrame, "BOTTOMRIGHT", offset, 0)
		return "RB"
	--topright
	elseif( distTop < distBottom and distTop < distCenter ) then
		frame:SetPoint("TOPLEFT", otherFrame, "TOPRIGHT", offset, 0)
		return "RT"
	--right
	else
		frame:SetPoint("LEFT", otherFrame, "RIGHT", offset, 0)
		return "RC"
	end
end

function FlyPaper:CanSnap(frame, otherFrame, tolerance)
	-- Get the frame we want to try to snap to otherFrame's points
	local left = frame:GetLeft()
	local right = frame:GetRight()
	local top = frame:GetTop()
	local bottom = frame:GetBottom()
	local centerX, centerY = frame:GetCenter()

	if( not left or not right or not top or not bottom or not centerX ) then
		return
	end

	-- Now get the points of the frame we want to snap to
	local oScale = otherFrame:GetScale()
	left = left / oScale
	right = right / oScale
	top = top / oScale
	bottom = bottom /oScale
	centerX = centerX / oScale
	centerY = centerY / oScale

	local oLeft = otherFrame:GetLeft()
	local oRight = otherFrame:GetRight()
	local oTop = otherFrame:GetTop()
	local oBottom = otherFrame:GetBottom()
	local oCenterX, oCenterY = otherFrame:GetCenter()

	if( not oLeft or not oRight or not oTop or not oBottom or not oCenterX ) then
		return
	end

	local scale = frame:GetScale()
	oCenterX = oCenterX / scale
	oCenterY = oCenterY / scale
	oLeft = oLeft / scale
	oRight = oRight / scale
	oTop = oTop / scale
	oBottom = oBottom / scale

	-- Check if any frames are within snapping distance
	if(oLeft - tolerance <= left and oRight + tolerance >= right) or (left - tolerance <= oLeft and right + tolerance >= oRight)then
		if( abs(oTop - bottom) <= tolerance or abs(oBottom - top) <= tolerance ) then
			return true
		end
	end


	if(oTop + tolerance >= top and oBottom - tolerance <= bottom) or (top + tolerance >= oTop and bottom - tolerance <= oBottom)then
		if( abs(oLeft - right) <= tolerance or abs(oRight - left) <= tolerance ) then
			return true
		end
	end
end

function FlyPaper:Stick( frame, otherFrame, tolerance, xOff, yOff)
	if( not xOff ) then
		xOff = 0
	end

	if( not yOff ) then
		yOff = 0
	end

	-- Get the frame we want to try to snap to otherFrame's points
	local left = frame:GetLeft()
	local right = frame:GetRight()
	local top = frame:GetTop()
	local bottom = frame:GetBottom()
	local centerX, centerY = frame:GetCenter()

	if( not left or not right or not top or not bottom or not centerX ) then
		return
	end

	-- Now get the points of the frame we want to snap to
	local oScale = otherFrame:GetScale()
	left = left / oScale
	right = right / oScale
	top = top / oScale
	bottom = bottom /oScale
	centerX = centerX / oScale
	centerY = centerY / oScale

	local oLeft = otherFrame:GetLeft()
	local oRight = otherFrame:GetRight()
	local oTop = otherFrame:GetTop()
	local oBottom = otherFrame:GetBottom()
	local oCenterX, oCenterY = otherFrame:GetCenter()

	if( not oLeft or not oRight or not oTop or not oBottom or not oCenterX ) then
		return
	end

	local scale = frame:GetScale()
	oCenterX = oCenterX / scale
	oCenterY = oCenterY / scale
	oLeft = oLeft / scale
	oRight = oRight / scale
	oTop = oTop / scale
	oBottom = oBottom / scale


	--[[ Start Attempting to Anchor <frame> to <otherFrame> ]]--
	if(oLeft - tolerance <= left and oRight + tolerance >= right) or (left - tolerance <= oLeft and right + tolerance >= oRight)then
		local distCenter = abs(oCenterX - centerX)
		local distLeft = abs(oLeft - left)
		local distRight = abs(right - oRight)

		--try to stick to the top if the distance is under the threshold distance to stick frames to each other (tolerance)
		if( abs(oTop - bottom) <= tolerance ) then
			frame:ClearAllPoints()
			return AttachToTop(frame, otherFrame, distLeft, distRight, distCenter, yOff)
		--to the bottom
		elseif( abs(oBottom - top) <= tolerance ) then
			frame:ClearAllPoints()
			return AttachToBottom(frame, otherFrame, distLeft, distRight, distCenter, yOff)
		end
	end


	if(oTop + tolerance >= top and oBottom - tolerance <= bottom) or (top + tolerance >= oTop and bottom - tolerance <= oBottom)then
		local distCenter = abs(oCenterY - centerY)
		local distTop = abs(oTop - top)
		local distBottom = abs(oBottom - bottom)

		--to the left
		if( abs(oLeft - right) <= tolerance ) then
			frame:ClearAllPoints()
			return AttachToLeft(frame, otherFrame, distTop, distBottom, distCenter, xOff)
		end

		--to the right
		if( abs(oRight - left) <= tolerance ) then
			frame:ClearAllPoints()
			return AttachToRight(frame, otherFrame, distTop, distBottom, distCenter, xOff)
		end
	end
end

function FlyPaper:StickToPoint( frame, otherFrame, point, xOff, yOff)
	--Sea.io.printTable({frame, otherFrame, point, xOff, yOff},1)
	if( not frame or not otherFrame or FrameIsDependentOnFrame(otherFrame, frame) ) then
		return nil
	end

	if( not xOff ) then
		xOff = 0
	end
	if( not yOff ) then
		yOff = 0
	end

	frame:ClearAllPoints()

	--to the top
	if point == "TL" then
		frame:SetPoint("BOTTOMLEFT", otherFrame, "TOPLEFT", 0, yOff)
		return point
	elseif point == "TC" then
		frame:SetPoint("BOTTOM", otherFrame, "TOP", 0, yOff)
		return point
	elseif point == "TR" then
		frame:SetPoint("BOTTOMRIGHT", otherFrame, "TOPRIGHT", 0, yOff)
		return point
	end

	--to the bottom
	if point == "BL" then
		frame:SetPoint("TOPLEFT", otherFrame, "BOTTOMLEFT", 0, -yOff)
		return point
	elseif point == "BC" then
		frame:SetPoint("TOP", otherFrame, "BOTTOM", 0, -yOff)
		return point
	elseif point == "BR" then
		frame:SetPoint("TOPRIGHT", otherFrame, "BOTTOMRIGHT", 0, -yOff)
		return point
	end

	--to the left
	if point == "LB" then
		frame:SetPoint("BOTTOMRIGHT", otherFrame, "BOTTOMLEFT", -xOff, 0)
		return point
	elseif point == "LC" then
		frame:SetPoint("RIGHT", otherFrame, "LEFT", -xOff, 0)
		return point
	elseif point == "LT" then
		frame:SetPoint("TOPRIGHT", otherFrame, "TOPLEFT", -xOff, 0)
		return point
	end

	--to the right
	if point == "RB" then
		frame:SetPoint("BOTTOMLEFT", otherFrame, "BOTTOMRIGHT", xOff, 0)
		return point
	elseif point == "RC" then
		frame:SetPoint("LEFT", otherFrame, "RIGHT", xOff, 0)
		return point
	elseif point == "RT" then
		frame:SetPoint("TOPLEFT", otherFrame, "TOPRIGHT", xOff, 0)
		return point
	end
end

local function resetFramePosition(frame)
	local xOff, yOff, anchor = GetPoints(frame)

	frame.stickPoint = nil
	frame:ClearAllPoints()
	frame:SetPoint(anchor or "CENTER", UIParent, anchor or "CENTER", xOff, yOff)
	saveFramePosition(frame)
end

local xOff = -2
local yOff = -2
local tolerance = 10

local function saveFramePositions(frame)
	if not savingPositions[frame] then
		savingPositions[frame] = true
		for f in pairs(frameLinks[frame]) do
			saveFramePositions(f)
		end
		saveFramePosition(frame)
	end
end

local function reheadFrames(block, newHead)
	if( block == newHead ) then
		return
	end

	local origBlock = newHead or block
	block.headLB = origBlock

	if( frameLinks[block] ) then
		for frame in pairs(frameLinks[block]) do
			frame.headLB = origBlock
			reheadFrames(frame, origBlock)
		end
	end
end
--[[
function dumpLinks()
	for frame, links in pairs(frameLinks) do
		local headLB = frame.headLB
		if( not headLB ) then
			headLB = "none"
		else
			headLB = headLB:GetName()
		end

		Debug("[" .. frame:GetName() .. "] [" .. headLB .. "]")
		local id = 0
		for chain in pairs(links) do
			id = id + 1
			Debug(" -- [" .. id .. "] " .. chain:GetName())
		end
	end

	Debug("------------")
end]]--

-- We need to clean this up later, but it works fine for now.
-- reverse the SetPoint connections (it's a silly linked list)
-- means we can do it iteratively
-- pass in the original node
local function reverseStick(block)
	local origblock = block
	-- if there is no next block then return
	if( not stickiedFrames[block] ) then
		return
	end
	local prevBlock = nil
	while( block ) do
		local nextBlock = stickiedFrames[block]
		--block.headLB = origblock

		stickiedFrames[block] = prevBlock
		-- if we have a nextBlock then
		if( nextBlock ) then
			-- remove the current block from the next block's list of attached
			-- blocks
			frameLinks[nextBlock][block] = nil
			-- add the next block to the current block's list of attached
			-- blocks
			frameLinks[block][nextBlock] = true
		end

		block:ClearAllPoints()
		prevBlock = block
		block = nextBlock

		if( prevBlock.stickPoint ) then
			local point = string_sub(prevBlock.stickPoint, 0, 1)
			if( point == "T" ) then
				prevBlock.stickPoint = "B" .. string_sub(prevBlock.stickPoint, 2)
			elseif( point == "B" ) then
				prevBlock.stickPoint = "T" .. string_sub(prevBlock.stickPoint, 2)
			elseif( point == "L" ) then
				prevBlock.stickPoint = "R" .. string_sub(prevBlock.stickPoint, 2)
			elseif( point == "R" ) then
				prevBlock.stickPoint = "L" .. string_sub(prevBlock.stickPoint, 2)
			else
				prevBlock.stickPoint = nil
			end
		end
	end

	block = prevBlock
	-- rehead all frames connected to this block (it was the previous head)
	reheadFrames(block, origblock)

	while( block ) do
		block:ClearAllPoints()
		local nextBlock = stickiedFrames[block]
		if( nextBlock ) then
			block.stickPoint = FlyPaper:StickToPoint(block, nextBlock, nextBlock.stickPoint, xOff, yOff)
		end
		block = nextBlock
	end
end

local highlightTexture = nil
local function showHighlightFrame(frame)
	if( not highlightTexture ) then
		highlightTexture = frame:CreateTexture(nil, "OVERLAY")
		highlightTexture:SetTexture(0.3, 0.3, 1, 0.4)
	else
		highlightTexture:SetParent(frame)
	end

	highlightTexture:SetAllPoints(frame)
	highlightTexture:Show()
end

local function hideHighlightFrame()
	if( highlightTexture ) then
		highlightTexture:Hide()
	end
end

-- Actually move
local currentStickyFrame
local cSFX, cSFY, cSFHeight, cSFWidth
local function frameMoving()
	local x, y = GetCursorPosition()

	this:ClearAllPoints()
	this:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / this.scale, y / this.scale)

	if( not IsControlKeyDown() ) then
		-- First check to see if we have highlighted a block
		local focusFrame = GetMouseFocus()
		if( focusFrame and focusFrame ~= this and legos[focusFrame] and focusFrame.headLB ~= this ) then

			if( currentStickyFrame ) then
				if( currentStickyFrame ~= focusFrame ) then
					hideHighlightFrame(currentStickyFrame)
					currentStickyFrame = nil
				end
			else
				currentStickyFrame = focusFrame
				showHighlightFrame(currentStickyFrame)
			end
		end

		-- Highlighting disabled, try and snap to everything nearby
		if( not currentStickyFrame ) then
			-- clear all the points then set it to its current position relative to
			-- UIParent.  This allows FlyPaper to do its magic without any
			-- dependencies on other LegoBlock blocks
			for frame in pairs(legos) do
				if( frame.headLB ~= this ) then
					local stick = FlyPaper:Stick(this, frame, tolerance, xOff, yOff)

					if( stick and not this.stickPoint ) then
						this.stickPoint = stick
						stickiedFrames[this] = frame
						break
					end
				end
			end

		-- Highlighting is enabled, so only try and snap to a specific frame
		else
			cSFX, cSFY = currentStickyFrame:GetCenter()
			cSFHeight, cSFWidth = currentStickyFrame:GetHeight(), currentStickyFrame:GetWidth()
			local x, y = this:GetCenter()
			local dist = sqrt((cSFX-x)^2+(cSFY-y)^2)
			if (dist > cSFHeight*10 or dist > cSFWidth*10) then
				-- 3 blocks away from the center of the block
				hideHighlightFrame(currentStickyFrame)
				currentStickyFrame = nil
			else
				local frame = currentStickyFrame
				local stick = FlyPaper:Stick(this, frame, tolerance, xOff, yOff)
				if( stick and not this.stickPoint ) then
					this.stickPoint = stick
					stickiedFrames[this] = frame
				end
			end
		end

		-- We were stuck, but we moved far enough away to unsnap ourself
		if( this.stickPoint and ( not stickiedFrames[this] or not FlyPaper:CanSnap(this, stickiedFrames[this], tolerance) ) ) then
			resetFramePosition(this)
			stickiedFrames[this] = nil
		end
	end
end

function OnDragStart()
	if( this.optionsTbl and this.optionsTbl.locked ) then
		return
	end

	LegoBlock.movingFrame = this

	onUpdateFuncs[this] = this:GetScript("OnUpdate")
	frameStrata[this] = this:GetFrameStrata()

	-- Reduce frameStrata so other LegoBlocks will be positioned above current one for GetMouseFocus().
	this:SetFrameStrata("LOW")
	this.isMoving = true
	this.scale = this:GetEffectiveScale()

	-- CTRL down, so only drag a single frame
	if( IsControlKeyDown() ) then
		-- Unlink us from what we're stuck to
		local stick = stickiedFrames[this]
		if( stick ) then
			resetFramePosition(this)

			-- remove this frame from being connected to the frame we were
			-- stuck to
			frameLinks[stick][this] = nil

			-- no longer list us as being connected to any frames
			stickiedFrames[this] = nil
		end

		-- Unlink anything stuck to us
		for frame in pairs(frameLinks[this]) do
			-- unset the headLB for all frames connected to this one
			frame.headLB = nil

			-- remove all frames from being connected to this one
			stickiedFrames[frame] = nil
			-- restore their position
			resetFramePosition(frame)
			-- rehead the frames to themself
			reheadFrames(frame)

			frameLinks[this][frame] = nil
		end

		this.headLB = nil

	-- Stick anything in the group to us so they move with it
	elseif( stickiedFrames[this] ) then
		-- we are attached to another frame
		-- reverse stick whatever we're attached to and rehead them
		reverseStick(this)
		-- rehead all frames attached to us
		reheadFrames(this)
	end

	this:SetScript("OnUpdate", frameMoving)
end

function OnDragStop()
	if( not this.isMoving ) then
		return
	end

	LegoBlock.movingFrame = nil

	-- Hide the highlighting self once we stop dragging
	if( currentStickyFrame ) then
		hideHighlightFrame(currentStickyFrame)
		currentStickyFrame = nil
	end

	-- Restore self strata and the OnUpdate
	this.isMoving = false
	this:SetFrameStrata(frameStrata[this] or "MEDIUM")
	this:SetScript("OnUpdate", onUpdateFuncs[this])

	-- if we're stuck to something then we need to put ourselves in that list
	if( stickiedFrames[this] ) then
		local attachedTo = stickiedFrames[this]
		this.headLB = attachedTo.headLB or attachedTo

		frameLinks[attachedTo][this] = true
		reheadFrames(this, this.headLB)
	end

	-- Save our position, and the position of anything attached to us
	saveFramePositions(this)
	for frame in pairs(savingPositions) do
		savingPositions[frame] = nil
	end
end

-- START LEGO BLOCK CODE
-- Misc stuffs
local protDefaults = {
	width = 8,
	height = 24,
	bg = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 16,
		insets = {left = 5, right = 5, top = 5, bottom = 5},
		tile = true, tileSize = 16,
	},
}

local defTbl = setmetatable({}, {
	__index = function(t,k) return protDefaults[k] end,
	__newindex = function(t,k,v) end, -- Don't allow saves to the default table
})


local function resizeWindow(self)
	if( self.optionsTbl.noResize ) then
		return
	end

	-- Base frame width.
	local width = self.optionsTbl.width or defTbl.width

	-- Add backdrop width.
	if( self.optionsTbl.bg ~= false ) then
		local bg = self.optionsTbl.bg or defTbl.bg
		width = width + bg.insets.left + bg.insets.right
	end

	if( self.optionsTbl.showIcon ) then
		width = width + self.icon:GetWidth()
	end

	if( self.optionsTbl.showText ) then
		local textWidth = self.text:GetStringWidth()
		self.text:SetWidth(textWidth)
		width = width + textWidth
	end

	self:SetWidth(width)
end

function saveFramePosition(self)
	local x, y, anchor = GetPoints(self)

	self.optionsTbl.x = x
	self.optionsTbl.y = y
	self.optionsTbl.anchor = anchor
	self.optionsTbl.scale = self:GetScale()

	local _, relative =  self:GetPoint()
	if( self.stickPoint and relative and relative:GetName() ~= "UIParent" ) then
		self.optionsTbl.stickPoint = self.stickPoint
		self.optionsTbl.relative = relative:GetName()
	else
		self.optionsTbl.stickPoint = nil
		self.optionsTbl.relative = nil
	end
end

function restoreFramePosition(self)
--	if( not IsLoggedIn() ) then
--		return
--	end

	self:ClearAllPoints()

	local scale = self.optionsTbl.scale
	if( scale ) then
		self:SetScale(scale)
	else
		scale = self:GetScale()
	end

	-- This is required for relative positioning
	-- If the frame we want is loaded, position ourselves to it
	-- If it doesn't, store it for later.
	local posFrame = getglobal(self.optionsTbl.relative)
	if( not posFrame and self.optionsTbl.stickPoint ) then
		restorePositions[self] = self.optionsTbl.relative
	end

	if( self.optionsTbl.stickPoint and posFrame ) then
--		Print({self,posFrame,self.optionsTbl.stickPoint})
		local stuck = FlyPaper:StickToPoint(self, posFrame, self.optionsTbl.stickPoint)

		if( stuck ) then
			stickiedFrames[self] = posFrame
			frameLinks[posFrame][self] = true

			self.stickPoint = self.optionsTbl.stickPoint
			self.headLB = posFrame.headLB or posFrame

			-- rehead all frames currently attached to us
			reheadFrames(self, self.headLB)
		end
	else
		local x = 0
		if( self.optionsTbl.x ) then
			x = self.optionsTbl.x / scale
		end

		local y = 0
		if( self.optionsTbl.y ) then
			y = self.optionsTbl.y / scale
		end

		self:SetPoint(self.optionsTbl.anchor or "CENTER", UIParent, self.optionsTbl.anchor or "CENTER", x, y)
	end
end

-- LEGOBLOCK LIBRARY
function LegoBlock:New(name, text, icon, optionsTbl)
	
	optionsTbl = optionsTbl or defTbl
	local width = optionsTbl.width or defTbl.width
	local height = optionsTbl.height or defTbl.height
	local bg = optionsTbl.bg

	-- Nil out the given backdrop
	if( bg == false ) then
		bg = nil

	-- No backdrop provided, use default
	elseif( not bg ) then
		bg = defTbl.bg
	end

	local frame = CreateFrame("Button", "Lego" .. name, UIParent, optionsTbl.appendString)
--        Mixin(frame, BackdropTemplateMixin)
	frame:SetWidth(width)
	frame:SetHeight(height)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetClampedToScreen(true)

	frame.icon = frame:CreateTexture()
	frame.icon:SetHeight(16)
	frame.icon:SetWidth(16)
	frame.icon:SetPoint("LEFT", frame, "LEFT", 8, 0)
	

	frame.text = frame:CreateFontString(nil, nil, "GameFontNormal")
	frame.text.positionType = "none"

	frame:SetBackdrop(bg)
	frame:SetBackdropColor(0,0,0,0.3)
	frame:SetBackdropBorderColor(0,0,0,0.7)
	frame:SetScript("OnDragStart", OnDragStart)
	frame:SetScript("OnDragStop", OnDragStop)

	LegoBlock.totalLegos = LegoBlock.totalLegos + 1
	frame.legoID = LegoBlock.totalLegos
	legos[frame] = true
	frameLinks[frame] = {}

	-- Inject methods
	for _, method in pairs(methods) do
		frame[method] = LegoBlock[method]
	end

	-- Setup
	frame:SetDB(optionsTbl)

	if( text ) then
		frame.text:SetText(text)
	end

	if( icon ) then
		frame.icon:SetIcon(icon)
		
	end
	
	if optionsTbl.texcoord then
	
		frame.texcoord = optionsTbl.texcoord
	end
	
	resizeWindow(frame)

	return frame
end

-- Change text value
function LegoBlock.SetText(self, text)
	self.text:SetText(text)
	resizeWindow(self)
end

-- Show/hide the text
function LegoBlock.ShowText(self)
	self.optionsTbl.showText = true
	self.text:Show()
	resizeWindow(self)
end

function LegoBlock.HideText(self)
	self.optionsTbl.showText = false
	self.text:Hide()
	resizeWindow(self)
end

-- Sets the icon texture
function LegoBlock.SetIcon(self, icon )
	--print("Legoblock: icon: ".. icon)
	self.icon:SetTexture(icon)
	--if self.texcoord then
	--	self.icon:SetTexCoord(unpack(self.texcoord))
	--end
end

-- Show/hide the icon
function LegoBlock.ShowIcon(self)
	self.optionsTbl.showIcon = true
	self.icon:Show()

	if( self.text.positionType ~= "icon" ) then
		self.text.positionType = "icon"
		self.text:ClearAllPoints()
		self.text:SetJustifyH("LEFT")
		self.text:SetPoint("LEFT", self.icon, "RIGHT", 0, 0)
	end

	resizeWindow(self)
end

function LegoBlock.HideIcon(self)
	self.optionsTbl.showIcon = false
	self.icon:Hide()

	if( self.text.positionType ~= "text" ) then
		self.text.positionType = "text"
		self.text:ClearAllPoints()
		self.text:SetJustifyH("CENTER")
		self.text:SetPoint("CENTER", 0, 0)
	end

	resizeWindow(self)
end

function LegoBlock.SetDB(self, db)
	self.optionsTbl = db

	self:SetWidth(db.width or defTbl.width)
	self:SetHeight(db.height or defTbl.height)

	if( db.showText ) then
		self:ShowText()
	else
		self:HideText()
	end

	if( db.showIcon ) then
		self:ShowIcon()
	else
		self:HideIcon()
	end

	if( db.hidden ) then
		self:Hide()
	else
		self:Show()
	end

	resizeWindow(self)
	restoreFramePosition(self)

	if( db.savedFields ) then
		for i=1, tgetn(db.savedFields), 2 do
			if( not db.savedFields[i] ) then
				break
			end

			self[db.savedFields[i]] = db.savedFields[i + 1]
		end
	end

	-- Figure out if we need to position anyone to us
	for frame, posName in pairs(restorePositions) do
		if( posName == self:GetName() ) then
			restoreFramePosition(frame)
			restorePositions[frame] = nil
		end
	end
end

-- Upgrade if need be
-- This must be done at the end because we have to update the injected methods
-- in LegoBlock before we can update the actual blocks with the new functions
for lframe in pairs(legos) do
	-- Update the dragging functions
	lframe:SetScript("OnDragStart", OnDragStart)
	lframe:SetScript("OnDragStop", OnDragStop)

	-- Now update the injected methods
	for _, method in pairs(methods) do
		lframe[method] = LegoBlock[method]
	end
end

-- uncomment for debugging
--LB = LegoBlock
