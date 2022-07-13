using SimpleByteStuffing
using Test

@testset "SimpleByteStuffing.jl" begin

    command = 0x01
    read_or_write = READ
    payload = []
    @test get_frame(command, read_or_write, payload=payload) ==
    [0xfc, 0x01, 0x00, 0xfe, 0xfd]

    command = 0x05
    read_or_write = WRITE
    payload = [0x01, 0xFC, 0xAB]
    @test get_frame(command, read_or_write, payload=payload) ==
    [0xfc, 0x05, 0x01, 0x01, 0xfe, 0xdc, 0xab, 0x51, 0xfd]

    command = 0xAB
    read_or_write = WRITE
    payload = [0x12, 0x34, 0xFD, 0x56, 0xFE]
    @test get_frame(command, read_or_write, payload=payload) ==
    [0xfc, 0xab, 0x01, 0x12, 0x34, 0xfe, 0xdd, 0x56, 0xfe, 0xde, 0xbc, 0xfd]

    @test SimpleByteStuffing.verify_read_or_write(READ) == false
    @test SimpleByteStuffing.verify_read_or_write(WRITE) == false
    @test_throws ErrorException SimpleByteStuffing.verify_read_or_write(0xFF)
    
end
