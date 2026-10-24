class InputResult {

    InputResult() {
        
    }

    InputResult(const string r, bool c) {
        string = r;
        changed = c;
    }

    InputResult(float r, bool c) {
        number = r;
        changed = c;
    }

    InputResult(int r, bool c) {
        integer = r;
        number = r;
        changed = c;
    }

    InputResult(uint r, bool c) {
        integer = r;
        number = r;
        changed = c;
    }

    InputResult(vec2 r, bool c) {
        vec2 = r;
        changed = c;
    }

    InputResult(vec3 r, bool c) {
        vec3 = r;
        changed = c;
    }

    InputResult(vec4 r, bool c) {
        vec4 = r;
        changed = c;
    }

    vec4 vec4;
    vec3 vec3;
    vec2 vec2;
    float number;
    string string;
    int integer;
    bool changed = false;
}


namespace UIR {
    InputResult InputText(const int sizing, const string&in id, const string&in label, const string&in str, int flags = UI::InputTextFlags::None) {
        UI::PushID(id);
        UI::PushItemWidth(sizing);
        bool isChanged;
        string resultText = UI::InputText(label, str, isChanged, flags);
        UI::PopItemWidth();
        UI::PopID();
        return InputResult(resultText, isChanged);
    }
    InputResult InputInt(const int sizing, const string&in id, const string&in label, int&in num, int step = 1) {
        UI::PushID(id);
        UI::PushItemWidth(sizing);
        int resultText = UI::InputInt(label, num, step);
        bool isChanged = (resultText == num);
        UI::PopItemWidth();
        UI::PopID();
        return InputResult(resultText, isChanged);
    }
    InputResult InputUint(const int sizing, const string&in id, const string&in label, uint&in num, int step = 1) {
        UI::PushID(id);
        UI::PushItemWidth(sizing);
        uint resultText = UI::InputUint(label, num, step);
        bool isChanged = (resultText == num);
        UI::PopItemWidth();
        UI::PopID();
        return InputResult(resultText, isChanged);
    }
    InputResult InputFloat(const int sizing, const string&in id, const string&in label, float&in num, float step = 1.0f, float step_fast = 1.0f, const string&in format = "%.3f") {
        UI::PushID(id);
        UI::PushItemWidth(sizing);
        float resultText = UI::InputFloat(label, num, step, step_fast, format);
        bool isChanged = (resultText == num);
        UI::PopItemWidth();
        UI::PopID();
        return InputResult(resultText, isChanged);
    }
    InputResult InputColor3(const int sizing, const string&in id, const string&in label, const vec3&in color, int flags = UI::ColorEditFlags::None) {
        UI::PushID(id);
        UI::PushItemWidth(sizing);
        vec3 resultText = UI::InputColor3(label, color, flags);
        bool isChanged = (resultText == color);
        UI::PopItemWidth();
        UI::PopID();
        return InputResult(resultText, isChanged);
    }
}