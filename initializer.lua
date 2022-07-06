local config = require("config")
local tags = require("tags")

local M = {}

function M.initialize_mod()
    if config.version and (global.mod_version == config.version) then
        return
    end

    global.player_gui = global.player_gui or {}
    global.all_todo_tags_by_force = global.all_todo_tags_by_force or {}

    tags.find_all_tags()

    global.mod_version = config.version
end

script.on_init(M.initialize_mod)
script.on_configuration_changed(M.initialize_mod)

return M
