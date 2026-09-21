

enum MAPTYPE {
    Unoffical,
    TOTD,
    Campaign,
}

namespace OnlineHandler {
    string mapId = "";
    dictionary accountIdList = {};
    int requestsSubmitted = 0;
    void Auth(const string type) {
        NadeoServices::AddAudience(type);

        while (! NadeoServices::IsAuthenticated(type)) {
            sleep(100);
        }
    }

    Net::HttpRequest@ ExternalGet(const string url) {
        Net::HttpRequest@ request = Net::HttpGet(url);

        while (! request.Finished()) {
            yield();
        }

        return request;
    }

    float GetRequestSubmittedRatio() {
        float max = 20;
        if (ReloadInterval == VariableSettings::RELOADINTERVAL::Per120s) {
            max = 10;
        }
        if (ReloadInterval == VariableSettings::RELOADINTERVAL::Per300s) {
            max = 15;
        }
        return float(OnlineHandler::requestsSubmitted)/max;
    }

    Json::Value@ Get(const string url) {
        if (GetRequestSubmittedRatio() >= 1.0) {
            warn("Hit request limit!");
            return Json::Object();
        }
        if (OnlineHandler::requestsSubmitted > 1) {
            sleep(600+float(OnlineHandler::requestsSubmitted)*200);
        }

        OnlineHandler::requestsSubmitted += 1;
        string audience = "NadeoLiveServices";
        if (url.Contains("prod.trackmania.core.nadeo.online")) {
            audience = "NadeoServices";
        }

        Auth(audience);

        auto request = NadeoServices::Get(audience, url);
        request.Start();

        while (! request.Finished()) {
            yield();
        }
        auto response = request.Json();
        return response;
    }

    MAPTYPE officalCampaignType() {
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;

        if (app.RootMap is null) {
            warn("Tried to get a time when no map was avaliable.");
            return MAPTYPE::Unoffical;
        }

        auto json = Get('https://live-services.trackmania.nadeo.live/api/campaign/map/' + track.MapInfo.MapUid );
        if (json.HasKey("totdYear")) {
            int totd = json.Get("totdYear");
            if (totd > -1) {
                return MAPTYPE::TOTD;
            }
        }
        if (json.HasKey("officalYear")) {
            int campaign = json.Get("officalYear");
            if (campaign > -1) {
                return MAPTYPE::Campaign;
            }
        }
        return MAPTYPE::Unoffical;
    }

    void getMapId() {
        if (mapId != "") {
            return;
        }
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;

        if (app.RootMap is null) {
            warn("Tried to get id when no map was avaliable.");
            return;
        }

        auto reques = Get("https://prod.trackmania.core.nadeo.online/maps/by-uid/?mapUidList=" + track.MapInfo.MapUid);
        if (reques.GetType() != Json::Type::Array) {
            warn("Returned value is not an array.");
            return;
        }
        if ((reques.Length > 0 ) ? reques[0].HasKey("mapId") : false) {
            mapId = reques[0].Get("mapId");
        }
    }

    void UpdatePlayerRecords() {
        array<string> updating = {};
        for (uint i = 0; i < accountIdList.GetKeys().Length; i++) {
            string key = accountIdList.GetKeys()[i];
            int val = int(accountIdList[key]);
            if (val == -2) {
                updating.InsertLast(key);
            }
        }
        if (updating.Length > 0) {
            getTimesFromUser(updating);
        }
    }

    void getTimesFromUser(const array<string> userIds) {
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;

        if (app.RootMap is null) {
            warn("Tried to get a time when no map was avaliable.");
            return;
        }

        OnlineHandler::getMapId();

        string scope = Records::GetScope();

        auto mapInfo = track.MapInfo;
        auto reques = Get('https://prod.trackmania.core.nadeo.online/v2/mapRecords/by-account/?accountIdList=' + Text::Join(userIds, ",") + "&mapId=" + mapId + '&gameMode=' + scope);
        for (uint i = 0; i < userIds.Length; i++) {
            accountIdList[userIds[i]] = -1;
        }
        if (reques.GetType() != Json::Type::Array) {
            warn("Returned value is not an array.");
            return;
        }
        for (uint i = 0; i < reques.Length; i++) {
            if (!reques[i].HasKey("recordScore")) {
                continue;
            }
            int time = -1;
            auto record = reques[i].Get("recordScore");
            if (scope == "Stunt") {
                time = record.Get("score");
            } else if (scope == "Platform") {
                time = record.Get("respawnCount");
            } else {
                time = record.Get("time");
            }
            accountIdList[reques[i].Get("accountId")] = time;
        }
    
    }


    int getTimeFromUser(const string userId) {
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;

        if (app.RootMap is null) {
            warn("Tried to get a time when no map was avaliable.");
            return -1;
        }

        accountIdList[userId] = -2;

        while (int(accountIdList[userId]) < -1) {
            yield();
        }
        return int(accountIdList[userId]);
    }

    int getPositionOfTime(int time = -1) {
        if (time < 0) {
            time = Records::Pb;
        }
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;

        if (app.RootMap is null) {
            warn("Tried to get a time when no map was avaliable.");
            return -1;
        }

        int pos = -1;
        auto mapInfo = track.MapInfo;
        auto reques = Get('https://live-services.trackmania.nadeo.live/api/token/leaderboard/group/Personal_Best/map/' + track.MapInfo.MapUid + "/surround/0/0?score=" + time + '&onlyWorld=true');
        
        if (reques.HasKey("tops")) {
            auto tops = reques.Get("tops");
            if ((tops.Length > 0 ) ? tops[0].HasKey("top") : false) {
                auto top = tops[0].Get("top");
                if ((top.Length > 0 ) ? top[0].HasKey("position") : false) {
                    auto keys = top[0].Get("position");
                    pos = keys;
                }
            }
        }
        return pos;
    }
 
    int getTimeAtPos(const int position) {
        if (position > 10000 || position < 1) {
            warn("Position invalid for request. Position: " + position);
            return -1;
        }
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;

        if (app.RootMap is null) {
            warn("Tried to get a time when no map was avaliable.");
            return -1;
        }

        int time = -1;
        auto mapInfo = track.MapInfo;
        auto reques = Get('https://live-services.trackmania.nadeo.live/api/token/leaderboard/group/Personal_Best/map/' + track.MapInfo.MapUid + '/top?length=1&onlyWorld=true&offset=' + (position-1));
        if (reques.HasKey("tops")) {
            auto tops = reques.Get("tops");
            if ((tops.Length > 0 ) ? tops[0].HasKey("top") : false) {
                auto top = tops[0].Get("top");
                if ((top.Length > 0 ) ? top[0].HasKey("score") : false) {
                    auto keys = top[0].Get("score");
                    time = keys;
                }
            }
        }
        return time;
    }
}