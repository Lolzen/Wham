Wham
====

A modular Dmg-Meter

INDEX:
1. Introduction
2. What is Wham?
3. The beginnings of Wham
4. What is it about?
5. Configuration
6. Slashcommands

1. Introduction
2. What is Wham?
Wham is a damage-meter addon for the game World of Warcraft.

3. The beginnings of Wham
Thank you for your interest on this project. Somewhere between The Burning Crusade and Wrath of the Lich King, 
i had interest in how the mechanics of a dmg-meter would work, and how i could get something like this to work,
from sratch. A name, you might recognize, xConStruct aka Cargor, gave me the right direction when i encountered
a hurdle i couldn't overcome. So the core mechanics are basicly most his work, which gave me the right direction
to build anything around.

4. What is it about?
Wham is nothing special, it is just another attempt to create a damage-meter.
Wham tries to be flexible, in the way it works. There are modules for a specific set of data. (Like Heal, Dispel..)
The data provided by the modules can be accessed and used for the layout.
This means you are able to create your very own layout for Wham. (think a bit like oUF)
Modifiy the look like YOU want, let the layout BEHAVE like YOU want, that's the spirit.

5. configuration
basic config is in the config.lua, inside the Wham folder.

6. Slashcommands
For a quick help inGame type "/wham", without the quotes in your chat.
Specific commands are:
/wham p
Report basic data to the Groupchannel.
/wham g
Report basic data to the Guildchannel.
/wham ra
Report basic data to the Raidchannel.
/wham w [name]
/Report basic data to a player, per whisper. example: /wham w Naarj
