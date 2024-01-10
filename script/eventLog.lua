local index = 0

function clearEventLog()
    eventLog = {}
    index = 0

    for i = 1, 5 do
        eventLog[i] = ""
    end
end

function drawEventLog()
    --[[
    printString(4, 15, "Player HP -3")
    printString(4, 16, "Enemy HP -3")
    printString(4, 17, "Player defeated Enemy")
    printString(4, 18, "Player EXP +10")
    printString(4, 19, "")
    ]]
    for i = 1, 5 do
        printString(4, 14 + i, eventLog[i])
    end
end

function logEvent(event)
    if (index < 5) then
        index = index + 1
    else
        for i = 1, 4 do
            eventLog[i] = eventLog[i + 1]
        end
    end

    eventLog[index] = event
end

