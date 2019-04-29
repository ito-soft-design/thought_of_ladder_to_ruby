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


  def initialize connection
    @connection = connection
    @mutex = Mutex.new
  end

  def method_missing(symbol, *args)
    name = symbol.to_s
    if args.size == 0
      @mutex.synchronize {
        d = connection.device_by_name name
        d = replace_device d
        return connection[d.name] if d
      }
    elsif args.size == 1 && /(.*)=$/ =~ name
      name = $1
      @mutex.synchronize {
        d = connection.device_by_name name
        d = replace_device d
        v = args.first
        connection[d.name] = v
        return v
      }
    end
    return super
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

def sequence plc=nil, &proc
  plc ||= PlcBase.default
  plc.sequence &proc
end
