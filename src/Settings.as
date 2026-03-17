[Setting name="Enabled Display" category="Display"]
bool Enabled = true;

[Setting name="UME Exports" category="Display"]
bool MaintainUME = true;

dictionary medalDefaults = {
    {"_Icon",Icons::Circle},
    {"_IconColor","fff"},
    {"",""},
    {"_Equation",""}
};
dictionary icons = Icons::GetAll();




namespace SettingHandler {
    dictionary jsonSettings = {};

    void LoadSettings() {
        jsonSettings = JsonLoader::JsonToDictionary("Settings.json");
    }

    void SaveSettings() {
        JsonLoader::SaveDictionaryToFile("Settings.json", jsonSettings);
    }

    void NewMdl() {
        string id = Time::get_Stamp()+"@"+Time::get_Now();
        for (uint i = 0; i < medalDefaults.GetKeys().Length; i++) {
            auto itemName = medalDefaults.GetKeys()[i];
            auto item = string(medalDefaults[itemName]);
            jsonSettings[id + itemName] = item;
        }
        SaveSettings();
    }

    void DelMdl(const string id) {
        auto keys = jsonSettings.GetKeys();
        for (uint i = 0; i < keys.Length; i++) {
            auto itemName = keys[i];
            if (itemName.Contains(id)) {
                jsonSettings.Delete(itemName);
            }
        }
        SaveSettings();
    }

    array<CMedal> GetCustomMedals() {
        array<CMedal> CustomMedals = {};
        for (uint i = 0; i < jsonSettings.GetKeys().Length; i++) {
            auto itemName = jsonSettings.GetKeys()[i];
            if (itemName.Contains("_")) {
                continue;
            }
            CustomMedals.InsertLast(IdToClass(itemName));
        }
        return CustomMedals;
    }

    CMedal IdToClass(const string id) {
        auto itemNameValue = string(jsonSettings[id]);
        auto itemIcn = id + "_Icon";
        auto itemIcnCol = id + "_IconColor";
        auto itemEqu = id + "_Equation";
        auto itemIcnValue = string(jsonSettings[itemIcn]);
        auto itemIcnColValue = string(jsonSettings[itemIcnCol]);
        auto itemEquValue = string(jsonSettings[itemEqu]);
        CMedal Medal;
        Medal.Icon = itemIcnValue;
        Medal.IconColor = itemIcnColValue;
        Medal.Name = itemNameValue;
        Medal.Time = int(OperationHandler::arrayToAns(OperationHandler::stringToArray(itemEquValue)));
        return Medal;
    }

    [SettingsTab name="Medals"]
    void RenderMedalCreation() {
        UI::BeginTable("SSTable", 5, UI::TableFlags::SizingFixedFit);
        for (uint i = 0; i < jsonSettings.GetKeys().Length; i++) {
            auto itemName = jsonSettings.GetKeys()[i];
            if (itemName.Contains("_")) {
                continue;
            }
            UI::TableNextRow();
            auto itemNameValue = string(jsonSettings[itemName]);
            auto itemIcn = itemName + "_Icon";
            auto itemIcnCol = itemName + "_IconColor";
            auto itemEqu = itemName + "_Equation";
            auto itemIcnValue = string(jsonSettings[itemIcn]);
            auto itemIcnColValue = string(jsonSettings[itemIcnCol]);
            auto itemEquValue = string(jsonSettings[itemEqu]);
            UI::TableNextColumn();
            UI::PushItemWidth(50);
            UI::Text("\\$"+itemIcnColValue+""+itemIcnValue+ "\\$fff ");
            UI::PopItemWidth();
            UI::PushID(itemName);
            if (UI::ButtonColored("Delete", 0, 0.5, 0.5)) {
                DelMdl(itemName);
            } else {
                UI::TableNextColumn();
                UI::Text("Medal Name");
                UI::PushID(itemName+"_nm");
                UI::PushItemWidth(150);
                jsonSettings[itemName] = UI::InputText("", itemNameValue);
                UI::PopItemWidth();
                UI::PopID();
                UI::TableNextColumn();
                UI::Text("Medal Equation");
                UI::PushID(itemEqu);
                UI::PushItemWidth(150);
                jsonSettings[itemEqu] = UI::InputText("", itemEquValue);
                UI::PopItemWidth();
                UI::PopID();
                UI::TableNextColumn();
                UI::Text("Icon");
                UI::PushID(itemIcn);
                UI::PushItemWidth(50);
                jsonSettings[itemIcn] = UI::InputText("", itemIcnValue);
                UI::PopItemWidth();
                UI::PopID();
                UI::TableNextColumn();
                UI::Text("Color");
                UI::PushID(itemIcnCol);
                UI::PushItemWidth(50);
                jsonSettings[itemIcnCol] = UI::InputText("", itemIcnColValue);
                 UI::PopItemWidth();
                UI::PopID();
                UI::TableNextColumn();
            }
            UI::PopID();
        }
        UI::EndTable();
        if (UI::ButtonColored("Create "+ Icons::Plus, 0.4f, 0.5, 0.5)) {
            NewMdl();
        }
        UI::SameLine();
        if (UI::Button("Save")) {
            ExportHandler::Export();
            SaveSettings();
        }
        UI::Text("\\$999" + Icons::InfoCircle + " Supported operators: + - * / ^ %");
        UI::Text("\\$999" + Icons::InfoCircle + " Supported bracketed operators: sqrt()");
        UI::Text("\\$999" + Icons::InfoCircle + " Brackets supported");
        UI::Text("\\$999" + Icons::InfoCircle + " Supported variables listed below:");
        UI::Text("\\$777Bronze - $BT");
        UI::Text("\\$777Silver - $ST");
        UI::Text("\\$777Gold - $GT");
        UI::Text("\\$777Author - $AT");
        UI::Text("\\$777Warrior - $WT \\$555Returns -1 if not avaliable.");
        UI::Text("\\$777Personal Best - $PB");
         UI::Text("\\$555Leaderboard Position times WIP.");
    }
}