require './plc_base'

sequence do |plc|
  plc.m0 = true
  plc.m1 = plc.m0
end
