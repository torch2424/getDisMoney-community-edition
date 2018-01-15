-- Debug Code used to be sprinkled in the appropriate area, but because of the token limit, I had to move here :(

-- Some helper debug functions
-- [[
function drawbox(boxobject, color)
  -- Use our collision file, get box
  local box = getbox(boxobject)
  rect(box.xleft, box.yup, box.xright, box.ydown, color)
end
-- ]]

-- Debug initi called in resetplaystate()
function debuginit()
  --currentmap__x, currentmap__y = 3, 0

  -- [[
    -- *******************************************************
    --    CODE GOES IN HERE, MOVE OUTSIDE OF HERE TO TEST
    -- *******************************************************

    -- *******************************************************
    --    enemy.lua
    -- *******************************************************
    bosshealth = 3

    -- *******************************************************
    --    map.lua
    -- *******************************************************
    currentmap__x, currentmap__y = 3, 2

    -- *******************************************************
    --    statemanager.lua
    -- *******************************************************
    gamestate__finalbossstart = true

    -- *******************************************************
    --    savemanager.lua
    -- *******************************************************
    -- if on debug, clear the game memory
    for i = 0, 63 do
      dset(i, 0)
    end

  -- ]]
end


function debugdraw()
  -- print(gamestate__runminutes .. ":" .. gamestate__runseconds, 5, 5, 11)
  -- [[
    -- *******************************************************
    --    CODE GOES IN HERE, MOVE OUTSIDE OF HERE TO TEST
    -- *******************************************************

    -- *******************************************************
    --    bullet.lua
    -- *******************************************************
    for bullet in all(bullets) do
      drawbox(bullet, 11)
    end

    -- *******************************************************
    --    collectable.lua
    -- *******************************************************
    for collectable in all(drops) do
      drawbox(collectable, 10)
    end

    -- *******************************************************
    --    enemy.lua
    -- *******************************************************
    for enemy in all(enemies) do
      drawbox(enemy, 8)
    end

    for spawner in all(enemyspawners) do
      drawbox(spawner, 12)
    end

    for catcher in all(enemycatchers) do
      drawbox(catcher, 12)
    end

    for boss in all(bosses) do
      drawbox(boss, 12)
    end

    print("enemiesdefeated" .. enemiesdefeated, 0, 60, 7)
    print("enemyrate" .. enemyrate, 0, 70, 7)
    print("maxenemiesonscreen" .. maxenemiesonscreen, 0, 80, 7)
    print("enemiesonscreen" .. enemiesonscreen, 0, 90, 7)

    -- *******************************************************
    --    levelcar.lua
    -- *******************************************************
    for levelcar in all(levelcars) do
      drawbox(levelcar, 7)
      print(levelcar.y, 5, 5, 7)
    end

    -- *******************************************************
    --    map.lua
    -- *******************************************************
    print("current level: " .. getcurrentlevel(), 40, 10, 7)

    -- *******************************************************
    --    player.lua
    -- *******************************************************
    for i=1,count(players) do
      drawbox(players[i], 12)
    end

    -- *******************************************************
    --    savemanager.lua
    -- *******************************************************
    -- if on debug, clear the game memory
    for i = 0, 63 do
      dset(i, 0)
    end

    -- If we need cash to test
    totalcash = 9999
    dset(0, totalcash)

    -- *******************************************************
    --    shop.lua
    -- *******************************************************
    print("browsedelay: " .. browsedelay, 10, 105, 9)

    -- *******************************************************
    --    statemanager.lua
    -- *******************************************************
    print(gamestate__runminutes .. ":" .. gamestate__runseconds .. ":" .. flr(gamestate__runframes * 16.667), 4, 20, 11)

  -- ]]
end
