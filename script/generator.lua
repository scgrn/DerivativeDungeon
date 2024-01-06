FLOORS = 5

DUNGEON_WIDTH = 5
DUNGEON_HEIGHT = 5

function scramble(a)
    for i = 1, #a do
        index1 = math.random(#a)
        index2 = math.random(#a)
        local temp = a[index1]
        a[index1] = a[index2]
        a[index2] = temp
    end
end

function erodeCorners()
    -- erode NW corner
    if (math.random() < 0.5) then
        grid[1][1].blocked = true
        if (math.random() < 0.5) then
            grid[2][2].blocked = true
        end
    end
    if (math.random() < 0.5) then
        grid[2][1].blocked = true
    elseif (math.random() < 0.5) then
        grid[1][2].blocked = true
    end

    -- erode NE corner
    if (math.random() < 0.5) then
        grid[5][1].blocked = true
        if (math.random() < 0.5) then
            grid[4][2].blocked = true
        end
    end
    if (math.random() < 0.5) then
        grid[4][1].blocked = true
    elseif (math.random() < 0.5) then
        grid[5][2].blocked = true
    end

    -- erode SW corner
    if (math.random() < 0.5) then
        grid[1][5].blocked = true
        if (math.random() < 0.5) then
            grid[2][4].blocked = true
        end
    end
    if (math.random() < 0.5) then
        grid[2][5].blocked = true
    elseif (math.random() < 0.5) then
        grid[1][4].blocked = true
    end

    -- erode SE corner
    if (math.random() < 0.5) then
        grid[5][5].blocked = true
        if (math.random() < 0.5) then
            grid[4][4].blocked = true
        end
    end
    if (math.random() < 0.5) then
        grid[4][5].blocked = true
    elseif (math.random() < 0.5) then
        grid[5][4].blocked = true
    end
end

function visit(x, y)
    grid[x][y].visited = true
    grid[x][y].seed = math.random(256 ^ 4)

    repeat
        local potential={}
        if (x > 1 and not grid[x-1][y].visited) then
            if (not grid[x-1][y].blocked) then
                table.insert(potential, {x - 1, y})
            end
        end
        if (x < DUNGEON_WIDTH and not grid[x + 1][y].visited) then
            if (not grid[x+1][y].blocked) then
                table.insert(potential, {x + 1, y})
            end
        end
        if (y > 1 and not grid[x][y - 1].visited) then
            if (not grid[x][y-1].blocked) then
                table.insert(potential, {x, y - 1})
            end
        end
        if (y < DUNGEON_HEIGHT and not grid[x][y + 1].visited) then
            if (not grid[x][y+1].blocked) then
                table.insert(potential, {x, y + 1})
            end
        end

        if (#potential > 0) then
            local index = math.random(#potential)
            nx = potential[index][1]
            ny = potential[index][2]

            if (nx < x) then
                grid[x][y].w = true
                grid[nx][ny].e = true
            end
            if (nx > x) then
                grid[x][y].e = true
                grid[nx][ny].w = true
            end
            if (ny < y) then
                grid[x][y].n = true
                grid[nx][ny].s = true
            end
            if (ny > y) then
                grid[x][y].s = true
                grid[nx][ny].n = true
            end

            visit(nx, ny)
        end
    until (#potential == 0)
end

function generateFloor(floor)
    local deadEnds = {}

    repeat
        local okay = true

        grid = {}
        for x = 1, DUNGEON_WIDTH do
            grid[x] = {}
            for y = 1, DUNGEON_HEIGHT do
                grid[x][y] = {
                    n = false,
                    s = false,
                    e = false,
                    w = false,

                    locked = {
                        n = false,
                        s = false,
                        e = false,
                        w = false,
                    },

                    -- for both generation and map filling in automap
                    visited = false,

                    -- if true do not generate a room here
                    blocked = false,
                }
            end
        end

        erodeCorners()

        -- count rooms
        totalRooms = 0
        for x = 1, DUNGEON_WIDTH - 1 do
          for y = 1, DUNGEON_HEIGHT - 1 do
            if (not grid[x][y].blocked) then
              totalRooms = totalRooms + 1
            end
          end
        end

        -- build maze
        visit(math.floor(DUNGEON_WIDTH / 2), math.floor(DUNGEON_HEIGHT / 2))

        -- knock out random walls
        local potential = {}
        for x = 1, DUNGEON_WIDTH - 1 do
            for y = 1, DUNGEON_HEIGHT - 1 do
                if (not grid[x][y].blocked) then
                  if (not grid[x][y].s and not grid[x][y + 1].blocked) then
                      table.insert(potential, {x, y, 0})
                  end

                  if (not grid[x][y].e and not grid[x + 1][y].blocked) then
                      table.insert(potential,{x, y, 1})
                  end
                end
            end
        end

        for i = 1, math.floor(totalRooms / 5) do
            if (#potential >= 1) then
              local index = math.random(#potential)
              r = potential[index]
              if (r[3] == 0) then
                  grid[r[1] ][r[2] ].s = true
                  grid[r[1] ][r[2] + 1].n = true
              else
                  grid[r[1] ][r[2] ].e = true
                  grid[r[1] + 1][r[2] ].w = true
              end
              table.remove(potential, index)
            end
        end

        -- find dead ends
        potential = {}
        for x = 1, DUNGEON_WIDTH do
            for y = 1, DUNGEON_HEIGHT do
                local exits = (grid[x][y].n and 1 or 0)+
                    (grid[x][y].s and 1 or 0) +
                    (grid[x][y].e and 1 or 0) +
                    (grid[x][y].w and 1 or 0)

                if (exits == 1 and ((x ~= 3 or y ~= 5) and (x ~= 3 or y ~= 1))) then
                    table.insert(potential, {x = x, y = y})
                end
            end
        end

        -- regen if not enough dead ends
        if (#potential < 3) then
            okay = false
        else
            deadEnds = potential
        end
    until okay

    --  place items in dead ends
    scramble(deadEnds)
    
    if (floor > 1) then
        grid.up = table.remove(deadEnds)
    else
        grid.up = nil    
    end
    
    if (floor < FLOORS) then
        grid.down = table.remove(deadEnds)
    else
        grid.down = nil    
    end

    -- lock test
    --[[
    for i = 1, #potential do
        local x = potential[i].x
        local y = potential[i].y
        if (grid[x][y].n) then
            grid[x][y].locked.n = true
        end
        if (grid[x][y].s) then
            grid[x][y].locked.s = true
        end
        if (grid[x][y].e) then
            grid[x][y].locked.e = true
        end
        if (grid[x][y].w) then
            grid[x][y].locked.w = true
        end
    end
    ]]

    --  dungeon entrance
    if (floor == 1) then
        grid[3][5].s = true
        grid[3][5].locked.s = true
    end
    
    --  clear visited flags for automap
    for x = 1, DUNGEON_WIDTH do
      for y = 1, DUNGEON_HEIGHT do
        grid[x][y].visited = false
      end
    end

    --reseed()
    return grid
end

function mapRect(x1, y1, x2, y2, v)
    v = v or false

    for x = x1, x2 do
        for y = y1, y2 do
            room[x][y].solid = v
        end
    end
end

function clearRoom()
    room = {}
    for x = 0, 10 do
        room[x] = {}
        for y = 0, 10 do
            room[x][y] = {
                solid = true,
                tile = 6
            }
        end
    end
    room.gate = {
        x1 = 0,
        y1 = 0,
        x2 = 0,
        y2 = 0,
        messageShown = false
    }
    room.pillars = {}
end

local function addPillar(x1, y1, x2, y2)
    x2 = x2 or x1
    y2 = y2 or y1
    table.insert(room.pillars, {
        x1 = x1,
        y1 = y1,
        x2 = x2,
        y2 = y2
    })
end

function generateRoom(x, y)
    grid[x][y].visited = true

    clearRoom()

    math.randomseed(grid[x][y].seed)
    local n = grid[x][y].n
    local s = grid[x][y].s
    local e = grid[x][y].e
    local w = grid[x][y].w

    local exits=(n and 1 or 0)+
        (s and 1 or 0) +
        (e and 1 or 0) +
        (w and 1 or 0)

    --  hallways
    mapRect(0,0,10,10,0)
    if (n) then mapRect(3,0,6,6,false) end
    if (e) then mapRect(3,3,10,6,false) end
    if (s) then mapRect(3,3,6,10,false) end
    if (w) then mapRect(0,3,6,6,false) end

    if (exits == 1) then
        mapRect(2, 2, 7, 7)
    else
        --  carve out center
        if (math.random() < 0.75) then
            room.xs = math.random(2, 3)
            room.ys = math.random(2, 3)
            mapRect(4 - room.xs, 4 - room.ys, 5 + room.xs, 5 + room.ys)

            -- pillars
            local xs = room.xs
            local ys = room.ys
            if (math.random() < 0.65 or (xs == 3 and ys == 3)) then
                if (math.random() < 0.35) then
                    --  center pillar

                    --  (as long as we're not in the first room)
                    if (player.roomX ~= 3 or player.roomY ~= 5) then
                        xs = math.random(1, xs - 1)
                        ys = math.random(1, ys - 1)
                        addPillar(5 - xs, 5 - ys, 5 + xs, 5 + ys)
                    end
                else
                    --  two or four pillars
                    local xPillars = false
                    local yPillars = false
                    if (xs > 2) then
                        xPillars = true
                        xs = xs - 1
                    end
                    if (ys > 2) then
                        yPillars = true
                        ys = ys - 1
                    end

                    if (xPillars and not yPillars) then
                        addPillar(5 - xs, 5)
                        addPillar(5 + xs, 5)
                    end

                    if (yPillars and not xPillars) then
                        if (player.roomX ~= 3 or player.roomY ~= 5) then
                            addPillar(5, 5 - ys)
                            addPillar(5, 5 + ys)
                        end
                    end

                    if (xPillars and yPillars) then
                        addPillar(5 - xs, 5 - ys)
                        addPillar(5 + xs, 5 - ys)
                        addPillar(5 - xs, 5 + ys)
                        addPillar(5 + xs, 5 + ys)
                    end
                end
            end
        end
    end
    
    room.gate = {
        x1 = 0,
        y1 = 0,
        x2 = 0,
        y2 = 0,
        messageShown = false
    }
    
    --  add gates
    if (grid[x][y].locked.n) then
        room.gate.x1 = 50
        room.gate.x2 = 59
        room.gate.y1 = 6
        room.gate.y2 = 6
    end

    if (grid[x][y].locked.s) then
        room.gate.x1 = 50
        room.gate.x2 = 59
        if (y == 5) then
            room.gate.y1 = 22
            room.gate.y2 = 22
        else
            room.gate.y1 = 18
            room.gate.y2 = 18
        end
    end

    if (grid[x][y].locked.e) then
        room.gate.x1 = 67
        room.gate.x2 = 67
        room.gate.y1 = 10
        room.gate.y2 = 14
    end

    if (grid[x][y].locked.w) then
        room.gate.x1 = 43
        room.gate.x2 = 43
        room.gate.y1 = 10
        room.gate.y2 = 14
    end
    
    room.gateMessageShown = false

    marchSquares()

    --  add pillars
    for _, pillar in pairs(room.pillars) do
        for y = pillar.y1, pillar.y2 do
            for x = pillar.x1, pillar.x2 do
                room[x][y].solid = true
                room[x][y].tile = 16
            end
        end
    end
end

local function checkTile(x, y)
    if (x < 0) then
        x = 0
    end
    if (y < 0) then
        y = 0
    end
    
    return room[x][y].solid
end

function marchSquares()
    for x = 0, 10 do
        for y = 0, 10 do
            local v = 0
            if (checkTile(x - 1, y)) then
                v = v + 1
            end
            if (checkTile(x, y)) then
                v = v + 2
            end
            if (checkTile(x, y - 1)) then
                v = v + 4
            end
            if (checkTile(x - 1, y - 1)) then
                v = v + 8
            end
            room[x][y].tile = v + 1
        end
    end
    for x = 0, 10 do
        for y = 0, 10 do
            if (room[x][y].tile > 1) then
                room[x][y].solid = true
            end
        end
    end
end

function generateDungeon()
    dungeon = {}
    for floor = 1, FLOORS do
        dungeon[floor] = generateFloor(floor)
    end
    grid = dungeon[currentFloor]
end

