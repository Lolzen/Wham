--[[================================
===		 Damage taken Data   	 ===
================================]]--
-- Gathers Damage taken

local addon, ns = ...
if ns.damagetakenmodule == false then return end

ns.dmgTakenFrame = CreateFrame("Frame", "damageTakenDataFrame", UIParent)

ns.totaldmgtaken = 0
ns.dmgtakenData = {}

function ns.dmgTakenFrame:Update()
	local guid = ns.getGuid()
	local dstname = ns.getDstName()
	local dmg = ns.getDamage()

	if guid then
		local firstDigits = tonumber("0x"..strsub(guid, 3,5))
		local unitType = bit.band(firstDigits, 0x00f)

		if unitType == 3 then
			for _, dstname in pairs(ns.pos) do
				ns.dmgtakenData[dstname] = (ns.dmgtakenData[dstname] or 0) + dmg
			end
		end
	end

	ns.totaldmgtaken = 0
	for _, dstname in pairs(ns.pos) do
		ns.totaldmgtaken = (ns.totaldmgtaken or 0) + (ns.dmgtakenData[dstname] or 0)
	end

	-- Send local data to other Wham users for syncing		
	if ns.dmgtakenData[dstname] then
		for _, userName in pairs(ns.users) do
			if userName == UnitName("player") then return end
			SendAddonMessage("Wham_DMGTAKEN", name.." "..ns.dmgtakenData[dstname].." "..ns.totaldmgtaken, "WHISPER", userName)
			SendAddonMessage("Wham_UPDATE", nil, "WHISPER", userName)
		end
	end
end