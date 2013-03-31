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
ns.damagetakenmodule = true
ns.deathtrackmodule = true
ns.dispelmodule = true
ns.healmodule = true
ns.interruptmodule = true
ns.slashcommandsmodule = true
ns.syncmodule = true
ns.versioncheckmodule = true

--[Settings]--
ns.initMode = "Damage"				-- Select which mode to display per standard [Damage, Heal, Absorb, Deaths, Dispels, Interrupts]
ns.solo_hide = false				-- gathers no data, until in a group or raid [true/false]
ns.autoAcceptExternalReset = true	-- !Depends on sync module! autoaccept resets from other people [true/false]
ns.cleanOnGrpChange = false			-- Purge data gathered, from players left the raid/group [true/false]
ns.width = 250
ns.height = 90

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
}
