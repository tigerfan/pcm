// Generator : SpinalHDL v1.7.0a    git head : 150a9b9067020722818dfb17df4a23ac712a7af8
// Component : pcm

`timescale 1ns/1ps

module pcm (
  input               io_sysRst,
  input               io_bitSync,
  input               io_nrzl,
  output              io_frameSync,
  output              io_isAnti,
  output              io_nearCode,
  output              io_wordSync,
  output     [7:0]    io_pcmData
);

  wire                fs_mk_1_io_frameSync;
  wire                fs_mk_1_io_isAnti;
  wire                fs_mk_1_io_nearCode;
  wire                fs_mk_1_io_wordSync;
  wire       [7:0]    fs_mk_1_io_pcmData;

  fs_mk fs_mk_1 (
    .io_nrzl      (io_nrzl                ), //i
    .io_frameSync (fs_mk_1_io_frameSync   ), //o
    .io_isAnti    (fs_mk_1_io_isAnti      ), //o
    .io_nearCode  (fs_mk_1_io_nearCode    ), //o
    .io_wordSync  (fs_mk_1_io_wordSync    ), //o
    .io_pcmData   (fs_mk_1_io_pcmData[7:0]), //o
    .io_bitSync   (io_bitSync             ), //i
    .io_sysRst    (io_sysRst              )  //i
  );
  assign io_frameSync = fs_mk_1_io_frameSync;
  assign io_isAnti = fs_mk_1_io_isAnti;
  assign io_nearCode = fs_mk_1_io_nearCode;
  assign io_wordSync = fs_mk_1_io_wordSync;
  assign io_pcmData = fs_mk_1_io_pcmData;

endmodule

module fs_mk (
  input               io_nrzl,
  output              io_frameSync,
  output              io_isAnti,
  output              io_nearCode,
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
  wire       [7:0]    _zz_io_wordSync;
  wire       [15:0]   synCode;
  wire       [15:0]   antiCode;
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
  wire                when_pcm_l68;
  wire                when_pcm_l68_1;
  wire                when_pcm_l68_2;
  wire                when_pcm_l68_3;
  wire                when_pcm_l68_4;
  wire                when_pcm_l68_5;
  wire                when_pcm_l68_6;
  wire                when_pcm_l68_7;
  wire                when_pcm_l68_8;
  wire                when_pcm_l68_9;
  wire                when_pcm_l68_10;
  wire                when_pcm_l68_11;
  wire                when_pcm_l68_12;
  wire                when_pcm_l68_13;
  wire                when_pcm_l68_14;
  wire                when_pcm_l68_15;
  wire       [4:0]    corrSum;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg        [7:0]    fsm_frameCounter;
  reg        [1:0]    fsm_missCounter;
  wire                fsm_frameEnd;
  wire                fsm_findCode;
  reg        [7:0]    shiftByte;
  reg        [7:0]    shiftByte_regNextWhen;
  reg        [1:0]    fsm_stateReg;
  reg        [1:0]    fsm_stateNext;
  wire                when_pcm_l106;
  wire                when_pcm_l109;
  wire                when_pcm_l123;
  wire                when_pcm_l126;
  wire                when_pcm_l129;
  wire                when_StateMachine_l245;
  wire                when_StateMachine_l245_1;
  `ifndef SYNTHESIS
  reg [87:0] fsm_stateReg_string;
  reg [87:0] fsm_stateNext_string;
  `endif


  assign _zz_corrSum = (_zz_corrSum_1 + _zz_corrSum_4);
  assign _zz_corrSum_1 = (_zz_corrSum_2 + _zz_corrSum_3);
  assign _zz_corrSum_2 = (corrVal_0 + corrVal_1);
  assign _zz_corrSum_3 = (corrVal_2 + corrVal_3);
  assign _zz_corrSum_4 = (_zz_corrSum_5 + _zz_corrSum_6);
  assign _zz_corrSum_5 = (corrVal_4 + corrVal_5);
  assign _zz_corrSum_6 = (corrVal_6 + corrVal_7);
  assign _zz_corrSum_7 = (_zz_corrSum_8 + _zz_corrSum_11);
  assign _zz_corrSum_8 = (_zz_corrSum_9 + _zz_corrSum_10);
  assign _zz_corrSum_9 = (corrVal_8 + corrVal_9);
  assign _zz_corrSum_10 = (corrVal_10 + corrVal_11);
  assign _zz_corrSum_11 = (_zz_corrSum_12 + _zz_corrSum_13);
  assign _zz_corrSum_12 = (corrVal_12 + corrVal_13);
  assign _zz_corrSum_13 = (corrVal_14 + corrVal_15);
  assign _zz_io_wordSync = (fsm_frameCounter % 4'b1000);
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

  assign synCode = 16'heb90;
  assign antiCode = (~ synCode);
  assign when_pcm_l68 = (shiftReg_0 ^ synCode[0]);
  always @(*) begin
    if(when_pcm_l68) begin
      corrVal_0 = 5'h01;
    end else begin
      corrVal_0 = 5'h0;
    end
  end

  assign when_pcm_l68_1 = (shiftReg_1 ^ synCode[1]);
  always @(*) begin
    if(when_pcm_l68_1) begin
      corrVal_1 = 5'h01;
    end else begin
      corrVal_1 = 5'h0;
    end
  end

  assign when_pcm_l68_2 = (shiftReg_2 ^ synCode[2]);
  always @(*) begin
    if(when_pcm_l68_2) begin
      corrVal_2 = 5'h01;
    end else begin
      corrVal_2 = 5'h0;
    end
  end

  assign when_pcm_l68_3 = (shiftReg_3 ^ synCode[3]);
  always @(*) begin
    if(when_pcm_l68_3) begin
      corrVal_3 = 5'h01;
    end else begin
      corrVal_3 = 5'h0;
    end
  end

  assign when_pcm_l68_4 = (shiftReg_4 ^ synCode[4]);
  always @(*) begin
    if(when_pcm_l68_4) begin
      corrVal_4 = 5'h01;
    end else begin
      corrVal_4 = 5'h0;
    end
  end

  assign when_pcm_l68_5 = (shiftReg_5 ^ synCode[5]);
  always @(*) begin
    if(when_pcm_l68_5) begin
      corrVal_5 = 5'h01;
    end else begin
      corrVal_5 = 5'h0;
    end
  end

  assign when_pcm_l68_6 = (shiftReg_6 ^ synCode[6]);
  always @(*) begin
    if(when_pcm_l68_6) begin
      corrVal_6 = 5'h01;
    end else begin
      corrVal_6 = 5'h0;
    end
  end

  assign when_pcm_l68_7 = (shiftReg_7 ^ synCode[7]);
  always @(*) begin
    if(when_pcm_l68_7) begin
      corrVal_7 = 5'h01;
    end else begin
      corrVal_7 = 5'h0;
    end
  end

  assign when_pcm_l68_8 = (shiftReg_8 ^ synCode[8]);
  always @(*) begin
    if(when_pcm_l68_8) begin
      corrVal_8 = 5'h01;
    end else begin
      corrVal_8 = 5'h0;
    end
  end

  assign when_pcm_l68_9 = (shiftReg_9 ^ synCode[9]);
  always @(*) begin
    if(when_pcm_l68_9) begin
      corrVal_9 = 5'h01;
    end else begin
      corrVal_9 = 5'h0;
    end
  end

  assign when_pcm_l68_10 = (shiftReg_10 ^ synCode[10]);
  always @(*) begin
    if(when_pcm_l68_10) begin
      corrVal_10 = 5'h01;
    end else begin
      corrVal_10 = 5'h0;
    end
  end

  assign when_pcm_l68_11 = (shiftReg_11 ^ synCode[11]);
  always @(*) begin
    if(when_pcm_l68_11) begin
      corrVal_11 = 5'h01;
    end else begin
      corrVal_11 = 5'h0;
    end
  end

  assign when_pcm_l68_12 = (shiftReg_12 ^ synCode[12]);
  always @(*) begin
    if(when_pcm_l68_12) begin
      corrVal_12 = 5'h01;
    end else begin
      corrVal_12 = 5'h0;
    end
  end

  assign when_pcm_l68_13 = (shiftReg_13 ^ synCode[13]);
  always @(*) begin
    if(when_pcm_l68_13) begin
      corrVal_13 = 5'h01;
    end else begin
      corrVal_13 = 5'h0;
    end
  end

  assign when_pcm_l68_14 = (shiftReg_14 ^ synCode[14]);
  always @(*) begin
    if(when_pcm_l68_14) begin
      corrVal_14 = 5'h01;
    end else begin
      corrVal_14 = 5'h0;
    end
  end

  assign when_pcm_l68_15 = (shiftReg_15 ^ synCode[15]);
  always @(*) begin
    if(when_pcm_l68_15) begin
      corrVal_15 = 5'h01;
    end else begin
      corrVal_15 = 5'h0;
    end
  end

  assign corrSum = (_zz_corrSum + _zz_corrSum_7);
  assign io_frameSync = (corrSum == 5'h0);
  assign io_isAnti = (corrSum == 5'h10);
  assign io_nearCode = (corrSum == 5'h01);
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
  assign fsm_frameEnd = (fsm_frameCounter == 8'hff);
  assign fsm_findCode = ((io_frameSync || io_isAnti) || io_nearCode);
  assign io_wordSync = (_zz_io_wordSync == 8'h0);
  assign io_pcmData = shiftByte_regNextWhen;
  always @(*) begin
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      fsm_enumDef_stateSearch : begin
        if(fsm_findCode) begin
          fsm_stateNext = fsm_enumDef_stateCheck;
        end
      end
      fsm_enumDef_stateCheck : begin
        if(when_pcm_l106) begin
          fsm_stateNext = fsm_enumDef_stateSync;
        end
      end
      fsm_enumDef_stateSync : begin
        if(when_pcm_l129) begin
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

  assign when_pcm_l106 = (io_frameSync && fsm_frameEnd);
  assign when_pcm_l109 = (io_frameSync || fsm_frameEnd);
  assign when_pcm_l123 = (fsm_frameEnd && fsm_findCode);
  assign when_pcm_l126 = (fsm_frameEnd && (! fsm_findCode));
  assign when_pcm_l129 = (2'b10 <= fsm_missCounter);
  assign when_StateMachine_l245 = ((! (fsm_stateReg == fsm_enumDef_stateCheck)) && (fsm_stateNext == fsm_enumDef_stateCheck));
  assign when_StateMachine_l245_1 = ((! (fsm_stateReg == fsm_enumDef_stateSync)) && (fsm_stateNext == fsm_enumDef_stateSync));
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
    shiftByte[0] <= shiftReg_0;
    shiftByte[1] <= shiftReg_1;
    shiftByte[2] <= shiftReg_2;
    shiftByte[3] <= shiftReg_3;
    shiftByte[4] <= shiftReg_4;
    shiftByte[5] <= shiftReg_5;
    shiftByte[6] <= shiftReg_6;
    shiftByte[7] <= shiftReg_7;
    if(io_wordSync) begin
      shiftByte_regNextWhen <= shiftByte;
    end
  end

  always @(posedge io_bitSync or negedge io_sysRst) begin
    if(!io_sysRst) begin
      fsm_frameCounter <= 8'h0;
      fsm_missCounter <= 2'b00;
      fsm_stateReg <= fsm_enumDef_BOOT;
    end else begin
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        fsm_enumDef_stateSearch : begin
        end
        fsm_enumDef_stateCheck : begin
          fsm_frameCounter <= (fsm_frameCounter + 8'h01);
          if(when_pcm_l109) begin
            fsm_frameCounter <= 8'h0;
          end
        end
        fsm_enumDef_stateSync : begin
          fsm_frameCounter <= (fsm_frameCounter + 8'h01);
          if(fsm_frameEnd) begin
            fsm_frameCounter <= 8'h0;
          end
          if(when_pcm_l123) begin
            fsm_missCounter <= 2'b00;
          end
          if(when_pcm_l126) begin
            fsm_missCounter <= (fsm_missCounter + 2'b01);
          end
        end
        default : begin
        end
      endcase
      if(when_StateMachine_l245) begin
        fsm_frameCounter <= 8'h0;
      end
      if(when_StateMachine_l245_1) begin
        fsm_frameCounter <= 8'h0;
      end
    end
  end


endmodule
