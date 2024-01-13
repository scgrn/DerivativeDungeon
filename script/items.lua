local items = {}

function clearItems()
    for _, item in pairs(items) do
        item.used = false
    end
    items = {}
end

function addItems(itemList)
    items = itemList
end

function addItem(x, y, representation, effect, permanent)
    effect = effect or function() end
    permanent = permanent or false
    table.insert(items, {
        x = x,
        y = y,
        representation = representation,
        effect = effect,
        permanent = permanent,
        used = false
    })
end

function checkItems(x, y)
    for _, item in pairs(items) do
        if (item.x == x and item.y == y) then
            if (not item.permanent) then
                item.effect()
                table.remove(items, key)
            else
                if (not item.used) then
                    item.effect()
                    item.used = true
                end
            end
        end
    end
end

function drawItems()
    for _, item in pairs(items) do
        printString(item.x * 4 + 35, item.y * 2 + 2, item.representation)
    end
end

function placeItems()
    placeSpellbooks()
    
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
    local lanternFloor = random(3, 4)
    room = table.remove(dungeon[lanternFloor].deadEnds)

    table.insert(dungeon[lanternFloor][room.x][room.y].items, {
        x = 5,
        y = 5,
        representation = 'Å',
        effect = function()
            messageBox.open({"You found a LANTERN to light your way."})
            inventory.lantern = true
        end,
    })

    --  place opal eye
    local opalEyeFloor = lanternFloor
    while (opalEyeFloor == lanternFloor) do
        opalEyeFloor = random(3, 5)
    end
    --  find random room
    --  TODO: factor this out for rusty keys
    repeat
        local okay = true

        room.x = random(1, DUNGEON_WIDTH)
        room.y = random(1, DUNGEON_HEIGHT)
        
        if (dungeon[opalEyeFloor][room.x][room.y].blocked or dungeon[opalEyeFloor][room.x][room.y].exits < 2) then
            okay = false
        end
    until okay
    table.insert(dungeon[opalEyeFloor][room.x][room.y].items, {
        -- setting x and y to 0 will have the room generator place it randomly
        x = 0,
        y = 0,
        representation = '°',
        effect = function()
            messageBox.open({"You found the OPAL EYE"})
            inventory.opalEye = true
        end,
    })

    --  place magic pool
    local poolFloor = random(2, 5)
    room = table.remove(dungeon[poolFloor].deadEnds)
    dungeon.pool = {
        floor = poolFloor,
        x = room.x,
        y = room.y,
        found = false,
    }
    -- logEvent("Pool: ".. poolFloor .. " (" .. room.x .. ", " .. room.y .. ")")
    table.insert(dungeon[poolFloor][room.x][room.y].items, {
        x = 5,
        y = 5,
        representation = 'O',
        effect = function()
            logEvent("You found a pool")
            messageBox.open({"You wade into the SHIMMERING POOL","","Magic fully restored!"})
            player.mp = player.maxMp
            dungeon.pool.found = true
        end,
        permanent = true,
    })

    --  place life statue
    local statueFloor = poolFloor
    while (statueFloor == poolFloor) do
        statueFloor = random(2, 5)
    end
    room = table.remove(dungeon[statueFloor].deadEnds)
    dungeon.statue = {
        floor = statueFloor,
        x = room.x,
        y = room.y,
        found = false,
    }
    -- logEvent("Statue: " .. statueFloor .. " (" .. room.x .. ", " .. room.y .. ")")
    table.insert(dungeon[statueFloor][room.x][room.y].items, {
        x = 5,
        y = 5,
        representation = 'Ω',
        effect = function()
            logEvent("You found a statue")
            messageBox.open({"You gaze at the GHOSTLY EFFIGY","","Life fully restored!"})
            player.hp = player.maxHp
            dungeon.statue.found = true
        end,
        permanent = true,
    })
    
    --  place keys
    local floor
    if (#dungeon[1].deadEnds == 0) then
        floor = 2
    elseif (#dungeon[2].deadEnds == 0) then
        floor = 1
    else
        floor = random(1, 2)
    end
    room = table.remove(dungeon[floor].deadEnds)
    table.insert(dungeon[floor][room.x][room.y].items, {
        x = 5,
        y = 5,
        representation = 'k',
        effect = function()
            logEvent("Found key")
            messageBox.open({"You found the IRON KEY"})
            inventory.ironKey = true
        end
    })
    logEvent("Key: F" .. floor .. ", (" .. room.x .. "," .. room.y .. ")")

    if (#dungeon[3].deadEnds == 0) then
        floor = 4
    elseif (#dungeon[4].deadEnds == 0) then
        floor = 3
    else
        floor = random(3, 4)
    end
    room = table.remove(dungeon[floor].deadEnds)
    table.insert(dungeon[floor][room.x][room.y].items, {
        x = 5,
        y = 5,
        representation = 'k',
        effect = function()
            logEvent("Found key")
            messageBox.open({"You found the SILVER KEY"})
            inventory.silverKey = true
        end
    })
    logEvent("Key: F" .. floor .. ", (" .. room.x .. "," .. room.y .. ")")

    if (#dungeon[5].deadEnds == 0) then
        floor = 6
    elseif (#dungeon[6].deadEnds == 0) then
        floor = 5
    else
        floor = random(5, 6)
    end
    room = table.remove(dungeon[floor].deadEnds)
    table.insert(dungeon[floor][room.x][room.y].items, {
        x = 5,
        y = 5,
        representation = 'k',
        effect = function()
            logEvent("Found key")
            messageBox.open({"You found the GOLD KEY"})
            inventory.goldKey = true
        end
    })
    logEvent("Key: F" .. floor .. ", (" .. room.x .. "," .. room.y .. ")")

    --  collect the remaining dead ends and assign life and magic bonuses
    local deadEnds = {}
    for floor = 1, FLOORS do
        for _, deadEnd in pairs(dungeon[floor].deadEnds) do
            table.insert(deadEnds, {
                floor = floor,
                x = deadEnd.x,
                y = deadEnd.y,
            })
        end
    end
    scramble(deadEnds)
    
    for i = 1, 4 do
        local room = table.remove(deadEnds)
        table.insert(dungeon[room.floor][room.x][room.y].items, {
            x = 5,
            y = 5,
            representation = 'l',
            effect = function()
                logEvent("Max HP +16")
                messageBox.open({"You found a life bonus!"})
                player.maxHp = player.maxHp + 16
                player.hp = player.hp + 16
            end
        })
        
        local room = table.remove(deadEnds)
        table.insert(dungeon[room.floor][room.x][room.y].items, {
            x = 5,
            y = 5,
            representation = 'm',
            effect = function()
                logEvent("Max MP +16")
                messageBox.open({"You found a magic bonus!"})
                player.maxMp = player.maxMp + 16
                player.mp = player.mp + 16
            end
        })
    end

    logEvent("Rem. DeadEnds: " .. #deadEnds)
end

