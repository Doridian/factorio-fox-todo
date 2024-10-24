-- data.lua

data:extend({
  {
    type = "shortcut",
    name = "fox-todo-toggle-gui",
    action = "lua",
    toggleable = true,
    order = "ft-a[open]",
    associated_control_input = "fox-todo-toggle-gui",
    style = "blue",
    icon = "__fox-todo__/graphics/fox-todo-button.png",
    icon_size = 24,
    small_icon = "__fox-todo__/graphics/fox-todo-button.png",
    small_icon_size = 24,
  },
  {
    type = "custom-input",
    name = "fox-todo-toggle-gui",
    key_sequence = "SHIFT + T",
    consuming = "none",
  },
  {
    type = "bool-setting",
    name = "fox-todo-use-se-remote-view",
    setting_type = "runtime-per-user",
    default_value = true,
    per_user = true,
  },
  {
    type = "bool-setting",
    name = "fox-todo-use-se-remote-view-same-surface",
    setting_type = "runtime-per-user",
    default_value = false,
    per_user = true,
  },
})
