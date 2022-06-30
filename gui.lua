local M = {}

local config = require("config")
local all_todo_tags_by_force = require("tags_holder")
local filters = require("filters")

local function signal_id_to_rich_text(signal_id, default)
    if not signal_id then
        return default or ""
    end

    local rt_type = signal_id.type
    if rt_type == "virtual" then
        rt_type = "virtual-signal"
    end
    return "[" .. rt_type .. "="  .. signal_id.name .. "]"
end

local function get_tag_caption(tag)
    return signal_id_to_rich_text(tag.icon, " [img=utility/custom_tag_in_map_view] ") ..
                " " .. tag.text:sub(config.tag_prefix_len + 1) ..
                " [color=yellow]by " .. tag.last_user.name .. "[/color]"
end

-- Function used for filter configuration later
local function should_show_tag(player, tag, filters_array)
    for _, filter in pairs(filters_array) do
        if not filter(player, tag) then
            return false
        end
    end
    return true
end

local function go_to_position(player, location_name, position, surface_index)
    if remote.interfaces["space-exploration"] then
        local remote_view_allowed = remote.call("space-exploration", "remote_view_is_unlocked", {player=player})
        if remote_view_allowed or surface_index ~= player.surface.index then
            local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index=surface_index})
            if not zone then
                player.print({"se-no-zone-for-surface"})
                return
            end
            remote.call("space-exploration", "remote_view_start", {
                player=player,
                position=position,
                zone_name=zone.name,
                location_name=location_name,
                freeze_history=true
            })
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
    local player_tags = all_todo_tags_by_force[player.force.index]

    local player_gui_config = global.player_gui[player.index]
    if not player_gui_config then
        player_gui_config = {}
        global.player_gui[player.index] = player_gui_config
    end

    local main_gui
    if not player.gui.screen.fox_todo_main_gui then
        main_gui = player.gui.screen.add{type="frame", name="fox_todo_main_gui", caption={"gui.todo-list-title"}, direction="vertical"}
        main_gui.auto_center = false
        main_gui.visible = false

        local checkbox_frame = main_gui.add{type="flow", name="checkbox_frame", direction="horizontal"}
        checkbox_frame.style.horizontal_align = "right"
        checkbox_frame.style.horizontally_stretchable = true
        checkbox_frame.add{type="checkbox", name="show_only_own", caption={"gui.show-only-own"}, state=false}
        checkbox_frame.add{type="checkbox", name="show_only_same_surface", caption={"gui.show-only-same-surface"}, state=false}

        main_gui.add{type="list-box", name="tag_list"}
    else
        main_gui = player.gui.screen.fox_todo_main_gui
    end

    main_gui.style.size = {400, 400}

    local gui_tag_list = main_gui.tag_list

    if not player_tags then
        gui_tag_list.clear_items()
        player_gui_config.item_tags = {}
        return
    end

    local old_tags = {}
    if player_gui_config.item_tags then
        for idx, tag in pairs(player_gui_config.item_tags) do
            old_tags[tag.tag_number] = idx
        end
    end

    local player_filters = {}
    if main_gui.checkbox_frame.show_only_own.state then
        table.insert(player_filters, filters.own)
    end
    if main_gui.checkbox_frame.show_only_same_surface.state then
        table.insert(player_filters, filters.same_surface)
    end

    local added_tags = {}
    local present_tags = {}
    for tag_number, tag in pairs(player_tags) do
        if should_show_tag(player, tag, player_filters) then
            if not old_tags[tag_number] then
                added_tags[tag_number] = tag
            end
            present_tags[tag_number] = tag
        end
    end

    local new_item_tags = {}
    local new_items = {}
    
    for _, tag in pairs(player_gui_config.item_tags) do
        if present_tags[tag.tag_number] then
            table.insert(new_item_tags, tag)
            table.insert(new_items, get_tag_caption(tag))
        end
    end
    for _, tag in pairs(added_tags) do
        table.insert(new_item_tags, tag)
        table.insert(new_items, get_tag_caption(tag))
    end

    gui_tag_list.items = new_items
    player_gui_config.item_tags = new_item_tags
end

function M.toggle_todo_gui_player(player)
    local player_gui_config = global.player_gui[player.index]
    
    if not player.gui.screen.fox_todo_main_gui then
        return M.render_todo_gui_player(player)
    end

    player.gui.screen.fox_todo_main_gui.visible = not player.gui.screen.fox_todo_main_gui.visible
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

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
    local player = game.players[event.player_index]
    M.render_todo_gui_player(player)
end)

script.on_event("fox-todo-toggle-gui", function(event)
    local player = game.players[event.player_index]
    M.toggle_todo_gui_player(player)
end)

script.on_event(defines.events.on_player_joined_game, render_todo_gui_player_index_event)
script.on_event(defines.events.on_player_changed_force, render_todo_gui_player_index_event)

return M
