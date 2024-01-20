levelUp = {
    choice = 0,
    showing = false,
}

local validChoice = {}

function levelUp.open()
    levelUp.showing = true

    local display = {
        "LEVEL UP",
        "",
        "      EXP    LVL    STAT                  ",
        "",
    }
    
    local str = "" .. player.nextAttack[player.attackLevel]
    str = string.rep(" ", 7 - #str) .. str
    str = str .. string.rep(" ", 11 - #str)
    str = str .. player.attackLevel .. "/8    "
    if (player.exp >= player.nextAttack[player.attackLevel]) then
        str = str .. "Increase attack level"
        validChoice[1] = true
    else
        str = str .. "Attack               "
        validChoice[1] = false
    end
    table.insert(display, str)

    local str = "" .. player.nextMagic[player.magicLevel]
    str = string.rep(" ", 7 - #str) .. str
    str = str .. string.rep(" ", 11 - #str)
    str = str .. player.magicLevel .. "/8    "
    if (player.exp >= player.nextMagic[player.magicLevel]) then
        str = str .. "Increase magic level "
        validChoice[2] = true
    else
        str = str .. "Magic                "
        validChoice[2] = false
    end
    table.insert(display, str)

    local str = "" .. player.nextLife[player.lifeLevel]
    str = string.rep(" ", 7 - #str) .. str
    str = str .. string.rep(" ", 11 - #str)
    str = str .. player.lifeLevel .. "/8    "
    if (player.exp >= player.nextLife[player.lifeLevel]) then
        str = str .. "Increase life level  "
        validChoice[3] = true
    else
        str = str .. "Life                 "
        validChoice[3] = false
    end
    table.insert(display, str)

    table.insert(display, "")
    table.insert(display, "    Cancel                            ")

    messageBox.open(display)

    validChoice[4] = true -- cancel
    
    for i = 1, 4 do
        if (validChoice[i]) then
            levelUp.choice = i
            break
        end
    end
end

function levelUp.render()
    if (levelUp.showing and messageBox.state == messageBox.States.OPEN) then
        local y = 16
        if (levelUp.choice ~= 4) then
            y = levelUp.choice + 11
        end
        printString(21, y, "►")
    end
end

local function calculateNext()
    local lowest = 10000
    
    if (player.nextLife[player.lifeLevel] > player.next and player.nextLife[player.lifeLevel] < lowest) then
        lowest = player.nextLife[player.lifeLevel]
    end
    if (player.nextMagic[player.magicLevel] > player.next and player.nextMagic[player.magicLevel] < lowest) then
        lowest = player.nextMagic[player.magicLevel]
    end
    if (player.nextAttack[player.attackLevel] > player.next and player.nextAttack[player.attackLevel] < lowest) then
        lowest = player.nextAttack[player.attackLevel]
    end
    player.next = lowest
end

function levelUp.checkInput(ch)
    if (tableContains(KEY.DOWN, ch)) then
        repeat
            levelUp.choice = levelUp.choice + 1
            if (levelUp.choice > 4) then
                levelUp.choice = 1
            end
        until validChoice[levelUp.choice]
    end

    if (tableContains(KEY.UP, ch)) then
        repeat
            levelUp.choice = levelUp.choice - 1
            if (levelUp.choice < 1) then
                levelUp.choice = 4
            end
        until validChoice[levelUp.choice]
    end

    if (ch == KEY.ENTER) then
        if (levelUp.choice == 1) then
            player.exp = player.exp - player.nextAttack[player.attackLevel]
            if (player.attackLevel < 8) then
                player.attackLevel = player.attackLevel + 1
            end
        end
        if (levelUp.choice == 2) then
            player.exp = player.exp - player.nextMagic[player.magicLevel]
            if (player.magicLevel < 8) then
                player.magicLevel = player.magicLevel + 1
                player.mp = player.maxMp
            end
        end
        if (levelUp.choice == 3) then
            player.exp = player.exp - player.nextLife[player.lifeLevel]
            if (player.lifeLevel < 8) then
                player.lifeLevel = player.lifeLevel + 1
                player.hp = player.maxHp
            end
        end

        messageBox.close()
        levelUp.showing = false

        if (levelUp.choice == 4) then
            calculateNext()
        else
            player.next = player.nextLife[player.lifeLevel]
            if (player.nextMagic[player.magicLevel] < player.next) then
                player.next = player.nextMagic[player.magicLevel]
            end
            if (player.nextAttack[player.attackLevel] < player.next) then
                player.next = player.nextAttack[player.attackLevel]
            end
        end

        if (levelUp.choice ~= 4) then
            if (player.exp >= player.next) then
                levelUp.open()
            end
        end
    end

    if (ch == 27) then
        messageBox.close()
        levelUp.showing = false

        calculateNext()
    end
end

