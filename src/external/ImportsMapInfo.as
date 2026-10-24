namespace ImportHandler {
    int players = -1;
    int worstTime = -1;
    void GetMapInfo() {
#if DEPENDENCY_MAPINFO
        if (MapInfo::GetCurrentMapInfo() == null) {
            return;
        }
        while (MapInfo::GetCurrentMapInfo().LoadedNbPlayers == false || MapInfo::GetCurrentMapInfo().NbPlayers < 0 || MapInfo::GetCurrentMapInfo().LoadedMapData == false) {
            yield();
        }
        
		auto mapInfo = MapInfo::GetCurrentMapInfo();

		if (mapInfo !is null) {
            players = mapInfo.NbPlayers;
            worstTime = mapInfo.WorstTime;        
        }
#endif
    }

    void ClearImports() {
        players = -1;
        worstTime = -1;
    }

}