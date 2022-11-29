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
    loadScript("../script/generator.lua")
    loadScript("../script/player.lua")

    generateDungeon()
    generateRoom(1, 1)
end

function drawRoom()
    for y = 0, 10 do
        for x = 0, 10 do
            if (room[y][x].solid) then
                rectangle(x * 4 + 34, y * 2 + 2, x * 4 + 37, y * 2 + 3)
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
    drawScreen()

    local ch = getch()
    movePlayer(ch)

    if (ch == KEY.F1) then
        loadScript("../script/main.lua")
        init()
        return
    end

    if (ch == KEY.H) then
    end

    if (ch == KEY.ESC) then
        quit()
    end
end
