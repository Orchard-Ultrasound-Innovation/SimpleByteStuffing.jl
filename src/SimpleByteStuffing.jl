"""
SimpleByteStuffing is used to create packets for device packet communication.

To create a packet:
```
packet = create_packet({command}, {read_or_write}, {payload})

command: 8-bit command
read_or_write: acceptables values are READ and WRITE
payload: vector of 8-bits
```

```
packet: [SOP][CMD][R/W][Payload1][...][Payloadn][Checksum][EOP]
SOP - start of packet
CMD - command 
R/W - read-write byte.  
Payload - data
Checksum - 8-bit checksum
EOP - end of packet
```
"""
module SimpleByteStuffing

const READ = 0x00
const WRITE = 0x01

export READ, WRITE
export create_packet

include("bytestuffing.jl")

end
