function findPath(target)
    local offsets = {
        {x = -1, y =  0},
        {x =  1, y =  0},
        {x =  0, y = -1},
        {x =  0, y =  1}
    }

    for x = 0, 10 do
        for y = 0, 10 do
            room[x][y].visited = false
            room[x][y].distance = 0
        end
    end

    local queue = {}
    room[target.x][target.y].distance = 0
    room[target.x][target.y].visited = true
    table.insert(queue, target)

    while (#queue > 0) do
        local current = table.remove(queue, 1)

        for i = 1, 4 do
            local newX = current.x + offsets[i].x
            local newY = current.y + offsets[i].y

            if (newX >= 0 and newX <= 10 and newY >= 0 and newY <= 10) then
                if not room[newX][newY].visited and not room[newX][newY].solid then
                    table.insert(queue, {x = newX, y = newY})
                    room[newX][newY].distance = room[current.x][current.y].distance + 1
                    room[newX][newY].visited = true
                end
            end
        end
    end
end

