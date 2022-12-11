DUNGEON_WIDTH = 5
DUNGEON_HEIGHT = 5

function visit(x, y)
  grid[x][y].visited = true
  grid[x][y].seed = math.random(256 ^ 4)

  repeat
    local potential={}
    if (x > 1 and not grid[x-1][y].visited) then
      table.insert(potential, {x - 1, y})
    end
    if (x < DUNGEON_WIDTH and not grid[x + 1][y].visited) then
      table.insert(potential, {x + 1, y})
    end
    if (y > 1 and not grid[x][y - 1].visited) then
      table.insert(potential, {x, y - 1})
    end
    if (y < DUNGEON_HEIGHT and not grid[x][y + 1].visited) then
      table.insert(potential, {x, y + 1})
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

function generateDungeon()
    repeat
        local ok=true

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
                }
            end
        end

        -- build maze
        visit(math.random(DUNGEON_WIDTH), math.random(DUNGEON_HEIGHT))

        -- knock out random walls
        local potential={}
        for x = 1, DUNGEON_WIDTH - 1 do
            for y = 1, DUNGEON_HEIGHT - 1 do
                if (not grid[x][y].s) then
                    table.insert(potential, {x, y, 0})
                end

                if (not grid[x][y].e) then
                    table.insert(potential,{x, y, 1})
                end
            end
        end

        for i=1,5 do
            local index = math.random(#potential)
            r = potential[index]
            if (r[3] == 0) then
                grid[r[1]][r[2]].s = true
                grid[r[1]][r[2] + 1].n = true
            else
                grid[r[1]][r[2]].e = true
                grid[r[1] + 1][r[2]].w = true
            end
            table.remove(potential, index)
        end

        -- find dead ends
        potential={}
        for x = 1, DUNGEON_WIDTH do
            for y = 1, DUNGEON_HEIGHT do
                local exits = (grid[x][y].n and 1 or 0)+
                    (grid[x][y].s and 1 or 0) +
                    (grid[x][y].e and 1 or 0) +
                    (grid[x][y].w and 1 or 0)

                if (exits == 1 and (x ~= 3 or y ~= 5)) then
                    table.insert(potential, {x,y})
                end
            end
        end

        -- regen if not enough dead ends
        if (#potential < 3) then
            ok = false
        else
            --  place items in dead ends
            --[[
            scramble(potential)

            grid[potential[1][1] ][potential[1][2] ].flag=1
            grid[potential[2][1] ][potential[2][2] ].flag=1
            if (dungeon~=3) grid[potential[3][1] ][potential[3][2] ].flag=2
            ]]
        end
    until ok

    --  entrance
    grid[3][1].n = true
    grid[3][1].locked.n = true

    --  exit
    grid[3][5].s = true
    grid[3][5].locked.s = true

    --  clear visited flags for automap
    for x = 1, DUNGEON_WIDTH do
      for y = 1, DUNGEON_HEIGHT do
        grid[x][y].visited = false
      end
    end

    --reseed()
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
                solid = true
            }
        end
    end
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
    if (n) then mapRect(4,0,6,6,false) end
    if (e) then mapRect(4,4,10,6,false) end
    if (s) then mapRect(4,4,6,10,false) end
    if (w) then mapRect(0,4,6,6,false) end

    if (exits == 1) then
        mapRect(3, 3, 7, 7)
    else
        --  carve out center
        if (math.random() < 0.5) then
            local xs = math.random(2, 4)
            local ys = math.random(2, 4)
            mapRect(5 - xs, 5 - ys, 5 + xs, 5 + ys)

            -- pillars
            if (math.random() < 0.5 or (xs == 4 and y2 == 4)) then
                if (math.random() < 0.5) then
                    --  center pillar

                    --  (as long as we're not in the first room)
                    if (player.roomX ~= 3 or player.roomY ~= 5) then
                        xs = math.random(1, xs - 1)
                        ys = math.random(1, ys - 1)
                        mapRect(5 - xs, 5 - ys, 5 + xs, 5 + ys, 1)
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
                        room[5 - xs][5].solid = true
                        room[5 + xs][5].solid = true
                    end

                    if (yPillars and not xPillars) then
                        room[5][5 - ys].solid = true
                        room[5][5 + ys].solid = true
                    end

                    if (xPillars and yPillars) then
                        room[5 - xs][5 - ys].solid = true
                        room[5 + xs][5 - ys].solid = true
                        room[5 - xs][5 + ys].solid = true
                        room[5 + xs][5 + ys].solid = true
                    end
                end
            end
        end
    end
end
