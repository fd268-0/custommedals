[Setting name="Show MI Medals" category="Imports" hidden]
bool ShowMIMedals = true;

namespace SettingHandler {
    [SettingsTab name="Imports"]
    void RenderMapImports() {
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;
        auto editor = app.Editor;
        if (! Permissions::ViewRecords()) {
            CDocument@ doc = CDocument("Access Denied","In order to use Custom Medals, you must get Standard or Club Access.\nWhy? You can access records through Custom Medals.",{});
            doc.generateDocumentUI();
		    return;
	    }
        Controls::BeginFrame(""+Icons::ExclamationTriangle+" User-Generated Content Ahead", true, vec4(0.5,0,0,0.5));
        UI::Text("The following options can expose you to content that is not created by this plugin.");
        Controls::EndFrame();
        Controls::BeginFrame(Icons::MapPin + " Map-Imported Medals", true, vec4(0.1,0.1,0.1,0.5));
        ShowMIMedals = UI::Checkbox("Enabled", ShowMIMedals);
        UI::Text("Current Medals:");
        UI::BeginTable("MITable", 3, UI::TableFlags::SizingFixedFit);
        for (uint i = 0; i < ImportingHandler::MapImports.Length; i++) {
            CMedal mapMedal = ImportingHandler::MapImports[i];
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text(mapMedal.GetIcon());
            UI::TableNextColumn();
            UI::Text(mapMedal.Name);
            UI::TableNextColumn();
            UI::Text(MedalHandler::FormatInt(mapMedal.Time));
        }
        UI::EndTable();
        if (UI::Button("Refresh")) {
            ImportingHandler::GetMapImports();
            MedalHandler::UpdateAllTimes();
        }
        Controls::EndFrame();
        if (editor !is null) {
            Controls::BeginFrame(Icons::PlusCircle + " Add Medals", true, vec4(0,0.3,0,0.5));
            UI::Text("To add custom medals to the current map, use this formatting in the author comments:");
            UI::Text("\\$9f9CustomMedals{\\$9fficon\\$fff,\\$9ffname\\$fff,\\$9fftime\\$f99;\\$9fficon\\$fff,\\$9ffname\\$fff,\\$9fftime\\$9f9}");
             if (UI::TextLink(Icons::Pencil + " Open Icons")) {
                iconSelOpen = ! iconSelOpen;
            }
            UI::Text("\\$999You can put the custom medal indicator anywhere in your author comment.");
            Controls::EndFrame();
        }
    }
}