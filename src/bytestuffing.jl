const ACK = 0xFA
const NAK = 0xFB
const SOP = 0xFC
const EOP = 0xFD
const ESC = 0xFE

const FLAG = [SOP, EOP, ESC]

function create_packet(command::UInt8, read_or_write; payload::Vector{UInt8}=UInt8[])
    verify_read_or_write(read_or_write)
    packet = []
    push!(packet, SOP)
    push!(packet, command | (read_or_write<<7) )
    !isempty(payload) && append!(packet, get_byte_stuffed_payload(payload))
    data = combine(command, read_or_write, payload)
    push!(packet, get_checksum(data))
    push!(packet, EOP)
    return convert(Vector{UInt8}, packet)
end

verify_read_or_write(read_or_write) = !(read_or_write in [READ,WRITE]) && error("read_or_write must be of value READ or WRITE.")

function combine(command, read_or_write, payload)
    data = [command, read_or_write]
    !isempty(payload) && append!(data, payload)
    return convert(Vector{UInt8}, data)
end

function get_byte_stuffed_payload(payload::Vector{UInt8})

    bs_payload = []
    for i in payload
        if i in FLAG
            push!(bs_payload, ESC)
            push!(bs_payload, xor(i,0x20))
        else
            push!(bs_payload, i)
        end
    end

    return bs_payload
end

function parse_packet(packet)
    
    sop = findfirst(x->x==SOP, packet)
    verify_sop(sop)

    ack = packet[sop+2]
    verify_ack(ack)

    eop = findfirst(x->x==EOP, packet)
    verify_eop(eop)

    data = packet[sop+1 : eop-2]
    destuffed = destuff_data(data)
    crc = get_checksum(data)
    verify_checksum( packet[eop-1], crc)
    
    return destuffed[3:end]
end

verify_sop(sop) = isempty(sop) && error("Packet is invalid! Start-of-packet not found.")
verify_ack(ack) = (ack != ACK) && error("Packet is invalid! ACK not found.")
verify_eop(eop) = isempty(eop) && error("Packet is invalid! End-of-packet not found.")
verify_checksum(sum1, sum2) = (sum1 != sum2) && error("Packet is invalid! CRC: does not match.")

function destuff_data(bs_data)

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
