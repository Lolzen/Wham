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

ns.players = {
	whamUsers = {},
	watched = {},
	rank = {},
	class = {},
	pets = {},
}

-- Add players to watched list
function ns.wham:addUnit(unit)
	local name, realm = UnitName(unit)
	if not name or name == "Unknown" then return end
	realm = realm and realm ~= "" and "-"..realm or ""
	if not ns.players.watched[name..realm] then
		ns.players.watched[name..realm] = true
	end
end
 
function ns.wham:UpdateWatchedPlayers()
	-- Delete old table
	if ns.cleanOnGrpChange == true then	
		for k in pairs(ns.players.watched) do
			ns.players.watched[k] = nil
		end
	end
 
	-- Insert player name
	local playerName = UnitName("player")
	if not ns.players.watched[playerName] then
		ns.players.watched[playerName] = true
	end

	-- Insert playerpet name
	local petName = UnitName("playerpet")
	if petName and not ns.players.pets[petName] then
		ns.players.pets[petName] = playerName
	end
 
	-- Insert party members & pets
	local isInGroup = IsInGroup("player")
	if isInGroup then
		for i=1, GetNumSubgroupMembers() do
			ns.wham:addUnit("party"..i)
			if ("partypet"..i) then
				if UnitName("partypet"..i) ~= nil then
					ns.players.pets[UnitName("party"..i)] = UnitName("partypet"..i)
				end
			end
		end
	end

	-- Insert raid members & pets
	local isInRaid = IsInRaid("player")
	if isInRaid then
		for i=1, GetNumGroupMembers() do
			ns.wham:addUnit("raid"..i)
			if ("raidpet"..i) then
				if UnitName("raidpet"..i) ~= nil then
					ns.players.pets[UnitName("raidpet"..i)] = UnitName("raid"..i)
				end
			end
		end
	end

	-- Gather Classes of watched players
	for name in pairs(ns.players.watched) do
		if not ns.players.class[name] and not ns.players.class[name] ~= nil then
			ns.players.class[name] = select(2,UnitClass(name))
		end
	end
 
	-- Delete Data of "old" players
	ns.resetData()

	-- Insert player names into rank-table
	for name in pairs(ns.players.watched) do
		ns.players.rank[#ns.players.rank+1] = name
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
		tinsert(ns.players.whamUsers, sender)
	end
end

-- Select recieved mode as activeMode
function ns.switchMode(selectedMode)
	ns.activeMode = selectedMode
	-- Use the selected data
	if selectedMode == "Damage" and ns.currentfightdatamodule == true then
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
	if ns.checkColor then
		ns.checkColor()
	end
end

-- Sortingfunction (Damage)
function ns.sortByDamage(a, b)
	if currentfightdatamodule == true and ns.curData then
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
	for k in ipairs(ns.players.rank) do 
		ns.players.rank[k] = nil 
	end
end

ns.wham:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug: "..event)
	end 
end)