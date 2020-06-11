// CSE140L -- lab 5
// applies done flag when cycle_ct = 255
module top_level5(
  input        clk, init, 
  output logic done);

  
  //Cycle counter
  //logic       initQ    = 0;          // previous value of init, for edge detection
  logic[15:0] cycle_ct = 0;
  
  //LFSR
  logic[5:0] LFSR[64];               // LFSR states
  logic[5:0] LFSR_ptrn[6];           // the 6 possible maximal length LFSR patterns
  logic[5:0] taps;                   //    one of these 6 tap patterns
  logic[7:0] prel;                   // preamble length
  logic[5:0] lfsr_trial[6][7];       // 6 possible LFSR match trials, each 7 cycles deep
  logic[7:0] foundit;                // got a match for LFSR
  
  //prelen
  int        km;                     // number of ASCII _ in front of decoded message
  
  //memory connection variables
  logic             write_en;			 // added, memory_connection
  logic[7:0]        raddr, 			 // added, memory_connection
                    waddr;				 // added, memory_connection
  logic[7:0]        data_in;			 // added, memory_connection
  logic[7:0]        data_out;     	 // added, memory_connection
  logic[7:0]        scram;           // encrypted character 
  logic[7:0]		  unscram;			 // decrypted character
  
  logic [6:0] i;
  logic foundKm;
  
 
  //Initializing LFSR patterns
  assign LFSR_ptrn[0] = 6'h21;
  assign LFSR_ptrn[1] = 6'h2D;
  assign LFSR_ptrn[2] = 6'h30;
  assign LFSR_ptrn[3] = 6'h33;
  assign LFSR_ptrn[4] = 6'h36;
  assign LFSR_ptrn[5] = 6'h39;
  
	
  //Initializing loop variables
	initial begin
	 foundKm = 0;
	 km = 0;
	end

  dat_mem dm1(.clk, .write_en, .raddr, .waddr, // memory_connection
       .data_in, .data_out);                   // instantiate data memory
		 
//Program counter
always @(posedge clk) begin
  if(init)
    cycle_ct <= 0;
  else
	 cycle_ct <= cycle_ct + 1;     // default: next_ct = ct+1	
	 
end

//Load control registers from dat_mem	 
always @(posedge clk) begin
scram = data_out;
data_in = unscram;

if (cycle_ct > 182 && cycle_ct < 247) begin
	$display("Foundkm: %d, scram: %h, km: %d", foundKm, scram, km);
	if (scram != 8'h5f && foundKm != 1) begin
		km = cycle_ct - 183 - 11;
		foundKm = 1;
	end
end

end


always_comb begin  //:clock_loop
    raddr = (64 + cycle_ct) - 1;
	 i = 0;
	 write_en = 0;
	 
//Step 1 and 2: Getting initial LFSR values to do trial	 
if(cycle_ct < 8 && cycle_ct > 0) begin

	if(cycle_ct == 1) begin
		     lfsr_trial[0][0] = scram[5:0] ^ 6'h1f;
           lfsr_trial[1][0] = scram[5:0] ^ 6'h1f;
           lfsr_trial[2][0] = scram[5:0] ^ 6'h1f;
           lfsr_trial[3][0] = scram[5:0] ^ 6'h1f;
           lfsr_trial[4][0] = scram[5:0] ^ 6'h1f;
           lfsr_trial[5][0] = scram[5:0] ^ 6'h1f;
	end
	
	LFSR[cycle_ct - 1] = scram[5:0] ^ 6'h1f;

end 

//Step 3: Figure out which of 6 LFSR tap patterns the encoder used
if(cycle_ct < 14 && cycle_ct > 7) begin 
	i = cycle_ct - 8;
	
	lfsr_trial[0][i + 1] = (lfsr_trial[0][i]<<1)+(^(lfsr_trial[0][i]&LFSR_ptrn[0]));   
   lfsr_trial[1][i + 1] = (lfsr_trial[1][i]<<1)+(^(lfsr_trial[1][i]&LFSR_ptrn[1]));   
   lfsr_trial[2][i + 1] = (lfsr_trial[2][i]<<1)+(^(lfsr_trial[2][i]&LFSR_ptrn[2]));   
   lfsr_trial[3][i + 1] = (lfsr_trial[3][i]<<1)+(^(lfsr_trial[3][i]&LFSR_ptrn[3]));   
   lfsr_trial[4][i + 1] = (lfsr_trial[4][i]<<1)+(^(lfsr_trial[4][i]&LFSR_ptrn[4]));   
   lfsr_trial[5][i + 1] = (lfsr_trial[5][i]<<1)+(^(lfsr_trial[5][i]&LFSR_ptrn[5]));   
   
	//Debug messages
	$display("trials %d %h %h %h %h %h %h    %h",  i,
		lfsr_trial[0][i+1],
		lfsr_trial[1][i+1],
		lfsr_trial[2][i+1],
		lfsr_trial[3][i+1],
		lfsr_trial[4][i+1],
	   lfsr_trial[5][i+1],
      LFSR[i+1]);
		
end

if(cycle_ct < 20 && cycle_ct > 13) begin 
	i = cycle_ct - 14;
	
	//Debug messages
	$display("i = %d  lfsr_trial[i] = %h, LFSR[6] = %h",
			     i, lfsr_trial[i][6], LFSR[6]); 
	
	
	if(lfsr_trial[i][6] == LFSR[6]) begin
		foundit = i;
		//Debug message
		$display("foundit = %d LFSR[6] = %h", foundit, LFSR[6]);
   end
	
end

//cycle_ct is currently at 20

//Step 4: Decode the message, one character / clock cycle

if (cycle_ct > 19 && cycle_ct < 83) begin
	i = cycle_ct - 20;	
	LFSR[i+1] = ((LFSR[i] << 1) + (^(LFSR[i] & LFSR_ptrn[foundit])));
end


//cycle_ct is currently at 83

if (cycle_ct > 82 && cycle_ct < 183) begin
	i = ((cycle_ct - 83) >> 1) + 7;
	if (cycle_ct & 1'b1 == 1) begin // if is first
		//$display("cycle_ct: %d. i: %d", cycle_ct, i);
		write_en = 0;
		raddr = 64 + i - 7;
		waddr = i - 7 - 1;
	end
	else begin							 // if is second
		raddr = 64 + i - 7;
		waddr = i - 7 - 1;
		write_en = 1;
		//$display("cycle_ct: %d. i: %d", cycle_ct, i);
		unscram = scram ^ {2'b0,LFSR[i-7]};
		//$display("unscram is: %h" , unscram);
	end
end
/*

	raddr = cycle_ct + 51;	
	waddr = cycle_ct - 20;
	unscram = scram[5:0] ^ LFSR_ptrn[foundit];
*/

//Step 5:
  


// cycle_ct = 247
if (cycle_ct > 246 && cycle_ct < 377) begin
	i = (cycle_ct - 247) >> 1;

	if (cycle_ct & 1'b1 == 1) begin 	// first 
		$display("cycle_ct: %d. i: %d", cycle_ct, i);
		raddr = i + km + 1;
		waddr = i - 1;
		write_en = 1;
	end
	else begin								// second
		//$display("cycle_ct: %d. i: %d", cycle_ct, i);
		raddr = i + km + 1;
		waddr = i - 1;
		write_en = 1;
		unscram = scram;
	end
	
end

  
end
  
  always_comb
    done = &cycle_ct[9:0];   // holds for two clocks

endmodule