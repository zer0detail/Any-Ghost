// Players represents a group of "Player" objects and state information around player searches.
// It holds a list of players, as well as trackmania.io search information used when searching
// for more players.
// Only one Players object needs to exist.
class Players {
    // PlayerList is the main array this plugin works off of.
    // Search results from trackmania.io will be parsed and the players
    // name + wsid will be appended to this list.
    // The Player objects in this list will each contain a ghost object to describe each players current ghost state.
    array<Player@> PlayerList;
    // This will be filled with the result of what the plugin user types into the searchbox in game.
    // Ideally a valid player name.
    string TMIOSearchString;
    // If a user types in a name and presses enter, this bool will be set to true.
    // Letting the main function know it can start a trackmanio.io query as it has a new search term to use.
    bool searchTMIO;

    Players() {
        searchTMIO = false; 
    }
}

// This will be called from main() whenever the Render() function sets the searchTMIO bool to true.
// Which occurs once a user presses enter after typing a players name to search.
// The function will use the trackmanio.io api to query for players whose name contains (or starts with?) that string.
// This is used to fill out the PlayerList.
void GetPlayerListFromTMIO() {
    
    print("Querying Trackmania.io for players matching term: "+ g_players.TMIOSearchString);
    
    // Build out a simple HTTP Request using openplanets API
    // https://openplanet.dev/docs/api/Net/HttpRequest
    Net::HttpRequest@ request = Net::HttpRequest();
    request.Url = "https://trackmania.io/api/players/find?search=" + g_players.TMIOSearchString;
    request.Headers["Accept"] = "application/json";
    request.Headers["Content-Type"] = "application/json";
    request.Headers["User-Agent"] = "Any Ghost Plugin v1.0";

    // Yield back execution until we receive results from trackmania.io to work with
    request.Start();
    while (!request.Finished()) yield();
    
    // Valid response, try to parse it and get players.
    if (request.ResponseCode() == 200) {

        Json::Value SearchResults;
        // Use OpenPlanet API to get the search results into a usable json object
        // https://openplanet.dev/docs/api/Json/Parse
        try {
            SearchResults = Json::Parse(request.String());
        } catch {
            error("Failed to parse Trackmania.io results: " + request.String());
            return;
        }

        // Add the returned trackmania.io search results to PlayerList so they can be Rendered.
        // SearchResults[i]['player']['id'] extracts the users WsId, which is needed to enable ghosts later.
        for(uint i = 0; i < SearchResults.Length; i++) {
            string wsid =  SearchResults[i]["player"]["id"];
            Ghost@ ghost = Ghost(wsid, false);
            g_players.PlayerList.InsertLast(Player(SearchResults[i]["player"]["name"], wsid, ghost));
        }
        print("Parsed "+SearchResults.Length+" results and added them the Player List.");
        
    } else {
        error("Request to Trackmania.io failed with error: " + request.Error());
    } 
} 



