// Generator : SpinalHDL v1.7.3    git head : aeaeece704fe43c766e0d36a93f2ecbb8a9f2003
// Component : my_pcm
// Git hash  : 8e8b22f6ec3191f0378aeced536ffcd14739dd33

`timescale 1ns/1ps

module my_pcm (
  input               io_sysRst,
  input               io_bitSync,
  input               io_nrzl,
  output              io_frameSync,
  output              io_wordSync,
  output     [7:0]    io_pcmData
);

  wire                fs_mk_1_io_frameSync;
  wire                fs_mk_1_io_wordSync;
  wire       [7:0]    fs_mk_1_io_pcmData;

  fs_mk fs_mk_1 (
    .io_nrzl      (io_nrzl                ), //i
    .io_frameSync (fs_mk_1_io_frameSync   ), //o
    .io_wordSync  (fs_mk_1_io_wordSync    ), //o
    .io_pcmData   (fs_mk_1_io_pcmData[7:0]), //o
    .io_bitSync   (io_bitSync             ), //i
    .io_sysRst    (io_sysRst              )  //i
  );
  assign io_frameSync = fs_mk_1_io_frameSync;
  assign io_wordSync = fs_mk_1_io_wordSync;
  assign io_pcmData = fs_mk_1_io_pcmData;

endmodule

module fs_mk (
  input               io_nrzl,
  output              io_frameSync,
  output              io_wordSync,
  output     [7:0]    io_pcmData,
  input               io_bitSync,
  input               io_sysRst
);
  localparam fsm_enumDef_BOOT = 2'd0;
  localparam fsm_enumDef_stateSearch = 2'd1;
  localparam fsm_enumDef_stateCheck = 2'd2;
  localparam fsm_enumDef_stateSync = 2'd3;

  wire       [4:0]    _zz_corrSum;
  wire       [4:0]    _zz_corrSum_1;
  wire       [4:0]    _zz_corrSum_2;
  wire       [4:0]    _zz_corrSum_3;
  wire       [4:0]    _zz_corrSum_4;
  wire       [4:0]    _zz_corrSum_5;
  wire       [4:0]    _zz_corrSum_6;
  wire       [4:0]    _zz_corrSum_7;
  wire       [4:0]    _zz_corrSum_8;
  wire       [4:0]    _zz_corrSum_9;
  wire       [4:0]    _zz_corrSum_10;
  wire       [4:0]    _zz_corrSum_11;
  wire       [4:0]    _zz_corrSum_12;
  wire       [4:0]    _zz_corrSum_13;
  wire       [4:0]    _zz_corrSum_14;
  wire       [4:0]    _zz_corrSum_15;
  wire       [4:0]    _zz_corrSum_16;
  wire       [4:0]    _zz_corrSum_17;
  wire       [4:0]    _zz_corrSum_18;
  wire       [4:0]    _zz_corrSum_19;
  wire       [4:0]    _zz_corrSum_20;
  wire       [4:0]    _zz_corrSum_21;
  wire       [3:0]    _zz_io_wordSync;
  wire       [23:0]   syncPatt;
  wire       [23:0]   antiPatt;
  reg                 shiftReg_0;
  reg                 shiftReg_1;
  reg                 shiftReg_2;
  reg                 shiftReg_3;
  reg                 shiftReg_4;
  reg                 shiftReg_5;
  reg                 shiftReg_6;
  reg                 shiftReg_7;
  reg                 shiftReg_8;
  reg                 shiftReg_9;
  reg                 shiftReg_10;
  reg                 shiftReg_11;
  reg                 shiftReg_12;
  reg                 shiftReg_13;
  reg                 shiftReg_14;
  reg                 shiftReg_15;
  reg                 shiftReg_16;
  reg                 shiftReg_17;
  reg                 shiftReg_18;
  reg                 shiftReg_19;
  reg                 shiftReg_20;
  reg                 shiftReg_21;
  reg                 shiftReg_22;
  reg                 shiftReg_23;
  reg        [4:0]    corrVal_0;
  reg        [4:0]    corrVal_1;
  reg        [4:0]    corrVal_2;
  reg        [4:0]    corrVal_3;
  reg        [4:0]    corrVal_4;
  reg        [4:0]    corrVal_5;
  reg        [4:0]    corrVal_6;
  reg        [4:0]    corrVal_7;
  reg        [4:0]    corrVal_8;
  reg        [4:0]    corrVal_9;
  reg        [4:0]    corrVal_10;
  reg        [4:0]    corrVal_11;
  reg        [4:0]    corrVal_12;
  reg        [4:0]    corrVal_13;
  reg        [4:0]    corrVal_14;
  reg        [4:0]    corrVal_15;
  reg        [4:0]    corrVal_16;
  reg        [4:0]    corrVal_17;
  reg        [4:0]    corrVal_18;
  reg        [4:0]    corrVal_19;
  reg        [4:0]    corrVal_20;
  reg        [4:0]    corrVal_21;
  reg        [4:0]    corrVal_22;
  reg        [4:0]    corrVal_23;
  wire                when_pcm_l60;
  wire                when_pcm_l60_1;
  wire                when_pcm_l60_2;
  wire                when_pcm_l60_3;
  wire                when_pcm_l60_4;
  wire                when_pcm_l60_5;
  wire                when_pcm_l60_6;
  wire                when_pcm_l60_7;
  wire                when_pcm_l60_8;
  wire                when_pcm_l60_9;
  wire                when_pcm_l60_10;
  wire                when_pcm_l60_11;
  wire                when_pcm_l60_12;
  wire                when_pcm_l60_13;
  wire                when_pcm_l60_14;
  wire                when_pcm_l60_15;
  wire                when_pcm_l60_16;
  wire                when_pcm_l60_17;
  wire                when_pcm_l60_18;
  wire                when_pcm_l60_19;
  wire                when_pcm_l60_20;
  wire                when_pcm_l60_21;
  wire                when_pcm_l60_22;
  wire                when_pcm_l60_23;
  wire       [4:0]    corrSum;
  wire                findFit;
  wire                findAnti;
  wire                findOnerr;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg        [12:0]   fsm_minorCounter;
  reg        [1:0]    fsm_missCounter;
  wire                fsm_minorTail;
  wire                fsm_findPatt;
  reg                 _zz_io_frameSync;
  reg        [7:0]    shiftByte;
  reg        [7:0]    shiftByte_regNextWhen;
  reg        [1:0]    fsm_stateReg;
  reg        [1:0]    fsm_stateNext;
  wire                when_pcm_l104;
  wire                when_pcm_l107;
  wire                when_pcm_l121;
  wire                when_pcm_l124;
  wire                when_pcm_l127;
  wire                when_StateMachine_l250;
  wire                when_StateMachine_l250_1;
  wire                when_StateMachine_l250_2;
  `ifndef SYNTHESIS
  reg [87:0] fsm_stateReg_string;
  reg [87:0] fsm_stateNext_string;
  `endif


  assign _zz_corrSum = (_zz_corrSum_1 + _zz_corrSum_8);
  assign _zz_corrSum_1 = (_zz_corrSum_2 + _zz_corrSum_5);
  assign _zz_corrSum_2 = (_zz_corrSum_3 + _zz_corrSum_4);
  assign _zz_corrSum_3 = (corrVal_0 + corrVal_1);
  assign _zz_corrSum_4 = (corrVal_2 + corrVal_3);
  assign _zz_corrSum_5 = (_zz_corrSum_6 + _zz_corrSum_7);
  assign _zz_corrSum_6 = (corrVal_4 + corrVal_5);
  assign _zz_corrSum_7 = (corrVal_6 + corrVal_7);
  assign _zz_corrSum_8 = (_zz_corrSum_9 + _zz_corrSum_12);
  assign _zz_corrSum_9 = (_zz_corrSum_10 + _zz_corrSum_11);
  assign _zz_corrSum_10 = (corrVal_8 + corrVal_9);
  assign _zz_corrSum_11 = (corrVal_10 + corrVal_11);
  assign _zz_corrSum_12 = (_zz_corrSum_13 + _zz_corrSum_14);
  assign _zz_corrSum_13 = (corrVal_12 + corrVal_13);
  assign _zz_corrSum_14 = (corrVal_14 + corrVal_15);
  assign _zz_corrSum_15 = (_zz_corrSum_16 + _zz_corrSum_19);
  assign _zz_corrSum_16 = (_zz_corrSum_17 + _zz_corrSum_18);
  assign _zz_corrSum_17 = (corrVal_16 + corrVal_17);
  assign _zz_corrSum_18 = (corrVal_18 + corrVal_19);
  assign _zz_corrSum_19 = (_zz_corrSum_20 + _zz_corrSum_21);
  assign _zz_corrSum_20 = (corrVal_20 + corrVal_21);
  assign _zz_corrSum_21 = (corrVal_22 + corrVal_23);
  assign _zz_io_wordSync = (fsm_minorCounter % 4'b1000);
  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      fsm_enumDef_BOOT : fsm_stateReg_string = "BOOT       ";
      fsm_enumDef_stateSearch : fsm_stateReg_string = "stateSearch";
      fsm_enumDef_stateCheck : fsm_stateReg_string = "stateCheck ";
      fsm_enumDef_stateSync : fsm_stateReg_string = "stateSync  ";
      default : fsm_stateReg_string = "???????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      fsm_enumDef_BOOT : fsm_stateNext_string = "BOOT       ";
      fsm_enumDef_stateSearch : fsm_stateNext_string = "stateSearch";
      fsm_enumDef_stateCheck : fsm_stateNext_string = "stateCheck ";
      fsm_enumDef_stateSync : fsm_stateNext_string = "stateSync  ";
      default : fsm_stateNext_string = "???????????";
    endcase
  end
  `endif

  assign syncPatt = 24'hfaf320;
  assign antiPatt = (~ syncPatt);
  assign when_pcm_l60 = (shiftReg_0 ^ syncPatt[0]);
  always @(*) begin
    if(when_pcm_l60) begin
      corrVal_0 = 5'h01;
    end else begin
      corrVal_0 = 5'h0;
    end
  end

  assign when_pcm_l60_1 = (shiftReg_1 ^ syncPatt[1]);
  always @(*) begin
    if(when_pcm_l60_1) begin
      corrVal_1 = 5'h01;
    end else begin
      corrVal_1 = 5'h0;
    end
  end

  assign when_pcm_l60_2 = (shiftReg_2 ^ syncPatt[2]);
  always @(*) begin
    if(when_pcm_l60_2) begin
      corrVal_2 = 5'h01;
    end else begin
      corrVal_2 = 5'h0;
    end
  end

  assign when_pcm_l60_3 = (shiftReg_3 ^ syncPatt[3]);
  always @(*) begin
    if(when_pcm_l60_3) begin
      corrVal_3 = 5'h01;
    end else begin
      corrVal_3 = 5'h0;
    end
  end

  assign when_pcm_l60_4 = (shiftReg_4 ^ syncPatt[4]);
  always @(*) begin
    if(when_pcm_l60_4) begin
      corrVal_4 = 5'h01;
    end else begin
      corrVal_4 = 5'h0;
    end
  end

  assign when_pcm_l60_5 = (shiftReg_5 ^ syncPatt[5]);
  always @(*) begin
    if(when_pcm_l60_5) begin
      corrVal_5 = 5'h01;
    end else begin
      corrVal_5 = 5'h0;
    end
  end

  assign when_pcm_l60_6 = (shiftReg_6 ^ syncPatt[6]);
  always @(*) begin
    if(when_pcm_l60_6) begin
      corrVal_6 = 5'h01;
    end else begin
      corrVal_6 = 5'h0;
    end
  end

  assign when_pcm_l60_7 = (shiftReg_7 ^ syncPatt[7]);
  always @(*) begin
    if(when_pcm_l60_7) begin
      corrVal_7 = 5'h01;
    end else begin
      corrVal_7 = 5'h0;
    end
  end

  assign when_pcm_l60_8 = (shiftReg_8 ^ syncPatt[8]);
  always @(*) begin
    if(when_pcm_l60_8) begin
      corrVal_8 = 5'h01;
    end else begin
      corrVal_8 = 5'h0;
    end
  end

  assign when_pcm_l60_9 = (shiftReg_9 ^ syncPatt[9]);
  always @(*) begin
    if(when_pcm_l60_9) begin
      corrVal_9 = 5'h01;
    end else begin
      corrVal_9 = 5'h0;
    end
  end

  assign when_pcm_l60_10 = (shiftReg_10 ^ syncPatt[10]);
  always @(*) begin
    if(when_pcm_l60_10) begin
      corrVal_10 = 5'h01;
    end else begin
      corrVal_10 = 5'h0;
    end
  end

  assign when_pcm_l60_11 = (shiftReg_11 ^ syncPatt[11]);
  always @(*) begin
    if(when_pcm_l60_11) begin
      corrVal_11 = 5'h01;
    end else begin
      corrVal_11 = 5'h0;
    end
  end

  assign when_pcm_l60_12 = (shiftReg_12 ^ syncPatt[12]);
  always @(*) begin
    if(when_pcm_l60_12) begin
      corrVal_12 = 5'h01;
    end else begin
      corrVal_12 = 5'h0;
    end
  end

  assign when_pcm_l60_13 = (shiftReg_13 ^ syncPatt[13]);
  always @(*) begin
    if(when_pcm_l60_13) begin
      corrVal_13 = 5'h01;
    end else begin
      corrVal_13 = 5'h0;
    end
  end

  assign when_pcm_l60_14 = (shiftReg_14 ^ syncPatt[14]);
  always @(*) begin
    if(when_pcm_l60_14) begin
      corrVal_14 = 5'h01;
    end else begin
      corrVal_14 = 5'h0;
    end
  end

  assign when_pcm_l60_15 = (shiftReg_15 ^ syncPatt[15]);
  always @(*) begin
    if(when_pcm_l60_15) begin
      corrVal_15 = 5'h01;
    end else begin
      corrVal_15 = 5'h0;
    end
  end

  assign when_pcm_l60_16 = (shiftReg_16 ^ syncPatt[16]);
  always @(*) begin
    if(when_pcm_l60_16) begin
      corrVal_16 = 5'h01;
    end else begin
      corrVal_16 = 5'h0;
    end
  end

  assign when_pcm_l60_17 = (shiftReg_17 ^ syncPatt[17]);
  always @(*) begin
    if(when_pcm_l60_17) begin
      corrVal_17 = 5'h01;
    end else begin
      corrVal_17 = 5'h0;
    end
  end

  assign when_pcm_l60_18 = (shiftReg_18 ^ syncPatt[18]);
  always @(*) begin
    if(when_pcm_l60_18) begin
      corrVal_18 = 5'h01;
    end else begin
      corrVal_18 = 5'h0;
    end
  end

  assign when_pcm_l60_19 = (shiftReg_19 ^ syncPatt[19]);
  always @(*) begin
    if(when_pcm_l60_19) begin
      corrVal_19 = 5'h01;
    end else begin
      corrVal_19 = 5'h0;
    end
  end

  assign when_pcm_l60_20 = (shiftReg_20 ^ syncPatt[20]);
  always @(*) begin
    if(when_pcm_l60_20) begin
      corrVal_20 = 5'h01;
    end else begin
      corrVal_20 = 5'h0;
    end
  end

  assign when_pcm_l60_21 = (shiftReg_21 ^ syncPatt[21]);
  always @(*) begin
    if(when_pcm_l60_21) begin
      corrVal_21 = 5'h01;
    end else begin
      corrVal_21 = 5'h0;
    end
  end

  assign when_pcm_l60_22 = (shiftReg_22 ^ syncPatt[22]);
  always @(*) begin
    if(when_pcm_l60_22) begin
      corrVal_22 = 5'h01;
    end else begin
      corrVal_22 = 5'h0;
    end
  end

  assign when_pcm_l60_23 = (shiftReg_23 ^ syncPatt[23]);
  always @(*) begin
    if(when_pcm_l60_23) begin
      corrVal_23 = 5'h01;
    end else begin
      corrVal_23 = 5'h0;
    end
  end

  assign corrSum = (_zz_corrSum + _zz_corrSum_15);
  assign findFit = (corrSum == 5'h0);
  assign findAnti = (corrSum == 5'h18);
  assign findOnerr = (corrSum == 5'h01);
  assign fsm_wantExit = 1'b0;
  always @(*) begin
    fsm_wantStart = 1'b0;
    case(fsm_stateReg)
      fsm_enumDef_stateSearch : begin
      end
      fsm_enumDef_stateCheck : begin
      end
      fsm_enumDef_stateSync : begin
      end
      default : begin
        fsm_wantStart = 1'b1;
      end
    endcase
  end

  assign fsm_wantKill = 1'b0;
  assign fsm_minorTail = (13'h07ff <= fsm_minorCounter);
  assign fsm_findPatt = ((findFit || findAnti) || findOnerr);
  assign io_frameSync = _zz_io_frameSync;
  assign io_wordSync = (_zz_io_wordSync == 4'b0000);
  assign io_pcmData = shiftByte_regNextWhen;
  always @(*) begin
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      fsm_enumDef_stateSearch : begin
        if(findFit) begin
          fsm_stateNext = fsm_enumDef_stateCheck;
        end
      end
      fsm_enumDef_stateCheck : begin
        if(when_pcm_l104) begin
          fsm_stateNext = fsm_enumDef_stateSync;
        end
      end
      fsm_enumDef_stateSync : begin
        if(when_pcm_l127) begin
          fsm_stateNext = fsm_enumDef_stateSearch;
        end
      end
      default : begin
      end
    endcase
    if(fsm_wantStart) begin
      fsm_stateNext = fsm_enumDef_stateSearch;
    end
    if(fsm_wantKill) begin
      fsm_stateNext = fsm_enumDef_BOOT;
    end
  end

  assign when_pcm_l104 = (findFit && fsm_minorTail);
  assign when_pcm_l107 = (findFit || fsm_minorTail);
  assign when_pcm_l121 = (findFit && fsm_minorTail);
  assign when_pcm_l124 = ((! fsm_findPatt) && fsm_minorTail);
  assign when_pcm_l127 = (2'b10 <= fsm_missCounter);
  assign when_StateMachine_l250 = ((! (fsm_stateReg == fsm_enumDef_stateSearch)) && (fsm_stateNext == fsm_enumDef_stateSearch));
  assign when_StateMachine_l250_1 = ((! (fsm_stateReg == fsm_enumDef_stateCheck)) && (fsm_stateNext == fsm_enumDef_stateCheck));
  assign when_StateMachine_l250_2 = ((! (fsm_stateReg == fsm_enumDef_stateSync)) && (fsm_stateNext == fsm_enumDef_stateSync));
  always @(posedge io_bitSync) begin
    shiftReg_0 <= io_nrzl;
    shiftReg_1 <= shiftReg_0;
    shiftReg_2 <= shiftReg_1;
    shiftReg_3 <= shiftReg_2;
    shiftReg_4 <= shiftReg_3;
    shiftReg_5 <= shiftReg_4;
    shiftReg_6 <= shiftReg_5;
    shiftReg_7 <= shiftReg_6;
    shiftReg_8 <= shiftReg_7;
    shiftReg_9 <= shiftReg_8;
    shiftReg_10 <= shiftReg_9;
    shiftReg_11 <= shiftReg_10;
    shiftReg_12 <= shiftReg_11;
    shiftReg_13 <= shiftReg_12;
    shiftReg_14 <= shiftReg_13;
    shiftReg_15 <= shiftReg_14;
    shiftReg_16 <= shiftReg_15;
    shiftReg_17 <= shiftReg_16;
    shiftReg_18 <= shiftReg_17;
    shiftReg_19 <= shiftReg_18;
    shiftReg_20 <= shiftReg_19;
    shiftReg_21 <= shiftReg_20;
    shiftReg_22 <= shiftReg_21;
    shiftReg_23 <= shiftReg_22;
    _zz_io_frameSync <= (fsm_findPatt && fsm_minorTail);
    shiftByte[0] <= shiftReg_16;
    shiftByte[1] <= shiftReg_17;
    shiftByte[2] <= shiftReg_18;
    shiftByte[3] <= shiftReg_19;
    shiftByte[4] <= shiftReg_20;
    shiftByte[5] <= shiftReg_21;
    shiftByte[6] <= shiftReg_22;
    shiftByte[7] <= shiftReg_23;
    if(io_wordSync) begin
      shiftByte_regNextWhen <= shiftByte;
    end
  end

  always @(posedge io_bitSync or negedge io_sysRst) begin
    if(!io_sysRst) begin
      fsm_minorCounter <= 13'h0;
      fsm_missCounter <= 2'b00;
      fsm_stateReg <= fsm_enumDef_BOOT;
    end else begin
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        fsm_enumDef_stateSearch : begin
          fsm_minorCounter <= (fsm_minorCounter + 13'h0001);
        end
        fsm_enumDef_stateCheck : begin
          fsm_minorCounter <= (fsm_minorCounter + 13'h0001);
          if(when_pcm_l107) begin
            fsm_minorCounter <= 13'h0;
          end
        end
        fsm_enumDef_stateSync : begin
          fsm_minorCounter <= (fsm_minorCounter + 13'h0001);
          if(fsm_minorTail) begin
            fsm_minorCounter <= 13'h0;
          end
          if(when_pcm_l121) begin
            fsm_missCounter <= 2'b00;
          end
          if(when_pcm_l124) begin
            fsm_missCounter <= (fsm_missCounter + 2'b01);
          end
          if(when_pcm_l127) begin
            fsm_missCounter <= 2'b00;
          end
        end
        default : begin
        end
      endcase
      if(when_StateMachine_l250) begin
        fsm_minorCounter <= 13'h0;
      end
      if(when_StateMachine_l250_1) begin
        fsm_minorCounter <= 13'h0;
      end
      if(when_StateMachine_l250_2) begin
        fsm_minorCounter <= 13'h0;
      end
    end
  end


endmodule
