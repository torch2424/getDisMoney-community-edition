function stateinit()
  -- states, would be in an object, but token limit :(
  gamestate__numplayers, gamestate__cash, gamestate__runframes, gamestate__runseconds, gamestate__runminutes, gamestate__rollingcash, gamestate__startstate, gamestate__playstate, gamestate__storystate, gamestate__numplayersstate, gamestate__statsstate, gamestate__shopstate, gamestate__finalbossstart, gamestate__finalbossend, gamestate__gameoverstate, gamestate__gameoverstategood, gamestate__canloop = 1, 0, 0, 0, 0, 0, true, false, false, false, false, false, false, false, false, false, false

  runspeedsaved, nextleveldelay, maxlevels, loops = false, 0, 12, 0
end

function stateupdate()
  if gamestate__playstate and not gamestate__canloop then
    if gamestate__runframes >= 60 then
      if gamestate__runseconds >= 60 then
        gamestate__runminutes += 1
        gamestate__runseconds = 0
      end
      gamestate__runseconds += 1
      gamestate__runframes = 0
    end
    gamestate__runframes += 1
  end

  -- Check if our current rolling cash is less than our current cash,
  -- And adding some dealy to our rolling cash
  if gamestate__rollingcash < gamestate__cash and gametime % 2 == 0 then
    gamestate__rollingcash += 1
  elseif gamestate__rollingcash >= gamestate__cash then
    gamestate__rollingcash = gamestate__cash
  end

  --Also, check for a delayed go to next level
  if nextleveldelay > 1 then nextleveldelay -= 1 end
  if nextleveldelay == 1 then
    if isfinalboss() then
      spawnendlevelcars()
    else
      spawnlevelcar()
    end
    nextleveldelay -= 1
  end
end

function statedraw()
  if gamestate__playstate then
    print("$" .. gamestate__rollingcash, 56, 2, 11)
  end
end

function resetplaystate()
  mapinit()
  debuginit()
  playerinit()
  bulletinit()
  enemyinit()
  collectableinit()

  runspeedsaved, gamestate__runframes, gamestate__runseconds, gamestate__runminutes, gamestate__canloop = false, 0, 0, 0, false

  playmusic(0)
end

-- Function to play music for each state
-- Can pass -1 to play nothing
function playmusic(track)
  --Stop all music
  music(-1)
  --Play the passed track
  music(track)
end

function getcurrentlevel()
  local currentlevel = currentmap__x + (currentmap__y * 4)
  -- If we are on a special level, else we are on a normal one
  if currentmap__y > 2 then
    currentlevel = flr(currentlevel / 3) + (currentmap__x * 2)
    if currentlevel % 4 == 0 then currentlevel -= 1 end
  end
  -- Add one to our level to account for index
  currentlevel += 1

  -- Check for loops
  currentlevel = currentlevel + (loops * maxlevels)
  return currentlevel
end

function getcurrentlevelwithoutloops()
  local currentlevel = getcurrentlevel()
  if getcurrentlevel() > maxlevels then
    currentlevel = getcurrentlevel() - (loops * maxlevels)
  end
  return currentlevel
end

function delaygotonextlevel(delay)
  nextleveldelay = delay
end

function gotonextlevel()

  -- Change the map and reset some things
  if (currentmap__x + 1) % 4 == 0 then
    currentmap__x = 0;
    currentmap__y += 1

    -- Check which world song to play
    if currentmap__y == 1 then
      playmusic(25)
    elseif currentmap__y == 2 then
      playmusic(29)
    end
  else
    currentmap__x += 1

    -- Check if we are on a boss level
    if currentmap__x == 3 then
      -- Check if we are at a normal or final boss
      if currentmap__y < 2 then
        playmusic(17)
      else
        playmusic(50)
        gamestate__finalbossstart = true
      end
    end
  end

  playerpowerreset()
  levelcarinit()
  enemyinit()
  collectableinit()

  -- Set the players back onto the map
  resetplayerlocation()
end
