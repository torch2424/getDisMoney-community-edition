function _draw()
  -- Clear the screen
  cls()

  -- Map should have lowest priority drawing
  mapdraw()

  if gamestate__startstate then
    startscreendraw()
  end

  if gamestate__storystate then
    storyscreendraw()
  end

  if gamestate__gameoverstate then
    enemydraw()
    collectabledraw()
    playerdraw()
    if gameovertime <= 0 then
      gameoverscreendraw()
    end
  end

  if gamestate__playstate then
    -- Call our objects functions (the order or drawing will dictate layers)
    enemydraw()
    collectabledraw()
    bulletdraw()
    playerdraw()
    levelcardraw()
  end

  -- Game specific drawing
  statedraw()
  cameradraw()
  debugdraw()
end
