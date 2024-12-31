# Pylon Controller
This is a system where you can control your pylons and disable /enable potion effects from anywhere with just a pocket computer using Pylons and CC: Tweaked

This setup is designed around the concept of a pylon server. Each pylon server can manage 9 potion filters. You can have up to 9 pylon servers per player (both of those caps are artificial, but there are performance drawbacks to having a lot of potion filters for most of the operations; and having too many pylons managed by the system)
# Setup
## Pylon Server
1. Place down a computer with space to the blocks left, behind, and right of it.
2. Put an ender modem on the back of the computer.
3. Put an infusion pylon on the left, and make sure it's on
4. Put a barrel (or other equivalent inventory) to the right of it. 
5. Import the server program to the computer
6. Edit the Config section of the program to reflect your username and what you want this pylon to be called
7. ```move server.lua startup.lua```
8. Reboot the computer
9. Rename all of the potion filters you wish to use in an anvil with the names you'd like the effects to be called
10. Place them either in the barrel or the pylon. 


## Pylon Client
1. Make an Advanced Ender Pocket Computer
2. Import the client program to the pocket computer
3. Edit the config to reflect your username
4. ```move client.lua startup.lua```
5. Reboot the computer


# Caveats
This program was written with rednet for a small private server. As such, security is very much not a thing on this program, and probably shouldn't be used on public servers with trolls. 