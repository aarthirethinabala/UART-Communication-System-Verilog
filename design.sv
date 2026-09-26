`timescale 1ns/1ps
module baud_gen #(
 parameter integer CLK_FREQ = 50_000_000,
 parameter integer BAUD_RATE = 9600
)(
 input wire clk,
 input wire rst,
 output reg baud_tick
);
 localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
 integer count;
 always @(posedge clk) begin
 if (rst) begin
 count <= 0;
 baud_tick <= 1'b0;
 end
 else if (count == CLKS_PER_BIT - 1) begin
 count <= 0;
 baud_tick <= 1'b1;
 end
 else begin
 count <= count + 1;
 baud_tick <= 1'b0;
 end
 end
endmodule

module uart_tx (
 input wire clk,
 input wire rst,
 input wire baud_tick,
 input wire [7:0] tx_data,
 input wire tx_start,
 output reg tx,
 output reg tx_busy
);
 localparam IDLE = 2'd0;
 localparam START = 2'd1;
 localparam DATA = 2'd2;
 localparam STOP = 2'd3;
 reg [1:0] state;
 reg [7:0] data_reg;
 reg [2:0] bit_count;
 always @(posedge clk) begin
 if (rst) begin
 state <= IDLE;
 data_reg <= 8'b0;
 bit_count <= 3'b0;
 tx <= 1'b1;
 tx_busy <= 1'b0;
 end
 else begin
 case (state)
 IDLE: begin
 tx <= 1'b1;
 tx_busy <= 1'b0;
 if (tx_start) begin
 data_reg <= tx_data;
 bit_count <= 3'd0;
 tx_busy <= 1'b1;
 state <= START;
 end
 end
 START: begin
 tx <= 1'b0;
 if (baud_tick)
 state <= DATA;
 end
 DATA: begin
 tx <= data_reg[bit_count];
 if (baud_tick) begin
 if (bit_count == 3'd7)
 state <= STOP;
 else
 bit_count <= bit_count + 1'b1;
 end
 end
 STOP: begin
 tx <= 1'b1;
 if (baud_tick) begin
 state <= IDLE;
 tx_busy <= 1'b0;
 end
 end
 default: begin
 state <= IDLE;
 tx <= 1'b1;
 tx_busy <= 1'b0;
 end
 endcase
 end
 end
endmodule

module uart_rx #(
 parameter integer CLKS_PER_BIT = 5208
)(
 input wire clk,
 input wire rst,
 input wire rx,
 output reg [7:0] rx_data,
 output reg rx_valid,
 output reg rx_error
);
 localparam IDLE = 2'd0;
 localparam START = 2'd1;
 localparam DATA = 2'd2;
 localparam STOP = 2'd3;
 reg [1:0] state;
 reg [7:0] data_reg;
 reg [2:0] bit_count;
 integer count;
 always @(posedge clk) begin
 if (rst) begin
 state <= IDLE;
 data_reg <= 8'b0;
 bit_count <= 3'b0;
 count <= 0;
 rx_data <= 8'b0;
 rx_valid <= 1'b0;
 rx_error <= 1'b0;
 end
 else begin
 rx_valid <= 1'b0;
 rx_error <= 1'b0;
 case (state)
 IDLE: begin
 count <= 0;
 bit_count <= 3'd0;
 if (rx == 1'b0)
 state <= START;
 end
 START: begin
 if (count == (CLKS_PER_BIT / 2) - 1) begin
 count <= 0;
 if (rx == 1'b0)
 state <= DATA;
 else
 state <= IDLE;
 end
 else begin
 count <= count + 1;
 end
 end
 DATA: begin
 if (count == CLKS_PER_BIT - 1) begin
 count <= 0;
 data_reg[bit_count] <= rx;
 if (bit_count == 3'd7)
 state <= STOP;
 else
 bit_count <= bit_count + 1'b1;
 end
 else begin
 count <= count + 1;
 end
 end
 STOP: begin
 if (count == CLKS_PER_BIT - 1) begin
 count <= 0;
 state <= IDLE;
 if (rx == 1'b1) begin
 rx_data <= data_reg;
 rx_valid <= 1'b1;
 end
 else begin
 rx_error <= 1'b1;
 end
 end
 else begin
 count <= count + 1;
 end
 end
 default: begin
 state <= IDLE;
 end
 endcase
 end
 end
endmodule

module uart_top #(
 parameter integer CLK_FREQ = 50_000_000,
 parameter integer BAUD_RATE = 9600
)(
 input wire clk,
 input wire rst,
 input wire [7:0] tx_data,
 input wire tx_start,
 input wire rx,
 output wire tx,
 output wire tx_busy,
 output wire [7:0] rx_data,
 output wire rx_valid,
 output wire rx_error
);
 localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
 wire baud_tick;
 baud_gen #(
 .CLK_FREQ(CLK_FREQ),
 .BAUD_RATE(BAUD_RATE)
 ) baud_generator (
 .clk(clk),
 .rst(rst),
 .baud_tick(baud_tick)
 );
 uart_tx transmitter (
 .clk(clk),
 .rst(rst),
 .baud_tick(baud_tick),
 .tx_data(tx_data),
 .tx_start(tx_start),
 .tx(tx),
 .tx_busy(tx_busy)
 );
 uart_rx #(
 .CLKS_PER_BIT(CLKS_PER_BIT)
 ) receiver (
 .clk(clk),
 .rst(rst),
 .rx(tx),
 .rx_data(rx_data),
 .rx_valid(rx_valid),
 .rx_error(rx_error)
 );
endmodule
