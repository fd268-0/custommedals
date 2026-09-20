namespace VariableHandler {
    array<CVariable> variables = {};

    enum VARIABLETYPE {
        Leaderboard,
        CampaignType,
        PlayerRecord,
        Number,
    }

    array<string> prefixes = {
        "Position",
        "",
        "Account ID",
        "float",
    };

    VARIABLETYPE TypeComboBox(const string label, int currentInt) {
        VARIABLETYPE current = VARIABLETYPE(currentInt);
        if (UI::BeginCombo(label, tostring(current))) {
            for (uint i = 0; i <= VARIABLETYPE::Number; i++) {
                string enumName = tostring(VARIABLETYPE(i));
                if (UI::Selectable(enumName, enumName == tostring(current))) {
                    current = VARIABLETYPE(i);
                }
            }
            UI::EndCombo();
        }
        return current;
    }

    void ResetValues() {
        sinceLastVariableReload = 0;
        OnlineHandler::requestsSubmitted = 0;
        for (uint i = 0; i < variables.Length; i++) {
            variables[i].Completed = false;
            variables[i].Processing = false;
            variables[i].Value = -1;
        }
    }

    void ForceUpdateAsync(ref variable) {
        int idx = variables.FindByRef(cast<CVariable@>(variable));
        variables[idx].ForceUpdate();
    }

    void ForceUpdate(const CVariable@ variable) {
        startnew(ForceUpdateAsync, ref(variable));
    }

    void UpdateValuesAsync() {
        for (uint i = 0; i < variables.Length; i++) {
            if (variables[i].Type == VariableHandler::VARIABLETYPE::PlayerRecord) {
                 variables[i].UpdateValue();
            }
        }
        for (uint i = 0; i < variables.Length; i++) {
            variables[i].UpdateValue();
        }
    }

    void ForceUpdatesAsync() {
        for (uint i = 0; i < variables.Length; i++) {
            if (variables[i].Type == VariableHandler::VARIABLETYPE::PlayerRecord) {
                variables[i].ForceUpdate();
            }
        }
        for (uint i = 0; i < variables.Length; i++) {
            if (variables[i].Type != VariableHandler::VARIABLETYPE::PlayerRecord) {
                variables[i].ForceUpdate();
            }
        }
    }

    // RUN ASYNC
    void UpdateValues() {
        startnew(UpdateValuesAsync);
    }

    void ForceUpdates() {
        sinceLastVariableReload = 0;
        OnlineHandler::requestsSubmitted = 0;
        startnew(ForceUpdatesAsync);
    }



    void AddVariable(const CVariable variable) {
        variables.InsertLast(variable);
    }

    void RemoveVariable(const CVariable@ variable) {
        int idx = variables.FindByRef(variable);
        if (idx >= 0) {
            variables.RemoveAt(uint(idx));
        }
    }

    CVariable JsonToCVariable(const Json::Value@ value) {
        CVariable medal;
        medal.Active = value["active"];
        medal.Parameter = value["parameter"];
        medal.Type = value["type"];
        medal.Name = value["name"];

        return medal;
    }

    Json::Value@ CVariableToJson(const CVariable medal) {
        Json::Value@ jsonMedal = Json::Object();
        jsonMedal["active"] = medal.Active;
        jsonMedal["parameter"] = medal.Parameter;
        jsonMedal["type"] = medal.Type;
        jsonMedal["name"] = medal.Name;

        return jsonMedal;
    }

    void LoadVariables() {
        Json::Value@ medalDict = JsonLoader::GetJsonFromFile("variables.json");
        for (uint i = 0; i < medalDict.Length; i++) {
            variables.InsertLast(JsonToCVariable(medalDict[i]));
        }
    }

    void SaveVariables() {
        Json::Value@ save = Json::Array();
        for (uint i = 0; i < variables.Length; i++) {
            if (variables[i].CanSave()) {
                save.Add(CVariableToJson(variables[i]));
            }
        }
        JsonLoader::SaveJsonToFile("variables.json", save);
    }
    
}