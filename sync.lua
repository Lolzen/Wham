--[[================
===		Sync   	 ===
================]]--
-- sync module

local addon, ns = ...

ns.syncFrame = CreateFrame("Frame", "syncFrame", UIParent)
ns.syncFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ns.syncFrame:RegisterEvent("CHAT_MSG_ADDON")

function ns.syncFrame:PLAYER_ENTERING_WORLD()
	RegisterAddonMessagePrefix("Wham_DMG")
	RegisterAddonMessagePrefix("Wham_HEAL")
	RegisterAddonMessagePrefix("Wham_ABSORB")
end

function ns.syncFrame:CHAT_MSG_ADDON(self, arg1, arg2, arg3, arg4)
	local prefix, msg, channel, sender = arg1, arg2, arg3, arg4
	-- Everything Damage related
	if prefix == "Wham_DMG" then
		-- Gathering Messages sent and converting them so we can work with them
		extDmgName, extDmg_raw = strsplit(" ", msg, 2)
		-- We can't compare strings to numbers, so we have to convert that
		extDmg = tonumber(extDmg_raw, A)
		
		-- k = name
		-- v = dmg
		for k, v in pairs(ns.dmgData) do
			localDmgName = k
			localDmg = v
		end
		
		-- Check if the names match, so we don't override somone else's data
		if extDmgName == localDmgName then
			-- If the external DmgData is more up to date, sync it
			if extDmg > localDmg then
				ns.dmgData[extDmgName] = extDmg
			end
		end
	end
	-- Everything Heal related
	if prefix == "Wham_HEAL" then
		-- Gathering Messages sent and converting them so we can work with them
		extHealName, extHeal_raw = strsplit(" ", msg, 2)
		-- We can't compare strings to numbers, so we have to convert that
		extHeal = tonumber(extHeal_raw, A)
		
		-- k = name
		-- v = heal
		for k, v in pairs(ns.healData) do
			localHealName = k
			localHeal = v
		end
		
		-- Check if the names match, so we don't override somone else's data
		if extHealName == localHealName then
			-- If the external HealData is more up to date, sync it
			if extHeal > localHeal then
				ns.healData[extHealName] = extHeal
			end
		end
	end
	-- Everything Absorb related
	if prefix == "Wham_ABSORB" then
		-- Gathering Messages sent and converting them so we can work with them
		extAbsorbName, extAbsorb_raw = strsplit(" ", msg, 2)
		-- We can't compare strings to numbers, so we have to convert that
		extAbsorb = tonumber(extAbsorb_raw, A)
		
		-- k = name
		-- v = absorb
		for k, v in pairs(ns.absorbData) do
			localAbsorbName = k
			localAbsorb = v
		end
		
		-- Check if the names match, so we don't override somone else's data
		if extAbsorbName == localAbsorbName then
			-- If the external AbsorbData is more up to date, sync it
			if extAbsorb > localAbsorb then
				ns.absorbdData[extAbsorbName] = extAbsorb
			end
		end
	end
end

ns.syncFrame:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug (syncFrame): "..event)
	end 
end)