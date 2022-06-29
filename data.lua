-- data.lua

local toggle_gui_hotkey = {
    type = "custom-input",
    name = "fox-todo-toggle-gui",
    key_sequence = "SHIFT + T",
    consuming = "none",
}

data:extend({toggle_gui_hotkey})
