local config = require("config")
local tags = require("tags")

local M = {}

function M.initialize_mod()
    if config.version and (storage.mod_version == config.version) then
        return
    end

    storage.player_gui = storage.player_gui or {}

    tags.refresh_all_tags()

    storage.mod_version = config.version
end

script.on_init(M.initialize_mod)
script.on_configuration_changed(M.initialize_mod)

return M
