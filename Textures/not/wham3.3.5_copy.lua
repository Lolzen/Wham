--[[	Notes:
*petdmg as seperate statusbar, angeheftet an anderer
*statusbar visuell updaten (update wenn ladescreen) um mit data gleich zu bleiben

IDEE
bei setValue der statusbar -petdmg damit petdm,g ´drangehängt werden kann
]]

--[[================
===		Wham	 ===
================]]--
-- a simpleminded dmg meter

--[[====================
===		MainFrame 	 ===
====================]]--
local wham = CreateFrame("Frame", "Wham", UIParent)
wham:SetHeight(120)
wham:SetWidth(250)
wham:SetPoint("TOP", UIParent, "BOTTOM", 300, 145)
--[[wham:SetBackdrop({
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
	edgeFile = "Interface\\AddOns\\Wham\\Textures\\border", edgeSize = 16,
	insets = {left = 3, right = 3, top = 3, bottom = 3},
})
]]
wham:SetBackdropColor(0,0,0,0.5)
wham:SetBackdropBorderColor(0.2,0.2,0.2)
wham:EnableMouse(true)
wham:SetMovable(true)
wham:SetUserPlaced(true)
wham:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
wham:RegisterEvent("PARTY_MEMBERS_CHANGED")
wham:RegisterEvent("RAID_ROSTER_UPDATE")
wham:RegisterEvent("PLAYER_ENTERING_WORLD")
wham:RegisterEvent("PLAYER_REGEN_DISABLED")
wham:RegisterEvent("PLAYER_REGEN_ENABLED")
--wham:Hide()

--[[===================
===		Buttons		===
===================]]--
-- UpButton
--local upbutton = CreateFrame("Button", "UpButton", UIParent)
--upbutton:SetPoint("BOTTOM", UIParent, "BOTTOM", 330, 10)
--upbutton:SetHeight(13)
--upbutton:SetWidth(100)
--upbutton:EnableMouse(true)
--upbutton:SetMovable(true)
--upbutton:SetUserPlaced(true)

-- A border for the UpButton
--local Border = CreateFrame("Frame", nil)
--Border:SetBackdrop({
--	bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 8,
--	edgeFile = "Interface\\AddOns\\Wham\\Textures\\border", edgeSize = 8,
--	insets = {left = 2, right = 2, top = 2, bottom = 2},
--})
--Border:SetPoint("TOPLEFT", upbutton, -2, 2)
--Border:SetPoint("BOTTOMRIGHT", upbutton, 3, -3)
--Border:SetBackdropBorderColor(0.2, 0.2, 0.2)
--Border:SetBackdropColor(0,0,0,0.5)

-- CloseButton
--local closebutton = CreateFrame("Button", "CloseButton", wham, "UIPanelCloseButton")
--closebutton:SetPoint("TOPRIGHT", wham, -2, -2)

-- ResetButton
local resetbutton = CreateFrame("Button", "ResetButton", wham)
--resetbutton:SetPoint("TOPRIGHT", wham, -25, -2)
resetbutton:SetPoint("LEFT", UIParent, 216, 0)
resetbutton:SetHeight(36)
resetbutton:SetWidth(36)
resetbutton:SetNormalTexture("Interface\\Buttons\\CancelButton-Up") 
resetbutton:SetPushedTexture("Interface\\Buttons\\CancelButton-Down")
resetbutton:SetHighlightTexture("Interface\\Buttons\\CancelButton-Highlight")
resetbutton:SetAlpha(0)

--[[=======================
===		FontStrings		===
=======================]]--
-- UpButton text
--local mini = upbutton:CreateFontString(nil, "OVERLAY")
--mini:SetPoint("CENTER", upbutton, "CENTER", 0, 1)
--mini:SetFont("Fonts\\FRIZQT__.TTF", 12, "THINOUTLINE")
--mini:SetTextColor(1,1,1)
--mini:SetText("[No Data]")

-- The Title
--local version = GetAddOnMetadata("Wham", "Version")
--local title = wham:CreateFontString(nil, "OVERLAY")
--title:SetPoint("TOPLEFT", wham, "TOPLEFT", 8, -8)
--title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
--title:SetText("Wham |cffee7700"..version.."|r")

-- Shows your dps
local dps = wham:CreateFontString(nil, "OVERLAY")
--dps:SetPoint("BOTTOMRIGHT", sb[5], "BOTTOMRIGHT", -3, 6)
dps:SetPoint("LEFT", UIParent, 15, 0)
dps:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")

--[[====================================
===		Gathering necessary Data	 ===
====================================]]--
-- We need this later
local totaldmg
local combatStartTime, combatTotalTime = 0, 0

-- Tables
local dmgData = {}
local watched = {}
--local petDmg = {}
--local watchedPets = {}
local pos = {}
--local petPos = {}
local sb = {}
--local sb2 = {}
-- for 1, max_party/raid + pets, 1 do
for i=1, 5, 1 do
	-- Create the StatusBars
	sb[i] = CreateFrame("StatusBar", "StatusBar"..i, wham)
	sb[i]:SetHeight(11)
	sb[i]:SetWidth(wham:GetWidth() -20)
	sb[i]:SetStatusBarTexture("Interface\\AddOns\\Wham\\Textures\\statusbar")
	sb[i]:SetAlpha(0.6)
	
	-- StatusbarBorder
	if not sb[i].border then
		local border = CreateFrame("Frame", nil, sb[i])
		border:SetBackdrop({
			edgeFile = "Interface\\AddOns\\Wham\\Textures\\border", edgeSize = 8,
			insets = {left = 4, right = 4, top = 4, bottom = 4},
		})
		border:SetPoint("TOPLEFT", sb[i], -2, 1)
		border:SetPoint("BOTTOMRIGHT", sb[i], 1, -1)
		border:SetBackdropBorderColor(0.2, 0.2, 0.2)
		sb[i].border = border
	end
	
	-- background
	if not sb[i].bg then
		local bg = sb[i]:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints(sb[i])
		bg:SetTexture("Interface\\AddOns\\Wham\\Textures\\statusbar")
		bg:SetVertexColor(0.5, 0.5, 0.5, 0.5)
		sb[i].bg = bg
	end

	-- Create the FontStrings
	if not sb[i].text then
		-- Damage on the StatusBar
		local sbtext = sb[i]:CreateFontString(nil, "OVERLAY")
		sbtext:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		sbtext:SetTextColor(1,1,1)
		sbtext:SetPoint("TOPRIGHT", sb[i], "TOPRIGHT", 0, 0)
		sb[i].text = sbtext
	
		-- Name on the StausBar
		local sbtext2 = sb[i]:CreateFontString(nil, "OVERLAY")
		sbtext2:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		sbtext2:SetTextColor(1,1,1)
		sbtext2:SetPoint("TOPLEFT", sb[i], "TOPLEFT", 0, 0)
		sb[i].text2 = sbtext2
	end
	
	-- Create the StatusBars
--	sb2[i] = CreateFrame("StatusBar", "PetStatusBar"..i, wham)
--	sb2[i]:SetHeight(11)
--	sb2[i]:SetWidth(wham:GetWidth() -20)
--	sb2[i]:SetStatusBarTexture("Interface\\AddOns\\Wham\\Textures\\statusbar")
--	sb2[i]:SetAlpha(0.6)
end

local function addUnit(unit)
	local name, realm = UnitName(unit)
	if not name then return end
	realm = realm and realm ~= "" and "-"..realm or ""
	watched[name..realm] = true
end
 
function wham:UpdateWatchedPlayers()
	-- Delete old table
--	if watched[name] then
--	if not GetPartyMember(watched[name]) then
		for k in pairs(watched) do
			--wenn Grmname nicht in watched DANN löschen
			--if watched[k] ~= UnitName(party..k) then
				watched[k] = nil
			--end
		end
--	end
--	end
 
	-- Insert player name
	local playerName = UnitName("player")
	watched[playerName] = true
 
	-- Insert party members
	for i=1, GetNumPartyMembers() do
		addUnit("party"..i)
	end
	
	-- Insert raid members
	for i=1, GetNumRaidMembers() do
		addUnit("raid"..i)
	end
 
	-- Delete dmgData of "old" players
	for name in pairs(dmgData) do
		if not watched[name] then
			dmgData[name] = nil
		end
	end
 
	-- Clear pos-table
	for k in ipairs(pos) do pos[k] = nil end
 
	-- Insert player names into pos-table
	for name in pairs(watched) do
		pos[#pos+1] = name
	end
end
--[[
local function addPet(unit)
	local name = UnitName(unit)
	if not name then return end
	petDmg[name] = true
end

function wham:UpdateWatchedPets()
	-- Delete old table
	for j in pairs(watchedPets) do
		watchedPets[j] = nil
	end
	
	-- Insert pet name
	local petName = UnitName("playerpet")
	watchedPets[petName] = true
	
	-- Insert partypets
	for i=1, GetNumPartyMembers() do
		addPet("partypet"..i)
	end
	
	-- Insert raidpets
	for i=1, GetNumRaidMembers() do
		addPet("raidpet"..i)
	end
	
	-- Delete old petdata
	for name in pairs(petDmg) do
		if not watchedpet[name] then
			petDmg[name] = nil
		end
	end
	
	-- Clear petpos-table
	for j in ipairs(petPos) do petPos[j] = nil end
	
	-- Inser petNames into petPos-table
	for name in pairs(watchedPet) do
		petPos[#petPos+1] = name
	end
end
]]
wham.PLAYER_ENTERING_WORLD = wham.UpdateWatchedPlayers
wham.RAID_ROSTER_UPDATE = wham.UpdateWatchedPlayers
wham.PARTY_MEMBERS_CHANGED = wham.UpdateWatchedPlayers
--UpdateWatchedPets()

function wham.PLAYER_REGEN_DISABLED()
	combatStartTime = GetTime()
end

function wham.PLAYER_REGEN_ENABLED()
	combatTotalTime = combatTotalTime + GetTime() - combatStartTime
	combatStartTime = nil
end
 
function wham:COMBAT_LOG_EVENT_UNFILTERED(self, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, ...)
	if not string.find(arg2, "_DAMAGE") then return end
	--print(event)
	-- If in PvPzone don't gather data
	local _ , instanceType = IsInInstance()
	if instanceType == "pvp" or instanceType == "arena" then return end
	
	-- Dont gather data if we are Solo
--	if GetNumPartyMembers() == 0 or GetNumRaidMembers() == 0 and GetNumPartyMembers() == 0 then return end

	-- Swing and Spell arguments are different
	local name, dmg, over
	if(string.find(arg2, "SWING")) then
	--if event == "SWING_" then
		name, dmg, over = arg4, arg9, arg10
	end
	if(string.find(arg2, "SPELL")) then 
	--if event == "SPELL_" then
		name, dmg, over = arg4, arg12, arg13
	end

	if watched[name] then
		dmgData[name] = (dmgData[name] or 0) + dmg - over
	end
	
	totaldmg = 0
	for _, name in pairs(pos) do
		totaldmg = (totaldmg or 0) + (dmgData[name] or 0)
	end
	
--	if petDmg[name] then
--		petDmg[name] = (petDmg[name] or 0) + dmg - over
--	end

	wham:UpdateStatusBars()
end

local function sortByDamage(a, b)
	return (dmgData[a] or 0) > (dmgData[b] or 0)
end

function wham:UpdateStatusBars()
	-- Sort names by damage
	sort(pos, sortByDamage)

	local playerName = UnitName("player")
	local combatTime = combatTotalTime + (combatStartTime and (GetTime() - combatStartTime) or 0)
	if(dmgData[playerName]) then
		dps:SetFormattedText("Dps: |cff00ffff%d|r", dmgData[playerName]/combatTime)
	end

	-- Statusbars
	-- ###########EDIT: maxraid/party / self defined
	for i=1, 5, 1 do	
		sb[i]:SetMinMaxValues(0, dmgData[pos[1]] or 0)
		if i == 1 then
			sb[i]:SetPoint("BOTTOMLEFT", dps, 0, -15)
			sb[i]:SetValue(dmgData[pos[1]] or 0)
		else
			sb[i]:SetPoint("BOTTOM", sb[i-1], "BOTTOM", 0, -14)
			sb[i]:SetValue(dmgData[pos[i]] or 0)
		end
		
		-- MiniText, What place am i, and what dps?
		local place
		if UnitName("player") == pos[i] and dmgData[pos[i]] then
			if i == 1 then
				place = "st"
			elseif i == 2 then
				place = "nd"
			elseif i == 3 then
				place = "rd"
			else
				place = "th"
			end
	--		mini:SetText("|cff00ff00"..i..place.."|r (|cff00ffff"..string.format("%d", dmgData[playerName]/combatTime).."|r dps)")
		end
		
		-- Set the texts: name & values
		if dmgData[pos[i]] then 
			local damage = dmgData[pos[i]]
			sb[i].text:SetFormattedText("%d (%.0f%%)", damage, damage / totaldmg * 100)
			sb[i].text2:SetText(i..".    "..pos[i])
			sb[i].border:Show()
			sb[i].bg:Show()
		else
			sb[i].text:SetText(nil)
			sb[i].text2:SetText(nil)
			sb[i].border:Hide()
			sb[i].bg:Hide()
		end

		-- ClassColoring the StatusBars for players, else The bar is green (pet)
		local sbColor
		if dmgData[pos[i]] then
--			if not UnitIsPlayer(pos[i]) then
--				sbColor = {r=0, g=1, b=0}
--			else
				sbColor = RAID_CLASS_COLORS[select(2,UnitClass(pos[i]))]
--			end
			sb[i]:SetStatusBarColor(sbColor.r, sbColor.g, sbColor.b)
			resetbutton:SetAlpha(0.8)
		end
		
--		sb2[i]:SetMinMaxValues(0, petDmg[1] or 0)
		--sb2[i]:SetMinMaxValues(0, petDmg[1] or 0)
--		if i == 1 then
--			sb2[i]:SetPoint("LEFT", sb[i], "LEFT", 0, 0)
--			sb2[i]:SetValue(petDmg[pos[1]] or 0)
--		else
--			sb2[i]:SetPoint("LEFT", sb[i], "LEFT", 0, 0)
--			sb2[i]:SetValue(petDmg[pos[i]] or 0)
--		end
	end
end

--[[===================
===		Scripts		===
===================]]--
wham:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print(event)
	end 
end)

-- Kill all data
resetbutton:SetScript("OnClick", function(self)
	dmgData = {}
	for i=1, 5, 1 do
		sb[i]:SetValue(0)
		sb[i].text:SetText(nil)
		sb[i].text2:SetText(nil)
		sb[i].border:Hide()
		sb[i].bg:Hide()
	end
	combatTotalTime = 0
	dps:SetText(nil) 
--	mini:SetText("[No Data]")
	resetbutton:SetAlpha(0)
end)
--[[
-- Wham is movable ;>
wham:SetScript("OnMouseDown", function()
	if IsAltKeyDown() then
		wham:ClearAllPoints()
		wham:StartMoving()
	end
end)

wham:SetScript("OnMouseUp", function()
	wham:StopMovingOrSizing()
end)

-- UpButton should interact with clicks
upbutton:SetScript("OnMouseDown", function()
	if IsAltKeyDown() then
		upbutton:ClearAllPoints()
		upbutton:StartMoving()
	else
		wham:Show()
		mini:Hide()
		Border:Hide()
	end
end)

upbutton:SetScript("OnMouseUp", function()
	upbutton:StopMovingOrSizing()
end)

closebutton:SetScript("OnClick", function(self)
	self:GetParent():Hide()
	mini:Show()
	Border:Show()
end)
]]
--[[========================
===		Slashcommands 	 ===
========================]]--
local channel, wname
local paste = function(self)
	SendChatMessage("Data from Wham:", channel, nil, wname)
	for i=1, 5, 1 do
		if i and dmgData[pos[i]] then
			sort(pos, sortByDamage)
			local damage = dmgData[pos[i]]
			local class = UnitClass(pos[i])
			SendChatMessage(string.format("%d. %s - Damage Done: %d (%.0f%%) [%s]", i, pos[i], damage, damage / totaldmg * 100, class), channel, nil, wname)
		end
	end
end

local pastedps = function(self)
	local combatTime = combatTotalTime + (combatStartTime and (GetTime() - combatStartTime) or 0)
	--SendChatMessage(string.format("My dps (data from Wham): %d", dmgData[playerName]/combatTime), "WHISPER", nil, name)
	SendChatMessage((dmgData[playerName]/combatTime), "WHISPER", nil, name)
end

SLASH_WHAM1 = "/wham"
SlashCmdList["WHAM"] = function(cmd)
	local variable, name = cmd:match("^(%S*)%s*(.-)$") 
	variable = string.lower(variable)
	if variable and variable == "s" then
		channel = "SAY"
		paste()
	elseif variable and variable == "p" then
		channel = "PARTY"
		paste()
	elseif variable and variable == "g" then
		channel = "GUILD"
		paste()
	elseif variable and variable == "ra" then
	channel = "RAID"
		paste()
	elseif variable == "w" and name ~= "" then
		channel = "WHISPER"
		wname = name
		paste()
	--elseif variable ==  channel number
--	elseif variable == "dps" and name ~= "" then
--		pastedps()
--		SendChatMessage(string.format("My dps (data from Wham): %d", dmgData[playerName]/combatTime), "WHISPER", nil, name)
--	elseif variable == "show" then
--		Wham:Show()
--		mini:Hide()
--	elseif variable == "hide" then
--		Wham:Hide()
--		mini:Show()
	else
		ChatFrame1:AddMessage("|cff88ffffWham:|r Valid: s/p/g/ra/w [name]")
		ChatFrame1:AddMessage("|cff88ffffWham:|r Valid: show/hide")
	end
end
