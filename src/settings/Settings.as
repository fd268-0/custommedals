[Setting name="Enable Medal Display" category="Display"]
bool Enabled = true;

[Setting name="Hide N/A Times" category="Display"]
bool HideNA = true;

[Setting name="Hide Delta Time" category="Display"]
bool HideDelta = false;

[Setting name="Hide Medal Name" category="Display"]
bool HideName = false;

[Setting name="Hide Medal Icon" category="Display"]
bool HideIcon = false;

[Setting name="Show Banners" category="Display"]
bool ShowAlerts = true;

[Setting name="Reload Interval" hidden]
VariableSettings::RELOADINTERVAL ReloadInterval = VariableSettings::RELOADINTERVAL::Per300s;


#if DEPENDENCY_ULTIMATEMEDALSEXTENDED

[Setting name="Export To UME" category="Display"]
bool MaintainUME = true;

#endif