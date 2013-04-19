--[[========================
===		  Damagedata   	 ===
========================]]--
-- Gathers Neccesary data for Damage

local addon, ns = ...
if ns.damagemodule == false then return end

ns.dmgFrame = CreateFrame("Frame", "damageDataFrame", UIParent)

ns.totaldmg = 0
ns.dmgData = {}

ns.totaloverdmg = 0
ns.overdmgData = {}

function ns.dmgFrame:Update(name, dmg, overdmg)
	-- Petdamage -> Ownerdamage
	for k, v in pairs(ns.players.pets) do
		if k == name then
			ns.dmgData[v] = (ns.dmgData[v] or 0) + dmg - overdmg
		end
	end

	-- Add dmgvalues of the players
	if ns.players.watched[name] then
		ns.dmgData[name] = (ns.dmgData[name] or 0) + dmg - overdmg
		ns.overdmgData[name] = (ns.overdmgData[name] or 0) + overdmg
	end

	ns.totaldmg = 0
	ns.totaloverdmg = 0
	for _, name in pairs(ns.players.rank) do
		ns.totaldmg = (ns.totaldmg or 0) + (ns.dmgData[name] or 0)
		ns.totaloverdmg = (ns.totaloverdmg or 0) + (ns.overdmgData[name] or 0)
	end

	-- Send local data to other Wham users for syncing		
	if ns.dmgData[name] then
		for _, userName in pairs(ns.players.whamUsers) do
			if userName == UnitName("player") then return end
			SendAddonMessage("Wham_DMG", name.." "..ns.dmgData[name].." "..ns.totaldmg, "WHISPER", userName)
			SendAddonMessage("Wham_UPDATE", nil, "WHISPER", userName)
		end
	end
end