`timescale 1ns / 1ps


module dense#(
    parameter IBW=202,
    parameter KBW=32,
    parameter OBW=IBW+KBW,
    parameter input_rows = 1,
    parameter input_columns =128,
    parameter input_length = input_rows*input_columns,
    parameter weight_rows = 128,
    parameter weight_columns = 512,
    parameter out_rows = 1,
    parameter out_columns = 512, 
    parameter weight_length = weight_rows*weight_columns,
    parameter out_length = out_rows*out_columns,
    
    parameter flag2 = 0,
    parameter flag_out = 0,
    parameter layerno = 1
    
    )
   
   (
    input[(IBW+1)*input_length -1:0] data,
    input[(KBW+1)* weight_length -1:0] weights,
    output reg [(OBW+1)*out_length -1 :0] result
    );
    

    // 1-D inputs are converted back to multi dimensional arrays for processing
   // NOTE: The proccessing can be done without converting to thier original shape but the proccessing more cleaner when converted back to thier orginal shapes
    reg signed [KBW:0]weight_matrix[weight_rows-1:0][weight_columns-1:0];
    reg signed [IBW:0]input_matrix[input_rows-1:0][input_columns:0];
    reg signed [OBW+flag2:0]out_matrix[out_rows-1:0][out_columns-1:0];
    reg signed [OBW+flag2:0]max; // A temp array used for finding the letter with the highest probablity 
    reg [5:0]index; // Array to store the letter with the highest probablity. 0-A,1-B,...
   
    integer i,j,k,t,t2;
    always@(data)
    begin
    #20
    $display("\nStarting propagation through layer%d (dense)",layerno);
    
    // converting 1-D weight matrix to its orginal shape
    t=0;
    for(i=0;i<weight_rows;i=i+1) begin
       for(j=0;j<weight_columns;j=j+1) begin
           weight_matrix[i][j] = weights[t+:KBW+1];
           
           t=t+KBW+1;
        end
    end
    
    // converting the 1-D input to the layer to its orginal shape
    t=0;
    for(i=0;i<input_rows;i=i+1)begin
       for(j=0;j<input_columns;j=j+1) begin
         input_matrix[i][j] = data[t+:IBW+1];
         
       t=t+IBW+1;
      end
    end
    
   // intialising the output matrix to zeros
    for(i=0;i<out_rows;i=i+1)begin
       for(j=0;j<out_columns;j=j+1)begin
          out_matrix[i][j] = 0;
      end
    end
   // Matrix multiplication of  input_matrix and weight_matrix
    for(i=0;i<out_rows;i=i+1)begin
       for(j=0;j<out_columns;j=j+1)begin
          for(k=0;k<input_columns;k=k+1)begin
            out_matrix[i][j] = out_matrix[i][j] + (input_matrix[i][k]*weight_matrix[k][j]);
          end
       end
    end
    
    max =0;
    
    // ReLu activation function
    // ReLu[f(x)] = Max(0,f(x))
    for(i=0;i<out_rows;i=i+1)begin
        for(j=0;j<out_columns;j=j+1)begin
          if(out_matrix[i][j]<0)begin
            out_matrix[i][j] = 0;
          end 
        end
    end
    
    
      
    t=0;
    t2=0;
    
    for(i=0;i<out_rows;i=i+1)begin
        for(j=0;j<out_columns;j=j+1)begin
           // If this is the last layer then find the maximum probablity latter
           // If this is not the last layer then convert the out_matrix to its 1-D form and end the module
           // flag out is the parameter which will decide about this
            
          if(flag_out == 0)begin // converting to 1-D form
             t2 = t2+1;
             result[t+:OBW+1] = out_matrix[i][j];
             t = t+OBW+1;
          end
          
         else begin  // Findiing the max probablity 
           if(out_matrix[i][j]>max)begin
               max  = out_matrix[i][j];
               index = j;      // We need the index of the max probablity. The index will map back to the letter 
             end
         end
       end
     end
     
     if(flag_out ==1)begin // Store the index in the final result. The index can be mapped to an alphabet 0-A,1-B,2-C, ...
       result[5:0] = index;
     end
     $display("\nPASS:propagation through layer%d (dense) ",layerno);
   end
endmodule
