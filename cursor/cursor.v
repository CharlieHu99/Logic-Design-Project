`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:12:14 01/16/2020 
// Design Name: 
// Module Name:    cursor 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module cursor(
	input clk,ps2_clk,ps2_data,rst,
	input[7:0] location_in,
	output[7:0] location_out,
	output request
    );
wire ready_1;
wire [7:0] data;
reg[7:0] temp_location;
reg ready_2;
ps2_keyboard m0(.clk(clk),.ps2_clk(ps2_clk),.rst(rst),.ps2_data(ps2_data),.data_out(data),.ready(ready_1));
/*always @ (posedge clk or posedge rst) begin
	if(rst) temp_location<=8'b0;
	else if(ready_1) temp_location<=location_in;
	else temp_location<=temp_location;
end*/
initial temp_location=location_in;
always @ (posedge clk or posedge rst) begin	//这个地方是应该写成posedge ready_1还是posedge_clk?
	if(rst) begin
		temp_location<=8'b0;
		ready_2<=1'b0;
	end
	else if(ready_1) begin
		if(data==8'h1C) begin		//A
			if(temp_location[7:4]==4'b0) temp_location<=temp_location;	//out of boundary
			else temp_location<=temp_location-8'h10;		//move leftward
			ready_2<=1'b0;
		end
		else if(data==8'h1b) begin	//S
			if(temp_location[3:0]==4'h9) temp_location<=temp_location;
			else temp_location<=temp_location+8'h01;
			ready_2<=1'b0;
		end
		else if(data==8'h23) begin	//D
			if(temp_location[7:4]==4'h8) temp_location<=temp_location;
			else temp_location<=temp_location+8'h10;
			ready_2<=1'b0;
		end
		else if(data==8'h1d) begin	//W
			if(temp_location[3:0]==4'h0) temp_location<=temp_location;
			else temp_location<=temp_location-8'h01;
			ready_2<=1'b0;
		end
		else if(data==8'h5A) begin	//Enter
			temp_location<=temp_location;
			ready_2<=1'b1;
		end
		else begin
			temp_location<=temp_location;
			ready_2<=1'b0;
		end
	end
	else begin
		temp_location<=temp_location;
		ready_2<=1'b0;
	end
end

assign request=ready_2;
assign location_out=temp_location;
			
endmodule
