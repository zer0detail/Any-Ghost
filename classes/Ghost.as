// The Ghost class really just holds the methods required to toggle on and off ghosts
// A future improvement idea is to check when the plugin is loaded if a ghost in the list is already enabled.
// At the moment we assume a ghost is off when a new Player is added to the list, but this might not always be true.
// If a ghost is on and the plugin is reloaded, the plugin will say the ghost is off, however it will be on.
// Implementing a check to see if the ghost is on and changing the state to on could be a good 1.1 change.
class Ghost {
    bool enabled; // Is the ghost enabled or disabled
    string WsId; // The players unique trackmania ID, used for toggling the ghost on/off
    string attachId; // The attachId is essentially just a unique identifier we tag this players UI layer with. Enabling us to find it in the future.

    Ghost(const string &in wsid, bool t_enabled) {
        print("Initializing Ghost for player: "+ wsid);
        enabled = t_enabled;
        WsId = wsid;
        attachId = "Force-Ghost-Attach-ID-" + wsid;    
    }

    // Enable the players ghost
    // This is done by creating a new UI layer and then injecting a script into the ManiaLinkPage
    // which fires an event to toggle a ghost on/off with a given player ID.
    // This has been taken and modified from skybaxriders work:
    // https://discord.com/channels/276076890714800129/276076890714800129/833427658523148319
    void Enable() {
        CGameManiaAppPlayground@ playground = GetApp().Network.ClientManiaAppPlayground;
        // Check through the current UI Layers and see if our players ID already exists.
        // If it does, don't bother creating a new UI Layer, just retoggle the ghost on.
        for (uint i = 0; i < playground.UILayers.Length; ++i)
        {
            if (playground.UILayers[i].AttachId == attachId)
            {
                print("Ghost layer already exists, re-enabling Ghost.");
                playground.UILayers[i].ManialinkPage = "";
                playground.UILayers[i].ManialinkPage = CreateManialink();
                return;
            }
        }
        // If a current UI layer for this player doesnt exist we make a new one and toggle the ghost on
        auto layer = playground.UILayerCreate();
        layer.AttachId = attachId;
        layer.ManialinkPage = CreateManialink();
        print("added layer: "+layer.AttachId);
    }
    
    // Disable the players ghost
    // There is probably a cleaner way to toggle the ghost off..
    // I found that but zeroing out the manialinkpage code and then adding the custom script again, it will cause the
    // toggle event to fire again, disabling the ghost.
    void Disable() {
        CGameManiaAppPlayground@ playground = GetApp().Network.ClientManiaAppPlayground;
        for (uint i = 0; i < playground.UILayers.Length; ++i) {
            auto layer = cast<CGameUILayer>(playground.UILayers[i]);
            if (layer.AttachId == attachId){
                layer.ManialinkPage = "";
                layer.ManialinkPage = CreateManialink();
                print("Ghost Disabled");
            }
        }    
    }
    
    string CreateManialink()
    {
        string ghostToggleEvent = "TMxSM_Race_Record_ToggleGhost";
        return "<script><!--"
            + "main()"
            + "{"
            + "    SendCustomEvent(\"" + ghostToggleEvent + "\", [\"" + WsId + "\"]);"
            + "}"
            + "--></script>";
    }    
}
