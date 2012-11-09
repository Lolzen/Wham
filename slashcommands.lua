--[[========================
===		Slashcommands 	 ===
========================]]--
-- Slashcommand module
-- provides executable slashcommands; type /wham for help

local addon, ns = ...

local channel, wname
local paste = function(self)
	SendChatMessage("Data from Wham:", channel, nil, wname)
	for i=1, 5, 1 do
		if i and ns.dmgData[ns.pos[i]] or ns.healData[ns.pos[i]] then
			sort(ns.pos, ns.sortByDamage)
			local damage = ns.dmgData[ns.pos[i]]
			local heal = ns.healData[ns.pos[i]]
			local class = UnitClass(ns.pos[i])
			if ns.dmgData[ns.pos[i]] and ns.healData[ns.pos[i]] then
				SendChatMessage(string.format("%d. %s - Damage: %d > (%.0f%%) Heal: %d > (%.0f%%) [%s]", i, ns.pos[i], damage, damage / ns.totaldmg * 100, heal, heal / ns.totalheal * 100, class), channel, nil, wname)
			elseif ns.healData[ns.pos[i]] and not ns.dmgData[ns.pos[i]] then
				SendChatMessage(string.format("%d. %s - Healing Done: %d (%.0f%%) [%s]", i, ns.pos[i], heal, heal / ns.totalheal * 100, class), channel, nil, wname)
			elseif ns.dmgData[ns.pos[i]] and not ns.healData[ns.pos[i]] then
				SendChatMessage(string.format("%d. %s - Damage Done: %d (%.0f%%) [%s]", i, ns.pos[i], damage, damage / ns.totaldmg * 100, class), channel, nil, wname)
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
		--ChatFrame1:AddMessage("|cff88ffffWham:|r Valid: show/hide")
	end
end