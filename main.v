`timescale 1ns / 1ps
`include "conv_layer.v"
`include "dense.v"


module main(output [5:0] final_out);

// Every layers shape and input and output shapes are defined as parameters
// output shape of any layer is input_dim - kernel_dim + 1

//conv layer 1
parameter height = 28;
parameter width = 28;
parameter length=height*width*1;
parameter filters = 32;
parameter channels = 1;
parameter k_x = 3; // kernel's no of rows
parameter k_y = 3; // kernel's no of columns
parameter out_x = 26;
parameter out_y = 26;
parameter length_conv = filters*channels*k_x*k_y;
parameter out_length = 5408;

//conv layer 2
parameter height2 = 13;
parameter width2 = 13;
parameter length2= 5408;
parameter filters2 = 64;
parameter channels2 = 32;
parameter out_x2 = 11;
parameter out_y2 = 11;
parameter length_conv2 = filters2*channels2*k_x*k_y;
parameter out_length2 = 1600;

//conv layer 3
parameter height3 = 5;
parameter width3 = 5;
parameter length3= 1600;
parameter filters3 = 128;
parameter channels3 = 64;
parameter out_x3 = 3;
parameter out_y3 = 3;
parameter length_conv3 = filters3*channels3*k_x*k_y;
parameter out_length3 = 128;

//dense layer 1
parameter weight1_input_rows = 1;
parameter weight1_input_columns = 128;
parameter weight1_rows = 128;
parameter weight1_columns = 512;
parameter weight1_length = weight1_rows*weight1_columns;
parameter dense1_out_rows = 1;
parameter dense1_out_columns = 512;
parameter dense1_in_length = weight1_input_rows*weight1_input_columns;
parameter dense1_out_length = dense1_out_rows*dense1_out_columns;

// dense layer 2
parameter weight2_input_rows = 1;
parameter weight2_input_columns = 512;
parameter weight2_rows = 512;
parameter weight2_columns = 25;
parameter weight2_length = weight2_rows*weight2_columns;
parameter dense2_out_rows = 1;
parameter dense2_out_columns = 25;
parameter dense2_in_length = weight2_input_rows*weight2_input_columns;
parameter dense2_out_length = dense2_out_rows*dense2_out_columns;



// Registers to store the loaded image values
reg signed [7:0]in[length-1:0];
reg signed [12:0]conv1[length_conv-1:0];
reg signed [12:0]conv2[length_conv2-1:0];
reg signed [12:0]conv3[length_conv3-1:0];
reg signed [12:0]dense1[weight1_length-1:0];
reg signed [12:0]dense2[weight2_length-1:0];

// 1-D arrays which have been reshaped from the above registers 
// These 1-D arrays will be given as input to the modules
reg [8*length -1:0] d;
reg [13*length_conv - 1:0] ker;
wire[(21)*out_length -1:0] out;
reg [13*length_conv2 - 1:0] ker2;
wire[(34)*out_length2 -1:0] out2;
reg [13*length_conv3 - 1:0] ker3;
wire[(47)*out_length3 -1:0] out3;
reg [13*weight1_length - 1:0] weight1;
wire[(59)*dense1_out_length -1:0] dense1_out;
reg [13*weight2_length - 1:0] weight2;
wire[(71)*dense2_out_length -1:0] dense2_out;

// Final output is will contain the first 5 bits of the last layer in this case its the 2nd dense layer
// 5 bits have been chosen as there are total 24 letters 
assign final_out = dense2_out[5:0];

integer i,j,t;


initial
begin


$display("Loading data...");
$readmemb("C:\\Users\\91944\\Desktop\\data\\new_100_in_bin.bin",in);  //  The input image bin file
#10
$readmemb("C:\\Users\\91944\\Desktop\\data\\new_conv1_test12_bin.bin",conv1); // The convulation layer1's weight matrix
#10
$readmemb("C:\\Users\\91944\\Desktop\\data\\new_conv2_test12_bin.bin",conv2); // The convulation layer2's weight matrix
#10
$readmemb("C:\\Users\\91944\\Desktop\\data\\new_conv3_test12_bin.bin",conv3); // The convulation layer3's weight matrix

#10
$readmemb("C:\\Users\\91944\\Desktop\\data\\new_dense1_test12_bin.bin",dense1); // The dense layer1's weight matrix
#10
$readmemb("C:\\Users\\91944\\Desktop\\data\\new_dense2_test12_bin.bin",dense2); // The dense layer2's weight matrix
$display("Data loaded successfully");

// Reshaping 2-D arrays into linear 1-D arrays
$display("Converting arrays");

t=0;
for(i=0;i<length;i=i+1)
   begin
   d[t+:8] = in[i];
   t=t+8;
   end
   
t=0;
for(i=0;i<length_conv;i=i+1)
   begin
   ker[t+:13] = conv1[i];
   t=t+13;
   end
t=0;

for(i=0;i<length_conv2;i=i+1)
   begin
   ker2[t+:13]=conv2[i];
   t=t+13;
   end
t=0;

for(i=0;i<length_conv3;i=i+1)
   begin
   ker3[t+:13]=conv3[i];
   t=t+13;
   end
t=0;
#30
for(i=0;i<weight1_length;i=i+1)
   begin
   weight1[t+:13]=dense1[i];
   t=t+13;
   end
t=0;
#30
for(i=0;i<weight2_length;i=i+1)
   begin
   weight2[t+:13]=dense2[i];
   t=t+13;
   end
end

// Instantiation every layer with thier corresponing parameters
// The network architecture :
// Layer (type)
// conv2d_1 (Conv2D)
// conv2d_2 (Conv2D)
// conv2d_2 (Conv2D)
// dense_1 (Dense)
//dense_2 (Dense)

// conv layers have inbuilt ReLu activation function and max-pooling layer of stride 2
conv_l #(.IBW(8),.KBW(12),.height(height),.width(width),.length(length),.filters(filters),.channels(channels),.k_x(k_x),.k_y(k_y),.out_x(out_x),.out_y(out_y),
          .out_length(out_length),.length_conv(length_conv),.flag2(1),.layerno(1))            
          
          conv_1(.data(d),.kernel(ker),.result(out));


conv_l #(.IBW(21),.KBW(12),.height(height2),.width(width2),.length(length2),.filters(filters2),.channels(channels2),.k_x(k_x),.k_y(k_y),.out_x(out_x2),.out_y(out_y2),
          .out_length(out_length2),.length_conv(length_conv2),.flag2(0),.layerno(2))            
          
          conv1_2(.data(out),.kernel(ker2),.result(out2));

 
conv_l #(.IBW(34),.KBW(12),.height(height3),.width(width3),.length(length3),.filters(filters3),.channels(channels3),.k_x(k_x),.k_y(k_y),.out_x(out_x3),.out_y(out_y3),
          .out_length(out_length3),.length_conv(length_conv3),.flag2(0),.layerno(3))            
          
          conv1_3(.data(out2),.kernel(ker3),.result(out3));

//dense layers have inbuilt ReLu activation function
dense #(.IBW(46),.KBW(12),.input_rows(weight1_input_rows),.input_columns(weight1_input_columns),.input_length(dense1_in_length),.weight_rows(weight1_rows),.weight_columns(weight1_columns),.out_rows(dense1_out_rows),.out_columns(dense1_out_columns),.weight_length(weight1_length),.out_length(dense1_out_length),
        .flag2(0),.flag_out(0),.layerno(4)
        
        )
         
         dense_1(.data(out3),.weights(weight1),.result(dense1_out));
  
dense #(.IBW(58),.KBW(12),.input_rows(weight2_input_rows),.input_columns(weight2_input_columns),.input_length(dense2_in_length),.weight_rows(weight2_rows),.weight_columns(weight2_columns),.out_rows(dense2_out_rows),.out_columns(dense2_out_columns),.weight_length(weight2_length),.out_length(dense2_out_length),
        .flag2(20),.flag_out(1),.layerno(5)
        
        )
         
         dense_2(.data(dense1_out),.weights(weight2),.result(dense2_out));

endmodule





