-- Hide SE specific settings if SE is not installed
if not mods["space-exploration"] then
    data.raw["bool-setting"]["fox-todo-use-se-remote-view"].hidden = true
    data.raw["bool-setting"]["fox-todo-use-se-remote-view-same-surface"].hidden = true
end
