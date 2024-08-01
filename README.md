# Godot Google Sheets Database

This implementation allows loading data from a google sheet to be used as a data source for a Godot project.

This is currently a oneway data source from Google Sheets into Godot, with local persistence.

---

[TOC]

---

## Setup

### Config file

1. Duplicate the configuration file: `res://code/sheet_db/SecretConfigSample.cfg`
2. Rename it to `SecretConfig.cfg`
3. [Setup a google api key](https://support.google.com/googleapi/answer/6158862?hl=en)
4. Fill out the details from your google sheet

### Google sheet

1. Your version tab needs must have the version specified at A1

 >I recommed linking the version cell in the databse tab with this formula `=version!A1` where `version` is the name of the version tab.

2. Row 1 is reserved for the column names, the current transformer uses these as keys for a dictionary, more on this below.

3. Column A is empty, besides A1 reserved for the version number

4. Column B is used as the root ID or KEY into the data when it gets transformed into a dictionary, more on this below.

![version example](/docs/version_tab_example.png)
![database example](/docs/database_tab_example.png)

### Transformer

`res://code/sheet_db/Transformer.gd`

The transformer is responsible for the conversion of the data into the data structure that your app or game wants to use.

As an example the `REQUIRED` column data is split into an array of strings.

The transformer example takes in the following data structure that comes back from the http request:

```gdscript
[
    [
        "0.0.1",
        "ID",
        "DATA",
        "REQUIRED",
        "ITEM_REWARDS",
        "ZONE_UNLOCK"
    ],
    [
        "",
        "001",
        "a",
        "",
        "map",
        "zone_1"
    ],
    [
        "",
        "002",
        "b",
        "001",
        "straw"
    ],
    [
        "",
        "003",
        "c",
        "001,002",
        "sticks",
        "zone_2"
    ]
]
```

and outputs the following:

```gdscript
{
    "001": {
        "DATA": "a",
        "ID": "001",
        "ITEM_REWARDS": "map",
        "REQUIRED": [],
        "ZONE_UNLOCK": "zone_1"
    },
    "002": {
        "DATA": "b",
        "ID": "002",
        "ITEM_REWARDS": "straw",
        "REQUIRED": [ "001" ]
    },
    "003": {
        "DATA": "c",
        "ID": "003",
        "ITEM_REWARDS": "sticks",
        "REQUIRED": [ "001", "002" ],
        "ZONE_UNLOCK": "zone_2"
    },
    "version": "0.0.1"
}
```

The modification of the transformer is left as an exercise for the reader to adapt to their own data structure needs.

---

## Updates

Data is downloaded on the first launch and then stored locally in the `user://` directory.
See [Godot's docs](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html) for more info on data paths.

| OS      | Path |
|:--------|:-----|
| Windows | %APPDATA%\Godot\app_userdata\\[project_name] |
| macOS   | ~/Library/Application Support/Godot/app_userdata/[project_name] |
| Linux   | ~/.local/share/godot/app_userdata/[project_name] |

Subsequent launches will then perform a version check and offer to update when the db version differs from the local one.

With this you can simply update the data in the sheet, change the version value and the next time the game is launched it will offer the user to update data.
