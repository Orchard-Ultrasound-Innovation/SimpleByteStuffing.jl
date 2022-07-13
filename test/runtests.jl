using SimpleByteStuffing
using Test

@testset "SimpleByteStuffing.jl" begin

    command = 0x01
    read_or_write = READ
    packet = create_packet(command, read_or_write)
    @test packet == [0xFC, 0x81, 0xfd, 0xFD]

    command = 0x05
    read_or_write = WRITE
    payload = [0x01, 0xFC, 0xAB]
    packet = create_packet(command, read_or_write, payload=payload)
    @test packet == [0xFC, 0x05, 0x01, 0xfe, 0xdc, 0xab, 0x52, 0xFD]

    command = 0x09
    read_or_write = READ
    payload = [0x12, 0x34, 0xFD, 0x56, 0xFE]
    packet = create_packet(command, read_or_write, payload=payload)
    @test packet == [0xFC, 0x89, 0x12, 0x34, 0xfe, 0xdd, 0x56, 0xfe, 0xde, 0x5e, 0xFD]

    ack_packet = [0xFC, 0x01, 0xFA, 0x04, 0xFD]
    data = parse_packet(ack_packet)
    @test data == []
    
    ack_packet = [0xFC, 0x07, 0xFA, 0x34, 0xAB, 0x1F, 0xFD]
    data = parse_packet(ack_packet)
    @test data == [0x34, 0xab]

    nak_packet = [0xFC, 0x07, 0xFB, 0x34, 0xFD]
    @test_throws ErrorException parse_packet(nak_packet)

    @test SimpleByteStuffing.verify_read_or_write(READ) == false
    @test SimpleByteStuffing.verify_read_or_write(WRITE) == false
    @test_throws ErrorException SimpleByteStuffing.verify_read_or_write(0xFF)

end
