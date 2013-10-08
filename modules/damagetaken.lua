--[[================================
===		 Damage taken Data   	 ===
================================]]--
-- Gathers Damage taken

local addon, ns = ...
if ns.activatedModules["Damage Taken"] == false then return end

ns.dmgTakenFrame = CreateFrame("Frame", "damageTakenDataFrame", UIParent)

ns.totaldmgtaken = 0
ns.dmgtakenData = {}

function ns.dmgTakenFrame:Update(guid, name, dstname, dmg)
	if ns.unitType == 3 then
		for _, dstname in pairs(ns.guidDB.rank) do
			ns.dmgtakenData[dstname] = (ns.dmgtakenData[dstname] or 0) + dmg
			ns.totaldmgtaken = (ns.totaldmgtaken or 0) + (ns.dmgtakenData[dstname] or 0)
		end
	end

	-- Send local data to other Wham users for syncing		
	if ns.dmgtakenData[dstname] then
		for _, userName in pairs(ns.guidDB.whamUsers) do
			if userName == UnitName("player") then return end
			SendAddonMessage("Wham_DMGTAKEN", ns.name.." "..ns.dmgtakenData[dstname].." "..ns.totaldmgtaken, "WHISPER", userName)
			SendAddonMessage("Wham_UPDATE", nil, "WHISPER", userName)
		end
	end
end