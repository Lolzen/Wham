--[[===============================
===		Current Fight Data		===
===============================]]--
-- Gathers Neccesary data for current fight

local addon, ns = ...
if ns.currentfightdatamodule == false then return end

ns.curFrame = CreateFrame("Frame", "curDataFrame", UIParent)
ns.curFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
ns.curFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

ns.curTotaldmg = 0
ns.curData = {}

function ns.curFrame:PLAYER_REGEN_ENABLED()
	ns.curData = {} --reset current fight data each time we're ooc
	--ns.curTotaldmg = 0
	ns.wham:UpdateLayout()
end

function ns.curFrame:COMBAT_LOG_EVENT_UNFILTERED(self, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
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
		local guid, name, dmg, over
		if(string.find(arg2, "SWING")) then
			guid, name, dmg, over = arg4, arg5, arg12, arg13
		end
		if(string.find(arg2, "RANGE")) then
			guid, name, dmg, over = arg4, arg5, arg15, arg16
		end
		if(string.find(arg2, "SPELL")) then 
			guid, name, dmg, over = arg4, arg5, arg15, arg16
		end
		
		-- This fixes a bug with dmg calculation
		if over == -1 then
			over = 0
		end

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
					--	print("Owner: "..k.." Pet: "..v)
						ns.curData[k] = (ns.curData[k] or 0) + dmg - over
					end
				end
			end
		end

		if ns.watched[name] then
			ns.curData[name] = (ns.curData[name] or 0) + dmg - over
		end
	
		ns.curTotaldmg = 0
		for _, name in pairs(ns.pos) do
			ns.curTotaldmg = (ns.curTotaldmg or 0) + (ns.curData[name] or 0)
		end
	end

	ns.wham:UpdateLayout()
end

ns.curFrame:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug (curFrame): "..event)
	end 
end)
