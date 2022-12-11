player = {
    pos = {
        x = 5,
        y = 5
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
    prevPos = {
        x = player.pos.x,
        y = player.pos.y
    }
    if (ch == KEY.UP) then
        player.pos.y = player.pos.y - 1
        if (player.pos.y < 0) then
            player.roomY = player.roomY - 1
            generateRoom(player.roomX, player.roomY)
            player.pos.y = 10
        end
    end
    if (ch == KEY.DOWN) then
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
    if (ch == KEY.LEFT) then
        player.pos.x = player.pos.x - 1
        if (player.pos.x < 0) then
            player.roomX = player.roomX - 1
            generateRoom(player.roomX, player.roomY)
            player.pos.x = 10
        end
    end
    if (ch == KEY.RIGHT) then
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
end
