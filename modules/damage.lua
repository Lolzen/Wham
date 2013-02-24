--[[========================
===		  Damagedata   	 ===
========================]]--
-- Gathers Neccesary data for Damage

local addon, ns = ...
if ns.damagemodule == false then return end

ns.dmgFrame = CreateFrame("Frame", "damageDataFrame", UIParent)

ns.totaldmg = 0
ns.dmgData = {}

ns.totaloverdmg = 0
ns.overdmgData = {}

function ns.dmgFrame:Update()
	local name = ns.getName()
	local guid = ns.getGuid()
	local dmg = ns.getDamage()
	local over = ns.getOverDamage()

	if guid then
		local firstDigits = tonumber("0x"..strsub(guid, 3,5))
		local unitType = bit.band(firstDigits, 0x00f)

		-- Check if the unit is a NPC, Pet or Vehicle
		-- 3 = NPCs or Temporary pets, like Shadowfiend
		-- 4 = "normal" Pets, like hunterpets
		-- 5 = Vehicles
		if (unitType == 3 and ns.tempPets[name]) or unitType == 4 or unitType == 5 then
			-- k is the first string in the table - owner
			-- v is the second string attached to the first one - pet
			for k, v in pairs(ns.owners) do
				if v == name then
					ns.dmgData[k] = (ns.dmgData[k] or 0) + dmg - over
				end
			end
		end
	end

	-- Add dmgvalues of the players
	if ns.watched[name] then
		ns.dmgData[name] = (ns.dmgData[name] or 0) + dmg - over
		ns.overdmgData[name] = (ns.overdmgData[name] or 0) + over
	end

	ns.totaldmg = 0
	ns.totaloverdmg = 0
	for _, name in pairs(ns.pos) do
		ns.totaldmg = (ns.totaldmg or 0) + (ns.dmgData[name] or 0)
		ns.totaloverdmg = (ns.totaloverdmg or 0) + (ns.overdmgData[name] or 0)
	end

	-- Send local data to other Wham users for syncing		
	if ns.dmgData[name] then
		for _, userName in pairs(ns.users) do
			if userName == UnitName("player") then return end
			SendAddonMessage("Wham_DMG", name.." "..ns.dmgData[name].." "..ns.totaldmg, "WHISPER", userName)
			SendAddonMessage("Wham_UPDATE", nil, "WHISPER", userName)
		end
	end
end