function generateRoom()
    room = {}
    for y = 0, 10 do
        room[y] = {}
        for x = 0, 10 do
            room[y][x] = {
                solid = false
            }
        end
    end
    
    -- test stuffs
    for y = 7, 10 do
        for x = 0, 10 do
            room[y][x].solid = true
        end
    end

    for y = 0, 3 do
        for x = 0, 3 do
            room[y][x].solid = true
        end
        for x = 7, 10 do
            room[y][x].solid = true
        end
    end

    for y = 2, 8 do
        for x = 2, 8 do
            room[y][x].solid = false
        end
    end

    --[[
    room[3][3].solid = true
    room[7][3].solid = true
    room[3][7].solid = true
    room[7][7].solid = true
    ]]
end
