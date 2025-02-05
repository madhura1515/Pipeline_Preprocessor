module tb_pipeline_processor;
    reg clk;
    reg reset;
    wire [31:0] result;

    pipeline_processor uut (
        .clk(clk),
        .reset(reset),
        .result(result)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        #10 reset = 0;
        #100;
        $stop;
    end

    initial begin
        $monitor("Time: %t | Result: %d", $time, result);
    end
endmodule