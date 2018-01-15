function _update()
  -- time reset is handled by timemanager.lua

  -- Call our game management
  timeupdate()
  stateupdate()

  if slowtime > 0 and
    gametime % 2 < 1 then
    cameraupdate()
    mapupdate()
  elseif slowtime <= 0 then
    cameraupdate()
    mapupdate()
  end

  if gamestate__playstate then
    -- Call our object functions
    playerupdate()
    bulletupdate()
    levelcarupdate()

    if slowtime > 0 and gametime % 4 < 2 then
      enemyupdate()
      collectableupdate()
    elseif slowtime <= 0 then
      enemyupdate()
      collectableupdate()
    end
  end

  if gamestate__gameoverstate then

    -- Slow down the game with gameovertime
    if gameovertime > 0 and gametime % 4 < 1 then
      -- Slow down
      enemyupdate()
      collectableupdate()
      playerupdate()
      gameoverscreenupdate()
    elseif gameovertime <= 0 then
      -- Normal time
      enemyupdate()
      collectableupdate()
      playerupdate()
      gameoverscreenupdate()
    end
  end

  -- Placing down here, to end button presses in the update
  if gamestate__startstate then
    startscreenupdate()
  end

  if gamestate__storystate then
    storyscreenupdate()
  end
end
