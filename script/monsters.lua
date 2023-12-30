MONSTER_BAT = 0
MONSTER_ZOMBIE = 1
MONSTER_ORC = 2
MONSTER_WRAITH = 3

monsters = {}

function clearMonsters()
    monsters = {}
end

function spawnMonster(x, y, species)
    table.insert(monsters, {
        pos = {x = x, y = y},
        species = species,
        aware = false
    })
end

function updateMonsters()
    local offsets = {
        {x = -1, y =  0},
        {x =  1, y =  0},
        {x =  0, y = -1},
        {x =  0, y =  1}
    }

    for key, value in pairs(monsters) do
        local bestDir = 0
        local lowestDistance = 1000
        
        for i = 1, 4 do
            local newX = value.pos.x + offsets[i].x
            local newY = value.pos.y + offsets[i].y

            if (newX >= 0 and newX <= 10 and newY >= 0 and newY <= 10) then
                if (not room[newX][newY].solid and room[newX][newY].distance < lowestDistance) then
                    bestDir = i
                    lowestDistance = room[newX][newY].distance
                end
            end
        end
        
        if (bestDir ~= 0) then
            value.pos.x = value.pos.x + offsets[bestDir].x
            value.pos.y = value.pos.y + offsets[bestDir].y
        end
    end
end

function drawMonsters()
    for key, value in pairs(monsters) do
        printString(value.pos.x * 4 + 35, value.pos.y * 2 + 2, "B")
    end
end

