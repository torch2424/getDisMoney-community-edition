-- Game time is used by random classes to do things
-- such as simple sprite animations that don't depend on a state
function timeinit()
  gametime, slowtime = 0, 0
end

function timeupdate()
  gametime += 1

  -- Get the current player slow time
  slowtime = 0
  for player in all(players) do
    if player.slowtimepowerup > slowtime then
      slowtime = player.slowtimepowerup
    end
  end

  if gametime >= PICO__MAX__NUMBER then
    timeinit()
  end
end
