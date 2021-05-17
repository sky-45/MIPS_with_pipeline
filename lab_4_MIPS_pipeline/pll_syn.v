// Copyright (C) 1991-2009 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// VENDOR "Altera"
// PROGRAM "Quartus II"
// VERSION "Version 9.1 Build 222 10/21/2009 SJ Full Version"

// DATE "01/31/2021 20:28:15"

// 
// Device: Altera EP2C5T144C6 Package TQFP144
// 

// 
// This greybox netlist file is for third party Synthesis Tools
// for timing and resource estimation only.
// 


module pll (
	inclk0,
	c0,
	c1)/* synthesis synthesis_greybox=0 */;
input 	inclk0;
output 	c0;
output 	c1;

wire gnd;
wire vcc;
wire unknown;

assign gnd = 1'b0;
assign vcc = 1'b1;
// unknown value (1'bx) is not needed for this tool. Default to 1'b0
assign unknown = 1'b0;

wire \altpll_component|_clk0 ;
wire \altpll_component|_clk1 ;


pll_altpll_1 altpll_component(
	._clk0(\altpll_component|_clk0 ),
	._clk1(\altpll_component|_clk1 ),
	.inclk({gnd,inclk0}));

assign c0 = \altpll_component|_clk0 ;

assign c1 = \altpll_component|_clk1 ;

endmodule

module pll_altpll_1 (
	_clk0,
	_clk1,
	inclk)/* synthesis synthesis_greybox=0 */;
output 	_clk0;
output 	_clk1;
input 	[1:0] inclk;

wire gnd;
wire vcc;
wire unknown;

assign gnd = 1'b0;
assign vcc = 1'b1;
// unknown value (1'bx) is not needed for this tool. Default to 1'b0
assign unknown = 1'b0;

wire \pll~CLK2 ;

wire [2:0] pll_CLK_bus;

assign _clk0 = pll_CLK_bus[0];
assign _clk1 = pll_CLK_bus[1];
assign \pll~CLK2  = pll_CLK_bus[2];

cycloneii_pll pll(
	.ena(vcc),
	.clkswitch(gnd),
	.areset(gnd),
	.pfdena(vcc),
	.testclearlock(gnd),
	.sbdin(gnd),
	.inclk({gnd,inclk[0]}),
	.locked(),
	.testupout(),
	.testdownout(),
	.sbdout(),
	.clk(pll_CLK_bus));
defparam pll.bandwidth = 0;
defparam pll.bandwidth_type = "auto";
defparam pll.c0_high = 15;
defparam pll.c0_initial = 1;
defparam pll.c0_low = 15;
defparam pll.c0_mode = "even";
defparam pll.c0_ph = 0;
defparam pll.c1_high = 8;
defparam pll.c1_initial = 1;
defparam pll.c1_low = 7;
defparam pll.c1_mode = "odd";
defparam pll.c1_ph = 0;
defparam pll.c2_mode = "bypass";
defparam pll.c2_ph = 0;
defparam pll.charge_pump_current = 80;
defparam pll.clk0_counter = "c0";
defparam pll.clk0_divide_by = 5;
defparam pll.clk0_duty_cycle = 50;
defparam pll.clk0_multiply_by = 2;
defparam pll.clk0_phase_shift = "0";
defparam pll.clk1_counter = "c1";
defparam pll.clk1_divide_by = 5;
defparam pll.clk1_duty_cycle = 50;
defparam pll.clk1_multiply_by = 4;
defparam pll.clk1_phase_shift = "0";
defparam pll.clk2_duty_cycle = 50;
defparam pll.clk2_phase_shift = "0";
defparam pll.compensate_clock = "clk0";
defparam pll.gate_lock_counter = 0;
defparam pll.gate_lock_signal = "no";
defparam pll.inclk0_input_frequency = 20000;
defparam pll.inclk1_input_frequency = 20000;
defparam pll.invalid_lock_multiplier = 5;
defparam pll.loop_filter_c = 3;
defparam pll.loop_filter_r = " 1.000000";
defparam pll.m = 12;
defparam pll.m_initial = 1;
defparam pll.m_ph = 0;
defparam pll.n = 1;
defparam pll.operation_mode = "normal";
defparam pll.pfd_max = 100000;
defparam pll.pfd_min = 2484;
defparam pll.self_reset_on_gated_loss_lock = "off";
defparam pll.sim_gate_lock_device_behavior = "off";
defparam pll.simulation_type = "timing";
defparam pll.valid_lock_multiplier = 1;
defparam pll.vco_center = 1333;
defparam pll.vco_max = 2000;
defparam pll.vco_min = 1000;

endmodule
