// We need to store the results of players from Trackmanio.io searches so that we can
// display those results to the user (hence username) and later activate that users ghost (hence wsid) 
class Player {
    string Username;
    bool Pinned;
    string WsId;
    Ghost@ ghost;

    Player(const string &in username, const string &in wsid, Ghost@ t_ghost) {
        Username = username;
        WsId = wsid;
        Pinned = false;
        @ghost = t_ghost;
    }
}