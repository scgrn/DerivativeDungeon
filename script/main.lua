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

function tableContains(table, value)
    for i = 1, #table do
        if (table[i] == value) then
            return true
        end
    end
    
    return false
end

function init()
    loadScript("../script/buildstamp.lua")()
    loadScript("../script/messageBox.lua")()
    loadScript("../script/generator.lua")()
    loadScript("../script/pathFinder.lua")()
    loadScript("../script/player.lua")()
    loadScript("../script/monsters.lua")()
    loadScript("../script/magic.lua")()
    loadScript("../script/inventory.lua")()
    loadScript("../script/eventLog.lua")()

    math.randomseed(os.time())
    masterSeed = math.random(256 ^ 4)
    rseed = masterSeed
    math.randomseed(rseed)

    clearEventLog()
    generateDungeon()
    generateRoom(player.roomX, player.roomY)
    findPath(player.pos)
    
    spawnMonster(5, 5, MONSTER_BAT)

    logEvent("Retrieve the Amulet!")
end

function drawRoom()
    for x = 0, 10 do
        for y = 0, 10 do
            if (room[x][y].solid) then
                rectangle(x * 4 + 33, y * 2 + 1, x * 4 + 36, y * 2 + 3)
            else
                printString(x * 4 + 35, y * 2 + 2, ".")
            end
            --printString(x * 4 + 35, y * 2 + 2, "" .. room[x][y].distance)
        end
    end

    --  draw gates
    if (room.gateX1 ~= 0) then
        for x = room.gateX1, room.gateX2 do
            for y = room.gateY1, room.gateY2 do
                printString(x, y, "#")
            end
        end
    end
end

function drawScreen()
    -- printString(8, 8, "Generate")
    -- printString(10, 8, "Enter seed: ")

    rectangle(0, 0, 79, 24)

    rectangle(2, 1, 31, 3)
    printString(4, 2, "*** Derivative Dungeon ***")

    rectangle(2, 4, 31, 6)
    printString(4, 5, "EXP / Next:")
    printString(19, 5, player.exp .. " / " .. player.next)

    rectangle(2, 7, 31, 13)
    printString(4, 8, "Life:")
    printString(4, 10, "Magic:")
    printString(4, 12, "Attack:")

    printString(14, 8, "Lvl " .. player.lifeLevel)
    printString(14, 10, "Lvl " .. player.magicLevel)
    printString(14, 12, "Lvl " .. player.attackLevel)

    printString(23, 8, player.hp .. " / " .. player.maxHp)
    printString(23, 10, player.mp .. " / " .. player.maxMp)

    rectangle(2, 14, 31, 20)
    drawEventLog()

    rectangle(2, 21, 31, 23)
    printString(4, 22, "Press [?] for help")

    drawRoom()
    rectangle(33, 1, 77, 23)

    drawMonsters()
    printString(35 + player.pos.x * 4, player.pos.y * 2 + 2, "@")
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
    -- messageBox.open({"Found spellbook. Learn *LIFE* spell."})
end

function generateAutomap()
    ret = {}
    table.insert(ret, "Floor 1                              ")
    if (grid[3][1].visited) then
        table.insert(ret, "|")
    else
        table.insert(ret, "")
    end

    for y = 1, 5 do
        local s = "    "
        for x = 1, 4 do
            if (grid[x][y].e and (grid[x][y].visited or grid[x + 1][y].visited)) then
                s = s .. "___   "
            else
                s = s .. "      "
            end
        end
        s = s .. " "
        table.insert(ret, s)
        table.insert(ret, "")

        if (y ~= 5) then
            s = ""
            for x = 1, 5 do
                if (grid[x][y].s and (grid[x][y].visited or grid[x][y + 1].visited)) then
                    s = s .. "  |   "
                else
                    s = s .. "      "
                end
            end
            table.insert(ret, s)
        end
    end
    table.insert(ret, "|")

    return ret
end

function update()
    local ch = 0
    animating = false

    drawScreen()
    messageBox.update()
    messageBox.render()

    -- draw map
    if (showingMap and messageBox.state == messageBox.States.OPEN) then
        for x = 1, DUNGEON_WIDTH do
            for y = 1, DUNGEON_HEIGHT do
                if (grid[x][y].visited) then
                  rectangle(x * 6 + 20, y * 3 + 3, x * 6 + 22, y * 3 + 4)
                end
            end
        end
        printString(player.roomX * 6 + 21, player.roomY * 3 + 3, "@")
    end

    if (animating) then
        delay(50);
    else
        ch = getch()
        -- logEvent("Scancode: " .. ch)
        if (messageBox.state == messageBox.States.OPEN) then
            ch = 0
            messageBox.close()
            showingMap = false
        else
            movePlayer(ch)
            updateMonsters()
        end
    end

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
        showingMap = true
        messageBox.open(generateAutomap())
    end

    --  user reload
    if (ch == KEY.R) then
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
            "Buildstamp: " .. buildstamp,
            "",
            "Source available at:",
            "  https://github.com/scgrn/DerivativeDungeon  ",
            "",
            "Press any key"
        })
    end
    
    if (ch == KEY.V) then
        messageBox.open({
            "Current random seed:",
            "",
            "80A9 45E2"
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

