local items = {}

function clearItems()
    items = {}
end

function addItems(itemList)
    items = itemList
end

function addItem(x, y, representation, effect)
    table.insert(items, {
        x = x,
        y = y,
        representation = representation,
        effect = effect
    })
end

function checkItems(x, y)
    for _, item in pairs(items) do
        if (item.x == x and item.y == y) then
            item.effect()
            table.remove(items, key)
        end
    end
end

function drawItems()
    for _, item in pairs(items) do
        printString(item.x * 4 + 35, item.y * 2 + 2, item.representation)
    end
end

function placeItems()
    --  place amulet
    local room = table.remove(dungeon[FLOORS].deadEnds)

    table.insert(dungeon[FLOORS][room.x][room.y].items, {
        x = 5,
        y = 5,
        representation = 'a',
        effect = function()
            inventory.amulet = true
            messageBox.open({"You found the AMULET!", "", "You feel protected"})
            player.hp = player.maxHp
            player.mp = player.maxMp
            -- TODO: spawn new monsters
        end,
    })
    
    --  place lantern
    local lanternFloor = math.random(3, 4)
    room = table.remove(dungeon[lanternFloor].deadEnds)

    table.insert(dungeon[lanternFloor][room.x][room.y].items, {
        x = 5,
        y = 5,
        representation = 'l',
        effect = function()
            messageBox.open({"You found a LANTERN to light your way."})
            inventory.lantern = true
        end,
    })
    
    --  place opal eye
    local opalEyeFloor = lanternFloor
    while (opalEyeFloor == lanternFloor) do
        opalEyeFloor = math.random(3, 5)
    end
    -- find random room

    repeat
        local okay = true

        room.x = math.random(1, DUNGEON_WIDTH)
        room.y = math.random(1, DUNGEON_HEIGHT)
        
        if (dungeon[opalEyeFloor][room.x][room.y].blocked or dungeon[opalEyeFloor][room.x][room.y].exits < 2) then
            okay = false
        end
    until okay
    table.insert(dungeon[opalEyeFloor][room.x][room.y].items, {
        x = 0,
        y = 0,
        representation = 'o',
        effect = function()
            messageBox.open({"You found the OPAL EYE"})
            inventory.opalEye = true
        end,
    })
end

