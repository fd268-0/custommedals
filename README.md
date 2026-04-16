This is the third rewrite of the equation handling code I've written. xdd

This plugin allows you to enter custom equations to create unique medals in Trackmania 2020.
Find it on Openplanet under the name 'Custom Medals'.

The assets/files contained in this github repository must not be used to train AI models.

# Exports
Added in v0.4.0 (not released yet.)
Add `CustomMedals` as a dependency or optional dependency.

### `string CustomMedals::GetCustomMedalsJson()`
Returns a Json::Array value, stringifed.
Each item in the Json::Array includes:
- `time` 
- `iconColor`
- `icon`
- `name`
- `isImported` - Is it imported from any Import source (Map Imports)
> Call `CustomMedals::Refresh` before using this if you changed anything!

### `string CustomMedals::GetCustomMedalJson(string name)`
Returns a Json::Object value, stringifed. It includes:
- `time` 
- `iconColor`
- `icon`
- `name`
- `isImported` - Is it imported from any Import source (Map Imports)
> Call `CustomMedals::Refresh` before using this if you changed anything!

### `bool CustomMedals::HasCustomMedal(string name)`
Returns weither a given custom medal exists.

## Experimental
These exports are experimental as of v0.4.0; they may / may not work

### `void CustomMedals::AddCustomVariable(string name, string value)`
Adds a custom variable to CustomMedals.
> The name of the variable usable in CustomMedals will be `#name`. This is to prevent user-defined variables being overwritten.

### `void CustomMedals::Refresh()`
Reevaluates the equations for all medals. This isn't called with `CustomMedals::AddCustomVariable`!
> This will cause performance issues if called every frame. Only use this when necessary.
