
module uart_rx
#(parameter data_len=15,
  parameter clk_div=100 // basically tells us it takes 100 clock cycles to transmit 1 bit
  )
(
    input logic rx_b,
    input logic clk,

    output logic [data_len-1:0] recieved_data,
    output logic ready_recieve
    
);


// no of bits needed to represent data_len and clk_div of given size
localparam DATA_WIDTH=$clog2(data_len);
localparam CLK_WIDTH=$clog2(clk_div);

// states of the fsm
typedef enum logic [2:0]
{S_IDLE =3'b000,
S_START=3'b001,
S_DATA=3'b010,
S_STOP=3'b100,
S_RESTART=3'B101 } state;
 
// defining the current state and the next state vars 
state curr_state,next_state;

// a buffer that we update with the incoming bits and once all bits updated we set it to the output
logic [data_len-1:0] rx_op_buffer; 


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
always_comb begin
    case(curr_state)
    S_IDLE:begin
        clk_count=0;
        bit_count=0;
        if(rx_b==0) next_state=S_START;
        else next_state=S_IDLE;
    end
    //checks half of baud rate to verify it is actually a low and not a glitch
    S_START:begin
        if(clk_count<(clk_div/2)-1) begin
            clk_count=clk_count+1;
            next_state=S_START;
        end
        else begin
            if(rx_b==0) begin
                clk_count=0;
                next_state=S_DATA;
        end
            else next_state=S_IDLE;
        end
        
    end

    S_DATA:begin
        if(clk_count<clk_div-1) begin
            clk_count=clk_count+1;
            next_state=S_DATA;
        end
        else begin
            clk_count=0;
            if(bit_count<data_len-1) begin
                next_state=S_DATA;
                bit_count=bit_count+1;
            end
            else begin
                next_state=S_STOP;
                bit_count=0;
            end

        end
    end
    // sending high for 1 bit period and then shift to restart
    S_STOP:begin
        if(clk_count<clk_div-1) begin
            clk_count=clk_count+1;
            next_state=S_STOP;
        end
        else begin
            clk_count=0;
            next_state=S_RESTART;
        end
    end
    S_RESTART:next_state=S_IDLE;

    default: next_state=S_IDLE;

    endcase

    
end
    
//ouput logic

always_comb begin 
    
    case(curr_state)
    S_IDLE:begin
        if(rx_b==0)
        ready_recieve=1'b1;
        else
        ready_recieve=1'b0;

    end

    S_START:begin
        if(rx_b==0)
        ready_recieve=1'b1;
        else
        ready_recieve=1'b0;
        
    end

    S_DATA:begin
        if(bit_count<data_len-1) rx_op_buffer[bit_count]=rx_b;
        else recieved_data=rx_op_buffer;

        ready_recieve=1'b0;
    end

    S_RESTART:ready_recieve=1'b0;

    endcase

    
end


endmodule