--[[===================
===		Parser		===
===================]]--
-- Parses the data

local addon, ns = ...

ns.parser = CreateFrame("Frame", "Parser", UIParent)
ns.parser:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

local guid, name, dstname, dmg, overdmg, missType, amount, heal, overheal, spellname
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
		local unitType = bit.band(firstDigits, 0x00f)
		
		-- Check if the unit is a NPC, Pet, Vehicle or Player
		-- 3 = NPCs or Temporary pets, like Shadowfiend
		-- 4 = "normal" Pets, like hunterpets
		-- 5 = Vehicles
		-- 8 = Players
		if (unitType == 3 and ns.tempPets[name]) or unitType == 4 or unitType == 5 then
			-- k is the first string in the table - owner
			-- v is the second string attached to the first one - pet
			for k, v in pairs(ns.players.pets) do
				if v ~= arg5 then return end
			end
		elseif unitType == 8 then
			if not ns.players.watched[arg5] then return end
		end
	end

	guid = arg4
	name = arg5
	dstname = arg9

	if string.find(arg2, "_MISSED") then
		-- Swing, Spell & Range arguments are different
		if(string.find(arg2, "SWING")) then
			missType, amount = arg12, arg14
		end
	
		if(string.find(arg2, "RANGE")) then
			missType, amount = arg15, arg17
		end
	
		if(string.find(arg2, "SPELL")) then 
			missType, amount = arg15, arg17
		end
	
		if ns.absorbmodule == true then
			ns.absorbFrame:Update()
		end
		
		if ns.wham.UpdateLayout then
			ns.wham:UpdateLayout()
		end
	end

	if string.find(arg2, "_HEAL") then
		if ns.healmodule == true then
			heal, overheal = arg15, arg16
			ns.healFrame:Update()
		end
		
		if ns.wham.UpdateLayout then
			ns.wham:UpdateLayout()
		end
	end

	if string.find(arg2, "_DAMAGE") then
		-- Swing, Spell & Range arguments are different
		if(string.find(arg2, "SWING")) then
			dmg, overdmg = arg12, arg13
		end
	
		if(string.find(arg2, "RANGE")) then
			dmg, overdmg = arg15, arg16
		end
	
		if(string.find(arg2, "SPELL")) then 
			dmg, overdmg = arg15, arg16
		end
	
		if(string.find(arg2, "ENVIRONMENTAL")) then
			dmg, overdmg = arg13, arg14
		end
	
		-- This fixes a bug with dmg calculation
		if overdmg == -1 then
			overdmg = 0
		end
	
		if ns.damagemodule == true then
			ns.dmgFrame:Update()
		end
	
		if ns.damagetakenmodule == true then
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
		end
		
		if ns.wham.UpdateLayout then
			ns.wham:UpdateLayout()
		end
	end

	if string.find(arg2, "_DISPEL") then
		if ns.dispelmodule == true then
			spellname = arg13
			ns.dispelFrame:Update()
		end
		
		if ns.wham.UpdateLayout then
			ns.wham:UpdateLayout()
		end
	end

	if string.find(arg2, "_INTERRUPT") then
		if ns.interruptmodule == true then
			spellname = arg13
			ns.interruptFrame:Update()
		end
		
		if ns.wham.UpdateLayout then
			ns.wham:UpdateLayout()
		end
	end
end

function ns.getGuid(self)
	return guid
end

function ns.getName(self)
	return name
end

function ns.getDamage(self)
	return dmg
end

function ns.getOverDamage(self)
	return overdmg
end

function ns.getDstName(self)
	return dstname
end

function ns.getMissType(self)
	return missType
end

function ns.getAbsorbAmount(self)
	return amount
end

function ns.getHeal(self)
	return heal
end

function ns.getOverHeal(self)
	return overheal
end

function ns.getSpellName(self)
	return spellname
end

ns.parser:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug (Parsers): "..event)
	end 
end)