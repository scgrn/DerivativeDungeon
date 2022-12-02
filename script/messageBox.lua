local OPENING = 1
local OPEN = 2
local CLOSING = 3
local CLOSED = 4

messageBox = {
  state = CLOSED,
  message = {},
  maxSize = 0,
  currentSize = 0,
  x1 = 0,
  x2 = 0,
}

function messageBox.open(message)
  -- TODO: enfore message is table

  messageBox.message = message
  messageBox.state = OPENING

  messageBox.maxSize = #message + 3
  messageBox.currentSize = 0

  local longestMessage = 20
  for k, v in pairs(message) do
    longestMessage = math.max(#v + 6, longestMessage)
  end

  messageBox.x1 = 40 - (longestMessage / 2)
  messageBox.x2 = 80 - messageBox.x1
end

function messageBox.close()
  messageBox.state = CLOSING
end

function messageBox.update()
  if (messageBox.state == OPENING) then
    if (messageBox.currentSize == messageBox.maxSize) then
      messageBox.state = OPEN
    else
      messageBox.currentSize = messageBox.currentSize + 1
    end
  end
end

function messageBox.render()
  local y1 = 12 - (messageBox.currentSize / 2)
  local y2 = 12 + (messageBox.currentSize / 2)

  local s = " "
  local width = messageBox.x2 - messageBox.x1
  for i = 1, width - 1 do
    s = s .. " "
  end

  for y = y1, y2 do
    cprint(messageBox.x1, y, s)
  end

  rectangle(messageBox.x1, y1, messageBox.x2, y2)

  if (messageBox.state == OPEN) then
    local y = y1 + 2
    for k, v in pairs(messageBox.message) do
        cprint(40 - (#v / 2), y, v)
        y = y + 1
    end
  end
end
