namespace VariableSettings {
    [SettingsTab name="Variables" order="3"]
    void RenderVariables() {
        if (! Permissions::ViewRecords()) {
            UI::ShowNotification("Custom Medals", "You can't use Custom Medals because you don't have Standard or Club Access.");
            return;
	    }
        if (ShowAlerts) {
            Controls::BeginFrame(""+Icons::InfoCircle+" How To Use", true, vec4(0.3,0.3,0.6,0.5));
            UI::Text("Use variable names inside of any custom medal equation to fetch values. \\$bbfe.x. variable+3");
            Controls::EndFrame();
        }
        UI::BeginTable("medalRendering", 7, UI::TableFlags::SizingFixedFit);
        UI::TableNextRow();
        UI::TableNextColumn();
        UI::Text("Name");
        UI::TableNextColumn();
        UI::Text("Type");
        UI::TableNextColumn();
        UI::Text("");
        UI::TableNextColumn();
        UI::Text("Parameter");
        for (uint i = 0; i < VariableHandler::variables.Length; i++) {
            CVariable@ variable = VariableHandler::variables[i]; // make it a HANDLE NOW!
            UI::TableNextRow();
            variable.RenderEditor(i+"");
        }
        UI::EndTable();

        if (UI::ButtonColored("Add", 0.3)) {
            VariableHandler::AddVariable(CVariable());
        }
        UI::SameLine();
        if (UI::ButtonColored("Save & Calculate New", 0.6)) {
            VariableHandler::SaveVariables();
            VariableHandler::UpdateValues();
        }
        UI::SameLine();
        if (UI::ButtonColored("Recalculate All", 0)) {
            VariableHandler::ResetValues();
            VariableHandler::UpdateValues();
        }

        if (OnlineHandler::requestsSubmitted < 1) {
            UI::Text("\\$999" + Icons::CircleO + " No requests sent.");
        } else if (OnlineHandler::requestsSubmitted < 4) {
            UI::Text("\\$fff" + Icons::ArrowCircleODown + " " + OnlineHandler::requestsSubmitted + " requests sent.");
        } else if (OnlineHandler::requestsSubmitted < 7) {
            UI::Text("\\$ff0" + Icons::ArrowCircleOUp + " " + OnlineHandler::requestsSubmitted + "/10 requests sent.");
        } else if (OnlineHandler::requestsSubmitted < 10) {
            UI::Text("\\$f80" + Icons::ExclamationCircle + " " + OnlineHandler::requestsSubmitted + "/10 requests sent! Lower requests.");
        } else {
            UI::Text("\\$f00" + Icons::TimesCircle + " Request limit reached! Try sending less requests.");
        }
    }
}