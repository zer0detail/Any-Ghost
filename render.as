#if DEPENDENCY_MLHOOK
Players@ g_players;
NadeoApi@ g_api;
bool g_PluginVisible = true;
bool g_mapSwitched = false;
bool g_pluginErrorShown = false;

void Main() {
    // Simple check to stop running if the user doesnt have the right permissions to be able to
    // race against ghosts. (i.e they have purchased Club)
    if (!canRaceGhostsCheck()){
        return;
    }
    @g_api = NadeoApi();
    @g_players = Players();

}

void RenderMenu() {
    // Create the menu entry under Plugins to enable/disable the plugin from being visible
	if(UI::MenuItem("\\$db4" + Icons::SnapchatGhost + "\\$z Any Ghost", "", g_PluginVisible)) {
        g_PluginVisible = !g_PluginVisible;
	}
}

void RenderInterface() {
    int windowFlags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoDocking;
    if (!UI::IsOverlayShown()) {
        windowFlags |= UI::WindowFlags::NoInputs;
    }

    if(UI::IsOverlayShown() && inMap() && g_PluginVisible){

        UI::Begin("Player Search", windowFlags);
        if (GetApp().PlaygroundScript is null) {
            UI::Text(Meta::ExecutingPlugin().Name + " only works in Solo modes.");
            UI::End();
            return;
        }
        UI::BeginGroup();
        UI::Text("Any Ghost");
        UI::Text("Enable ghost to see player ranking");
        // If a player enters a string in the search bar, this is the first thing that will change.
        // The g_players.searchTMIO flag will be set to true and the g_players.TMIOSearchString will be filled
        // with the search string the user typed out.
        // This cause the check in Render() to pass and kick off a Trackmania.io search
        if(!g_players.searchInProgress){
            g_players.TMIOSearchString = UI::InputText("Search", "", g_players.searchTMIO, UI::InputTextFlags::EnterReturnsTrue);
        } else {
            // Make the hourglass move while we search for players from TMIO so the user knows we are doing something
            switch(g_players.IconRotation) {
                case 0:
                    g_players.Icon = Icons::HourglassO;
                    break;
                case 24:
                    g_players.Icon = Icons::HourglassStart;
                    break;
                case 48:
                    g_players.Icon = Icons::HourglassHalf;
                    break;
                case 64:
                    g_players.Icon = Icons::HourglassEnd;
                    g_players.IconRotation = -1;
                    break;
            }
            g_players.IconRotation = g_players.IconRotation+1;
            UI::Text(g_players.Icon + "Searching for " + g_players.TMIOSearchString);
        }

        // Only show the "Clear Unpinned results" button if theres atleast one player who is unpinned in the list.
        // Otherwise it doesn't really make sense to exist, and removing it keeps the overlay smaller
        for (uint i =0; i < g_players.PlayerList.Length; i++){
            if (!g_players.PlayerList[i].Pinned) {
                if(UI::Button("Clear Unpinned Results")) {
                    clearUnpinnedResults();
                }
                break;
            }
        }

        UI::Separator();
        if(UI::BeginTable("Player Results",6)){
            for (uint i =0; i < g_players.PlayerList.Length; i++) {
                UI::TableNextRow();


                UI::PushID(g_players.PlayerList[i].WsId);
                UI::TableNextColumn();
                if(UI::Button("\\$080" + Icons::Refresh)){
                    g_players.PlayerList[i].ghost.reset();
                }
                UI::TableNextColumn();
                // Flip the pin/unpin button as the user pins/unpins the player
                if (!g_players.PlayerList[i].Pinned) {
                    if (UI::Button(Icons::ThumbTack)) {
                        // print("Pinned: " + g_players.PlayerList[i].Username);
                        g_players.PlayerList[i].Pinned = true;
                    }
                } else {
                    if (UI::Button("\\$888" +Icons::ThumbTack)) {
                        // print("Unpinned: " + g_players.PlayerList[i].Username);
                        g_players.PlayerList[i].Pinned = false;
                    }
                }
                UI::TableNextColumn();
                // Colour the username green if the players ghost is enabled.
                // This gives a nice visual cue other than the checked radio box
                // that this ghost is on.
                if (g_players.PlayerList[i].ghost.enabled) {
                    UI::Text("\\$080" + g_players.PlayerList[i].Username);
                } else {
                    UI::Text(g_players.PlayerList[i].Username);
                }
                UI::TableNextColumn();



                if (UI::Button("Spectate")){
                    g_players.PlayerList[i].ghost.Spectate();
                }
                UI::TableNextColumn();
                // Trigger the Ghosts on/off based on the users input into the checkbox
                if (g_players.PlayerList[i].ghost != null) {
                    // Pass in the current active state of the ghost so we can have the checkbox display activated
                    // even if the ghost is activated somewhere else.
                    // Save the result of any user clicks to a totally different variable "checkbox_clicked".
                    // checkbox_clicked may be true or false, depending on if the user clicks the checkbox when the ghost is toggled on or off.
                    // so a check like if(checkbox_clicked) wont work, buuuut we can check if checkbox_clicked is DIFFERENT to ghost.enabled.
                    // Which will only occur if the checkbox is clicked.
                    // This lets us decouple the actions of clicking the checkbox, from the visualization of the checkbox being enabled disabled.
                    // Which is very important to let us sync with the official leaderboards ghosts being enabled/disabled
                    if (g_players.PlayerList[i].ghost.enabling) {
                        g_players.PlayerList[i].ghost.checkbox_clicked = UI::Checkbox(Icons::Spinner+"Adding", g_players.PlayerList[i].ghost.enabled);

                    } else if (g_players.PlayerList[i].ghost.error) {
                        UI::Text("\\$800" + Icons::Times + "No Ghost");
                    } else {
                        g_players.PlayerList[i].ghost.checkbox_clicked = UI::Checkbox("Add Ghost", g_players.PlayerList[i].ghost.enabled);
                        if (g_players.PlayerList[i].ghost.checkbox_clicked){
                            g_mapSwitched = false;
                        }
                    }
                    UI::TableNextColumn();

                    if (g_players.PlayerList[i].ghost.rank.Length > 0 ) {
                        UI::Text(Icons::Kenney::Podium + " " + g_players.PlayerList[i].ghost.rank);
                    }
                }

                UI::PopID();
            }
            UI::EndTable();
        }
        UI::EndGroup();
        UI::End();


        if(!g_pluginErrorShown){

        }



    }
}
void Render() {
    if (!canRaceGhostsCheck()) {
        return;
    }
    if (g_players.searchTMIO){
        // The user started a new search, so clear old unpinned results
        // since they probably didnt want them.
        // print(g_players.TMIOSearchString);
        clearUnpinnedResults();
        startnew(GetPlayerListFromTMIO);
        // Set back to false so we only search once.
        g_players.searchTMIO = false;
    }

    // If we aren't in a map we need to clear the enabled status of all the ghosts.
    // This stops us from loading into a new map and seeing that the ghosts checkbox is still enabled,
    // but the ghost is off.
    if (!inMap()) {
        g_mapSwitched = true;
        if (g_players.PlayerList.Length > 0){
            for (uint i = 0; i < g_players.PlayerList.Length; ++i){
                g_players.PlayerList[i].ghost.reset();
            }
        }
    } else if (!g_mapSwitched){
        CGameManiaAppPlayground@ playground = GetApp().Network.ClientManiaAppPlayground;
        // ghosts are added when you click enable/disable in the DataFileMgr. Which also
        // sits under ClientManiaAppPlayground.
        // So playground.DataFileMgr.Ghosts will retrieve an array of CGameGhostScript@'s
        // Each of which will contain an active ghost.
        // so we could check if wirtuals ghost is enabled by something like
        // for (uint i = 0; i < playground.DataFileMgr.Ghosts.Length; ++i)
        //    if playground.DataFileMgr.Ghosts[i].Nickname == <our ghost object>.Nickname
        //      wirtual is enabled
        for (uint i = 0; i < g_players.PlayerList.Length; ++i){
            // If the players "Add Ghost" checkbox has been clicked, do the ghost enabling/disabling
            if(g_players.PlayerList[i].ghost.checkbox_clicked != g_players.PlayerList[i].ghost.enabled) {
                if (!g_players.PlayerList[i].ghost.enabled){
                    print("Adding ghost for player "+ g_players.PlayerList[i].Username);
                    g_players.PlayerList[i].ghost.enabling = true;
                    g_players.PlayerList[i].ghost.Enable();
                } else {
                    print("Turning off ghost for "+ g_players.PlayerList[i].Username);
                    g_players.PlayerList[i].ghost.Disable();
                }
            }
            // Regardless of whether the checkbox was clicked, see if there has been a change to the ghost, so we can update its enabled state.
            // e.g if someone clicked the inbuilt leaderboard and changed the ghost state outside of our plugin
            bool ghost_exists = false;
            for (uint j = 0; j < playground.DataFileMgr.Ghosts.Length; ++j) {
                if (playground.DataFileMgr.Ghosts[j].Nickname == g_players.PlayerList[i].Username) {
                    g_players.PlayerList[i].ghost.MwId = playground.DataFileMgr.Ghosts[j].Id;
                    ghost_exists = true;
                }
            }
            if (ghost_exists) {
                g_players.PlayerList[i].ghost.enabling = false;
                g_players.PlayerList[i].ghost.enabled = true;
                g_players.PlayerList[i].ghost.timeout = 0;
                if (g_players.PlayerList[i].ghost.rank == "-" ){
                    g_players.PlayerList[i].ghost.rank = "--";
                    print("Getting rank for " + g_players.PlayerList[i].Username);
                    startnew(CoroutineFunc(g_players.PlayerList[i].ghost.getRank));
                }
            } else {
                if (g_players.PlayerList[i].ghost.enabling) {
                    g_players.PlayerList[i].ghost.timeout++;
                    if (g_players.PlayerList[i].ghost.timeout >= 1000){
                        g_players.PlayerList[i].ghost.enabling = false;
                        g_players.PlayerList[i].ghost.error = true;
                        g_players.PlayerList[i].ghost.timeout = 0;
                    }
                }
                g_players.PlayerList[i].ghost.enabled = false;
            }
        }
    }

    return;

}


void clearUnpinnedResults() {
    // Clear out all old search results, except for pinned players
    // Once this occurs, the UI stuff in RenderInterface will remove them
    // from the users sight.
    for (uint i = 0; i < g_players.PlayerList.Length; i++) {
        if (!g_players.PlayerList[i].Pinned) {
            // If the user unpins the ghost they probably don't want to see it anymore.
            // Toggle the ghost off if its enabled and reset its error/timeout/enabling/etc states.
            g_players.PlayerList[i].ghost.reset();
            g_players.PlayerList.RemoveAt(i);
            i--;
        } else {
            // print("Leaving Pinned Player: " + g_players.PlayerList[i].Username);
        }
    }
}

#else
void Main() {
    UI::ShowNotification(
        "Any Ghost Plugin Error",
        "This plugin now depends on the plugin MLHook.\nPlease install \\$000 MLHook \\$z from the Plugin Manager",
        vec4(1, 0.5, 0.2, 0),
        10000
    );
}

#endif
