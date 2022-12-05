DUNGEON_WIDTH = 5
DUNGEON_HEIGHT = 5

function visit(x, y)
  grid[x][y].visited = true
  grid[x][y].seed = math.random()

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
    grid = {}
    for x = 1, DUNGEON_WIDTH do
        grid[x] = {}
        for y = 1, DUNGEON_HEIGHT do
            grid[x][y] = {
                n = false,
                s = false,
                e = false,
                w = false,
                visited = false,
            }
        end
    end

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
end

function mapRect(x1, y1, x2, y2, v)
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

    mapRect(0,0,10,10,0)
    if (n) then mapRect(4,0,6,6,false) end
    if (e) then mapRect(4,4,10,6,false) end
    if (s) then mapRect(4,4,6,10,false) end
    if (w) then mapRect(0,4,6,6,false) end
end
