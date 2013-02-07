--[[================================
===		 Damage taken Data   	 ===
================================]]--
-- Gathers Damage taken

local addon, ns = ...
if ns.damagetakenmodule == false then return end

ns.dmgTakenFrame = CreateFrame("Frame", "damageTakenDataFrame", UIParent)
ns.dmgTakenFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

ns.totaldmgtaken = 0
ns.dmgtakenData = {}

function ns.dmgTakenFrame:COMBAT_LOG_EVENT_UNFILTERED(self, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
	if not string.find(arg2, "_DAMAGE") then return end

	-- If in PvPzone don't gather data
	local _ , instanceType = IsInInstance()
	if instanceType == "pvp" or instanceType == "arena" then return end

	-- Dont gather data if we are Solo
	if ns.solo_hide == true then
		if GetNumSubgroupMembers() == 0 or GetNumGroupMembers() == 0 and GetNumSubgroupMembers() == 0 then return end
	end

	if string.find(arg2, "_DAMAGE") then
		-- Swing, Spell & Range arguments are different
		local guid, dstname, dmg
		if(string.find(arg2, "SWING")) then
			guid, dstname, dmg = arg4, arg9, arg12
		end
		if(string.find(arg2, "RANGE")) then
			guid, dstname, dmg = arg4, arg9, arg15
		end
		if(string.find(arg2, "SPELL")) then 
			guid, dstname, dmg = arg4, arg9, arg15
		end

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
				SendAddonMessage("Wham_DMG", name.." "..ns.dmgtakenData[name].." "..ns.totaldmgtaken, "WHISPER", userName)
				SendAddonMessage("Wham_UPDATE", nil, "WHISPER", userName)
			end
		end
	end

	if ns.wham.UpdateLayout then
		ns.wham:UpdateLayout()
	end
end

ns.dmgTakenFrame:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug (dmgTakenFrame): "..event)
	end 
end)