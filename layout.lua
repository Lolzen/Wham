--[[===================
===		Layout		===
===================]]--
-- Here you can modify the look of the data display
--[[ Available values:
>>Config<<
*ns.cfdGather
*ns.solo_hide
*ns.width
*ns.height

>>Core<<
*ns.wham
*ns.combatStartTime
*ns.combatTotalTime
*ns.watched
*ns.pos
*ns.owners

>>Current Fight Data<<
*ns.curframe
*ns.curTotaldmg
*ns.curData

>>Damage Data<<
ns.totaldmg
ns.dmgData

>>Heal Data<<
ns.healFrame
ns.totalheal
ns.healData

>>Absorb Data<<
ns.absorbFrame
ns.totalabsorb
ns.absorbData

>>Layout<<
ns.wham:UpdateLayout()
This is the function to update everything like texts, values or statusbars
Just put everything that needs to be uptated in there, look below for an example
do not remove this or you will have errors
]]

local addon, ns = ...

-- Wham is movable ;>
ns.wham:EnableMouse(true)
ns.wham:SetMovable(true)
ns.wham:SetUserPlaced(true)

ns.wham:SetScript("OnMouseDown", function()
	if IsAltKeyDown() then
		ns.wham:ClearAllPoints()
		ns.wham:StartMoving()
	end
end)

ns.wham:SetScript("OnMouseUp", function()
	ns.wham:StopMovingOrSizing()
end)

-- Background
ns.bg = ns.wham:CreateTexture("Background")
ns.bg:SetTexture(0, 0, 0, 0.5)
ns.bg:SetAllPoints(ns.wham)
ns.bg:SetAlpha(0)

-- Border
ns.border = CreateFrame("Frame", nil, ns.wham)
ns.border:SetBackdrop({
	edgeFile = "Interface\\AddOns\\Wham\\Textures\\border3", edgeSize = 8,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
})
ns.border:SetPoint("TOPLEFT", ns.bg, -2, 1)
ns.border:SetPoint("BOTTOMRIGHT", ns.bg, 2, -1)
ns.border:SetBackdropBorderColor(0.2, 0.2, 0.2)
ns.border:SetAlpha(0)

--[[===================
===		Buttons		===
===================]]--
-- ResetButton
ns.resetbutton = CreateFrame("Button", "ResetButton", ns.wham)
ns.resetbutton:SetPoint("BOTTOMRIGHT", ns.wham, 4, 0)
ns.resetbutton:SetHeight(36)
ns.resetbutton:SetWidth(36)
ns.resetbutton:SetNormalTexture("Interface\\Buttons\\CancelButton-Up") 
ns.resetbutton:SetPushedTexture("Interface\\Buttons\\CancelButton-Down")
ns.resetbutton:SetHighlightTexture("Interface\\Buttons\\CancelButton-Highlight")

-- Kill all data
ns.resetbutton:SetScript("OnClick", function(self)
	if ns.dmgData then
		ns.dmgData = {}
	end
	if ns.healData then
		ns.healData = {}
	end
	if ns.combatTotalTime then
		ns.combatTotalTime = 0
	end
	for i=1, 5, 1 do
		ns.sbdmg[i]:SetValue(0)
		ns.sbdmg[i].bg:Hide()
		ns.sbheal[i]:SetValue(0)
		ns.sbheal[i].bg:Hide()
		ns.sbabsorb[i]:SetValue(0)
		ns.sbabsorb[i].bg:Hide()
		ns.f[i].string1:SetText(nil)
		ns.f[i].string2:SetText(nil)
		ns.f[i].border:Hide()
		ns.f[i].bg:Hide()
	end
	ns.resetbutton:SetAlpha(0)
	ns.bg:SetAlpha(0)
	ns.border:SetAlpha(0)
end)

--[[=======================
===		Statusbars		===
=======================]]--
ns.sbdmg = {}
ns.sbheal = {}
ns.sbabsorb = {}
ns.dps = {}
ns.hps = {}
ns.f = {}

for i=1, 5, 1 do
	-- Create the frame all other bars will be attached to
	ns.f[i] = CreateFrame("Frame", nil, ns.wham)
	ns.f[i]:SetHeight(14)
	ns.f[i]:SetWidth(ns.wham:GetWidth() -8)
	
	-- Border
	if not ns.f[i].border then
		ns.f[i].border = CreateFrame("Frame", nil, ns.f[i])
		ns.f[i].border:SetBackdrop({
			edgeFile = "Interface\\AddOns\\Wham\\Textures\\border3", edgeSize = 8,
			insets = {left = 4, right = 4, top = 4, bottom = 4},
		})
		ns.f[i].border:SetPoint("TOPLEFT", ns.f[i], -2, 1)
		ns.f[i].border:SetPoint("BOTTOMRIGHT", ns.f[i], 2, -1)
		ns.f[i].border:SetBackdropBorderColor(0.2, 0.2, 0.2)
	end
	
	-- background
	if not ns.f[i].bg then
		ns.f[i].bg = ns.f[i]:CreateTexture(nil, "BACKGROUND")
		ns.f[i].bg:SetAllPoints(ns.f[i])
		ns.f[i].bg:SetTexture("Interface\\AddOns\\Wham\\Textures\\statusbar")
		ns.f[i].bg:SetVertexColor(0, 0, 0)
	end
	
	-- Create the dmgStatusBars
	ns.sbdmg[i] = CreateFrame("StatusBar", "dmgStatusBar"..i, ns.wham)
	ns.sbdmg[i]:SetHeight(8)
	ns.sbdmg[i]:SetWidth(ns.wham:GetWidth() -8)
	ns.sbdmg[i]:SetStatusBarTexture("Interface\\AddOns\\Wham\\Textures\\statusbar")
	ns.sbdmg[i]:SetStatusBarColor(0.8, 0, 0)
	
	-- dmgStatusBars background
	if not ns.sbdmg[i].bg then
		ns.sbdmg[i].bg = ns.sbdmg[i]:CreateTexture(nil, "BACKGROUND")
		ns.sbdmg[i].bg:SetAllPoints(ns.sbdmg[i])
		ns.sbdmg[i].bg:SetTexture("Interface\\AddOns\\Wham\\Textures\\statusbar")
		ns.sbdmg[i].bg:SetVertexColor(0.4, 0, 0)
	end
	
	-- Create the healStatusBars
	ns.sbheal[i] = CreateFrame("StatusBar", "healStatusBar"..i, ns.wham)
	ns.sbheal[i]:SetHeight(3)
	ns.sbheal[i]:SetWidth(ns.wham:GetWidth() -8)
	ns.sbheal[i]:SetStatusBarTexture("Interface\\AddOns\\Wham\\Textures\\statusbar")
	ns.sbheal[i]:SetStatusBarColor(0, 0.8, 0.2)
	
	if not ns.sbheal[i].bg then
		ns.sbheal[i].bg = ns.sbheal[i]:CreateTexture(nil, "BACKGROUND")
		ns.sbheal[i].bg:SetAllPoints(ns.sbheal[i])
		ns.sbheal[i].bg:SetTexture("Interface\\AddOns\\Wham\\Textures\\statusbar")
		ns.sbheal[i].bg:SetVertexColor(0, 0.4, 0.1)
	end
	
	-- Create the absorbStatusBars
	ns.sbabsorb[i] = CreateFrame("StatusBar", "absorbStatusBar"..i, ns.wham)
	ns.sbabsorb[i]:SetHeight(3)
	ns.sbabsorb[i]:SetWidth(ns.wham:GetWidth() -8)
	ns.sbabsorb[i]:SetStatusBarTexture("Interface\\AddOns\\Wham\\Textures\\statusbar")
	ns.sbabsorb[i]:SetStatusBarColor(1, 1, 0)
	
	if not ns.sbabsorb[i].bg then
		ns.sbabsorb[i].bg = ns.sbabsorb[i]:CreateTexture(nil, "BACKGROUND")
		ns.sbabsorb[i].bg:SetAllPoints(ns.sbabsorb[i])
		ns.sbabsorb[i].bg:SetTexture("Interface\\AddOns\\Wham\\Textures\\statusbar")
		ns.sbabsorb[i].bg:SetVertexColor(0.5, 0.5, 0)
	end
	
	-- Create the FontStrings
	if not ns.f[i].string1 then
		-- #. Name dps hps
		ns.f[i].string1 = ns.f[i]:CreateFontString(nil, "OVERLAY")
		ns.f[i].string1:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		ns.f[i].string1:SetPoint("TOPLEFT", ns.f[i], "TOPLEFT", 2, 11)
	end
	if not ns.f[i].string2 then
		-- absorb/heal/dmg
		ns.f[i].string2 = ns.f[i]:CreateFontString(nil, "OVERLAY")
		ns.f[i].string2:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		ns.f[i].string2:SetPoint("TOPRIGHT", ns.f[i], "TOPRIGHT", -2, 11)
	end
end

function ns.wham:UpdateStatusBars()
	for i=1, 5, 1 do
		if i == 1 then
			ns.f[i]:SetPoint("TOPLEFT", ns.wham, 4, -15)
			-- Current Fight
			if ns.curData[ns.pos[i]] and ns.curTotaldmg > 0 and ns.cfdGather == true then
				ns.sbdmg[i]:SetAlpha(1)
				ns.sbdmg[i]:SetMinMaxValues(0, ns.curData[ns.pos[1]] or 0)
				ns.sbdmg[i]:SetPoint("BOTTOMLEFT", ns.f[i], 0, 0)
				ns.sbdmg[i]:SetValue(ns.curData[ns.pos[i]] or 0)
			else
				-- Dmg	
				if ns.dmgData[ns.pos[i]] and ns.totaldmg > 0 then	
					ns.sbdmg[i]:SetAlpha(1)
					ns.sbdmg[i]:SetMinMaxValues(0, ns.dmgData[ns.pos[1]] or 0)
					ns.sbdmg[i]:SetPoint("BOTTOMLEFT", ns.f[i], 0, 0)
					ns.sbdmg[i]:SetValue(ns.dmgData[ns.pos[i]] or 0)
				else
					ns.sbdmg[i]:SetAlpha(0)
				end
			end
			-- Heal
			if ns.healData[ns.pos[i]] and ns.totalheal > 0 then
				ns.sbheal[i]:SetAlpha(1)
				ns.sbheal[i]:SetMinMaxValues(0, ns.healData[ns.pos[1]] or 0)
				ns.sbheal[i]:SetPoint("TOPLEFT", ns.f[i], 0, -3)
				ns.sbheal[i]:SetValue(ns.healData[ns.pos[i]] or 0)
			else
				ns.sbheal[i]:SetAlpha(0)
			end
			-- Absorb
			if ns.absorbData[ns.pos[i]] and ns.totalabsorb > 0 then
				ns.sbabsorb[i]:SetAlpha(1)
				ns.sbabsorb[i]:SetMinMaxValues(0, ns.absorbData[ns.pos[1]] or 0)
				ns.sbabsorb[i]:SetPoint("TOPLEFT", ns.f[i], 0, 0)
				ns.sbabsorb[i]:SetValue(ns.absorbData[ns.pos[i]] or 0)
			else
				ns.sbabsorb[i]:SetAlpha(0)
			end
		else
			ns.f[i]:SetPoint("TOP", ns.f[i-1], "BOTTOM", 0, -15)
			-- Current Fight
			if ns.curData[ns.pos[i]] and ns.cfdGather == true then
				ns.sbdmg[i]:SetAlpha(1)
				ns.sbdmg[i]:SetMinMaxValues(0, ns.curData[ns.pos[1]] or 0)
				ns.sbdmg[i]:SetPoint("BOTTOMLEFT", ns.f[i], 0, 0)
				ns.sbdmg[i]:SetValue(ns.curData[ns.pos[i]] or 0)
			else
				-- Dmg
				if ns.dmgData[ns.pos[i]] then
					ns.sbdmg[i]:SetAlpha(1)
					ns.sbdmg[i]:SetMinMaxValues(0, ns.dmgData[ns.pos[1]] or 0)
					ns.sbdmg[i]:SetPoint("BOTTOMLEFT", ns.f[i], 0, 0)
					ns.sbdmg[i]:SetValue(ns.dmgData[ns.pos[i]] or 0)
				else
					ns.sbdmg[i]:SetAlpha(0)
				end
			end
			-- Heal
			if ns.healData[ns.pos[i]] then
				ns.sbdmg[i]:SetAlpha(1)
				ns.sbheal[i]:SetMinMaxValues(0, ns.healData[ns.pos[1]] or 0)
				ns.sbheal[i]:SetPoint("TOPLEFT", ns.f[i], 0, -3)
				ns.sbheal[i]:SetValue(ns.healData[ns.pos[1]] or 0)
			else
				ns.sbheal[i]:SetAlpha(0)
			end
			-- Absorb
			if ns.absorbData[ns.pos[i]] then
				ns.sbabsorb[i]:SetAlpha(1)
				ns.sbabsorb[i]:SetMinMaxValues(0, ns.absorbData[ns.pos[1]] or 0)
				ns.sbabsorb[i]:SetPoint("TOPLEFT", ns.f[i], 0, 0)
				ns.sbabsorb[i]:SetValue(ns.absorbData[ns.pos[i]] or 0)
			else
				ns.sbabsorb[i]:SetAlpha(0)
			end
		end

		-- Strings
		if ns.curData[ns.pos[i]] and ns.curTotaldmg > 0 and ns.cfdGather == true then
			local rcColor = RAID_CLASS_COLORS[select(2,UnitClass(ns.pos[i]))]
			local curdamage = ns.curData[ns.pos[i]] or 0
			local heal = ns.healData[ns.pos[i]] or 0
			local absorb = ns.absorbData[ns.pos[i]] or 0
			local combatTime = ns.combatTotalTime + (ns.combatStartTime and (GetTime() - ns.combatStartTime) or 0)
			ns.f[i].string2:SetFormattedText("|cffffff00%d (%.0f%%)|r |cff00ff22%d (%.0f%%)|r |cffff0000%d (%.0f%%)|r", absorb, absorb / ns.totalabsorb * 100, heal, heal / ns.totalheal * 100, curdamage, curdamage / ns.curTotaldmg * 100)
			if ns.dmgData[ns.pos[i]] and ns.healData[ns.pos[i]] and combatTime > 0 then
				ns.f[i].string1:SetFormattedText("%d.  |cff%02x%02x%02x%s|r |cffff0000%d|r |cff00ff00%d|r", i, rcColor.r*255, rcColor.g*255, rcColor.b*255, ns.pos[i], ns.dmgData[ns.pos[i]]/combatTime, ns.healData[ns.pos[i]]/combatTime)
			elseif ns.healData[ns.pos[i]] then
				ns.f[i].string1:SetFormattedText("%d.  |cff%02x%02x%02x%s|r |cff00ff00%d|r", i, rcColor.r*255, rcColor.g*255, rcColor.b*255, ns.pos[i], ns.healData[ns.pos[i]]/combatTime)
			else
				ns.f[i].string1:SetFormattedText("%d.  |cff%02x%02x%02x%s|r |cffff0000%d|r", i, rcColor.r*255, rcColor.g*255, rcColor.b*255, ns.pos[i], ns.dmgData[ns.pos[i]]/combatTime)
			end
			ns.f[i].border:Show()
			ns.f[i].bg:Show()
		else
			if ns.dmgData[ns.pos[i]] and ns.totaldmg > 0 or ns.healData[ns.pos[i]] and ns.totalheal > 0 or ns.absorbData[ns.pos[i]] and ns.totalabsorb > 0 then
				local rcColor = RAID_CLASS_COLORS[select(2,UnitClass(ns.pos[i]))]
				local damage = ns.dmgData[ns.pos[i]] or 0
				local heal = ns.healData[ns.pos[i]] or 0
				local absorb = ns.absorbData[ns.pos[i]] or 0
				local combatTime = ns.combatTotalTime + (ns.combatStartTime and (GetTime() - ns.combatStartTime) or 0)
				ns.f[i].string2:SetFormattedText("|cffffff00%d (%.0f%%)|r |cff00ff22%d (%.0f%%)|r |cffff0000%d (%.0f%%)|r", absorb, absorb / ns.totalabsorb * 100, heal, heal / ns.totalheal * 100, damage, damage / ns.totaldmg * 100)
				if ns.dmgData[ns.pos[i]] and ns.healData[ns.pos[i]] and combatTime > 0 then
					ns.f[i].string1:SetFormattedText("%d.  |cff%02x%02x%02x%s|r |cffff0000%d|r |cff00ff00%d|r", i, rcColor.r*255, rcColor.g*255, rcColor.b*255, ns.pos[i], ns.dmgData[ns.pos[i]]/combatTime, ns.healData[ns.pos[i]]/combatTime)
				elseif ns.healData[ns.pos[i]] then
					ns.f[i].string1:SetFormattedText("%d.  |cff%02x%02x%02x%s|r |cff00ff00%d|r", i, rcColor.r*255, rcColor.g*255, rcColor.b*255, ns.pos[i], ns.healData[ns.pos[i]]/combatTime)
				else
					ns.f[i].string1:SetFormattedText("%d.  |cff%02x%02x%02x%s|r |cffff0000%d|r", i, rcColor.r*255, rcColor.g*255, rcColor.b*255, ns.pos[i], ns.dmgData[ns.pos[i]]/combatTime)
				end
				ns.f[i].border:Show()
				ns.f[i].bg:Show()
			else
				ns.f[i].string1:SetText(nil)
				ns.f[i].string2:SetText(nil)
				ns.f[i].border:Hide()
				ns.f[i].bg:Hide()
			end
		end
	end
end

function ns.wham:UpdateLayout()
	-- Sort names by damage
	sort(ns.pos, ns.sortByDamage)
	
	for i=1, 5 do
		if ns.dmgData[ns.pos[i]] or ns.healData[ns.pos[i]] or ns.absorbData[ns.pos[i]] then
			ns.bg:SetAlpha(1)
			ns.border:SetAlpha(1)
			ns.resetbutton:SetAlpha(1)
		end
	end
	ns.wham:UpdateStatusBars()
end