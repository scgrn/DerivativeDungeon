inventory = {
    rustyKey = 0,
    ironKey =   false,
    silverKey = false,
    goldKey = false,
    amulet = false,
}

function showInventory()
    local display = {
        "",
        "      * Inventory *      ",
        "",
        "DULL BROADSWORD",
        "BATTERED SHIELD",
        "",
    }

    if (inventory.rustyKey == 1) then
        table.insert(display, "RUSTY KEY")
    elseif (inventory.rustyKey > 0) then
        table.insert(display, "RUSTY KEY x" .. inventory.rustyKey)
    end

    if (inventory.ironKey) then
        table.insert(display, "IRON KEY")
    end

    if (inventory.silverKey) then
        table.insert(display, "SILVER KEY")
    end

    if (inventory.goldKey) then
        table.insert(display, "GOLD KEY")
    end

    if (inventory.amulet) then
        table.insert(display, "THE AMULET")
    end

    table.insert(display, "")
    table.insert(display, "YOUR LIFE")
    table.insert(display, "")

    messageBox.open(display)
end
