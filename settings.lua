-- settings.lua

data:extend({
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
  