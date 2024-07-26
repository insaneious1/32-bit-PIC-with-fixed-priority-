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
         @(posedge clk);
        irq = 32'b00000000000000000110011011001111;    //31 BIT TURNED OFF 
      
         repeat(3)
        @(posedge clk); 
        
          read= 1; s = 2'b01; 
           repeat(3)
        @(posedge clk); 
          int_ack = 1; //14TH INTERRUPT SERVED
          @(posedge clk); 
          int_ack = 0;  
          @(posedge clk);
           irq = 32'b00000000000000000010011011001111;  //14TH BIT TURNED OFF
          @(posedge clk); 
          s = 2'b10;
          @(posedge clk); 
          s = 2'b11;
          @(posedge clk); 
          s = 2'b00;
          @(posedge clk);
           read= 0;
           repeat(3)
         @(posedge clk);
        int_ack = 1; //13TH INTERRUPT SERVED
         @(posedge clk);
        int_ack = 0; 
          @(posedge clk);
           irq = 32'b00000000000000000000011011001111;  //13TH BIT TURNED OFF
       
        # 10 $finish;
    
    
        
    end

endmodule
