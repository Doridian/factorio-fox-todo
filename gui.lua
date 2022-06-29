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

local function tag_to_gps_tag(tag)
    -- Technically invalid GPS tag, but it works for our purposes
    return "[gps=" .. tostring(tag.position.x) .. "," .. tostring(tag.position.y) .. "," .. tostring(tag.surface.index) .. "]"
end

local function list_item_extract_gps_tag_info(text)
    local x, y, surface = text:match("%[gps=([^%],]+),([^%],]+),([^%],]+)%]")
    if x == nil or y == nil or surface == nil then
        return
    end
    return {x = tonumber(x),  y = tonumber(y)}, tonumber(surface)
end

local function go_to_position(player, name, position, surface_index)
    if remote.interfaces["space-exploration"] then
        local remote_view_allowed = remote.call("space-exploration", "remote_view_is_unlocked", {player=player})
        if remote_view_allowed or surface_index ~= player.surface.index then
            local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index=surface_index})
            if not zone then
                player.print("Could not find zone for given surface! THIS IS A BUG!")
                return
            end
            remote.call("space-exploration", "remote_view_start", {player=player, position=position, zone_name=zone.name, location_name=name, freeze_history=true})
            return
        end
    end

    if surface_index ~= player.surface.index then
        player.print("Can not show map on different surface than the one you are on!")
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

    if not tags then
        -- TODO: put notice here
        return
    end


    for tag_number, tag in pairs(tags) do
        local caption = tag_to_gps_tag(tag) .. " " .. signal_id_to_rich_text(tag.icon) .. " " .. tag.text
        tag_list.add_item(caption)
    end
end

function M.render_todo_gui_force(force)
    for _, ply in pairs(force.connected_players) do
        M.render_todo_gui_player(ply)
    end
end

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
    if event.element.name == "tag_list" then
        local player = game.players[event.player_index]
        local selected_item = event.element.get_item(event.element.selected_index)
        local pos, surface_index = list_item_extract_gps_tag_info(selected_item)
        if pos then
            go_to_position(player, selected_item, pos, surface_index)
        end
        event.element.selected_index = 0
    end
end)

script.on_event(defines.events.on_player_joined_game, function(event)
    local player = game.players[event.player_index]
    M.render_todo_gui_player(player)
end)

return M
