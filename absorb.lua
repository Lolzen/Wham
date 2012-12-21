--[[======================
===		Absorbdata     ===
======================]]--
-- Gathers Neccesary data for Absorb
local addon, ns = ...

ns.absorbFrame = CreateFrame("Frame", "absorbDataFrame", UIParent)
ns.absorbFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

ns.totalabsorb = 0
ns.absorbData = {}

function ns.absorbFrame:COMBAT_LOG_EVENT_UNFILTERED(self, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20)
	if not string.find(arg2, "_MISSED") then return end
	
	if ns.solo_hide == true then
		if GetNumSubgroupMembers() == 0 or GetNumGroupMembers() == 0 and GetNumSubgroupMembers() == 0 then return end
	end
	
	-- Swing, Spell & Range arguments are different
	local name, missType, amount
	if(string.find(arg2, "SWING")) then
		name, missType, amount = arg9, arg12, arg14
	end
	if(string.find(arg2, "RANGE")) then
		name, missType, amount = arg9, arg15, arg17
	end
	if(string.find(arg2, "SPELL")) then 
		name, missType, amount = arg9, arg15, arg17
	end
	
	if missType == "ABSORB" then
		if ns.watched[name] then
			ns.absorbData[name] = (ns.absorbData[name] or 0) + amount
		end
	
		ns.totalabsorb = 0
		for _, name in pairs(ns.pos) do
			ns.totalabsorb = (ns.totalabsorb or 0) + (ns.absorbData[name] or 0)
		end
	end
	
	-- Send local data to other Wham users for syncing
	if ns.absorbData[name] then
		if IsInRaid("player") then
			SendAddonMessage("Wham_ABSORB", name.." "..ns.absorbData[name], "RAID")
			SendAddonMessage("Wham_UPDATE", nil, "RAID")
		elseif IsInGroup("player") and not IsInRaid("player") then
			SendAddonMessage("Wham_ABSORB", name.." "..ns.absorbData[name], "PARTY")
			SendAddonMessage("Wham_UPDATE", nil, "PARTY")
		end	
	end
	
	ns.wham:UpdateLayout()
end

ns.absorbFrame:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug (absorbFrame): "..event)
	end 
end)