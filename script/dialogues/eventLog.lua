local index = 0

function clearEventLog()
    eventLog = {}
    index = 0

    for i = 1, 5 do
        eventLog[i] = ""
    end
end

function drawEventLog()
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

