enum SCORETYPE {
    TimeAttack,
    Stunt,
    Platform,
}
class CMedal {

    string GetIcon() {
        return "\\$" + IconColor + Icon;
    }
    void UpdateIconColor(const string str) {
        if (str.Length != 3) {
            return;
        }
        IconColor = str;
    }
    int GetDeltaFromPb() {
        return Pb.Time-Time;
    }
    void UpdateExportTime() {
        ExportHandler::UpdateExport(this);
    }
    int Time = -1;
    string IconColor = "0ff";
    string Icon = "";
    string Name = "";
    bool IsPb = false;
}

CMedal Pb;
array<CMedal> Medals = {};
SCORETYPE mapType = SCORETYPE::TimeAttack;
array<int> queuedPositionsToGet = {};
dictionary positions = {};

namespace MedalHandler {
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


        NadeoServices::AddAudience("NadeoLiveServices");

        while (! NadeoServices::IsAuthenticated("NadeoLiveServices")) {
            sleep(100);
        }

        auto request = NadeoServices::Get("NadeoLiveServices", 'https://live-services.trackmania.nadeo.live/api/token/leaderboard/group/Personal_Best/map/' + track.MapInfo.MapUid + '/top?length=1&onlyWorld=true&offset=' + (position-1) );
        request.Start();

        while (! request.Finished()) {
            sleep(100);
        }
        int time = -1;
        if (app.RootMap is null) {
            warn("No map is avaliable to update the record for.");
            return -1;
        }
        auto mapInfo = track.MapInfo;
        if (request.Finished()) {
            auto reques = request.Json();
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
        }
        return time;
    }

    string FormatInt(const int num, const bool&in isForDelta = false) {
        string txt = "";
        if (mapType == SCORETYPE::TimeAttack) {
            txt = Time::Format(num, true);
        } else if (mapType == SCORETYPE::Stunt) {
            txt = ""+num;
        } else if (mapType == SCORETYPE::Platform) {
            txt = ""+num;
        }
        if (isForDelta) {
            if (mapType == SCORETYPE::Stunt) {
                if (num > 0) {
                    txt = "\\$99f+" + txt;
                } else if (num == 0) {
                    txt = "\\$999" + txt;
                } else {
                    txt = "\\$f99" + txt;
                }
            } else {
                if (num > 0) {
                    txt = "\\$f99+" + txt;
                } else if (num == 0) {
                    txt = "\\$999" + txt;
                } else {
                    txt = "\\$99f" + txt;
                }
            }
        }
        return txt;
    }

    void RenderTime(CMedal medal) {
        UI::TableNextColumn();
        string icon = medal.GetIcon();
        if (medal.Time < 0) {
            UI::BeginDisabled();
        }
        UI::Text(icon);
        UI::TableNextColumn();
        UI::Text(medal.Name);
        UI::TableNextColumn();
        if (medal.Time < 0) {
            UI::Text("N/A");
        } else {
            UI::Text(FormatInt(medal.Time));
        }
        UI::TableNextColumn();
        if (! medal.IsPb && medal.Time >= 0) {
            int delta = medal.GetDeltaFromPb();
            UI::Text(FormatInt(delta, true));
        }
        if (medal.Time < 0) {
            UI::EndDisabled();
        }
    }
    
    void AddTime(const int time, const string name, const string iconCol, const string icon, const bool&in pb = false) {
        CMedal Medal;
        Medal.Time = time;
        Medal.Name = name;
        Medal.IconColor = iconCol;
        Medal.Icon = icon;
        Medal.IsPb = pb;
        Medals.InsertLast(Medal);
    }

    void UpdateAllTimes() {
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;
        if (GetVisiblity()) {
            if (Medals == {}) {
                updLBs = true;
            }
            auto mapInfo = track.MapInfo;
            UpdateCurrentPb();
            Medals = {};
            Medals.InsertLast(Pb);
            array<CMedal> CustomMedals = SettingHandler::GetCustomMedals();
            for (uint i = 0; i < CustomMedals.Length; i++) {
                Medals.InsertLast(CustomMedals[i]);
            }
            OrderMedals();
        }
    }

    void OrderMedals() {
        Medals.Sort(function(a,b) {
            if (mapType == SCORETYPE::Stunt) {
                return a.Time > b.Time; 
            }
            return a.Time < b.Time;
        });
    }

    bool GetVisiblity() {
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;
        auto editor = app.Editor;
        return (track !is null && editor is null && Enabled);
    }

    bool UpdateCurrentPb() {
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;
        auto editor = app.Editor;
        auto network = cast<CTrackManiaNetwork>(app.Network);
        if (network.ClientManiaAppPlayground !is null && track !is null && editor is null) {
            auto challengeParams = track.ChallengeParameters;
            string mapTypeStr = string(challengeParams.MapType);
            auto scoreMgr = network.ClientManiaAppPlayground.ScoreMgr;
            auto userMgr = network.ClientManiaAppPlayground.UserMgr;
            MwId userId;
            if (userMgr.Users.Length > 0) {
                userId = userMgr.Users[0].Id;
            } else {
                userId.Value = uint(-1);
            }
            mapType = SCORETYPE::TimeAttack;
            string scope = "TimeAttack";
            if (track.MapInfo.TMObjective_NbClones > 0) {
                scope = "TimeAttackClone";
            }
            if (mapTypeStr.Contains("TM_Stunt")) {
                mapType = SCORETYPE::Stunt;
                scope = "Stunt";
            }
            if (mapTypeStr.Contains("TM_Platform")) {
                mapType = SCORETYPE::Platform;
                scope = "Platform";
            }
            auto score = scoreMgr.Map_GetRecord_v2(userId, track.MapInfo.MapUid, "PersonalBest", "", scope, "");
            Pb.Time = score;
            Pb.IsPb = true;
            Pb.Name = "\\$0ffPersonal Best";
            Pb.Icon = "";
            return true;
        }
        return false;
    }
}
