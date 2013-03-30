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
	local guid = ns.getGuid()
	local name = ns.getName()
	local dmg = ns.getDamage()
	local over = ns.getOverDamage()

	if guid then
		local firstDigits = tonumber("0x"..strsub(guid, 3,5))
		local unitType = bit.band(firstDigits, 0x00f)

		--check if the unit is a NPC, Pet or Vehicle
		--3 = NPCs or Temporary pets, like Shadowfiend
		--4 = "normal" Pets, like hunterpets
		--5 = Vehicles
		if (unitType == 3 and ns.tempPets[name]) or unitType == 4 or unitType == 5 then
			--k is the first string in the table - owner
			--v is the second string attached to the first one - pet
			for k, v in pairs(ns.owners) do
				if v == name then
					ns.curData[k] = (ns.curData[k] or 0) + dmg - over
				end
			end
		end
	end

	if ns.watched[name] then
		ns.curData[name] = (ns.curData[name] or 0) + dmg - over
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