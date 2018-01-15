-- Our base collectable
basecollectable = {
  sprite = 10,
  x = 0,
  y = 0,
  width = 1,
  height = 1,
  dy = 0,
  box = {
    xleft = 1,
    xright = 5,
    yup = 0,
    ydown = 7
  },
  floaty = 0,
  floatingup = true,
  maxlifespan = 60 * 4,
  lifespan = 0,
  floatheight = 2,
  cashtype = false,
  healthtype = false
}

-- the collectable class constructor
function basecollectable:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end


function collectableinit()
  -- the larger the collectable spawn rate the less they spawn
  drops, collectablespawnrate = {}, 250
  collectablespawnrate = (425) - getcurrentlevel() * 2
  
  if bossmode then
    collectablespawnrate = flr(collectablespawnrate / 1.75)
  end
  if collectablespawnrate < 250 then collectablespawnrate = 250 end
end

function spawncash(cashx, cashy, amount)

  if gamestate__finalbossstart then
    return
  end

  -- Spawning too much cash is bad
  -- Delete drops if cash is spawning
  if count(drops) > 50 then
    del(drops, drops[0])
  end

  local newcash = basecollectable:new({
    x = cashx,
    y = cashy
  })
  newcash.box = {
    xleft = 1,
    xright = 4,
    yup = 0,
    ydown = 3
  }
  newcash.lifespan, newcash.sprite, newcash.cashtype, newcash.floaty, newcash.amount = newcash.maxlifespan + flr(rnd(20)), 10, true, cashy, amount
  add(drops, newcash)
end

function spawnhealth(collectablex, collectabley, amount)

  if gamestate__finalbossstart then
    return
  end

  local newcollectable = basecollectable:new({
    x = collectablex,
    y = collectabley
  })
  newcollectable.lifespan, newcollectable.sprite, newcollectable.healthtype, newcollectable.floaty, newcollectable.amount = newcollectable.maxlifespan + flr(rnd(20)), 11, true, collectabley, amount
  add(drops, newcollectable)
end

function spawncoffee(collectablex, collectabley, amount)

  if gamestate__finalbossstart then
    return
  end

  local newcollectable = basecollectable:new({
    x = collectablex,
    y = collectabley
  })
  newcollectable.lifespan, newcollectable.sprite, newcollectable.coffeetype, newcollectable.coffeetime, newcollectable.floaty = newcollectable.maxlifespan + flr(rnd(20)), 12, true, 300, collectabley
  add(drops, newcollectable)
end

function spawnslowtime(collectablex, collectabley, amount)

  if gamestate__finalbossstart then
    return
  end

  local newcollectable = basecollectable:new({
    x = collectablex,
    y = collectabley
  })
  newcollectable.lifespan, newcollectable.sprite, newcollectable.slowtimetype, newcollectable.slowtime, newcollectable.floaty = newcollectable.maxlifespan, 13, true, 300, collectabley
  add(drops, newcollectable)
end

function floatcollectable(collectable)
  -- Slightly increase the collectable dy
  if collectable.floatingup then
    collectable.dy += .03
  else
    collectable.dy -= .03
  end

  collectable.floaty += collectable.dy

  if collectable.floaty - collectable.y > collectable.floatheight then
    collectable.floatingup = false
  end
  if collectable.floaty < collectable.y then
    collectable.floatingup = true
    collectable.dy = 0
  end
end

function generatecollectablespawn()
  -- generate the spawn (Get a random enemy and spawn near it)
  local spawnlocation = {
    x = flr(rnd(110)),
    y = flr(rnd(110)),
    width = 1,
    height = 1
  }
  if count(bosses) > 0 then
    local enemyindex = flr(rnd(count(bosses))) + 1
    spawnlocation.x, spawnlocation.y = bosses[enemyindex].x, bosses[enemyindex].y - 8
  end
  if count(enemies) > 0 then
    local enemyindex = flr(rnd(count(enemies))) + 1
    spawnlocation.x, spawnlocation.y = enemies[enemyindex].x, enemies[enemyindex].y - 8
  end

  -- Check if we spawned inside the ground
  if isgrounded(spawnlocation) then spawnlocation.y += 8 end

  -- return the spawn locaiton
  return spawnlocation
end

function collectableupdate()
  for collectable in all(drops) do

    -- Decrease collectable lifespan
    if collectable.lifespan > 0 then collectable.lifespan -= 1 end

    floatcollectable(collectable)

    -- Check for collectable collision with a player
    for player in all(players) do
      if iscollision(collectable, player) and player.health > 0 then

        -- cash collectable logic
        if collectable.cashtype then
          -- Add the cash value to the player score
          sfx(6)
          gamestate__cash += collectable.amount
          if gamestate__cash >= PICO__MAX__NUMBER then gamestate__cash = PICO__MAX__NUMBER end
          del(drops, collectable)
        end

        -- health colelctable logic
        if collectable.healthtype then
          -- Add the cash value to the player score
          player.health += collectable.amount
          sfx(5)
          if player.health > player.maxhealth then player.health = player.maxhealth end
          del(drops, collectable)
        end

        -- coffee collectable logic
        if collectable.coffeetype then
          -- Add the cash value to the player score
          player.slowtimepowerup, player.coffeepowerup = 0, collectable.coffeetime
          sfx(5)
          del(drops, collectable)
        end

        -- slow time collectable logic
        if collectable.slowtimetype then
          -- Add the cash value to the player score
          player.coffeepowerup, player.slowtimepowerup = 0, collectable.slowtime
          sfx(5)
          del(drops, collectable)
        end
      end

      -- Check if we should remove the collectable
      if collectable.lifespan <= 0 then
        del(drops, collectable)
      end
    end
  end

  -- Randomly spawn some drops
  -- only if the players is alive, and the next level car has not spawned
  if not allplayersdead() and
    gametime % collectablespawnrate == 0 and
    not levelcarspawned then
    -- get our spawn location
    local spawn = generatecollectablespawn()
    local whichdrop = flr(rnd(9))
    if whichdrop >= 5 then
      spawnhealth(spawn.x, spawn.y, flr(rnd(3)) + 2)
    elseif whichdrop >= 2 then
      spawncoffee(spawn.x, spawn.y, 1)
    elseif whichdrop >= 0 then
      spawnslowtime(spawn.x, spawn.y, 1)
    end
  end
end

function collectabledraw()
  for collectable in all(drops) do

    -- Check if it is cash
    if collectable.cashtype then
      if collectable.amount > 5 then
        pal(3, 1)
        pal(11, 12)
      elseif collectable.amount > 10 then
        pal(3, 9)
        pal(11, 10)
      elseif collectable.amount > 25 then
        pal(3, 8)
        pal(11, 14)
      elseif collectable.amount > 50 then
        pal(3, 5)
        pal(11, 13)
      end
    end

    -- Flash if about to disappear
    if collectable.lifespan < 105 then
      if collectable.lifespan % 6 > 0 and collectable.lifespan % 6 <= 2 then
        pal(1, 10)
        pal(2, 10)
        pal(3, 10)
        pal(4, 10)
        pal(5, 10)
        pal(6, 10)
        pal(7, 10)
        pal(8, 10)
        pal(9, 10)
        pal(11, 10)
        pal(12, 10)
        pal(13, 10)
        pal(14, 10)
        pal(15, 10)
      end
    end

    spr(collectable.sprite, collectable.x, collectable.floaty, collectable.width, collectable.height)

    -- reset pal
    pal()
  end

  -- Show powerupds in HUD
  for i=1,count(players) do
    local powertitley = 0
    if i == 1 then
      powertitley = 1
    else
      powertitley = 9
    end

    -- Print the current powerup
    if players[i].coffeepowerup > 0 then
      spr(12, 120, powertitley)
    end

    if players[i].slowtimepowerup > 0 then
      spr(13, 120, powertitley)
    end
  end
end
