# FPGA High Speed Stream Protocol

## Description

This stream transmittion protocol is used for data transmission between some fpgas.

The top module is board_level_data_block_transmitter and board_level_data_block_receiver.

In physical level(board_level_transmitter_physical and board_level_receiver_physical module), data is transmitted in a source-synchronous bit stream channel.

I use a special code to transfer data in physical level:

\<Start\>\<Data1\>\<Data2\>\<...\>\<Idle\>\<Datan\>\<End\>

Here, \<Start\> is 8'b00000001, \<Data\> is 8'bxxxxxx11, \<Idle\> is 8'b00000000, \<End\> is 8'b00000010.

To identify seven "0" and one "1", the reception module can find frame boundary easily.

To introduce idle signal, it's enable transmitter waiting a second when send a frame because data isn't ready.

You may notice that actually data is only 6-bit, I will explain it later.

In high level(board_level_data_transmitter and board_level_data_receiver module), data is transmitted as follows:

\<Data1\>\<Data2\>\<...\>\<Datan\>\<CRC\>

Here, \<Data\> and \<CRC\> are both 8-bit, the module will split these 8-bit data to many 6-bit data with some zero-padding.

CRC is CRC8/maxim for Data1..n with initial value 0.

In highest level(board_level_data_block_transmitter and board_level_data_block_receiver module), data is organized as n-byte width data block. You can send and receive stream data very easily with these modules.

## Notice

You should use ODDR primitive to ensure the phase relation between clock and data signal of source-synchronized channel.

In Spartan6:

```verilog
ODDR2 #(
    .DDR_ALIGNMENT("NONE"),
    .INIT(1'b0),
    .SRTYPE("SYNC")
)ODDR2_send_clk(
    .Q(oddr2_send_clk),
    .C0(send_clk),
    .C1(~send_clk),
    .CE(1'b1),
    .D0(1'b1),
    .D1(1'b0),
    .R(1'b0),
    .S(1'b0)
);

ODDR2 #(
    .DDR_ALIGNMENT("NONE"),
    .INIT(1'b0),
    .SRTYPE("SYNC")
)ODDR2_serial_data(
    .Q(oddr2_send_serial_data),
    .C0(send_clk),
    .C1(~send_clk),
    .CE(1'b1),
    .D0(send_serial_data),
    .D1(send_serial_data),
    .R(1'b0),
    .S(1'b0)
);
```

In Kintex7:

```verilog
ODDR #(
    .DDR_CLK_EDGE("OPPOSITE_EDGE"),
    .INIT(1'b0),
    .SRTYPE("SYNC")
)ODDR_send_clk(
    .Q(oddr_send_clk),
    .C(send_clk),
    .CE(1'b1),
    .D1(1'b1),
    .D2(1'b0),
    .R(1'b0),
    .S(1'b0)
);

ODDR #(
    .DDR_CLK_EDGE("OPPOSITE_EDGE"),
    .INIT(1'b0),
    .SRTYPE("SYNC")
)ODDR_serial_data(
    .Q(oddr_send_serial_data),
    .C(send_clk),
    .CE(1'b1),
    .D1(send_serial_data),
    .D2(send_serial_data),
    .R(1'b0),
    .S(1'b0)
);
```

You must use clock-dedicated port of fpga in receiver and don't want to contraint it as a normal clock signal.

You can also use some more advanced technologies such as timing training, differential transmission, clock recovery and so on to increase protocol performance.