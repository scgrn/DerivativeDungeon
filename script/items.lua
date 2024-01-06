items = {}

function addItem(x, y, representation, effect)
    table.insert(items, {
        x = x,
        y = y,
        representation = representation,
        effect = effect
    })
end

function checkItems(x, y)
    for key, value in pairs(items) do
        if (value.x == x and value.y == y) then
            value.effect()
            table.remove(items, key)
        end
    end
end

function drawItems()
    for key, value in pairs(items) do
        printString(value.x * 4 + 35, value.y * 2 + 2, value.representation)
    end
end

