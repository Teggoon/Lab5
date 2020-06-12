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
  logic[5:0] 		  LFSR_seq[64]; 	 // seq
  logic[7:0] 		  unscram_seq; 	 // seq
  logic[7:0]		  foundit_seq;		 // seq
  logic[5:0] 		  lfsr_trial_seq[6][7];  // seq
  logic 				  unscram_write;	 // seq write
  logic				  lfsr_trial_write;// seq write
  logic				  LFSR_write[64];		 // seq write
  logic		  		  foundit_write;		 // seq write
  
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
	 unscram_seq = 7'h0;
	 for (int a = 0; a < 64; a++) begin
		LFSR_seq[a] = 5'h0;
	 end
	 for (int a = 0; a < 6; a++) begin
		for (int b = 0; b < 7; b++) begin
			lfsr_trial_seq[a][b] = 5'h0;
		end
	 end
	end

  dat_mem dm1(.clk, .write_en, .raddr, .waddr, // memory_connection
       .data_in, .data_out);                   // instantiate data memory
		 
//Program counter
always @(posedge clk) begin
  if(init)
    cycle_ct <= 15'hFFFF;
  else
	 cycle_ct <= cycle_ct + 1;     // default: next_ct = ct+1	
	 
end

//Load control registers from dat_mem	 
always @(posedge clk) begin
scram = data_out;
if (unscram_write == 1) begin
	unscram_seq = unscram;
end

if (foundit_write == 1) begin
	foundit_seq = foundit;
end

for (int a = 0; a < 64; a++) begin
	if (LFSR_write[a] == 1) begin
		LFSR_seq[a] = LFSR[a];
	end
end

if (lfsr_trial_write == 1) begin
	$display("At least chin is being written!!");
	 for (int a = 0; a < 6; a++) begin
		for (int b = 0; b < 7; b++) begin
			lfsr_trial_seq[a][b] = lfsr_trial[a][b];
		end
		/*$display("\n    cycle_ct:", cycle_ct);
		$display("lfsr_trial_seq 0: %h, %h, %h, %h, %h, %h, %h", lfsr_trial_seq[0][0], lfsr_trial_seq[0][1], lfsr_trial_seq[0][2], lfsr_trial_seq[0][3], lfsr_trial_seq[0][4], lfsr_trial_seq[0][5], lfsr_trial_seq[0][6]);
		$display("lfsr_trial_seq 1: %h, %h, %h, %h, %h, %h, %h", lfsr_trial_seq[1][0], lfsr_trial_seq[1][1], lfsr_trial_seq[1][2], lfsr_trial_seq[1][3], lfsr_trial_seq[1][4], lfsr_trial_seq[1][5], lfsr_trial_seq[1][6]);
		$display("lfsr_trial_seq 2: %h, %h, %h, %h, %h, %h, %h", lfsr_trial_seq[2][0], lfsr_trial_seq[2][1], lfsr_trial_seq[2][2], lfsr_trial_seq[2][3], lfsr_trial_seq[2][4], lfsr_trial_seq[2][5], lfsr_trial_seq[2][6]);
		$display("lfsr_trial_seq 3: %h, %h, %h, %h, %h, %h, %h", lfsr_trial_seq[3][0], lfsr_trial_seq[3][1], lfsr_trial_seq[3][2], lfsr_trial_seq[3][3], lfsr_trial_seq[3][4], lfsr_trial_seq[3][5], lfsr_trial_seq[3][6]);
		$display("lfsr_trial_seq 4: %h, %h, %h, %h, %h, %h, %h", lfsr_trial_seq[4][0], lfsr_trial_seq[4][1], lfsr_trial_seq[4][2], lfsr_trial_seq[4][3], lfsr_trial_seq[4][4], lfsr_trial_seq[4][5], lfsr_trial_seq[4][6]);
		$display("lfsr_trial_seq 5: %h, %h, %h, %h, %h, %h, %h", lfsr_trial_seq[5][0], lfsr_trial_seq[5][1], lfsr_trial_seq[5][2], lfsr_trial_seq[5][3], lfsr_trial_seq[5][4], lfsr_trial_seq[5][5], lfsr_trial_seq[5][6]);
		*/
	 end
end

data_in = unscram_seq;


// Step 4: cycle_ct is 185

if (cycle_ct > 184 && cycle_ct < 249) begin
	$display("Foundkm: %d, scram: %h, km: %d", foundKm, scram, km);
	if (scram != 8'h5f && foundKm != 1) begin
		km = cycle_ct - 185;
		foundKm = 1;
	end
end

end


always_comb begin  //:clock_loop
    raddr = 64;
	 i = 0;
	 write_en = 0;
	 waddr = 7'h0;
	 unscram = 7'h0;
	 unscram_write = 0;
	 for (int a = 0; a < 64; a++) begin
		LFSR[a] = cycle_ct;
		LFSR_write[a] = 0;
	 end
	 for (int a = 0; a < 6; a++) begin
		for (int b = 0; b < 7; b++) begin
			lfsr_trial[a][b] = 5'h0d;
		end
	 end
	 
	 lfsr_trial_write = 0;
	 foundit = 0;
	 foundit_write = 0;
	 
//Step 1 and 2: Getting initial LFSR values to do trial	 


if(cycle_ct < 8 && cycle_ct > 0) begin

	raddr = (64 + cycle_ct) - 1;
	if(cycle_ct == 1) begin
			  lfsr_trial_write = 1;
		     lfsr_trial[0][0] = scram[5:0] ^ 6'h1f;
           lfsr_trial[1][0] = scram[5:0] ^ 6'h1f;
           lfsr_trial[2][0] = scram[5:0] ^ 6'h1f;
           lfsr_trial[3][0] = scram[5:0] ^ 6'h1f;
           lfsr_trial[4][0] = scram[5:0] ^ 6'h1f;
           lfsr_trial[5][0] = scram[5:0] ^ 6'h1f;
	end
	
	$display(lfsr_trial);
	
	LFSR[cycle_ct - 1] = scram[5:0] ^ 6'h1f;
	LFSR_write[cycle_ct - 1] = 1;
	$display("LFSR[ %d ]: %h",cycle_ct - 1,LFSR[cycle_ct - 1]);

end 

if (cycle_ct == 8) begin
	LFSR_write[6] = 1;
	LFSR[6] = scram[5:0] ^ 6'h1f;
end

//Step 3: Figure out which of 6 LFSR tap patterns the encoder used
if(cycle_ct < 14 && cycle_ct > 7) begin 
	i = cycle_ct - 8;

	lfsr_trial_write = 1;	
	lfsr_trial[0][i + 1] = (lfsr_trial_seq[0][i]<<1)+(^(lfsr_trial_seq[0][i]&LFSR_ptrn[0]));   
   lfsr_trial[1][i + 1] = (lfsr_trial_seq[1][i]<<1)+(^(lfsr_trial_seq[1][i]&LFSR_ptrn[1]));   
   lfsr_trial[2][i + 1] = (lfsr_trial_seq[2][i]<<1)+(^(lfsr_trial_seq[2][i]&LFSR_ptrn[2]));   
   lfsr_trial[3][i + 1] = (lfsr_trial_seq[3][i]<<1)+(^(lfsr_trial_seq[3][i]&LFSR_ptrn[3]));   
   lfsr_trial[4][i + 1] = (lfsr_trial_seq[4][i]<<1)+(^(lfsr_trial_seq[4][i]&LFSR_ptrn[4]));   
   lfsr_trial[5][i + 1] = (lfsr_trial_seq[5][i]<<1)+(^(lfsr_trial_seq[5][i]&LFSR_ptrn[5]));   
   
	//Debug messages
	$display("trials %d %h %h %h %h %h %h    %h",  i,
		lfsr_trial[0][i+1],
		lfsr_trial[1][i+1],
		lfsr_trial[2][i+1],
		lfsr_trial[3][i+1],
		lfsr_trial[4][i+1],
	   lfsr_trial[5][i+1],
      LFSR_seq[i+1]);
		
end

if(cycle_ct < 20 && cycle_ct > 13) begin 
	i = cycle_ct - 14;
	
	//Debug messages
	$display("i = %d  lfsr_trial[i] = %h, LFSR[6] = %h",
			     i, lfsr_trial_seq[i][6], LFSR_seq[6]); 
	
	
	if(lfsr_trial_seq[i][6] == LFSR_seq[6]) begin
		foundit = i;
		foundit_write = 1;
		//Debug message
		$display("foundit = %d LFSR[6] = %h", foundit, LFSR_seq[6]);
   end
	
end

//cycle_ct is currently at 20

//Step 4: Decode the message, one character / clock cycle

if (cycle_ct > 19 && cycle_ct < 83) begin
	i = cycle_ct - 20;	
	LFSR_write[i+1] = 1;
	LFSR[i+1] = ((LFSR_seq[i] << 1) + (^(LFSR_seq[i] & LFSR_ptrn[foundit_seq])));
	$display("LFSR_ptrn found it: %h", LFSR_ptrn[foundit_seq]);
	
	if (cycle_ct == 82) begin
		//for (int a = 0; a < 64; a++) $display("LFSR please. %h", LFSR[a]);
	end
end


//cycle_ct is currently at 83

if (cycle_ct > 82 && cycle_ct < 185) begin
	i = ((cycle_ct - 83) >> 1) + 7;
	$display("cycle_ct: %d. i: %d", cycle_ct, i);
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
		unscram_write = 1;
		unscram = scram ^ {2'b0,LFSR_seq[i-7]};
		$display("scram is: %h" , scram);
		$display("LFSR_seq[i-7] is: %h" , LFSR_seq[i-7]);
	end
end
/*

	raddr = cycle_ct + 51;	
	waddr = cycle_ct - 20;
	unscram = scram[5:0] ^ LFSR_ptrn[foundit];
*/

//Step 5:
  

if (cycle_ct > 184 && cycle_ct < 249) begin
	raddr = cycle_ct - 185;
end

// cycle_ct = 249
if (cycle_ct > 248 && cycle_ct < 379) begin
	i = (cycle_ct - 249) >> 1;

	if (cycle_ct & 1'b1 == 1) begin 	// first 
		//$display("cycle_ct: %d. i: %d", cycle_ct, i);
		raddr = i + km;
		waddr = i - 1;
		write_en = 1;
	end
	else begin								// second
		//$display("cycle_ct: %d. i: %d", cycle_ct, i);
		raddr = i + km;
		waddr = i - 1;
		write_en = 1;
		unscram_write = 1;
		unscram = scram;
	end
	
end



  
end
  
  always_comb
    done = (cycle_ct == 15'h190 ? 1: 0);   // holds for two clocks

endmodule