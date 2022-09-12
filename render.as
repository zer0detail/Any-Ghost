void Render() {

    if (!canRaceGhostsCheck()) {
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
        TMIOSearchString = UI::InputText("Search", "", searchTMIO, UI::InputTextFlags::EnterReturnsTrue);
        if (searchTMIO) {
            print("Got Search " + TMIOSearchString);
            clearUnpinnedResults();
            print(PlayerList.Length);
            startnew(GetPlayerListFromTMIO);
            searchTMIO = false;
        }
        if (PlayerList.Length > 0) {
            if(UI::Button("Clear Unpinned Results")) {
                clearUnpinnedResults();
            }
        }

        UI::Separator();
        if(UI::BeginTable("Player Results", 3)){
            for (uint i =0; i < PlayerList.Length; i++) {
                UI::TableNextRow();
                UI::TableNextColumn();
                if (PlayerList[i].ghostOn) {
                    UI::Text(Icons::SnapchatGhost + " " + PlayerList[i].Username);
                } else {
                    UI::Text(PlayerList[i].Username);
                }
                UI::TableNextColumn();
                UI::PushID(PlayerList[i].WsId);
                if (!PlayerList[i].Pinned) {
                    if (UI::Button("Pin")) {
                        print("Pinned: " + PlayerList[i].Username);
                        PlayerList[i].Pinned = true;
                    }
                } else {
                    if (UI::Button("Unpin")) {
                        print("Unpinned: " + PlayerList[i].Username);
                        PlayerList[i].Pinned = false;
                    }
                }
                
                UI::TableNextColumn();
                if(UI::RadioButton("Add Ghost", PlayerList[i].ghostOn)) {
                    PlayerList[i].ghostOn = !PlayerList[i].ghostOn;
                    if (PlayerList[i].ghostOn){
                        print("Adding ghost for player "+ PlayerList[i].Username);
                        TurnOnGhost(PlayerList[i]);
                    } else {
                        print("Turning off ghost for "+ PlayerList[i].Username);
                        TurnOffGhost(PlayerList[i]);
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


void clearUnpinnedResults() {
    // Clear out all old search results, except for pinned players
    for (uint i = 0; i < PlayerList.Length; i++) {
        if (!PlayerList[i].Pinned) {
            PlayerList.RemoveAt(i);
            i--;
        } else {
            print("Leaving Pinned Player: " + PlayerList[i].Username);
        }
    }
}