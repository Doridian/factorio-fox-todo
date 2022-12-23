-- data.lua

local toggle_gui_hotkey = {
    type = "custom-input",
    name = "fox-todo-toggle-gui",
    key_sequence = "SHIFT + T",
    consuming = "none",
}

local toggle_gui_shortcut = {
    type = "shortcut",
    name = "fox-todo-toggle-gui",
    action = "lua",
    toggleable = true,
    order = "ft-a[open]",
    associated_control_input = "fox-todo-toggle-gui",
    style = "blue",
    icon =
    {
      filename = "__fox-todo__/graphics/fox-todo-button.png",
      priority = "extra-high-no-scale",
      size = 24,
      flags = {"gui-icon"}
    },
    small_icon =
    {
      filename = "__fox-todo__/graphics/fox-todo-button.png",
      priority = "extra-high-no-scale",
      size = 24,
      flags = {"gui-icon"}
    },
    disabled_small_icon =
    {
      filename = "__fox-todo__/graphics/fox-todo-button.png",
      priority = "extra-high-no-scale",
      size = 24,
      flags = {"gui-icon"}
    },
}

data:extend({
    toggle_gui_hotkey,
    toggle_gui_shortcut,
})
