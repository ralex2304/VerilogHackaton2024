module music (
    input  logic            clk,
    input  logic            arst_n,

    output logic            o_pwm
);

parameter dA = 16'd4584;
parameter C = 16'd3822;
parameter D = 16'd3405;
parameter E = 16'd3034;
parameter F = 16'd2865;
parameter G = 16'd2551;
parameter uA = 16'd2273;
parameter Bb = 16'd2148;

parameter q = 16'd24;
parameter q1 = 16'd48;
parameter p = 16'h0;

reg[2047 : 0] tune_roll = {
    D,C,D,p,E,p,E,F,D,p,D,uA,p,G,p,F,p,F,E,D,
    p,D,uA,G,uA,p,Bb,p,Bb,uA,G,p,G,p,G,F,D,p,D,p,D,C,dA,
    p,D,C,C,D,p,E,p,E,G,F,p,F,p,F,E,D,p,D,p,D,C,dA,
    p,D,C,C,D,p,E,p,E,G,F,p,F,p,F,E,D,p,D,p,D,C,dA
};

reg[2047 : 0]  dur_roll = {
    q,q,q,q,q,q,q,q,q,q1,q,q,q,q,q,q,q,q,q,q,
    q1,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,
    q1,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,
    q1,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q,q
};



endmodule


module MusicBox(clk,rst,out,debug,control);
input  clk,rst;
input [7 : 0] control;
output out;
output[7 : 0] debug;
reg out;
reg [7 : 0] debug;

//note tone defenitions
//тон нот:


reg[31 : 0] cnt;
reg[15 : 0] tune;
reg[15 : 0] clk_tune;
reg[7  : 0] clk_dur;


//melody (separate rolls for duration and tone) - read BACKWARDS.
//мелодия (отдельные доржки длительности ноты и тона) - играется ЗАДОМ НАПЕРЕД.


reg [7:0] ctrl;

reg[2047 : 0] note_tune;
reg[2047 : 0] note_dur;

//control of clock dividers (switch of octave and speed)
//управление делителем частоты (переключение октавы и скорости)
always@(control)
begin
	ctrl[7:4] <= 4'd4; //octave switch is disabled by default | переключение октав отключено, ctrl[7:4] <= ~control[3:0]; включит его через свитчи 5-8
	case (control[7:4])
	4'b1110: ctrl[3:0] <= 4'd3;
	4'b1101: ctrl[3:0] <= 4'd4;
	4'b1011: ctrl[3:0] <= 4'd6;
	4'b0111: ctrl[3:0] <= 4'd12;
	default: ctrl[3:0] <= 4'd4;
	endcase
end


//clock divider
//делитель частоты
always@(posedge clk or negedge rst)
begin
  if(!rst) begin
    clk_tune<=0;
    clk_dur <=0;
    end
  else begin
    if(clk_tune<ctrl[7:4])
      clk_tune<=clk_tune+1;
    else
      clk_tune<=0;

    if(clk_dur<ctrl[3:0])
      clk_dur<=clk_dur+1;
    else
      clk_dur<=0;
    end
end

//note duration switcher
//переключатель длительности ноты
always@(posedge clk or negedge rst)
begin
  if(!rst) begin
    cnt<=0;
    note_dur<=dur_roll;
  end
  else if(clk_dur>=ctrl[3:0]) begin
    if(cnt[31 : 16]!=note_dur[15 : 0]) begin
      cnt<=cnt+1;
      note_dur<=note_dur;
    end else begin
      note_dur=note_dur >> 16;
      cnt<=0;
    end
  end
end


//note tone switcher
//переключатель тона ноты, лампочки на плате показывают текущую ноту.
always@(posedge clk or negedge rst)
begin
  if(!rst) begin
    note_tune<=tune_roll;
  end
  else if(clk_dur>=ctrl[3:0])
    if(cnt[31 : 16]==note_dur[15 : 0]) begin
        note_tune=note_tune >> 16;
        debug<=note_tune[7 : 0];
    end else
        note_tune<=note_tune;
end

//output controller
//генератор выходного сигнала
always@(posedge clk or negedge rst)
begin
  if(!rst)
    tune<=0;
  else if(note_tune[15 : 0] == 0)
    out<=1;
  else if(cnt[31 : 16]==note_dur[15 : 0])
    tune<=0;
  else if(clk_tune>=ctrl[7:4]) begin
    if(tune!=note_tune[15 : 0]) begin
      tune<=tune+1;
      out<=out;
    end else begin
      tune<=0;
      out<=~out;
    end
  end
end

endmodule
