--[[========================
===		  Deathdata   	 ===
========================]]--
-- Tracks Deaths

local addon, ns = ...
if ns.deathtrackmodule == false then return end

ns.deathFrame = CreateFrame("Frame", "deathDataFrame", UIParent)
ns.deathFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

ns.totaldeaths = 0
ns.deathData = {}

function ns.deathFrame:COMBAT_LOG_EVENT_UNFILTERED(self, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
	if not string.find(arg2, "UNIT_DIED") then return end
	
	-- If in PvPzone don't gather data
	local _ , instanceType = IsInInstance()
	if instanceType == "pvp" or instanceType == "arena" then return end
	
	-- Dont gather data if we are Solo
	if ns.solo_hide == true then
		if GetNumSubgroupMembers() == 0 or GetNumGroupMembers() == 0 and GetNumSubgroupMembers() == 0 then return end
	end
	
	if string.find(arg2, "UNIT_DIED") then
		local name = arg9

		-- Add deathvalues of the players
		if ns.watched[name] then
			ns.deathData[name] = (ns.deathData[name] or 0) + 1
		end
	
		ns.totaldeaths = 0
		for _, name in pairs(ns.pos) do
			ns.totaldeaths = (ns.totaldeaths or 0) + (ns.deathData[name] or 0)
		end
		
		-- Send local data to other Wham users for syncing
		if ns.deathData[name] then
			if IsInGroup("player") then
				local channel = IsInRaid("player") and "RAID" or "PARTY"
				SendAddonMessage("Wham_DEATH", name.." "..ns.deathData[name].." "..ns.totaldeaths, channel)
				SendAddonMessage("Wham_UPDATE", nil, channel)
			end
		end
	end

	ns.wham:UpdateLayout()
end

ns.deathFrame:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug (deathFrame): "..event)
	end 
end)