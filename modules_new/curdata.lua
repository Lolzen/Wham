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
	--reset current fight data each time we're ooc
	if ns.curData then
		for name in pairs(ns.curData) do
			if not ns.players.watched[name] then
				ns.curData[name] = nil
			end
		end
	end
end

function ns.curFrame:Update(name, dmg, overdmg)
	-- Petdamage -> Ownerdamage
	for k, v in pairs(ns.players.pets) do
		if k == ns.name then
			ns.dmgData[v] = (ns.dmgData[v] or 0) + dmg - overdmg
		end
	end

	if ns.watched[name] then
		ns.curData[name] = (ns.curData[name] or 0) + dmg - overdmg
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