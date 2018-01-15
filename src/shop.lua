function shopinit()
  browseindex, browsedelay = 1, 0
end

function resetbrowsedelay()
  browsedelay = 5
end

function shopupdate()

  --Decrease our browsedelay
  if browsedelay > 0 then browsedelay -= 1 end

  -- Every frame update our unlockble sprite
  if gametime % 6 == 0 then
    for unlock in all(gameunlockables) do
      if unlock.spriteindex + 1 > count(unlock.sprites) then
        unlock.spriteindex = 1
      else
        unlock.spriteindex += 1
      end
    end
  end

  -- go back to start
  if btn(2) then
    startstatedelay, gamestate__startstate, gamestate__shopstate = 60, true, false
  end

  -- previous
  if btn(0) and browsedelay <= 0 then
    if browseindex > 1 then
      browseindex -= 1
    end

    -- Set our browse delay
    resetbrowsedelay()
  end

  -- next
  if btn(1) and browsedelay <= 0 then
    if browseindex < count(gameunlockables) then
      browseindex += 1
    end

    -- Set our browse delay
    resetbrowsedelay()
  end

  -- buy the item, or equip it
  if (btn(4) or btn(5)) and browsedelay <= 0 then
    if not gameunlockables[browseindex].purchased and
      totalcash > gameunlockables[browseindex].price then
      -- Buy/equip the item
      totalcash -= gameunlockables[browseindex].price
      gameunlockables[browseindex].purchased = true
      equipunlock(browseindex)
      savepurchase()
    elseif not gameunlockables[browseindex].equipped and
      gameunlockables[browseindex].purchased then
      -- equip the item
      equipunlock(browseindex)
      savepurchase()
    else
      -- Play a bad sound
      sfx(50)
    end

    -- Set our browse delay
    resetbrowsedelay()
  end
end

function equipunlock(index)
  -- set og deanbad to unequipped
  gameunlockables[1].equipped = false
  for i = 1, count(gameunlockables) do
    if i == index then
      gameunlockables[i].equipped = true
    else
      gameunlockables[i].equipped = false
    end
  end
end

function shopdraw()

  --Get our unlockable
  -- Show the price (Or Purchased)
  local unlock, pricey, pricecolor = gameunlockables[browseindex], 30, 11

  -- Show the title
  print(unlock.title.text, unlock.title.x, 20, 10)
  if unlock.equipped then
    print("equipped", 48, pricey, 12)
  elseif unlock.purchased then
    print("purchased", 48, pricey, pricecolor)
  else
    if unlock.price > totalcash then pricecolor = 8 end
    print("cost: $" .. unlock.price, 40, pricey, pricecolor)
  end

  -- Show the item (silouhette if not purchased)
  if unlock.purchased then

    -- Apply conditional colors to our unlocks
    if browseindex == 2 then
      keboppal()
    end
    if browseindex == 3 then
      bunterpal()
    end
  else
    -- Silohuette
    for i = 0, 15 do
      pal(i, 5)
    end
  end
  -- print the sprite
  local spritey = 45
  spr(unlock.sprites[unlock.spriteindex], 60, spritey)
  --Reset our pallet
  pal()

  -- description
  print(unlock.descriptionlineone.text, unlock.descriptionlineone.x, 60, 7)
  print(unlock.descriptionlinetwo.text, unlock.descriptionlinetwo.x, 70, 7)

  -- Previous or next items
  if browseindex > 1 then
    print("\x8B previous", 10, 85, 7);
  else
    print("\x8B previous", 10, 85, 5);
  end
  if browseindex < count(gameunlockables) then
    print("next \x91", 95, 85, 7);
  else
    print("next \x91", 95, 85, 5);
  end

  --Show the total cash
  print("total money: $" .. totalcash, 30, 95, 11)

  -- X to exit
  print("press \x94 to go back to start", 8, 115, 7)
end
