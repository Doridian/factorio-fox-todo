local M = {}

local TRIM_PATTERN_1 = "^%s+"
local TRIM_PATTERN_2 = "%s+$"

local ASSIGNEE_PATTERN = "@([^%s]+)"
M.ASSIGNEE_PATTERN = ASSIGNEE_PATTERN

function M.trim(str)
    return str:gsub(TRIM_PATTERN_1, ""):gsub(TRIM_PATTERN_2, "")
end

function M.get_tag_assignee(tag)
    local m = tag.text:match(ASSIGNEE_PATTERN)
    if not m then
        return nil     
    end
    return game.players[m]
end

return M
