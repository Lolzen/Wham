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

function ns.layoutSpecificReset()
	for i=1, 25, 1 do
		ns.sb[i]:SetValue(0)
		ns.sb[i].bg:Hide()
		ns.f[i].string1:SetText(nil)
		ns.f[i].string2:SetText(nil)
		ns.f[i].border:Hide()
		ns.f[i].bg:Hide()
	end
	for i=1, #ns.tabs do
		ns.tabs[i]:SetAlpha(0)
		ns.tabs[i].border:SetAlpha(0)
	end
	ns.bg:SetAlpha(0)
	ns.border:SetAlpha(0)
end

-- Initialize tabs for switching modes
ns.activeMode = ns.initMode --activate mode chosen in config first

-- Check which modules are true in config.lua and pollute the activatedModes table
ns.activatedModes = {}
if ns.damagemodule == true then
	ns.activatedModes["Damage"] = true
end
if ns.damagetakenmodule == true then
	ns.activatedModes["Damage Taken"] = true
end
if ns.healmodule == true then
	ns.activatedModes["Heal"] = true
	ns.activatedModes["OverHeal"] = true
end
if ns.absorbModule == true then
	ns.activatedModes["Absorb"] = true
end
if ns.deathtrackmodule == true then
	ns.activatedModes["Deaths"] = true
end
if ns.dispelmodule == true then
	ns.activatedModes["Dispels"] = true
end
if ns.interruptmodule == true then
	ns.activatedModes["Interrupts"] = true
end

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

-- A little helper to check colors corresponding to mode
function ns.checkColor()
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

-- Create some clickable tabs
ns.tabs = {}
function ns.updateTabs()
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
		if v == ns.activeMode then
			ns.tabs[k].bg:SetTexture(0.5, 0, 0, 0.5)
		else
			ns.tabs[k].bg:SetTexture(0, 0, 0, 0.5)
		end
		-- Labels
		if not ns.tabs[k].label then
			ns.tabs[k].label = ns.tabs[k]:CreateFontString(nil, "OVERLAY")
			ns.tabs[k].label:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
			ns.tabs[k].label:SetPoint("CENTER", ns.tabs[k], "CENTER", 0, 0)
			if ns.activatedModes[v] == true then
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
			if ns.activatedModes[v] == true then
				ns.switchMode(v)
				ns.wham:UpdateLayout()
			else
				print("Module for "..v.." deactivated. Check your config.lua")
			end
		end)
	end
end

function ns.hideTabs()
	for i=1, #ns.tabs do
		ns.tabs[i]:SetAlpha(0)
		ns.tabs[i].border:SetAlpha(0)
	end
end

function ns.showTabs()
	for i=1, #ns.tabs do
		ns.tabs[i]:SetAlpha(0.4)
		ns.tabs[i].border:SetAlpha(1)
	end
end

-- Handle the Statusbars
ns.sb = {}
ns.f = {}
ns.class = {}

for i=1, 25, 1 do
	-- Create the frame all other bars will be attached to
	ns.f[i] = CreateFrame("Frame", nil, ns.wham)
	ns.f[i]:SetHeight(15)
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

	-- Create the StatusBars
	ns.sb[i] = CreateFrame("StatusBar", "StatusBar"..i, ns.wham)
	ns.sb[i]:SetHeight(15)
	ns.sb[i]:SetWidth(ns.wham:GetWidth() -8)
	ns.sb[i]:SetStatusBarTexture("Interface\\AddOns\\Wham\\Textures\\statusbar")

	-- StatusBars background
	if not ns.sb[i].bg then
		ns.sb[i].bg = ns.sb[i]:CreateTexture(nil, "BACKGROUND")
		ns.sb[i].bg:SetAllPoints(ns.sb[i])
		ns.sb[i].bg:SetTexture("Interface\\AddOns\\Wham\\Textures\\statusbar")
		ns.sb[i].bg:SetVertexColor(0.3, 0.3, 0.3)
	end

	-- Create the FontStrings
	if not ns.f[i].string1 then
		-- #. Name
		ns.f[i].string1 = ns.f[i]:CreateFontString(nil, "OVERLAY")
		ns.f[i].string1:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		ns.f[i].string1:SetPoint("TOPLEFT", ns.f[i], "TOPLEFT", 2, -2)
	end
	if not ns.f[i].string2 then
		-- mode (mode%)
		ns.f[i].string2 = ns.f[i]:CreateFontString(nil, "OVERLAY")
		ns.f[i].string2:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		ns.f[i].string2:SetPoint("TOPRIGHT", ns.f[i], "TOPRIGHT", -2, -2)
	end
end

function ns.wham:UpdateDisplay()
	for i=1, 5, 1 do
		if i == 1 then
			ns.f[i]:SetPoint("TOPLEFT", ns.wham, 4, -4)
			if ns.modeData[ns.pos[ns.viewrange]] and ns.modeTotal > 0 then
				--Statusbars
				ns.sb[i]:SetAlpha(1)
				ns.sb[i]:SetMinMaxValues(0, ns.modeData[ns.pos[1]] or 0)
				ns.sb[i]:SetPoint("BOTTOMLEFT", ns.f[i], 0, 0)
				ns.sb[i]:SetValue(ns.modeData[ns.pos[ns.viewrange]] or 0)
				-- Strings
				local rcColor = RAID_CLASS_COLORS[ns.class[ns.pos[ns.viewrange]]] or {r = 0.3, g = 0.3, b = 0.3}
				local curModeVal = ns.modeData[ns.pos[ns.viewrange]] or 0
				ns.f[i].string2:SetFormattedText("%d (%.0f%%)", curModeVal, curModeVal / ns.modeTotal * 100)
				ns.f[i].string1:SetFormattedText("%d.  |cff%02x%02x%02x%s|r", ns.viewrange, rcColor.r*255, rcColor.g*255, rcColor.b*255, ns.pos[ns.viewrange])
				ns.f[i].border:Show()
				ns.f[i].bg:Show()
			else
				ns.sb[i]:SetAlpha(0)
				ns.f[i].string1:SetText(nil)
				ns.f[i].string2:SetText(nil)
				ns.f[i].border:Hide()
				ns.f[i].bg:Hide()
			end
		else
			ns.f[i]:SetPoint("TOP", ns.f[i-1], "BOTTOM", 0, -2)
			if ns.modeData[ns.pos[ns.viewrange + i - 1]] and ns.modeTotal > 0 then
				-- Statusbars
				ns.sb[i]:SetAlpha(1)
				ns.sb[i]:SetMinMaxValues(0, ns.modeData[ns.pos[1]] or 0)
				ns.sb[i]:SetPoint("BOTTOMLEFT", ns.f[i], 0, 0)
				ns.sb[i]:SetValue(ns.modeData[ns.pos[ns.viewrange + i - 1]] or 0)
				-- Strings
				local rcColor = RAID_CLASS_COLORS[ns.class[ns.pos[ns.viewrange + i - 1]]] or {r = 0.3, g = 0.3, b = 0.3}
				local curModeVal = ns.modeData[ns.pos[ns.viewrange + i - 1]] or 0
				ns.f[i].string2:SetFormattedText("%d (%.0f%%)", curModeVal, curModeVal / ns.modeTotal * 100)
				ns.f[i].string1:SetFormattedText("%d.  |cff%02x%02x%02x%s|r", ns.viewrange + i - 1, rcColor.r*255, rcColor.g*255, rcColor.b*255, ns.pos[ns.viewrange + i - 1])
				ns.f[i].border:Show()
				ns.f[i].bg:Show()
			else
				ns.sb[i]:SetAlpha(0)
				ns.f[i].string1:SetText(nil)
				ns.f[i].string2:SetText(nil)
				ns.f[i].border:Hide()
				ns.f[i].bg:Hide()
			end
		end
	end
end

function ns.wham:UpdateLayout()
	-- Sort Statusbars by mode, so they aren't getting displayed funny
	if ns.activeMode == "Damage" then
		sort(ns.pos, ns.sortByDamage)
	elseif ns.activeMode == "Damage Taken" then
		sort(ns.pos, ns.sortByDamageTaken)
	elseif ns.activeMode == "Heal" then
		sort(ns.pos, ns.sortByHeal)
	elseif ns.activeMode == "OverHeal" then
		sort(ns.pos, ns.sortByOverHeal)
	elseif ns.activeMode == "Absorb" then
		sort(ns.pos, ns.sortByAbsorb)
	elseif ns.activeMode == "Deaths" then
		sort(ns.pos, ns.sortByDeaths)
	elseif ns.activeMode == "Dispels" then
		sort(ns.pos, ns.sortByDispels)
	elseif ns.activeMode == "Interrupts" then
		sort(ns.pos, ns.sortByinterrupts)
	end

	-- ensure we're always getting fresh modedata
	ns.switchMode(ns.activeMode)

	-- Gather Classes of watched players
	for class in pairs(ns.watched) do
		if class ~= nil then
			ns.class[class] = select(2,UnitClass(class))
		end
	end

	for i=1, 25 do
		if ns.modeData[ns.pos[i]] then
			ns.bg:SetAlpha(1)
			ns.border:SetAlpha(1)
		end
	end

	if ns.modeData then
		ns.showTabs()
	else
		ns.hideTabs()
	end

	ns.wham:UpdateDisplay()
	ns.updateTabs()
	ns.checkColor()
end