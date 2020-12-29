"""
# PiAVRDude.jl

AVRDude interface for Raspberry Pi GPIO ISP.
"""
module PiAVRDude

struct AVRDude
    name::String
    config::String
    function AVRDude(name;
                     sck=nothing, miso=nothing, mosi=nothing, reset=nothing)
        new(name, """
            programmer
              id    = "$name";
              desc  = "GPIO ISP";
              type  = "linuxgpio";
              sck   = $sck;
              miso  = $miso;
              mosi  = $mosi;
              reset = $reset;
            ;
            """)
    end
end

config(isp) = isp.config


end # module
