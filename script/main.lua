KEY = {
    UP = 259,
    DOWN = 258,
    LEFT = 260,
    RIGHT = 261,

    H = 104, --72,
    M = 109,
    ENTER = 10,

    ESC = 27,
    F1 = 265,
}

function init()
    loadScript("../script/messageBox.lua")
    loadScript("../script/generator.lua")
    loadScript("../script/player.lua")

    math.randomseed(os.time())
    masterSeed = math.random(256 ^ 4)
    rseed = masterSeed
    math.randomseed(rseed)

    generateDungeon()
    generateRoom(player.roomX, player.roomY)
end

function drawRoom()
    for x = 0, 10 do
        for y = 0, 10 do
            if (room[x][y].solid) then
                rectangle(x * 4 + 33, y * 2 + 1, x * 4 + 36, y * 2 + 3)
            else
                printString(x * 4 + 35, y * 2 + 2, ".")
            end
        end
    end
    for x = 1, 10 do
--        printString(x + 49, 2, "#")
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
    printString(4, 15, "Player HP -3")
    printString(4, 16, "Enemy HP -3")
    printString(4, 17, "Player defeated Enemy")
    printString(4, 18, "Player EXP +10")
    printString(4, 19, "")

    rectangle(2, 21, 31, 23)
    printString(4, 22, "Press [H] for help")

    drawRoom()
    rectangle(33, 1, 77, 23)

    printString(35 + player.pos.x * 4, player.pos.y * 2 + 2, "@")
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
                rectangle(x * 6 + 20, y * 3 + 3, x * 6 + 22, y * 3 + 4)
            end
        end
        printString(player.roomX * 6 + 21, player.roomY * 3 + 3, "@")
    end

    if (animating) then
        delay(50);
    else
        ch = getch()
        if (messageBox.state == messageBox.States.OPEN) then
            ch = 0
            messageBox.close()
            showingMap = false
        else
            movePlayer(ch)
        end
    end

    if (ch == KEY.F1) then
        loadScript("../script/main.lua")
        init()
        return
    end

    if (ch == KEY.H) then
        messageBox.open({
            "Retrieve the amulet!",
            "",
            "Use the arrow keys to move. To attack",
            "a monster, just like, bump into it.",
            "",
            "Other commands:                    ",
            "",
            "   [M] - View map                  ",
            "   [I] - View inventory            ",
            "   [S] - Open spellbook            ",
            "   [C] - Cast magic                ",
            -- "   [esc] Exit program              ",
            "",
            "Legend:                            ",
            "",
            "   @ - You          l - Life bonus ",
            "   B - Bat          m - Magic bonus",
            "   O - Orc          e - EXP bonus  ",
            "   Z - Zombie       k - Key        ",
            "   W - Wraith       s - Spellbook  ",
            "",
            "Press any key"
        })
        -- messageBox.open({"Found spellbook. Learn *LIFE* spell."})
    end
    
    if (ch == KEY.M) then
        showingMap = true
        messageBox.open({
            "Floor 1",
            "",
            "    ___   ___   ___   ___    ",
            "",
            "  |     |     |     |     |  ",
            "    ___   ___   ___   ___    ",
            "",
            "  |     |     |     |     |  ",
            "    ___   ___   ___   ___    ",
            "",
            "  |     |     |     |     |  ",
            "    ___   ___   ___   ___    ",
            "",
            "  |     |     |     |     |  ",
            "    ___   ___   ___   ___    ",
            "",
        })
    end
    
    if (ch == KEY.ESC) then
        quit()
    end
end
