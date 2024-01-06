spells = {
    { name = "SHIELD", spellbook = "Tome of Fortitude"},
    { name = "LIFE", spellbook = "Tome of Healing"},
    { name = "FIRE", spellbook = "Tome of Pyromancy"},
    { name = "TELEPORT", spellbook = "Tome of Conveyance"},
    { name = "DEATHSPELL", spellbook = "Tome of Decimation"},
}

for i = 1, #spells do
    spells[i].learned = false
end
selected = 0

function learnSpell(spell)
    logEvent("You found a spellbook")
    local message = {
        "You found the " .. spells[spell].spellbook,
        "",
        "You learn " .. spells[spell].name
    }
    if (spell ~= 5) then
        message[3] = message[3] .. " spell"
    end
    messageBox.open(message)
    spells[spell].learned = true
end

function castSpell()
    if (selected == 0) then
        messageBox.open({
            "No spell selected!",
        })
    end
end

function openSpellbook()
    local spellsLearned = 0
    for i = 1, #spells do
        if (spells[i].learned) then
            spellsLearned = spellsLearned + 1
        end
    end

    local display = {
        "",
        "         ~ Spellbook ~         ",
        "",
    }

    if (spellsLearned == 0) then
        table.insert(display, "   You haven't learned any spells yet   ")
    else
        for i = 1, #spells do
            table.insert(display, "")
            if (spells[i].learned) then
                table.insert(display, spells[i].name)
            else
                table.insert(display, "--------")
            end
        end
        table.insert(display, "")
    end

    table.insert(display, "")

    messageBox.open(display)
end
