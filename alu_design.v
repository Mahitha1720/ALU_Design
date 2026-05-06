module alu_design(OPA,OPB,CIN,CLK,RST,CMD,CE,MODE,INP_VALID,COUT,OFLOW,RES,G,E,L,ERR);

parameter WIDTH = 4;
parameter RES_WIDTH=8;

  input [WIDTH-1:0] OPA;
  input [WIDTH-1:0] OPB;
  input [1:0] INP_VALID;
  input CLK,RST,CE,MODE,CIN;
  input [3:0] CMD;
  output reg [RES_WIDTH-1:0] RES = 8'b0;
  output reg COUT = 1'b0;
  output reg OFLOW = 1'b0;
  output reg G = 1'b0;
  output reg E = 1'b0;
  output reg L = 1'b0;
  output reg ERR = 1'b0;

  reg [WIDTH-1:0] OPA_1, OPB_1;

  reg [1:0] mul_state;
  reg [WIDTH-1:0] mul_a, mul_b;

  reg [RES_WIDTH-1:0] RES_d;

  reg [WIDTH-1:0] temp_add;
  reg [WIDTH-1:0] temp_sub;

  parameter IDLE = 2'd0;
  parameter MUL1 = 2'd1;
  parameter MUL2 = 2'd2;
  parameter MUL3 = 2'd3;

    always@(posedge CLK)
      begin
       if(CE)
        begin
         if(RST)
          begin
            RES<=8'b00000000;
            RES_d<=8'b00000000;
            COUT<=1'b0;
            OFLOW<=1'b0;
            G<=1'b0;
            E<=1'b0;
            L<=1'b0;
            ERR<=1'b0;
            mul_state <= IDLE;
          end

         else
          begin

           RES <= RES_d;

           RES_d<=8'b00000000;
           COUT<=1'b0;
           OFLOW<=1'b0;
           G<=1'b0;
           E<=1'b0;
           L<=1'b0;
           ERR<=1'b0;

           if(mul_state != IDLE)
            begin
             if(INP_VALID != 2'b00)
              begin
               mul_state <= IDLE;
              end
             else
              begin
               case(mul_state)
                MUL1: mul_state <= MUL2;
                MUL2: mul_state <= MUL3;
                MUL3:
                 begin
                  RES_d <= mul_a * mul_b;
                  mul_state <= IDLE;
                 end
               endcase
              end
            end

           else
            begin

             if(MODE)
              begin
               RES_d<=8'b00000000;

               case(CMD)
                4'b0000:
                 begin
                  if(INP_VALID==2'b11)
                    RES_d<=OPA+OPB;
                  else
                    ERR<=1'b1;
                 end

                4'b0001:
                 begin
                  if(INP_VALID==2'b11)
                    RES_d<=OPA-OPB;
                  else
                    ERR<=1'b1;
                 end

                4'b0010:
                 begin
                  if(INP_VALID==2'b11)
                    RES_d<=OPA+OPB+CIN;
                  else
                    ERR<=1'b1;
                 end

                4'b0011:
                 begin
                  if(INP_VALID==2'b11)
                    RES_d<=OPA-OPB-CIN;
                  else
                    ERR<=1'b1;
                 end

                4'b0100:
                 begin
                  if(INP_VALID==2'b01)
                    RES_d<=OPA+1;
                  else
                    ERR<=1'b1;
                 end

                4'b0101:
                 begin
                  if(INP_VALID==2'b01)
                    RES_d<=OPA-1;
                  else
                    ERR<=1'b1;
                 end

                4'b0110:
                 begin
                  if(INP_VALID==2'b10)
                    RES_d<=OPB+1;
                  else
                    ERR<=1'b1;
                 end

                4'b0111:
                 begin
                  if(INP_VALID==2'b10)
                    RES_d<=OPB-1;
                  else
                    ERR<=1'b1;
                 end

                4'b1000:
                 begin
                  if(INP_VALID==2'b11)
                   begin
                    if(OPA==OPB)
                      E<=1'b1;
                    else if(OPA>OPB)
                      G<=1'b1;
                    else
                      L<=1'b1;
                   end
                 end

                4'b1001:
                 begin
                  if(INP_VALID==2'b11)
                   begin
                    mul_a <= OPA + 1;
                    mul_b <= OPB + 1;
                    mul_state <= MUL1;
                   end
                  else
                    ERR<=1'b1;
                 end

                4'b1010:
                 begin
                  if(INP_VALID==2'b11)
                   begin
                    mul_a <= (OPA << 1);
                    mul_b <= OPB;
                    mul_state <= MUL1;
                   end
                  else
                    ERR<=1'b1;
                 end

                4'b1011:
                 begin
                  if(INP_VALID==2'b11)
                   begin
                    temp_add = OPA + OPB;
                    RES_d <= temp_add;
                    OFLOW <= (~OPA[WIDTH-1] & ~OPB[WIDTH-1] & temp_add[WIDTH-1]) |
                             ( OPA[WIDTH-1] &  OPB[WIDTH-1] & ~temp_add[WIDTH-1]);
                   end
                  else
                    ERR<=1'b1;
                 end

                4'b1100:
                 begin
                  if(INP_VALID==2'b11)
                   begin
                    temp_sub = OPA + (~OPB + 1);
                    RES_d <= temp_sub;
                    OFLOW <= (~OPA[WIDTH-1] & OPB[WIDTH-1] & temp_sub[WIDTH-1]) |
                             ( OPA[WIDTH-1] & ~OPB[WIDTH-1] & ~temp_sub[WIDTH-1]);
                   end
                  else
                    ERR<=1'b1;
                 end

                default:
                 begin
                  RES_d<=8'b0;
                  COUT<=1'b0;
                  OFLOW<=1'b0;
                  G<=1'b0;
                  E<=1'b0;
                  L<=1'b0;
                  ERR<=1'b0;
                 end
               endcase
              end

             else
              begin
               RES_d<=8'b00000000;
               COUT<=1'b0;
               OFLOW<=1'b0;
               G<=1'b0;
               E<=1'b0;
               L<=1'b0;
               ERR<=1'b0;

               case(CMD)
                4'b0000:
                 begin
                  if(INP_VALID==2'b11)
                    RES_d<={{WIDTH{1'b0}},OPA&OPB};
                  else
                    ERR<=1'b1;
                 end

                4'b0001:
                 begin
                  if(INP_VALID==2'b11)
                    RES_d<={{WIDTH{1'b0}},~(OPA&OPB)};
                  else
                    ERR<=1'b1;
                 end

                4'b0010:
                 begin
                  if(INP_VALID==2'b11)
                    RES_d<={{WIDTH{1'b0}},OPA|OPB};
                  else
                    ERR<=1'b1;
                 end

                4'b0011:
                 begin
                  if(INP_VALID==2'b11)
                    RES_d<={{WIDTH{1'b0}},~(OPA|OPB)};
                  else
                    ERR<=1'b1;
                 end

                4'b0100:
                 begin
                  if(INP_VALID==2'b11)
                    RES_d<={{WIDTH{1'b0}},OPA^OPB};
                  else
                    ERR<=1'b1;
                 end

                4'b0101:
                 begin
                  if(INP_VALID==2'b11)
                    RES_d<={{WIDTH{1'b0}},~(OPA^OPB)};
                  else
                    ERR<=1'b1;
                 end

                4'b0110:
                 begin
                  if(INP_VALID==2'b01)
                    RES_d<={{WIDTH{1'b0}},~OPA};
                  else
                    ERR<=1'b1;
                 end

                4'b0111:
                 begin
                  if(INP_VALID==2'b10)
                    RES_d<={{WIDTH{1'b0}},~OPB};
                  else
                    ERR<=1'b1;
                 end

                4'b1000:
                 begin
                  if(INP_VALID==2'b01)
                    RES_d<={{WIDTH{1'b0}},OPA>>1};
                  else
                    ERR<=1'b1;
                 end

                4'b1001:
                 begin
                  if(INP_VALID==2'b01)
                    RES_d<={{WIDTH{1'b0}},OPA<<1};
                  else
                    ERR<=1'b1;
                 end

                4'b1010:
                 begin
                  if(INP_VALID==2'b10)
                    RES_d<={{WIDTH{1'b0}},OPB>>1};
                  else
                    ERR<=1'b1;
                 end

                4'b1011:
                 begin
                  if(INP_VALID==2'b10)
                    RES_d<={{WIDTH{1'b0}},OPB<<1};
                  else
                    ERR<=1'b1;
                 end

                4'b1100:
                 begin
                  if(INP_VALID==2'b11)
                   begin
                    RES_d <= (OPA << OPB[$clog2(WIDTH)-1:0]) |
                             (OPA >> (WIDTH - OPB[$clog2(WIDTH)-1:0]));
                    if(OPB[WIDTH-1:$clog2(WIDTH)] != 0)
                        ERR <= 1'b1;
                   end
                  else
                    ERR <= 1'b1;
                 end

                4'b1101:
                 begin
                  if(INP_VALID==2'b11)
                   begin
                    RES_d <= (OPA >> OPB[$clog2(WIDTH)-1:0]) |
                             (OPA << (WIDTH - OPB[$clog2(WIDTH)-1:0]));
                    if(OPB[WIDTH-1:$clog2(WIDTH)] != 0)
                        ERR <= 1'b1;
                   end
                  else
                    ERR <= 1'b1;
                 end

                default:
                 begin
                  RES_d<=8'b0;
                  COUT<=1'b0;
                  OFLOW<=1'b0;
                  G<=1'b0;
                  E<=1'b0;
                  L<=1'b0;
                  ERR<=1'b0;
                 end
               endcase
              end
            end
          end
        end
      end
endmodule
