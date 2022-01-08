module Divider(
    input 			I_CLK	,
    input 			rst		,
    output reg 		O_CLK
);
    parameter base = 20000;
    integer cnt;
    initial begin cnt <=  0; O_CLK <= 0; end
    always @(posedge I_CLK) begin
        if(rst == 1) begin cnt <= 0; O_CLK <= 0; end
        else begin 
            cnt <= cnt + 1;
            if(cnt == base / 2 - 1) begin O_CLK <= ~O_CLK; cnt <= 0; end
        end
    end 
endmodule

module trans7(
    input [3:0] 	iData	,
    output [7:0] 	oData
    );
    wire [15:0] 	num		;
	wire a,b,c,d,e,f,g,dp;
    assign num[0] = (~iData[3] & ~iData[2] & ~iData[1] & ~iData[0]);
    assign num[1] = (~iData[3] & ~iData[2] & ~iData[1] & iData[0]);
    assign num[2] = (~iData[3] & ~iData[2] & iData[1] & ~iData[0]);
    assign num[3] = (~iData[3] & ~iData[2] & iData[1] & iData[0]);
    assign num[4] = (~iData[3] & iData[2] & ~iData[1] & ~iData[0]);
    assign num[5] = (~iData[3] & iData[2] & ~iData[1] & iData[0]);
    assign num[6] = (~iData[3] & iData[2] & iData[1] & ~iData[0]);
    assign num[7] = (~iData[3] & iData[2] & iData[1] & iData[0]);
    assign num[8] = (iData[3] & ~iData[2] & ~iData[1] & ~iData[0]);
    assign num[9] = (iData[3] & ~iData[2] & ~iData[1] & iData[0]);
	assign num[10] = (iData[3] & ~iData[2] & iData[1] & ~iData[0]);
	assign num[11] = (iData[3] & ~iData[2] & iData[1] & iData[0]);
	assign num[12] = (iData[3] & iData[2] & ~iData[1] & ~iData[0]);
	assign num[13] = (iData[3] & iData[2] & ~iData[1] & iData[0]);
	assign num[14] = (iData[3] & iData[2] & iData[1] & ~iData[0]);
	assign num[15] = (iData[3] & iData[2] & iData[1] & iData[0]);
    assign a = num[1] | num[4] | num[11] | num[13];
    assign b = num[5] | num[6] | num[11] | num[12] | num[14] | num[15];
    assign c = num[2] | num[12] | num[14] | num[15];
    assign d = num[1] | num[4] | num[7] | num[10] | num[15];
    assign e = num[1] | num[3] | num[4] | num[5] | num[7] | num[9];
    assign f = num[1] | num[2] | num[3] | num[7] | num[13];
    assign g = num[0] | num[1] | num[7] | num[12];
	assign dp = num[0] | num[1]| num[2]| num[3]| num[4]| num[5]| num[6]| num[7]| num[8]| num[9];
    assign oData = {dp,g,f,e,d,c,b,a};
endmodule

module display7(
	input 				clk		,
	input [3:0] 		led1	,
	input [3:0] 		led2	,
	input [3:0] 		led3	,
	input [3:0] 		led4	,
	input [3:0] 		led5	,
	input [3:0] 		led6	,
	input [3:0] 		led7	,
	input [3:0] 		led8	,
	output reg [7:0] 	ena		,
	output [7:0] 		ctl
);
    wire display_clk;
    Divider display_div(.I_CLK(clk), .O_CLK(display_clk));
	reg [3:0] led;
	trans7 trans7_0(led, ctl);
	reg [2:0] cnt;
	initial begin
	  cnt <= 0;
	  ena <= 0;
	end
	always @(posedge display_clk) begin
		cnt <= cnt + 1;
	end
	always @(posedge display_clk)
		case(cnt)
			default: led <= led1;
			3'b000:	led <= led1;
			3'b001:	led <= led2;
			3'b010:	led <= led3;
			3'b011:	led <= led4;
			3'b100:	led <= led5;
			3'b101:	led <= led6;
			3'b110:	led <= led7;
			3'b111:	led <= led8;
		endcase
	always @(posedge display_clk)
		case(cnt)
			default: ena <= 8'b11111110;
			3'b000:	ena <= 8'b11111110;
			3'b001:	ena <= 8'b11111101;
			3'b010:	ena <= 8'b11111011;
			3'b011:	ena <= 8'b11110111;
			3'b100:	ena <= 8'b11101111;
			3'b101:	ena <= 8'b11011111;
			3'b110:	ena <= 8'b10111111;
			3'b111:	ena <= 8'b01111111;
		endcase
endmodule