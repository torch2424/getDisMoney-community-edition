function storyscreenupdate()
  if btn(4) or btn(5) or btn(1) then
    startstatedelay, gamestate__startstate, gamestate__storystate = 30, true, false
  end
end

function storyscreendraw()
  -- cls() to not show the stars
  print("og deanbad is a gangsta,", 10, 2, 12)
  print("in space.", 10, 12, 7)
  print("in the year 3030,", 10, 22, 10)
  print("gangstas get paid.", 10, 32, 7)
  print("alien bounties", 10, 42, 8)
  print("is the new hustle,", 10, 52, 7)
  print("let's", 10, 62, 7)
  print("get dis money", 35, 62, 11)

  print("press \x91 to go back to start", 8, 110, 7)
end
