namespace CustomMedals {
    // Refer to the Github repository README.md for information on exports!
    import string GetCustomMedalsJson() from "CustomMedals";
    import string GetCustomMedalJson(const string name) from "CustomMedals";
    import bool HasCustomMedal(const string name) from "CustomMedals";

    // Experimental below
    import void AddCustomVariable(const string name, const string value) from "CustomMedals";
    import void Refresh() from "CustomMedals";
    import float Calculate(const string text) from "CustomMedals";
}