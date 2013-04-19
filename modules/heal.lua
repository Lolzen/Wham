--[[====================
===		Healdata   	 ===
====================]]--
-- Gathers Neccesary data for Heal

local addon, ns = ...
if ns.healmodule == false then return end

ns.healFrame = CreateFrame("Frame", "healDataFrame", UIParent)

ns.totalheal = 0
ns.healData = {}

ns.totaloverheal = 0
ns.overhealData = {}

function ns.healFrame:Update(name, heal, overheal)
	if ns.players.watched[name] then
		ns.healData[name] = (ns.healData[name] or 0) + heal - overheal
		ns.overhealData[name] = (ns.overhealData[name] or 0) + overheal
	end

	ns.totalheal = 0
	ns.totaloverheal = 0
	for _, name in pairs(ns.players.rank) do
		ns.totalheal = (ns.totalheal or 0) + (ns.healData[name] or 0)
		ns.totaloverheal = (ns.totaloverheal or 0) + (ns.overhealData[name] or 0)
	end

	-- Send local data to other Wham users for syncing
	if ns.healData[name] then
		for _, userName in pairs(ns.players.whamUsers) do
			if userName == UnitName("player") then return end
			SendAddonMessage("Wham_HEAL", name.." "..ns.healData[name].." "..ns.totalheal, "WHISPER", userName)
			SendAddonMessage("Wham_UPDATE", nil, "WHISPER", userName)
		end
	end
end