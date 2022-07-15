const READ = 0x01
const WRITE = 0x00
const ACK = 0xFA
const NAK = 0xFB
const SOP = 0xFC
const EOP = 0xFD
const ESC = 0xFE

const FLAG = [SOP, EOP, ESC]

function create_packet(command::UInt8, read_or_write; payload::Vector{UInt8}=UInt8[])
    verify_read_or_write(read_or_write)
    packet = combine_and_stuff(command, read_or_write, payload)
    pushfirst!(packet, SOP)
    push!(packet, EOP)
    return convert(Vector{UInt8},packet)
end

verify_read_or_write(read_or_write) = !(read_or_write in [READ,WRITE]) && error("read_or_write must be of value READ or WRITE.")

function combine_and_stuff(command, read_or_write, payload)
    packet = []
    push!(packet, command | (read_or_write<<7) )
    append!(packet, payload)
    checksum = get_checksum(packet)
    push!(packet, checksum)
    packet = byte_stuff(convert(Vector{UInt8},packet))
end

function byte_stuff(data::Vector{UInt8})
    bs_data = []
    for i in data
        if i in FLAG
            push!(bs_data, ESC)
            push!(bs_data, xor(i,0x20))
        else
            push!(bs_data, i)
        end
    end

    return bs_data
end

function parse_packet(packet)
    
    destuffed = destuff_packet(packet)

    sop = findfirst(x->x==SOP, destuffed)
    verify_sop(sop)

    ack = destuffed[sop+2]
    verify_ack(ack)

    eop = findfirst(x->x==EOP, destuffed)
    verify_eop(eop)

    data = destuffed[sop+1 : eop-2]
    crc = get_checksum(data)
    verify_checksum( destuffed[eop-1], crc)
    
    
    @info convert(Vector{UInt8},destuffed[sop+2:end-2])
    return convert(Vector{UInt8},destuffed[sop+2:end-2])
end

verify_sop(sop) = isempty(sop) && error("Packet is invalid! Start-of-packet not found.")
verify_ack(ack) = (ack != ACK) && error("Packet is invalid! ACK not found.")
verify_eop(eop) = isempty(eop) && error("Packet is invalid! End-of-packet not found.")
verify_checksum(sum1, sum2) = (sum1 != sum2) && error("Packet is invalid! CRC: does not match.")

function destuff_packet(bs_data)

    len = length(bs_data)
    i = 1
    data = []

    while(i <= len)
        if bs_data[i] == ESC
            i = i+1
            push!(data, xor( bs_data[i] ,0x20))
        else
            push!(data, bs_data[i])
        end

        i = i + 1
    end    

    return data

end

function get_checksum(data)
    checksum = sum(data)
    checksum = UInt8( checksum%256 )
    checksum = ~checksum
    return UInt8(checksum)
end