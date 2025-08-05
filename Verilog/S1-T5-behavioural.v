// S1-T5 (DDS-mini-project-2024-25)
// Dineflow - Smart Automatic Restaurant Management System
// Team members-
// 1) Rakshith Ashok Kumar - 231CS147
// 2) Utsav Singh Bhamra - 231CS161
// 3) Akshaj PVY - 231CS109


module restaurant_management_system (
     input clk,
     input reset,
     input [1:0] table0_order_item, // 2-bit order items
     input table0_order_valid,
     input [1:0] table1_order_item, // 2-bit order items
     input table1_order_valid,
     output reg [7:0] table0_bill,
     output reg [7:0] table1_bill,
     output reg table0_order_reject,
     output reg table1_order_reject,
     output reg [3:0] table0_queue_size,
     output reg [3:0] table1_queue_size,
     output reg [1:0] table0_ready_item, // 2-bit ready items
     output reg [1:0] table1_ready_item, // 2-bit ready items
     output reg table0_item_ready,
     output reg table1_item_ready
 );

   // Parameters
   parameter NUM_ITEMS = 4; // Items 0 to 3
   parameter QUEUE_SIZE = 16;

   // Inventory
   reg [3:0] inventory [0:NUM_ITEMS-1];

   // Menu prices and preparation times
   reg [7:0] item_prices [0:NUM_ITEMS-1];
   reg [7:0] item_prep_times [0:NUM_ITEMS-1];

   // Order queues
   reg [1:0] table0_queue [0:QUEUE_SIZE-1]; // 2-bit order items
   reg [1:0] table1_queue [0:QUEUE_SIZE-1]; // 2-bit order items
   reg [3:0] table0_queue_head, table0_queue_tail;
   reg [3:0] table1_queue_head, table1_queue_tail;

   // Timers
   reg [7:0] table0_timer, table1_timer;

   integer i;

   // Initialize inventory, prices, and prep times
   initial begin
       for (i = 0; i < NUM_ITEMS; i = i + 1) begin
           inventory[i] = 5;
           item_prices[i] = i+2; // Prices set to 0,1,2,3
           item_prep_times[i] = i+1; // Preparation times set to 0,1,2,3
       end
   end

   always @(posedge clk or posedge reset) begin
       if (reset) begin
           // Reset all registers
           table0_bill <= 0;
           table1_bill <= 0;
           table0_order_reject <= 0;
           table1_order_reject <= 0;
           table0_queue_size <= 0;
           table1_queue_size <= 0;
           table0_ready_item <= 0;
           table1_ready_item <= 0;
           table0_item_ready <= 0;
           table1_item_ready <= 0;
           table0_queue_head <= 0;
           table0_queue_tail <= 0;
           table1_queue_head <= 0;
           table1_queue_tail <= 0;
           table0_timer <= 0;
           table1_timer <= 0;

           for (i = 0; i < NUM_ITEMS; i = i + 1) begin
               inventory[i] <= 5;
           end
       end else begin
           // Handle orders for Table 0
           if (table0_order_valid) begin
               if (inventory[table0_order_item] > 0 && table0_queue_size < QUEUE_SIZE) begin
                   inventory[table0_order_item] <= inventory[table0_order_item] - 1;
                   table0_queue[table0_queue_tail] <= table0_order_item;
                   table0_queue_tail <= (table0_queue_tail + 1) % QUEUE_SIZE;
                   table0_queue_size <= table0_queue_size + 1;
                   table0_bill <= table0_bill + item_prices[table0_order_item];
                   table0_order_reject <= 0;
               end else begin
                   table0_order_reject <= 1;
               end
           end else begin
               table0_order_reject <= 0;
           end

           // Handle orders for Table 1
           if (table1_order_valid) begin
               if (inventory[table1_order_item] > 0 && table1_queue_size < QUEUE_SIZE) begin
                   inventory[table1_order_item] <= inventory[table1_order_item] - 1;
                   table1_queue[table1_queue_tail] <= table1_order_item;
                   table1_queue_tail <= (table1_queue_tail + 1) % QUEUE_SIZE;
                   table1_queue_size <= table1_queue_size + 1;
                   table1_bill <= table1_bill + item_prices[table1_order_item];
                   table1_order_reject <= 0;
               end else begin
                   table1_order_reject <= 1;
               end
           end else begin
               table1_order_reject <= 0;
           end

           // Handle timers and item readiness for Table 0
           if (table0_queue_size > 0) begin
               if (table0_timer == 0) begin
                   table0_timer <= item_prep_times[table0_queue[table0_queue_head]];
               end else if (table0_timer == 1) begin
                   table0_ready_item <= table0_queue[table0_queue_head];
                   table0_item_ready <= 1;
                   table0_queue_head <= (table0_queue_head + 1) % QUEUE_SIZE;
                   table0_queue_size <= table0_queue_size - 1;
                   table0_timer <= 0;
               end else begin
                   table0_timer <= table0_timer - 1;
                   table0_item_ready <= 0;
               end
           end else begin
               table0_item_ready <= 0;
           end

           // Handle timers and item readiness for Table 1
           if (table1_queue_size > 0) begin
               if (table1_timer == 0) begin
                   table1_timer <= item_prep_times[table1_queue[table1_queue_head]];
               end else if (table1_timer == 1) begin
                   table1_ready_item <= table1_queue[table1_queue_head];
                   table1_item_ready <= 1;
                   table1_queue_head <= (table1_queue_head + 1) % QUEUE_SIZE;
                   table1_queue_size <= table1_queue_size - 1;
                   table1_timer <= 0;
               end else begin
                   table1_timer <= table1_timer - 1;
                   table1_item_ready <= 0;
               end
           end else begin
               table1_item_ready <= 0;
           end
       end
   end

endmodule
