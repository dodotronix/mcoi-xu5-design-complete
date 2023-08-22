package clsclk;

    class reset_lengths;
        rand int ResetTimes[0:10];

        // generate array of 10 reset times, used to delay resets in state machines
        constraint A {foreach(ResetTimes[i]) {ResetTimes[i] > 100;
        ResetTimes[i] < 5000;}};
    endclass : reset_lengths


    // class handling creation of clocks
    class clock_generator;

        // connection to clock tree to drive the signals
        virtual t_clocks.producer clk_tree_x;
        reset_lengths r, r1;

        // spawns threads creating clocks
        task run;
            // get reset wait times
            r = new;
            assert(r.randomize());
            fork
                run_100MHz_clock();
                run_GBT_clock();
                run_GBT40_clock();
            join_none

            // fork reset engines and wait until the last one finishes. The
            // resets are deasserted on negedge of all clocks _except_ link
            // clocks, where it is deasserted at 45deg phase of link clock
            // 0. This fits all of them
            fork begin
                clk_tree_x.ClkRs100MHz_ix.reset = '1;
                #(r.ResetTimes[0] * 1ns);
                @(negedge clk_tree_x.ClkRs100MHz_ix.clk);
                clk_tree_x.ClkRs100MHz_ix.reset = '0;
            end begin
                clk_tree_x.ClkRs120MHz_ix.reset = '1;
                #(r.ResetTimes[1] * 1ns);
                @(negedge clk_tree_x.ClkRs120MHz_ix.clk);
                clk_tree_x.ClkRs120MHz_ix.reset = '0;
            end begin
                clk_tree_x.ClkRs40MHz_ix.reset = '1;
                #(r.ResetTimes[2] * 1ns);
                @(negedge clk_tree_x.ClkRs40MHz_ix.clk);
                clk_tree_x.ClkRs40MHz_ix.reset = '0;
            end join // WAIT FOR ALL PROCESSES TO FINISH TO BRING THE SYSTEMS FROM

            $display("System initialized, clocks are running");
        endtask : run

        task run_GBT_clock;
            // two clocks generated here: 120MHz and 40MHz frame clock
            clk_tree_x.ClkRs120MHz_ix.clk  = 1'b0;
            forever begin : gbt_clocks
                clk_tree_x.ClkRs120MHz_ix.clk = 1'b0;
                #4.167ns;
                clk_tree_x.ClkRs120MHz_ix.clk = 1'b1;
                #4.167ns;
                /* clk_tree_x.ClkRs120MHz_ix.clk = '1;
                #4ns;
                clk_tree_x.ClkRs120MHz_ix.clk = '0;
                #4ns; */
            end
        endtask : run_GBT_clock

        task run_GBT40_clock;
            #100ns;
            // sync with 120MHz as it comes from the same PLL
            @(posedge clk_tree_x.ClkRs120MHz_ix.clk);
            // two clocks generated here: 120MHz and 40MHz frame clock
            forever begin : gbt_clocks
                clk_tree_x.ClkRs40MHz_ix.clk = '1;
                #12.5ns;
                clk_tree_x.ClkRs40MHz_ix.clk = '0;
                #12.5ns;
            end
        endtask : run_GBT40_clock

        task run_100MHz_clock;
            forever begin : link_clocks
                clk_tree_x.ClkRs100MHz_ix.clk = '1;
                #5ns;
                clk_tree_x.ClkRs100MHz_ix.clk = '0;
                #5ns;
            end
        endtask : run_100MHz_clock

    endclass : clock_generator


endpackage // clsclk
