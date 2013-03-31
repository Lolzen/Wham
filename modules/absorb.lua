--[[======================
===		Absorbdata     ===
======================]]--
-- Gathers Neccesary data for Absorb

local addon, ns = ...
if ns.absorbmodule == false then return end

ns.absorbFrame = CreateFrame("Frame", "absorbDataFrame", UIParent)

ns.totalabsorb = 0
ns.absorbData = {}

function ns.absorbFrame:Update()
	local name = ns.dstname

	if ns.missType == "ABSORB" then
		if ns.players.watched[name] then
			ns.absorbData[name] = (ns.absorbData[name] or 0) + ns.amount
		end

		ns.totalabsorb = 0
		for _, name in pairs(ns.players.rank) do
			ns.totalabsorb = (ns.totalabsorb or 0) + (ns.absorbData[name] or 0)
		end
	end

	-- Send local data to other Wham users for syncing
	if ns.absorbData[name] then
		for _, userName in pairs(ns.players.whamUsers) do
			if userName == UnitName("player") then return end
			SendAddonMessage("Wham_ABSORB", name.." "..ns.absorbData[name].." "..ns.totalabsorb, "WHISPER", userName)
			SendAddonMessage("Wham_UPDATE", nil, "WHISPER", userName)
		end
	end
end