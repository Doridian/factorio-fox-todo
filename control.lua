local gui = require("gui")
local tags = require("tags")

script.on_event(defines.events.on_tick, function()
    script.on_event(defines.events.on_tick, nil)

    tags.find_all_tags()

    for _, ply in pairs(game.connected_players) do
        gui.render_todo_gui_player(ply)
    end
end)

script.on_init(function()
    global.player_gui = {}
end)
