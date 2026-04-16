namespace CustomMedals {
    Json::Value@ CMedalToJson(const CMedal medal) {
        Json::Value@ jsonMedal = Json::Object();
        jsonMedal["time"] = medal.Time;
        jsonMedal["isImported"] = medal.IsImported;
        jsonMedal["iconColor"] = medal.IconColor;
        jsonMedal["icon"] = medal.Icon;
        jsonMedal["name"] = medal.Name;
		jsonMedal["isPb"] = medal.IsPb;
        return jsonMedal;
    }
    Json::Value@ GetCustomMedal(const string name) {
        Json::Value@ jsonMedal = Json::Object();
        for (uint i = 0; i < Medals.Length; i++) {
            if (Medals[i].Name != name) {
                continue;
            }
            jsonMedal = CMedalToJson(Medals[i]);
        }
        return jsonMedal;
    }
    string GetCustomMedalsJson() {
        Json::Value@ jsonMedals = Json::Array();
        for (uint i = 0; i < Medals.Length; i++) {
            if (Medals[i].Parameters.Find("noexport") >= 0) {
                continue;
            }
            jsonMedals.Add(CMedalToJson(Medals[i]));
        }
        return jsonMedals;
    }
    void Refresh() {
        ImportingHandler::GetMapImports();
		MedalHandler::UpdateAllTimes();
    }
    void AddCustomVariable(const string name, const string value) {
        OperationHandler::globalVariables["#" + name] = value;
    }
    float Calculate(const string text) {
        return OperationHandler::arrayToAns(text);
    }
}
