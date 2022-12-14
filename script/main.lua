KEY = {
    UP = 259,
    DOWN = 258,
    LEFT = 260,
    RIGHT = 261,

    H = 104, --72,
    I = 105,
    M = 109,
    S = 115,
    C = 99,
    ENTER = 10,

    ESC = 27,
    F1 = 265,
}

function init()
    loadScript("../script/messageBox.lua")()
    loadScript("../script/generator.lua")()
    loadScript("../script/player.lua")()
    loadScript("../script/magic.lua")()
    loadScript("../script/inventory.lua")()
    loadScript("../script/eventLog.lua")()

    math.randomseed(os.time())
    masterSeed = math.random(256 ^ 4)
    rseed = masterSeed
    math.randomseed(rseed)

    generateDungeon()
    generateRoom(player.roomX, player.roomY)
    clearEventLog()
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

    --  draw gates
    if (grid[player.roomX][player.roomY].locked.n) then
        if (player.roomX == 3 and player.roomY == 1) then
            for x = 1, 10 do
                printString(x + 49, 2, "#")
            end
        else
            for x = 1, 10 do
                printString(x + 49, 6, "#")
            end
        end
    end

    if (grid[player.roomX][player.roomY].locked.s) then
        if (player.roomX == 3 and player.roomY == 5) then
            for x = 1, 10 do
                printString(x + 49, 22, "#")
            end
        else
            for x = 1, 10 do
                printString(x + 49, 18, "#")
            end
        end
    end

    if (grid[player.roomX][player.roomY].locked.w) then
        for y = 1, 5 do
            printString(43, y + 9, "#")
        end
    end

    if (grid[player.roomX][player.roomY].locked.e) then
        for y = 1, 5 do
            printString(67, y + 9, "#")
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
    printString(4, 22, "Press [H] for help")

    drawRoom()
    rectangle(33, 1, 77, 23)

    printString(35 + player.pos.x * 4, player.pos.y * 2 + 2, "@")
end

function showHelp()
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
      "   [C] - Cast spell                ",
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
        if (messageBox.state == messageBox.States.OPEN) then
            ch = 0
            messageBox.close()
            showingMap = false
        else
            movePlayer(ch)
        end
    end

    --  hot reload
    if (ch == KEY.F1) then
        loadScript("../script/main.lua")
        init()
        return
    end

    --  help message
    if (ch == KEY.H) then
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
        -- castSpell()
        loadScript("../script/main.lua")
        init()
    end

    --  draw map
    if (ch == KEY.M) then
        showingMap = true
        messageBox.open(generateAutomap())
    end

    if (ch == KEY.ESC) then
        quit()
    end
end
