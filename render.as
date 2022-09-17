Players@ g_players = Players();

void RenderInterface() {

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
        g_players.TMIOSearchString = UI::InputText("Search", "", g_players.searchTMIO, UI::InputTextFlags::EnterReturnsTrue);
       
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
        
                if (g_players.PlayerList[i].ghost.enabled) {
                    UI::Text(Icons::SnapchatGhost + " " + g_players.PlayerList[i].Username);
                } else {
                    UI::Text(g_players.PlayerList[i].Username);
                }
                UI::TableNextColumn();
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
    for (uint i = 0; i < g_players.PlayerList.Length; i++) {
        if (!g_players.PlayerList[i].Pinned) {
            g_players.PlayerList.RemoveAt(i);
            i--;
        } else {
            print("Leaving Pinned Player: " + g_players.PlayerList[i].Username);
        }
    }
}