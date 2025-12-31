module top(    input logic clk,
           input logic [9:0] SW,
           input logic KEY1,
           output logic [9:0] LEDR,
           output logic [31:0] HEX3HEX0,
           output logic [15:0] HEX5HEX4,
           output logic [31:0] WriteData, DataAdr,
           output logic MemWrite,
           output logic [31:0] ReadData);

    logic [31:0] PC, Instr, ReadData_out;

    localparam logic[31:0]    LEDR_BASE = 32'hFF200000;
    localparam logic[31:0]    HEX3_HEX0_BASE = 32'hFF200020;
    localparam logic[31:0]    HEX5_HEX4_BASE = 32'hFF200030;
    localparam logic[31:0]    SW_BASE = 32'hFF200040;

     assign reset = ~KEY1;

    always_ff @(posedge clk) begin
        if(reset) begin
            LEDR <= 10'h000;
            HEX3HEX0 <= 32'hFFFFFFFF;
            HEX5HEX4 <= 16'hFFFF;
        end 
        else if(MemWrite) begin
            case(DataAdr)
                LEDR_BASE: LEDR <= WriteData[9:0];
                HEX3_HEX0_BASE: HEX3HEX0 <= ~WriteData;
                HEX5_HEX4_BASE: HEX5HEX4 <= ~WriteData[15:0];
            endcase
        end
    end

    always_comb begin
        if(DataAdr == SW_BASE)
            ReadData = SW;
        else
            ReadData = ReadData_out;
    end

    // instantiate processor and memories
    riscvsingle rvsingle(clk, reset, PC, Instr, MemWrite,
    DataAdr, WriteData, ReadData);

    imem imem(PC, Instr);
     dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData_out);

endmodule