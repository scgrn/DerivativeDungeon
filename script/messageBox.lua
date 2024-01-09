local blankString

messageBox = {
    States = {
        OPENING = 1,
        OPEN = 2,
        CLOSING = 3,
        CLOSED = 4
    },

    state = 4,
    message = {},
    maxSize = 0,
    currentSize = 0,
    x1 = 0,
    x2 = 0,
}

function messageBox.setMessage(message)
    -- TODO: enfore message is table

    messageBox.message = message

    messageBox.maxSize = #message + 3
    
    local longestMessage = 20
    for k, v in pairs(message) do
        longestMessage = math.max(#v + 6, longestMessage)
    end

    messageBox.x1 = 40 - (longestMessage / 2)
    messageBox.x2 = 80 - messageBox.x1

    blankString = " "
    local width = messageBox.x2 - messageBox.x1
    for i = 1, width - 1 do
        blankString = blankString .. " "
    end
end

function messageBox.open(message)
    --  wait until no keys are being held
    setBlockingInput(false);
    ch = 0
    while (ch ~= -1) do
        ch = getch()
        logEvent("Chr: " .. ch)
        delay(1)
    end
    --while (getch() ~= -1) do end
    setBlockingInput(true)

    messageBox.state = messageBox.States.OPENING
    messageBox.currentSize = 0
    messageBox.setMessage(message)
end

function messageBox.close()
    messageBox.state = messageBox.States.CLOSING
end

function messageBox.update()
    if (messageBox.state == messageBox.States.OPENING) then
        animating = true
        if (messageBox.currentSize == messageBox.maxSize) then
            messageBox.state = messageBox.States.OPEN
        else
            messageBox.currentSize = messageBox.currentSize + 1
        end
    end

    if (messageBox.state == messageBox.States.CLOSING) then
        animating = true
        if (messageBox.currentSize == 0) then
            messageBox.state = messageBox.States.CLOSED
        else
            messageBox.currentSize = messageBox.currentSize - 1
        end
    end
end

function messageBox.render()
    if (messageBox.state ~= messageBox.States.CLOSED) then
        local y1 = 12 - (messageBox.currentSize / 2)
        local y2 = 12 + (messageBox.currentSize / 2)

        for y = y1, y2 do
            printString(messageBox.x1, y, blankString)
        end
        rectangle(messageBox.x1, y1, messageBox.x2, y2)

        if (messageBox.state == messageBox.States.OPEN) then
            local y = y1 + 2
            for k, v in pairs(messageBox.message) do
                    printString(40 - (#v / 2), y, v)
                    y = y + 1
            end
        end
    end
end
