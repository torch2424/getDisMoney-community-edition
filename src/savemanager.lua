-- Our cart save indexes
-- Schema v1
-- dset will return 0 if something does not exist
-- 0: total cash [number]

function saveinit()

  -- Set our cart data/ID (Required)
  -- http://pico-8.wikia.com/wiki/Cartdata
  -- Company_Game_SaveSchemaVersion
  -- it is done in the _init.lua

  -- load the game
  loadgame()
end

function savereset()
  totalcash, topspeeds, topcashruns = 0, {}, {}
end

function loadgame()
  --Reset our save
  savereset()

  -- Check if we have no game to load
  if not dget(0) or dget(0) == 0 then
    return false
  end

  -- load the totalcash
  if dget(0) then
    totalcash = dget(0)
    if totalcash < 0 or totalcash > PICO__MAX__NUMBER then totalcash = PICO__MAX__NUMBER end
  end
end

function saverun()
  -- Add the player cash to the total cash
  totalcash += gamestate__cash
  if totalcash < 0 or totalcash > PICO__MAX__NUMBER then totalcash = PICO__MAX__NUMBER end
  -- Save our total cash
  dset(0, totalcash)

  -- Finally reload the game
  loadgame()
end
