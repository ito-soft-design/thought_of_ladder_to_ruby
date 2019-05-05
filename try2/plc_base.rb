require 'benchmark'
require 'ladder_drive'
require 'yaml'

class PlcBase

  attr_reader :connection

  class << self

    def config
      @config ||= begin
        dir = File.expand_path File.dirname(__FILE__)
        path = File.join(dir, "config", "connection.yml")
        YAML.load(File.read(path))["plc"]
      end
    end

    def default_connection
      @default_connection ||= begin
        case self.config["protocol"]
        when 'mc_protocol'
          LadderDrive::Protocol::Mitsubishi::McProtocol.new host:config["host"], port:config["port"]
        else
          nil
        end
      end
    end

    def default
      @default ||= self.new self.default_connection
    end

  end

  class DevicePicker

    attr_reader :connection

    def initialize connection
      @connection = connection
      @dev_dict = {}
    end

    def method_missing(symbol, *args)
      name = symbol.to_s
      if args.size == 0
        return @dev_dict[name] if @dev_dict[name]
        d = connection.device_by_name name
        if d
          d = replace_device d
          @dev_dict[name] = d
          return d
        end
      end
      return super
    end

    def add_device options={}
      options.each do |key, dev|
        dev.connection = self.connection
        @dev_dict[key.to_s] = dev
      end
    end

    private

    def replace_device d
      case d.suffix
      when "X"
        d = connection.device_by_name "B#{d.number.to_s(16)}" if (0...0x1000).include? d.number
      when "Y"
        d = connection.device_by_name "B#{(d.number + 0x1000).to_s(16)}" if (0...0x1000).include? d.number
      end
      d
    end

  end
  private_constant :DevicePicker


  def initialize connection
    @connection = connection
    @mutex = Mutex.new
  end

  def device
    @device ||= DevicePicker.new(self.connection)
  end
  alias :dev :device

  def method_missing(symbol, *args)
    name = symbol.to_s
    if args.size == 0
      d = device.send name
      case d
      when PlcDevice
        return connection[d.name]
      else
        return d.value
      end
    elsif args.size == 1 && /(.*)=$/ =~ name
      name = $1
      d = device.send name
      v = args.first
      case d
      when PlcDevice
        connection[d.name] = v
        return v
      else
        d.value = v
        return v
      end
    end
    return super
  end

  def setup
    yield(self) if block_given?
  end

  def sequence
    loop do
      Benchmark.bm do |x|
        x.report {
          yield(self) if block_given?
        }
      end
      print "\e[2A"
    end
  end

  def add_device options={}
    device.add_device options
  end

end

def setup plc=nil, &proc
  plc ||= PlcBase.default
  plc.setup &proc
end

def sequence plc=nil, &proc
  plc ||= PlcBase.default
  plc.sequence &proc
end
