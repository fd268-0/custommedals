void MapEntered() {
    ImportHandler::GetMapInfo();
    MedalHandler::UpdateValues();
    VariableHandler::UpdateValues();
}

void MapExited() {
    ImportHandler::ClearImports();
    VariableHandler::ResetValues();
    OnlineHandler::mapId = "";
    OnlineHandler::accountIdList = {};
    ExportHandler::KillExports();
}

void PbUpdated() { // IMPLEMENTED
    MedalHandler::UpdateValues();
    VariableHandler::UpdateValues();
}

// should only update when 'Save' pressed, not for every event

void MedalsUpdated() { // IMPLEMENTED
    MedalHandler::SaveMedals();
    ExportHandler::Export();
}

// should only update when 'Save' pressed, not for every event

void VariablesUpdated() { // IMPLEMENTED
    MedalHandler::UpdateValues();
    VariableHandler::SaveVariables();
}