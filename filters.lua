local M = {}
function M.same_surface(player, tag)
    return player.surface.index == tag.surface.index
end

function M.own(player, tag)
    return player.index == tag.last_user.index
end
return M
