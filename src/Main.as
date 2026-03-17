void OnDestroyed() {
    ExportHandler::KillExports();
}

void Main() {
	SettingHandler::LoadSettings();
	while (true) {
		MedalHandler::UpdateAllTimes();
#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
		if (MaintainUME) {
			auto app = cast<CTrackMania>(GetApp());
        	auto track = app.RootMap;
			if (exports.Length == 0 && track !is null) {
				ExportHandler::Export();
			}
			if (track is null) {
				ExportHandler::KillExports();
			}
		} else {
			ExportHandler::KillExports();
		}
#endif
		yield();
	}
}

void Render() {
	if (MedalHandler::GetVisiblity() == false) {
		return;
	}
	int flags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize;
	UI::Begin("CustomMedalsWindow", flags);
	if (UI::BeginTable("CMTable", 4, UI::TableFlags::SizingFixedFit)) {
		UI::TableNextRow();
		for (uint i = 0; i < Medals.Length; i++) {
			MedalHandler::RenderTime(Medals[i]);
		}
		UI::EndTable();
	}
	UI::End();
}