automap = {}

local viewingFloor = 1

local function generate()
    ret = {}
    local grid = dungeon[viewingFloor]
    
    table.insert(ret, "Floor " .. viewingFloor .. "                              ")
    table.insert(ret, "")

    for y = 1, DUNGEON_HEIGHT do
        local s = "    "
        for x = 1, DUNGEON_WIDTH - 1 do
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
    if (viewingFloor == 1) then
        table.insert(ret, "|")
    else
        table.insert(ret, "")
    end

    return ret
end

function automap.open()
    showingMap = true
    viewingFloor = currentFloor
    messageBox.open(generate())
end

function automap.render()
    local grid = dungeon[viewingFloor]
    
    -- draw map
    if (showingMap and messageBox.state == messageBox.States.OPEN) then
        for x = 1, DUNGEON_WIDTH do
            for y = 1, DUNGEON_HEIGHT do
                if (grid[x][y].visited) then
                  rectangle(x * 6 + 20, y * 3 + 3, x * 6 + 22, y * 3 + 4)
                end
            end
        end

        --  draw stairs on map if player has found them
        if (grid.down ~= nil) then
            if (grid[grid.down.x][grid.down.y].visited or inventory.opalEye) then
                printString(grid.down.x * 6 + 21, grid.down.y * 3 + 3, "D")
            end
        end
        if (grid.up ~= nil) then
            if (grid[grid.up.x][grid.up.y].visited or inventory.opalEye) then
                printString(grid.up.x * 6 + 21, grid.up.y * 3 + 3, "U")
            end
        end

        --  you are here
        if (viewingFloor == currentFloor) then
            printString(player.roomX * 6 + 21, player.roomY * 3 + 3, "@")
        end

        if (viewingFloor > 1) then
            printString(24, 3, "▲")
        end

        if (viewingFloor < deepestFloor) then
            printString(24, 5, "▼")
        end
    end
end

function automap.checkKeypress(ch)
    if (tableContains(KEY.UP, ch)) then
        if (viewingFloor > 1) then
            viewingFloor = viewingFloor - 1
            messageBox.setMessage(generate())
        end
        return
    end

    if (tableContains(KEY.DOWN, ch)) then
        if (viewingFloor < deepestFloor) then
            viewingFloor = viewingFloor + 1
            messageBox.setMessage(generate())
        end
        return
    end

    messageBox.close()
    showingMap = false
end

