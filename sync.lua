--[[================
===		Sync   	 ===
================]]--
-- sync module

local addon, ns = ...

ns.syncFrame = CreateFrame("Frame", "syncFrame", UIParent)
ns.syncFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ns.syncFrame:RegisterEvent("CHAT_MSG_ADDON")
ns.syncFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

function ns.syncFrame:PLAYER_ENTERING_WORLD()
	RegisterAddonMessagePrefix("Wham_DMG")
	RegisterAddonMessagePrefix("Wham_HEAL")
	RegisterAddonMessagePrefix("Wham_ABSORB")
	RegisterAddonMessagePrefix("Wham_UPDATE")
	RegisterAddonMessagePrefix("Wham_RESET")
end

local localDmg, localHeal, localAbsorb = 0, 0, 0
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
		ns.wham:addUnit(extDmgName)

		-- v = dmg
		for extDmgName, v in pairs(ns.dmgData) do
			localDmg = v
		end

		if extDmg > localDmg then
			if ns.watched[extDmgName] then
				ns.dmgData[extDmgName] = extDmg
				ns.totaldmg = extTotalDmg
				ns.wham:UpdateLayout()
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
		ns.wham:addUnit(extHealName)

		-- v = heal
		for extHealName, v in pairs(ns.healData) do
			localHeal = v
		end

		if extHeal > localHeal then
			if ns.watched[extHealName] then
				ns.healData[extHealName] = extHeal
				ns.totalheal = extTotalHeal
				ns.wham:UpdateLayout()
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
		ns.wham:addUnit(extAbsorbName)

		-- v = absorb
		for extAbsorbName, v in pairs(ns.absorbData) do
			localAbsorb = v
		end

		if extAbsorb > localAbsorb then
			if ns.watched[extAbsorbName] then
				ns.absorbData[extAbsorbName] = extAbsorb
				ns.totalabsorb = extTotalAbsorb
				ns.wham:UpdateLayout()
			end
		end
	end
	if prefix == "Wham_UPDATE" then
		ns.wham:UpdateLayout()
	end
	if prefix == "Wham_RESET" then
		if ns.acceptExternalReset == true then
			ns.resetData()
			print("Recieved synced data reset. All data is resetted.")
		end
	end
end

function ns.syncFrame:PLAYER_REGEN_DISABLED()
	if IsInGroup("player") then
		local channel = IsInRaid("player") and "RAID" or "PARTY"
		SendAddonMessage("Wham_UPDATE", nil, channel)
	end
	ns.wham:UpdateLayout()
end

ns.syncFrame:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug (syncFrame): "..event)
	end 
end)