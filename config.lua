--[[====================
===		Config   	 ===
====================]]--
-- configuration file

local addon, ns = ...

ns.cfdGather = false				-- [Plugin] log Current Fight Data? [true/false]
ns.sync = false						-- [Plugin] sync data from other Wham users? [true/false]
ns.solo_hide = false				-- gathers no data, until in a group or raid [true/false]
ns.autoreset = false
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
