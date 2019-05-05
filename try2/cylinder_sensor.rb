require 'timer'

class CylinderSensor
  attr_accessor :connection
  attr_reader :org_sensor
  attr_reader :moved_sensor
  attr_reader :solenoid

  def initialize options={}
    @org_sensor = options[:org_sensor]
    @moved_sensor = options[:moved_sensor]
    @solenoid = options[:solenoid]
    @timer = Timer.new options[:timeout]
  end

  def moved?
    @solenoid.moved? && !connection[org_sensor.name] && connection[moved_sensor.name]
  end

  def returned?
    @solenoid.returned? && connection[org_sensor.name] && !connection[moved_sensor.name]
  end

  def error?
    @timer.value = !(moved? ^ returned?)
    @timer.value
  end

end
