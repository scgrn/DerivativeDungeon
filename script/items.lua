local items = {}

function clearItems()
    items = {}
end

function addItems(itemList)
    items = itemList
end

function addItem(x, y, representation, effect)
    table.insert(items, {
        x = x,
        y = y,
        representation = representation,
        effect = effect
    })
end

function checkItems(x, y)
    for _, item in pairs(items) do
        if (item.x == x and item.y == y) then
            item.effect()
            table.remove(items, key)
        end
    end
end

function drawItems()
    for _, item in pairs(items) do
        printString(item.x * 4 + 35, item.y * 2 + 2, item.representation)
    end
end

