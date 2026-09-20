bool inTrack = false;

void Main() {
    if (! Permissions::ViewRecords()) {
        UI::ShowNotification("Custom Medals", "You can't use Custom Medals because you don't have Standard or Club Access.");
		return;
	}
    VariableHandler::LoadVariables();
    MedalHandler::LoadMedals();

    MedalHandler::UpdateValues();
    while (true) {
        Records::UpdateCurrentPb();
        OnlineHandler::UpdatePlayerRecords();
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;
		if (track is null and inTrack) {
			inTrack = false;
            MapExited();
		}
		if (track !is null && app.PlaygroundScript !is null and !inTrack) {
			inTrack = true;
            MapEntered();
		}
        yield();
    }
}

void OnDestroyed() {
    ExportHandler::KillExports();
}

float sinceLastVariableReload = 0;

void Update(float dt) {
    if (inTrack) {
        sinceLastVariableReload += dt;
    }
    if (sinceLastVariableReload > 120000.0 && ReloadInterval == VariableSettings::RELOADINTERVAL::Per120s) {
        VariableHandler::ForceUpdates();
    }
    if (sinceLastVariableReload > 300000.0 && ReloadInterval == VariableSettings::RELOADINTERVAL::Per300s) {
        VariableHandler::ForceUpdates();
    }
    if (sinceLastVariableReload > 900000.0 && ReloadInterval == VariableSettings::RELOADINTERVAL::Per900s) {
        VariableHandler::ForceUpdates();
    }
}

void Render() {
	if (! Permissions::ViewRecords()) {
		return;
	}
    if (inTrack) {
        RenderHandler::RenderMenu();
    }
}