--[[============================
===		 Interruptdata   	 ===
============================]]--
-- Gathers Interrupts

local addon, ns = ...
if ns.activatedModules["Interrputs"] == false then return end

ns.interruptFrame = CreateFrame("Frame", "interruptDataFrame", UIParent)
ns.interruptFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

ns.totalinterrupts = 0
ns.interruptData = {}

function ns.interruptFrame:Update(guid, name)
	-- Add interrupts of the players
	-- [WIP] ToDo: divide into spells
	for _, guid in pairs(ns.guidDB.players) do
		ns.interruptData[name] = (ns.interruptData[name] or 0) + 1
	end

	ns.totalinterrupts = 0
	for _, name in pairs(ns.guidDB.rank) do
		ns.totalinterrupts = (ns.totalinterrupts or 0) + (ns.interruptData[name] or 0)
	end

	-- Send local data to other Wham users for syncing
	if ns.interruptData[name] then
		for _, userName in pairs(ns.guidDB.whamUsers) do
			if userName == UnitName("player") then return end
			SendAddonMessage("Wham_INTERRUPT", name.." "..ns.interruptData[name].." "..ns.totalinterrupts, "WHISPER", userName)
			SendAddonMessage("Wham_UPDATE", nil, "WHISPER", userName)
		end
	end
end