namespace RenderHandler {
    bool GetVisiblity() {
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;
        auto editor = app.Editor;
        return (track !is null && editor is null && Enabled);
    }

    bool HasPermissions() {
        if (! Permissions::ViewRecords()) {
            CDocument@ doc = CDocument("Access Denied","In order to use Custom Medals, you must get Standard or Club Access.\nWhy? You can access records through Custom Medals.",{});
            doc.generateDocumentUI();
		    return false;
	    } else {
            return true;
        }
    }

    int GetMedalTableSize() {
        int ams = 4;
		if (HideIcon) {
			ams--;
		}
		if (HideName) {
			ams--;
		}
		if (HideDelta || Records::Pb <= 0) {
			ams--;
		}
        return ams;
    }

    vec3 StrToVec3(const string str) {
        return Text::ParseHexColor(Text::Repeat(str.SubStr(0,1),2) + Text::Repeat(str.SubStr(1,1),2) + Text::Repeat(str.SubStr(2,1),2)).get_xyz();
    }

    void RenderMenu() {
        if (!Enabled) {
            return;
        }
        array<CMedal> medals = MedalHandler::medals;
        if (medals.Length > 0) {
            medals = MedalHandler::OrderMedals(medals);
        }
        int flags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize;
        if (UI::Begin("CustomMedalsWindow", flags)) {
            if (MedalHandler::medals.Length < 1) {
                UI::Text("Create your first medal!");
                if (UI::Button("Create")) {
                    Meta::OpenSettings();
                }
            } else {
                int ams = GetMedalTableSize();
                if (UI::BeginTable("CMTable", ams, UI::TableFlags::SizingFixedFit)) {
                    for (uint i = 0; i < medals.Length; i++) {
                        CMedal medal = medals[i];
                        if (medal.Time < 0 && HideNA) {
                            continue;
                        }
                        UI::TableNextRow();
                        medal.RenderTime();
                    }
                    UI::EndTable();
                }
            }
            UI::End();
        }
    }
}