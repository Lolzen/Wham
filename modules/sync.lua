--[[================
===		Sync   	 ===
================]]--
-- sync module

local addon, ns = ...
if ns.activatedModules["Sync"] == false then return end

ns.syncFrame = CreateFrame("Frame", "syncFrame", UIParent)
ns.syncFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ns.syncFrame:RegisterEvent("CHAT_MSG_ADDON")
ns.syncFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

function ns.syncFrame:PLAYER_ENTERING_WORLD()
	RegisterAddonMessagePrefix("Wham_DMG")
	RegisterAddonMessagePrefix("Wham_DMGTAKEN")
	RegisterAddonMessagePrefix("Wham_HEAL")
	RegisterAddonMessagePrefix("Wham_ABSORB")
	RegisterAddonMessagePrefix("Wham_DEATH")
	RegisterAddonMessagePrefix("Wham_INTERRUPT")
	RegisterAddonMessagePrefix("Wham_DISPEL")
	RegisterAddonMessagePrefix("Wham_UPDATE")
	RegisterAddonMessagePrefix("Wham_RESET")
end

StaticPopupDialogs["WHAM_CHECK_DATA_RESET"] = {
	text = "Data reset requested. Reset all data?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function()
		ns.resetData()
		print("Accepted synced data reset. All data is resetted.")
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = false,
	preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

local localDmg, localHeal, localAbsorb, extDeaths, extinterrupts = 0, 0, 0, 0, 0
function ns.syncFrame:CHAT_MSG_ADDON(self, arg1, arg2, arg3, arg4)
	local prefix, msg, channel, sender = arg1, arg2, arg3, arg4
	--print(channel..": "..prefix.." - From: ["..sender.."] > "..msg)
	-- Everything Damage related
	if prefix == "Wham_DMG" then
		-- Gathering Messages sent and converting them so we can work with them
		local extDmgName, extDmg_raw, extTotalDmg_raw = strsplit(" ", msg, 3)
		-- We can't compare strings to numbers, so we have to convert that
		local extDmg = tonumber(extDmg_raw, A)
		local extTotalDmg = tonumber(extTotalDmg_raw, A)
		-- Add to watched list
		ns.wham:addUnitToDB(extDmgName)

		-- v = dmg
		for extDmgName, v in pairs(ns.dmgData) do
			localDmg = v
		end

		if extDmg > localDmg then
			if ns.guidDB.rank[extDmgName] then
				ns.dmgData[extDmgName] = extDmg
				ns.totaldmg = extTotalDmg
				if ns.wham.UpdateLayout then
					ns.wham:UpdateLayout()
				end
			end
		end
	end
	-- Everything Heal related
	if prefix == "Wham_HEAL" then
		-- Gathering Messages sent and converting them so we can work with them
		local extHealName, extHeal_raw, extTotalheal_raw = strsplit(" ", msg, 3)
		-- We can't compare strings to numbers, so we have to convert that
		local extHeal = tonumber(extHeal_raw, A)
		local extTotalheal = tonumber(extTotalHeal_raw, A)
		-- Add to watchd list
		ns.wham:addUnitToDB(extHealName)

		-- v = heal
		for extHealName, v in pairs(ns.healData) do
			localHeal = v
		end

		if extHeal > localHeal then
			if ns.guidDB.rank[extHealName] then
				ns.healData[extHealName] = extHeal
				ns.totalheal = extTotalHeal
				if ns.wham.UpdateLayout then
					ns.wham:UpdateLayout()
				end
			end
		end
	end
	-- Everything Absorb related
	if prefix == "Wham_ABSORB" then
		-- Gathering Messages sent and converting them so we can work with them
		local extAbsorbName, extAbsorb_raw, extTotalAbsorb_raw = strsplit(" ", msg, 3)
		-- We can't compare strings to numbers, so we have to convert that
		local extAbsorb = tonumber(extAbsorb_raw, A)
		local extTotalAbsorb = tonumber(extTotalAbsorb_raw, A)
		-- Add to watched list
		ns.wham:addUnitToDB(extAbsorbName)

		-- v = absorb
		for extAbsorbName, v in pairs(ns.absorbData) do
			localAbsorb = v
		end

		if extAbsorb > localAbsorb then
			if ns.guidDB.rank[extAbsorbName] then
				ns.absorbData[extAbsorbName] = extAbsorb
				ns.totalabsorb = extTotalAbsorb
				if ns.wham.UpdateLayout then
					ns.wham:UpdateLayout()
				end
			end
		end
	end
	-- Deaths
	if prefix == "Wham_DEATH" then
		-- Gathering Messages sent and converting them so we can work with them
		local extDeathName, extDeaths_raw, extTotalDeaths_raw = strsplit(" ", msg, 3)
		-- We can't compare strings to numbers, so we have to convert that
		local extDeaths = tonumber(extDeaths_raw, A)
		local extTotalDeaths = tonumber(extTotalDeaths_raw, A)
		-- Add to watched list
		ns.wham:addUnitToDB(extDeathName)

		-- v = deaths
		for extDeathName, v in pairs(ns.deathData) do
			localDeaths = v
		end

		if extDeaths > localDeaths then
			if ns.guidDB.rank[extDeathName] then
				ns.deathData[extDeathName] = extDeaths
				ns.totaldeaths = extTotalDeaths
				if ns.wham.UpdateLayout then
					ns.wham:UpdateLayout()
				end
			end
		end
	end
	-- Interrupts
	if prefix == "Wham_INTERRUPT" then
		-- Gathering Messages sent and converting them so we can work with them
		local extInterruptName, extInterrupts_raw, extTotalInterrupts_raw = strsplit(" ", msg, 3)
		-- We can't compare strings to numbers, so we have to convert that
		local extInterrupts = tonumber(extInterrupts_raw, A)
		local extTotalInterrupts = tonumber(extTotalInterrupts_raw, A)
		-- Add to watched list
		ns.wham:addUnitToDB(extInterruptName)

		-- v = interrupts
		for extInterruptName, v in pairs(ns.interruptData) do
			localInterrupts = v
		end

		if extInterrupts > localInterrupts then
			if ns.guidDB.rank[extInterruptName] then
				ns.interruptData[extInterruptName] = extInterrupts
				ns.totalinterrupts = extTotalInterrupts
				if ns.wham.UpdateLayout then
					ns.wham:UpdateLayout()
				end
			end
		end
	end
	-- Dispels
	if prefix == "Wham_DISPEL" then
		-- Gathering Messages sent and converting them so we can work with them
		local extDispelName, extDispels_raw, extTotalDispels_raw = strsplit(" ", msg, 3)
		-- We can't compare strings to numbers, so we have to convert that
		local extDispels = tonumber(extDispels_raw, A)
		local extTotalDispels = tonumber(extTotalDispels_raw, A)
		-- Add to watched list
		ns.wham:addUnitToDB(extDispelName)

		-- v = dispels
		for extDispelName, v in pairs(ns.dispelData) do
			localDispels = v
		end

		if extDispels > localDispels then
			if ns.guidDB.rank[extDispelName] then
				ns.dispelData[extDispelName] = extDispells
				ns.totaldispels = extTotalDispels
				if ns.wham.UpdateLayout then
					ns.wham:UpdateLayout()
				end
			end
		end
	end
	if prefix == "Wham_UPDATE" then
		if ns.wham.UpdateLayout then
			ns.wham:UpdateLayout()
		end
	end
	if prefix == "Wham_RESET" then
		if ns.autoAcceptExternalReset == true then
			ns.resetData()
			print("Recieved synced data reset. All data is resetted.")
		else
			StaticPopup_Show("WHAM_CHECK_DATA_RESET")
		end
	end
end

function ns.syncFrame:PLAYER_REGEN_DISABLED()
	if IsInGroup("player") then
		local channel = IsInRaid("player") and "RAID" or "PARTY"
		SendAddonMessage("Wham_UPDATE", nil, channel)
	end
	if ns.wham.UpdateLayout then
		ns.wham:UpdateLayout()
	end
end

ns.syncFrame:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug (syncFrame): "..event)
	end 
end)