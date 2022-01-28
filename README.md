## Explicit Bouncers Promod [![CodeFactor](https://www.codefactor.io/repository/github/kristiandz/ebc-pm/badge)](https://www.codefactor.io/repository/github/kristiandz/ebc-pm) ![GitHub](https://img.shields.io/github/license/kristiandz/ebc-pm)

This repository contains live code from the promod server.
The mod is stable and has all known issues solved, you can use it for your needs freely, just leave credits. Feel free to contribute to the project.

Visit us at [Explicit Bouncers](https://explicitbouncers.com) or join the [server](https://www.explicitbouncers.com/joinpromod)

## Features

- This is a mod built on a cleaned up version of [Promod V2.20](https://github.com/cod4mw/promod), only custom_public and strat modes are available, most of promod features have been removed, everything that is not needed for pub servers.
- Old bugs from promod and cod4 files have been fixed and there are updates to the code that optimize the mod and server. eBc Promod is quite a heavy mod but it will run pretty well within 100+MB of RAM than your typical promod or similar servers. Average usage for filled and active 24 slot server is around 300-350MB of RAM, or less if you restart the server daily, the mod has been running for weeks at times without any crashes or restarts.
- The mod features ranks that were removed in promod, and it also includes prestiges which was not available on PC version of the game. There are 55 levels anad 30 prestige levels. With the current settings, the players need around 4-5 months of active playing to get to level/prestige cap.
- The mod features seasons that change every 6 months, including prestige and rank reset. After each season players are awarded depending on their achieved prestige. The server runs prestige check on the players to prevent exploiting, also there is logging for quite a lot of items to easily check what is happening with the playerbase and the server.
- You can find custom viewmodels, sprays, killcards that have been ported from different mods/games, each prestige unlocks a set of rewards.
- There are 4 key menus that are available to different ranks on the server. A graphics/player settings menu, prestige awards menu, VIP menu and admin menu.
- Mod runs SQL support to expand the possibilities of the modding and access to adminmod data and other SQL db's to provide easy integration with whatever application you run.
- Mod is primarily built for S&D and S&R gametypes, but you can access some other custom gametypes as well, note that not all the gametypes from mixmod are available here.
- Mod contains plenty of features, yet keeps simplicity and a clean UI, you can find custom stuff like map voting with custom camera movement, killcards, custom commands for players and admins.
- Damage is increased by 2 points in the player_killed callback to prevent tags with sniper weapons, slowdown is disabled and FPS limit has been increased to 333. Promod checks for some DVARS and restrictions have been removed to suit pub server settings.
- And many more for you to explore and use...

## How to work on the mod

Follow these instructions to successfully run, edit and recompile the work you made

```
- Pull the code from git into your game directory "/cod4/Mods/"
- Get CoD4 Mod tools and extract it in your "/cod4/" directory
- Get CoD4X server to run post 1.7a functions that are not available in vanilla, otherwise simply run "devmap" 
  from the console after loading the mod in the game
- After you've edited the code to your liking, simply open the makeMod.bat and run build fastfile/iwd in case
  you updated assets or menu files, if you only changed the gsc/gsx files, simply change the map to load new code
- While working on the mod in game, use "/developer 1" and "/devmap map_name" for easier debugging, 
  along with the output in qconsole.log
```
Keep reading the next section for requirements, especially if you want to work on .gsx/1.7a and latter

## How to run the mod (for 1.7a+ only)

If you want to run the live and latest version of the mod you will need some dependencies

- MySQL support from [GSCLIB](https://github.com/Iswenzz/gsclib) in the form of a plugin .dll/.so file
- Custom CoD4X compilation including GSCLIB, as a custom binary that you run for your server
- Working MySQL database and access to it

Note: CoD4X binary and GSCLIB plugin will have their own dependencies, you can find them on their github pages
You will need to add custom paramenters to the startup to increase the number of xassets available to prevent errors on some big maps, also don't forget to load gsclib from config or startup, just like any other plugin

If you want to run the vanilla version of the mod, you will not have all the functionality, and you will load .gsc version of the same files.
For vanilla you don't need any dependencies, just upload the mod and run the server
All files that run .gsx should have their .gsc counterpart for vanilla server, in case some are missing, please open an issue or make a pull request

In case you don't want to run MySQL you can always opt for file storage locally, although I don't recommend it, MySQL is around 2x faster from what I've seen comparing the load and store times, and not to mention all the advantages MySQL gives. But if you are having problems with figuring out GSCLIB dependencies, you can remove the MySQL code and change to setCvar/getCvar functions.

## Required files and folders to run the mod/server

- /maps/
- /promod/
- /duffman/
- /scripts/
- /server binary
- /config.cfg
- /mod.ff
- / .iwd files, depending how you split the assets

IWD files contain /images, /sounds and /weapons

## Have fun

Thanks to everyone who contributed to this project. I hope you will make good use of it, feel free to contribute and make a pull request if you decide to make some updates.
The mod is in a nice state but there is always place for improvement, the active development of this mod has stopped and the source is being released, the mod will still recieve fixes and updates to existing features, in case someone decides to contribute with good improvements, I will help out with the work. Happy coding!
