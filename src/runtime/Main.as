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

void Render() {
	if (! Permissions::ViewRecords()) {
		return;
	}
    RenderHandler::RenderMenu();
}