--[[======================
===		Absorbdata     ===
======================]]--
-- Gathers Neccesary data for Absorb

local addon, ns = ...
if ns.activatedModules["Absorb"] == false then return end

ns.absorbFrame = CreateFrame("Frame", "absorbDataFrame", UIParent)

ns.totalabsorb = 0
ns.absorbData = {}

function ns.absorbFrame:Update(guid, name, missType, absorb)
	if missType == "ABSORB" then
		for _, guid in pairs(ns.guidDB.players) do
			ns.absorbData[name] = (ns.absorbData[name] or 0) + absorb
		end

		ns.totalabsorb = 0
		for _, name in pairs(ns.guidDB.rank) do
			ns.totalabsorb = (ns.totalabsorb or 0) + (ns.absorbData[name] or 0)
		end
	end

	-- Send local data to other Wham users for syncing
	if ns.absorbData[name] then
		for _, userName in pairs(ns.guidDB.whamUsers) do
			if userName == UnitName("player") then return end
			SendAddonMessage("Wham_ABSORB", name.." "..ns.absorbData[name].." "..ns.totalabsorb, "WHISPER", userName)
			SendAddonMessage("Wham_UPDATE", nil, "WHISPER", userName)
		end
	end
end