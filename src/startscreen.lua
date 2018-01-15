function startscreeninit()
  startstatedelay = 30

  -- Play the menu music
  playmusic(16)
end

function startscreenupdate()
  if startstatedelay < 0 then
    if btn(1) then
      gamestate__numplayers, gamestate__playstate, gamestate__startstate = 1, true, false
      resetplaystate()
    end

    if btn(0) then
      gamestate__storystate, gamestate__startstate = true, false
    end
  else
    startstatedelay -= 1
  end
end

function startscreendraw()
  print("get dis money", 40, 15, 11);
  print("community edition", 31, 25, 8);

  if gametime % 12 < 6 then
    spr(0, 62, 42)
  else
    spr(1, 62, 42)
  end

  -- Reset our pallet
  pal()

  print("\x8b story", 26, 62, 7);
  print("start \x91", 71, 62, 7);

  print ("total cash: $" .. totalcash, 35, 85, 11)

  print ("a game by aaron turner", 23, 95, 12)

  print ("get the full game at", 25, 105, 7)
  print ("https://getdismoney.com", 20, 115, 12)
end
