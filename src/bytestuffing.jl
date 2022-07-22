const SOP = 0xFC
const EOP = 0xFD
const ESC = 0xFE

const FLAGS = [SOP, EOP, ESC]

function create_packet(command::UInt8, read_or_write::String; payload::Vector{UInt8}=UInt8[])
    verify_read_or_write(read_or_write)
    packet = byte_stuff(command, read_or_write, payload)
    pushfirst!(packet, SOP)
    push!(packet, EOP)
    return packet
end

verify_read_or_write(read_or_write::String) = !(read_or_write in ["READ", "WRITE"]) && error("read_or_write must be of value \"READ\" or \"WRITE\".")

function byte_stuff(command::UInt8, read_or_write::String, payload::Vector{UInt8})
    frame = UInt8[]
    push!(frame, combine(command, read_or_write))
    append!(frame, payload)
    push!(frame, checksum(frame))
    return _byte_stuff(frame)
end

function combine(command::UInt8, read_or_write::String)
    if(read_or_write === "WRITE") 
        rw = 0x00
    else
        rw = 0x80
    end
    return command | rw
end

function checksum(data::Vector{UInt8})
    checksum = sum(data)
    checksum = UInt8(checksum%256)
    return ~checksum
end

function _byte_stuff(data::Vector{UInt8})
    bs_data = UInt8[]
    for byte in data
        if byte in FLAGS
            push!(bs_data, ESC)
            push!(bs_data, xor(byte, 0x20))
        else
            push!(bs_data, byte)
        end
    end

    return bs_data
end

function parse_packet(packet::Vector{UInt8})
    destuffed = destuff_packet(packet)
    verify_sop(destuffed[1])
    verify_eop(destuffed[end])
    data = destuffed[2:end-2]
    verify_checksum(destuffed[end-1], checksum(data))
    return destuffed[3:end-2]
end

function destuff_packet(bs_data::Vector{UInt8})
    len = length(bs_data)
    byte_idx = 1
    data = UInt8[]

    while(byte_idx <= len)
        if bs_data[byte_idx] == ESC
            byte_idx += 1
            push!(data, xor(bs_data[byte_idx], 0x20))
        else
            push!(data, bs_data[byte_idx])
        end
        byte_idx += 1
    end    

    return data
end

verify_sop(sop) = isempty(sop) && error("Packet is invalid! Start-of-packet not found.")
verify_eop(eop) = isempty(eop) && error("Packet is invalid! End-of-packet not found.")
verify_checksum(sum1, sum2) = (sum1 != sum2) && error("Packet is invalid! Checksum does not match.")
