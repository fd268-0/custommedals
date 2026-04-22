void OnDestroyed() {
    ExportHandler::KillExports();
}

string curMapId = "";

void Main() {
	SettingHandler::LoadSettings();
	DocsHandler::DocDynamicUpdate();
	while (true) {
		if (! Permissions::ViewRecords()) {
			UI::ShowNotification("Custom Medals", "You can't use Custom Medals because you don't have Standard or Club Access.");
			return;
		}
		MedalHandler::UpdateCurrentPb();
		auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;
		if (track is null) {
			queuedPositionsToGet = {};
			positions = {};
			Medals = {};
			curMapId = "";
			ImportingHandler::MapImports = {};
		}
		if (track !is null && app.PlaygroundScript !is null) {
			bool isNew = (track.EdChallengeId != curMapId);
			if (isNew == true) {
				ImportingHandler::GetMapImports();
				MedalHandler::UpdateAllTimes();
				curMapId = track.EdChallengeId;
			}
		}
#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
		if (MaintainUME) {
			if (exports.Length == 0 && track !is null && app.PlaygroundScript !is null) {
				ExportHandler::Export();
			}
			if (track is null) {
				ExportHandler::KillExports();
			}
		} else {
			ExportHandler::KillExports();
		}
#endif	
		if (queuedPositionsToGet.Length > 0 && positions.GetKeys().Length < 10) {
			int pos = queuedPositionsToGet[0];
			positions[""+pos] = MedalHandler::getTimeAtPos(pos);
			queuedPositionsToGet.RemoveAt(0);
			MedalHandler::UpdateAllTimes();
			ExportHandler::Export();
			sleep(1500+(positions.GetKeys().Length*100));
		}
		yield();
	}
}

void RenderIconsMenu() {
	int iflags = UI::WindowFlags::NoCollapse;
	UI::SetNextWindowSize(430,500);
	if (UI::Begin("\\$09fClick To Copy Icon", iflags)) {
		iconSelSearch = UI::InputText("  "+Icons::Search, iconSelSearch);
		UI::SameLine();
		if (UI::ButtonColored("Close", 0, 0.5, 0.5)) {
			iconSelOpen = false;
		}
		if (UI::BeginTable("ICTable", 10, UI::TableFlags::SizingFixedFit)) {
			auto keys = icons.GetKeys();
			for (uint i = 0; i < keys.Length; i++) {
				auto iconName = keys[i];
				if (! iconName.Contains(iconSelSearch)) {
					continue;
				}
				UI::TableNextColumn();
				string icon = string(icons[iconName]);
				if (UI::ButtonColored(icon, 0, 0, 0)) {
					IO::SetClipboard(icon);
					UI::ShowNotification("Custom Medals", "Copied "+ icon + " to clipboard.");
				}
			}
			UI::EndTable();
		}
	}
	UI::End();
}

void Render() {
	if (! Permissions::ViewRecords()) {
		return;
	}
	if (iconSelOpen) {
		RenderIconsMenu();
	}
	if (MedalHandler::GetVisiblity() == false) {
		return;
	}
	int flags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize;
	if (UI::Begin("CustomMedalsWindow", flags)) {
		if (Medals.Length <= 1) {
			UI::Text("Create your first medal!");
			if (UI::Button("Create")) {
				Meta::OpenSettings();
			}
		} else {
			int ams = MedalHandler::getMedalTableSize();
			if (UI::BeginTable("CMTable", ams, UI::TableFlags::SizingFixedFit)) {
				for (uint i = 0; i < Medals.Length; i++) {
					CMedal medal = Medals[i];
					if (medal.Time < 0 && HideNA) {
						continue;
					}
					if (HidePB && medal.IsPb) {
						continue;
					}
					UI::TableNextRow();
					MedalHandler::RenderTime(medal);
				}
				UI::EndTable();
			}
		}
	}
	UI::End();
}