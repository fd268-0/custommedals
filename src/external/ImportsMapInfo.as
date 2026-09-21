namespace ImportHandler {
    int players = -1;
    int worstTime = -1;
    void GetMapInfo() {
#if DEPENDENCY_MAPINFO
        while (MapInfo::GetCurrentMapInfo().LoadedNbPlayers == false || MapInfo::GetCurrentMapInfo().LoadedMapData == false) {
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