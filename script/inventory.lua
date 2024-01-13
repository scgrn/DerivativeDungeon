function resetInventory()
    inventory = {
        rustyKey = 0,
        ironKey =   false,
        silverKey = false,
        goldKey = false,
        
        lantern = false,
        opalEye = false,
        
        amulet = false,
        
        lanternTimer = 0,
    }
end

function showInventory()
    local display = {
        "",
        "      * Inventory *      ",
        "",
        "DULL BROADSWORD",
        "BATTERED SHIELD",
        "",
    }

    local anything = false

    if (inventory.rustyKey == 1) then
        table.insert(display, "RUSTY KEY")
        anything = true
    elseif (inventory.rustyKey > 0) then
        table.insert(display, "RUSTY KEY x" .. inventory.rustyKey)
        anything = true
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

    if (inventory.lantern) then
        table.insert(display, "LANTERN")
    end

    if (inventory.opalEye) then
        table.insert(display, "OPAL EYE")
    end

    if (inventory.amulet) then
        table.insert(display, "THE AMULET")
    end

    if (not anything) then
        for key, value in pairs(inventory) do
            if (type(value) == "boolean" and value) then
                anything = true
                break
            end
        end
    end

    if (not anything) then
        table.insert(display, "")
        table.insert(display, "YOUR LIFE")
    end
    table.insert(display, "")

    messageBox.open(display)
end
