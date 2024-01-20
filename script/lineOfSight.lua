local function check(x, y)
    if (x >= 0 and x <= 10 and y >= 0 and y <= 10) then
        return room[x][y].solid
    else
        return true
    end
end

function lineOfSight(x1, y1, x2, y2)
    local deltaX = math.abs(x2 - x1)
    local deltaY = math.abs(y2 - y1)

    local x = x1
    local y = y1

    local xInc1, xInc2, yInc1, yInc2

    if (x2 >= x1) then
        xInc1 = 1
        xInc2 = 1
    else
        xInc1 = -1
        xInc2 = -1
    end

    if (y2 >= y1) then
        yInc1 = 1
        yInc2 = 1
    else
        yInc1 = -1
        yInc2 = -1
    end

    if (deltaX >= deltaY) then
        xInc1 = 0
        yInc2 = 0
        den = deltaX
        num = deltaX / 2
        numAdd = deltaY
        numTiles = deltaX
    else
        xInc2 = 0
        yInc1 = 0
        den = deltaY
        num = deltaY / 2
        numAdd = deltaX
        numTiles = deltaY
    end

    local oneMoreRound = false
    local roundNum = 0

    while (true) do
        roundNum = roundNum + 1

        if (oneMoreRound and roundNum > 2) then
            return false
        end
        if (roundNum ~= 1 and check(x, y)) then
            oneMoreRound = true
        end
        if (x == x2 and y == y2) then
            return true
        end

        num = num + numAdd
        if (num >= den) then
            num = num - den
            x = x + xInc1
            y = y + yInc1
        end
        x = x + xInc2
        y = y + yInc2
    end
end

