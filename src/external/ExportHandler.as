enum FETCHTYPE {
	Name,
	Id
}

namespace CustomMedals {
    Json::Value@ CMedalToJson(const CMedal@ medal) {
        return MedalHandler::CMedalToJson(medal);
    }
    CMedal JsonToCMedal(const Json::Value@ value) {
        return MedalHandler::JsonToCMedal(value);
    }
    Json::Value@ GetCustomMedal(const string name, const FETCHTYPE&in fetchtype = FETCHTYPE::Name) {
        Json::Value@ jsonMedal = Json::Object();
        for (uint i = 0; i < MedalHandler::medals.Length; i++) {
            string fetchValue = MedalHandler::medals[i].Name;
			if (fetchtype == FETCHTYPE::Id) {
				fetchValue = MedalHandler::medals[i].Id;
			}
            if (fetchValue != name) {
                continue;
            }
            jsonMedal = CMedalToJson(MedalHandler::medals[i]);
        }
        return jsonMedal;
    }
    string GetCustomMedalsJson() {
        Json::Value@ jsonMedals = Json::Array();
        for (uint i = 0; i < MedalHandler::medals.Length; i++) {
            if (MedalHandler::medals[i].Parameters.Split(",").Find("noexport") >= 0) {
                continue;
            }
            jsonMedals.Add(CMedalToJson(MedalHandler::medals[i]));
        }
        return Json::Write(jsonMedals);
    }
    string GetCustomMedalJson(const string name) {
        return Json::Write(GetCustomMedal(name));
    }
    bool HasCustomMedal(const string name) {
        return Json::Write(GetCustomMedal(name)["name"]) != "null";
    }
    void Refresh() {
        // WIP
    }
    void AddCustomVariable(const string name, const string value) {
        OperationHandler::globalVariables["#" + name] = value;
    }
    float Calculate(const string text) {
        return OperationHandler::arrayToAns(text);
    }
}
