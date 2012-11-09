--[[========================
===		  Damagedata   	 ===
========================]]--
-- Gathers Neccesary data for Damage

local addon, ns = ...

ns.totaldmg = 0
ns.dmgData = {}

function ns.wham:COMBAT_LOG_EVENT_UNFILTERED(self, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
	if not string.find(arg2, "_DAMAGE") then return end
	
	-- If in PvPzone don't gather data
--	local _ , instanceType = IsInInstance()
--	if instanceType == "pvp" or instanceType == "arena" then return end
	
	-- Dont gather data if we are Solo
	if ns.solo_hide == true then
		-- UNTESTET
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
	
			-- Check if the unit is a NPC, Pet or Vehicle
			-- 3 = NPCs or Temporary pets, like Shadowfiend
			-- 4 = "normal" Pets, like hunterpets
			-- 5 = Vehicles
			if (unitType == 3 and ns.tempPets[name]) or unitType == 4 or unitType == 5 then
				-- k is the first string in the table - owner
				-- v is the second string attached to the first one - pet
				for k, v in pairs(ns.owners) do
					if v == name then
					--	print("Owner: "..k.." Pet: "..v)
						ns.dmgData[k] = (ns.dmgData[k] or 0) + dmg - over
					end
				end
			end
		end

		-- Add dmgvalues of the players
		if ns.watched[name] then
			ns.dmgData[name] = (ns.dmgData[name] or 0) + dmg - over
		end
	
		ns.totaldmg = 0
		for _, name in pairs(ns.pos) do
			ns.totaldmg = (ns.totaldmg or 0) + (ns.dmgData[name] or 0)
		end
		
		-- Send local data to other Wham users for syncing
		if ns.dmgData[name] then
			if IsInRaid("player") then
				SendAddonMessage("Wham_DMG", name.." "..ns.dmgData[name], "RAID")
			elseif IsInGroup("player") and not IsInRaid("player") then
				SendAddonMessage("Wham_DMG", name.." "..ns.dmgData[name], "PARTY")
			--else --DEBUGGING ONLY
				--SendAddonMessage("Wham_DMG", name.." "..ns.dmgData[name], "GUILD")
			end
		end
	end

	ns.wham:UpdateLayout()
end