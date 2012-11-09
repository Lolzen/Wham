--[[====================
===		Healdata   	 ===
====================]]--
-- Gathers Neccesary data for Heal
local addon, ns = ...

ns.healFrame = CreateFrame("Frame", "healDataFrame", UIParent)
ns.healFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

ns.totalheal = 0
ns.healData = {}

function ns.healFrame:COMBAT_LOG_EVENT_UNFILTERED(self, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
	if not string.find(arg2, "_HEAL") then return end
	
	if ns.solo_hide == true then
		if GetNumSubgroupMembers() == 0 or GetNumGroupMembers() == 0 and GetNumSubgroupMembers() == 0 then return end
	end
	
	if string.find(arg2, "_HEAL") then
		local name, heal, over = arg5, arg15, arg16
		
		if ns.watched[name] then
			ns.healData[name] = (ns.healData[name] or 0) + heal - over
		end
		
		ns.totalheal = 0
		for _, name in pairs(ns.pos) do
			ns.totalheal = (ns.totalheal or 0) + (ns.healData[name] or 0)
		end
		
		-- Send local data to other Wham users for syncing
		if ns.healData[name] then
			if IsInRaid("player") then
				SendAddonMessage("Wham_HEAL", name.." "..ns.healData[name], "RAID")
			elseif IsInGroup("player") and not IsInRaid("player") then
				SendAddonMessage("Wham_HEAL", name.." "..ns.healData[name], "PARTY")
			end
		
		end
	end
	
	ns.wham:UpdateLayout()
end

ns.healFrame:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug (healFrame): "..event)
	end 
end)