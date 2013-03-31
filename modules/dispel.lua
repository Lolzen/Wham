--[[========================
===		 Dispeldata   	 ===
========================]]--
-- Gathers Dispels

local addon, ns = ...
if ns.dispelmodule == false then return end

ns.dispelFrame = CreateFrame("Frame", "dispelDataFrame", UIParent)

ns.totaldispels = 0
ns.dispelData = {}

function ns.dispelFrame:Update()
	local name = ns.name
	
	-- Add dispels of the players
	-- [WIP] ToDo: divide into spells
	if ns.players.watched[name] then
		ns.dispelData[name] = (ns.dispelData[name] or 0) + 1
	end

	ns.totaldispels = 0
	for _, name in pairs(ns.players.rank) do
		ns.totaldispels = (ns.totaldispels or 0) + (ns.dispelData[name] or 0)
	end

	-- Send local data to other Wham users for syncing
	if ns.dispelData[name] then
		for _, userName in pairs(ns.players.whamUsers) do
			if userName == UnitName("player") then return end
			SendAddonMessage("Wham_DISPEL", name.." "..ns.dispelData[name].." "..ns.totaldispels, "WHISPER", userName)
			SendAddonMessage("Wham_UPDATE", nil, "WHISPER", userName)
		end
	end
end