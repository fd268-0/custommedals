namespace ImportingHandler {
    array<CMedal> MapImports = {};
    string MapImportToStr() {
        array<string> mdlStrs = {};
        for (uint i = 0; i < MapImports.Length; i++) {
            CMedal medal = MapImports[i];
            mdlStrs.InsertLast(medal.Icon+","+medal.Name+","+medal.Time);
        }
        return string::Join(mdlStrs,";");
    }
    void GetMapImports() {
        auto app = cast<CTrackMania>(GetApp());
        auto track = app.RootMap;
        MapImports = {};
        if (track is null) {
            warn("Importing medals from map failed: no map found!");
            return;
        }

        // icon,name,time;icon,name,time
        string comments = track.Comments;
        int indexOfStart = comments.IndexOf("CustomMedals{");
        if (indexOfStart > -1) {
            string subComment = comments.SubStr(indexOfStart+13);
            string listVal = subComment.Split("}")[0];
            array<string> mdlList = listVal.Split(";");
            //array<array<string>> paramList = {};
            for (uint i = 0; i < mdlList.Length; i++) {
                array<string> params = mdlList[i].Split(",");
                //paramList.InsertLast(params);
                CMedal mMedal;
                mMedal.Time = Text::ParseInt(params[2]);
                mMedal.Icon = params[0];
                mMedal.Name = params[1];
                mMedal.IconColor = "";
                mMedal.IsImported = true;
                mMedal.Id = "map@" + i;
                MapImports.InsertLast(mMedal);
            }
        }
    }
}