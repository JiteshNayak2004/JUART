module uart_tx
#(parameter DATA_LEN = 8,
  parameter CLK_DIV = 100 // Number of clock cycles to transmit 1 bit
)
(
    input logic [DATA_LEN-1:0] data,
    input logic send_en,
    input logic clk,
    input logic rst_n,  // Added reset signal
    output logic next_d_ready,
    output logic tx_op
);

// Number of bits needed to represent DATA_LEN and CLK_DIV
localparam DATA_WIDTH = $clog2(DATA_LEN);
localparam CLK_WIDTH = $clog2(CLK_DIV);

// States of the FSM
typedef enum logic [1:0] {
    S_IDLE  = 2'b00,
    S_START = 2'b01,
    S_DATA  = 2'b10,
    S_STOP  = 2'b11
} state_t;

// Defining the current state and the next state variables
state_t curr_state, next_state;

// Store clock count (for synchronization)
logic [CLK_WIDTH-1:0] clk_count;
// Store bit currently being sent
logic [DATA_WIDTH-1:0] bit_count;

// Telling controller that we're ready to send the next data block
assign next_d_ready = (curr_state == S_IDLE);

// State register
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        curr_state <= S_IDLE;
        clk_count <= '0;
        bit_count <= '0;
    end else begin
        curr_state <= next_state;
        
        if (curr_state != next_state) begin
            clk_count <= '0;
        end else if (clk_count < CLK_DIV - 1) begin
            clk_count <= clk_count + 1;
        end

        if (curr_state == S_DATA && clk_count == CLK_DIV - 1) begin
            if (bit_count < DATA_LEN - 1) begin
                bit_count <= bit_count + 1;
            end else begin
                bit_count <= '0;
            end
        end
    end
end

// Next state logic
always_comb begin
    next_state = curr_state;  // Default: stay in current state
    
    case (curr_state)
        S_IDLE: begin
            if (send_en)
                next_state = S_START;
        end
        
        S_START: begin
            if (clk_count == CLK_DIV - 1)
                next_state = S_DATA;
        end
        
        S_DATA: begin
            if (clk_count == CLK_DIV - 1 && bit_count == DATA_LEN - 1)
                next_state = S_STOP;
        end
        
        S_STOP: begin
            if (clk_count == CLK_DIV - 1)
                next_state = S_IDLE;
        end
    endcase
end

// Output logic
always_comb begin
    case (curr_state)
        S_IDLE:  tx_op = 1'b1;
        S_START: tx_op = 1'b0;
        S_DATA:  tx_op = data[bit_count];
        S_STOP:  tx_op = 1'b1;
        default: tx_op = 1'b1;
    endcase
end

endmodule
