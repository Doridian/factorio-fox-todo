local gui = require("gui")
local all_todo_tags_by_force = require("tags_holder")

local M = {}

local function is_tag_todo(tag)
    return tag.text:sub(1, 4) == "TODO"
end

local function on_tag_added(tag, force)
    if not is_tag_todo(tag) then
        return
    end

    if not all_todo_tags_by_force[force.index] then
        all_todo_tags_by_force[force.index] = {}
    end
    all_todo_tags_by_force[force.index][tag.tag_number] = tag
    gui.render_todo_gui_force(force)
end

local function on_tag_removed(tag, force)
    if not all_todo_tags_by_force[force.index] then
        return
    end

    if all_todo_tags_by_force[force.index][tag.tag_number] then
        all_todo_tags_by_force[force.index][tag.tag_number] = nil
        if not next(all_todo_tags_by_force[force.index]) then
            all_todo_tags_by_force[force.index] = nil
        end
        gui.render_todo_gui_force(force)
    end
end

local function on_tag_modified(tag, force)
    if not is_tag_todo(tag) then
        return on_tag_removed(tag, force)
    end

    return on_tag_added(tag, force)
end

function M.cleanup_tags()
    for force_index, tags in pairs(all_todo_tags_by_force) do
        local force = game.forces[force_index]

        if not force.valid then
            all_todo_tags_by_force[force_index] = nil
        else
            local new_tags = {}
            local tags_modified = false
            local tags_found = false

            for idx, tag in pairs(tags) do
                tags_found = true
                if tag.valid then
                    new_tags[idx] = true
                else
                    tags_modified = true
                end
            end

            if tags_modified then
                if not tags_found then
                    new_tags = nil
                end
                all_todo_tags_by_force[force_index] = new_tags
                gui.render_todo_gui_force(force)
            end
        end
    end
end

function M.find_all_tags()
    for _, force in pairs(game.forces) do
        local todo_tags = {}
        local has_tags = false

        for _, surface in pairs(game.surfaces) do
            local tags = force.find_chart_tags(surface)
            for _, tag in pairs(tags) do
                if is_tag_todo(tag) then
                    todo_tags[tag.tag_number] = tag
                    has_tags = true
                end
            end
        end

        if has_tags then
            all_todo_tags_by_force[force.index] = todo_tags
        end
    end
end

script.on_event(defines.events.on_chart_tag_added, function(event)
    on_tag_added(event.tag, event.force)
end)

script.on_event(defines.events.on_chart_tag_removed, function(event)
    on_tag_removed(event.tag, event.force)
end)

script.on_event(defines.events.on_chart_tag_modified, function(event)
    on_tag_modified(event.tag, event.force)
end)

script.on_event(defines.events.on_surface_cleared, M.cleanup_tags)
script.on_event(defines.events.on_surface_deleted, M.cleanup_tags)
script.on_event(defines.events.on_force_reset, M.cleanup_tags)
script.on_event(defines.events.on_forces_merged, M.cleanup_tags)

return M
