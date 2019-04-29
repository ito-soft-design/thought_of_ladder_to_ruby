require './plc_base'

sequence do |plc|
  plc.y0 = plc.x0
  plc.y1 = (plc.x1 || plc.y1) && !plc.x2
end
