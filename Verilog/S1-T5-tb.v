module restaurant_management_system_tb;

    // Inputs
    reg clk;
    reg reset;
    reg [1:0] table0_order_item; // 2-bit order items
    reg table0_order_valid;
    reg [1:0] table1_order_item; // 2-bit order items
    reg table1_order_valid;

    // Outputs
    wire [7:0] table0_bill;
    wire [7:0] table1_bill;
    wire table0_order_reject;
    wire table1_order_reject;
    wire [3:0] table0_queue_size;
    wire [3:0] table1_queue_size;
    wire [1:0] table0_ready_item; // 2-bit ready items
    wire [1:0] table1_ready_item; // 2-bit ready items
    wire table0_item_ready;
    wire table1_item_ready;

    // Instantiate the Unit Under Test (UUT)
    restaurant_management_system uut (
        .clk(clk), 
        .reset(reset), 
        .table0_order_item(table0_order_item), 
        .table0_order_valid(table0_order_valid), 
        .table1_order_item(table1_order_item), 
        .table1_order_valid(table1_order_valid), 
        .table0_bill(table0_bill), 
        .table1_bill(table1_bill), 
        .table0_order_reject(table0_order_reject), 
        .table1_order_reject(table1_order_reject), 
        .table0_queue_size(table0_queue_size), 
        .table1_queue_size(table1_queue_size), 
        .table0_ready_item(table0_ready_item), 
        .table1_ready_item(table1_ready_item), 
        .table0_item_ready(table0_item_ready), 
        .table1_item_ready(table1_item_ready)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units period
    end

    initial begin 
        $dumpfile("S1-T5.vcd");
        $dumpvars(0,restaurant_management_system_tb);
    end

    // Test procedure
    initial begin
        // Initialize Inputs
        reset = 1;
        table0_order_item = 0;
        table0_order_valid = 0;
        table1_order_item = 0;
        table1_order_valid = 0;

        // Wait 100 ns for global reset to finish
        #100;
        reset = 0;

        // Test Case 1: Table 0 orders item 2
        #10 table0_order_item = 2;
        #10 table0_order_valid = 1;
        #10 table0_order_valid = 0;
        $display("Time=%t | Table 0 Ordered Item: %d", $time, table0_order_item);
        if (!table0_order_reject) begin
            $display("Time=%t | Updated Bill for Table 0: %d", $time, table0_bill);
        end else begin
            $display("Time=%t | Table 0 Order Rejected (Inventory or Queue Full)", $time);
        end

        // Test Case 2: Table 1 orders item 3
        #20 table1_order_item = 3;
        #10 table1_order_valid = 1;
        #10 table1_order_valid = 0;
        $display("Time=%t | Table 1 Ordered Item: %d", $time, table1_order_item);
        if (!table1_order_reject) begin
            $display("Time=%t | Updated Bill for Table 1: %d", $time, table1_bill);
        end else begin
            $display("Time=%t | Table 1 Order Rejected (Inventory or Queue Full)", $time);
        end

        // Test Case 3: Table 0 orders item 2 again
        #20 table0_order_item = 2;
        #10 table0_order_valid = 1;
        #10 table0_order_valid = 0;
        $display("Time=%t | Table 0 Ordered Item: %d", $time, table0_order_item);
        if (!table0_order_reject) begin
            $display("Time=%t | Updated Bill for Table 0: %d", $time, table0_bill);
        end else begin
            $display("Time=%t | Table 0 Order Rejected (Inventory or Queue Full)", $time);
        end

        // Test Case 4: Table 1 orders items 1, 2, 3 repeatedly (total 6 orders)
        repeat (6) begin
            #20 table1_order_item = ($random % 3) + 1; // Select item 1, 2, or 3
            #10 table1_order_valid = 1;
            #10 table1_order_valid = 0;
            $display("Time=%t | Table 1 Ordered Item: %d", $time, table1_order_item);
            if (!table1_order_reject) begin
                $display("Time=%t | Updated Bill for Table 1: %d", $time, table1_bill);
            end else begin
                $display("Time=%t | Table 1 Order Rejected (Inventory or Queue Full)", $time);
            end
        end

        // Wait for items to be ready
        #500;

        // Test Case 5: Table 0 orders multiple items to fill queue
        repeat (16) begin
            #20 table0_order_item = ($random % 3) + 1; // Select item 1, 2, or 3
            #10 table0_order_valid = 1;
            #10 table0_order_valid = 0;
            $display("Time=%t | Table 0 Ordered Item: %d", $time, table0_order_item);
            if (!table0_order_reject) begin
                $display("Time=%t | Updated Bill for Table 0: %d", $time, table0_bill);
            end else begin
                $display("Time=%t | Table 0 Order Rejected (Inventory or Queue Full)", $time);
            end
        end

        // Test Case 6: Table 0 tries to order when queue is full (should be rejected)
        #20 table0_order_item = 1;
        #10 table0_order_valid = 1;
        #10 table0_order_valid = 0;
        $display("Time=%t | Table 0 Ordered Item: %d", $time, table0_order_item);
        if (table0_order_reject) begin
            $display("Time=%t | Table 0 Order Rejected (Queue Full)", $time);
        end else begin
            $display("Time=%t | Updated Bill for Table 0: %d", $time, table0_bill);
        end

        // Wait for simulation to finish
        #1000;

        // Capture the final bills
        $display("\n================== Final Results ==================");
        $display("Final Bill for Table 0: %d", table0_bill);
        $display("Final Bill for Table 1: %d", table1_bill);
        $display("Total Simulation Time: %t units", $time);
        $display("==================================================\n");

        $finish;
    end

endmodule
