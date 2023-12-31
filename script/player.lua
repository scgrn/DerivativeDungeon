player = {
    pos = {
        x = 5,
        y = 8
    },

    lifeLevel = 1,
    magicLevel = 1,
    attackLevel = 1,

    hp = 64,
    maxHp = 64,

    mp = 64,
    maxMp = 64,

    exp = 0,
    nextLife = {50, 150, 400, 800, 1500, 2500, 4000},
    nextMagic = {100, 300, 700, 1200, 2200, 3500, 6000},
    nextAttack = {200, 500, 1000, 2000, 3000, 5000, 8000},

    damageLevel = {8, 12, 16, 24, 32, 48, 64, 96},

    next = 50,
    
    roomX = 3,
    roomY = 5
}

function movePlayer(ch)
    local prevPos = {
        x = player.pos.x,
        y = player.pos.y
    }
    if (tableContains(KEY.UP, ch)) then
        player.pos.y = player.pos.y - 1
        if (player.pos.y < 0) then
            if (player.roomY > 1) then
                player.roomY = player.roomY - 1
                generateRoom(player.roomX, player.roomY)
                player.pos.y = 10
            else
                player.pos.y = 0
            end
        end
    end
    if (tableContains(KEY.DOWN, ch)) then
        player.pos.y = player.pos.y + 1
        if (player.pos.y > 10) then
            if (player.roomY < DUNGEON_HEIGHT) then
                player.roomY = player.roomY + 1
                generateRoom(player.roomX, player.roomY)
                player.pos.y = 0
            else
                player.pos.y = 10
            end
        end
    end
    if (tableContains(KEY.LEFT, ch)) then
        player.pos.x = player.pos.x - 1
        if (player.pos.x < 0) then
            player.roomX = player.roomX - 1
            generateRoom(player.roomX, player.roomY)
            player.pos.x = 10
        end
    end
    if (tableContains(KEY.RIGHT, ch)) then
        player.pos.x = player.pos.x + 1
        if (player.pos.x > 10) then
            player.roomX = player.roomX + 1
            generateRoom(player.roomX, player.roomY)
            player.pos.x = 0
        end
    end

    if (room[player.pos.x][player.pos.y].solid) then
        player.pos = prevPos
    end

    --  check gates
    local sx = player.pos.x * 4 + 35
    local sy = player.pos.y * 2 + 2
    if (sx >= room.gateX1 and sx <= room.gateX2 and sy >= room.gateY1 and sy <= room.gateY2) then
        player.pos = prevPos
        logEvent("Locked.")
    end
    
    --  check monsters
    for key, value in pairs(monsters) do
        if (value.pos.x == player.pos.x and value.pos.y == player.pos.y) then
            player.pos = prevPos
            value.hp = value.hp - 1
            if (value.hp == 0) then
                table.remove(monsters, key)
                logEvent("You defeated the bat!")
            else
                logEvent("You attacked the bat")
            end
        end
    end

    findPath(player.pos)
end
