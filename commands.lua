local tags = require("tags")

commands.add_command("refresh_all_todo_tags", nil, function(command)
    local player = nil
    if command.player_index then
        player = game.players[command.player_index]
        if not player then
            return
        end
        if not player.admin then
            return
        end
    end

    tags.refresh_all_tags()
    
    local printer = player or game
    printer.print({"commands.refreshed-all-todo-tags"})
end)

commands.add_command("refresh_my_todo_tags", nil, function(command)
    if not command.player_index then
        return
    end

    local player = game.players[command.player_index]
    if not player then
        return
    end
    
    tags.refresh_force_tags(player.force)

    local printer = player or game
    printer.print({"commands.refreshed-your-todo-tags"})
end)
