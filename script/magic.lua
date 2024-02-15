spells = {
    {
        name = "SHIELD",
        spellbook = "Tome of Fortitude",
        cost = {32, 24, 24, 16, 16, 16, 16, 16},
        effect = function()
        end
    },{
        name = "LIFE",
        spellbook = "Tome of Healing",
        cost = {70, 70, 60, 60, 50, 50, 50, 50},
        effect = function()
            player.hp = player.hp + 32
            if (player.hp > player.maxHp) then
                player.hp = player.maxHp
            end
        end
    },{
        name = "STONE",
        spellbook = "Tome of Petrification",
        cost = {80, 80, 60, 30, 16, 16, 16, 16 },
        effect = function()
            stoneCountdownTimer = 16
        end
    },{
        name = "FIRE",
        spellbook = "Tome of Pyromancy",
        cost = {120, 80, 60, 30, 16, 16, 16, 16},
        effect = function()
            if (inventory.lantern) then
                inventory.lanternTimer = 16
                logEvent("The LANTERN has been relit")
            end
        end
    },{
        name = "DEATHSPELL",
        spellbook = "Tome of Decimation",
        cost = {120, 120, 120, 120, 120, 120, 100, 64},
        effect = function()
        end
    },
}

spellbook = {
    selected = 0,
    choice = 0,
    showing = false,
}

function resetSpellbook()
    for i = 1, #spells do
        spells[i].learned = false
    end

    spellbook.selected = 0
    spellbook.choice = 0
    spellbook.showing = false
    spellbook.playerHasCast = false
end

function learnSpell(spell)
    logEvent("You found a spellbook")
    local message = {
        "You found the " .. spells[spell].spellbook,
        "",
        "You learn " .. spells[spell].name
    }
    --  avoid saying "DEATHSPELL spell" because that just sounds ridiculous
    if (spell ~= 5) then
        message[3] = message[3] .. " spell"
    end
    messageBox.open(message)
    spells[spell].learned = true
end

function castSpell()
    if (spellbook.selected == 0) then
        messageBox.open({
            "No spell selected!",
        })
        return
    end

    if (player.mp >= spells[spellbook.selected].cost[player.magicLevel]) then
        if (spellbook.selected == 5) then
            logEvent("Cast " .. spells[spellbook.selected].name)
        else
            logEvent("Cast " .. spells[spellbook.selected].name .. " spell")
        end
        player.mp = player.mp - spells[spellbook.selected].cost[player.magicLevel]
        spells[spellbook.selected].effect()
        spellbook.playerHasCast = true
    else
        logEvent("Not enough magic")
    end
end

function spellbook.open()
    local spellsLearned = 0
    for i = 1, #spells do
        if (spells[i].learned) then
            spellsLearned = spellsLearned + 1
        end
    end

    local display = {
        "",
        "~ ~ ~  Spellbook  ~ ~ ~",
        "",
    }

    if (spellsLearned == 0) then
        table.insert(display, "   You haven't learned any spells yet   ")
    else
        spellbook.showing = true
        spellbook.choice = spellbook.selected
        if (spellbook.choice == 0) then
            for i = 1, #spells do
                if (spells[i].learned) then
                    spellbook.choice = i
                    break
                end
            end
        end
        
        for i = 1, #spells do
            table.insert(display, "")
            if (spells[i].learned) then
                local str = spells[i].name .. " "
                local mp = " " .. spells[i].cost[player.magicLevel]
                str = "  " .. str .. string.rep(".", 19 - (#str + #mp)) .. mp
                table.insert(display, str)
            else
                table.insert(display, "  " .. string.rep(".", 19))
            end
        end
        table.insert(display, "")
        table.insert(display, "")
        table.insert(display, "   Press Enter to select or Esc to cancel   ")
        --  TODO: only display this if player hasn't cast a spell yet
        if not spellbook.playerHasCast then
            table.insert(display, "")
            table.insert(display, "  After selecting spell, press [C] to cast  ")
        end
    end

    table.insert(display, "")

    messageBox.open(display)
end

function spellbook.render()
    if (spellbook.showing and messageBox.state == messageBox.States.OPEN) then
        local y = spellbook.choice * 2 + 5
        printString(28, y, "►")
    end
end

function spellbook.checkInput(ch)
    if (tableContains(KEY.DOWN, ch)) then
        local okay = false
        repeat
            spellbook.choice = spellbook.choice + 1
            if (spellbook.choice > #spells) then
                spellbook.choice = 1
            end
            if (spells[spellbook.choice].learned) then
                okay = true
            end
        until okay
    end

    if (tableContains(KEY.UP, ch)) then
        local okay = false
        repeat
            spellbook.choice = spellbook.choice - 1
            if (spellbook.choice < 1) then
                spellbook.choice = #spells
            end
            if (spells[spellbook.choice].learned) then
                okay = true
            end
        until okay
    end

    if (ch == KEY.ENTER) then
        spellbook.selected = spellbook.choice

        messageBox.close()
        spellbook.showing = false
    end

    if (ch == 27) then
        messageBox.close()
        spellbook.showing = false
    end
end

function placeSpellbooks()
    local skip = random(1, 5)
    
    local spellMap = {1, 2, 3, 4}
    scramble(spellMap)
    spellMap[5] = 5
    
    for spell = 1, 5 do
        local floor = spell
        if (floor >= skip) then
            floor = floor + 1
        end
        local room = table.remove(dungeon[floor].deadEnds)
        table.insert(dungeon[floor][room.x][room.y].items, {
            x = 5,
            y = 5,
            representation = "s",
            effect = function()
                learnSpell(spellMap[spell])
            end,
        })
    end
end

