// We need to store the results of players from Trackmanio.io searches so that we can
// display those results to the user (hence username) and later activate that users ghost (hence wsid) 
class Player {
    string Username;
    string WsId;
    bool Pinned;
    bool ghostOn;

    Player(const string &in username, const string &in wsid) {
        Username = username;
        WsId = wsid;
        Pinned = false;
        ghostOn = false;
    }
}