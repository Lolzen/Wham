--[[===============================
===		Current Fight Data		===
===============================]]--
-- Gathers Neccesary data for current fight

local addon, ns = ...
if ns.currentfightdatamodule == false then return end

ns.curFrame = CreateFrame("Frame", "curDataFrame", UIParent)
ns.curFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

ns.curTotaldmg = 0
ns.curData = {}

function ns.curFrame:PLAYER_REGEN_ENABLED()
	ns.curData = {} --reset current fight data each time we're ooc
	ns.wham:UpdateLayout()
end

function ns.curFrame:Update()
	local name = ns.name

	-- Petdamage -> Ownerdamage
	for k, v in pairs(ns.players.pets) do
		if v == ns.name then
			ns.dmgData[k] = (ns.dmgData[k] or 0) + ns.dmg - ns.overdmg
		end
	end

	if ns.watched[name] then
		ns.curData[name] = (ns.curData[name] or 0) + ns.dmg - ns.overdmg
	end

	ns.curTotaldmg = 0
	for _, name in pairs(ns.players.rank) do
		ns.curTotaldmg = (ns.curTotaldmg or 0) + (ns.curData[name] or 0)
	end
end

ns.curFrame:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug (curFrame): "..event)
	end 
end)