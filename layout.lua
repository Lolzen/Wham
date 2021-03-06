--[[===========================
===		Layout (Tabbed)		===
===========================]]--
-- Sample layout: basic tabbed layout

local addon, ns = ...

ns.wham:EnableMouse(true)
ns.wham:SetMovable(true)
ns.wham:SetUserPlaced(true)

-- Script for moving the frame and resetting data
ns.wham:SetScript("OnMouseDown", function(self, button)
	if IsAltKeyDown() then
		ns.wham:ClearAllPoints()
		ns.wham:StartMoving()
	end
	if IsShiftKeyDown() then
		if button == "LeftButton" then
			ns.resetData()
			print("Data has been resetted.")
		elseif button == "RightButton" then
			if IsInGroup("player") then
				local channel = IsInRaid("player") and "RAID" or "PARTY"
				SendAddonMessage("Wham_RESET", nil, channel)
			end
		end
	end
end)

ns.wham:SetScript("OnMouseUp", function()
	ns.wham:StopMovingOrSizing()
end)

-- Script for fake-scrolling
ns.viewrange = 1
ns.wham:SetScript("OnMouseWheel", function(self, direction)
	if IsAltKeyDown() then
		if direction == 1 then -- "up"
			if ns.viewrange > 1 then
				ns.viewrange = ns.viewrange - 1
			end
		elseif direction == -1 then -- "down"
			if ns.viewrange < 20 then
				ns.viewrange = ns.viewrange + 1
			end
		end
		ns.wham:UpdateLayout()
	end
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

-- Initialize tabs for switching modes
ns.activeMode = ns.initMode --activate mode chosen in config first

-- Modes available, used as tokens for creating our tabs
ns.modes = {
	"Damage",
	"Heal",
	"OverHeal",
	"Absorb",
	"Damage Taken",
	"Deaths",
	"Dispels",
	"Interrupts",
}

-- Create some clickable tabs
ns.tabs = {}
for k, v in pairs(ns.modes) do
	-- Create the Tabs
	if not ns.tabs[k] then
		ns.tabs[k] = CreateFrame("Frame", v.."-Tab", ns.wham)
		if k == 1 then
			ns.tabs[k]:SetPoint("TOPRIGHT", ns.wham, "TOPLEFT", -4, -1)
		else
			ns.tabs[k]:SetPoint("TOP", ns.tabs[k-1], "BOTTOM", 0, -3)
		end
		ns.tabs[k]:SetSize(80, 12)
		ns.tabs[k]:SetAlpha(0.4)
	end
	-- Backgrond
	if not ns.tabs[k].bg then
		ns.tabs[k].bg = ns.tabs[k]:CreateTexture("Background")
		ns.tabs[k].bg:SetAllPoints(ns.tabs[k])
	end
	-- Labels
	if not ns.tabs[k].label then
		ns.tabs[k].label = ns.tabs[k]:CreateFontString(nil, "OVERLAY")
		ns.tabs[k].label:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		ns.tabs[k].label:SetPoint("CENTER", ns.tabs[k], "CENTER", 0, 0)
		if ns.activatedModules[v] == true then
			ns.tabs[k].label:SetFormattedText("%s", v)
		else
			ns.tabs[k].label:SetFormattedText("|cff550000%s|r", v)
		end
	end
	-- Border
	if not ns.tabs[k].border then
		ns.tabs[k].border = CreateFrame("Frame", nil, ns.wham)
		ns.tabs[k].border:SetBackdrop({
			edgeFile = "Interface\\AddOns\\Wham\\Textures\\border3", edgeSize = 8,
			insets = {left = 4, right = 4, top = 4, bottom = 4},
		})
		ns.tabs[k].border:SetBackdropBorderColor(0.2, 0.2, 0.2)
		ns.tabs[k].border:SetPoint("TOPLEFT", ns.tabs[k], -2, 1)
		ns.tabs[k].border:SetPoint("BOTTOMRIGHT", ns.tabs[k], 2, -1)
		ns.tabs[k].border:SetAlpha(1)
	end
	-- clickscript for switching
	ns.tabs[k]:SetScript("OnMouseDown", function(self, button)
		if ns.activatedModules[v] == true then
			ns.switchMode(v)
			ns.wham:UpdateLayout()
		else
			print("Module for "..v.." deactivated. Check your config.lua")
		end
	end)
end

-- Handle the Statusbars
ns.sb = {}

for i=1, 25, 1 do
	-- Create the StatusBars
	if not ns.sb[i] then
		ns.sb[i] = CreateFrame("StatusBar", "StatusBar"..i, ns.wham)
		ns.sb[i]:SetHeight(15)
		ns.sb[i]:SetWidth(ns.wham:GetWidth() -8)
		ns.sb[i]:SetStatusBarTexture("Interface\\AddOns\\Wham\\Textures\\statusbar")
		if i == 1 then
			ns.sb[i]:SetPoint("TOPLEFT", ns.wham, 4, -4)
		elseif i >= 1 and i <= 5 then
			ns.sb[i]:SetPoint("TOP", ns.sb[i-1], "BOTTOM", 0, -2)
		end
	end
	
		-- Border
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

	-- StatusBars background
	if not ns.sb[i].bg then
		ns.sb[i].bg = ns.sb[i]:CreateTexture(nil, "BACKGROUND")
		ns.sb[i].bg:SetAllPoints(ns.sb[i])
		ns.sb[i].bg:SetTexture("Interface\\AddOns\\Wham\\Textures\\statusbar")
		ns.sb[i].bg:SetVertexColor(0.3, 0.3, 0.3)
	end

	-- Create the FontStrings
	if not ns.sb[i].string1 then
		-- #. Name
		ns.sb[i].string1 = ns.sb[i]:CreateFontString(nil, "OVERLAY")
		ns.sb[i].string1:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		ns.sb[i].string1:SetPoint("TOPLEFT", ns.sb[i], "TOPLEFT", 2, -2)
	end
	if not ns.sb[i].string2 then
		-- mode (mode%)
		ns.sb[i].string2 = ns.sb[i]:CreateFontString(nil, "OVERLAY")
		ns.sb[i].string2:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		ns.sb[i].string2:SetPoint("TOPRIGHT", ns.sb[i], "TOPRIGHT", -2, -2)
	end
end

function ns.wham:UpdateDisplay()
	for i=1, 5, 1 do
		if i == 1 then
			if ns.modeData[ns.guidDB.rank[ns.viewrange]] and ns.modeTotal > 0 then
				--Statusbars
				if ns.sb[i]:GetAlpha() == 0 then
					ns.sb[i]:SetAlpha(1)
				end
				ns.sb[i]:SetMinMaxValues(0, ns.modeData[ns.guidDB.rank[1]] or 0)
				ns.sb[i]:SetValue(ns.modeData[ns.guidDB.rank[ns.viewrange]] or 0)
				-- Strings
				local rcColor
				for _, guid in pairs(ns.guidDB.players) do
					rcColor = guid.classcolor or {r = 0.3, g = 0.3, b = 0.3}
				end
				local curModeVal = ns.modeData[ns.guidDB.rank[ns.viewrange]] or 0
				ns.sb[i].string2:SetFormattedText("%d (%.0f%%)", curModeVal, curModeVal / ns.modeTotal * 100)
				ns.sb[i].string1:SetFormattedText("%d.  |cff%02x%02x%02x%s|r", ns.viewrange, rcColor.r*255, rcColor.g*255, rcColor.b*255, ns.guidDB.rank[ns.viewrange])
				ns.sb[i].border:Show()
				ns.sb[i].bg:Show()
			else
				if ns.sb[i]:GetAlpha() == 1 then
					ns.sb[i]:SetAlpha(0)
				end
				ns.sb[i].string1:SetText(nil)
				ns.sb[i].string2:SetText(nil)
				ns.sb[i].border:Hide()
				ns.sb[i].bg:Hide()
			end
		else
			if ns.modeData[ns.guidDB.rank[ns.viewrange + i - 1]] and ns.modeTotal > 0 then
				-- Statusbars
				if ns.sb[i]:GetAlpha() == 0 then
					ns.sb[i]:SetAlpha(1)
				end
				ns.sb[i]:SetMinMaxValues(0, ns.modeData[ns.guidDB.rank[1]] or 0)
				ns.sb[i]:SetValue(ns.modeData[ns.guidDB.rank[ns.viewrange + i - 1]] or 0)
				-- Strings
				local rcColor 
				for _, guid in pairs(ns.guidDB.players) do
					rcColor = guid.classcolor  or {r = 0.3, g = 0.3, b = 0.3}
				end
				local curModeVal = ns.modeData[ns.guidDB.rank[ns.viewrange + i - 1]] or 0
				ns.sb[i].string2:SetFormattedText("%d (%.0f%%)", curModeVal, curModeVal / ns.modeTotal * 100)
				ns.sb[i].string1:SetFormattedText("%d.  |cff%02x%02x%02x%s|r", ns.viewrange + i - 1, rcColor.r*255, rcColor.g*255, rcColor.b*255, ns.guidDB.rank[ns.viewrange + i - 1])
				ns.sb[i].border:Show()
				ns.sb[i].bg:Show()
			else
				if ns.sb[i]:GetAlpha() == 1 then
					ns.sb[i]:SetAlpha(0)
				end
				ns.sb[i].string1:SetText(nil)
				ns.sb[i].string2:SetText(nil)
				ns.sb[i].border:Hide()
				ns.sb[i].bg:Hide()
			end
		end
	end
end

--###Functions called by core###--

function ns.layoutSpecificReset()
	for i=1, 25, 1 do
		ns.sb[i]:SetValue(0)
		ns.sb[i].bg:Hide()
		ns.sb[i].string1:SetText(nil)
		ns.sb[i].string2:SetText(nil)
		ns.sb[i].border:Hide()
		ns.sb[i].bg:Hide()
	end
	ns.bg:SetAlpha(0)
	ns.border:SetAlpha(0)
end

function ns.switchModeEvent()
	for k, v in pairs(ns.modes) do
		if v == ns.activeMode then
			ns.tabs[k].bg:SetTexture(0.5, 0, 0, 0.5)
		else
			ns.tabs[k].bg:SetTexture(0, 0, 0, 0.5)
		end
	end
	
	-- Sort Statusbars by mode, so they aren't getting displayed funny
	if ns.activeMode == "Damage" then
		sort(ns.guidDB.rank, ns.sortByDamage)
	elseif ns.activeMode == "Damage Taken" then
		sort(ns.guidDB.rank, ns.sortByDamageTaken)
	elseif ns.activeMode == "Heal" then
		sort(ns.guidDB.rank, ns.sortByHeal)
	elseif ns.activeMode == "OverHeal" then
		sort(ns.guidDB.rank, ns.sortByOverHeal)
	elseif ns.activeMode == "Absorb" then
		sort(ns.guidDB.rank, ns.sortByAbsorb)
	elseif ns.activeMode == "Deaths" then
		sort(ns.guidDB.rank, ns.sortByDeaths)
	elseif ns.activeMode == "Dispels" then
		sort(ns.guidDB.rank, ns.sortByDispels)
	elseif ns.activeMode == "Interrupts" then
		sort(ns.guidDB.rank, ns.sortByinterrupts)
	end
	
	for i=1, 25, 1 do
		if ns.activeMode == "Damage" or ns.activeMode == "Damage Taken" then
			ns.sb[i]:SetStatusBarColor(0.8, 0, 0)
		elseif ns.activeMode == "Heal" or ns.activeMode == "OverHeal" then
			ns.sb[i]:SetStatusBarColor(0, 0.8, 0)
		elseif ns.activeMode == "Absorb" then
			ns.sb[i]:SetStatusBarColor(0.8, 0.8, 0)
		elseif ns.activeMode == "Deaths" then
			ns.sb[i]:SetStatusBarColor(0.2, 0.2, 0.2)
		else
			ns.sb[i]:SetStatusBarColor(0.7, 0.7, 0.7)
		end
	end
end

function ns.wham:UpdateLayout()
	-- ensure we're always getting fresh modedata
	ns.switchMode(ns.activeMode)

	-- Show background and border when data is stored
	for i=1, 25, 1 do
		if ns.modeData[ns.guidDB.rank[i]] then
			if ns.bg:GetAlpha() ~= 1 then
				ns.bg:SetAlpha(1)
			end
			if ns.border:GetAlpha() ~=1 then
				ns.border:SetAlpha(1)
			end
		end
	end

	ns.wham:UpdateDisplay()
end