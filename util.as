bool canRaceGhostsCheck() {
    return Permissions::PlayRecords();
}

bool inMap(){
    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);
    return app.CurrentPlayground !is null 
        && network.ClientManiaAppPlayground !is null 
        && network.ClientManiaAppPlayground.Playground !is null 
        && network.ClientManiaAppPlayground.Playground.Map !is null;
}


