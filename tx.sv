
module uart_tx
#(parameter data_len=15,
  parameter clk_div=100 // basically tells us it takes 100 clock cycles to transmit 1 bit
  )
(
    input logic data[data_len-1:0],
    input logic send_en,
    input logic clk,

    output logic next_d_ready,
    output logic tx_op
    
);


// no of bits needed to represent data_len and clk_div of given size
localparam DATA_WIDTH=$clog2(data_len);
localparam CLK_WIDTH=$clog2(clk_div);

// states of the fsm
typedef enum logic [2:0]
{S_IDLE =3'b000,
S_START=3'b001,
S_DATA=3'b010,
S_STOP=3'b100 } state;
 
// defining the current state and the next state vars 
state curr_state,next_state;

// Store clock count (for synchronization)
logic [CLK_WIDTH-1:0]  clk_count = 0;       
// Store bit currently being sent
logic [DATA_WIDTH-1:0] bit_count = 0;  


// telling controller that ready to send the next data block
assign next_d_ready=(curr_state==S_IDLE);


//state register
always_ff @( posedge clk ) 
begin
curr_state<=next_state; 
end
//next state logic

always_comb 
begin
    case(curr_state)

    S_IDLE:begin
        clk_count=0;
        bit_count=0;
        if(send_en==1'b1)
        begin
            next_state=S_START;
            
        end
        else next_state=S_IDLE;
    end
        
    S_START:begin
        if(clk_count<clk_div-1)
        begin
            clk_count=clk_count+1;
            next_state=S_START;
        end
        else 
        clk_count=0;
        next_state=S_DATA;

    end

    S_DATA:begin
        if(clk_count<clk_div-1)
            begin
                clk_count=clk_count+1;
                next_state=S_DATA;
            end
        else
            clk_count=0;
            if(bit_count<data_len-1)
                begin
                    bit_count=bit_count+1;
                end
            else
                begin
                    next_state=S_STOP;
                    bit_count=0;
                end            
    end
    
    S_STOP:begin
        if(clk_count<clk_div-1)
            begin
                clk_count=clk_count+1;
                next_state=S_STOP;
            end
        else
            begin
                clk_count=0;
                next_state=S_IDLE;
            end
    end 

   
    endcase

end
    

// output logic
always_comb 
begin
    case(curr_state)
    S_IDLE:tx_op=1'b1;
    S_START:tx_op=1'b0;
    S_DATA:tx_op=data[bit_count];
    S_STOP:tx_op=1'b1;
    
    endcase
    
end
    



endmodule