class Ghost {
    bool enabled;
    string WsId;
    string attachId;

    Ghost(const string &in wsid, bool t_enabled) {
        print("Initializing Ghost for player: "+ wsid);
        enabled = t_enabled;
        WsId = wsid;
        attachId = "Force-Ghost-Attach-ID-" + wsid;    
    }

    void Enable() {
        CGameManiaAppPlayground@ playground = GetApp().Network.ClientManiaAppPlayground;
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
        auto layer = playground.UILayerCreate();
        layer.AttachId = attachId;
        layer.ManialinkPage = CreateManialink();
        print("added layer: "+layer.AttachId);
    }
    
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
