

enum MAPTYPE {
    Unoffical,
    TOTD,
    Campaign,
}

namespace OnlineHandler {
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

    Json::Value@ Get(const string url) {
        if (OnlineHandler::requestsSubmitted >= 10) {
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
        int totd = json.Get("totdYear");
        int campaign = json.Get("officalYear");
        if (campaign > -1) {
            return MAPTYPE::Campaign;
        }
        if (totd > -1) {
            return MAPTYPE::TOTD;
        }
        return MAPTYPE::Unoffical;
    }

    int getTimeAtPos(const int position) {
        if (position > 10000 || position < 1) {
            warn("Position invalid for request.");
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