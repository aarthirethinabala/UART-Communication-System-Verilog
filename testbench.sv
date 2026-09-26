`timescale 1ns/1ps

module uart_tb;

    // Simulation settings
    localparam integer CLK_FREQ  = 1_000_000;
    localparam integer BAUD_RATE = 10_000;

    reg clk;
    reg rst;
    reg [7:0] tx_data;
    reg tx_start;

    wire tx;
    wire tx_busy;
    wire [7:0] rx_data;
    wire rx_valid;
    wire rx_error;

    // UART system
    uart_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .rst(rst),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .rx(tx),
        .tx(tx),
        .tx_busy(tx_busy),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_error(rx_error)
    );

    // 1 MHz clock
    initial begin
        clk = 1'b0;
        forever #500 clk = ~clk;
    end

    // Main test
    initial begin

        rst      = 1'b1;
        tx_data  = 8'h00;
        tx_start = 1'b0;

        // Reset
        #5000;
        rst = 1'b0;

        tx_data  = 8'hA5;
        tx_start = 1'b1;

        #1000;
        tx_start = 1'b0;

        // Wait for complete 10-bit UART frame
        #1100000;

        if (rx_data == 8'hA5)
            $display("PASS: Sent = A5, Received = %h", rx_data);
        else
            $display("FAIL: Sent = A5, Received = %h", rx_data);

        tx_data  = 8'h3C;
        tx_start = 1'b1;

        #1000;
        tx_start = 1'b0;

        #1100000;

        if (rx_data == 8'h3C)
            $display("PASS: Sent = 3C, Received = %h", rx_data);
        else
            $display("FAIL: Sent = 3C, Received = %h", rx_data);

        tx_data  = 8'h55;
        tx_start = 1'b1;

        #1000;
        tx_start = 1'b0;

        #1100000;

        if (rx_data == 8'h55)
            $display("PASS: Sent = 55, Received = %h", rx_data);
        else
            $display("FAIL: Sent = 55, Received = %h", rx_data);

        tx_data  = 8'h00;
        tx_start = 1'b1;

        #1000;
        tx_start = 1'b0;

        #1100000;

        if (rx_data == 8'h00)
            $display("PASS: Sent = 00, Received = %h", rx_data);
        else
            $display("FAIL: Sent = 00, Received = %h", rx_data);

        tx_data  = 8'hFF;
        tx_start = 1'b1;

        #1000;
        tx_start = 1'b0;

        #1100000;

        if (rx_data == 8'hFF)
            $display("PASS: Sent = FF, Received = %h", rx_data);
        else
            $display("FAIL: Sent = FF, Received = %h", rx_data);

        $display("----------------------------------------");
        $display("UART MULTI-BYTE SIMULATION COMPLETED");
        $display("----------------------------------------");

        $finish;

    end

endmodule
