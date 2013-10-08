--[[================
===		Core	 ===
================]]--
-- Core functions

local addon, ns = ...

ns.wham = CreateFrame("Frame", "Wham", UIParent)
ns.wham:SetPoint("LEFT", UIParent, 95, 0)
ns.wham:SetSize(ns.width, ns.height)
ns.wham:RegisterEvent("GROUP_ROSTER_UPDATE")
ns.wham:RegisterEvent("PLAYER_ENTERING_WORLD")
ns.wham:RegisterEvent("UNIT_PET")
ns.wham:RegisterEvent("CHAT_MSG_ADDON")

-- In the guidDB is stored all player and pet information
ns.guidDB = {
	players = {},
	pets = {},
	rank = {},
	whamUsers = {},
}

function ns.wham:addUnitToDB(unit, owner)
	local guid = UnitGUID(unit)
	if not guid or guid == "" then return end
	local unitType = bit.band(tonumber("0x"..strsub(guid, 3,5)), 0x00f)
	local name, realm = UnitName(unit)
	if not name or name == "Unknown" then return end
	
	-- Players
	if unitType == 8 then
		local realm = realm and realm ~= "" and "-"..realm or ""
		local _, class, race, _, _ = GetPlayerInfoByGUID(guid)
		
		if not ns.guidDB.players[guid] then
			ns.guidDB.players[guid] = {
				["name"] = name..realm, 
				["class"] = class,
				["classcolor"] = RAID_CLASS_COLORS[class],
			}
		end
	-- Pets or Vehicles
	elseif unitType == 4 or unitType == 3 then
		if not ns.guidDB.pets[guid] then
			ns.guidDB.pets[guid] = {
				["name"] = name, 
				["owner"] = owner,
			}
		end
	end
end
 
function ns.wham:UpdateWatchedPlayers()
	-- Delete old table
	if ns.cleanOnGrpChange == true then	
		for k in pairs(ns.guidDB) do
			ns.guidDB[k] = nil
		end
	end
 
	-- Insert player name
	ns.wham:addUnitToDB("player")

	-- Insert playerpet name
	if UnitExists("playerpet") then
		ns.wham:addUnitToDB("playerpet", UnitName("player"))
	end
 
	-- Insert party members & pets
	local isInGroup = IsInGroup("player")
	if isInGroup then
		for i=1, GetNumSubgroupMembers() do
			ns.wham:addUnitToDB("party"..i)
			if UnitExists("partypet"..i) then
				ns.wham:addUnitToDB(("partypet"..i), UnitName("party"..i))
			end
		end
	end

	-- Insert raid members & pets
	local isInRaid = IsInRaid("player")
	if isInRaid then
		for i=1, GetNumGroupMembers() do
			ns.wham:addUnitToDB("raid"..i)
			if UnitExists("raidpet"..i) then
				ns.wham:addUnitToDB(("raidpet"..i), UnitName("raid"..i))
			end
		end
	end
 
	-- Delete Data of "old" players
	ns.resetData()

	-- Insert player names into rank-table
	for _, guid in pairs(ns.guidDB.players) do
		ns.guidDB.rank[#ns.guidDB.rank+1] = guid.name
	end
end

-- Upate on certain events
ns.wham.GROUP_ROSTER_UPDATE = ns.wham.UpdateWatchedPlayers
ns.wham.UNIT_PET = ns.wham.UpdateWatchedPlayers

function ns.wham.PLAYER_ENTERING_WORLD()
	RegisterAddonMessagePrefix("Wham_TOKEN")
	ns.wham:UpdateWatchedPlayers()
	ns.wham:sendToken()
	if ns.wham.UpdateLayout then
		ns.wham:UpdateLayout()
	end
end

-- Sending the token, so other's can identify us, like we can idetify them as Wham-Users
function ns.wham:sendToken()
	if IsInGroup("player") then
		local channel = IsInRaid("player") and "RAID" or "PARTY"
		SendAddonMessage("Wham_TOKEN", nil, channel)
	end
end

function ns.wham:CHAT_MSG_ADDON(self, arg1, arg2, arg3, arg4)
	local prefix, msg, channel, sender = arg1, arg2, arg3, arg4
	if prefix == "Wham_TOKEN" then
		tinsert(ns.guidDB.whamUsers, sender)
	end
end

-- Select recieved mode as activeMode
function ns.switchMode(selectedMode)
	ns.activeMode = selectedMode
	-- Use the selected data
	if selectedMode == "Damage" and ns.activatedModules["Current Fight Data"] == true then
		ns.modeTotal = ns.curTotaldmg
		ns.modeData = ns.curData
	elseif selectedMode == "Damage" then
		ns.modeTotal = ns.totaldmg
		ns.modeData = ns.dmgData
	elseif selectedMode == "Damage Taken" then
		ns.modeTotal = ns.totaldmgtaken
		ns.modeData = ns.dmgtakenData
	elseif selectedMode == "Heal" then
		ns.modeTotal = ns.totalheal
		ns.modeData = ns.healData
	elseif selectedMode == "OverHeal" then
		ns.modeTotal = ns.totaloverheal
		ns.modeData = ns.overhealData
	elseif selectedMode == "Absorb" then
		ns.modeTotal = ns.totalabsorb
		ns.modeData = ns.absorbData
	elseif selectedMode == "Deaths" then
		ns.modeTotal = ns.totaldeaths
		ns.modeData = ns.deathData
	elseif selectedMode == "Dispels" then
		ns.modeTotal = ns.totaldispels
		ns.modeData = ns.dispelData
	elseif selectedMode == "Interrupts" then
		ns.modeTotal = ns.totalinterrupts
		ns.modeData = ns.interruptData
	end
	
	if ns.switchModeEvent then
		ns.switchModeEvent()
	end
end

-- Sortingfunction (Damage)
function ns.sortByDamage(a, b)
	if ns.activatedModules["Current Fight Data"] == true and ns.curData then
		return (ns.curData[a] or 0) > (ns.curData[b] or 0)
	else
		if ns.dmgData then
			return (ns.dmgData[a] or 0) > (ns.dmgData[b] or 0)
		end
	end
end

-- Sortingfunction (Damage Taken)
function ns.sortByDamageTaken(a, b)
	if ns.dmgtakenData then
		return (ns.dmgtakenData[a] or 0) > (ns.dmgtakenData[b] or 0)
	end
end

-- Sortingfunction (Heal)
function ns.sortByHeal(a, b)
	if ns.healData then
		return (ns.healData[a] or 0) > (ns.healData[b] or 0)
	end
end

-- Sortingfunction (OverHeal)
function ns.sortByOverHeal(a, b)
	if ns.overhealData then
		return (ns.overhealData[a] or 0) > (ns.overhealData[b] or 0)
	end
end

-- Sortingfunction (Absorb)
function ns.sortByAbsorb(a, b)
	if ns.absorbData then
		return (ns.absorbData[a] or 0) > (ns.absorbData[b] or 0)
	end
end

-- Sortingfunction (Deaths)
function ns.sortByDeaths(a, b)
	if ns.deathData then
		return (ns.deathData[a] or 0) > (ns.deathData[b] or 0)
	end
end

-- Sortingfunction (Dispels)
function ns.sortByDispels(a, b)
	if ns.dispelData then
		return (ns.dispelData[a] or 0) > (ns.dispelData[b] or 0)
	end
end

-- Sortingfunction (Interrupts)
function ns.sortByInterrupts(a, b)
	if ns.interruptData then
		return (ns.interruptData[a] or 0) > (ns.interruptData[b] or 0)
	end
end

-- Resettingfunction (reset all collected data)
function ns.resetData()
	if ns.curData then
		for k in pairs(ns.curData) do
			ns.curData[k] = nil
		end
	end
	
	if ns.dmgData then
		for k in pairs(ns.dmgData) do
			ns.dmgData[k] = nil
		end
	end

	if ns.overdmgData then
		for k in pairs(ns.overdmgData) do
			ns.overdmgData[k] = nil
		end
	end

	if ns.dmgtakenData then
		for k in pairs(ns.dmgtakenData) do
			ns.dmgtakenData[k] = nil
		end
	end

	if ns.healData then
		for k in pairs(ns.healData) do
			ns.healData[k] = nil
		end
	end

	if ns.overhealData then
		for k in pairs(ns.overhealData) do
			ns.overhealData[k] = nil
		end
	end

	if ns.absorbData then
		for k in pairs(ns.absorbData) do
			ns.absorbData[k] = nil
		end
	end

	if ns.deathData then
		for k in pairs(ns.deathData) do
			ns.deathData[k] = nil
		end
	end

	if ns.dispelData then
		for k in pairs(ns.dispelData) do
			ns.dispelData[k] = nil
		end
	end

	if ns.interruptData then
		for k in pairs(ns.interruptData) do
			ns.interruptData[k] = nil
		end
	end

	if ns.combatTotalTime then
		ns.combatTotalTime = 0
	end

	if ns.layoutSpecificReset then
		ns.layoutSpecificReset()
	end
	
	-- Clear rank-table
	for k in ipairs(ns.guidDB.rank) do 
		ns.guidDB.rank[k] = nil 
	end
end

ns.wham:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug: "..event)
	end 
end)