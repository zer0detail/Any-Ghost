// We need to store the results of players from Trackmanio.io searches so that we can
// display those results to the user (hence username) and later activate that users ghost (hence wsid) 
#if DEPENDENCY_MLHOOK
class Player {
    string Username; // Players in game display name e.g. ZerodetailTM
    bool Pinned; // Whether this player has been pinned in our player list to prevent removal
    string WsId; // The players 'under the hood' ID, needed for creating ghost events
    Ghost@ ghost; // The custom Ghost@ (Ghost.as) object which holds the methods required to toggle ghosts on and off for this player

    Player(const string &in username, const string &in wsid, Ghost@ t_ghost) {
        Username = username;
        WsId = wsid;
        Pinned = false;
        @ghost = t_ghost;
    }
}
#endif