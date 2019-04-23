require 'ladder_drive'

class PlcBase

  attr_reader :plc

  def initialize
    @plc = LadderDrive::Protocol::Mitsubishi::McProtocol.new host:"localhost"
  end

    def method_missing(symbol, *args)
      name = symbol.to_s
      if args.size == 0
        d = plc.device_by_name name
        return plc[d.name] if d
      elsif args.size == 1 && /(.*)=$/ =~ name
        name = $1
        d = plc.device_by_name name
        v = args.first
        plc[d.name] = v
        return v
      end
      return super
    end

end


PlcBase.new.plc['m0']
