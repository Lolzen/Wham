--[[========================
===		 Dispeldata   	 ===
========================]]--
-- Gathers Dispels

local addon, ns = ...
if ns.dispelmodule == false then return end

ns.dispelFrame = CreateFrame("Frame", "dispelDataFrame", UIParent)
ns.dispelFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

ns.totaldispels = 0
ns.dispelData = {}

function ns.dispelFrame:COMBAT_LOG_EVENT_UNFILTERED(self, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
	if not string.find(arg2, "_DISPEL") then return end

	-- If in PvPzone don't gather data
	local _ , instanceType = IsInInstance()
	if instanceType == "pvp" or instanceType == "arena" then return end

	-- Dont gather data if we are Solo
	if ns.solo_hide == true then
		if GetNumSubgroupMembers() == 0 or GetNumGroupMembers() == 0 and GetNumSubgroupMembers() == 0 then return end
	end

	if string.find(arg2, "_DISPEL") then
		local name, spellname = arg5, arg13

		-- Add dispels of the players
		-- [WIP] ToDo: divide into spells
		if ns.watched[name] then
			ns.dispelData[name] = (ns.dispelData[name] or 0) + 1
		end

		ns.totaldispels = 0
		for _, name in pairs(ns.pos) do
			ns.totaldispels = (ns.totaldispels or 0) + (ns.dispelData[name] or 0)
		end

		-- Send local data to other Wham users for syncing
		if ns.dispelData[name] then
			for _, userName in pairs(ns.users) do
				if userName == UnitName("player") then return end
				SendAddonMessage("Wham_DISPEL", name.." "..ns.dispelData[name].." "..ns.totaldispels, "WHISPER", userName)
				SendAddonMessage("Wham_UPDATE", nil, "WHISPER", userName)
			end
		end
	end

	if ns.wham.UpdateLayout then
		ns.wham:UpdateLayout()
	end
end

ns.dispelFrame:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug (interruptFrame): "..event)
	end 
end)