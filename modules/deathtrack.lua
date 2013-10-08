--[[========================
===		  Deathdata   	 ===
========================]]--
-- Tracks Deaths

local addon, ns = ...
if ns.activatedModules["Deaths"] == false then return end

ns.deathFrame = CreateFrame("Frame", "deathDataFrame", UIParent)

ns.totaldeaths = 0
ns.deathData = {}

function ns.deathFrame:Update(guid, name)
	-- Add deathvalues of the players
	for _, guid in pairs(ns.guidDB.players) do
		ns.deathData[name] = (ns.deathData[name] or 0) + 1
	end

	ns.totaldeaths = 0
	for _, name in pairs(ns.guidDB.rank) do
		ns.totaldeaths = (ns.totaldeaths or 0) + (ns.deathData[name] or 0)
	end

	-- Send local data to other Wham users for syncing
	if ns.deathData[name] then
		for _, userName in pairs(ns.guidDB.whamUsers) do
			if userName == UnitName("player") then return end
			SendAddonMessage("Wham_DEATH", name.." "..ns.deathData[name].." "..ns.totaldeaths, "WHISPER", userName)
			SendAddonMessage("Wham_UPDATE", nil, "WHISPER", userName)
		end
	end
end