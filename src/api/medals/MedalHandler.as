namespace MedalHandler {
    array<CMedal> medals = {};

    enum SCORETYPE {
        TimeAttack,
        Stunt,
        Platform,
    }

    array<CMedal> GetActiveMedals() {
        array<CMedal> activeMedals = {};
        for (uint i = 0; i < medals.Length; i++) {
            if (medals[i].Active == true) {
                activeMedals.InsertLast(medals[i]);
            }
        }
        return activeMedals;
    }

    CMedal JsonToCMedal(const Json::Value@ value) {
        CMedal medal;
        medal.Time = value["time"];
        medal.IsImported = value["isImported"];
        medal.IsPb = value["isPb"];
        medal.IconColor = value["iconColor"];
        medal.Icon = value["icon"];
        medal.Name = value["name"];
        medal.Id = value["id"];
        medal.Calculation = value["calculation"];
        medal.Parameters = value["parameters"];

        medal.SecondaryIcon = value["secondaryIcon"];
        medal.NameColor = value["nameColor"];
        medal.Active = value["active"];

        return medal;
    }

    Json::Value@ CMedalToJson(const CMedal medal) {
        Json::Value@ jsonMedal = Json::Object();
        jsonMedal["time"] = medal.Time;
        jsonMedal["isImported"] = medal.IsImported;
        jsonMedal["isPb"] = medal.IsPb;
        jsonMedal["iconColor"] = medal.IconColor;
        jsonMedal["icon"] = medal.Icon;
        jsonMedal["name"] = medal.Name;
        jsonMedal["id"] = medal.Id;
        jsonMedal["calculation"] = medal.Calculation;
        jsonMedal["parameters"] = medal.Parameters;

        jsonMedal["secondaryIcon"] = medal.SecondaryIcon;
        jsonMedal["nameColor"] = medal.NameColor;
        jsonMedal["active"] = medal.Active;

        return jsonMedal;
    }

    void UpdateValues() {
        for (uint i = 0; i < medals.Length; i++) {
            medals[i].Calculate();
        }
        MedalsUpdated();
    }

    void AddMedal(const CMedal medal) {
        medals.InsertLast(medal);
    }

    void CreatePbTemplate() {
        CMedal medal;
        medal.Calculation = "$PB";
        medal.Name = "Personal Best";
        medal.Icon = "";
        medal.NameColor = "0ff";
        medal.Parameters = "noexport";
        medals.InsertLast(medal);
        UpdateValues();
    }

    void RemoveMedal(const CMedal@ medal) {
        int idx = medals.FindByRef(medal);
        if (idx >= 0) {
            medals.RemoveAt(uint(idx));
        }
    }

    void LoadMedals() {
        Json::Value@ medalDict = JsonLoader::GetJsonFromFile("settings.json");
        for (uint i = 0; i < medalDict.Length; i++) {
            medals.InsertLast(JsonToCMedal(medalDict[i]));
        }
    }

    void SaveMedals() {
        Json::Value@ save = Json::Array();
        for (uint i = 0; i < medals.Length; i++) {
            if (medals[i].CanSave()) {
                save.Add(CMedalToJson(medals[i]));
            }
        }
        JsonLoader::SaveJsonToFile("settings.json", save);
    }

    array<CMedal> OrderMedals(array<CMedal> medals) {
        MedalHandler::SCORETYPE scoring = Records::mapType;
        if (scoring == MedalHandler::SCORETYPE::Stunt) {
            medals.Sort(function(a,b) {
                return a.Time > b.Time;
            });
        } else {
            medals.Sort(function(a,b) {
                return a.Time < b.Time;
            });
        }
        return medals;
    }
}