enum OPERTYPE {
    Number,
    Operation,
    Bracket,
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

    array<string> rightHandedOperators = {"sqrt"};

    array<string> performOperand(const array<string> curarr, const array<string> strs, bool&in righthanded = false) {
        iter += 1;
        if (iter > 1000) {
            escape = true;
        }

        array<string> arr = curarr;
        int pos = getPositionsOfStrs(arr, strs)[0];
        if (rightHandedOperators.Find(arr[pos]) > -1) {
            righthanded = true;
        }
        array<string> range = getRangeFromList(arr, righthanded ? pos : pos-1, pos+1);
        if (range.Length < uint(righthanded ? 2 : 3)) {
            return {};
        }
        if (righthanded) {
            if (Text::TryParseFloat(range[1], 0) == false) {
                return {};
            }
        } else {
            if (Text::TryParseFloat(range[0], 0) == false || Text::TryParseFloat(range[2], 0) == false) {
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
        } else {
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

    float arrayToAns(const array<string> curarr) {
        iter = 0;
        escape = false;
        array<string> arr = curarr;
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;
        if (track !is null) {
            arr = replaceValues(arr, "$BT", track.MapInfo.TMObjective_BronzeTime);
            arr = replaceValues(arr, "$ST", track.MapInfo.TMObjective_SilverTime);
            arr = replaceValues(arr, "$GT", track.MapInfo.TMObjective_GoldTime);
            arr = replaceValues(arr, "$AT", track.MapInfo.TMObjective_AuthorTime);
            arr = replaceValues(arr, "$PB", Pb.Time);
#if DEPENDENCY_WARRIORMEDALS
            int warriorTime = WarriorMedals::GetWMTime();
            if (warriorTime <= 0) {
                warriorTime = -1;
            }
            arr = replaceValues(arr, "$WT", warriorTime);
#endif
        } 
        
        while (getPositionsOfStrs(arr, {"("}).Length > 0 && escape == false) {
            array<int> leftBrackets = getPositionsOfStrs(arr, {"("});
            array<int> rightBrackets = getPositionsOfStrs(arr, {")"});
            int lPos = leftBrackets[0];
            if (rightBrackets.Length > 0) {
                int rPos = rightBrackets[rightBrackets.Length-1];
                float answer = arrayToAns(getRangeFromList(arr, lPos+1, rPos-1));
                arr = rangeToStr(arr, lPos, rPos, ""+answer);
            } else {
                arr.RemoveAt(lPos);
            }
        }

         while (getPositionsOfStrs(arr, {"^","sqrt"}).Length > 0 && escape == false) {
            arr = performOperand(arr, {"^","sqrt"});
        }

        while (getPositionsOfStrs(arr, {"*","/","%"}).Length > 0 && escape == false) {
            arr = performOperand(arr, {"*","/","%"});
        }

        while (getPositionsOfStrs(arr, {"+","-"}).Length > 0 && escape == false) {
            arr = performOperand(arr, {"+","-"});
        }
        float ans = 0;
        if (arr.Length > 0) {
            Text::TryParseFloat(arr[0], ans);
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
            if (Regex::Search(byte, "([*^%+-\/])").Length > 0 && curOperation != OPERTYPE::Operation) {
                byteOperation = OPERTYPE::Operation;
            } else if (Regex::Search(byte, "([()])").Length > 0) {
                byteOperation = OPERTYPE::Bracket;
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