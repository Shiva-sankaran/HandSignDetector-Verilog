`timescale 1ns / 1ps


module test_bench;

    wire[5:0] out;
   
    main Instance(out);
    
     always @(out)begin
        // display the letter based on the number 
        $display("--------------------------");
        if(out==0)
          $display("The predicted letter is A");
        else if(out==1)
          $display("The predicted letter is B");
        else if(out==2)
          $display("The predicted letter is C");
        else if(out==3)
          $display("The predicted letter is D");
        else if(out==4)
          $display("The predicted letter is E");
        else if(out==5)
          $display("The predicted letter is F");
        else if(out==6)
          $display("The predicted letter is G");
        else if(out==7)
          $display("The predicted letter is H");
        else if(out==8)
          $display("The predicted letter is I");
        else if(out==9)
          $display("The predicted letter is j");
        else if(out==10)
          $display("The predicted letter is k");
        else if(out==11)
          $display("The predicted letter is L");
        else if(out==12)
          $display("The predicted letter is M");
        else if(out==13)
          $display("The predicted letter is N");
        else if(out==14)
          $display("The predicted letter is O");
        else if(out==15)
          $display("The predicted letter is P");
        else if(out==16)
          $display("The predicted letter is Q");
        else if(out==17)
          $display("The predicted letter is R");
        else if(out==18)
          $display("The predicted letter is S");
        else if(out==19)
          $display("The predicted letter is T");
        else if(out==20)
          $display("The predicted letter is U");
        else if(out==21)
          $display("The predicted letter is V");
        else if(out==22)
          $display("The predicted letter is W");
        else if(out==23)
          $display("The predicted letter is X");
        else 
          $display("The predicted letter is Y");

     end
     
endmodule
