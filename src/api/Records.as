namespace Records {
    int Pb = -1;
    MedalHandler::SCORETYPE mapType = MedalHandler::SCORETYPE::TimeAttack;

    string GetScope() {
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;
        if (track !is null) {
            auto challengeParams = track.ChallengeParameters;
            string mapTypeStr = string(challengeParams.MapType);
            string scope = "TimeAttack";
            mapType = MedalHandler::SCORETYPE::TimeAttack;
            if (track.MapInfo.TMObjective_NbClones > 0) {
                scope = "TimeAttackClone";
            }
            if (mapTypeStr.Contains("TM_Stunt")) {
                mapType = MedalHandler::SCORETYPE::Stunt;
                scope = "Stunt";
            }
            if (mapTypeStr.Contains("TM_Platform")) {
                mapType = MedalHandler::SCORETYPE::Platform;
                scope = "Platform";
            }
            return scope;
        }
        return "Menu";
    }

    bool UpdateCurrentPb() {
        int lastPb = Pb;
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;
        auto editor = app.Editor;
        auto network = cast<CTrackManiaNetwork>(app.Network);
        if (network.ClientManiaAppPlayground !is null && track !is null && editor is null) {
            auto challengeParams = track.ChallengeParameters;
            string mapTypeStr = string(challengeParams.MapType);
            auto scoreMgr = network.ClientManiaAppPlayground.ScoreMgr;
            auto userMgr = network.ClientManiaAppPlayground.UserMgr;
            auto userId = userMgr.Users[0].Id;
            string scope = GetScope();
            auto score = scoreMgr.Map_GetRecord_v2(userId, track.MapInfo.MapUid, "PersonalBest", "", scope, "");
            Pb = score;
        } else {
            Pb = -1;
        }
        if (lastPb != Pb) {
            PbUpdated();
        }
        return true;
    }
}