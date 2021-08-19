// this can be used in simulation to avoid waiting cycles for the led blinking
mem['h0000] <= 32'h00000013;
mem['h0001] <= 32'h02800093;

mem['h0002] <= 32'h00000113;  //           li      x2,0
mem['h0003] <= 32'h00000193;  //           li      x3,0
mem['h0004] <= 32'h00110113;  //     loop: addi    x2,x2,1
mem['h0005] <= 32'hfe111ee3;  //           beq     x2,x1,10 <loop>
mem['h0006] <= 32'hfff1c193;  //           not     x3,x3
mem['h0007] <= 32'h20000237;  //           lui     x4,0x20000
mem['h0008] <= 32'h00322023;  //           sw      x3,0(x4) # 20000000 <loop+0x1ffffff0>
mem['h0009] <= 32'h00000113;  //           li      x2,0
mem['h000a] <= 32'hfe9ff06f;  //           j       10 <loop>