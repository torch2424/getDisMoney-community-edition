-- base level car object
baselevelcar = {
  x = 64,
  y = 10,
  width = 2,
  height = 1,
  dy = 0,
  dx = 0,
  box = {
    xleft = 1,
    xright = 10,
    yup = -1,
    ydown = 4
  },
  spriteindex = 104,
  sprite = 104,
  spawned = false,
  immunity = 0,
  liftoff = false,
  isend = false
}

-- the base level car class constructor
function baselevelcar:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function levelcarinit()
  levelcars, levelcarspawned, levelcarshot, levelcarshotdelay = {}, false, 0, 10
  add(levelcars, baselevelcar:new({}))
  -- Create an end level car
  add(levelcars, baselevelcar:new({
    x = 90,
    y = 70,
    immunity = 200,
    isend = true
  }))
end

-- Function to spawn the level car
function spawnlevelcar()
  levelcarspawned = true
  levelcars[1].x, levelcars[1].y, levelcars[1].spawned = playerspawn__x, playerspawn__y, true
end

-- Function to spawn final cars
function spawnendlevelcars()
  levelcarspawned = true
  -- spawn the normal level car in another position
  levelcars[2].spawned = 30, 70, true, 200, true
end

function levelcarupdate()
  for levelcar in all(levelcars) do
    -- Check if the level car is spawned
    if not levelcar.spawned then
      return true
    end

    if levelcar.immunity > 0 then
      levelcar.immunity -= 1
    end

    if isgrounded(levelcar) and not levelcar.liftoff then
      levelcar.dy, levelcar.y, levelcar.sprite = 0, flr(flr(levelcar.y) / 8) * 8, levelcar.spriteindex
    elseif levelcar.liftoff then
      levelcar.dy -= .42
      -- Screenshake while lifting off
      if levelcar.y > -20 then
        screenshake(1.5, 2, 3)
      end
      if gametime % 7 < 3 then
        levelcar.sprite = levelcar.spriteindex + 4
      else
        levelcar.sprite = levelcar.spriteindex + 6
      end
    else
      levelcar.dy += .52
      if gametime % 7 < 3 then
        levelcar.sprite = levelcar.spriteindex
      else
        levelcar.sprite = levelcar.spriteindex + 2
      end
    end

    -- Fax falling through the screen
    if levelcar.y > 128 then
      levelcar.dy, levelcar.y = -.27, 127
    end

    -- Check for a player collision to lift off and go to next map
    for player in all(players) do
      if levelcar.immunity <= 0 and iscollision(levelcar, player) then
        player.x, player.y, levelcar.liftoff, levelcar.height = -100, -100, true, 2

        -- play the liftoff sound
        sfx(8)
      end
    end

    -- Check if we flew off screen
    if levelcar.y < -20 then
      if levelcar.isend then
        -- Go To Good Gameover screen
        gamestate__gameoverstategood = true
        gameoverscreenshow()
        gameovertime = 0
      else
        gotonextlevel()
      end
    end

    -- Apply all forces
    if levelcar.y < -20 then
      levelcar.y = -30
      levelcar.dy = 0
    end
    levelcar.y += levelcar.dy
    levelcar.x += levelcar.dx
  end
end

function levelcardraw()
  for levelcar in all(levelcars) do
    if levelcar.spawned then
      if levelcar.isend then
        pal(14, 12)
        pal(12, 14)
      end
      spr(levelcar.sprite, levelcar.x, levelcar.y, levelcar.width, levelcar.height)
      pal()

      if isfinalboss() then
        if levelcar.isend then
          print("cash out", 83, 100, 11)
        else
          print("continue?", 20, 100, 8)
        end
      end
    end
  end
end
