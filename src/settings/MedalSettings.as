namespace MedalSettings {
    [SettingsTab name="Medals" icon="CircleO" order="2"]
    void RenderMedals() {
        if (! Permissions::ViewRecords()) {
            UI::ShowNotification("Custom Medals", "You can't use Custom Medals because you don't have Standard or Club Access.");
            return;
	    }
        if (ShowAlerts) {
            Controls::BeginFrame(""+Icons::ExclamationTriangle+" Data Format Changed", true, vec4(0.6,0.3,0.3,0.5));
            UI::Text("Unfortunately, previously saved data has been replaced. This does mean that updating will take less time!");
            Controls::EndFrame();
        }
        UI::BeginTable("medalRendering", 7, UI::TableFlags::SizingFixedFit);
        UI::TableNextRow();
        UI::TableNextColumn();
        UI::Text("");
        UI::TableNextColumn();
        UI::Text("Name");
        UI::TableNextColumn();
        UI::Text("Calculation");
        UI::TableNextColumn();
        UI::Text("Icon Color");
        UI::TableNextColumn();
        UI::Text("Icon");
        UI::SameLine();
        if (UI::TextLink(Icons::Pencil)) {
            OpenBrowserURL("https://openplanet.dev/docs/reference/icons");
        }
        for (uint i = 0; i < MedalHandler::medals.Length; i++) {
            CMedal@ medal = MedalHandler::medals[i]; // make it a HANDLE NOW!
            UI::TableNextRow();
            medal.RenderEditor(i+"");
        }
        UI::EndTable();

        if (UI::ButtonColored("Add", 0.3)) {
            MedalHandler::AddMedal(CMedal());
        }
        UI::SameLine();
        if (UI::ButtonColored("Save & Recaculate", 0.6)) {
            MedalHandler::UpdateValues();
        }
        if (UI::ButtonColored("Add PB Template", 0.9)) {
            MedalHandler::CreatePbTemplate();
        }
        UI::PushFontSize(24);
        UI::Text("Quick Reference");
        UI::PopFontSize();
        UI::Text(documents[5].Description+"\n"+documents[6].Description);
    }
}