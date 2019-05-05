class Timer
  attr_accessor :connection
  attr_accessor :time

  def initialize time=0
    @started_at = nil
    @fired_at = nil
    @time = time
  end

  def value= value
    case value
    when false
      stop
    when true
      start
    else
      self.time = value
    end
  end

  def value
    fired?
  end

  def fired?
    !!(@fired_at && (@fired_at <= Time.now))
  end


  private

  def start
    @started_at ||= Time.now
    @fired_at = @started_at + time;
  end

  def stop
    @started_at = nil
    @fired_at = nil
  end

end
