-- Insertion sort of tables
-- http://www.lexaloffle.com/bbs/?tid=2477
-- true for least to greatest (ascending),
-- false for greatest to least (descending)
function sort(a, order)
  for i=1,#a do
  local j = i
    if order then
      while j > 1 and a[j-1] > a[j] do
        a[j], a[j-1], j = a[j-1], a[j], j - 1
      end
    else
      while j > 1 and a[j-1] < a[j] do
        a[j], a[j-1], j = a[j-1], a[j], j - 1
      end
    end
  end
end

-- ceil implementation
-- http://pico-8.wikia.com/wiki/Flr
function ceil(num)
  return flr(num+0x0.ffff)
end

-- Max pico 8 number: http://pico-8.wikia.com/wiki/Math
PICO__MAX__NUMBER = 32767
