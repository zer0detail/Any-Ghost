// The Ghost class really just holds the methods required to toggle on and off ghosts
// A future improvement idea is to check when the plugin is loaded if a ghost in the list is already enabled.
// At the moment we assume a ghost is off when a new Player is added to the list, but this might not always be true.
// If a ghost is on and the plugin is reloaded, the plugin will say the ghost is off, however it will be on.
// Implementing a check to see if the ghost is on and changing the state to on could be a good 1.1 change.
#if DEPENDENCY_MLHOOK
class Ghost {
    bool enabled; // Is the ghost enabled or disabled
    bool checkbox_clicked;
    bool enabling; // The ghost is in the process of turning on. This lets us provide a little loading UI feedback to the user
    string WsId; // The players unique trackmania ID, used for toggling the ghost on/off
    string attachId; // The attachId is essentially just a unique identifier we tag this players UI layer with. Enabling us to find it in the future.
    string Username; // Username for the ghost, used for checking if ghosts already exist
    MwId MwId;
    string rank;
    uint timeout;
    bool error;
    


    Ghost(const string &in wsid, bool t_enabled, string username) {
        // print("Initializing Ghost for player: "+ wsid);
        enabled = t_enabled;
        WsId = wsid;
        Username = username;  
        checkbox_clicked = false;
        timeout = 0;
        rank = "-";
    }

    // Enable the players ghost
    // This is done by creating a new UI layer and then injecting a script into the ManiaLinkPage
    // which fires an event to toggle a ghost on/off with a given player ID.
    // This has been taken and modified from skybaxriders work:
    // https://discord.com/channels/276076890714800129/276076890714800129/833427658523148319
    void Enable() {
        CGameManiaAppPlayground@ playground = GetApp().Network.ClientManiaAppPlayground;
        
        for (uint i = 0; i < playground.DataFileMgr.Ghosts.Length; ++i) {
            if (playground.DataFileMgr.Ghosts[i].Nickname == Username) {
                print("Ghost already enabled");
                return;
            }
        }
        print("Sending ToggleGhost MLHook for " + WsId);
        MLHook::Queue_SH_SendCustomEvent( "TMGame_Record_ToggleGhost", {WsId});
        
    }
    
    // Disable the players ghost
    // There is probably a cleaner way to toggle the ghost off..
    // I found that but zeroing out the manialinkpage code and then adding the custom script again, it will cause the
    // toggle event to fire again, disabling the ghost.
    void Disable() {
        CGameManiaAppPlayground@ playground = GetApp().Network.ClientManiaAppPlayground;
        bool already_disabled = true;
        for (uint i = 0; i < playground.DataFileMgr.Ghosts.Length; ++i) {
            if (playground.DataFileMgr.Ghosts[i].Nickname == Username) {
                already_disabled = false;
            }
        }
        if (already_disabled) {
            return;
        }
        MLHook::Queue_SH_SendCustomEvent( "TMGame_Record_ToggleGhost", {WsId});
    }

    void Spectate() {
        MLHook::Queue_SH_SendCustomEvent("TMGame_Record_SpectateGhost", {WsId});
    }  

    // We get the ranking on a per-ghost basis.
    // I considered just batch getting all rankings for each search that's conducted so players didn't need to 
    // activate ghosts to get a ranking displayed. But the player score isn't available until a ghost is turned on and the ghost object appears in DataFileMgr.
    // So we have to retrieve ranks one by one. To make sure we dont spam Nadeo, the ranking will only be retrieved if a ghost is enabled, and then only the first time it's enabled.
    void getRank() {
        string MapUid = GetApp().RootMap.MapInfo.MapUid;
        CGameManiaAppPlayground@ playground = GetApp().Network.ClientManiaAppPlayground;
        string score;
        while(!enabled) { 
            if(!inMap())
            {
                print("thread for "+Username+" dying");
                return;
            } 
            yield();  
            }
        for (uint i = 0; i < playground.DataFileMgr.Ghosts.Length; ++i) {
            if (playground.DataFileMgr.Ghosts[i].Nickname == Username) {
                score = tostring(playground.DataFileMgr.Ghosts[i].Result.Time);
            }
        }
        
        Json::Value rankresult = g_api.GetPlayerRank(MapUid, score);
        // Rank positions seem to be one off from the real position when returned
        // by the API, so we -1.
        rank = Json::Write(rankresult[0]['zones'][0]['ranking']['position']-1);
        print("Got rank " +rank+ " for player " + Username);
    }

    void reset() {
        // print("Reseting ghost for " + Username);
        if (enabled && inMap()) {
            Disable();
        }
        enabled = false;
        rank = "-";
        error=false;
        timeout = 0;
        enabling = false;
    }
}
#endif