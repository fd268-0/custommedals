

#if DEPENDENCY_ULTIMATEMEDALSEXTENDED

class CustomMedal : UltimateMedalsExtended::IMedal {
    UltimateMedalsExtended::Config GetConfig() override {
        UltimateMedalsExtended::Config c;
        if (name == "") {
            name = " ";
        }
        c.defaultName = name;
        c.icon = icon;
        c.iconOverlay = secondaryIcon;
        c.nameColor = nameColor;
        return c;
    }
    string name = "";
    string icon = "";
    string secondaryIcon = "";
    string nameColor = "";
    int time = -1;
    void UpdateMedal(const string &in uid) override {}
    bool HasMedalTime(const string &in uid) override {
        return time >= 0;
    }
    uint GetMedalTime() override {
        return uint(time);
    }
}

array<CustomMedal> exports = {};
#endif
namespace ExportHandler {
    void Export() {
        KillExports();
        array<CMedal> CustomMedals = SettingHandler::GetCustomMedals();
#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
        for (uint i = 0; i < CustomMedals.Length; i++) {
            if (CustomMedals[i].Parameters.Find("noexport") >= 0) {
                continue;
            }
            CustomMedal UMEMedal;
            UMEMedal.name = CustomMedals[i].Name;
            UMEMedal.icon = CustomMedals[i].GetIcon();
            UMEMedal.time = CustomMedals[i].Time;
            UMEMedal.secondaryIcon = CustomMedals[i].SecondaryIcon;
            UMEMedal.nameColor = CustomMedals[i].NameColor;
            if (UltimateMedalsExtended::HasMedal(UMEMedal.name)) {
                continue;
            }
            UltimateMedalsExtended::AddMedal(UMEMedal);
            exports.InsertLast(UMEMedal);
        }
#endif
    }

    void KillExports() {
#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
        for (uint i = 0; i < exports.Length; i++) {
            UltimateMedalsExtended::RemoveMedal(exports[i].name);
        }
        exports = {};
#endif
    }

    
}