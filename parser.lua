--[[===================
===		Parser		===
===================]]--
-- Parses the data

local addon, ns = ...

ns.parser = CreateFrame("Frame", "Parser", UIParent)
ns.parser:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

local function checkIfWatchedUnit(guid)
	local unitType
	if guid and guid ~= "" then
		unitType = bit.band(tonumber("0x"..strsub(guid, 3,5)), 0x00f)
	end

	if unitType == 8 then
		if not ns.guidDB.players[guid] then
			return false
		end
	elseif unitType == 4 or unitType == 3 then
		if not ns.guidDB.pets[guid] then
			return false
		end
	else
		return false
	end
end

local function checkForPvPZone()
	if select(2,IsInInstance()) == "pvp" or select(2,IsInInstance()) == "arena" then
		return false
	end
end

local function checkIfSolo()
	if ns.solo_hide == true then
		if not UnitInParty("player") or not UnitInRaid("player") then
			return false
		end
	end
end

function ns.parser.COMBAT_LOG_EVENT_UNFILTERED(timestamp, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)
	--==Exeptions==--	
	-- Only parse for watched units and pets
	-- Do not parse in PvP-Zones
	-- Optional: Disable parsing when no pet, or group/raidmembers are existant
	if checkIfWatchedUnit(arg4) == false or checkForPvPZone() == false or checkIfSolo() == false then return end
	
	if string.find(arg2, "_MISSED") then
		if ns.activatedModules["Absorb"] == true then
			if(string.find(arg2, "SWING")) then
				ns.absorbFrame:Update(arg4, arg5, arg12, arg14)
			end
	
			if(string.find(arg2, "RANGE")) then
				ns.absorbFrame:Update(arg4, arg5, arg15, arg17)
			end
	
			if(string.find(arg2, "SPELL")) then 
				ns.absorbFrame:Update(arg4, arg5, arg15, arg17)
			end
	
			if ns.wham.UpdateLayout then
				ns.wham:UpdateLayout()
			end
		end
	end

	if string.find(arg2, "_HEAL") then
		if ns.activatedModules["Heal"] == true then
			ns.healFrame:Update(arg4, arg5, arg15, arg16)
		
			if ns.wham.UpdateLayout then
				ns.wham:UpdateLayout()
			end
		end
	end

	if string.find(arg2, "_DAMAGE") then
			if(string.find(arg2, "SWING")) then
				if arg13 == -1 then
					arg13 = 0
				end
				if ns.activatedModules["Current Fight Data"] == true then
					ns.curFrame:Update(arg4, arg5, arg12, arg13)
				end
				if ns.activatedModules["Damage"] == true then
					ns.dmgFrame:Update(arg4, arg5, arg12, arg13)
				end
				if ns.activatedModules["Damage Taken"] == true then
					ns.dmgTakenFrame:Update(arg4, arg5, arg9, arg12)
				end
			end
	
			if(string.find(arg2, "RANGE")) then
				if arg16 == -1 then
					arg16 = 0
				end
				if ns.activatedModules["Current Fight Data"] == true then
					ns.curFrame:Update(arg4, arg5, arg15, arg16)
				end
				if ns.activatedModules["Damage"] == true then
					ns.dmgFrame:Update(arg4, arg5, arg15, arg16)
				end
				if ns.activatedModules["Damage Taken"] == true then
					ns.dmgTakenFrame:Update(arg4, arg5, arg9, arg15)
				end
			end
	
			if(string.find(arg2, "SPELL")) then
				if arg16 == -1 then
					arg16 = 0
				end
				if ns.activatedModules["Current Fight Data"] == true then
					ns.curFrame:Update(arg4, arg5, arg15, arg16)
				end
				if ns.activatedModules["Damage"] == true then
					ns.dmgFrame:Update(arg4, arg5, arg15, arg16)
				end
				if ns.activatedModules["Damage Taken"] == true then
					ns.dmgTakenFrame:Update(arg4, arg5, arg9, arg15)
				end
			end
	
			if(string.find(arg2, "ENVIRONMENTAL")) then
				if ns.activatedModules["Damage Taken"] == true then
					ns.dmgTakenFrame:Update(arg4, arg5, arg9, arg13)
				end
			end
		
		if ns.wham.UpdateLayout then
			if ns.activeMode == "Damage" or ns.activeMode == "Damage Taken" then
				ns.wham:UpdateLayout()
			end
		end
	end

	if string.find(arg2, "UNIT_DIED") then
		if ns.activatedModules["Deaths"] == true then
			ns.deathFrame:Update(arg4, arg5)
		
			if ns.wham.UpdateLayout then
				ns.wham:UpdateLayout()
			end
		end
	end

	if string.find(arg2, "_DISPEL") then
		if ns.activatedModules["Dispels"] == true then
			--ns.spellname = arg13
			ns.dispelFrame:Update(arg4, arg5)
		
			if ns.wham.UpdateLayout then
				ns.wham:UpdateLayout()
			end
		end
	end

	if string.find(arg2, "_INTERRUPT") then
		if ns.activatedModules["Interrputs"] == true then
			--ns.spellname = arg13
			ns.interruptFrame:Update(arg4, arg5)
		
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