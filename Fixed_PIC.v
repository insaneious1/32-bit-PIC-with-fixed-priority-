`timescale 1ns / 1ps



module irr (
	input clk,           	// Clock signal
	input reset,         	// Reset signal
	input [31:0] irq,     	// Interrupt requests from 8 sources (IR0 - IR7)
	input [31:0]isr,     	// In-Service Register indicating currently serviced interrupts
	output reg [31:0] irr 	// Interrupt Request Register output
);

	// Internal register to hold the interrupt requests
 	reg [31:0] irr2;
	// Always block to update the IRR on clock edge or reset
	always @(posedge clk or posedge reset /*or posedge irr2 posedge irq*/ ) begin
    	if (reset) begin
        	irr <= 32'd0;
    	end else begin
       	irr <= irq | irr2;
       	//irr <= irq & isr;
    	end
	end
	always @(*)begin
    	irr2 = irr;
    	if(isr)begin
        	irr2 = irr2 & isr;
    	end
	end
endmodule

module priority_resolver (
	input clk,reset,
	input [31:0] irr,     	// Interrupt Request Register
	input [31:0] imq,     	// Interrupt Mask Register
	output reg [5:0] int_id  // Interrupt ID with the highest priority
);
   // reg [31:0]imr;
   reg [31:0] masked_irr;
	integer i;

	// Mask the IRR using IMR and ISR
  always @(posedge clk) begin
    	if(reset)begin
        	int_id <= 6'b000000;
    	end
    	else begin
	//	imr = imq;
    	masked_irr = irr & imq;
        	int_id <= 6'b111111;
    	// Check if masked_irr is not all zeros
    	if (masked_irr != 32'd0) begin
        	// Search for the highest priority interrupt request
        	for (i = 0; i < 32; i = i + 1) begin
            	if (masked_irr[i] ) begin
                	// Found the highest priority interrupt
                	int_id <= i;
               	 
            	end
        	end
    	end
    	 
	end  end
 
endmodule

module isr (
	input clk,
	input reset,
    
	input int_ack,
	input [5:0] int_id,
	output reg [31:0] isr
);


	// Update ISR based on interrupt acknowledgment
  	always @(posedge clk or posedge reset) begin
  	 
    	if (reset)
        	isr <= 32'hffffffff;  // Reset ISR to all zeros
     	else  begin
        	if (int_ack) begin
            	isr <= 32'hffffffff;
            	isr[int_id] <= 1'b0;  
        	end// Set the corresponding bit for the acknowledged interrupt
    	end
	end
   
endmodule

module vector_generator (
input clk,
input reset,
	input [5:0] int_id,   	// Interrupt ID from the priority resolver
	output reg [31:0] vector   // Vector address based on interrupt ID
);

	// Assign vector address based on interrupt ID
	always @(posedge clk) begin
	if(reset)
	vector = 32'dz;
	else begin
    	case (int_id)
            	6'b00000: vector = 32'hffffff00;
            	6'b00001: vector = 32'hffffff01;
            	6'b00010: vector = 32'hffffff02;
            	6'b00011: vector = 32'hffffff03;
            	6'b00100: vector = 32'hffffff04;
            	6'b00101: vector = 32'hffffff06;
            	6'b00110: vector = 32'hffffff06;
            	6'b00111: vector = 32'hffffff07;
            	6'b01000: vector = 32'hffffff08;
            	6'b01001: vector = 32'hffffff09;
            	6'b01010: vector = 32'hffffff0a;
            	6'b01011: vector = 32'hffffff0b;
            	6'b01100: vector = 32'hffffff0c;
            	6'b01101: vector = 32'hffffff0d;
            	6'b01110: vector = 32'hffffff0e;
            	6'b01111: vector = 32'hffffff0f;
            	6'b10000: vector = 32'hffffff10;
            	6'b10001: vector = 32'hffffff11;
            	6'b10010: vector = 32'hffffff12;
            	6'b10011: vector = 32'hffffff13;
            	6'b10100: vector = 32'hffffff14;
            	6'b10101: vector = 32'hffffff15;
            	6'b10110: vector = 32'hffffff16;
            	6'b10111: vector = 32'hffffff17;
            	6'b11000: vector = 32'hffffff18;
            	6'b11001: vector = 32'hffffff19;
            	6'b11010: vector = 32'hffffff1a;
            	6'b11011: vector = 32'hffffff1b;
            	6'b11100: vector = 32'hffffff1c;
            	6'b11101: vector = 32'hffffff1d;
            	6'b11110: vector = 32'hffffff1e;
            	6'b11111: vector = 32'hffffff1f;
            	default : vector = 32'bz;
    	endcase
	end
	end

endmodule



module control_logic (
	input clk,               	// Clock signal
	input [5:0] int_id,  
	input reset,    	// Interrupt ID from the priority resolver
    
	output reg int_req ,     	// Interrupt request output
	input wire int_ack 	 
    
);

	// Control logic for generating interrupt request and transmitting vector address
	always @(*) begin
	if(reset) int_req <= 0;
	else begin
    	// Check if there is an interrupt request (int_id != 3'b000) and generate interrupt output accordingly
   	if(int_id == 6'bz) begin
        	int_req <= 1'b0;
        	end else
     	if (int_id <32 && !int_ack) begin
        	int_req <= 1'b1;  // Generate interrupt request
    	end else if(int_ack) begin
        	int_req <= 1'b0;  // No interrupt request
    	end
   	end
    
end
endmodule


//mux to select which registrs data to be read
module mux(
	input clk,
	input reset,
	input int_ack,read,
	input wire [1:0]select,
	input wire [31:0]imr,
	input wire [31:0]irr,
	input wire [31:0]isr,
	input wire [31:0]vector,
	output reg [31:0]outdata  
	);
always @(posedge clk)
	begin
	if(reset)begin
    	outdata <= 32'bz;
    	end
 	else if(int_ack)
    	outdata <= vector;
 	else if(read)
    	begin
        	case(select)
        	2'b00 : outdata <= imr;
        	2'b01 : outdata <= irr;
        	2'b10 : outdata <= isr;
        	2'b11 : outdata <= vector;
        	endcase
     	end
  	end
   
endmodule

module intrcntrl (
	input clk,           	// Clock signal
	input reset,      	// Reset signal
	input read,
	input [31:0] irq,     	// Interrupt requests from 8 sources (IR0 - IR7)
	input int_ack,       	// Interrupt acknowledgment from microprocessor
	output int_req,      	// Interrupt request output to microprocessor
	output [31:0] data_bus,  // Data bus to transmit vector address to microprocessor
	input wire [1:0]s,   	//select lines to select the register whose value is to be read by the processor
	input wire [31:0]imq  //wires to write on mask register
);
    
	wire [31:0] irr;      	// Interrupt Request Register
	wire [31:0] isr;      	// In-Service Register
	wire [5:0] int_id;   	// Interrupt ID with the highest priority
	wire [31:0] vector;   	// Vector address based on interrupt ID
 
	// Instantiate the IRR module
	irr irr_inst (
    	.clk(clk),
    	.reset(reset),
    	.irq(irq),
    	.irr(irr),
    	.isr(isr)
	);

	// Instantiate the priority resolver module
	priority_resolver priority_resolver_inst (
    	.irr(irr),
    	.imq(imq),
    	.int_id(int_id),
    	.clk(clk),
    	.reset(reset)
    	);

	// Instantiate the ISR module
	isr isr_inst (
    	.clk(clk),
    	.reset(reset),
    	.int_id(int_id),
    	.isr(isr),
    	.int_ack(int_ack)
	);

	// Instantiate the vector generator module
	vector_generator vector_generator_inst (
    	.clk(clk),
    	.reset(reset),
    	.int_id(int_id),
    	.vector(vector)
	);

	// Instantiate the control logic module
	control_logic control_logic_inst (
    	.clk(clk),
    	.reset(reset),
    	.int_id(int_id),
    	.int_req(int_req)  ,
    	.int_ack(int_ack)
   	 
	);
    
	//instentiating the mux
	mux mux_inst(
     	.clk(clk),
     	.int_ack(int_ack),
     	.read(read),
     	.reset(reset),
     	.imr(imq),
     	.isr(isr),
     	.irr(irr),
     	.vector(vector),
     	.select(s),
     	.outdata(data_bus)
	);
 
endmodule
