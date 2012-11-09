--[[======================
===		Absorbdata     ===
======================]]--
-- Gathers Neccesary data for Absorb
local addon, ns = ...

ns.absorbFrame = CreateFrame("Frame", "absorbDataFrame", UIParent)
ns.absorbFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

ns.totalabsorb = 0
ns.absorbData = {}

function ns.absorbFrame:COMBAT_LOG_EVENT_UNFILTERED(self, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
	if not string.find(arg2, "_HEAL") then return end
	
	if string.find(arg2, "_HEAL") then
		local name, absorb = arg5, arg17
		print(absorb)
		
		if ns.watched[name] then
			ns.absorbData[name] = (ns.absorbData[name] or 0) + absorb
			--print(absorb)
		end
		
		ns.totalabsorb = 0
		for _, name in pairs(ns.pos) do
			ns.totalabsorb = (ns.totalabsorb or 0) + (ns.absorbData[name] or 0)
			--print(ns.totalabsorb)
		end
	end
	
	ns.wham:UpdateLayout()
end

ns.absorbFrame:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug (healFrame): "..event)
	end 
end)