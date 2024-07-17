function findPath(target)
    local offsets = {
        {x = -1, y =  0},
        {x =  1, y =  0},
        {x =  0, y = -1},
        {x =  0, y =  1}
    }

    for x = 0, 10 do
        for y = 0, 10 do
            room[x][y].distance = 0
            room[x][y].rangedDistance = 0
        end
    end

    --  calculate distances for ranged enemies in step 2
    for step = 1, 2 do
        for x = 0, 10 do
            for y = 0, 10 do
                room[x][y].visited = false
            end
        end

        local queue = {}
        room[target.x][target.y].distance = 0
        room[target.x][target.y].rangedDistance = 0
        room[target.x][target.y].visited = true
        table.insert(queue, target)

        if (step == 2) then
            --  scan left
            local x = target.x - 1
            local y = target.y
            while (x >= 0) do
                if (room[x][y].solid) then
                    break
                else
                    table.insert(queue, {x = x, y = y})
                    room[x][y].rangedDistance = 0
                    room[x][y].visited = true
                end
                x = x - 1
            end

            --  scan right
            x = target.x + 1
            while (x <= 10) do
                if (room[x][y].solid) then
                    break
                else
                    table.insert(queue, {x = x, y = y})
                    room[x][y].rangedDistance = 0
                    room[x][y].visited = true
                end
                x = x + 1
            end

            --  scan up
            x = target.x
            y = target.y - 1
            while (y >= 0) do
                if (room[x][y].solid) then
                    break
                else
                    table.insert(queue, {x = x, y = y})
                    room[x][y].rangedDistance = 0
                    room[x][y].visited = true
                end
                y = y - 1
            end

            --  scan down
            x = target.x
            y = target.y + 1
            while (y <= 10) do
                if (room[x][y].solid) then
                    break
                else
                    table.insert(queue, {x = x, y = y})
                    room[x][y].rangedDistance = 0
                    room[x][y].visited = true
                end
                y = y + 1
            end
        end
        
        while (#queue > 0) do
            local current = table.remove(queue, 1)

            for i = 1, 4 do
                local newX = current.x + offsets[i].x
                local newY = current.y + offsets[i].y

                if (newX >= 0 and newX <= 10 and newY >= 0 and newY <= 10) then
                    if not room[newX][newY].visited and not room[newX][newY].solid then
                        table.insert(queue, {x = newX, y = newY})
                        if (step == 1) then
                            room[newX][newY].distance = room[current.x][current.y].distance + 1
                        else
                            room[newX][newY].rangedDistance = room[current.x][current.y].rangedDistance + 1
                        end
                        room[newX][newY].visited = true
                    end
                end
            end
        end
    end
end

