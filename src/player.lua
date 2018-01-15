function playerinit()
  -- Add the player 1 to our players
  players = {}

  -- add some players
  -- Create our number of players
  for i = 1, gamestate__numplayers do
    local spawnmultiplier = (i / 2) + 1
    local spawndistance = 8 * spawnmultiplier
    --Check if it is positive or negative
    if i % 2 == 1 then
      spawndistance = spawndistance * -1
    end

    spawnplayer(spawndistance)
  end

  -- Player input delay
  playerinputdelay = 15
end

function spawnplayer(spawnx)
  -- Add the player to the players array
  playerspawn__x, playerspawn__y = 60, 20
  local player = {
    sprite = 0,
    x = playerspawn__x,
    y = playerspawn__y,
    width = 1,
    height = 1,
    dx = 0,
    dy = 0,
    box = {
      xleft = 1,
      xright = 4,
      yup = 1,
      ydown = 4
    },
    flipx = false,
    moving = false,
    grounded  = false,
    jumps = 2,
    maxhealth = 10,
    health = 10,
    invicibleframes = 90,
    currentinvincible = 0,
    coffeepowerup = 0,
    slowtimepowerup = 0,
    wingspowerup = 0,
    bigbulletspowerup = 0
  }

  add(players, player)
  resetplayerlocation()
end

function resetplayerlocation()
  if count(players) > 1 then
  for i = 1, count(players) do
    if i == 1 then
      players[i].x = playerspawn__x + 8
    else
      players[i].x = playerspawn__x - 8
    end
    players[i].y = playerspawn__y
  end
  else
    players[1].x, players[1].y = playerspawn__x, playerspawn__y
  end
end

function playerupdate()

  -- Check our input delay
  if gamestate__finalbossstart or
    gamestate__finalbossend then
    playerinputdelay = 2
  end

  if playerinputdelay > 0 then
    playerinputdelay -= 1
  end

  -- Apply actions for each player
  for i=1,count(players) do
    if players[i].health <= 0 then
      players[i].sprite = 17
      if not gamestate__gameoverstate and allplayersdead() then
        gameoverscreenshow()
        -- Jump the player
        players[i].dy -= 3.8
      else
        -- Apply forces to the player
        if isgrounded(players[i]) then
          players[i].dy = 0
        else
          players[i].dy += 0.24
        end
      end

      -- Remove hurt color
      players[i].currentinvincible = 0

      -- Apply forces
      players[i].y += players[i].dy
    else
      playeraction(players[i], i)
      if(players[i].moving and gametime % 2 < 1) then
        players[i].sprite = 1
      else
        players[i].sprite = 0
      end
      -- decrease our modifiers
      if players[i].currentinvincible > 0 then players[i].currentinvincible -= 1 end
      if players[i].coffeepowerup > 0 then players[i].coffeepowerup -= 1 end
      if players[i].slowtimepowerup > 0 then players[i].slowtimepowerup -= 1 end
      if players[i].wingspowerup > 0 then players[i].wingspowerup -= 1 end
    end
  end
end

function playeraction(player, playerindex)

  -- get our current player number
  -- Our player speed
  local playernum, speed, maxspeedmultiplier, gravity = playerindex - 1, 1.05, 2.1, 0.375

  -- apply powerups/equpiment
  if player.coffeepowerup > 0 then
    speed += .5
  end
  if player.wingspowerup > 0 then gravity -= 1 end

  -- Player X movement
  if btn(0, playernum) and
    not iswallleft(player) and
    playerinputdelay <= 0 then
    player.moving = true
    -- Limit the dx
    if player.dx > abs(speed * maxspeedmultiplier) * -1 and gametime % 3 == 1 then player.dx -= speed end
    player.flipx = true
  elseif btn(1, playernum) and
    not iswallright(player) and
    playerinputdelay <= 0 then
    player.moving = true
    -- Limit the dx
    if player.dx < abs(speed * maxspeedmultiplier) and gametime % 3 == 1 then player.dx += speed end
    player.flipx = false
  else
    if abs(player.dx) < speed and gametime % 3 == 1 then
      player.dx = 0
    elseif player.dx < 0 and gametime % 3 == 1 then
      player.dx += speed
    elseif player.dx > 0 and gametime % 3 == 1 then
      player.dx -= speed
    end
    player.moving = false
  end

  -- Player Y movement
  if isgrounded(player) then
    -- Default grounded state
    player.dy, player.jumps, player.y = 0, 2, flr(flr(player.y) / 8) * 8

    -- Check if we just landed
    if not player.grounded then
      playermapbump()
      player.grounded = true
    end
  elseif isceiling(player) then
    -- Place below the ceiling
    player.dy = gravity
    player.y += 0.22
  else
    -- Increase gravity
    player.dy += gravity
    player.grounded = false
  end

  -- Check for jumping, must be before ceiling
  if ((btnp(5, playernum) or btnp(2, playernum)) and
    player.jumps > 0 and
    not isceiling(player)) and
    playerinputdelay <= 0 then
    playerjump(player)
  end

  -- Check for shooting
  if btnp(4, playernum) and
    playerinputdelay <= 0 then
    if player.flipx then
      spawnbullet(player.x - 5, player.y, true, false)
      player.dx += 0.25
    else
      spawnbullet(player.x + 5, player.y, false, false)
      player.dx -= 0.25
    end
    local bulletshake = count(players) * 2
    if count(bullets) > 0 and count(bullets) % bulletshake == 1 then
      screenshake(1, 2, 1)
    end
  end

  -- Check for attempting to revive other player
  if count(players) > 1 then
    for i = 1, count(players) do
      if i != playerindex and
      players[playerindex].health >= 2 and
      players[i].health <= 0 and
      iscollision(players[playerindex], players[i]) then
        -- Divide your health in half and give to other player
        local halfhealth = flr(players[playerindex].health / 2)
        players[playerindex].health -= halfhealth
        players[i].health = halfhealth
        players[i].invicibleframes = 120

        -- Play the hurt sound
        sfx(3)
      end
    end
  end

  -- check for walls
  if iswallleft(player) and player.dx < 0 then
    playermapbump()
    player.dx = 0
  end
  if iswallright(player) and player.dx > 0 then
    playermapbump()
    player.dx = 0
  end

  -- Apply our velocity (dx and dy)
  player.x += player.dx
  player.y += player.dy

  -- Don't allow to go outside the screen
  if player.x < 0 then player.x = 0 end
  if player.x > 120 then player.x = 120 end

  -- Ceiling support done with grounded
  if player.y > 120 then player.y = 120 end
end

-- Fucntion to reset all player powerups
function playerpowerreset()
  for player in all(players) do
    player.currentinvincible, player.coffeepowerup, player.slowtimepowerup, player.wingspowerup, player.bigbulletspowerup = 0, 0, 0, 0, 0
  end
end

-- Function called to jump the plyer
function playerjump(player)
  -- Play the jump sound
  sfx(0)
  -- Reset Dy if over 0
  if player.dy > 0 then player.dy = 0 end
  -- Add force depending on jumps
  player.dy -= 3.65
  player.jumps -= 1
end

-- Funtion called whenever the played bumps into something on the map
function playermapbump()
  screenshake(1.25, 5, 1)
  sfx(2)
end

-- function to return if all players have died
function allplayersdead()
  local numplayersdead = 0
  for player in all(players) do
    if flr(player.health) <= 0 then
      numplayersdead += 1
    end
  end

  if numplayersdead >= count(players) then
    return true
  else
    return false
  end
end

function playerdraw()

  for i = 1, count(players) do

    -- if we got hurt
    if players[i].currentinvincible > (players[i].invicibleframes - 10) then
      hurtpal()
    end

    spr(players[i].sprite, players[i].x, players[i].y, 1, 1, players[i].flipx)

    -- Reset our pallet
    pal()

    local numhearts = 5
    for k = 1, numhearts, 1 do
      -- Print their current hearts
      local heartcolor = 8
      if players[i].health > flr(players[i].maxhealth / 2) and
        k <= players[i].health - flr(players[i].maxhealth / 2) then
        heartcolor = 12
      end
      if k > players[i].health then
        heartcolor = 5
      end
      if i == 1 then
        print("\x87", 8 * k - 4, 2, heartcolor)
      else
        print("\x87", 8 * k - 4, 10, heartcolor)
      end
    end
  end
end
