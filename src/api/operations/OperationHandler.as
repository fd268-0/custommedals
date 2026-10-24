enum OPERTYPE {
    Number,
    Operation,
    Bracket,
    Condition,
    Unknown,
    Special,
    String,
}

namespace OperationHandler {
    bool escape = false;
    int iter = 0;

    dictionary globalVariables = {};

    array<string> rangeToStr(const array<string> curarr, const int start, const int end, const string str) {
        array<string> arr = curarr;
        arr.RemoveRange(Math::Max(0,start), Math::Min(end,arr.Length-1)-start+1);
        arr.InsertAt(start, str);
        return arr;
    }

    array<string> rangeToArr(const array<string> curarr, const int start, const int end, const array<string> str) {
        array<string> arr = curarr;
        arr.RemoveRange(Math::Max(0,start), Math::Min(end,arr.Length-1)-start+1);
        arr.InsertAt(Math::Max(0,start), str);
        return arr;
    }

    array<string> getRangeFromList(const array<string> curarr, const int start, const int curend) {
        uint end = Math::Clamp(curend,0,Math::Max(0,curarr.Length-1));
        array<string> arr = {};
        if (curarr.Length > 0) {
            for (uint i = Math::Clamp(start,0,Math::Max(0,curarr.Length-1)); i <= end; i++) {
                arr.InsertLast(curarr[i]);
            }
        } else {
            DebugHandler::AddOutput("Range is 0 or out of bounds: "  + start + "-" + curend);
            arr = {};
        }

        return arr;
    }

    array<string> rightHandedOperators = {"sqrt", "floor", "ceil", "round", "abs"};
    dictionary functions = {
        {"min",2},
        {"max",2},
        {"lerp",3}
    };
    array<string> conditions = {">", "<", "<=", ">=", "==", "!="};
    array<string> secondconditions = {"||", "!|", "&&", "!&"};

    void iterateEscapeCounter() {
        iter += 1;
        if (iter > 1000) {
            escape = true;
            DebugHandler::AddOutput("Escaping calcuation (iteration: " + iter + ")");
            warn("Escaping calculation for CustomMedals due to the calculation limit being reached... please contact the author (fd268) about how you got this message.");
        }

    };

    array<string> performFunction(const array<string> curarr, const array<string> strs) {
        iterateEscapeCounter();

        array<string> arr = curarr;
        int pos = getPositionsOfStrs(arr, strs)[0];
        string op = arr[pos];
        int size = (int(functions[op])*2);
        array<string> range = getRangeFromList(arr, pos, pos+size-1);
        if (range.Length < uint(size)) {
            escape = true;
            DebugHandler::AddOutput("Function failed, not enough parameters - got " + range.Length + ", expected " + size + " parameters.");
            return {};
        }
        array<float> floats = {};
        for (uint i = 1; i < range.Length; i = i + 2) {
            if (Text::TryParseFloat(range[i], 0) == false) {
                escape = true;
                DebugHandler::AddOutput("Function failed, string is not float - " + Text::Join(range, ", "));
                return {};
            } else {
                floats.InsertLast(Text::ParseFloat(range[i]));
            }
        }
        float answer = -1;

        if (op == "min") {
            answer = Math::Min(floats[0], floats[1]);
        } else if (op == "max") {
            answer = Math::Max(floats[0], floats[1]);
        } else if (op == "lerp") {
            answer = Math::Lerp(floats[0], floats[1], floats[2]);
        } else {
            escape = true;
            DebugHandler::AddOutput("Function failed, invalid name");
            return {};
        }

        return rangeToStr(arr, pos, pos+size-1, ""+answer);
    }

    array<array<string>> getList(const array<string> curarr, int start, int end) {
        // No safeguards are in place for now
        array<array<string>> list = {};
        array<int> commas = getPositionsOfStrs(curarr, {"(", "[", ",", ")", "]"});
        for (uint i = 0; i < commas.Length; i++) {
            if (commas[i] > end) {
                break;
            }
            if (commas[i] <= start) {
                continue;
            }
            if (i > 0) {
                list.InsertLast(getRangeFromList(curarr, commas[i-1]+1, commas[i]-1));
            }
        }
        return list;
    }

    array<string> performListSearch(const array<string> curarr) {
        // Expected format: 0@(5+3,6,7*3)
        iterateEscapeCounter();
        int pos = getPositionsOfStrs(curarr, {"@"})[0];
        int endingPos = pos + 1;
        int startingPos = pos - 1;
        uint startingValue = 0;
        if (startingPos < 0) {
            escape = true;
            DebugHandler::AddOutput("List search failed, starting pos invalid");
            return {};
        }
        if (Text::TryParseUInt(curarr[startingPos], 0) == false) {
            escape = true;
            DebugHandler::AddOutput("List search failed, starting pos is not a float - " + curarr[startingPos]);
            return {};
        }
        startingValue = Text::ParseUInt(curarr[startingPos]);
        array<int> endBrackets = getPositionsOfStrs(curarr, {")", "]"});
        for (uint i = 0; i < endBrackets.Length; i++) {
            if (endBrackets[i] > pos) {
                endingPos = endBrackets[i];
                break;
            }
        }
        array<array<string>> list = getList(curarr, startingPos, endingPos);
        if (startingValue >= list.Length) {
            escape = true;
            DebugHandler::AddOutput("List search failed, invalid or out of bound index - " + startingValue);
            return {};
        }
        array<string> value = list[startingValue];
        return rangeToArr(curarr, startingPos, endingPos, value);
    }

    array<string> performConditional(const array<string> curarr) {
        iterateEscapeCounter();

        array<string> arr = curarr;
        int pos = getPositionsOfStrs(arr, {"?"})[0];
        array<string> range = getRangeFromList(arr, pos-1, pos+3);
        // num, ?, num, :, num
        if (range.Length < 5) {
            escape = true;
            DebugHandler::AddOutput("If statement failed, range length is " + range.Length + ", expected 5");
            return {};
        }
        if (Text::TryParseFloat(range[0], 0) == false) {
            escape = true;
            DebugHandler::AddOutput("If statement failed, conditional is not a float - " + range[0]);
            return {};
        }
        float condition = Text::ParseFloat(range[0]);
        string atrue = range[2];
        string afalse = range[4];

        string answer = (condition == 1) ? atrue : afalse;
        return rangeToStr(arr, pos-1, pos+3, ""+answer);
    }

    array<string> performOperand(const array<string> curarr, const array<string> strs, bool&in righthanded = false) {
        iterateEscapeCounter();

        array<string> arr = curarr;
        int pos = getPositionsOfStrs(arr, strs)[0];
        if (rightHandedOperators.Find(arr[pos]) > -1 || arr[pos] == "!") {
            righthanded = true;
        }
        array<string> range = getRangeFromList(arr, righthanded ? pos : pos-1, pos+1);
        if (range.Length < uint(righthanded ? 2 : 3)) {
            escape = true;
            DebugHandler::AddOutput("Operand not enough parameters, got " + range.Length + ", expected " + uint(righthanded ? 2 : 3));
            return {};
        }
        string op = range[righthanded ? 0 : 1];
        string s1 = range[0];
        string s2 = range[righthanded ? 1 : 2];
        float n1 = -1;
        float n2 = -1;
        if (op == "==" || op == "!=" || op == "..") {
                // bla
            } else {
                if ((Text::TryParseFloat(s1, 0) == false && ! righthanded) || Text::TryParseFloat(s2, 0) == false) {
                    escape = true;
                    DebugHandler::AddOutput("Operand " + op + " failed, either " + s1 + " or " + s2 + " is not a float");
                    return {};
                } else {
                    n1 = righthanded ? -1 : Text::ParseFloat(s1);
                    n2 = Text::ParseFloat(s2);
                }
            }

        float answer = -1;
        if (op == "*") {
            answer = n1 * n2;
        } else if (op == "/") {
            if (n2 == 0) {
                answer = 0;
            } else {
                answer = n1 / n2;
            }
        } else if (op == "+") {
            answer = n1 + n2;
        } else if (op == "..") {
            return rangeToStr(arr, righthanded ? pos : pos-1, pos+1, s1 + s2);
        } else if (op == "-") {
            answer = n1 - n2;
        } else if (op == "^") {
            answer = n1 ** n2;
        } else if (op == "%") {
            answer = n1 % n2;
        } else if (op == "==") {
            answer = (s1 == s2 ? 1 : 0);
        } else if (op == "!=") {
            answer = (s1 != s2 ? 1 : 0);
        } else if (op == "<=") {
            answer = (n1 <= n2 ? 1 : 0);
        } else if (op == ">=") {
            answer = (n1 >= n2 ? 1 : 0);
        } else if (op == ">") {
            answer = (n1 > n2 ? 1 : 0);
        } else if (op == "<") {
            answer = (n1 < n2 ? 1 : 0);
        } else if (op == "||") {
            answer = (Math::Max(n1,n2)); // bools are stored as 0 = false, 1 = true
        } else if (op == "&&") {
            answer = ((n1 == 1 && n2 == 1) ? 1 : 0);
        } else if (op == "!&") {
            answer = ((n1 == 1 && n2 == 1) ? 0 : 1);
        } else if (op == "!|") {
            answer = (1-Math::Max(n1,n2));
        } else if (op == "!") {
            answer = (1-n2);
        } else if (op == "sqrt") {
            answer = n2 ** 0.5;
        } else if (op == "float") {
            answer = Math::Floor(n2);
        } else if (op == "ceil") {
            answer = Math::Ceil(n2);
        } else if (op == "round") {
            answer = Math::Round(n2);
        } else if (op == "abs") {
            answer = Math::Abs(n2);
        } else {
            escape = true;
            DebugHandler::AddOutput("Operand " + op + " is not a valid operand");
            return {};
        }
        return rangeToStr(arr, righthanded ? pos : pos-1, pos+1, ""+answer);
    }

    array<int> getPositionsOfStrs(const array<string> curarr, const array<string> strs) {
        array<int> positions = {};
        for (int i = 0; i < int(strs.Length); i++) {
            int curStart = -1;
            while (curarr.Find(curStart+1, strs[i]) > -1) {
                int found = curarr.Find(curStart+1, strs[i]);
                curStart = int(found);
                positions.InsertLast(found);
            }
        }
        positions.SortAsc();
        return positions;
    }

    array<string> replaceValues(const array<string> curarr, const string str, const string rep) {
        array<string> arr = curarr;
        array<int> poses = getPositionsOfStrs(arr, {str});
        for (uint i = 0; i < poses.Length; i++) {
            arr = rangeToArr(arr, poses[i], poses[i], stringToArray(rep));
        }
        return arr;
    }

    array<string> performBrackets(const array<string> curarr, const array<string> bracketsleft, const array<string> bracketsright, const dictionary&in variableInserts = {}) {
        array<string> arr = curarr;
        iterateEscapeCounter();
        array<int> leftBrackets = getPositionsOfStrs(arr, bracketsleft);
        array<string> splitarr = arr;
        if (leftBrackets.Length > 1) {
            splitarr.RemoveRange(leftBrackets[1],999999);
        }
        array<int> rightBrackets = getPositionsOfStrs(splitarr, bracketsright);
        int lPos = leftBrackets[0];

        if (rightBrackets.Length > 0) {
            int rPos = rightBrackets[rightBrackets.Length-1];
            array<string> answer = arrayToArr(getRangeFromList(arr, lPos+1, rPos-1), variableInserts);
            arr = rangeToArr(arr, lPos, rPos, answer);
        } else {
            arr.RemoveAt(lPos);
        }
        return arr;
    }

    array<string> arrayToArr(const array<string> curarr, const dictionary&in variableInserts = {}, const array<string>&in params = {}) {
        iter = 0;
        escape = false;
        array<string> arr = curarr;
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;
        if (track !is null) {
            if (track.MapInfo !is null && track.ChallengeParameters !is null) {
                array<string> varKeys = variableInserts.GetKeys();
                for (uint i = 0; i < varKeys.Length; i++) {
                    string name = varKeys[i];
                    string value = string(variableInserts[name]);
                    arr = replaceValues(arr, name, value);
                }
                arr = replaceValues(arr, "$BT", ""+track.MapInfo.TMObjective_BronzeTime);
                arr = replaceValues(arr, "$ST", ""+track.MapInfo.TMObjective_SilverTime);
                arr = replaceValues(arr, "$MAPUID", ""+track.MapInfo.MapUid);
                arr = replaceValues(arr, "$GT", ""+track.MapInfo.TMObjective_GoldTime);
                arr = replaceValues(arr, "$AT", ""+track.MapInfo.TMObjective_AuthorTime);
                arr = replaceValues(arr, "$CLONES", ""+track.MapInfo.TMObjective_NbClones);

                arr = replaceValues(arr, "$PLAYERS", ""+ImportHandler::players);
                arr = replaceValues(arr, "$WRST", ""+ImportHandler::worstTime);
                if (track.MapInfo.TMObjective_IsLapRace) {
                    arr = replaceValues(arr, "$LAPS", ""+track.MapInfo.TMObjective_NbLaps);
                } else {
                    arr = replaceValues(arr, "$LAPS", "1");
                }
                arr = replaceValues(arr, "$TYPE", ""+int(Records::mapType));
                if (track.ChallengeParameters.RaceValidateGhost !is null) {
                    arr = replaceValues(arr, "$VALIDATE", ""+track.ChallengeParameters.RaceValidateGhost.RaceTime);
                } else {
                    arr = replaceValues(arr, "$VALIDATE", "-1");
                }
                arr = replaceValues(arr, "$PB", ""+Records::Pb);
#if DEPENDENCY_WARRIORMEDALS
                int warriorTime = WarriorMedals::GetWMTime();
                if (warriorTime <= 0) {
                    warriorTime = -1;
                }
                arr = replaceValues(arr, "$WT", ""+warriorTime);
#endif
            }
        }

        while (getPositionsOfStrs(arr, {"("}).Length > 0 && escape == false) {
            arr = performBrackets(arr, {"("}, {")"}, variableInserts);
        }

        while (getPositionsOfStrs(arr, {"@"}).Length > 0 && escape == false) {
            arr = performListSearch(arr);
        }

        while (getPositionsOfStrs(arr, {"["}).Length > 0 && escape == false) {
            arr = performBrackets(arr, {"["}, {"]"}, variableInserts);
        }

        while (getPositionsOfStrs(arr, rightHandedOperators).Length > 0 && escape == false) {
            arr = performOperand(arr, rightHandedOperators);
        }

        while (getPositionsOfStrs(arr, {".."}).Length > 0 && escape == false) {
            arr = performOperand(arr, {".."});
        }

        while (getPositionsOfStrs(arr, {"^"}).Length > 0 && escape == false) {
            arr = performOperand(arr, {"^"});
        }

        while (getPositionsOfStrs(arr, {"*","/","%"}).Length > 0 && escape == false) {
            arr = performOperand(arr, {"*","/","%"});
        }

        while (getPositionsOfStrs(arr, {"+","-"}).Length > 0 && escape == false) {
            arr = performOperand(arr, {"+","-"});
        }

        while (getPositionsOfStrs(arr, functions.GetKeys()).Length > 0 && escape == false) {
            arr = performFunction(arr, functions.GetKeys());
        }

        while (getPositionsOfStrs(arr, conditions).Length > 0 && escape == false) {
            arr = performOperand(arr, conditions);
        }

        while (getPositionsOfStrs(arr, secondconditions).Length > 0 && escape == false) {
            arr = performOperand(arr, secondconditions);
        }

        while (getPositionsOfStrs(arr, {"!"}).Length > 0 && escape == false) {
            arr = performOperand(arr, {"!"});
        }

        while (getPositionsOfStrs(arr, {"?"}).Length > 0 && escape == false) {
            arr = performConditional(arr);
        }

        return arr;
    }

    float arrayToAns(const string curarr, const string&in params = "") {
        string ans = arrayToString(curarr, params);
        float numAns = -2;
        if (Text::TryParseFloat(ans, 0)) {
            numAns = Text::ParseFloat(ans);
        } else {
            DebugHandler::AddOutput(ans + " is not a float", false);
        }
        return numAns;
    }

    string arrayToString(const string curarr, const string&in params = "") {
        array<string> sepParams = params.Split(",");
        array<string> lines = curarr.Split(";");
        dictionary variables = {};
        array<string> globalVariableKeys = globalVariables.GetKeys();
        for (uint i = 0; i < globalVariableKeys.Length; i++) {
            string name = globalVariableKeys[i];
            string value = string(globalVariables[name]);
            variables[name] = value;
        }
        string ans = "-1";
        for (uint i = 0; i < lines.Length; i++) {
            string line = lines[i];
            string vname = "";
            array<string> splitLine = stringToArray(line, sepParams);
            if (splitLine.Length > 1) {
                if (splitLine[1] == "=") {
                    vname = splitLine[0];
                    splitLine.RemoveRange(0,2);
                }
            }
            ans = arrayToAnsSingular(splitLine, variables, sepParams);
            if (vname != "" && (Regex::IsMatch(vname, "[A-z_]+") || (sepParams.Find("anyvar") >= 0))) {
                variables[vname] = ans;
            }
        }
        return ans;
    }

    string arrayToAnsSingular(const array<string> curarr, const dictionary variables = {}, const array<string>&in params = {}) {
        array<string> arr = arrayToArr(curarr, variables, params);
        return Text::Join(arr,"");
    }

    array<string> stringToArray(const string estr, const array<string>&in params = {}) {
        OPERTYPE curOperation = OPERTYPE::Operation;
        string opText = "";
        bool stringEnabled = false;
        string str = Regex::Replace(estr, " ", "");
        array<string> split = {};
        for (int i = 0; i < int(str.Length); i++) {
		    string byte = str.SubStr(i, 1);
            string addedOp = opText + byte;
            OPERTYPE byteOperation = OPERTYPE::Unknown;
            if (Regex::Search(byte, '(["])').Length > 0) {
                stringEnabled = !stringEnabled;
                if (stringEnabled) {
                    byteOperation = OPERTYPE::String;
                }
            }
            if (stringEnabled) {
                byteOperation = OPERTYPE::String;
            } else if (Regex::Search(byte, "([*^%+\\/,?:@])").Length > 0 && curOperation != OPERTYPE::Operation) {
                byteOperation = OPERTYPE::Operation;
            } else if (Regex::Search(byte, "([()\\[\\]])").Length > 0) {
                byteOperation = OPERTYPE::Bracket;
            } else if (Regex::Search(byte, "([<>=!|&])").Length > 0) {
                byteOperation = OPERTYPE::Condition;
            } else if (Regex::Search(byte, "([-])").Length > 0 && (str.SubStr(i-1, 1) == ")" || curOperation == OPERTYPE::Number)) {
                byteOperation = OPERTYPE::Operation;
            } else if (((addedOp == "return") && (params.Find("coperators") >= 0)) || opText == "..") {
                byteOperation = OPERTYPE::Special;
            } else {
                byteOperation = OPERTYPE::Number;
            }
            if (byteOperation != curOperation || curOperation == OPERTYPE::Bracket) {
                curOperation = byteOperation;
                split.InsertLast(opText);
                opText = "";
            }
            if (Regex::Search(byte, '(["])').Length == 0) {
                opText = opText + byte;
            }
        }
        if (opText.Length > 0) {
            split.InsertLast(opText);
        }
        if (split.Length > 0) {
            split.RemoveAt(0);
        }
        return split;
    }
}