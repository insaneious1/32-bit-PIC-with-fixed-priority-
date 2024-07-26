`timescale 1ns / 1ps

module tb_intrcntrl;

    // Parameters
    parameter CLK_PERIOD = 20; // Clock period in ns

    // Signals
    reg clk = 0;               // Clock signal
    reg reset;             // Reset signal
    reg read = 0;             // Read/Write control signal
    reg int_ack = 0;           // Interrupt acknowledgment from microprocessor
    reg [31:0] irq = 32'b0;  // Interrupt requests from 8 sources (IR0 - IR7)
    reg [1:0] s = 2'b00;       // Select lines to select the register whose value is to be read by the processor
    reg [31:0] imq = 32'b0; // Data to write on mask register
    wire int_req;              // Interrupt request output to microprocessor
    wire [31:0] data_bus;       // Data bus to transmit vector address to microprocessor

    // Instantiate the intrcntrl module
    intrcntrl intrcntrl_inst (
        .clk(clk),
        .reset(reset),
        .read(read),
        .irq(irq),
        .int_ack(int_ack),
        .int_req(int_req),
        .data_bus(data_bus),
        .s(s),
        .imq(imq)
    );
        
    // Clock generation
    always #((CLK_PERIOD / 2)) clk = ~clk;

   initial begin
        // Test case 1: Write to mask register and acknowledge interrupt
        reset = 1;
        #100 reset = 0;
        irq = 32'b10000000000000000110011011001111;//(31,14,13,10,9,7,6,3,2,1,0)
        imq = 32'b11111111111111111111111111110111;  //(3)
        repeat(3)
        @(posedge clk);        
        int_ack = 1;  //31st interrupt served
        @(posedge clk);
        int_ack = 0;        
        irq = 32'b00000000000000000110011011000111; //31st interrupt served so disable it
        repeat(3)
        @(posedge clk);        
        int_ack = 1; //14th from prev set will be served here
        @(posedge clk);
        int_ack = 0; 
        irq = 32'b01000000000000000000000000000110;  //new set of interrupt came and remaining interrupts of previous set are unserved (30,2,1)
        repeat(3)
        @(posedge clk);        
        int_ack = 1;   //30th 
        @(posedge clk);
        int_ack = 0; 
        irq = 32'b00000000000000000000000000000110;  // disable 30th 
        repeat(3)
       @(posedge clk);        
        int_ack = 1;  //13th from new set served
        @(posedge clk);
        int_ack = 0; 
        
        repeat(3)
        @(posedge clk);        
        int_ack = 1;  //10th from unserved set served
        @(posedge clk);
        int_ack = 0; 
        
        repeat(3)
       @(posedge clk);        
        int_ack = 1;  //9th from unserved set
        @(posedge clk);
        int_ack = 0; 
        
        repeat(3)
       @(posedge clk);        
        int_ack = 1;  //7th from unserved
        @(posedge clk);
        int_ack = 0; 
        
        repeat(3)
       @(posedge clk);        
        int_ack = 1;  //6th from unserved set
        @(posedge clk);
        int_ack = 0; 
        
        repeat(3)
       @(posedge clk);        
        int_ack = 1;  //2nd from new
        @(posedge clk);
        int_ack = 0; 
        irq = 32'b00000000000000000000000000000010;  //disable 2nd
        
        repeat(3)
       @(posedge clk);        
        int_ack = 1;  //1st from current set
        @(posedge clk);
        int_ack = 0; 
        int_ack = 0; irq = 32'b00000000000000000000000000000000; 
        
        repeat(3)
       @(posedge clk);        
        int_ack = 1; //0th from unserved set
        @(posedge clk);
        int_ack = 0; 
        
        # 50 $finish;  
    end

endmodule

