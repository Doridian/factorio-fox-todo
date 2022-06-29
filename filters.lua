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

return M
