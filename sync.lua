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
end

local localDmg, localHeal, localAbsorb
function ns.syncFrame:CHAT_MSG_ADDON(self, arg1, arg2, arg3, arg4)
	local prefix, msg, channel, sender = arg1, arg2, arg3, arg4
	--print(channel..": "..prefix.." - From: ["..sender.."]")
	-- Everything Damage related
	if prefix == "Wham_DMG" then
		-- Gathering Messages sent and converting them so we can work with them
		local extDmgName_raw, extDmg_raw = strsplit(" ", msg, 2)
		-- We can't compare strings to numbers, so we have to convert that
		local extDmg = tonumber(extDmg_raw, A)
		-- Attach realm to the Name, so we don't get duplicates
		local name, realm = UnitName(extDmgName_raw)
		realm = realm and realm ~= "" and "-"..realm or ""
		local extDmgName = extDmgName_raw..realm
		
		-- v = dmg
		for extDmgName, v in pairs(ns.dmgData) do
			localDmg = v
		end

		-- initialize if nil
		if localDmg == nil then
			localDmg = 0
		end

		ns.watched[extDmgName] = true
		if extDmg > localDmg then
			if ns.watched[extDmgName] then
				ns.dmgData[extDmgName] = extDmg
				ns.wham:UpdateLayout()
			end
		end
	end
	-- Everything Heal related
	if prefix == "Wham_HEAL" then
		-- Gathering Messages sent and converting them so we can work with them
		local extHealName_raw, extHeal_raw = strsplit(" ", msg, 2)
		-- We can't compare strings to numbers, so we have to convert that
		local extHeal = tonumber(extHeal_raw, A)
		-- Attach realm to the Name, so we don't get duplicates
		local name, realm = UnitName(extHealName_raw)
		realm = realm and realm ~= "" and "-"..realm or ""
		local extHealName = extHealName_raw..realm

		-- v = heal
		for extHealName, v in pairs(ns.healData) do
			localHeal = v
		end

		-- initialize if nil
		if localHeal == nil then
			localHeal = 0
		end

		ns.watched[extHealName] = true
		if extHeal > localHeal then
			if ns.watched[extHealName] then
				ns.healData[extHealName] = extHeal
				ns.wham:UpdateLayout()
			end
		end
	end
	-- Everything Absorb related
	if prefix == "Wham_ABSORB" then
		-- Gathering Messages sent and converting them so we can work with them
		local extAbsorbName_raw, extAbsorb_raw = strsplit(" ", msg, 2)
		-- We can't compare strings to numbers, so we have to convert that
		local extAbsorb = tonumber(extAbsorb_raw, A)
		-- Attach realm to the Name, so we don't get duplicates
		local name, realm = UnitName(extAbsorbName_raw)
		realm = realm and realm ~= "" and "-"..realm or ""
		local extAbsorbName = extAbsorbName_raw..realm

		-- v = absorb
		for extAbsorbName, v in pairs(ns.absorbData) do
			localAbsorb = v
		end

		-- initialize if nil
		if localAbsorb == nil then
			localAbsorb = 0
		end

		ns.watched[extAbsorbName] = true		
		if extAbsorb > localAbsorb then
			if ns.watched[extAbsorbName] then
				ns.absorbData[extAbsorbName] = extAbsorb
				ns.wham:UpdateLayout()
			end
		end
	end
	if prefix == "Wham_UPDATE" then
		ns.wham:UpdateLayout()
	end
end

function ns.syncFrame:PLAYER_REGEN_DISABLED()
	if IsInRaid("player") then
		SendAddonMessage("Wham_UPDATE", nil, "RAID")
	elseif IsInGroup("player") and not IsInRaid("player") then
		SendAddonMessage("Wham_UPDATE", nil, "PARTY")
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