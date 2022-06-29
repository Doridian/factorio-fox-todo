local M = {}

local all_todo_tags_by_force = require("tags_holder")

local function signal_id_to_rich_text(signal_id)
    if not signal_id then
        return " [img=utility/custom_tag_in_map_view] "
    end

    local rt_type = signal_id.type
    if rt_type == "virtual" then
        rt_type = "virtual-signal"
    end
    return "[" .. rt_type .. "="  .. signal_id.name .. "]"
end

local function go_to_position(player, name, position, surface_index)
    if remote.interfaces["space-exploration"] then
        local remote_view_allowed = remote.call("space-exploration", "remote_view_is_unlocked", {player=player})
        if remote_view_allowed or surface_index ~= player.surface.index then
            local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index=surface_index})
            if not zone then
                player.print({"se-no-zone-for-surface"})
                return
            end
            remote.call("space-exploration", "remote_view_start", {player=player, position=position, zone_name=zone.name, location_name=name, freeze_history=true})
            return
        end
    end

    if surface_index ~= player.surface.index then
        player.print({"require-same-surface-map"})
        return
    end

    player.open_map(position)
end

function M.render_todo_gui_player(player)
    local tags = all_todo_tags_by_force[player.force.index]

    local player_gui_config = global.player_gui[player.index]
    if not player_gui_config then
        player_gui_config = {}
        global.player_gui[player.index] = player_gui_config
    end

    if player_gui_config.closed then
        return
    end

    if not player.gui.screen.fox_todo_main_gui then
        local main_gui = player.gui.screen.add{type="frame", name="fox_todo_main_gui", caption={"gui.todo-list-title"}}
        main_gui.style.size = {385, 165}
        main_gui.auto_center = false
        main_gui.add{type="list-box", name="tag_list"}
    end

    local tag_list = player.gui.screen.fox_todo_main_gui.tag_list
    tag_list.clear_items()
    player_gui_config.item_tags = {}

    if not tags then
        -- TODO: put notice here
        return
    end


    for tag_number, tag in pairs(tags) do
        local caption = signal_id_to_rich_text(tag.icon) .. " " .. tag.text
        tag_list.add_item(caption)
        table.insert(player_gui_config.item_tags, tag)
    end
end

function M.render_todo_gui_force(force)
    for _, ply in pairs(force.connected_players) do
        M.render_todo_gui_player(ply)
    end
end

local function render_todo_gui_player_index_event(event)
    M.render_todo_gui_player(game.players[event.player_index])
end

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
    if event.element.name == "tag_list" then
        local player_gui_config = global.player_gui[event.player_index]
        if player_gui_config and player_gui_config.item_tags then
            local player = game.players[event.player_index]
            local tag = player_gui_config.item_tags[event.element.selected_index]
            if tag then
                go_to_position(player, selected_item, tag.position, tag.surface.index)
            end
        end
        event.element.selected_index = 0
    end
end)

script.on_event(defines.events.on_player_joined_game, render_todo_gui_player_index_event)
script.on_event(defines.events.on_player_changed_force, render_todo_gui_player_index_event)

return M
