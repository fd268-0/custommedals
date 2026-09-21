class CMedal {

    string GetIcon() {
        string icon = Icon;
        if (IconColor != "") {
            icon = "\\$" + IconColor + icon;
        }
        return icon;
    }

    void UpdateIconColor(const string str) {
        if (str.Length != 3) {
            return;
        }
        IconColor = str;
    }

    int GetDeltaFromPb() {
        return Records::Pb - Time;
    }

    int Calculate() {
        Time = int(OperationHandler::arrayToAns(Calculation, Parameters));
        return Time;
    }

    string Format(const int delta, const bool&in isForDelta = false) {
        MedalHandler::SCORETYPE mapType = Records::mapType;
        string txt = "";
        if (mapType == MedalHandler::SCORETYPE::TimeAttack) {
            txt = Time::Format(delta, true);
        } else if (mapType == MedalHandler::SCORETYPE::Stunt) {
            txt = ""+delta;
        } else if (mapType == MedalHandler::SCORETYPE::Platform) {
            txt = ""+delta;
        }
        if (isForDelta) {
            if (mapType == MedalHandler::SCORETYPE::Stunt) {
                if (delta > 0) {
                    txt = "\\$99f+" + txt;
                } else if (delta == 0) {
                    txt = "\\$999" + txt;
                } else {
                    txt = "\\$f99" + txt;
                }
            } else {
                if (delta > 0) {
                    txt = "\\$f99+" + txt;
                } else if (delta == 0) {
                    txt = "\\$999" + txt;
                } else {
                    txt = "\\$99f" + txt;
                }
            }
            if (Calculation == "$PB") {
                return "";
            }
        }
        return txt;
    }

    void RenderTime() {
        UI::TableNextColumn();
        string icon = GetIcon();
        if (Time < 0) {
            UI::BeginDisabled();
        }
        if (! HideIcon) {
            UI::Text(icon);
            UI::TableNextColumn();
        }
        if (! HideName) {
            UI::Text("\\$" + NameColor + Name);
            UI::TableNextColumn();
        }
        if (Time < 0) {
            UI::Text("\\$" + NameColor + "N/A");
        } else {
            UI::Text("\\$" + NameColor + Format(Time));
        }
        if (! IsPb && Time >= 0 && Records::Pb > 0 && ! HideDelta) {
            UI::TableNextColumn();
            UI::Text(Format(GetDeltaFromPb(), true));
        }
        if (Time < 0) {
            UI::EndDisabled();
        }
    }



    // c 7 (a:8)
    void RenderEditor(string&in idpre = "") {

        idpre = idpre + Id;

        UI::PushID(idpre+"preview");
        UI::TableNextColumn();
        UI::ButtonColored(GetIcon(), 0.0, 0.0, 0.0);
        if (UI::BeginItemTooltip()) {
            int ams = RenderHandler::GetMedalTableSize()+1;
            if (UI::BeginTable("EXPTable", ams, UI::TableFlags::SizingFixedFit)) {
                UI::TableNextColumn();
                UI::Text("Example  " + Icons::AngleDoubleRight);
                RenderTime();
                UI::EndTable();
            }
            UI::EndTooltip();
        }
        UI::PopID();

        UI::TableNextColumn();
        InputResult NameResult = UIR::InputText(150, idpre + "name", "", Name);

        UI::TableNextColumn();
        InputResult CalculationResult = UIR::InputText(250, idpre + "calc", "", Calculation);

        UI::TableNextColumn();
        InputResult IconColorResult = UIR::InputColor3(200, idpre + "iconcolor", "", RenderHandler::StrToVec3(IconColor));

        UI::TableNextColumn();
        InputResult IconResult = UIR::InputText(100, idpre + "icon", "", Icon);

        UI::PushID(idpre+"Del");
        UI::TableNextColumn();
        if (UI::ButtonColored("Del", 0)) {
            MedalHandler::RemoveMedal(this);
        }
        UI::PopID();

        UI::PushID(idpre+"Adv");
        UI::TableNextColumn();
        if (UI::ButtonColored("Adv", 0.3, 0.2, 0.2)) {
            AdvancedActive = !AdvancedActive;
        }
        UI::PopID();

        if (AdvancedActive) {
            UI::TableNextColumn();
            UI::Text("");
            UI::TableNextColumn();
            UI::Text("\\$0f0Name Color");
            InputResult NameColorResult = UIR::InputColor3(150, idpre + "nc", "", RenderHandler::StrToVec3(NameColor));
            UI::TableNextColumn();
            UI::Text("\\$0f0Parameters");
            InputResult ParametersResult = UIR::InputText(250, idpre + "parameters", "", Parameters);

#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
            UI::TableNextColumn();
            UI::Text("\\$0ffUME \\$0f0Overlay Color");
            InputResult SecondaryIconColorResult = UIR::InputColor3(200, idpre + "sic", "", RenderHandler::StrToVec3(SecondaryIcon.SubStr(2,3)));
            UI::TableNextColumn();
            UI::Text("\\$0ffUME \\$0f0Overlay");
            InputResult OverlayIconResult = UIR::InputText(100, idpre + "ovi", "", SecondaryIcon.SubStr(5));
            SecondaryIcon = "\\$" + Text::FormatGameColor(SecondaryIconColorResult.vec3).SubStr(1,3) + OverlayIconResult.string;
#endif
            Parameters = ParametersResult.string;
            NameColor = Text::FormatGameColor(NameColorResult.vec3).SubStr(1,3);
        }

        Name = NameResult.string;
        Calculation = CalculationResult.string;
        IconColor = Text::FormatGameColor(IconColorResult.vec3).SubStr(1,3);
        Icon = IconResult.string;
    }

    bool CanSave() {
        return ((IsPb || IsImported) == false);
    }


    int Time = -1;
    string Calculation = "";
    string IconColor = "bbb";
    string Icon = Icons::Circle;
    string Name = "";

    // UME
    string SecondaryIcon = "";
    string NameColor = "fff";
    // UME

    string Id = "";

    string Parameters = "";
    bool IsPb = false;
    bool IsImported = false;
    bool Active = true;

    bool AdvancedActive = false;
}