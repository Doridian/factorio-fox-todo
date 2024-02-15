local M = {}

local config = require("config")
local filters = require("filters")
local util = require("util")

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
    str = signal_id_to_rich_text(tag.icon, " [img=utility/custom_tag_in_map_view] ") ..
                " " .. util.trim(tag.text:gsub("TODO:?", ""):gsub(util.ASSIGNEE_PATTERN, "[color=blue]@%1[/color]"))

    if tag.last_user then
        str = str .. " [color=yellow]by " .. tag.last_user.name .. "[/color]"
    end

    return str
end

local function sort_tags(a, b)
    return a.text < b.text
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
            player.close_map()
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
    local player_tags = global.all_todo_tags_by_force[player.force.index]

    local player_gui_config = global.player_gui[player.index]
    if not player_gui_config then
        player_gui_config = {
            item_tags = {}
        }
        global.player_gui[player.index] = player_gui_config
    end

    local default_visibility = false
    local default_location = nil
    local default_show_only_own = false
    local default_show_only_same_surface = false
    local default_show_only_assigned = false
    local main_gui = player.gui.screen.fox_todo_main_gui

    if main_gui then
        default_visibility = main_gui.visible
        default_location = main_gui.location

        local checkbox_container = main_gui.checkbox_frame or main_gui.titlebar
        if checkbox_container then
            default_show_only_own = checkbox_container.show_only_own.state
            default_show_only_same_surface = checkbox_container.show_only_same_surface.state
            if checkbox_container.show_only_assigned then
                default_show_only_assigned = checkbox_container.show_only_assigned.state
            end
        end

        if (not config.version) or main_gui.tags.version ~= config.version then
            main_gui.destroy()
            main_gui = nil
        end
    end

    if not main_gui then
        main_gui = player.gui.screen.add{type="frame", name="fox_todo_main_gui", direction="vertical"}
        main_gui.auto_center = false
        main_gui.visible = default_visibility

        if default_location then
            main_gui.location = default_location
        end

        local titlebar = main_gui.add{type="flow", name="titlebar"}
        titlebar.drag_target = main_gui
        titlebar.add{
          type = "label",
          style = "frame_title",
          caption = {"gui.todo-list-title"},
          ignored_by_interaction = true,
        }

        local filler = titlebar.add{
          type = "empty-widget",
          style = "draggable_space",
          ignored_by_interaction = true,
        }
        filler.style.height = 24
        filler.style.horizontally_stretchable = true

        titlebar.add{type="checkbox", name="show_only_own", caption={"gui.show-only-own"}, state=default_show_only_own}
        titlebar.add{type="checkbox", name="show_only_same_surface", caption={"gui.show-only-same-surface"}, state=default_show_only_same_surface}
        titlebar.add{type="checkbox", name="show_only_assigned", caption={"gui.show-only-assigned"}, state=default_show_only_assigned}

        titlebar.add{
          type = "sprite-button",
          name = "todo_close_button",
          style = "frame_action_button",
          sprite = "utility/close_white",
          hovered_sprite = "utility/close_black",
          clicked_sprite = "utility/close_black",
        }

        main_gui.add{type="list-box", name="tag_list"}

        main_gui.tags.version = config.version
    end

    main_gui.style.size = {400, 400}

    local gui_tag_list = main_gui.tag_list

    if not player_tags then
        gui_tag_list.clear_items()
        player_gui_config.item_tags = {}
        return
    end

    local player_filters = {}
    if main_gui.titlebar.show_only_own.state then
        table.insert(player_filters, filters.own)
    end
    if main_gui.titlebar.show_only_same_surface.state then
        table.insert(player_filters, filters.same_surface)
    end
    if main_gui.titlebar.show_only_assigned.state then
        table.insert(player_filters, filters.assigned)
    end

    local new_item_tags = {}
    for _, tag in pairs(player_tags) do
        if should_show_tag(player, tag, player_filters) then
            table.insert(new_item_tags, tag)
        end
    end

    table.sort(new_item_tags, sort_tags)

    local new_items = {}
    for _, tag in pairs(new_item_tags) do
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

    show_gui = not player.gui.screen.fox_todo_main_gui.visible
    player.set_shortcut_toggled("fox-todo-toggle-gui", show_gui)
    player.gui.screen.fox_todo_main_gui.visible = show_gui
end

function M.render_todo_gui_force(force)
    for _, ply in pairs(force.players) do
        M.render_todo_gui_player(ply)
    end
end

local function render_todo_gui_player_index_event(event)
    M.render_todo_gui_player(game.players[event.player_index])
end

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
    if event.element.name == "tag_list" then
        local player_gui_config = global.player_gui[event.player_index]
        if player_gui_config then
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

script.on_event(defines.events.on_gui_click, function(event)
    local player = game.players[event.player_index]
    if event.element.name == "todo_close_button" then
        player.gui.screen.fox_todo_main_gui.visible = false
        player.set_shortcut_toggled("fox-todo-toggle-gui", false)
    end
end)

script.on_event("fox-todo-toggle-gui", function(event)
    local player = game.players[event.player_index]
    M.toggle_todo_gui_player(player)
end)

script.on_event(defines.events.on_lua_shortcut, function(event)
    if event.prototype_name ~= "fox-todo-toggle-gui" then
        return
    end
    local player = game.players[event.player_index]
    M.toggle_todo_gui_player(player)
end)

script.on_event(defines.events.on_player_joined_game, render_todo_gui_player_index_event)
script.on_event(defines.events.on_player_changed_force, render_todo_gui_player_index_event)

script.on_event(defines.events.on_player_changed_surface, function(event)
    local player = game.players[event.player_index]

    local main_gui = player.gui.screen.fox_todo_main_gui
    if not main_gui then
        return
    end

    if not main_gui.titlebar.show_only_same_surface.state then
        return
    end

    M.render_todo_gui_player(player)
end)

script.on_event(defines.events.on_player_removed, function(event)
    global.player_gui[event.player_index] = nil
end)

return M
