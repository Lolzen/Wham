--[[===================
===		Parser		===
===================]]--
-- Parses the data

local addon, ns = ...

ns.parser = CreateFrame("Frame", "Parser", UIParent)
ns.parser:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

function ns.parser.COMBAT_LOG_EVENT_UNFILTERED(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
	-- Do not parse anything in PvP-Zones
	local _ , instanceType = IsInInstance()
	if instanceType == "pvp" or instanceType == "arena" then return end

	-- Optional: Disable parsing when no pet, or group/raidmembers are existant
	if ns.solo_hide == true then
		if GetNumSubgroupMembers() == 0 or GetNumGroupMembers() == 0 and GetNumSubgroupMembers() == 0 then return end
	end

	-- Only parse for watched units and pets, otherwise do nothing
	if arg4 and arg4 ~= "" then
		local firstDigits = tonumber("0x"..strsub(arg4, 3,5))
		ns.unitType = bit.band(firstDigits, 0x00f)
		
		-- Check if the unit is a NPC, Pet, Vehicle or Player
		-- 3 = NPCs or Temporary pets, like Shadowfiend
		-- 4 = "normal" Pets, like hunterpets
		-- 5 = Vehicles
		-- 8 = Players
		if (ns.unitType == 3 and ns.tempPets[name]) or ns.unitType == 4 or ns.unitType == 5 then
			-- k is the first string in the table - owner
			-- v is the second string attached to the first one - pet
			for k, v in pairs(ns.players.pets) do
				if v ~= arg5 then return end
			end
		elseif ns.unitType == 8 then
			if not ns.players.watched[arg5] then return end
		end
	end

	ns.guid = arg4
	ns.name = arg5
	ns.dstname = arg9

	if string.find(arg2, "_MISSED") then
		if ns.absorbmodule == true then
			-- Swing, Spell & Range arguments are different
			if(string.find(arg2, "SWING")) then
				ns.missType, ns.amount = arg12, arg14
			end
	
			if(string.find(arg2, "RANGE")) then
				ns.missType, ns.amount = arg15, arg17
			end
	
			if(string.find(arg2, "SPELL")) then 
				ns.missType, ns.amount = arg15, arg17
			end
			
			ns.absorbFrame:Update()
	
			if ns.wham.UpdateLayout then
				ns.wham:UpdateLayout()
			end
		end
	end

	if string.find(arg2, "_HEAL") then
		if ns.healmodule == true then
			ns.heal, ns.overheal = arg15, arg16
			ns.healFrame:Update()
		
			if ns.wham.UpdateLayout then
				ns.wham:UpdateLayout()
			end
		end
	end

	if string.find(arg2, "_DAMAGE") then
		if ns.damagemodule == true or ns.damagetakenmodule == true or ns.currentfightdatamodule == true then
			-- Swing, Spell & Range arguments are different
			if(string.find(arg2, "SWING")) then
				ns.dmg, ns.overdmg = arg12, arg13
			end
	
			if(string.find(arg2, "RANGE")) then
				ns.dmg, ns.overdmg = arg15, arg16
			end
	
			if(string.find(arg2, "SPELL")) then 
				ns.dmg, ns.overdmg = arg15, arg16
			end
	
			if(string.find(arg2, "ENVIRONMENTAL")) then
				ns.dmg, ns.overdmg = arg13, arg14
			end
	
			-- This fixes a bug with dmg calculation
			if ns.overdmg == -1 then
				ns.overdmg = 0
			end
		end
	
		if ns.damagemodule == true then
			ns.dmgFrame:Update()
		end
	
		if ns.damagetakenmodule == true and ns.unitType == 3 then
			ns.dmgTakenFrame:Update()
		end
	
		if ns.currentfightdatamodule == true then
			ns.curFrame:Update()
		end
		
		if ns.wham.UpdateLayout then
			ns.wham:UpdateLayout()
		end
	end

	if string.find(arg2, "UNIT_DIED") then
		if ns.deathtrackmodule == true then
			ns.deathFrame:Update()
		
			if ns.wham.UpdateLayout then
				ns.wham:UpdateLayout()
			end
		end
	end

	if string.find(arg2, "_DISPEL") then
		if ns.dispelmodule == true then
			--ns.spellname = arg13
			ns.dispelFrame:Update()
		
			if ns.wham.UpdateLayout then
				ns.wham:UpdateLayout()
			end
		end
	end

	if string.find(arg2, "_INTERRUPT") then
		if ns.interruptmodule == true then
			--ns.spellname = arg13
			ns.interruptFrame:Update()
		
			if ns.wham.UpdateLayout then
				ns.wham:UpdateLayout()
			end
		end
	end
end

ns.parser:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug (Parsers): "..event)
	end 
end)