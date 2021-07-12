"""
# PiAVRDude.jl

AVRDude interface for Raspberry Pi GPIO ISP.
"""
module PiAVRDude

export AVRDude

using UnixIO

struct AVRDude

    name::String
    device::String
    config::String
    usb_port::Union{Nothing, String}

    function AVRDude(;device=nothing,
                      sck=nothing, miso=nothing, mosi=nothing, reset=nothing,
                      usb_port=nothing)
        if usb_port != nothing
            new("avrisp2", device, """
                default_safemode = no;
                """,
                usb_port)
        else
            name = "gpio$reset"
            new(name, device, """
                default_safemode = no;
                programmer
                  id    = "$name";
                  desc  = "GPIO ISP";
                  type  = "linuxgpio";
                  sck   = $sck;
                  miso  = $miso;
                  mosi  = $mosi;
                  reset = $reset;
                ;
                """,
                nothing)
        end
    end
end


config(isp) = isp.config


function avrdude(isp, cmd)
    mktempdir() do d
        conf=joinpath(d, "avrdude.conf")
        write(conf, config(isp))
        options = `-p $(isp.device) -C +$conf -c $(isp.name)`
        if isp.usb_port != nothing
            options = `$options -D -P $(isp.usb_port)`
        end
        cmd = `avrdude $options $cmd`
        @info cmd
        UnixIO.system(cmd)
    end
end

status(isp) = avrdude(isp, `-v`)

flash_hex(isp, file) = avrdude(isp, `-U flash:w:$file:i`)
flash_elf(isp, file) = avrdude(isp, `-U flash:w:$file:e`)
eeprom_hex(isp, file) = avrdude(isp, `-U eeprom:w:$file:i`)
eeprom_elf(isp, file) = avrdude(isp, `-U eeprom:w:$file:e`)
flash(i, f) = endswith(f, ".elf") ? flash_elf(i, f) : flash_hex(i, f)
eeprom(i, f) = endswith(f, ".elf") ? eeprom_elf(i, f) : eeprom_hex(i, f)

read(isp, type, file) = avrdude(isp, `-U $type:r:$file:i`)

fuse(isp, fuse) = avrdude(isp, `-U $fuse`)



end # module
