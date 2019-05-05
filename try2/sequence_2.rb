require './plc_base'
require './cylinder_sensor'
require './single_solenoid'

# Device assign
# X0: Cylinder moving switch
# X1: Cylinder returning switch
# X2: Cylinder sensor for moved
# X3: Cylinder sensor for returned
# Y0: Cylinder output
# M0: Cylinder state for moved
# M1: Cylinder state for returned
# M2: Cylinder error
# L0: Simulate cylinder sensors if it's true
setup do |plc|
  sol = SingleSolenoid.new out:plc.dev.y0
  plc.add_device sol:sol
  cyl_sen = CylinderSensor.new solenoid:sol, moved_sensor:plc.dev.x2, org_sensor:plc.dev.x3, timeout:3.0
  plc.add_device cyl_sen:cyl_sen
  # for simulation
  plc.add_device t_on:Timer.new(1)
  plc.add_device t_off:Timer.new(1)
  plc.l0 = true
end

sequence do |plc|
  plc.sol = (plc.x0 || plc.sol) && !plc.x1
  plc.m0 = plc.dev.cyl_sen.moved?
  plc.m1 = plc.dev.cyl_sen.returned?
  plc.m2 = plc.dev.cyl_sen.error?
  # for simulation
  if plc.l0 == true
    plc.t_on = plc.sol
    plc.t_off = !plc.sol
    plc.x2 = plc.t_on
    plc.x3 = plc.t_off
  end
end
