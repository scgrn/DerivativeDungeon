function resetPlayer()
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
        nextLife = {50, 150, 400, 800, 1500, 2500, 4000, 9000},
        nextMagic = {100, 300, 700, 1200, 2200, 3500, 6000, 9000},
        nextAttack = {200, 500, 1000, 2000, 3000, 5000, 8000, 9000},

        damage = {8, 12, 16, 24, 32, 48, 64, 96},

        next = 50,
        
        roomX = 3,
        roomY = 5
    }
end

function ascendStairs()
    if (currentFloor > 1) then
        currentFloor = currentFloor - 1
        if (currentFloor > deepestFloor) then
            deepestFloor = currentFloor
        end
        grid = dungeon[currentFloor]

        player.roomX = grid.down.x
        player.roomY = grid.down.y

        generateRoom(player.roomX, player.roomY)
        logEvent("You ascend to floor " .. currentFloor)
    end
end

--  Albany ham scam

function descendStairs()
    if (currentFloor < FLOORS) then
        currentFloor = currentFloor + 1
        grid = dungeon[currentFloor]

        if (currentFloor > deepestFloor) then
            deepestFloor = currentFloor
        end

        player.roomX = grid.up.x
        player.roomY = grid.up.y

        generateRoom(player.roomX, player.roomY)
        logEvent("You descend to floor " .. currentFloor)
    end
end

function addEXP(amount)
    logEvent(" +" .. amount .. " EXP")
    
    player.exp = player.exp + amount
    if (player.exp >= player.next) then
        levelUp.open()
    end
end

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
    elseif (tableContains(KEY.DOWN, ch)) then
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
    elseif (tableContains(KEY.LEFT, ch)) then
        player.pos.x = player.pos.x - 1
        if (player.pos.x < 0) then
            player.roomX = player.roomX - 1
            generateRoom(player.roomX, player.roomY)
            player.pos.x = 10
        end
    elseif (tableContains(KEY.RIGHT, ch)) then
        player.pos.x = player.pos.x + 1
        if (player.pos.x > 10) then
            player.roomX = player.roomX + 1
            generateRoom(player.roomX, player.roomY)
            player.pos.x = 0
        end
    else
        --  invalid key
        return
    end

    if (room[player.pos.x][player.pos.y].solid) then
        player.pos = prevPos
    end

    checkItems(player.pos.x, player.pos.y)

    --  check stairs
    --  TODO: make into items
    if (grid.down ~= nil) then
        if (grid.down.x == player.roomX and grid.down.y == player.roomY) then
            if (player.pos.x == 5 and player.pos.y == 5) then
                descendStairs()
                return
            end
        end
    end
    if (grid.up ~= nil) then
        if (grid.up.x == player.roomX and grid.up.y == player.roomY) then
            if (player.pos.x == 5 and player.pos.y == 5) then
                ascendStairs()
                return
            end
        end
    end


    --  check gates
    local sx = player.pos.x * 4 + 35
    local sy = player.pos.y * 2 + 2
    if (sx >= room.gate.x1 and sx <= room.gate.x2 and sy >= room.gate.y1 and sy <= room.gate.y2) then
        player.pos = prevPos
        if (not room.gate.messageShown) then
            logEvent("You cannot leave without")
            logEvent(" the amulet!")
            room.gate.messageShown = true
        end
    end
    
    --  check monsters
    for key, value in pairs(monsters) do
        if (value.pos.x == player.pos.x and value.pos.y == player.pos.y) then
            player.pos = prevPos
            value.hp = value.hp - player.damage[player.attackLevel]
            if (value.hp <= 0) then
                table.remove(monsters, key)
                logEvent("You defeated the bat!")
                addEXP(value.exp)
            else
                logEvent("You attacked the bat")
            end
        end
    end

    findPath(player.pos)
end
