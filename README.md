# Any Ghost
** This plugin requires club access as it interacts with ghosts **

** This plugin also requires that you have installed the MLHook plugin **

This Trackmania 2020 plugin allows you to search for any trackmania user (that exists inside trackmania.io) and quickly enable or disable their ghost to race against, as well as spectate them.

The default trackmania interface allows users (with club access) to enable ghosts in the top 5 rankings of a given category (world, region, country, etc) as well as players one rank above and one rank below them.
However there is no quick and easy way to add arbitrary user ghosts to race against.

This plugin solves that problem, so you can now quickly enable ghosts for your favourite trackmania streamers, even when they're not good enough to be top 5 world ;)

Feel free to open an issue or submit a pull request if you have one.

# Usage

When installed and enabled, this plugin will automatically open a searchbox UI when you enter a map.
![](images/any_ghost_initial_window.png)

Simply enter a player name, or part of a player name to search for and hit enter. (e.g. to search for wirtual you can just type wirt).

![](images/any_ghost_search.png)

A list of player names who match your search will be returned from Trackmania.io.
Go ahead and click Pin icon to permanently pin that player to your ghosts list.
After that you can click "Clear unpinned results" to remove other irrelevant entries.

![](images/any_ghost_search_results.png)

You can do this over and over to build a list of ghosts you wish to race against.

![](images/any_ghost_pinned_players.png)

Once you have your list, toggle the ghost on and off by clicking the Add ghost radio button.

![](images/ghosts.png)


Click the "Spectate button to watch the ghost replay for any ghosts you've search for.

Rankings will automatically be added for any ghosts you activate.

Good Luck beating those ghosts!

# Version Log

## Version 1.0
Initial Plugin creation
- You can search for any trackmania.io user to add a ghost for
- Found players can be pinned so they dont disappear during future searches
- Click the "add ghost" radio button to toggle that players ghost on/off


## Version 1.1
- Updated logic for ghost enabled/disabled status. Ghosts are now synchronized with Nadeo leaderboard widget to enable/disable ghosts.
- Removed excess print statement to declutter openplanet log.

## Version 1.2
- Spectate any ghost you seach for
- Ladder ranking displayed for activated ghosts
- refactored ghost toggling and spectating to use MLHook. Thanks @XertroV!
- Better (imo) UI
- Activated ghosts will change the players name to green so its very obvious which ghosts are on
- Pin icon instead of a big pin/unpin button 
- Hide the plugin overlay from the plugins menu
- Visual feedback to users when a search is in progress and when a ghost is being enabled.

## Version 1.3
- Fix custom events passed to MLHook after update. (e.g. TMxSM_Race_Record_ToggleGhost becomes TMGame_Record_ToggleGhost)
- Minor fix to displayed player ranking (the returned API value appears to be off by one)