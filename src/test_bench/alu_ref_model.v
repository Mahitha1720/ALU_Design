module alu_ref_model #(
    parameter WIDTH     = 4,
    parameter RES_WIDTH = 8
)(
    input  [WIDTH-1:0]   OPA, OPB,
    input                CIN, MODE, CE,
    input  [1:0]         INP_VALID,
    input  [3:0]         CMD,
    output reg [RES_WIDTH-1:0] RES,
    output reg           COUT, OFLOW, G, E, L, ERR
);

    always @(*) begin

        RES   = {RES_WIDTH{1'b0}};
        COUT  = 1'b0;
        OFLOW = 1'b0;
        G     = 1'b0;
        E     = 1'b0;
        L     = 1'b0;
        ERR   = 1'b0;

        if (CE) begin

            if (MODE) begin

                case (CMD)

                    4'b0000: begin
                        if (INP_VALID == 2'b11)
                            {COUT, RES[WIDTH-1:0]} = OPA + OPB;
                        else
                            ERR = 1'b1;
                    end

                    4'b0001: begin
                        if (INP_VALID == 2'b11) begin
                            RES   = OPA - OPB;
                            OFLOW = (OPA < OPB);
                        end else
                            ERR = 1'b1;
                    end

                    4'b0010: begin
                        if (INP_VALID == 2'b11) begin
                            RES  = OPA + OPB + CIN;
                            COUT = RES[WIDTH];
                        end else
                            ERR = 1'b1;
                    end

                    4'b0011: begin
                        if (INP_VALID == 2'b11) begin
                            RES   = OPA - OPB - CIN;
                            OFLOW = (OPA < OPB);
                        end else
                            ERR = 1'b1;
                    end

                    4'b0100: begin
                        if (INP_VALID == 2'b11 || INP_VALID == 2'b01)
                            RES = OPA + 1;
                        else
                            ERR = 1'b1;
                    end

                    4'b0101: begin
                        if (INP_VALID == 2'b11 || INP_VALID == 2'b01)
                            RES = OPA - 1;
                        else
                            ERR = 1'b1;
                    end

                    4'b0110: begin
                        if (INP_VALID == 2'b11 || INP_VALID == 2'b10)
                            RES = OPB + 1;
                        else
                            ERR = 1'b1;
                    end

                    4'b0111: begin
                        if (INP_VALID == 2'b11 || INP_VALID == 2'b10)
                            RES = OPB - 1;
                        else
                            ERR = 1'b1;
                    end

                    4'b1000: begin
                        if (INP_VALID == 2'b11) begin
                            if (OPA == OPB)      begin E = 1; G = 0; L = 0; end
                            else if (OPA > OPB)  begin E = 0; G = 1; L = 0; end
                            else                 begin E = 0; G = 0; L = 1; end
                        end else
                            ERR = 1'b1;
                    end

                    4'b1001: begin
                        if (INP_VALID == 2'b11)
                            RES = (OPA + 1) * (OPB + 1);
                        else
                            ERR = 1'b1;
                    end

                    4'b1010: begin
                        if (INP_VALID == 2'b11)
                            RES = (OPA << 1) * OPB;
                        else
                            ERR = 1'b1;
                    end

                    4'b1011: begin
                        if (INP_VALID == 2'b11) begin
                            RES   = $signed(OPA) + $signed(OPB);
                            OFLOW = (OPA[WIDTH-1] == OPB[WIDTH-1]) &&
                                    (RES[WIDTH-1] != OPA[WIDTH-1]);
                        end else
                            ERR = 1'b1;
                    end

                    4'b1100: begin
                        if (INP_VALID == 2'b11) begin
                            RES   = $signed(OPA) - $signed(OPB);
                            OFLOW = (OPA[WIDTH-1] != OPB[WIDTH-1]) &&
                                    (RES[WIDTH-1] != OPA[WIDTH-1]);
                        end else
                            ERR = 1'b1;
                    end

                    default: begin
                        RES   = {RES_WIDTH{1'b0}};
                        COUT  = 1'b0;
                        OFLOW = 1'b0;
                        G     = 1'b0;
                        E     = 1'b0;
                        L     = 1'b0;
                        ERR   = 1'b1;
                    end

                endcase

            end

            else begin

                case (CMD)

                    4'b0000: begin
                        if (INP_VALID == 2'b11)
                            RES = {{WIDTH{1'b0}}, OPA & OPB};
                        else
                            ERR = 1'b1;
                    end

                    4'b0001: begin
                        if (INP_VALID == 2'b11)
                            RES = {{WIDTH{1'b0}}, ~(OPA & OPB)};
                        else
                            ERR = 1'b1;
                    end

                    4'b0010: begin
                        if (INP_VALID == 2'b11)
                            RES = {{WIDTH{1'b0}}, OPA | OPB};
                        else
                            ERR = 1'b1;
                    end

                    4'b0011: begin
                        if (INP_VALID == 2'b11)
                            RES = {{WIDTH{1'b0}}, ~(OPA | OPB)};
                        else
                            ERR = 1'b1;
                    end

                    4'b0100: begin
                        if (INP_VALID == 2'b11)
                            RES = {{WIDTH{1'b0}}, OPA ^ OPB};
                        else
                            ERR = 1'b1;
                    end

                    4'b0101: begin
                        if (INP_VALID == 2'b11)
                            RES = {{WIDTH{1'b0}}, ~(OPA ^ OPB)};
                        else
                            ERR = 1'b1;
                    end

                    4'b0110: begin
                        if (INP_VALID == 2'b11 || INP_VALID == 2'b01)
                            RES = {{WIDTH{1'b0}}, ~OPA};
                        else
                            ERR = 1'b1;
                    end

                    4'b0111: begin
                        if (INP_VALID == 2'b11 || INP_VALID == 2'b10)
                            RES = {{WIDTH{1'b0}}, ~OPB};
                        else
                            ERR = 1'b1;
                    end

                    4'b1000: begin
                        if (INP_VALID == 2'b11)
                            RES = {{WIDTH{1'b0}}, OPA >> 1};
                        else
                            ERR = 1'b1;
                    end

                    4'b1001: begin
                        if (INP_VALID == 2'b11)
                            RES = {{WIDTH{1'b0}}, OPA << 1};
                        else
                            ERR = 1'b1;
                    end

                    4'b1010: begin
                        if (INP_VALID == 2'b11)
                            RES = {{WIDTH{1'b0}}, OPB >> 1};
                        else
                            ERR = 1'b1;
                    end

                    4'b1011: begin
                        if (INP_VALID == 2'b11)
                            RES = {{WIDTH{1'b0}}, OPB << 1};
                        else
                            ERR = 1'b1;
                    end

                    4'b1100: begin
                        if (INP_VALID == 2'b11) begin
                            if (|OPB[(WIDTH-1):(WIDTH/2)]) begin
                                ERR = 1'b1;
                                RES = {RES_WIDTH{1'b0}};
                            end else begin
                                RES = {{WIDTH{1'b0}},
                                       (OPA << OPB[$clog2(WIDTH)-1:0]) |
                                       (OPA >> (WIDTH - OPB[$clog2(WIDTH)-1:0]))};
                            end
                        end else
                            ERR = 1'b1;
                    end

                    4'b1101: begin
                        if (INP_VALID == 2'b11) begin
                            if (|OPB[(WIDTH-1):(WIDTH/2)]) begin
                                ERR = 1'b1;
                                RES = {RES_WIDTH{1'b0}};
                            end else begin
                                RES = {{WIDTH{1'b0}},
                                       (OPA >> OPB[$clog2(WIDTH)-1:0]) |
                                       (OPA << (WIDTH - OPB[$clog2(WIDTH)-1:0]))};
                            end
                        end else
                            ERR = 1'b1;
                    end

                    default: begin
                        RES   = {RES_WIDTH{1'b0}};
                        COUT  = 1'b0;
                        OFLOW = 1'b0;
                        G     = 1'b0;
                        E     = 1'b0;
                        L     = 1'b0;
                        ERR   = 1'b1;
                    end

                endcase

            end

        end

    end

endmodule
