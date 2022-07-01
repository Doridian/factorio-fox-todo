-- data.lua

local styles = data.raw["gui-style"].default

styles.fox_todo_list = {
    type = "table_style",
    parent = "mods_table",
}

local toggle_gui_hotkey = {
    type = "custom-input",
    name = "fox-todo-toggle-gui",
    key_sequence = "SHIFT + T",
    consuming = "none",
}

data:extend({toggle_gui_hotkey})
