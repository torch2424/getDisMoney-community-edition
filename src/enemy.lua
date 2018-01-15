function enemyinit()

  -- bossspriteindexes: Our boss sprite indexes
  -- enemyspriteindexes: Our enemy sprite indexes, sprite order will determine how fast they are
  -- How often we get a chance to spawn an enemy
  -- enemiesonscreen: Get the max enemies on screen
  enemies, enemyspawners, enemycatchers, bosses, bossmode, bossspriteindexes, enemyspriteindexes, maxenemyrate, enemiesdefeated, enemiesspawned, enemyspawndelay, enemyspawnskips, enemiesonscreen, maxenemiesonscreen = {}, {}, {}, {}, false, {64, 68, 0}, {20, 23, 4, 7, 36}, 6, 0, 0, (60 - ((getcurrentlevel() - 1) * 15)) / 2.35, 0, 0, getcurrentlevel() * 6 + 6

  enemyrate = maxenemyrate
  -- multiplayer
  if count(players) > 1 then
    maxenemiesonscreen += ((getcurrentlevel() - 1) * (2 + count(players)) + 6)
  end

  -- Get if we are in boss mode
  if getcurrentlevelwithoutloops() % 4 == 0 then
      bossmode = true
  end

  if bossmode then
    local bosshealth = ceil(getcurrentlevel()) + 7
    local bossmaxspeed = 1.575
    if isfinalboss() then
      bossmaxspeed = 2.185;
    end
    local bossmaximmunity = 10;
    local bossspriteindex = getcurrentlevelwithoutloops() / 4
    local boss = {
      spriteindex = bossspriteindexes[bossspriteindex],
      currentsprite = bossspriteindexes[bossspriteindex],
      x = 90,
      y = 60,
      width = 2,
      height = 2,
      dx = 0,
      dy = 0,
      box = {
        xleft = 0,
        xright = 11,
        yup = 0,
        ydown = 11
      },
      flipx = true,
      immunity = 0,
      maximmunitty = bossmaximmunity,
      health = bosshealth,
      speed = bossmaxspeed / 2,
      maxspeed = bossmaxspeed,
    }

    -- Check if it is the final boss
    if isfinalboss() then
      boss.box.xleft, boss.box.xright, boss.box.yup, boss.box.ydown, boss.width, boss.height = 1, 4, 1, 4, 1, 1
    end

    add(bosses, boss)
  end

  if not bossmode then
    -- spawners
    local spawnery = 2
    local leftspawner = {
      sprite = 50,
      x = 0,
      y = spawnery,
      width = 1,
      height = 1,
      flipx = false,
      box = {
        xleft = 0,
        xright = 3,
        yup = 3,
        ydown = 5
      }
    }
    local rightspawner = {
      sprite = 49,
      x = 120,
      y = spawnery,
      width = 1,
      height = 1,
      flipx = true,
      box = {
        xleft = 0,
        xright = 3,
        yup = 3,
        ydown = 5
      }
    }
    add(enemyspawners, leftspawner)
    add(enemyspawners, rightspawner)

    -- catchers
    local catchery = 105
    local leftcatcher = {
      sprite = 54,
      x = 0,
      y = catchery,
      width = 1,
      height = 1,
      flipx = false,
      box = {
        xleft = 0,
        xright = 3,
        yup = 2,
        ydown = 5
      }
    }
    local rightcatcher = {
      sprite = 55,
      x = 120,
      y = catchery,
      width = 1,
      height = 1,
      flipx = true,
      box = {
        xleft = 0,
        xright = 3,
        yup = 2,
        ydown = 5
      }
    }
    add(enemycatchers, leftcatcher)
    add(enemycatchers, rightcatcher)
  end
end

function isfinalboss()
  if getcurrentlevelwithoutloops() == 12 then
    return true
  else
    return false
  end
end

function spawnenemy()
  -- Create our spawn point
  local spawnpoint = enemyspawners[flr(rnd(count(enemyspawners)) + 1)]
  -- get a random enemy spirte (no - zero,
  -- since rnd is exclusive of maximumum, and can only rach the max with flr)
  -- Also, increase the ceiling of sprite indexes as we advance through levels
  local levelspriteindex = ceil(getcurrentlevel() / 3) + 1
  if levelspriteindex > count(enemyspriteindexes) then
    levelspriteindex = count(enemyspriteindexes)
  end
  local enemyspriteindex = flr(rnd(levelspriteindex) + 1)
  local randomsprite = enemyspriteindexes[enemyspriteindex]

  -- get a random speed (based from their sprite index to give enemies character)
  -- Speed can be a decimal
  local randomspeed = (rnd(2) / 5) + (enemyspriteindex / (count(enemyspriteindexes) / 2))
  if randomspeed > 1.985 then randomspeed = 1.985 end
  randomspeed = randomspeed * 2

  local enemy = {
    spriteindex = randomsprite,
    currentsprite = randomsprite,
    x = spawnpoint.x,
    y = spawnpoint.y - 4,
    width = 1,
    height = 1,
    dx = randomspeed,
    dy = 0,
    box = {
      xleft = 1,
      xright = 4,
      yup = 0,
      ydown = 5
    },
    flipx = false,
    immunity = 20 - getcurrentlevelwithoutloops(),
    isdead = 0
  }
  -- Push to the enemies array
  add(enemies, enemy)
  enemiesonscreen += 1
  enemiesspawned += 1
end

function enemyupdate()
  --Check for enemy spawning
  enemyspawndelay -= 1
  if gamestate__playstate and
    not bossmode and
    enemyspawndelay < 0 and
    enemiesdefeated < maxenemiesonscreen then

    enemyrate -= 1
    if enemyrate <= 0 then
      --reset our enemyrate
      enemyrate = maxenemyrate

      --Get a random number based from our max levels
      local shouldspawn = flr(rnd(maxlevels - getcurrentlevel() + 2))
      if shouldspawn == 1 or enemyspawnskips >= 10 then
        spawnenemy()
        enemyspawnskips = 0
      else
        enemyspawnskips += count(players) + (getcurrentlevel())
      end
    end
  end

  -- Check for spawning the (next) level car
  if enemiesdefeated >= maxenemiesonscreen - flr(getcurrentlevel() * 2) and
    not levelcarspawned then
    spawnlevelcar()
  end

  -- Spawners
  for spawner in all(enemyspawners) do
    if gametime % 7 < 3 then
      spawner.sprite = 50
    else
      spawner.sprite = 49
    end

    -- Drop to grounded
    if isgrounded(spawner) then
      spawner.y = flr(flr(spawner.y) / 8) * 8
    else
      spawner.y += 0.75
    end
  end

  -- Catchers
  for catcher in all(enemycatchers) do
    if gametime % 7 < 3 then
      catcher.sprite = 55
    else
      catcher.sprite = 54
    end

    -- Drop to grounded
    if isgrounded(catcher) then
      catcher.y = flr(flr(catcher.y) / 8) * 8
    else
      catcher.y += 0.75
    end
  end

  -- Enemies
  for enemy in all(enemies) do
    enemy.immunity -= 1
    if enemy.isdead > 2 then
      del(enemies, enemy)
    elseif enemy.isdead > 0 then
      enemy.isdead += 1
    end

    if enemy.isdead <= 0 then
      if enemy.x < 0 or iswallleft(enemy) then
        enemy.x += 1
        enemy.flipx, enemy.dx = false, abs(enemy.dx) + .05
        if enemy.dx > 2 then enemy.dx = 2 end
      end
      if enemy.x > 120 or iswallright(enemy) then
        enemy.x -= 1
        enemy.flipx, enemy.dx = true, enemy.dx * -1 + .05
        if enemy.dx < -2 then enemy.dx = -2 end
      end
      -- No Ceiling support, would be on this line
      if enemy.y > 120 then
        enemy.y = 119
      end

      -- flip our sprites
      if gametime % 7 < 3 then
        enemy.currentsprite = enemy.spriteindex + 1
      else
        enemy.currentsprite = enemy.spriteindex
      end

      -- Grounding
      if isgrounded(enemy) then
        -- Default grounded state
        enemy.dy, enemy.y = 0, flr(flr(enemy.y) / 8) * 8

        -- Check if we want to jump (1 in 60 chance)
        local shouldjump = flr(rnd(30))
        if getcurrentlevel() > 4 and
          shouldjump == 9 and
          enemy.spriteindex == enemyspriteindexes[1] then
          -- Play the jump sound
          sfx(0)
          enemy.dy -= 2.4
        end
      else
        enemy.dy += 0.34
      end

      -- Apply the velocity to the enemy
      enemy.x += enemy.dx
      enemy.y += enemy.dy

      -- check for collision with the player
      for player in all(players) do
        if iscollision(player, enemy) and
        player.currentinvincible <= 0 and
        player.health >= 1 and
        enemy.isdead <= 0
        then
          player.currentinvincible = player.invicibleframes
          player.health -= 1;
          -- Play hurt sound effect only if not dead
          if player.health > 0 then sfx(3) end
          screenshake(1.35, 8, 1)
        end
      end

      -- Check for collision with a catcher
      for catcher in all(enemycatchers) do
        if(iscollision(enemy, catcher) and enemy.y <= catcher.y) then
          -- Delete the enemy
          enemiesonscreen -= 1
          del(enemies, enemy)
        end
      end
    end
  end

  -- Bosses Update
  for boss in all(bosses) do

    -- Check if in any of the custscenes
    if gamestate__finalbossstart then
      if isgrounded(boss) then
        gamestate__finalbossstart = false
      else
        boss.dy = 0.19
        boss.y += boss.dy
      end
      return
    end

    if gamestate__finalbossend then
      if not runspeedsaved then
        savespeed()
        runspeedsaved, gamestate__canloop = true, true
      end
      boss.dy += 0.19

      if gametime % 5 == 0 then
        boss.y += boss.dy
      end

      if isgrounded(boss) then
        -- del(bosses, boss)
        delaygotonextlevel(150)
        gamestate__finalbossend = false
        boss.health = -100
      end

      return
    end

    boss.immunity -= 1
    if boss.health > 0 then

      -- Wall checking
      if boss.x < 0 or iswallleft(boss) then
        boss.x += 1
        boss.flipx, boss.dx = false, abs(boss.dx) + .1
      end
      if boss.x > 120 or iswallright(boss) then
        boss.x -= 1
        boss.flipx, boss.dx = true, boss.dx * -1 + .1
      end

      -- flip our sprites
      if gametime % 7 < 3 then
        if isfinalboss() then
          boss.currentsprite = boss.spriteindex + 1
        else
          boss.currentsprite = boss.spriteindex + 2
        end
      else
        boss.currentsprite = boss.spriteindex
      end

      -- Check if we should shoot
      if boss.spriteindex != bossspriteindexes[1] then
        local shouldshoot = flr(rnd(70))
        if shouldshoot == 10 and
          flr(enemyspawndelay / 2) + 50 <= 0 and
          not allplayersdead() then
          -- Spawn a bullet
          local bulletspawnx = 4
          local bulletspawny = 8
          local bulletspeed = 0.125
          if isfinalboss() then
            bulletspawny, bulletspeed = 0, 0.325
          end
          if boss.flipx then
            spawnbulletoverload(boss.x - bulletspawnx, boss.y + bulletspawny, bulletspeed, true, true)
          else
            spawnbulletoverload(boss.x + bulletspawnx, boss.y + bulletspawny, bulletspeed, false, true)
          end
        end
      end

      -- Grounding
      if isgrounded(boss) then
        -- Default grounded state
        boss.dy, boss.y = 0, flr(flr(boss.y) / 8) * 8

        -- Check if we want to jump (1 in 60 chance)
        if boss.spriteindex != bossspriteindexes[2] then
          local shouldjump = flr(rnd(60))
          if shouldjump == 10 and
            not allplayersdead() then
            -- Play the jump sound
            sfx(0)
            boss.dy -= 3.4
          end
        end
      else
        boss.dy += 0.34
      end

      -- No Ceiling support, would be on this line
      if boss.y > 120 then
        boss.y = 119
      end

      -- Move x relative to the closest player
      local nearestplayer = players[1];
      if count(players) > 1 then
        -- If player 2 is closer and alive, or player 1 is dead
        if (abs(nearestplayer.x - boss.x) > abs(players[2].x - boss.x) and
          players[2].health > 0) or
         players[1].health <= 0 then
          nearestplayer = players[2];
        end
      end
      if nearestplayer.x - boss.x > 0 then
        boss.dx += boss.speed
        boss.flipx = false
      else
        boss.dx -= boss.speed
        boss.flipx = true
      end

      if boss.dx > boss.maxspeed then boss.dx = boss.maxspeed end
      if boss.dx < boss.maxspeed * -1 then boss.dx = boss.maxspeed * -1 end

      -- Apply the velocity to the enemy
      if not allplayersdead() and flr(enemyspawndelay / 2) + 20 <= 0 then
        if boss.health < 3 then
          boss.x += (boss.dx / 1.5)
        else
          boss.x += boss.dx
        end
      end
      boss.y += boss.dy

      -- check for collision with the player
      for player in all(players) do
        if (iscollision(player, boss) and player.currentinvincible <= 0 and player.health >= 1) then
          player.currentinvincible = player.invicibleframes
          player.health -= 1;
          sfx(3)
          screenshake(1.45, 9, 1)
        end
      end
    else
      -- boss is dead
      if isfinalboss() then
        boss.currentsprite = 17
      end
    end
  end
  -- Bosses Update end
end


function enemydraw()

  -- Final boss red flash
  if gamestate__finalbossstart and gametime % 60 > 50 then
    if gametime % 60 < 55 then
      rectfill(0, 0, 128, 128, 2)
    else
      rectfill(0, 0, 128, 128, 8)
    end
  end

  -- Final Boss Kill White flash
  if gamestate__finalbossend then
    rectfill(0, 0, 128, 128, 7)
  end

  -- enemies
  for enemy in all(enemies) do
    -- Pallete flips
    if enemy.spriteindex == enemyspriteindexes[1] and
      getcurrentlevel() > 4 then
        pal(12, 8)
    end

    if enemy.isdead > 0 then
      hurtpal()
    end

    -- Draw the sprite
    spr(enemy.currentsprite, enemy.x, enemy.y, enemy.width, enemy.height, enemy.flipx)

    -- reset the pallete
    pal()
  end
  -- spawners
  for spawner in all(enemyspawners) do
    spr(spawner.sprite, spawner.x, spawner.y, spawner.width, spawner.height, spawner.flipx)
  end
  -- catchers
  for catcher in all(enemycatchers) do
    spr(catcher.sprite, catcher.x, catcher.y, catcher.width, catcher.height, catcher.flipx)
  end
  -- bosses
  for boss in all(bosses) do
    -- Pallete flips

    -- If is the final boss, make a shadow you
    pal(3, 1)
    pal(5, 4)
    pal(14, 13)
    pal(8, 2)
    pal(7, 8)

    -- Hurt pallete
    if boss.immunity > 0 then
      hurtpal()
    end

    spr(boss.currentsprite, boss.x, boss.y, boss.width, boss.height, boss.flipx)

    --reset the pallete
    pal()
  end
end
