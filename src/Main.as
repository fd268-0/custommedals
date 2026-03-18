void OnDestroyed() {
    ExportHandler::KillExports();
}

void Main() {
	SettingHandler::LoadSettings();
	DocsHandler::DocDynamicUpdate();
	while (true) {
		if (! Permissions::ViewRecords()) {
			UI::ShowNotification("Custom Medals", "You can't use Custom Medals because you don't have Standard or Club Access.");
			return;
		}
		auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;
#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
		if (MaintainUME) {
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
		if (track is null) {
			queuedPositionsToGet = {};
			positions = {};
			Medals = {};
		} else if (Medals == {}) {
			MedalHandler::UpdateAllTimes();
		}
		if (queuedPositionsToGet.Length > 0 && positions.GetKeys().Length < 10) {
			int pos = queuedPositionsToGet[0];
			positions[""+pos] = MedalHandler::getTimeAtPos(pos);
			queuedPositionsToGet.RemoveAt(0);
			ExportHandler::Export();
			MedalHandler::UpdateAllTimes();
			sleep(1500+(positions.GetKeys().Length*100));
		}
		sleep(100);
	}
}

void Render() {
	if (! Permissions::ViewRecords()) {
		return;
	}
	if (iconSelOpen) {
		int iflags = UI::WindowFlags::NoCollapse;
		UI::SetNextWindowSize(430,500);
		UI::Begin("\\$09fClick To Copy Icon", iflags);
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
		UI::End();
	}
	if (MedalHandler::GetVisiblity() == false) {
		return;
	}
	int flags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize;
	UI::Begin("CustomMedalsWindow", flags);
	if (UI::BeginTable("CMTable", 4, UI::TableFlags::SizingFixedFit)) {
		for (uint i = 0; i < Medals.Length; i++) {
			CMedal medal = Medals[i];
			if (medal.Time < 0 && HideNA) {
				continue;
			}
			UI::TableNextRow();
			MedalHandler::RenderTime(medal);
		}
		UI::EndTable();
	}
	UI::End();
}
