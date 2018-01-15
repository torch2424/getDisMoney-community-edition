-- nasty code because of token limit
function camerainit()
  gamecamera__x, gamecamera__y, gamecamera__shakeamount, gamecamera__shakeuntil, gamecamera__shakerate, gamecamera__currentshakerate = -128, 0, 0, 0, 0, 0
end

function screenshake(amount, when, shakerate)
  gamecamera__shakeamount, gamecamera__shakeuntil, gamecamera__shakerate = amount, when, shakerate
end

function cameraupdate()
  -- Update vairables
  gamecamera__currentshakerate -= 1
  if gamecamera__shakeuntil > 0 then gamecamera__shakeuntil -= 1 end

  if gamecamera__currentshakerate < 0 and
    gamecamera__shakeuntil > 0 then
    gamecamera__currentshakerate = gamecamera__shakerate
    if gamecamera__x > 0 then
      gamecamera__x, gamecamera__y = 0, gamecamera__shakeamount
    else
      gamecamera__y, gamecamera__x = 0, gamecamera__shakeamount
    end
  else
    gamecamera__x, gamecamera__y = 0, 0
  end
end

function cameradraw()
  -- Set the camera location
  camera(gamecamera__x, gamecamera__y)
end
