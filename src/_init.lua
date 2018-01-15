function _init()
  -- Iniitalize our cart data for saving
  cartdata("nocomplygames_letsgetdismoney_community_edition_v1")

  -- Init the game time
  timeinit()

  -- Game Init
  stateinit()
  camerainit()
  mapinit()

  -- debuginit
  debuginit()

  startscreeninit()
  gameoverscreeninit()
  playerinit()
  levelcarinit()
  saveinit()

  -- Object init (Handled by other objects, statemanager.resetplaystate())
  -- playerinit()
  -- bulletinit()
  -- enemyinit()
  -- collectableinit()
end
