enum OPERTYPE {
    Number,
    Operation,
    Bracket,
    Condition,
    Unknown,
}
namespace OperationHandler {
    bool escape = false;
    int iter = 0;

    array<string> rangeToStr(const array<string> curarr, const int start, const int end, const string str) {
        array<string> arr = curarr;
        arr.RemoveRange(Math::Max(0,start), Math::Min(end,arr.Length-1)-start+1);
        arr.InsertAt(start, str);
        return arr;
    }

    array<string> rangeToArr(const array<string> curarr, const int start, const int end, const array<string> str) {
        array<string> arr = curarr;
        arr.RemoveRange(Math::Max(0,start), Math::Min(end,arr.Length-1)-start+1);
        arr.InsertAt(start, str);
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
            arr = {};
        }

        return arr;
    }

    array<string> rightHandedOperators = {"sqrt", "floor", "ceil", "round", "abs"};
    dictionary functions = {
        {"min",2},
        {"max",2}
    };

    void iterateEscapeCounter() {
        iter += 1;
        if (iter > 1000) {
            escape = true;
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
            return {};
        }
        array<float> floats = {};
        for (uint i = 1; i < range.Length; i = i + 2) {
            if (Text::TryParseFloat(range[i], 0) == false) {
                escape = true;
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
        } else {
            escape = true;
            return {};
        }

        return rangeToStr(arr, pos, pos+size-1, ""+answer);
    }

    array<string> performConditional(const array<string> curarr) {
        iterateEscapeCounter();

        array<string> arr = curarr;
        int pos = getPositionsOfStrs(arr, {"?"})[0];
        array<string> range = getRangeFromList(arr, pos-3, pos+3);
        // num, conditional, num, ?, num, :, num
        if (range.Length < 7) {
            escape = true;
            return {};
        }
        float nc1 = 0;
        float nc2 = 0;
        string condition = range[1];
        if ((Text::TryParseFloat(range[0], 0) == false || Text::TryParseFloat(range[2], 0) == false) && ! (condition == "==" || condition == "!=")) {
            escape = true;
            return {};
        }
        nc1 = Text::ParseFloat(range[0]);
        nc2 = Text::ParseFloat(range[2]);

        string atrue = range[4];
        string afalse = range[6];
        bool isTrue = false;
        if (condition == ">") {
            isTrue = (nc1 > nc2);
        } else if (condition == "<") {
            isTrue = (nc1 < nc2);
        } else if (condition == "==") {
            isTrue = (range[0] == range[2]);
        } else if (condition == ">=") {
            isTrue = (nc1 >= nc2);
        } else if (condition == "<=") {
            isTrue = (nc1 <= nc2);
        } else if (condition == "!=") {
            isTrue = (range[0] != range[2]);
        } else {
            escape = true;
            return {};
        } 

        string answer = isTrue ? atrue : afalse;
        return rangeToStr(arr, pos-3, pos+3, ""+answer);
    }

    array<string> performOperand(const array<string> curarr, const array<string> strs, bool&in righthanded = false) {
        iterateEscapeCounter();

        array<string> arr = curarr;
        int pos = getPositionsOfStrs(arr, strs)[0];
        if (rightHandedOperators.Find(arr[pos]) > -1) {
            righthanded = true;
        }
        array<string> range = getRangeFromList(arr, righthanded ? pos : pos-1, pos+1);
        if (range.Length < uint(righthanded ? 2 : 3)) {
            escape = true;
            return {};
        }
        if (righthanded) {
            if (Text::TryParseFloat(range[1], 0) == false) {
                escape = true;
                return {};
            }
        } else {
            if (Text::TryParseFloat(range[0], 0) == false || Text::TryParseFloat(range[2], 0) == false) {
                escape = true;
                return {};
            }
        }
        float n1 = righthanded ? -1 : Text::ParseFloat(range[0]);
        string op = range[righthanded ? 0 : 1];
        float n2 = Text::ParseFloat(range[righthanded ? 1 : 2]);

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
        } else if (op == "-") {
            answer = n1 - n2;
        } else if (op == "^") {
            answer = n1 ** n2;
        } else if (op == "%") {
            answer = n1 % n2;
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
        return positions;
    }

    array<string> replaceValues(const array<string> curarr, const string str, const float rep) {
        array<string> arr = curarr;
        array<int> poses = getPositionsOfStrs(arr, {str});
        for (uint i = 0; i < poses.Length; i++) {
            arr[poses[i]] = ""+rep;
        }
        return arr;
    }

    array<string> arrayToArr(const array<string> curarr) {
        iter = 0;
        escape = false;
        array<string> arr = curarr;
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;
        if (track !is null) {
            if (track.MapInfo !is null && track.ChallengeParameters !is null) {
                arr = replaceValues(arr, "$BT", track.MapInfo.TMObjective_BronzeTime);
                arr = replaceValues(arr, "$ST", track.MapInfo.TMObjective_SilverTime);
                arr = replaceValues(arr, "$GT", track.MapInfo.TMObjective_GoldTime);
                arr = replaceValues(arr, "$AT", track.MapInfo.TMObjective_AuthorTime);
                arr = replaceValues(arr, "$CLONES", track.MapInfo.TMObjective_NbClones);
                if (track.MapInfo.TMObjective_IsLapRace) {
                    arr = replaceValues(arr, "$LAPS", track.MapInfo.TMObjective_NbLaps);
                } else {
                    arr = replaceValues(arr, "$LAPS", 1);
                }
                arr = replaceValues(arr, "$TYPE", int(mapType));
                if (track.ChallengeParameters.RaceValidateGhost !is null) {
                    arr = replaceValues(arr, "$VALIDATE", track.ChallengeParameters.RaceValidateGhost.RaceTime);
                } else {
                    arr = replaceValues(arr, "$VALIDATE", -1);
                }
                arr = replaceValues(arr, "$PB", Pb.Time);
#if DEPENDENCY_WARRIORMEDALS
                int warriorTime = WarriorMedals::GetWMTime();
                if (warriorTime <= 0) {
                    warriorTime = -1;
                }
                arr = replaceValues(arr, "$WT", warriorTime);
#endif
                for (uint i = 0; i < positions.GetKeys().Length; i++) {
                    string pos = positions.GetKeys()[i];
                    int time = int(positions[pos]);
                    arr = replaceValues(arr, "$#"+pos, time);
                }
                for (uint i = 0; i < queuedPositionsToGet.Length; i++) {
                    arr = replaceValues(arr, "$#"+queuedPositionsToGet[i], -1);
                }
                for (uint i = 0; i < arr.Length; i++) {
                    string item = arr[i];
                    if (item.SubStr(0,2) == "$#" && updLBs) {
                        string posStr = item.SubStr(2);
                        if (Text::TryParseInt(posStr, 0)) {
                            int pos = Text::ParseInt(posStr);
                            if (! positions.Exists(posStr) && queuedPositionsToGet.Find(pos) < 0) {
                                queuedPositionsToGet.InsertLast(pos);
                            }
                        }
                    }
                }
            }
        } 

        
        while (getPositionsOfStrs(arr, {"("}).Length > 0 && escape == false) {
            array<int> leftBrackets = getPositionsOfStrs(arr, {"("});
            array<int> rightBrackets = getPositionsOfStrs(arr, {")"});
            int lPos = leftBrackets[0];
            if (rightBrackets.Length > 0) {
                int rPos = rightBrackets[rightBrackets.Length-1];
                array<string> answer = arrayToArr(getRangeFromList(arr, lPos+1, rPos-1));
                arr = rangeToArr(arr, lPos, rPos, answer);
            } else {
                arr.RemoveAt(lPos);
            }
        }

        while (getPositionsOfStrs(arr, rightHandedOperators).Length > 0 && escape == false) {
            arr = performOperand(arr, rightHandedOperators);
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

        while (getPositionsOfStrs(arr, {"?"}).Length > 0 && escape == false) {
            arr = performConditional(arr);
        }
        return arr;
    }

    float arrayToAns(const array<string> curarr) {
        array<string> arr = arrayToArr(curarr);
        float ans = -1;
        if (arr.Length > 0 && escape == false) {
            if (Text::TryParseFloat(arr[0], 0)) {
                ans = Text::ParseFloat(arr[0]);
            }
        }
        return ans;
    }

    array<string> stringToArray(const string estr) {
        OPERTYPE curOperation = OPERTYPE::Operation;
        string opText = "";
        string str = Regex::Replace(estr, " ", "");
        array<string> split = {};
        for (int i = 0; i < int(str.Length); i++) {
		    string byte = str.SubStr(i, 1);
            OPERTYPE byteOperation = OPERTYPE::Unknown;
            if (Regex::Search(byte, "([*^%+\\/,?:])").Length > 0 && curOperation != OPERTYPE::Operation) {
                byteOperation = OPERTYPE::Operation;
            } else if (Regex::Search(byte, "([()])").Length > 0) {
                byteOperation = OPERTYPE::Bracket;
            } else if (Regex::Search(byte, "([<>=!])").Length > 0) {
                byteOperation = OPERTYPE::Condition;
            } else if (Regex::Search(byte, "([-])").Length > 0 && (str.SubStr(i-1, 1) == ")" || curOperation == OPERTYPE::Number)) {
                byteOperation = OPERTYPE::Operation;
            } else {
                byteOperation = OPERTYPE::Number;
            }
            if (byteOperation != curOperation || curOperation == OPERTYPE::Bracket) {
                curOperation = byteOperation;
                split.InsertLast(opText);
                opText = "";
            }
            opText = opText + byte;
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
