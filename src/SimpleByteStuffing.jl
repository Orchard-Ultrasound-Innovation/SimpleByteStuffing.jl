"""
SimpleByteStuffing is used to create packets for device packet communication.

To create a packet:
```
packet = create_packet({command}, {read_or_write}, {payload})

command: 8-bit command
read_or_write: acceptables values are "READ" and "WRITE"
payload: vector of 8-bits
```

To parse a received packet:
```
payload = parse_packet(packet)
```

```
packet: [SOP][CMD][Payload1][...][Payloadn][Checksum][EOP]
SOP - start of packet
CMD - command with read/write bit 
Payload - data
Checksum - 8-bit checksum
EOP - end of packet
```

"""
module SimpleByteStuffing

export create_packet
export parse_packet

include("bytestuffing.jl")

end
