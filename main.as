bool searchTMIO = false;
string TMIOSearchString = "";
array<Player@> PlayerList;

void Main() {  
    if (canRaceGhostsCheck()){
        print("User can race record ghosts.");
    } else {
        warn("You are unable to race against record ghosts, this plugin will not work.");
        return;
    }
    while(true) {
        // Clear Active ghosts radio buttons when you're not in a map.
        if (!inMap()) {
            for (uint i = 0; i < PlayerList.Length; ++i){
                PlayerList[i].ghostOn = false;
            }
        }
        yield();
    }
    
}

bool canRaceGhostsCheck() {
    return Permissions::PlayRecords();
}

void TurnOnGhost(Player@ player) {
    string attachIdPrefix = "Force-Ghost-Attach-ID-";
    CGameManiaAppPlayground@ playground = GetApp().Network.ClientManiaAppPlayground;
    string attachId = attachIdPrefix + player.WsId;
    auto ghostID = MwFastBuffer<wstring>();
    ghostID.Add(attachId);
    for (uint i = 0; i < playground.UILayers.Length; ++i)
    {
        if (playground.UILayers[i].AttachId == attachId)
        {
            print("Ghost layer already exists, re-enabling Ghost.");
            playground.UILayers[i].ManialinkPage = "";
            playground.UILayers[i].ManialinkPage = CreateManialink(player.WsId);
            return;
        }
    }
    auto layer = playground.UILayerCreate();
    layer.AttachId = attachId;
    layer.ManialinkPage = CreateManialink(player.WsId);
    print("added layer: "+layer.AttachId);
}


void TurnOffGhost(Player@ player) {
    string attachIdPrefix = "Force-Ghost-Attach-ID-";
    string attachId = attachIdPrefix + player.WsId;
    CGameManiaAppPlayground@ playground = GetApp().Network.ClientManiaAppPlayground;
    for (uint i = 0; i < playground.UILayers.Length; ++i) {
        auto layer = cast<CGameUILayer>(playground.UILayers[i]);
        if (layer.AttachId == attachId){
            layer.ManialinkPage = "";
            layer.ManialinkPage = CreateManialink(player.WsId);
            print("Ghost Disabled");
        }
    }
        
}
void GetPlayerListFromTMIO() {
    
    print("Started with arg " + TMIOSearchString);
    Net::HttpRequest@ request = Net::HttpRequest();
    request.Url = "https://trackmania.io/api/players/find?search=" + TMIOSearchString;
    request.Headers["Accept"] = "application/json";
    request.Headers["Content-Type"] = "application/json";
    request.Headers["User-Agent"] = "Any Ghost Plugin v1.0";

    request.Start();
    while (!request.Finished()) yield();
    
    print("Request Finished.");
    if (request.ResponseCode() == 200) {
        print(request.String());
        Json::Value SearchResults = Json::Parse(request.String());
        print(SearchResults.Length);

        // Add the returned trackmania.io search results to SearchResults so they can be Rendered
        for(uint i = 0; i < SearchResults.Length; i++) {
            PlayerList.InsertLast(Player(SearchResults[i]["player"]["name"], SearchResults[i]["player"]["id"]));
        }
        print("Player list retrieved and saved. Last Player: "+ PlayerList[PlayerList.Length-1].Username);
        
    } else {
        print("Request to Trackmania.io failed with error: " + request.Error());
    } 
}

string CreateManialink(string webServicesId)
{
    string ghostToggleEvent = "TMxSM_Race_Record_ToggleGhost";
    return "<script><!--"
        + "main()"
        + "{"
        + "    SendCustomEvent(\"" + ghostToggleEvent + "\", [\"" + webServicesId + "\"]);"
        + "}"
        + "--></script>";
}

bool inMap(){
    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);
    return app.CurrentPlayground !is null 
        && network.ClientManiaAppPlayground !is null 
        && network.ClientManiaAppPlayground.Playground !is null 
        && network.ClientManiaAppPlayground.Playground.Map !is null;
}