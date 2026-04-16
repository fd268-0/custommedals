class CDocument {
    CDocument(const string name, const string desc, const array<string>&in types = {}) {
        Name = name;
        Description = desc;
        Types = types;
    }
    void generateDocumentUI() {
        UI::PushFontSize(24);
        UI::Text(Name);
        UI::PopFontSize();
        for (uint i = 0; i < Types.Length; i++) {
            UI::Text("\\$999"+Types[i]);
            UI::SameLine();
        }
        if (Types.Length > 0) {
            UI::NewLine();
        }
        UI::PushTextWrapPos(0);
        UI::Text(Description);
        UI::PopTextWrapPos();
        if (Name == "Examples") {
            if (UI::ButtonColored("Starter Medal", 0, 0, 0)) {
                SettingHandler::AddPrsMdl("Starter","$BT+($BT-$ST)");
            }
            UI::SameLine();
            if (UI::ButtonColored("Platform-Only Medal", 0, 0, 0)) {
                SettingHandler::AddPrsMdl("Awesome","$TYPE != 2 ? -1 : $AT+1");
            }
            UI::SameLine();
            if (UI::ButtonColored("Author-Warrior Medal \\$099*Requires Warrior Medals", 0, 0, 0)) {
                SettingHandler::AddPrsMdl("Author+","$WT <= 0 ? -1 : $AT+($WT-$AT)/2");
            }
        }
    }
    string Name;
    string Description;
    array<string> Types;
}

array<CDocument@> documents = {
    @CDocument("Functions","Function usage: func(number)\n\\$999Current functions: " + string::Join(OperationHandler::rightHandedOperators,", ") + "\n\\$999Current multi-parameter functions: ",{}),
    @CDocument("Operators","Operator usage: number op number\n\\$999Current operators: +, -, *, /, %, ^",{}),
    @CDocument("Brackets","Brackets are supported.",{}),
    @CDocument("If Statements","Usage: \\$0f0condition (ex. 1 == 1) \\$ff0?\\$fff number \\$ff0:\\$fff number\n\\$999If statements are calculated after all functions and operators are calculated.",{}),
    @CDocument("Conditions","Usage in If Statements.\n\\$999First: "  + string::Join(OperationHandler::conditions,", ") + "\n\\$999Then: "  + string::Join(OperationHandler::secondconditions,", ") + "\n\\$999Then: ! \\$777(right-handed)\n\\$fffNote: Returns 0 if false, 1 if true.",{}),
    @CDocument("Time Variables","\\$fff$AT \\$999Author Time\n\\$fff$GT \\$999Gold Time\n\\$fff$ST \\$999Silver Time\n\\$fff$BT \\$999Bronze Time\n\\$0ff$WT \\$099Warrior Time \\$900*Needs Warrior Medals plugin. *Returns -1 if not avaliable.\n\\$ff0$PB \\$990Personal Best\n\\$0f0$#num \\$090Leaderboard Time \\$070*num is the position you'd like. Calculated before anything else. \\$900*Returns -1 if not avaliable.\n\\$777Getting times of certain players coming soon.",{}),
    @CDocument("Other Variables","\\$fff$TYPE \\$999Map Type. \\$990(0 = TimeAttack, 1 = Stunt, 2 = Platform)\n\\$fff$VALIDATE \\$999Validation Time. \\$990(-1 if no ghost found, refer to $VALIDATE in docs for more info)\n\\$fff$CLONES \\$999Amount of Clones.\n\\$fff$LAPS \\$999Laps.",{}),
    @CDocument("Custom Variables","You can declare and set custom variables using \\$0ffvariable_name = operation; \\$fffUse the variable name in any subsequent line to get the value of it\n\\$fffVariable names must only include letters and underscores, or they will not be set \\$999(this means you can't override $ variables)\n\\$f33Be careful! Your variables can override functions.",{}),
    @CDocument("Exports","Exporting to Ultimate Medals Extended (UME) is an option that is enabled by default if you have the plugin.\n\\$f33Times are updated upon clicking Save, when a leaderboard time request is complete, and when a map is loaded.\n\\$fffTo get a medal to display on UME, it must:\n\\$0f0"+Icons::CheckCircle+" Not show N/A (by being less then 0)\n\\$0f0"+Icons::CheckCircle+" Not already have a medal of the same name on UME",{"UME"}),
    @CDocument("Exports","You can get medals generated, create custom variables, refresh the operations, and more using the CustomMedals dependency. Learn more on the Github repository.",{"Other","Experimental"}),
    @CDocument("Ordering","The calculation order for each line is: \\$f9fVariable Calculations -> \\$f99Brackets -> \\$ff9Functions -> \\$9f9Exponents -> \\$9f9Mult, Divide -> \\$9f9Add, Sub -> \\$ff9Multi-Parameter Functions -> \\$9ffConditions -> \\$9ffIf Statements",{}),
    @CDocument("Basics","Lines can be seperated using ;\nAll medal equations must return an integer on the last line. Some variables are not a number, and you must use if statements to return a number.",{}),
    @CDocument("$VALIDATE","$VALIDATE returns the Map.ChallengeParameters.RaceValidateGhost.RaceTime (integer), or -1 if not found.\n\\$999Restrictions: The map must be validated with a ghost in the Winter 2026 update or later. Note: This can be used as an alternative for the $AT.",{"Variable"}),
    @CDocument("Parameters","Parameters can be edited in the advanced settings. Use commas to seperate parameters. Parameters are used to modify the operation handling and display.\n\\$fffanyvar \\$999Allows the use of any string as a variable.\n\\$fffcoperators \\$999Testing text detection for future logic addition.\n\\$fffnoexport \\$999Disables exports to UME and other plugins.",{"Experimental"}),
    @CDocument("Examples","Here's some examples of what you can make:",{})
};



namespace DocsHandler {
    void DocDynamicUpdate() {
        array<string> keys = OperationHandler::functions.GetKeys();
        for (uint i = 0; i < keys.Length; i++) {
            string key = keys[i];
            int am = int(OperationHandler::functions[key]);
            documents[0].Description = documents[0].Description + (i > 0 ? ", " : "") + key + "(" + string::Repeat("num, ", am-1) + "num)";
        }
    }
    string search = "";
    [SettingsTab name="Documentation"]
    void RenderDocs() {
        if (! Permissions::ViewRecords()) {
            CDocument@ doc = CDocument("Access Denied","In order to use Custom Medals, you must get Standard or Club Access.\nWhy? You can access records through Custom Medals.",{});
            doc.generateDocumentUI();
		    return;
	    }
        search = UI::InputText(Icons::Search,search);
        int found = 0;
        for (uint i = 0; i < documents.Length; i++) {
            if (documents[i].Name.Contains(search) || documents[i].Types.Find(search) > -1) {
                found += 1;
                UI::Separator();
                documents[i].generateDocumentUI();
            }
        }
        if (found < 1) {
            UI::Separator();
            UI::Text("No results. Try searching for a different term.");
        }
    }
}