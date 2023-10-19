local util = require("util")

local M = {}

function M.same_surface(player, tag)
    return player.surface.index == tag.surface.index
end

function M.own(player, tag)
    if not tag.last_user then
        return false
    end
    return player.index == tag.last_user.index
end

function M.assigned(player, tag)
    local assignee = util.get_tag_assignee(tag)
    return assignee and assignee.index == player.index
end

return M
