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

    local spellbook = {
        "",
        "",
        "         ~ Spellbook ~         ",
        "",
    }
    
    if (spellsLearned == 0) then
        table.insert(spellbook, "   You haven't learned any spells yet   ")
    else
        for i = 1, #spells do
            table.insert(spellbook, "")
            if (spells[i].learned) then
                table.insert(spellbook, spells[i].name)
            else
                table.insert(spellbook, "- - - - -")
            end
        end
    end
    
    table.insert(spellbook, "")
    table.insert(spellbook, "")
    table.insert(spellbook, "")
    
    messageBox.open(spellbook)
end
