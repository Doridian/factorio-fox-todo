local M = {}

local all_filters = {}
function all_filters.same_surface(player, tag)
    return player.surface.index == tag.surface.index
end

function all_filters.own(player, tag)
    return player.index == tag.last_user.index
end

function M.get_filter(name)
    return all_filters[name]
end

function M.set_filters_for(player, filter_names)
    global.player_filters[player.index] = filter_names
end

function M.get_filters_for(player, resolve)
    local filter_names = global.player_filters[player.index]
    if not filter_names then
        return {}
    end
    
    if not resolve then
        return filter_names
    end

    local filters = {}
    for _, name in pairs(filter_names) do
        local filter = M.get_filter(name)
        if filter then
            table.insert(filters, filter)
        end
    end
    return filters
end

return M
