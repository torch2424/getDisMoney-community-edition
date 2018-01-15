function bulletinit()
  bullets, actions = {}, {}
end

-- Function to spawn bullet, overload to spawnbullet to not include a default speed
function spawnbullet(spawnx, spawny, isgoingleft, isforplayers)
  spawnbulletoverload(spawnx, spawny, 1, isgoingleft, isforplayers)
end

-- Function to play the bullet fx
function bulletfx(bullet)
  sfx(4)
  if bullet.hitframes <= 0 then
    bullet.sprite, bullet.hitframes = 19, 1
  end
end

function spawnbulletoverload(spawnx, spawny, speed, isgoingleft, isforplayers)
  local bullet = {
    sprite = 18,
    x = spawnx,
    y = spawny,
    width = 1,
    height = 1,
    box = {
      xleft = 1,
      xright = 2,
      yup = -1,
      ydown = 2
    },
    flipx = isgoingleft,
    speed = 6.5 * speed,
    dy = rnd(35) / 50,
    aliveframes = 0,
    hitframes = 0,
    isforplayer = isforplayers
  }
  -- Apply the velocity and spacing
  -- depending on facing direction
  if isgoingleft then
    bullet.dx = bullet.speed * -1
    bullet.x -= bullet.speed
  else
    bullet.dx = bullet.speed
    bullet.x += bullet.speed
  end
  if bullet.isforplayer then
    bullet.dy = 0
  elseif rnd(2) == 0 then
    bullet.dy = bullet.dy * -1
  end
  add(bullets, bullet)
  -- Play shooting sound
  sfx(1)
end

function bulletupdate()

  -- Update any coroutines
  -- http://www.lexaloffle.com/bbs/?tid=3458
  for c in all(actions) do
    if costatus(c) then
      coresume(c)
    else
      del(actions,c)
    end
  end

  for bullet in all(bullets) do

    -- Apply our motions
    if bullet.aliveframes > 1 then
      if bullet.flipx then
        bullet.dx -= .34
      else
        bullet.dx += .34
      end
      -- Apply our vectors, dependent on slow time
      if slowtime > 0 and bullet.isforplayer then
        bullet.x += (bullet.dx / 3)
      else
        bullet.x += bullet.dx
      end
      bullet.y += bullet.dy
    end

    -- Check if we should delete the bullet off the screen
    if bullet.x < 0 or bullet.x > 128 or bullet.y < 0 or bullet.y > 128 then
      del(bullets, bullet)
    end

    -- flip our sprite, if we are not in hit frames, and we have been alive a while
    if bullet.hitframes < 1 and bullet.aliveframes > 1 then
      if gametime % 2 < 1 then
        bullet.sprite = 2
      else
        bullet.sprite = 3
      end
    end

    -- Check for enemy collisions
    for enemy in all(enemies) do
      if not bullet.isforplayer and
        iscollision(bullet, enemy) and
        enemy.isdead <= 0 and
        enemy.immunity < 1 then
        -- Spawn ALOT of cash
        cashdrop(enemy.x, enemy.y, flr(getcurrentlevel() / 2) + 1, 1)
        -- will start death animation
        enemy.isdead += 1
        enemiesonscreen -= 1
        enemiesdefeated += 1
        sfx(51)
        bulletfx(bullet)
      end
    end

    -- Check for Boss collisions
    for boss in all(bosses) do
      if not bullet.isforplayer and
        iscollision(bullet, boss) and
        boss.health > 0 and
        boss.immunity < 1 then

        -- Subtract health and reset immunity
        boss.health -= 1
        boss.immunity = boss.maximmunitty

        -- Check if we killed the boss
        if boss.health < 1 then
          -- Spawn some health (2nd has a slight chance for full health)
          spawnhealth((boss.x / 2) + 10, 95, 1)
          spawnhealth((boss.x / 3) + 21, 99, flr(rnd(2)) + 1)
          spawnhealth((boss.x / 2) + 34, 91, 1)

          -- Delete the boss, and go to the next level
          if isfinalboss() then
            -- Spawn ALOT MORE of cash since it's the final boss
            cashdrop(boss.x, boss.y, getcurrentlevel(), 30)
            gamestate__finalbossend = true
            music(-1)
            boss.dy -= 8
            boss.y += boss.dy
          else
            -- Spawn ALOT of cash
            cashdrop(boss.x, boss.y, getcurrentlevel(), 15)
            del(bosses, boss)
            delaygotonextlevel(150)
          end
        end

        -- Play the bullet effects
        sfx(51)
        bulletfx(bullet)
      end
    end

    -- Check for player collisions
    for player in all(players) do
      if bullet.isforplayer and
        iscollision(bullet, player) and
        player.currentinvincible <= 0 then
        -- subtract player health
        player.health -= 1
        player.currentinvincible = player.invicibleframes

        -- Play the bullet effects
        bulletfx(bullet)
      end
    end

    -- Check for wall collisions
    if iswallleft(bullet) or iswallright(bullet) then
      if bullet.hitframes <= 0 then
        bulletfx(bullet)
      end
    end

    -- Check if the bullet hit, and should be deleted
    if bullet.hitframes > 0 then bullet.hitframes += 1 end
    if bullet.hitframes > 5 then del(bullets, bullet) end

    -- increase the frames the bullet has been alive
    bullet.aliveframes += 1
  end
end

-- Coroutine to spawn cash over multiple frames
function cashdrop(basex, basey, baseamount, spawnmultiplier)
  local c = cocreate(function()
    local cashtospawn = flr((getcurrentlevel() / 6) * spawnmultiplier)
    if cashtospawn < 1 then cashtospawn = 1 end
    for i = cashtospawn, 1, -1 do
      local cashx = flr(rnd(20)) + basex
      -- Make sure not to spawn on edges
      if cashx > 90 then cashx = cashx * -1 end
      if cashx < 30 then cashx = cashx + 10 end
      local cashy = flr(rnd(3)) + basey - 2
      spawncash(cashx, cashy, flr(rnd(getcurrentlevel() * 2)) + baseamount)

      -- Wait 3 frames
      yield()
      yield()
      yield()
    end
  end)
  add(actions, c)
end

function bulletdraw()
  for bullet in all(bullets) do
    spr(bullet.sprite, bullet.x, bullet.y, 1, 1, bullet.flipx)
  end
end
