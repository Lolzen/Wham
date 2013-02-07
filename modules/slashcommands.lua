--[[========================
===		Slashcommands 	 ===
========================]]--
-- Slashcommand module
-- provides executable slashcommands; type /wham for help

local addon, ns = ...
if ns.slashcommandsmodule == false then return end

local channel, wname
local paste = function(self)
	SendChatMessage("Data from Wham:", channel, nil, wname)
	for i=1, 5, 1 do
		if i and ns.modeData[ns.pos[i]] then
			if ns.activeMode == "Damage" then
				sort(ns.pos, ns.sortByDamage)
			elseif ns.activeMode == "Heal" then
				sort(ns.pos, ns.sortByHeal)
			elseif ns.activeMode == "Absorb" then
				sort(ns.pos, ns.sortByAbsorb)
			elseif ns.activeMode == "Deaths" then
				sort(ns.pos, ns.sortByDeaths)
			elseif ns.activeMode == "Dispels" then
				sort(ns.pos, ns.sortByDispels)
			elseif ns.activeMode == "Interrupts" then
				sort(ns.pos, ns.sortByinterrupts)
			end
			local curModeVal = ns.modeData[ns.pos[i]] or 0
			local class = UnitClass(ns.pos[i])
			if curModeVal then
				SendChatMessage(string.format("%d. %s - %s Done: %d (%.0f%%) [%s]", i, ns.pos[i], ns.activeMode or ns.initMode, curModeVal, curModeVal / ns.modeTotal * 100, class), channel, nil, wname)
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