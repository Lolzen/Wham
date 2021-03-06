--[[========================
===		  Damagedata   	 ===
========================]]--
-- Gathers Neccesary data for Damage

local addon, ns = ...
if ns.activatedModules["Damage"] == false then return end

ns.dmgFrame = CreateFrame("Frame", "damageDataFrame", UIParent)

ns.totaldmg = 0
ns.dmgData = {}

ns.totaloverdmg = 0
ns.overdmgData = {}

function ns.dmgFrame:Update(guid, name, dmg, overdmg)
	-- Petdamage -> Ownerdamage
	for _, guid in pairs(ns.guidDB.pets) do
		if guid.name == name then
			ns.dmgData[guid.owner] = (ns.dmgData[guid.owner] or 0) + dmg - overdmg
		end
	end

	-- Add dmgvalues of the players
	for _, guid in pairs(ns.guidDB.players) do
		ns.dmgData[name] = (ns.dmgData[name] or 0) + dmg - overdmg
		ns.overdmgData[name] = (ns.overdmgData[name] or 0) + overdmg
	end

	ns.totaldmg = 0
	ns.totaloverdmg = 0
	for _, name in pairs(ns.guidDB.rank) do
		ns.totaldmg = (ns.totaldmg or 0) + (ns.dmgData[name] or 0)
		ns.totaloverdmg = (ns.totaloverdmg or 0) + (ns.overdmgData[name] or 0)
	end

	-- Send local data to other Wham users for syncing		
	if ns.dmgData[name] then
		for _, userName in pairs(ns.guidDB.whamUsers) do
			if userName == UnitName("player") then return end
			SendAddonMessage("Wham_DMG", name.." "..ns.dmgData[name].." "..ns.totaldmg, "WHISPER", userName)
			SendAddonMessage("Wham_UPDATE", nil, "WHISPER", userName)
		end
	end
end