namespace DebugHandler {
    string CurrentLine = "";
    array<string> DebugOutput = {};

    void ResetHandler() {
        CurrentLine = "";
        DebugOutput = {};
    }

    void UpdateLine(const string&in new) {
        array<string> DupeOutput = cast<array<string>>(DebugOutput);
        for (uint i = 0; i < DupeOutput.Length; i++) {
            string outputItem = DupeOutput[i];
            if (outputItem.Contains(new+":")) {
                DebugOutput.RemoveAt(DebugOutput.Find(outputItem));
            }
        }
        CurrentLine = new;
        AddOutput("Loading calculation @ \\$fff" + Time::FormatString("%H:%M:%S", Time::get_Stamp()) + "." + Time::get_MilliStamp() % 1000, false, true);
    }

    void AddOutput(const string&in output, const bool error = true, const bool info = false) {
        string prefix = "WARN ";
        if (error) {
            prefix = "ERROR\\$f99 ";
        }
        if (info) {
            prefix = "INFO\\$9ff ";
        }

        int am = 1;
        string main = prefix + CurrentLine + ": " + output;
        DebugOutput.InsertLast(main);
        
        if (DebugOutput.Length > 100) {
            DebugOutput.RemoveAt(0);
        }
    }

    bool IsErrored(const string&in contains, const bool errorOnly = false) {
        for (uint i = 0; i < DebugOutput.Length; i++) {
            string outputItem = DebugOutput[i];
            if (outputItem.Contains(contains+":") && errorOnly ? outputItem.Contains("ERROR") : !outputItem.Contains("INFO")) {
                return true;
            }
        }
        return false;
    }

    void RenderDebug(const string&in contains) {
        for (uint i = 0; i < DebugOutput.Length; i++) {
            string outputItem = DebugOutput[i];
            if (!outputItem.Contains(contains+":")) {
                continue;
            }
            string prefix = "\\$ff7";
            if (outputItem.StartsWith("ERROR")) {
                prefix = "\\$f77";
            }
            if (outputItem.StartsWith("INFO")) {
                prefix = "\\$0ff";
            }
            UI::Text(prefix + outputItem);
        }
    }
}