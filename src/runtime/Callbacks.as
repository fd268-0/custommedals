void MapEntered() {
    MedalHandler::UpdateValues();
    VariableHandler::UpdateValues();
}

void MapExited() {
    VariableHandler::ResetValues();
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