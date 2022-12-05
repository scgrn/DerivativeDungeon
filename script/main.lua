KEY = {
    UP = 259,
    DOWN = 258,
    LEFT = 260,
    RIGHT = 261,

    H = 104, --72,
    ENTER = 10,

    ESC = 27,
    F1 = 265,
}

function init()
    loadScript("../script/messageBox.lua")
    loadScript("../script/generator.lua")
    loadScript("../script/player.lua")

    math.randomseed(os.time())
    masterSeed = math.random(32767)
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
                cprint(x * 4 + 35, y * 2 + 2, ".")
            end
        end
    end
end

function drawScreen()
    -- cprint(8, 8, "Generate")
    -- cprint(10, 8, "Enter seed: ")

    rectangle(0, 0, 79, 24)

    rectangle(2, 1, 31, 3)
    cprint(4, 2, "*** Derivative Dungeon ***")

    rectangle(2, 4, 31, 6)
    cprint(4, 5, "EXP / Next:")
    cprint(19, 5, player.exp .. " / " .. player.next)

    rectangle(2, 7, 31, 13)
    cprint(4, 8, "Life:")
    cprint(4, 10, "Magic:")
    cprint(4, 12, "Attack:")

    cprint(14, 8, "Lvl " .. player.lifeLevel)
    cprint(14, 10, "Lvl " .. player.magicLevel)
    cprint(14, 12, "Lvl " .. player.attackLevel)

    cprint(23, 8, player.hp .. " / " .. player.maxHp)
    cprint(23, 10, player.mp .. " / " .. player.maxMp)

    rectangle(2, 14, 31, 20)
    cprint(4, 15, "Player HP -3")
    cprint(4, 16, "Enemy HP -3")
    cprint(4, 17, "Player defeated Enemy")
    cprint(4, 18, "Player EXP +10")
    cprint(4, 19, "")

    rectangle(2, 21, 31, 23)
    cprint(4, 22, "Press [H] for help")

    drawRoom()
    rectangle(33, 1, 77, 23)

    cprint(35 + player.pos.x * 4, player.pos.y * 2 + 2, "@")
end

function update()
    local ch = 0
    animating = false

    drawScreen()
    messageBox.update()
    messageBox.render()

    if (animating) then
        delay(250);
    else
        ch = getch()
        if (messageBox.state == messageBox.States.OPEN) then
            ch = 0
            messageBox.close()
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
            "Use the arrow keys to move. To attack a",
            "monster, just like, bump into it. Et cetera",
            "",
            "Press any key"
        })
        -- messageBox.open({"Found spellbook. Learn *LIFE* spell."})
    end

    if (ch == KEY.ESC) then
        quit()
    end
end
