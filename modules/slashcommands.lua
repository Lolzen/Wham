--[[========================
===		Slashcommands 	 ===
========================]]--
-- Slashcommand module
-- provides executable slashcommands; type /wham for help

local addon, ns = ...
if ns.activatedModules["Slashcommands"] == false then return end

local channel, wname
local paste = function(self)
	SendChatMessage("Data from Wham: ["..ns.activeMode.."-Mode]", channel, nil, wname)
	for i=1, 5, 1 do
		if i and ns.modeData[ns.guidDB.rank[i]] then
			if ns.activeMode == "Damage" then
				sort(ns.guidDB.rank, ns.sortByDamage)
			elseif ns.activeMode == "Damage Taken" then
				sort(ns.guidDB.rank, ns.sortByDamageTaken)
			elseif ns.activeMode == "Heal" then
				sort(ns.guidDB.rank, ns.sortByHeal)
			elseif ns.activeMode == "OverHeal" then
				sort(ns.guidDB.rank, ns.sortByOverHeal)
			elseif ns.activeMode == "Absorb" then
				sort(ns.guidDB.rank, ns.sortByAbsorb)
			elseif ns.activeMode == "Deaths" then
				sort(ns.guidDB.rank, ns.sortByDeaths)
			elseif ns.activeMode == "Dispels" then
				sort(ns.guidDB.rank, ns.sortByDispels)
			elseif ns.activeMode == "Interrupts" then
				sort(ns.guidDB.rank, ns.sortByinterrupts)
			end
			local curModeVal = ns.modeData[ns.guidDB.rank[i]] or 0
			local class = UnitClass(ns.guidDB.rank[i]) or "Unknown"
			if curModeVal then
				SendChatMessage(string.format("%d. %s: %d (%.0f%%) [%s]", i, ns.guidDB.rank[i], curModeVal, curModeVal / ns.modeTotal * 100, class), channel, nil, wname)
			end
		end
	end
end

SLASH_WHAM1 = "/wham"
SlashCmdList["WHAM"] = function(cmd)
	local variable, name = cmd:match("^(%S*)%s*(.-)$") 
	variable = string.lower(variable)
	if variable and variable == "s" then
		channel = "SAY"
		paste()
	elseif variable and variable == "p" then
		channel = "PARTY"
		paste()
	elseif variable and variable == "g" then
		channel = "GUILD"
		paste()
	elseif variable and variable == "ra" then
		channel = "RAID"
		paste()
	elseif variable == "w" and name ~= "" then
		channel = "WHISPER"
		wname = name
		paste()
	else
		ChatFrame1:AddMessage("|cff88ffffWham:|r Valid: s/p/g/ra/w [name]")
	end
end