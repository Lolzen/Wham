--[[===========================
===		VersionChecker		===
===========================]]--
-- checks for version

local addon, ns = ...
if ns.activatedModules["Versioncheck"] == false then return end

local localversion = GetAddOnMetadata("Wham", "Version")

-- Send local version to other Wham users for version check
for _, userName in pairs(ns.guidDB.whamUsers) do
	if userName == UnitName("player") then return end
	SendAddonMessage("Wham_VERSION", localversion, "WHISPER", userName)
end

ns.verFrame = CreateFrame("Frame", "verFrame", UIParent)
ns.verFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ns.verFrame:RegisterEvent("CHAT_MSG_ADDON")

function ns.verFrame:PLAYER_ENTERING_WORLD()
	RegisterAddonMessagePrefix("Wham_VERSION")
end

function ns.verFrame:CHAT_MSG_ADDON(self, arg1, arg2, arg3, arg4)
	local prefix, msg, channel, sender = arg1, arg2, arg3, arg4
	if prefix == "Wham_VERSION" then
		local extversion = msg
		if extversion > localversion then
			print("New version of |cff88ffffWham:|r detected! (v "..extversion..") Please consider updating.")
		elseif extversion < localversion then
			print("|cff88ffffWham:|r |cffff4444Warning:|r "..sender.." has an old version of Wham installed (v "..extversion..") Syncing data may lead to errors or data corruption")
		end
	end
end

ns.verFrame:SetScript("OnEvent", function(self, event, ...)  
	if(self[event]) then
		self[event](self, event, ...)
	else
		print("Wham debug (verFrame): "..event)
	end 
end)