--[[========================
===		 Dispeldata   	 ===
========================]]--
-- Gathers Dispels

local addon, ns = ...
if ns.activatedModules["Dispels"] == false then return end

ns.dispelFrame = CreateFrame("Frame", "dispelDataFrame", UIParent)

ns.totaldispels = 0
ns.dispelData = {}

function ns.dispelFrame:Update(guid, name)
	-- Add dispels of the players
	-- [WIP] ToDo: divide into spells
	for _, guid in pairs(ns.guidDB.players) do
		ns.dispelData[name] = (ns.dispelData[name] or 0) + 1
	end

	ns.totaldispels = 0
	for _, name in pairs(ns.guidDB.rank) do
		ns.totaldispels = (ns.totaldispels or 0) + (ns.dispelData[name] or 0)
	end

	-- Send local data to other Wham users for syncing
	if ns.dispelData[name] then
		for _, userName in pairs(ns.guidDB.whamUsers) do
			if userName == UnitName("player") then return end
			SendAddonMessage("Wham_DISPEL", name.." "..ns.dispelData[name].." "..ns.totaldispels, "WHISPER", userName)
			SendAddonMessage("Wham_UPDATE", nil, "WHISPER", userName)
		end
	end
end