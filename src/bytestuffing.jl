const SOP = 0xFC
const EOP = 0xFD
const ESC = 0xFE

const FLAG = [SOP, EOP, ESC]

function get_frame(command::UInt8, read_or_write::UInt8; payload=[])
    frame = []
    push!(frame, SOP)
    push!(frame, command)
    verify_read_or_write(read_or_write)
    push!(frame, read_or_write)
    !isempty(payload) && append!(frame, get_byte_stuffed_payload(payload) )
    push!(frame, get_checksum(command, read_or_write, payload))
    push!(frame, EOP)
    return convert(Vector{UInt8}, frame)
end

verify_read_or_write(read_or_write) = !(read_or_write in [READ,WRITE]) && error("read_or_write must be of value READ:0x00 or WRITE:0x01.")

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

function get_checksum(command, read_or_write, payload)
    checksum = [command, read_or_write]
    !isempty(payload) && append!(checksum, payload)
    checksum = convert(Vector{UInt8}, checksum)
    checksum = sum(checksum)
    checksum = UInt8( checksum%256 )
    checksum = ~checksum
    return checksum
end