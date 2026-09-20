A redesign of the Custom Medals codebase.

Exports are currently being redone, but here's the rundown:

### string GetCustomMedalsJson()
Get all custom medals.

### string GetCustomMedalJson(const string name)
Returns the first medal with the given name.

### bool HasCustomMedal(const string name)
Returns if a medal with the given name exists.

### void AddCustomVariable(const string name, const string value)
Add a variable usable in all medal equations under `#variablename`.

### void Refresh()
Recalculate all medals.

### Calculate(const string text)
Evaluate a string of text.
