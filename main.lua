-- Microbe Mayhem: Immune System Defense (Love2D prototype)

local lg = love.graphics

local width, height = 1024, 720

-- Grid for tower placement
local grid = {
  cols = 10,
  rows = 6,
  cell = 64,
  origin_x = 80,
  origin_y = 80,
}

-- Game state
local game = {
  time = 0,
  nutrients = 50,
  nutrient_rate = 5, -- per second
  resting = false,
  wave = 1,
  enemies = {},
  towers = {},
  projectiles = {},
  particles = {},
  spawn_timer = 0,
  spawn_interval = 1.5,
  unlocked_adaptive = false,
}

-- Tower definitions
local tower_types = {
  macrophage = { cost = 30, range = 80, rate = 1.2, damage = 20, color = {0.9,0.6,0.4}, desc = "Innate: AoE, slow" },
  neutrophil = { cost = 20, range = 120, rate = 0.5, damage = 12, color = {0.8,0.8,0.6}, desc = "Innate: fast single-target" },
  tcell = { cost = 60, range = 180, rate = 0.8, damage = 30, color = {0.6,0.7,1}, desc = "Adaptive: strong projectile" },
  bcell = { cost = 70, range = 220, rate = 2.0, damage = 8, color = {1,0.7,0.9}, desc = "Adaptive: produces antibodies (particles)" },
}

local selected_tower = 'macrophage'

-- Enemy definitions
local enemy_types = {
  bacteria = { hp = 40, speed = 40, color = {0.2,0.9,0.2}, size = 18, score = 5 },
  virus = { hp = 25, speed = 80, color = {0.9,0.2,0.2}, size = 12, score = 8 },
  fungus = { hp = 80, speed = 30, color = {0.6,0.3,0.7}, size = 22, score = 12 },
}

-- Utilities
local function clamp(x,a,b) return math.max(a, math.min(b,x)) end

local function world_to_cell(x,y)
  local gx = math.floor((x - grid.origin_x) / grid.cell) + 1
  local gy = math.floor((y - grid.origin_y) / grid.cell) + 1
  return gx, gy
end

local function cell_to_world(cx, cy)
  local x = grid.origin_x + (cx-1) * grid.cell + grid.cell/2
  local y = grid.origin_y + (cy-1) * grid.cell + grid.cell/2
  return x, y
end

-- Spawn path: enemies enter from left, head to right goal
local goal_x = width - 120
local spawn_x = 20
local path_y = height/2

-- Game functions
local function spawn_enemy(kind)
  local def = enemy_types[kind]
  local e = {
    kind = kind,
    hp = def.hp,
    maxhp = def.hp,
    speed = def.speed,
    x = spawn_x,
    y = path_y + (math.random()-0.5)*120,
    size = def.size,
    color = def.color,
    reached = false,
  }
  table.insert(game.enemies, e)
end

local function spawn_wave()
  local n = 6 + math.floor(game.wave * 1.5)
  for i=1,n do
    local r = math.random()
    if r < 0.55 then spawn_enemy('bacteria')
    elseif r < 0.85 then spawn_enemy('virus')
    else spawn_enemy('fungus') end
  end
  game.wave = game.wave + 1
end

local function place_tower_at(mousex, mousey)
  local cx, cy = world_to_cell(mousex, mousey)
  if cx < 1 or cy < 1 or cx > grid.cols or cy > grid.rows then return end
  -- check not occupied
  for _,t in ipairs(game.towers) do
    if t.cx == cx and t.cy == cy then return end
  end
  local ty = tower_types[selected_tower]
  if game.nutrients < ty.cost then return end
  game.nutrients = game.nutrients - ty.cost
  local x,y = cell_to_world(cx,cy)
  local t = { type = selected_tower, cx = cx, cy = cy, x = x, y = y, def = ty, cooldown = 0 }
  table.insert(game.towers, t)
end

local function damage_enemy(e, dmg)
  e.hp = e.hp - dmg
  -- spawn particles
  for i=1,6 do
    local p = { x = e.x + (math.random()-0.5)*e.size, y = e.y + (math.random()-0.5)*e.size, vx = (math.random()-0.5)*60, vy = (math.random()-0.5)*60, t = 0.6 }
    table.insert(game.particles, p)
  end
end

-- Projectiles
local function fire_projectile(sx, sy, tx, ty, speed, damage)
  local ang = math.atan2(ty - sy, tx - sx)
  local p = { x = sx, y = sy, vx = math.cos(ang)*speed, vy = math.sin(ang)*speed, damage = damage, t = 5 }
  table.insert(game.projectiles, p)
end

-- Update
function love.load()
  lg.setDefaultFilter('nearest','nearest')
  love.window.setMode(width, height)
  math.randomseed(os.time())
  -- initial wave
  spawn_wave()
end

function love.update(dt)
  game.time = game.time + dt
  -- nutrient accumulation
  local rate = game.nutrient_rate * (game.resting and 1.8 or 1)
  game.nutrients = game.nutrients + rate * dt

  -- unlock adaptive immunity after 25 seconds
  if not game.unlocked_adaptive and game.time > 25 then game.unlocked_adaptive = true end

  -- spawn handling
  game.spawn_timer = game.spawn_timer + dt
  if game.spawn_timer >= game.spawn_interval then
    game.spawn_timer = game.spawn_timer - game.spawn_interval
    -- spawn a single enemy occasionally between waves to keep action
    local r = math.random()
    if r < 0.5 then spawn_enemy('bacteria') elseif r < 0.8 then spawn_enemy('virus') else spawn_enemy('fungus') end
  end

  -- update enemies
  for i=#game.enemies,1,-1 do
    local e = game.enemies[i]
    local dx = goal_x - e.x
    local dy = path_y - e.y
    local dist = math.sqrt(dx*dx+dy*dy)
    if dist > 1 then
      e.x = e.x + (dx/dist) * e.speed * dt
      e.y = e.y + (dy/dist) * e.speed * dt
    else
      e.reached = true
    end
    if e.hp <= 0 then table.remove(game.enemies, i) end
  end

  -- update towers
  for _,t in ipairs(game.towers) do
    t.cooldown = t.cooldown - dt
    if t.cooldown <= 0 then
      -- find target
      local best, bd = nil, 1e9
      for _,e in ipairs(game.enemies) do
        local dx = e.x - t.x
        local dy = e.y - t.y
        local d = math.sqrt(dx*dx+dy*dy)
        if d <= t.def.range then
          if t.type == 'macrophage' then
            -- AoE: damage and slight slow to nearby
            damage_enemy(e, t.def.damage)
            for _,o in ipairs(game.enemies) do
              local dx2 = o.x - e.x
              local dy2 = o.y - e.y
              local dd = math.sqrt(dx2*dx2+dy2*dy2)
              if dd < 40 then o.x = o.x - (dx2/dd or 0) * 4 end
            end
            t.cooldown = t.def.rate
            break
          elseif t.type == 'neutrophil' then
            if d < bd then best, bd = e, d end
          elseif t.type == 'tcell' then
            best = e; break
          elseif t.type == 'bcell' then
            -- bcell: spawn antibodies (particle projectiles)
            for i=1,2 do
              local ang = math.random()*math.pi*2
              local px = t.x + math.cos(ang)*10
              local py = t.y + math.sin(ang)*10
              fire_projectile(px,py,t.x + math.cos(ang)*100, t.y + math.sin(ang)*100, 120, t.def.damage)
            end
            t.cooldown = t.def.rate
            break
          end
        end
      end
      if best and t.type == 'neutrophil' then
        fire_projectile(t.x, t.y, best.x, best.y, 320, t.def.damage)
        t.cooldown = t.def.rate
      elseif best and t.type == 'tcell' then
        fire_projectile(t.x, t.y, best.x, best.y, 380, t.def.damage)
        t.cooldown = t.def.rate
      end
    end
  end

  -- update projectiles
  for i=#game.projectiles,1,-1 do
    local p = game.projectiles[i]
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    p.t = p.t - dt
    -- collision with enemies
    for j=#game.enemies,1,-1 do
      local e = game.enemies[j]
      local dx = e.x - p.x
      local dy = e.y - p.y
      if dx*dx + dy*dy < (e.size+4)^2 then
        damage_enemy(e, p.damage)
        table.remove(game.projectiles, i)
        break
      end
    end
    if p.t <= 0 then table.remove(game.projectiles, i) end
  end

  -- update particles
  for i=#game.particles,1,-1 do
    local p = game.particles[i]
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    p.t = p.t - dt
    if p.t <= 0 then table.remove(game.particles, i) end
  end
end

function love.mousepressed(x,y,b)
  if b == 1 then
    place_tower_at(x,y)
  elseif b == 2 then
    game.resting = not game.resting
  end
end

function love.keypressed(k)
  if k == '1' then selected_tower = 'macrophage' end
  if k == '2' then selected_tower = 'neutrophil' end
  if k == '3' and game.unlocked_adaptive then selected_tower = 'tcell' end
  if k == '4' and game.unlocked_adaptive then selected_tower = 'bcell' end
  if k == 'space' then spawn_wave() end
end

function love.draw()
  lg.clear(0.08,0.08,0.12)

  -- draw grid
  for cx=1,grid.cols do
    for cy=1,grid.rows do
      local x = grid.origin_x + (cx-1)*grid.cell
      local y = grid.origin_y + (cy-1)*grid.cell
      lg.setColor(0.15,0.15,0.18)
      lg.rectangle('fill', x, y, grid.cell-2, grid.cell-2)
      lg.setColor(0.1,0.1,0.12)
      lg.rectangle('line', x, y, grid.cell-2, grid.cell-2)
    end
  end

  -- draw towers
  for _,t in ipairs(game.towers) do
    lg.setColor(t.def.color)
    lg.circle('fill', t.x, t.y, 18)
    lg.setColor(1,1,1,0.08)
    lg.circle('fill', t.x, t.y, t.def.range)
  end

  -- draw enemies
  for _,e in ipairs(game.enemies) do
    lg.setColor(e.color)
    lg.circle('fill', e.x, e.y, e.size)
    -- hp bar
    lg.setColor(0,0,0)
    lg.rectangle('fill', e.x - e.size, e.y - e.size - 8, e.size*2, 5)
    lg.setColor(0.2,1,0.2)
    local pct = clamp(e.hp / e.maxhp, 0, 1)
    lg.rectangle('fill', e.x - e.size, e.y - e.size - 8, e.size*2 * pct, 5)
  end

  -- draw projectiles
  for _,p in ipairs(game.projectiles) do
    lg.setColor(1,1,0.6)
    lg.circle('fill', p.x, p.y, 4)
  end

  -- particles
  for _,p in ipairs(game.particles) do
    lg.setColor(1,0.8,0.6, clamp(p.t*2,0,1))
    lg.rectangle('fill', p.x, p.y, 3,3)
  end

  -- UI
  lg.setColor(1,1,1)
  lg.print(string.format("Time: %.1fs", game.time), 12, 12)
  lg.print(string.format("Nutrients: %d", math.floor(game.nutrients)), 12, 32)
  lg.print(string.format("Wave: %d", game.wave-1), 12, 52)
  lg.print("Resting (right-click): " .. (game.resting and "ON" or "OFF"), 12, 72)
  lg.print("Selected: " .. selected_tower, 12, 92)
  lg.print("Keys: 1 macrophage, 2 neutrophil, 3 T-cell, 4 B-cell (adaptive unlocks after 25s)", 12, 112)
  lg.print("Click grid to place tower. Space to spawn wave.", 12, 132)

  if not game.unlocked_adaptive then
    lg.setColor(1,1,1,0.6)
    lg.print("Adaptive immunity will unlock shortly...", width - 320, 12)
  end
end