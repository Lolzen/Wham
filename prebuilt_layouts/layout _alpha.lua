--[[===================
===		Layout		===
===================]]--
--#######Alpha#######--
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
ns.totalheal
ns.totalabsorb
ns.healData
ns.absorbData
]]

local addon, ns = ...

ns.sb = {}

ns.wham:EnableMouse(true)
ns.wham:SetMovable(true)
ns.wham:SetUserPlaced(true)


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
ns.resetbutton:SetPoint("TOPRIGHT", ns.wham, 4, 4)
ns.resetbutton:SetHeight(36)
ns.resetbutton:SetWidth(36)
ns.resetbutton:SetNormalTexture("Interface\\Buttons\\CancelButton-Up") 
ns.resetbutton:SetPushedTexture("Interface\\Buttons\\CancelButton-Down")
ns.resetbutton:SetHighlightTexture("Interface\\Buttons\\CancelButton-Highlight")
ns.resetbutton:SetAlpha(0)

-- CurrentFightDataButton
ns.cfdButton = CreateFrame("Button", "resetButton", ns.wham)
ns.cfdButton:SetPoint("TOPRIGHT", ns.wham, -16, 4)
ns.cfdButton:SetSize(36, 36)
ns.cfdButton:SetNormalTexture("Interface\\Buttons\\CancelButton-Up") 
ns.cfdButton:SetPushedTexture("Interface\\Buttons\\CancelButton-Down")
ns.cfdButton:SetHighlightTexture("Interface\\Buttons\\CancelButton-Highlight")
ns.cfdButton:SetAlpha(0)

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
		ns.sb[i]:SetValue(0)
		ns.sb[i].sbtext:SetText(nil)
		ns.sb[i].sbtext2:SetText(nil)
		ns.sb[i].border:Hide()
		ns.sb[i].bg:Hide()
	end
	ns.dps:SetText(nil) 
	ns.resetbutton:SetAlpha(0)
	ns.cfdButton:SetAlpha(0)
	ns.bg:SetAlpha(0)
	ns.border:SetAlpha(0)
end)

-- de/activate "Current Fight Data Mode"
ns.cfdButton:SetScript("OnClick", function(self)
	if ns.cfdGather == false then
		ns.cfdGather = true
		print("Activated Current Fight Data Mode")
	elseif ns.cfdGather == true then
		ns.cfdGather = false
		print("DeactivatedCurrent Fight Data Mode")
	end
end)

--[[=======================
===		FontStrings		===
=======================]]--
-- Shows your dps
ns.dps = ns.wham:CreateFontString(nil, "OVERLAY")
ns.dps:SetPoint("TOPLEFT", ns.wham, 4, -4)
ns.dps:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")

-- Shows Healammount (in percent)
--local heal = wham:CreateFontString(nil, "OVERLAY")
--heal:SetPoint("LEFT", dps, "RIGHT", 0, 0)
--heal:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

--[[=======================
===		StatusBars  	===
=======================]]--

for i=1, 5, 1 do
	-- Create the StatusBars
	ns.sb[i] = CreateFrame("StatusBar", "StatusBar"..i, ns.wham)
	ns.sb[i]:SetHeight(14)
	ns.sb[i]:SetWidth(ns.wham:GetWidth() -8)
	ns.sb[i]:SetStatusBarTexture("Interface\\AddOns\\Wham\\Textures\\statusbar")
	ns.sb[i]:SetAlpha(0.6)
	
	-- StatusbarBorder
	if not ns.sb[i].border then
		ns.sb[i].border = CreateFrame("Frame", nil, ns.sb[i])
		ns.sb[i].border:SetBackdrop({
			edgeFile = "Interface\\AddOns\\Wham\\Textures\\border3", edgeSize = 8,
			insets = {left = 4, right = 4, top = 4, bottom = 4},
		})
		ns.sb[i].border:SetPoint("TOPLEFT", ns.sb[i], -2, 1)
		ns.sb[i].border:SetPoint("BOTTOMRIGHT", ns.sb[i], 2, -1)
		ns.sb[i].border:SetBackdropBorderColor(0.2, 0.2, 0.2)
	end
	
	-- background
	if not ns.sb[i].bg then
		ns.sb[i].bg = ns.sb[i]:CreateTexture(nil, "BACKGROUND")
		ns.sb[i].bg:SetAllPoints(ns.sb[i])
		ns.sb[i].bg:SetTexture("Interface\\AddOns\\Wham\\Textures\\statusbar")
		ns.sb[i].bg:SetVertexColor(0, 0, 0)
	end

	-- Create the FontStrings
	if not ns.sb[i].sbtext then
		-- Damage on the StatusBar
		ns.sb[i].sbtext = ns.sb[i]:CreateFontString(nil, "OVERLAY")
		ns.sb[i].sbtext:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		ns.sb[i].sbtext:SetTextColor(1,1,1)
		ns.sb[i].sbtext:SetPoint("TOPRIGHT", ns.sb[i], "TOPRIGHT", 0, -2)
	
		-- Name on the StausBar
		ns.sb[i].sbtext2 = ns.sb[i]:CreateFontString(nil, "OVERLAY")
		ns.sb[i].sbtext2:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		ns.sb[i].sbtext2:SetTextColor(1,1,1)
		ns.sb[i].sbtext2:SetPoint("TOPLEFT", ns.sb[i], "TOPLEFT", 2, -2)
	end
end

function ns.wham:UpdateStatusBars()
	for i=1, 5, 1 do
		if i == 1 then
			if ns.curData[ns.pos[i]] then
				ns.sb[i]:SetMinMaxValues(0, ns.curData[ns.pos[1]] or 0)
				ns.sb[i]:SetPoint("BOTTOMLEFT", ns.dps, 0, -15)
				ns.sb[i]:SetValue(ns.curData[ns.pos[1]] or 0)
			else
				if ns.dmgData[ns.pos[i]] then
					ns.sb[i]:SetMinMaxValues(0, ns.dmgData[ns.pos[1]] or 0)
					ns.sb[i]:SetPoint("BOTTOMLEFT", ns.dps, 0, -15)
					ns.sb[i]:SetValue(ns.dmgData[ns.pos[1]] or 0)
				end
			end
		else
			if ns.curData[ns.pos[i]] then
				ns.sb[i]:SetMinMaxValues(0, ns.curData[ns.pos[1]] or 0)
				ns.sb[i]:SetPoint("BOTTOM", ns.sb[i-1], "BOTTOM", 0, -15)
				ns.sb[i]:SetValue(ns.curData[ns.pos[i]] or 0)
			else
				if ns.dmgData[ns.pos[i]] then
					ns.sb[i]:SetMinMaxValues(0, ns.dmgData[ns.pos[1]] or 0)
					ns.sb[i]:SetPoint("BOTTOM", ns.sb[i-1], "BOTTOM", 0, -15)
					ns.sb[i]:SetValue(ns.dmgData[ns.pos[i]] or 0)
				end
			end
		end
		
		-- Set the texts: name & values
		if ns.cfdGather == true and ns.curData[ns.pos[i]] then
			local damage = ns.curData[ns.pos[i]]
			ns.sb[i].sbtext:SetFormattedText("%d (%.0f%%)", damage, damage / ns.curTotaldmg * 100)
			ns.sb[i].sbtext2:SetText(i..".    "..ns.pos[i])
			ns.sb[i].border:Show()
			ns.sb[i].bg:Show()
		else
			if ns.dmgData[ns.pos[i]] then 
				local damage = ns.dmgData[ns.pos[i]]
				ns.sb[i].sbtext:SetFormattedText("%d (%.0f%%)", damage, damage / ns.totaldmg * 100)
				ns.sb[i].sbtext2:SetText(i..".    "..ns.pos[i])
				ns.sb[i].border:Show()
				ns.sb[i].bg:Show()
			else
				ns.sb[i].sbtext:SetText(nil)
				ns.sb[i].sbtext2:SetText(nil)
				ns.sb[i].border:Hide()
				ns.sb[i].bg:Hide()
			end
		end

		-- ClassColoring the StatusBars for players
		if ns.curData[ns.pos[i]] then
			local sbColor = RAID_CLASS_COLORS[select(2,UnitClass(ns.pos[i]))]
				ns.sb[i]:SetStatusBarColor(sbColor.r, sbColor.g, sbColor.b)
		else
			if ns.dmgData[ns.pos[i]] then
				local sbColor = RAID_CLASS_COLORS[select(2,UnitClass(ns.pos[i]))]
				ns.sb[i]:SetStatusBarColor(sbColor.r, sbColor.g, sbColor.b)
			end
		end
	end
end

function ns.wham:UpdateText()
	-- Sort names by damage
	sort(ns.pos, ns.sortByDamage)
	
	local playerName = UnitName("player")
	local combatTime = ns.combatTotalTime + (ns.combatStartTime and (GetTime() - ns.combatStartTime) or 0)
	local curCombatTime = (ns.combatStartTime and (GetTime() - ns.combatStartTime) or 0)
	
--	if healData[playerName] then
--		heal:SetFormattedText("Hps: |cff0066ff%d|r", healData[playerName]/combatTime)
--	end
	if ns.cfdGather == true and ns.curData[playerName] then
		ns.dps:SetFormattedText("Dps: |cffffdd00%d|r", ns.curData[playerName]/curCombatTime)
		--sort(ns.pos, ns.sortByDamage)
	else
		if ns.dmgData[playerName] then
			ns.dps:SetFormattedText("Dps: |cff00ffff%d|r", ns.dmgData[playerName]/combatTime)
			--sort(ns.pos, ns.sortByDamage)
		end
	end
	
	for i=1, 5, 1 do
		if ns.cfdGather and ns.curData[ns.pos[i]] or ns.dmgData[ns.pos[i]] then
			ns.resetbutton:SetAlpha(0.8)
			ns.cfdButton:SetAlpha(0.5)
			ns.bg:SetAlpha(1)
			ns.border:SetAlpha(1)
		end
	end
end