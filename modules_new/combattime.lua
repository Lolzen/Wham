--[[========================
===		Combat Time  	 ===
========================]]--
-- Tracks combat time, providing data for xps(dps/hps/...)

local addon, ns = ...

ns.combatStartTime = 0
ns.combatCurrentTime = 0
ns.combatTotalTime = 0

ns.ctimeFrame = CreateFrame("Frame", "combatTimeDataFrame", UIParent)
ns.ctimeFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
ns.ctimeFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
ns.ctimeFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

function ns.ctimeFrame.PLAYER_REGEN_DISABLED()
	ns.combatStartTime = GetTime()
end

function ns.ctimeFrame.PLAYER_REGEN_ENABLED()
	ns.combatTotalTime = ns.combatTotalTime + GetTime() - ns.combatStartTime
	ns.combatStartTime = nil
end

function ns.ctimeFrame:COMBAT_LOG_EVENT_UNFILTERED(self, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
	ns.combatTime = ns.combatTotalTime + (ns.combatStartTime and (GetTime() - ns.combatStartTime) or 0)
	ns.curCombatTime = ns.combatTotalTime
end

ns.ctimeFrame:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug (ctimeFrame): "..event)
	end 
end)