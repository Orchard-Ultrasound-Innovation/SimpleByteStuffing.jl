using SimpleByteStuffing
using Random
using Test

@testset "SimpleByteStuffing.jl" begin
    
    payload = rand(UInt8, 1000)
    packet = create_packet(rand(UInt8, 1)[1], "WRITE", payload=payload)
    parsed = parse_packet(packet)
    @test parsed == payload

    payload = rand(UInt8, 1000)
    packet = create_packet(0xFE, "READ", payload=payload)
    parsed = parse_packet(packet)
    @test parsed == payload

    @test SimpleByteStuffing.verify_read_or_write("READ") == false
    @test SimpleByteStuffing.verify_read_or_write("WRITE") == false
    @test_throws ErrorException SimpleByteStuffing.verify_read_or_write("r")

end
