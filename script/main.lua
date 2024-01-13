KEY = {
    --  cursors / vim keybindings
    UP = {259, 107},
    DOWN = {258, 106},
    LEFT = {260, 104},
    RIGHT = {261, 108},

    HELP = 63,
    M = 109,
    I = 105,
    S = 115,
    C = 99,
    
    R = 114,
    E = 101,
    V = 118,
    A = 97,
    Q = {27, 113},
    
    ENTER = 10,
}

function init()
    loadScript("../script/buildstamp.lua")()
    loadScript("../script/utils.lua")()
    loadScript("../script/messageBox.lua")()
    loadScript("../script/tiles.lua")()
    loadScript("../script/items.lua")()
    loadScript("../script/generator.lua")()
    loadScript("../script/pathFinder.lua")()
    loadScript("../script/player.lua")()
    loadScript("../script/monsters.lua")()
    loadScript("../script/magic.lua")()
    loadScript("../script/inventory.lua")()
    loadScript("../script/eventLog.lua")()
    loadScript("../script/automap.lua")()

    randomSeed()
    newGame(random(256 ^ 4 - 1))
end

function newGame(seed)
    masterSeed = seed
    randomSeed(masterSeed)

    currentFloor = 1
    deepestFloor = 1

    resetPlayer()
    resetInventory()
    resetSpellbook()
    
    clearEventLog()
    generateDungeon()
    generateRoom(player.roomX, player.roomY)
    findPath(player.pos)
    
    spawnMonster(5, 5, MONSTER_BAT)
    --[[
    addItem(7, 5, "k", function()
        logEvent("You found a RUSTY KEY")
        inventory.rustyKey = inventory.rustyKey + 1
    end)
    ]]

    logEvent("Retrieve the Amulet!")
end

function drawRoom()
    for x = 0, 10 do
        for y = 0, 10 do
            printString(x * 4 + 33, y * 2 + 1, tiles[room[x][y].tile][1])
            printString(x * 4 + 33, y * 2 + 2, tiles[room[x][y].tile][2])
        end
    end

    --  draw gates
    if (room.gate.x1 ~= 0) then
        for x = room.gate.x1, room.gate.x2 do
            for y = room.gate.y1, room.gate.y2 do
                printString(x, y, "#")
            end
        end
    end

    --  draw pillars
    for _, pillar in pairs(room.pillars) do
        local doubleLines = (pillar.x1 ~= pillar.x2)
        rectangle(pillar.x1 * 4 + 33, pillar.y1 * 2 + 1, pillar.x2 * 4 + 36, pillar.y2 * 2 + 3, doubleLines, not doubleLines)
    end
        
    --  draw stairs
    if (grid.down ~= nil) then
        if (grid.down.x == player.roomX and grid.down.y == player.roomY) then
            printString(5 * 4 + 35, 5 * 2 + 2, "D")
        end
    end
    if (grid.up ~= nil) then
        if (grid.up.x == player.roomX and grid.up.y == player.roomY) then
            printString(5 * 4 + 35, 5 * 2 + 2, "U")
        end
    end
end

function drawDarkness()
    distances = {0, 28, 24, 18, 12, 8} -- indexed by floor

    if (inventory.lantern or currentFloor == 1) then
        return
    end

    local playerX = player.pos.x * 4 + 35
    local playerY = player.pos.y * 2 + 2
    
    local dist = 0
    if (currentFloor <= #distances) then
        dist = distances[currentFloor]
    else
        dist = distances[#distances]
    end

    local minY = playerY - dist / 2
    local maxY = playerY + dist / 2
    if (minY < 1) then
        minY = 1
    end
    if (maxY > 23) then
        maxY = 23
    end
    for y = 2, minY - 1 do
        printString(34, y, string.rep(" ", 44))
    end

    for y = minY, maxY do
        for x = 34, 76 do
            local d = ((playerX - x) * (playerX - x)) + ((playerY - y) * (playerY - y) * 4.5)
            if (d > dist * dist) then
                printString(x, y, " ")
            end
        end
    end

    for y = maxY + 1, 22 do
        printString(34, y, string.rep(" ", 44))
    end
end

function drawScreen()
    rectangle(0, 0, 79, 24)

    rectangle(2, 1, 31, 3)
    printString(4, 2, "*** Derivative Dungeon ***")

    rectangle(2, 4, 31, 6)
    printString(4, 5, "EXP / Next:")
    local str = player.exp .. " / " .. player.next
    printString(30 - #str, 5, str)

    rectangle(2, 7, 31, 13)
    printString(4, 8, "Life:")
    printString(4, 10, "Magic:")
    printString(4, 12, "Attack:")

    printString(14, 8, "Lvl " .. player.lifeLevel)
    printString(14, 10, "Lvl " .. player.magicLevel)
    printString(14, 12, "Lvl " .. player.attackLevel)

    str = player.hp .. " / " .. player.maxHp
    printString(30 - #str, 8, str)
    str = player.mp .. " / " .. player.maxMp
    printString(30 - #str, 10, str)

    rectangle(2, 14, 31, 20)
    drawEventLog()

    rectangle(2, 21, 31, 23)
    printString(4, 22, "Press [?] for help")

    drawRoom()

    drawItems()
    drawMonsters()
    drawDarkness()
    printString(player.pos.x * 4 + 35, player.pos.y * 2 + 2, "@")

    rectangle(33, 1, 77, 23)
end

function showHelp()
    messageBox.open({
        "Use the arrow keys to move. To attack",
        "a monster, just like, bump into it.",
        "",
        "Other commands:                            ",
        "",
        "   [M] - View map         [R] Restart      ",
        "   [I] - View inventory   [E] Enter seed   ",
        "   [S] - Open spellbook   [V] View seed    ",
        "   [C] - Cast spell       [A] About        ",
        "                          [Q] Quit         ",
        "Legend:                                    ",
        "",
        "   @ - You                 l - Life bonus  ",
        "   B - Giant Bat           m - Magic bonus ",
        "   Z - Zombie              e - EXP bonus   ",
        "   S - Skeleton Archer     k - Key         ",
        "   W - Wraith              s - Spellbook   ",
        "",
        "Press any key"
    })
end

function update()
    local ch = 0
    animating = false

    drawScreen()
    messageBox.update()
    messageBox.render()

    automap.render()
    
    if (animating) then
        delay(10);
    else
        ch = getch()
        -- logEvent("Scancode: " .. ch)

        if (showingMap) then
            automap.checkKeypress(ch)
        else
            if (messageBox.state == messageBox.States.OPEN) then
                messageBox.close()
                showingMap = false

                return
            else
                movePlayer(ch)
                updateMonsters()

                --  help message
                if (ch == KEY.HELP) then
                    showHelp()
                end

                -- show inventory
                if (ch == KEY.I) then
                    showInventory()
                end

                --  open spellbook
                if (ch == KEY.S) then
                    openSpellbook()
                end

                --  cast spell
                if (ch == KEY.C) then
                    castSpell()
                end

                --  draw map
                if (ch == KEY.M) then
                    automap.open()
                end

                --  hot reload
                if (ch == KEY.R) then
                    --newGame(random(256 ^ 4 - 1))
                    
                    loadScript("../script/main.lua")
                    init()
                end

                if (ch == KEY.A) then
                    messageBox.open({
                        "Derivative Dungeon",
                        "",
                        "(c) Copyright 2024 Andrew Krause",
                        "alienbug.games",
                        "",
                        "Source available at:",
                        "  https://github.com/scgrn/DerivativeDungeon  ",
                        "",
                        "Buildstamp: " .. buildstamp,
                        "",
                        "Press any key"
                    })
                end
                
                if (ch == KEY.V) then
                    local seed = intToHex(masterSeed)
                    seed = string.insert(seed, " ", 4)
                    messageBox.open({
                        "Current random seed:",
                        "",
                        seed,
                    })
                end

                if (ch == KEY.E) then
                    messageBox.open({
                        "Enter random seed:",
                        "(this will start a new game)",
                        "",
                        "---- ----",
                        "",
                        "Press Enter to accept or Esc to cancel"
                    })
                end

                if (tableContains(KEY.Q, ch)) then
                    quit()
                end
            end
        end
    end
end

