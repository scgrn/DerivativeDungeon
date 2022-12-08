inventory = {
    rustyKey = 0,
    ironKey = true,
    silverKey = true,
    goldKey = true,
    amulet = false,
}

function showInventory()
    local display = {
        "",
        "   * Inventory *   ",
        "",
        "DULL BROADSWORD    ",
        "BATTERED SHIELD    ",
        "",
    }
    
    if (inventory.rustyKey > 0) then
        table.insert(display, "RUSTY KEY x" .. inventory.rustyKey .. "                 ")
    end
    
    if (inventory.ironKey) then
        table.insert(display, "")
    end
    
    table.insert(display, "")
    table.insert(display, "YOUR LIFE")
    table.insert(display, "")

    messageBox.open(display)
end
