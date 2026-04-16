enum FETCHTYPE {
	Name,
	Id
}

namespace CustomMedals {
    Json::Value@ CMedalToJson(const CMedal medal) {
        Json::Value@ jsonMedal = Json::Object();
        jsonMedal["time"] = medal.Time;
        jsonMedal["isImported"] = medal.IsImported;
        jsonMedal["iconColor"] = medal.IconColor;
        jsonMedal["icon"] = medal.Icon;
        jsonMedal["name"] = medal.Name;
		jsonMedal["isPb"] = medal.IsPb;
		jsonMedal["id"] = medal.Id;
        return jsonMedal;
    }
    Json::Value@ GetCustomMedal(const string name, const FETCHTYPE fetchtype) {
        Json::Value@ jsonMedal = Json::Object();oo
        for (uint i = 0; i < Medals.Length; i++) {
			string fetchValue = Medals[i].Name;
			if (fetchtype == FETCHTYPE::Id) {
				fetchValue = Medals[i].Id;
			}
            if (fetchValue != name) {
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
	// forgot HasCustomMedal, will be included later
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
