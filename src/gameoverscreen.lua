function gameoverscreeninit()
  gameovertime = 30
end

function gameoverscreenshow()
  --Flip state booleans
  gamestate__playstate = false
  gamestate__gameoverstate = true

  -- Play the gameover sound
  if not gamestate__gameoverstategood then
    sfx(7)
  end

  -- reset the player
  playerpowerreset()

  --Stop all music
  playmusic(-1)

  -- Reset the gameovertime
  gameovertime = 32

  -- save the game
  saverun()
end

function gameoverscreenupdate()
  if gameovertime < 0 then
    if btn(4) or btn(5) then
      gamestate__playstate, gamestate__gameoverstate, gamestate__gameoverstategood, gamestate__cash, gamestate__rollingcash, gamestate__runframes, gameovertime = true, false, false, 0, 0, 0, 45

      -- init play state, and the map
      resetplaystate()
    elseif btn(3) then
      -- Return to the start screen
      stateinit()
      camerainit()
      mapinit()
      startscreeninit()
      storyscreendraw()
      gameoverscreeninit()
      playerinit()
      levelcarinit()
    end
  else
    gameovertime -= 1

    -- Play the game over music if gameover time it zero
    if gameovertime <= 0 and not gamestate__gameoverstategood then
      playmusic(12)
    end
  end
end

function gameoverscreendraw()
  rectfill(10,
    25,
    115,
    90,
    0
  )
  if gamestate__gameoverstategood then
    print("\x87 thanks for playing! \x87", 15, 30, 14)
  else
    print("game over", 50, 30, 8)
  end
  print("cash collected: $" .. gamestate__rollingcash, 25, 40, 11)
  if loops <= 0 then
    if not gamestate__gameoverstategood then
      print("last level: " .. (getcurrentlevel() - (loops * 12)), 38, 50, 7)
    end
  else
    print("loop " .. loops .. ", level " .. (getcurrentlevel() - (loops * 12)), 34, 50, 7)
  end
  print("press \x8E to get dis money", 15, 70, 7);
  print("press \x83 to go to start", 19, 80, 7);
end
