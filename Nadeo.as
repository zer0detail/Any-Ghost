// Lovingly pilfered from XertoV
// https://github.com/XertroV/tm-too-many-ghosts/blob/master/src/Main.as

class NadeoApi {
    string liveSvcUrl;

    NadeoApi() {
        NadeoServices::AddAudience("NadeoLiveServices");
        liveSvcUrl = NadeoServices::BaseURLLive();
    }

    Json::Value GetPlayerRank(const string &in mapUid, const string &in score) {
        string url = liveSvcUrl+"/api/token/leaderboard/group/map?scores["+ mapUid +"]="+score;
        auto body = '{"maps": [{"mapUid": "'+mapUid+'","groupUid": "Personal_Best"}]}';
        return FetchLiveEndpoint(url, body);
    }
}

Json::Value FetchLiveEndpoint(const string &in route, const string &in body) {
    while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) { yield(); }
    
    auto req = NadeoServices::Post("NadeoLiveServices", route, body);
    req.Start();
    while(!req.Finished()) { yield(); }
    return Json::Parse(req.String());
}