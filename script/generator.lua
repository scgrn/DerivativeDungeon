DUNGEON_WIDTH = 5
DUNGEON_HEIGHT = 5

function generateDungeon()
  grid = {}
  for y = 1, DUNGEON_HEIGHT do
    grid[y] = {}
    for x = 1, DUNGEON_WIDTH do
      grid[y][x] = {
        n = false,
        s = false,
        e = true,
        w = true,
        seed = 0
      }
    end
  end
end

function mapRect(x1, y1, x2, y2, v)
  for y = y1, y2 do
    for x = x1, x2 do
      room[y][x].solid = v
    end
  end
end

function clearRoom()
  room = {}
  for y = 0, 10 do
      room[y] = {}
      for x = 0, 10 do
          room[y][x] = {
              solid = true
          }
      end
  end
end

function generateRoom(x, y)
  clearRoom()

  --srand(grid[x][y].seed)
  local n = grid[x][y].n
  local s = grid[x][y].s
  local e = grid[x][y].e
  local w = grid[x][y].w

  local exits=(n and 1 or 0)+
   (s and 1 or 0) +
   (e and 1 or 0) +
   (w and 1 or 0)

  mapRect(0,0,10,10,0)
  if (n) then mapRect(4,0,6,5,false) end
  if (e) then mapRect(5,4,10,6,false) end
  if (s) then mapRect(4,5,6,10,false) end
  if (w) then mapRect(0,4,5,6,false) end
end
