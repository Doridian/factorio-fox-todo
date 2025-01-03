local gui = require("gui")
local config = require("config")
local util = require("util")

local M = {}

local function is_tag_todo(tag)
    if not util.is_valid_tag(tag) then
        return false
    end

    return tag.text:find("^TODO") ~= nil
end

local function on_tag_added(tag, force)
    if not is_tag_todo(tag) then
        return
    end

    if not storage.all_todo_tags_by_force[force.index] then
        storage.all_todo_tags_by_force[force.index] = {}
    end
    storage.all_todo_tags_by_force[force.index][tag.tag_number] = tag
    gui.render_todo_gui_force(force)
end

local function on_tag_removed(tag, force)
    if not storage.all_todo_tags_by_force[force.index] then
        return
    end

    if storage.all_todo_tags_by_force[force.index][tag.tag_number] then
        storage.all_todo_tags_by_force[force.index][tag.tag_number] = nil
        if not next(storage.all_todo_tags_by_force[force.index]) then
            storage.all_todo_tags_by_force[force.index] = nil
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
    for force_index, tags in pairs(storage.all_todo_tags_by_force) do
        local force = game.forces[force_index]

        if not (force and force.valid) then
            storage.all_todo_tags_by_force[force_index] = nil
        else
            local new_tags = {}
            local tags_modified = false
            local tags_found = false

            for idx, tag in pairs(tags) do
                tags_found = true
                if is_tag_todo(tag) then
                    new_tags[idx] = tag
                else
                    tags_modified = true
                end
            end

            if tags_modified then
                if not tags_found then
                    new_tags = nil
                end
                storage.all_todo_tags_by_force[force_index] = new_tags
                gui.render_todo_gui_force(force)
            end
        end
    end
end

function M.refresh_force_tags(force)
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
        storage.all_todo_tags_by_force[force.index] = todo_tags
    else
        storage.all_todo_tags_by_force[force.index] = nil
    end

    gui.render_todo_gui_force(force)
end

function M.refresh_all_tags()
    storage.all_todo_tags_by_force = {}

    for _, force in pairs(game.forces) do
        M.refresh_force_tags(force)
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

script.on_event(defines.events.on_force_reset, function(event)
    M.refresh_force_tags(event.force)
end)

script.on_event(defines.events.on_forces_merged, function(event)
    storage.all_todo_tags_by_force[event.source_index] = nil
    M.refresh_force_tags(event.destination)
end)

script.on_event(defines.events.on_surface_cleared, M.cleanup_tags)
script.on_event(defines.events.on_surface_deleted, M.cleanup_tags)

return M
