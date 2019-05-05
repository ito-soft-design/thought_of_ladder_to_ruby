class SingleSolenoid
  attr_accessor :connection

  def initialize options={}
    @out = options[:out]
  end

  def value= value
    case value
    when false, true
      connection[@out.name] = value
    end
  end

  def value
    connection[@out.name]
  end

  def moved?
    value
  end

  def returned?
    !moved?
  end

end
