// CSE140L -- lab 5
// applies done flag when cycle_ct = 255
module top_level5_sol(
  input        clk, init, 
  output logic done);
  logic       initQ    = 0;          // previous value of init, for edge detection
  logic[15:0] cycle_ct = 0;
  logic[5:0] LFSR[64];               // LFSR states
  logic[5:0] LFSR_ptrn[6];           // the 6 possible maximal length LFSR patterns
  logic[5:0] taps;                   //    one of these 6 tap patterns
  logic[7:0] prel;                   // preamble length
  logic[5:0] lfsr_trial[6][7];       // 6 possible LFSR match trials, each 7 cycles deep
  int        km;                     // number of ASCII _ in front of decoded message
  logic             wr_en;				// added, memory_connection
  logic       [7:0] raddr, 			// added, memory_connection
                    waddr,				// added, memory_connection
                    data_in;			// added, memory_connection
  logic[7:0] data_out;     			// added, memory_connection
  assign LFSR_ptrn[0] = 6'h21;
  assign LFSR_ptrn[1] = 6'h2D;
  assign LFSR_ptrn[2] = 6'h30;
  assign LFSR_ptrn[3] = 6'h33;
  assign LFSR_ptrn[4] = 6'h36;
  assign LFSR_ptrn[5] = 6'h39;
  logic[7:0] foundit;                // got a match for LFSR
  logic alternate_1;
  logic [4:0] step,
				  jl,
				  mm;
  logic [7:0] jm, 
				  km_loop, 
				  kl;
	initial begin
	 step = 1;
	 jl = 0;
	 kl = 0;
	 mm = 0;
	 jm = 0;
	 km_loop = 0;
	 kl = 0;
	 alternate_1 = 0;
	 wr_en = 1;
	end

  dat_mem dm1(.clk(clk), .write_en(wr_en), .raddr(raddr), .waddr(waddr), // memory_connection
       .data_in(data_out), .data_out(data_in));                   // instantiate data memory
		 
		 
	  always @(posedge clk) begin  //:clock_loop
    initQ <= init;
    if(!init)
	  cycle_ct <= cycle_ct + 1;
    if(!init && initQ) begin //:init_loop  // falling init
		
    end //:init_loop
	 begin // loop 2
	 
	  begin  //:loop2
		 if (step == 1) begin
			$display("Currently at step 1.");
			//read address should be 64+jl
			if (alternate_1 == 0) begin
			
			// number to go into raddr
			$display("Num: %h", 8'b1000000 + jl);
			
			// modify raddr
			raddr <= 8'b1000000 + jl;
			
			// this is different hmm
			$display("Raddr: %h", raddr);
			alternate_1 <= 1;
			end
			else begin // alernate_1 = 1
			$display("data_in: %h", data_in);
			LFSR[jl] <= data_in ^ 6'h1f;
			alternate_1 <= 0;
				if (jl < 7) jl <= jl + 1;
				else begin
					step <= 2;
					raddr = 64;
				end
			end
		  /*
	      LFSR[jl] =         dm1.core[64+jl][5:0]^6'h1f;
          lfsr_trial[0][0] = dm1.core[64][5:0]^6'h1f;
          lfsr_trial[1][0] = dm1.core[64][5:0]^6'h1f;
          lfsr_trial[2][0] = dm1.core[64][5:0]^6'h1f;
          lfsr_trial[3][0] = dm1.core[64][5:0]^6'h1f;
          lfsr_trial[4][0] = dm1.core[64][5:0]^6'h1f;
          lfsr_trial[5][0] = dm1.core[64][5:0]^6'h1f;
			 */
		  end // end of step 1
		  else if (step == 2) begin
		  
				lfsr_trial[0][0] <= data_in^6'h1f;
				lfsr_trial[1][0] <= data_in^6'h1f;
				lfsr_trial[2][0] <= data_in^6'h1f;
				lfsr_trial[3][0] <= data_in^6'h1f;
				lfsr_trial[4][0] <= data_in^6'h1f;
				lfsr_trial[5][0] <= data_in^6'h1f;
				step <= 3;
		  end
		  
		  else if (step == 3) begin
				
//          $display("trial 0 = %h",lfsr_trial[0][0]);
          for(int kl=0;kl<6;kl++) begin //:trial_loop
            lfsr_trial[0][kl+1] <= (lfsr_trial[0][kl]<<1)+(^(lfsr_trial[0][kl]&LFSR_ptrn[0]));   
            lfsr_trial[1][kl+1] <= (lfsr_trial[1][kl]<<1)+(^(lfsr_trial[1][kl]&LFSR_ptrn[1]));   
            lfsr_trial[2][kl+1] <= (lfsr_trial[2][kl]<<1)+(^(lfsr_trial[2][kl]&LFSR_ptrn[2]));   
            lfsr_trial[3][kl+1] <= (lfsr_trial[3][kl]<<1)+(^(lfsr_trial[3][kl]&LFSR_ptrn[3]));   
            lfsr_trial[4][kl+1] <= (lfsr_trial[4][kl]<<1)+(^(lfsr_trial[4][kl]&LFSR_ptrn[4]));   
            lfsr_trial[5][kl+1] <= (lfsr_trial[5][kl]<<1)+(^(lfsr_trial[5][kl]&LFSR_ptrn[5]));   
            $display("trials %d %h %h %h %h %h %h    %h",  kl,
				 lfsr_trial[0][kl+1],
				 lfsr_trial[1][kl+1],
				 lfsr_trial[2][kl+1],
				 lfsr_trial[3][kl+1],
				 lfsr_trial[4][kl+1],
				 lfsr_trial[5][kl+1],
				 LFSR[kl+1]);			  
          end //:trial_loop
			 
		  
		  for(int mm=0;mm<6;mm++) begin //:ureka_loop
            $display("mm = %d  lfsr_trial[mm] = %h, LFSR[6] = %h",
			     mm, lfsr_trial[mm][6], LFSR[6]); 
		    if(lfsr_trial[mm][6] == LFSR[6]) begin
			  foundit <= mm;
			  $display("foundit = %d LFSR[6] = %h",foundit,LFSR[6]);
            end
		  end //:ureka_loop
		  
		  $display("foundit fer sure = %d",foundit);		
		  
		  step <= 4;
		  
		  end // end of step 2
		  						   
		  else if (step == 4) begin 
		    LFSR[jm+1] <= (LFSR[jm]<<1)+(^(LFSR[jm]&LFSR_ptrn[foundit]));
          for(int mn=7;mn<64-7;mn++) 
				begin
				raddr <= 64 + mn - 7;
				waddr <= mn - 7;
				data_out <= data_in^{2'b0,LFSR[mn-7]};
			//$display("%dth core = %h LFSR = %h",mn,data_out,LFSR[mn-7]);
				
		 /*	
			 :first_core_write
		    dm1.core[mn-7] = dm1.core[64+mn-7]^{2'b0,LFSR[mn-7]};
			$display("%dth core = %h LFSR = %h",mn,dm1.core[64+mn-7],LFSR[mn-7]);
			  :first_core_write
		*/
				end 
         #10ns;
         for(km=0; km<64; km++) begin
				raddr <= km;
				#10ns;
            if(data_in==8'h5f) continue;
            else break;  
				/*
            if(dm1.core[km]==8'h5f) continue;
            else break;  
				*/
          end     
          //$display("underscores to %d th",km);
          for(int kl=0; kl<64; kl++) 
			 begin
			 raddr <= kl + km;
			 waddr <= kl;
			 #10ns;
			 data_out <= data_in;
		    //$display("%dth core = %h",kl,data_in);
			 
			 /*
            dm1.core[kl] = dm1.core[kl+km];
		    $display("%dth core = %h",kl,dm1.core[kl]);
			 */
          end
			 if (jm < 63) jm <= jm + 1;
			 else step <= 5;
		end // end of step 3
		else if (step == 5) begin
			for (int i = 0; i <= 60; i++) begin
				raddr = i + 71;
				waddr = i;
				#10ns;
				data_out <= {2'b0, LFSR[i]} ^ data_in;
			end // end of test loop
		end // end of step 4
	  end   //:loop2
	 end // loop 2
		
  end  //:clock_loop

  //initial 
  //  $readmemb("lab4_out.txt",dm1.core[64:127]);
  always_comb
    done = &cycle_ct[6:0];   // holds for two clocks

endmodule