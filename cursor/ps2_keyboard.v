`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:06:00 01/15/2020 
// Design Name: 
// Module Name:    ps2_keyboard 
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
module ps2_keyboard(
	input clk,ps2_clk,ps2_data,rst,
	output[7:0]data_out,
	output ready
    );
/*=============test negtive edge of ps2_clk===============*/
reg ps2_clk_0,ps2_clk_1,ps2_clk_2;
wire negedge_ps2_clk; //negetive edge of ps2_clk

always @(posedge clk or posedge rst) begin
	if(rst) begin
		ps2_clk_0<=1'b0;
		ps2_clk_2<=1'b0;
		ps2_clk_1<=1'b0;

	end
	else begin
		ps2_clk_0<=ps2_clk;
		ps2_clk_1<=ps2_clk_0;
		ps2_clk_2<=ps2_clk_1;
	end
end

assign negedge_ps2_clk=!ps2_clk_1&ps2_clk_2; //if it's 1, negedge of ps2_clk occurs
/*==================read data==================*/

reg[3:0] count;		
always @(posedge clk or posedge rst)begin
	   if(rst)
	       count <= 4'd0;
	   else if(count==4'd11)	//end of one frame
		    count <= 4'd0;
	   else if(negedge_ps2_clk)
	       count <= count +1'b1;
end
	 
reg negedge_ps2_clk_shift;
always @(posedge clk) begin
	     negedge_ps2_clk_shift <= negedge_ps2_clk;
end
reg [7:0] temp_data;
always @(posedge clk or posedge rst)begin
	     if(rst)
		      temp_data <= 8'd0;
		  else if(negedge_ps2_clk_shift) begin             //read data at negedge of ps2_clk
		  
		      case(count)                                    //read 8-bit data
				
				    4'd2 : temp_data[0] <= ps2_data;
					 4'd3 : temp_data[1] <= ps2_data;
					 4'd4 : temp_data[2] <= ps2_data;
					 4'd5 : temp_data[3] <= ps2_data;
					 4'd6 : temp_data[4] <= ps2_data;
					 4'd7 : temp_data[5] <= ps2_data;
					 4'd8 : temp_data[6] <= ps2_data;
					 4'd9 : temp_data[7] <= ps2_data;
					 default : temp_data <= temp_data;
				endcase
		  end else
		      temp_data <= temp_data;
end

/*=========processing data=============*/
reg data_break,data_done,data_expand;
reg [7:0] data;
always @(posedge clk or posedge rst)begin
	     if(rst) begin
		     data_break <= 1'b0;
			  data <= 10'd0;
			  data_done <=1'b0;
			  data_expand <= 1'b0;
		  end
		  else if(count == 4'd11)begin		//end of each frame
		      if(temp_data == 8'hE0)
				    data_expand <= 1'b1;                     
				else if(temp_data == 8'hF0)	//it's break code
				    data_break <= 1'b1;
				else begin
				    data <= temp_data;
					 data_done <= 1'b1;  	//ready for output                     
					 data_expand <= 1'b0;
					 data_break <=1'b0;
			   end
		  end
		  else begin
		    data <= data;
			 data_done <= 1'b0;
			 data_expand <= data_expand;
			 data_break <= data_break;
		  end
end
	  
assign data_out = data;
assign ready = data_done;  
endmodule
