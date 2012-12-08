--[[================
===		Wham	 ===
================]]--
-- a simpleminded dmg meter

local addon, ns = ...

ns.wham = CreateFrame("Frame", "Wham", UIParent)
ns.wham:SetPoint("LEFT", UIParent, 15, 0)
ns.wham:SetSize(ns.width, ns.height)
ns.wham:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
ns.wham:RegisterEvent("GROUP_ROSTER_UPDATE")
ns.wham:RegisterEvent("PLAYER_ENTERING_WORLD")
ns.wham:RegisterEvent("PLAYER_REGEN_DISABLED")
ns.wham:RegisterEvent("PLAYER_REGEN_ENABLED")
ns.wham:RegisterEvent("UNIT_PET")

--[[====================================
===		Gathering necessary Data	 ===
====================================]]--

ns.combatStartTime = 0
ns.combatTotalTime = 0

-- Tables
ns.watched = {}
ns.pos = {}
ns.owners = {}

-- Add players to watched list
local function addUnit(unit)
	local name, realm = UnitName(unit)
	if not name then return end
	realm = realm and realm ~= "" and "-"..realm or ""
	ns.watched[name..realm] = true
end
 
function ns.wham:UpdateWatchedPlayers()
	if ns.autoreset == true then
		-- Delete old table
		for k in pairs(ns.watched) do
			ns.watched[k] = nil
		end
	end
 
	-- Insert player name
	local playerName = UnitName("player")
	ns.watched[playerName] = true
	
	-- Insert playerpet name
	local petName = UnitName("playerpet")
	if petName then
		ns.owners[playerName] = petName
	end
 
	-- Insert party members & pets
	local isInGroup = IsInGroup("player")
	if isInGroup then
		for i=1, GetNumSubgroupMembers() do
			addUnit("party"..i)
			if ("partypet"..i) then
				ns.owners[UnitName("party"..i)] = UnitName("partypet"..i)
			end
		end
	end
	
	-- Insert raid members & pets
	local isInRaid = IsInRaid("player")
	if isInRaid then
		for i=1, GetNumGroupMembers() do
			addUnit("raid"..i)
			if ("raidpet"..i) then
				ns.owners[UnitName("raid"..i)] = UnitName("raidpet"..i)
			end
		end
	end
 
	if ns.autoreset == true then
		-- Delete dmgData of "old" players
		for name in pairs(ns.dmgData) do
			if not ns.watched[name] then
				ns.dmgData[name] = nil
			end
		end

		-- Also for the healvalues
		for name in pairs(ns.healData) do
			if not ns.watched[name] then
				ns.healData[name] = nil
			end
		end

		-- Also for the absorbvalues
		for name in pairs(ns.absorbData) do
			if not ns.watched[name] then
				ns.absorbData[name] = nil
			end
		end
	end

	-- Clear pos-table
	for k in ipairs(ns.pos) do ns.pos[k] = nil end
	
 
	-- Insert player names into pos-table
	for name in pairs(ns.watched) do
		ns.pos[#ns.pos+1] = name
	end
end

-- Upate on certain events
ns.wham.GROUP_ROSTER_UPDATE = ns.wham.UpdateWatchedPlayers
ns.wham.UNIT_PET = ns.wham.UpdateWatchedPlayers

function ns.wham.PLAYER_ENTERING_WORLD()
	ns.wham:UpdateWatchedPlayers()
	ns.wham:UpdateLayout()
end

function ns.wham.PLAYER_REGEN_DISABLED()
	ns.combatStartTime = GetTime()
end

function ns.wham.PLAYER_REGEN_ENABLED()
	ns.combatTotalTime = ns.combatTotalTime + GetTime() - ns.combatStartTime
	ns.combatStartTime = nil
end

-- Sortingfunction (Damage)
function ns.sortByDamage(a, b)
	if ns.cfdGather == true and ns.curData then
		return (ns.curData[a] or 0) > (ns.curData[b] or 0)
	else
		if ns.dmgData then
			return (ns.dmgData[a] or 0) > (ns.dmgData[b] or 0)
		end
	end
end

-- Sortingfunction (Heal)
function ns.sortByHeal(a, b)
	if ns.healData then
		return (ns.healData[a] or 0) > (ns.healData[b] or 0)
	end
end

-- Sortingfunction (Absorb)
function ns.sortByAbsorb(a, b)
	if ns.absorbData then
		return (ns.absorbData[a] or 0) > (ns.absorbData[b] or 0)
	end
end

ns.wham:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug: "..event)
	end 
end)