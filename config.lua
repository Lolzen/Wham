--[[====================
===		Config   	 ===
====================]]--
-- configuration file

local addon, ns = ...

--[Module control]--
-- true = toggle module on
-- false = toggle module off
ns.absorbModule = true
ns.currentfightdatamodule = false
ns.damagemodule = true
ns.deathtrackmodule = false
ns.dispelmodule = false
ns.healmodule = true
ns.interruptmodule = false
ns.slashcommandsmodule = true
ns.syncmodule = true
ns.versioncheckmodule = true

--[Settings]--
ns.solo_hide = false				-- gathers no data, until in a group or raid [true/false]
ns.autoAcceptExternalReset = true	-- autoaccept resets from other people [true/false]
ns.width = 400
ns.height = 170

-- tempPets contains all temporary summoned pets, which will be added to the summoners/owners damage
ns.tempPets = {
	--Death knight
	["Risen Ghoul"] = true,
	--Druid
	["Treant"] = true,
	--Mage
	["Water Elemental"] = true,
	--Priest
	["Shadowfiend"] = true,
	["Shadowy Apartion"] = true, --WoW doesn't declare the owner so this is still bugged from client
	--Shaman
	["Spirit Wolf"] = true,
	["Fire Elemental"] = true,
	["Earth Elemental"] = true,
--	["Searing Totem"] = true, --test
}
