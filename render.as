Players@ g_players = Players(); // I made it global. Sue me.

void RenderInterface() {

    // Simple check to stop running if the user doesnt have the right permissions to be able to
    // race against ghosts. (i.e they have purchased Club)
    if (!canRaceGhostsCheck()){
        return;
    }
    int windowFlags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoDocking;
    if (!UI::IsOverlayShown()) {
        windowFlags |= UI::WindowFlags::NoInputs;
    }

    if(UI::IsOverlayShown() && inMap()){
        UI::Begin("Player Search", windowFlags);
        UI::BeginGroup();
        UI::Text("Any Ghost");
        // If a player enters a string in the search bar, this is the first thing that will change.
        // The g_players.searchTMIO flag will be set to true and the g_players.TMIOSearchString will be filled
        // with the search string the user typed out.
        // This cause the check in Render() to pass and kick off a Trackmania.io search
        g_players.TMIOSearchString = UI::InputText("Search", "", g_players.searchTMIO, UI::InputTextFlags::EnterReturnsTrue);
       
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
        if(UI::BeginTable("Player Results", 3)){
            for (uint i =0; i < g_players.PlayerList.Length; i++) {
                UI::TableNextRow();
                UI::TableNextColumn();
                // Load the snapchat ghost icon is the players ghost is enabled.
                // This gives a nice visual cue other than the checked radio box
                // that this ghost is on.
                if (g_players.PlayerList[i].ghost.enabled) {
                    UI::Text(Icons::SnapchatGhost + " " + g_players.PlayerList[i].Username);
                } else {
                    UI::Text(g_players.PlayerList[i].Username);
                }
                UI::TableNextColumn();
                // Flip the pin/unpin button as the user pins/unpins the player
                UI::PushID(g_players.PlayerList[i].WsId);
                if (!g_players.PlayerList[i].Pinned) {
                    if (UI::Button("Pin")) {
                        print("Pinned: " + g_players.PlayerList[i].Username);
                        g_players.PlayerList[i].Pinned = true;
                    }
                } else {
                    if (UI::Button("Unpin")) {
                        print("Unpinned: " + g_players.PlayerList[i].Username);
                        g_players.PlayerList[i].Pinned = false;
                    }
                }
                UI::TableNextColumn();
                // Trigger the Ghosts on/off based on the users input into the checkbox
                if (g_players.PlayerList[i].ghost != null) {
                    bool checked = UI::Checkbox("Add Ghost", g_players.PlayerList[i].ghost.enabled);
                    if(checked != g_players.PlayerList[i].ghost.enabled) {
                        g_players.PlayerList[i].ghost.enabled = !g_players.PlayerList[i].ghost.enabled;       
                        if (g_players.PlayerList[i].ghost.enabled){
                            print("Adding ghost for player "+ g_players.PlayerList[i].Username);
                            g_players.PlayerList[i].ghost.Enable();
                        } else {
                            print("Turning off ghost for "+ g_players.PlayerList[i].Username);
                            g_players.PlayerList[i].ghost.Disable();
                        }                 
                    }
                }     
                UI::PopID();
            }
            UI::EndTable();
        }
        UI::EndGroup();
        UI::End();
    }
}
void Render() {
    if (!canRaceGhostsCheck()) {
        return;
    }
    if (g_players.searchTMIO){
        // The user started a new search, so clear old unpinned results
        // since they probably didnt want them.
        print(g_players.TMIOSearchString);
        clearUnpinnedResults();
        startnew(GetPlayerListFromTMIO);
        // Set back to false so we only search once.
        g_players.searchTMIO = false;
    } 
    
    // If we aren't in a map we need to clear the enabled status of all the ghosts.
    // This stops us from loading into a new map and seeing that the ghosts checkbox is still enabled,
    // but the ghost is off.
    if (!inMap()) {
        if (g_players.PlayerList.Length > 0){
            for (uint i = 0; i < g_players.PlayerList.Length; ++i){
                g_players.PlayerList[i].ghost.enabled = false;
            }
        }
    }
}


void clearUnpinnedResults() {
    // Clear out all old search results, except for pinned players
    // Once this occurs, the UI stuff in RenderInterface will remove them
    // from the users sight.
    for (uint i = 0; i < g_players.PlayerList.Length; i++) {
        if (!g_players.PlayerList[i].Pinned) {
            g_players.PlayerList.RemoveAt(i);
            i--;
        } else {
            print("Leaving Pinned Player: " + g_players.PlayerList[i].Username);
        }
    }
}