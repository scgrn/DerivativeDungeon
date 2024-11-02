seed = {
    showing = false
}

local newSeed = ""

function seed.show()
    local seed = intToHex(masterSeed)
    seed = string.insert(seed, " ", 4)
    messageBox.open({
        "Current random seed:",
        "",
        seed,
        "",
        "Press Enter to close",
    })
end

function seed.enter()
    seed.showing = true
    newSeed = ""
    
    messageBox.open({
        "Enter random seed:",
        "(this will start a new game)",
        "",
        "---- ----",
        "",
        "Press Enter to accept or Esc to cancel"
    })
end

function seed.print()
    if (seed.showing and messageBox.state == messageBox.States.OPEN) then
        printString(36, 12, string.sub(newSeed, 1, 4))
        printString(41, 12, string.sub(newSeed, 5, 8))
    end
end

function seed.checkInput(ch)
    if (ch == 27) then
        seed.showing = false
        messageBox.close()
    end
    
    if (#newSeed < 8) then
        if (ch >= 48 and ch <= 57) then
            newSeed = newSeed .. string.char(ch)
        end
        if (ch >= 65 and ch <= 70) then
            newSeed = newSeed .. string.char(ch)
        end
        if (ch >= 97 and ch <= 102) then
            newSeed = newSeed .. string.char(ch - 32)
        end
    end
    
    if ((ch == 8 or ch == 263) and #newSeed > 0) then
        newSeed = string.sub(newSeed, 1, #newSeed - 1)
    end
    
    if (ch == 10 and #newSeed == 8) then
        seed.showing = false
        messageBox.close()

        newGame(hexToInt(newSeed))
    end
end
