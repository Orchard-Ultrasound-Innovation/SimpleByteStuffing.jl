using SimpleByteStuffing
using Test

@testset "SimpleByteStuffing.jl" begin

    command = 0x01
    read_or_write = WRITE
    packet = create_packet(command, read_or_write)
    @test packet == [0xfc, 0x01, 0xfe, 0xde, 0xfd]

    command = 0x05
    read_or_write = WRITE
    payload = [0x01, 0xFC, 0xAB]
    packet = create_packet(command, read_or_write, payload=payload)
    @test packet == [0xFC, 0x05, 0x01, 0xfe, 0xdc, 0xab, 0x52, 0xfd]

    command = 0x09
    read_or_write = READ
    payload = [0x12, 0x34, 0xFD, 0x56, 0xFE]
    packet = create_packet(command, read_or_write, payload=payload)
    @test packet == [0xfc, 0x89, 0x12, 0x34, 0xfe, 0xdd, 0x56, 0xfe, 0xde, 0xdf, 0xfd]

    ack_packet = [0xfc, 0x01, 0xfa, 0x04, 0xfd]
    data = parse_packet(ack_packet)
    @test data == [0xfa]
    
    ack_packet = [0xfc, 0x07, 0xfa, 0xfe, 0x34, 0xea, 0xfd]
    data = parse_packet(ack_packet)
    @test data == [0xfa, 0x14]

    nak_packet = [0xfc, 0x07, 0xFB, 0x34, 0xfd]
    @test_throws ErrorException parse_packet(nak_packet)

    @test SimpleByteStuffing.verify_read_or_write(READ) == false
    @test SimpleByteStuffing.verify_read_or_write(WRITE) == false
    @test_throws ErrorException SimpleByteStuffing.verify_read_or_write(0xFF)

end
