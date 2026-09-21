class CVariable {

    void ForceUpdate() {
        if (!inTrack) {
            return;
        }
        Processing = true;
        float FloatParam = OperationHandler::arrayToAns(Parameter);
        if (Type == VariableHandler::VARIABLETYPE::Number) {
            Value = int(FloatParam);
        } else if (Type == VariableHandler::VARIABLETYPE::Leaderboard) {
            Value = OnlineHandler::getTimeAtPos(int(FloatParam));
        } else if (Type == VariableHandler::VARIABLETYPE::CampaignType) {
            Value = OnlineHandler::officalCampaignType();
        } else if (Type == VariableHandler::VARIABLETYPE::PlayerRecord) {
            Value = OnlineHandler::getTimeFromUser(Parameter);
        } else if (Type == VariableHandler::VARIABLETYPE::CurrentPosition) {
            Value = OnlineHandler::getPositionOfTime();
        }
        if (Processing) {
            Processing = false;
            Completed = true;
            VariablesUpdated();
        }
    }

    void UpdateValue() {
        if (!Completed and !Processing) {
            if (Type == VariableHandler::VARIABLETYPE::PlayerRecord) {
                VariableHandler::ForceUpdate(this);
            } else {
                ForceUpdate();
            }
        } else {
            OperationHandler::globalVariables[Name] = Value + "";
        }
    }

    bool CanSave() {
        return true;
    }

    // c 4
    void RenderEditor(string&in idpre = "") {
        idpre = idpre + Id;

        UI::TableNextColumn();
        InputResult NameResult = UIR::InputText(150, idpre + "name", "", Name);

        UI::PushID(idpre+"Type");
        UI::TableNextColumn();
        UI::PushItemWidth(150);
        Type = VariableHandler::TypeComboBox("", Type);
        UI::PopItemWidth();
        UI::PopID();

        UI::TableNextColumn();
        UI::Text("\\$999" + VariableHandler::prefixes[int(Type)]);

        UI::TableNextColumn();
        if (VariableHandler::prefixes[int(Type)] == "") {
            UI::BeginDisabled();
            UIR::InputText(250, idpre + "params", "", "\\$990No parameter.");
            UI::EndDisabled();
        } else {
            InputResult ParameterResult = UIR::InputText(250, idpre + "params", "", Parameter);
            Parameter = ParameterResult.string;
        }

        UI::PushID(idpre+"Del");
        UI::TableNextColumn();
        if (UI::ButtonColored("Del", 0)) {
            VariableHandler::RemoveVariable(this);
        }
        UI::PopID();

        UI::TableNextColumn();
        if (Processing) {
            UI::Text("\\$ff0" + Icons::ArrowCircleODown + "Processing");
        } else if (Completed) {
            UI::Text("\\$0f0" + Icons::CheckCircle + "Calculated");
            UI::TableNextColumn();
            UI::PushID(idpre+"Re");
            if (UI::ButtonColored(Icons::Refresh, 0.8)) {
                VariableHandler::ForceUpdate(this);
            }
            UI::PopID();
        } else {
            UI::Text("\\$f00" + Icons::CircleO + "Unprocessed");
        }

        Name = NameResult.string;
    }

    int ValueInternal = -1;
    int Value {
        get {
            return ValueInternal;
        }
        set {
            ValueInternal = value;
            OperationHandler::globalVariables[Name] = value + "";
        }
    }

    int Type = VariableHandler::VARIABLETYPE::Number;
    string Parameter = "";
    string Name = "";

    bool Active = true;
    bool Processing = false;
    bool Completed = false;
}