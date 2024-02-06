# UART
uart protocol implementation in systemverilog using 2 process fsm style

## usage
- For communication between microcontrollers
- For communication between microcontrollers and a computer (for debugging or sending commands)

## features
- serial data transfer
- full duplex (data can be sent from sender to reciever and vice versa)
  ![image](https://github.com/JiteshNayak2004/UART/assets/117510555/ada99604-e93f-42fd-befa-87a4b7d6934d)

## protocol
### UART data packet 
![image](https://github.com/JiteshNayak2004/UART/assets/117510555/56968351-72a4-464f-94fe-1195048b512c)
- A ```start bit``` indicates start of packet
  - The default ```HIGH``` level is pulled down to ```LOW``` for one clock cycle
  - The receiving UART detects the transition and prepares to read the subsequent bits

- The ```data frame``` holds the actual data. It can be 5 to 8 bits long if the parity bit is used, or 9 bits long if parity is not used.
  - LSB first

- ```Parity bit``` is used to check for errors. It can follow odd or even parity.

- ```Stop bit``` indicates end of packet
  - The signal is pulled ```HIGH``` for 1 to 2 cycles.
 
## State machines

Transmitter state machine | Receiver state machine
:-:|:-:
![image](https://github.com/JiteshNayak2004/UART/assets/117510555/46856727-ebc8-459f-a594-e8a1eca77bf1) | ![image](https://github.com/JiteshNayak2004/UART/assets/117510555/563cb21e-f24a-43b1-ba69-d328b9736fa6)

## port interfaces

- for transmitter,
  
Name of port | function
:------------:|:-------------------------:
data          |     input data bus to be sent
send_en          |     enable signal to start sending
clk          |     clk to the modules
next_d_ready          |     signal indicating whether next data packet can be sent
tx_op          |     1 bit data to be sent

- for reciever,
  
Name of port | function
:------------:|:-------------------------:
rx_b   |    bit recieved
recieved_data  |     the bus of data that is recieved
clk          |     input data to be sent
ready_recieve          |     signal indicating the reciever is ready to recieve

## credits and references
1) [Analog Devices](https://www.analog.com/en/analog-dialogue/articles/uart-a-hardware-communication-protocol.html#:~:text=By%20definition%2C%20UART%20is%20a,going%20to%20the%20receiving%20end.)
2) [NandLand implementation](https://www.nandland.com/vhdl/modules/module-uart-serial-port-rs232.html)
3) https://github.com/Ashwin-Rajesh/Verilog_comm
