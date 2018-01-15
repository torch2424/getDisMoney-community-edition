function mapinit()
  bgstars = {}
  for i = 1, 128 do
    add(bgstars, {
      x = flr(rnd(128)),
      y = flr(rnd(128)),
      color = flr(rnd(3)),
      dx = rnd(1.05) * -1
    })
  end

  -- X is the x tile of the map, Y is the map tile of the map,
  -- xspread is the distance to multiply by x to get the next map,
  -- yspread is the y distance to multiply by y to get the next map
  currentmap__x, currentmap__y, currentmap__xspread, currentmap__yspread = 0, 0, 32, 16
end

function mapupdate()
  -- Update our stars
  for star in all(bgstars) do
    if gamestate__finalbossstart then
      if gametime % 10 == 0 then
        star.x += star.dx
      end
    else
      star.x += star.dx
    end
    if star.x < 0 then star.x = 128 end
  end
end

function mapdraw()
  --Draw our stars
  for star in all(bgstars) do
    if star.color == 0 then
      pset(star.x, star.y, 5)
    elseif star.color == 1 then
      pset(star.x, star.y, 13)
    else
      pset(star.x, star.y, 6)
    end
  end

  -- Draw the map
  if gamestate__playstate or gamestate__gameoverstate then
    -- * 32 for how our map is laid out
    map(currentmap__x * currentmap__xspread, currentmap__y * currentmap__yspread, 0, 0, currentmap__yspread, currentmap__xspread)
  end
end

-- Player physics:
-- https://www.reddit.com/r/pico8/comments/4w6jwk/any_good_resources_for_2d_game_physics/
-- Helper function to apply map and get collision status
function getrelativemaplocation(xyobject, xrelative, yrelative)
  -- Get the current map tile

  -- flr() floors the number
  -- Since 1 tile on the map is 8 pixels, / 8

  -- + the current player location in terms of map tiles
  --     (/8 since they are 8x8 pixels in a 1x1 map tile)
  --      (Multiple the size of the pixels e.g 8x8 by the width and heigh)
  -- + the relative amount we are looking for

  --Support for width and height
  -- Only apply width and height, when checking positive positions
  -- As width and height increases from top left corener :)
  if xrelative > 0 then xrelative += xyobject.width - 1 end
  if yrelative > 0 then yrelative += xyobject.height - 1 end

  return mget((currentmap__x * currentmap__xspread) + (flr(xyobject.x + 4) / 8) + xrelative,
      (currentmap__y * currentmap__yspread) + (flr(xyobject.y) / 8) + yrelative)
end

-- isGrounded
function isgrounded(xyobject)
  -- Check the sprite flag (in sprite editor) on the player
  return fget(getrelativemaplocation(xyobject, 0, 1), 0)
end

-- isCeiling
function isceiling(xyobject)
  -- Check the sprite flag (in sprite editor) on the player
  return fget(getrelativemaplocation(xyobject, 0, - 0.15), 0)
end

-- Walls
function iswallleft(xyobject)
  -- Check the sprite flag (in sprite editor) on the player
  return fget(getrelativemaplocation(xyobject, -0.5, 0), 0)
end

function iswallright(xyobject)
  -- Check the sprite flag (in sprite editor) on the player
  return fget(getrelativemaplocation(xyobject, 0.5, 0), 0)
end
