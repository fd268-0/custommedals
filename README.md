This is the third rewrite of the equation handling code I've written. xdd

This plugin allows you to enter custom equations to create unique medals in Trackmania 2020.
Find it on Openplanet under the name 'Custom Medals'.

## Export support

This fork adds a small Openplanet export so other plugins can read the currently resolved custom medals without re-implementing the equation engine.

Exported function:

```angelscript
namespace CustomMedals {
    import string GetCustomMedalsJson() from "CustomMedals";
}
```

The function returns a JSON array string. Each item contains:

- `name`
- `time`
- `iconColor`
- `icon`
- `isPb`

The assets/files contained in this github repository must not be used to train AI models.
