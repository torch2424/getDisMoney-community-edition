
-- Collision boxes defined as box = {xleft, xright, yup, ydown}
--                             yup
--                      ------------------
--                      -                -
--             xleft    -                -   xright
--                      -                -
--                      ------------------
--                            ydown
--

function getbox(boxobject)
  -- boxshift to help center the box on normal 8x8 sprites
  local boxshift = 2
  local finalbox = {
    xright = boxobject.x + boxobject.box.xright + boxshift,
    xleft = boxobject.x - boxobject.box.xleft + boxshift,
    yup = boxobject.y - boxobject.box.yup + boxshift,
    ydown = boxobject.y + boxobject.box.ydown + boxshift
  }
  return finalbox
end

function iscollision(aobject, bobject)
  -- find our boxes
  local abox = getbox(aobject)
  local bbox = getbox(bobject)

  -- find if we are NOT colliding for ease and readability
  if abox.xleft > bbox.xright or
    bbox.xleft > abox.xright or
    abox.yup > bbox.ydown or
    bbox.yup > abox.ydown then
    return false
  end

  -- We are colliding
  return true
end
