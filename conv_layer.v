`timescale 1ns / 1ps

module conv_l #
         (
         
         
         parameter IBW = 8,
         parameter KBW = 64,
         parameter OBW = IBW+KBW,
         parameter full_OBW = IBW+KBW,
         parameter height = 28,
         parameter width = 28,
         parameter length=height*width,
         parameter filters = 32,
         parameter channels = 1,
         parameter k_x = 3,
         parameter k_y = 3,
         parameter out_x = height - k_x +1,
         parameter out_y = width - k_y +1,
         parameter out_length = filters*out_x*out_y/4,
         parameter length_conv = filters*channels*k_x*k_y,
         parameter layerno = 1,
         
         parameter flag2=0
         
         )
     (
    input[IBW*length -1:0] data,
    
    input[(KBW+1)*length_conv -1 :0] kernel,
    
    output reg [(OBW+1)*out_length -1:0] result
    
    
    );

  // 1-D inputs are converted back to multi dimensional arrays for processing
  // NOTE: The proccessing can be done without converting to thier original shape but the proccessing more cleaner when converted back to thier orginal shapes
  reg signed[OBW:0] temp_out[out_x-1:0][out_y-1:0]; // we need a temperoray matrix to store the output of the current channel before adding it to the final output
  reg signed[OBW:0] out[filters-1:0][out_x-1:0][out_y-1:0];
  reg signed [IBW+flag2-1:0] input_matrix [channels-1:0][height-1:0][width-1:0];
  reg signed [KBW:0]conv1_matrix[filters-1:0][channels-1:0][k_x-1:0][k_y-1:0];
  integer i,j,k,l,m,t,iter,out_x_iter,out_y_iter,t2;
  always @(data)
  begin
  $display("\nStarting propagation through layer%d (conv)",layerno);
  
  #10
  t=0;
  
  //conversion of input data to its corresponding shape
  for(k=0;k<channels;k= k+1)  
    for(i=0;i<height;i=i+1)
     for(j=0;j<width;j=j+1)
        begin
        input_matrix[k][i][j] = data[t+:IBW];
        t =t +IBW;
        end
  // conversion of kernel matrix to its corresponding shape
   iter = 0;
   for(i=0;i<filters;i = i+1)
      for(j=0;j<channels;j = j+1)
         for(k=0;k<k_x;k=k+1)
            for(t=0;t<k_y; t = t+1)
                begin
                conv1_matrix[i][j][k][t] = kernel[iter+:KBW+1];
                
                iter = iter +KBW+1;
                end
   // Intialising the out matrix to zeroes
   for(i=0;i<filters;i = i+1)
       for(out_x_iter = 0;out_x_iter<out_x;out_x_iter = out_x_iter +1)
            for(out_y_iter = 0;out_y_iter<out_y;out_y_iter = out_y_iter +1) 
                out[i][out_x_iter][out_y_iter] = 0;
   
   // convolving through the layer 
   for(i=0;i<filters;i = i+1)
     begin
      for(j=0;j<channels;j = j+1)
        begin
         // for every channel intialise temp_out to zeroes
         for(out_x_iter = 0;out_x_iter<out_x;out_x_iter = out_x_iter +1)
            for(out_y_iter = 0;out_y_iter<out_y;out_y_iter = out_y_iter +1)
               temp_out[out_x_iter][out_y_iter] = 0;
         for(out_x_iter = 0;out_x_iter<out_x;out_x_iter = out_x_iter +1)
            for(out_y_iter = 0;out_y_iter<out_y;out_y_iter = out_y_iter +1)
                for(k=0;k<k_x;k=k+1)
                    for(t=0;t<k_y; t = t+1)
                     begin
                     temp_out[out_x_iter][out_y_iter] = temp_out[out_x_iter][out_y_iter] + conv1_matrix[i][j][k][t]*input_matrix[j][out_x_iter+k][out_y_iter+t];
                     end
         // After done with all channels of the filter store the temp_out matrix to the out[filter] matrix
         for(out_x_iter = 0;out_x_iter<out_x;out_x_iter = out_x_iter +1)
            for(out_y_iter = 0;out_y_iter<out_y;out_y_iter = out_y_iter +1)
              out[i][out_x_iter][out_y_iter] = out[i][out_x_iter][out_y_iter] + temp_out[out_x_iter][out_y_iter];
         end
      end
    
    // ReLu activation function
    // ReLu[f(x)] = Max(0,f(x))
    t=0;
    for(i=0;i<filters;i = i+1)
       for(out_x_iter = 0;out_x_iter<out_x;out_x_iter = out_x_iter +1)
            for(out_y_iter = 0;out_y_iter<out_y;out_y_iter = out_y_iter +1) 
               begin
               if(out[i][out_x_iter][out_y_iter]<0)
                 out[i][out_x_iter][out_y_iter] = 0;
                t = t+1;
               end
    
    
    // Maxpooling layer of stride 2
    t=0;
    t2=0;
    for(i=0;i<filters;i = i+1)
       for(out_x_iter = 0;out_x_iter+1<out_x;out_x_iter = out_x_iter +2)
            for(out_y_iter = 0;out_y_iter+1<out_y;out_y_iter = out_y_iter +2) 
              begin
                // The output of max pooling layer is given to the 1-D output
                result[t+:OBW+1]= (out[i][out_x_iter][out_y_iter]>=out[i][out_x_iter][out_y_iter+1]&out[i][out_x_iter][out_y_iter]>=out[i][out_x_iter+1][out_y_iter]&out[i][out_x_iter][out_y_iter]>=out[i][out_x_iter+1][out_y_iter+1])?out[i][out_x_iter][out_y_iter]:(out[i][out_x_iter+1][out_y_iter]>=out[i][out_x_iter][out_y_iter]&out[i][out_x_iter+1][out_y_iter]>=out[i][out_x_iter][out_y_iter+1]&out[i][out_x_iter+1][out_y_iter]>=out[i][out_x_iter+1][out_y_iter+1])?out[i][out_x_iter+1][out_y_iter]:(out[i][out_x_iter][out_y_iter+1]>=out[i][out_x_iter][out_y_iter]&out[i][out_x_iter][out_y_iter+1]>=out[i][out_x_iter+1][out_y_iter]&out[i][out_x_iter][out_y_iter+1]>=out[i][out_x_iter+1][out_y_iter+1])?out[i][out_x_iter][out_y_iter+1]:out[i][out_x_iter+1][out_y_iter+1];
                t2 = t2 +1;
                t = t+OBW+1;
               end
   $display("\nPASS:propagation through layer%d (conv) ",layerno);    
 end 
 
endmodule
