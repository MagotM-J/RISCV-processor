module cpu_top(input logic MAX10_CLK1_50,
					input logic [1:0] KEY,
					input logic [9:0] SW,
					output logic [9:0] LEDR,
					output logic [7:0] HEX5,
					output logic [7:0] HEX4,
					output logic [7:0] HEX3,
					output logic [7:0] HEX2,
					output logic [7:0] HEX1,
					output logic [7:0] HEX0 );
					
	logic        clk;
	logic        reset;
	logic [9:0] sw;
	logic [9:0] ledr;
	logic [31:0] hex3hex0;
	logic [15:0] hex5hex4;
	logic [31:0] ReadData;
	logic [31:0] WriteData, DataAdr;
	logic        MemWrite;
	
	assign clk = MAX10_CLK1_50;
	assign reset = KEY[0];
	assign sw = SW;
	
	assign LEDR = ledr;
	
	assign {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = {hex5hex4, hex3hex0};

	
	top dut(clk, sw, reset, ledr, hex3hex0, hex5hex4, WriteData, DataAdr, MemWrite, ReadData);
					
endmodule