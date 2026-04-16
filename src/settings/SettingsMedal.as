[Setting name="Enabled Display" category="Display"]
bool Enabled = true;

[Setting name="Hide N/A Times" category="Display"]
bool HideNA = false;

[Setting name="Hide PB" category="Display"]
bool HidePB = false;

[Setting name="Hide Delta" category="Display"]
bool HideDelta = false;

[Setting name="Hide Name" category="Display"]
bool HideName = false;

[Setting name="Hide Icon" category="Display"]
bool HideIcon = false;


#if DEPENDENCY_ULTIMATEMEDALSEXTENDED

[Setting name="Export To UME" category="Display"]
bool MaintainUME = true;

#endif

dictionary medalDefaults = {
    {"_Icon",Icons::Circle},
    {"_IconColor","fff"},
    {"",""},
    {"_Equation",""},
    {"_UME_SecondaryIcon",""},
    {"_UME_NameColor",""},
    {"_Params",""}
};

// fix final three showing null

dictionary icons = Icons::GetAll();

bool iconSelOpen = false;
string iconSelSearch = "";
bool updLBs = false;
bool saved = true;

string idSel = "";


namespace SettingHandler {
    dictionary jsonSettings = {};

    void LoadSettings() {
        jsonSettings = JsonLoader::JsonToDictionary("Settings.json");
    }

    void SaveSettings() {
        JsonLoader::SaveDictionaryToFile("Settings.json", jsonSettings);
    }

    void ForceMedalIntegrity(const string id) {
        for (uint i = 0; i < medalDefaults.GetKeys().Length; i++) {
            auto itemName = medalDefaults.GetKeys()[i];
            auto item = string(medalDefaults[itemName]);
            if (string(jsonSettings[id + itemName]) == "") {
                jsonSettings[id + itemName] = item;
            }
        }
    }

    string NewMdl() {
        string id = Time::get_Stamp()+"@"+Time::get_Now();
        for (uint i = 0; i < medalDefaults.GetKeys().Length; i++) {
            auto itemName = medalDefaults.GetKeys()[i];
            auto item = string(medalDefaults[itemName]);
            jsonSettings[id + itemName] = item;
        }
        MedalHandler::UpdateAllTimes();
        saved = false;
        return id;
    }

    void AddPrsMdl(const string name, const string eq) {
        string id = NewMdl();
        jsonSettings[id] = name;
        jsonSettings[id+"_Equation"] = eq;
        UI::ShowNotification("Custom Medals","Custom Medal Added! Check your Medals tab.");
        MedalHandler::UpdateAllTimes();
    }

    void DelMdl(const string id) {
        auto keys = jsonSettings.GetKeys();
        for (uint i = 0; i < keys.Length; i++) {
            auto itemName = keys[i];
            if (itemName.Contains(id)) {
                jsonSettings.Delete(itemName);
            }
        }
        MedalHandler::UpdateAllTimes();
        saved = false;
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
        if (ShowMIMedals) {
            for (uint i = 0; i < ImportingHandler::MapImports.Length; i++) {
                CustomMedals.InsertLast(ImportingHandler::MapImports[i]);
            }
        }
        updLBs = false;
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
        Medal.SecondaryIcon = string(jsonSettings[id + "_UME_SecondaryIcon"]);
        Medal.NameColor = string(jsonSettings[id + "_UME_NameColor"]);
        if (Medal.NameColor != "") {
            Medal.NameColor = "\\$" + Medal.NameColor;
        }
        Medal.Parameters = string(jsonSettings[id + "_Params"]).Split(",");
        Medal.Time = int(OperationHandler::arrayToAns(itemEquValue, string(jsonSettings[id + "_Params"])));
        return Medal;
    }

    bool InputStr(const string id, const string name, const string current, const int&in width = 150) {
        bool exit = false;
        UI::Text(name);
        UI::PushID(id);
        UI::PushItemWidth(width);
        string ctext = UI::InputText("", current, exit);
        UI::PopItemWidth();
        UI::PopID();
        jsonSettings[id] = ctext; 
        return exit;
    }

    [SettingsTab name="Medals"]
    void RenderMedalCreation() {
        if (! Permissions::ViewRecords()) {
            CDocument@ doc = CDocument("Access Denied","In order to use Custom Medals, you must get Standard or Club Access.\nWhy? You can access records through Custom Medals.",{});
            doc.generateDocumentUI();
		    return;
	    }
        UI::BeginTable("SSTable", 6, UI::TableFlags::SizingFixedFit);
        int generated = 0;
        for (uint i = 0; i < jsonSettings.GetKeys().Length; i++) {
            auto itemName = jsonSettings.GetKeys()[i];
            if (itemName.Contains("_")) {
                continue;
            }
            ForceMedalIntegrity(itemName);
            generated++;
            UI::TableNextRow();
            auto itemNameValue = string(jsonSettings[itemName]);
            auto itemIcn = itemName + "_Icon";
            auto itemIcnCol = itemName + "_IconColor";
            auto itemEqu = itemName + "_Equation";
            auto itemIcnValue = string(jsonSettings[itemIcn]);
            auto itemIcnColValue = string(jsonSettings[itemIcnCol]);
            auto itemEquValue = string(jsonSettings[itemEqu]);
            bool c1 = false;
            bool c2 = false;
            bool c3 = false;
            bool c4 = false;
            UI::TableNextColumn();
            UI::PushID(itemName);
            UI::ButtonColored("?", 0, 0, 0);
            if (UI::BeginItemTooltip()) {
                int ams = MedalHandler::getMedalTableSize()+1;
                if (UI::BeginTable("EXPTable", ams, UI::TableFlags::SizingFixedFit)) {
                    UI::TableNextColumn();
                    UI::Text("Example  " + Icons::AngleDoubleRight);
                    MedalHandler::RenderTime(IdToClass(itemName));
                    UI::EndTable();
                }
                UI::EndTooltip();
            }
            UI::PopID();
            UI::TableNextColumn();
            c1 = InputStr(itemName, "Medal Name", itemNameValue);
            UI::TableNextColumn();
            c2 = InputStr(itemEqu, "Medal Equation", itemEquValue);
            UI::TableNextColumn();
            UI::Text("Icon");
            UI::SameLine();
            if (UI::TextLink(Icons::Pencil)) {
                iconSelOpen = ! iconSelOpen;
            }
            UI::PushID(itemIcn);
            UI::PushItemWidth(50);
            jsonSettings[itemIcn] = UI::InputText("", itemIcnValue, c3);
            UI::PopItemWidth();
            UI::PopID();
            UI::TableNextColumn();
            c4 = InputStr(itemIcnCol, "Color \\$"+itemIcnColValue+""+itemIcnValue+ "\\$fff ", itemIcnColValue, 50);
            
            bool c5 = false;
            if (idSel == itemName && idSel != "") {
                auto overlayIconVal = string(SettingHandler::jsonSettings[itemName + "_UME_SecondaryIcon"]);
                auto nameColorVal = string(SettingHandler::jsonSettings[itemName + "_UME_NameColor"]);
                auto paramsVal = string(SettingHandler::jsonSettings[itemName + "_Params"]);
                int iflags = UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize;
                if (UI::Begin("\\$0f0Advanced Options", iflags)) {
                    UI::Text(itemNameValue + " \\$999id: "+itemName);
                    CMedal medal = IdToClass(itemName);
                    UI::Text("\\$0ffvalue: "+medal.Time);
                    if (medal.Time == -2) {
                        UI::Text("\\$ff0equation calculation may have failed");
                    }
#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
                    c5 = c5 || SettingHandler::InputStr(itemName+"_UME_NameColor", "UME Name Color \\$"+nameColorVal+Icons::Circle, nameColorVal, 250);
#endif 
                    Controls::BeginFrame(""+Icons::ExclamationTriangle+" Experimental Settings Ahead", true, vec4(0.5,0,0,0.5));
                    UI::Text("\\$f99Expect bugs and issues.");
#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
                    c5 = c5 || SettingHandler::InputStr(itemName+"_UME_SecondaryIcon", "UME Overlay Icon "+overlayIconVal, overlayIconVal, 80);
#endif 
                    c5 = c5 || SettingHandler::InputStr(itemName+"_Params", "Parameters", paramsVal, 220);
                    Controls::EndFrame();
                    if (UI::Button("Close")) { idSel = ""; }
                }
                UI::End();
            }
            
            UI::TableNextColumn();
            UI::PushItemWidth(50);
            UI::Text("");
            UI::PopItemWidth();
            UI::PushID(itemName+"del");
            if (UI::ButtonColored("Delete", 0, 0.5, 0.5)) {
                DelMdl(itemName);
            }
            UI::PopID();
            UI::PushID(itemName+"del");
            UI::SameLine();
            if (UI::ButtonColored("Advanced", 0.6, 0.5, 0.5)) {
                if (idSel == itemName) {
                    idSel = "";
                } else {
                    idSel = itemName;
                }
            }
            UI::PopID();


    

            if (c1 || c2 || c3 || c4 || c5) {
                MedalHandler::UpdateAllTimes();
                saved = false;
            }
        }
        UI::EndTable();
        if (UI::ButtonColored("Create "+ Icons::Plus, 0.4f, 0.5, 0.5)) {
            NewMdl();
        }
        UI::SameLine();
        if (UI::Button("Save")) {
            SaveSettings();
            saved = true;
            MedalHandler::UpdateAllTimes();
            ExportHandler::Export();
        }
        if (! saved) {
            UI::SameLine();
            UI::Text("\\$139"+Icons::ExclamationCircle+" Unsaved Changes");
        }
        if (generated > 0) {
             UI::PushFontSize(24);
            UI::Text("Quick Reference");
            UI::PopFontSize();
            UI::Text(documents[5].Description+"\n"+documents[6].Description);
            UI::Text("\\$ff0Leaderboard: \\$990"+positions.GetKeys().Length+"\\$900/10 MAX\\$990 Positions Loaded");
            if (queuedPositionsToGet.Length > 0) {
                UI::SameLine();
                UI::Text("+   \\$090"+queuedPositionsToGet.Length+" Queued Positions");
            }
            if (positions.GetKeys().Length+queuedPositionsToGet.Length >= 10 ) {
                UI::Text("\\$900Remove unwanted leaderboard requests by reloading and reduce requests to 10 if possible!");
            }
            if (UI::Button("Reload Leaderboard")) {
                updLBs = true;
                positions = {};
                MedalHandler::UpdateAllTimes();
                ExportHandler::Export();
            }
            UI::Text("\\$999" + Icons::InfoCircle + " Check the Documentation for more information.");
            UI::Text("\\$f00" + Icons::ExclamationCircle + " Work In Progress \\$900This plugin is a WIP! Expect issues as features are added.");
        } else {
            documents[documents.Length-1].generateDocumentUI();
            UI::Text("\\$999" + Icons::InfoCircle + " Create your first custom medal!");
        }
    }
}