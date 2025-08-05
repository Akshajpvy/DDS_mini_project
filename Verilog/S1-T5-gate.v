// S1-T5 (DDS-mini-project-2024-25)
// Dineflow - Smart Automatic Restaurant Management System
// Team members-
// 1) Rakshith Ashok Kumar - 231CS147
// 2) Utsav Singh Bhamra - 231CS161
// 3) Akshaj PVY - 231CS109


module restaurant_management_system_gate_level (
    input clk,
    input reset,
    input [1:0] table0_order_item, // 2-bit order items
    input table0_order_valid,
    input [1:0] table1_order_item, // 2-bit order items
    input table1_order_valid,
    output reg [7:0] table0_bill,     // 8-bit bill for table 0
    output reg [7:0] table1_bill,     // 8-bit bill for table 1
    output table0_order_reject,
    output table1_order_reject,
    output [3:0] table0_queue_size,
    output [3:0] table1_queue_size,
    output [1:0] table0_ready_item,   // 2-bit ready items
    output [1:0] table1_ready_item,   // 2-bit ready items
    output table0_item_ready,
    output table1_item_ready
);

    // Parameters and signals
    wire [3:0] inventory [3:0];        // Inventory for 4 items
    wire [7:0] item_prices [3:0];      // Prices for 4 items
    wire [7:0] item_prep_times [3:0];  // Prep times for 4 items

    // Queue signals
    wire [1:0] table0_queue [15:0];    // Queue for 16 orders at table 0
    wire [1:0] table1_queue [15:0];    // Queue for 16 orders at table 1

    // Queue head and tail pointers
    wire [3:0] table0_queue_head, table0_queue_tail;
    wire [3:0] table1_queue_head, table1_queue_tail;

    // Timer signals
    reg [7:0] table0_timer_reg;
    reg [7:0] table1_timer_reg;

    // Registers for queue sizes
    reg [3:0] table0_qsize;
    reg [3:0] table1_qsize;

    // Registers for inventory
    reg [3:0] table0_inventory [3:0];
    reg [3:0] table1_inventory [3:0];

    // D Flip-flop implementations for resetting and clock edge behavior
    d_flip_flop dff_table0_total_bill(.q(table0_bill), .d(8'b0), .clk(clk), .reset(reset));
    d_flip_flop dff_table1_total_bill(.q(table1_bill), .d(8'b0), .clk(clk), .reset(reset));

    // Inventory initialization
    d_flip_flop dff_table0_inventory_0(.q(table0_inventory[0]), .d(4'd5), .clk(clk), .reset(reset));
    d_flip_flop dff_table0_inventory_1(.q(table0_inventory[1]), .d(4'd5), .clk(clk), .reset(reset));
    d_flip_flop dff_table0_inventory_2(.q(table0_inventory[2]), .d(4'd5), .clk(clk), .reset(reset));
    d_flip_flop dff_table0_inventory_3(.q(table0_inventory[3]), .d(4'd5), .clk(clk), .reset(reset));

    d_flip_flop dff_table1_inventory_0(.q(table1_inventory[0]), .d(4'd5), .clk(clk), .reset(reset));
    d_flip_flop dff_table1_inventory_1(.q(table1_inventory[1]), .d(4'd5), .clk(clk), .reset(reset));
    d_flip_flop dff_table1_inventory_2(.q(table1_inventory[2]), .d(4'd5), .clk(clk), .reset(reset));
    d_flip_flop dff_table1_inventory_3(.q(table1_inventory[3]), .d(4'd5), .clk(clk), .reset(reset));

    // Timer logic for Table 0
    d_flip_flop dff_table0_timer(.q(table0_timer_reg), .d(table0_timer_reg - 1), .clk(clk), .reset(reset));

    // Timer logic for Table 1
    d_flip_flop dff_table1_timer(.q(table1_timer_reg), .d(table1_timer_reg - 1), .clk(clk), .reset(reset));

    // Queue size updates for Table 0 using gates
    wire [3:0] table0_qsize_next;
    wire table0_queue_not_full;

    assign table0_qsize_next = table0_qsize + 1;
    assign table0_queue_not_full = (table0_qsize < 4'b1111);

    // Flip-flop to store queue size for Table 0
    d_flip_flop dff_table0_qsize(.q(table0_qsize), .d(table0_qsize_next), .clk(clk), .reset(reset));

    // Queue size updates for Table 1 using gates
    wire [3:0] table1_qsize_next;
    wire table1_queue_not_full;

    assign table1_qsize_next = table1_qsize + 1;
    assign table1_queue_not_full = (table1_qsize < 4'b1111);

    // Flip-flop to store queue size for Table 1
    d_flip_flop dff_table1_qsize(.q(table1_qsize), .d(table1_qsize_next), .clk(clk), .reset(reset));

    // Order reject logic for Table 0
    wire table0_inventory_not_empty;
    assign table0_inventory_not_empty = (table0_inventory[table0_order_item] > 0);

    assign table0_order_reject = ~(table0_inventory_not_empty & table0_queue_not_full & table0_order_valid);

    // Order reject logic for Table 1
    wire table1_inventory_not_empty;
    assign table1_inventory_not_empty = (table1_inventory[table1_order_item] > 0);

    assign table1_order_reject = ~(table1_inventory_not_empty & table1_queue_not_full & table1_order_valid);

    // Item ready output for Table 0
    assign table0_item_ready = (table0_timer_reg == 8'b0 && table0_qsize > 0);
    assign table0_ready_item = table0_queue[table0_queue_head];

    // Item ready output for Table 1
    assign table1_item_ready = (table1_timer_reg == 8'b0 && table1_qsize > 0);
    assign table1_ready_item = table1_queue[table1_queue_head];

    // Queue sizes
    assign table0_queue_size = table0_qsize;
    assign table1_queue_size = table1_qsize;

endmodule

module d_flip_flop (
    output reg q,
    input d,
    input clk,
    input reset
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            q <= 0;
        end else begin
            q <= d;
        end
    end
endmodule

