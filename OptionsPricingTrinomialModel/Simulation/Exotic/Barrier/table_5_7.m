function [trinomial_times, percentages, bs_times] = generate_table_5_7()
    % Main function to generate Table 5.7 with computational times
    % Returns:
    %   trinomial_times - matrix of trinomial computation times in microseconds
    %   percentages - matrix of percentage differences
    %   bs_times - matrix of Black-Scholes computation times in microseconds
    
    % Parameters from the problem
    S0 = 100;           % Current stock price
    K = 70;             % Strike price
    r = 0.05;           % Risk-free rate
    sigma = 0.2;        % Volatility
    T = 30/365;         % Time to maturity (30 days)
    p = 1/6;            % Probability for trinomial tree
    q = 0;              % Dividend yield
    
    % Barrier levels and iteration counts from Table 5.7
    barrier_levels = [85, 88, 91, 94, 97];
    N_values = [10, 20, 30, 40, 50];
    
    fprintf('Generating Table 5.7: Computational Times Comparison\n');
    fprintf('===================================================\n\n');
    fprintf('Parameters: T=30/365, r=0.05, S0=100, K=70, sigma=0.2, p=1/6\n');
    fprintf('Running 1000 simulations for each combination...\n\n');
    
    % Preallocate results
    trinomial_times = zeros(length(N_values), length(barrier_levels));
    bs_times = zeros(length(N_values), length(barrier_levels));
    percentages = zeros(length(N_values), length(barrier_levels));
    
    % Number of runs for averaging (as mentioned in the paper: 1000 runs)
    num_runs = 1000;
    
    fprintf('Performing warm-up runs to avoid JIT compilation delays...\n');
    % Warm-up runs to initialize functions and avoid JIT compilation delays
    for k = 1:50
        BarrierOptionDOCTMP(T, S0, K, r, sigma, p, 10, 85);
        BSDownOutCall(S0, T, K, r, sigma, q, 85);
    end
    
    fprintf('Starting computational time measurements...\n\n');
    
    % Main simulation loop
    for i = 1:length(N_values)
        N = N_values(i);
        fprintf('Processing N = %d:\n', N);
        
        for j = 1:length(barrier_levels)
            B = barrier_levels(j);
            fprintf('  Barrier B = %d... ', B);
            
            % Measure computational time for trinomial method
            trinomial_time_total = 0;
            for k = 1:num_runs
                start_time = tic;
                trinomial_price = BarrierOptionDOCTMP(T, S0, K, r, sigma, p, N, B);
                trinomial_time_total = trinomial_time_total + toc(start_time);
            end
            avg_trinomial_time = (trinomial_time_total / num_runs) * 1e6; % Convert to microseconds
            
            % Measure computational time for Black-Scholes method
            bs_time_total = 0;
            for k = 1:num_runs
                start_time = tic;
                bs_price = BSDownOutCall(S0, T, K, r, sigma, q, B);
                bs_time_total = bs_time_total + toc(start_time);
            end
            avg_bs_time = (bs_time_total / num_runs) * 1e6; % Convert to microseconds
            
            % Calculate percentage difference as defined in the paper:
            % Percentage = ((Trinomial_Time - BS_Time) / BS_Time) * 100
            percentage = ((avg_trinomial_time - avg_bs_time) / avg_bs_time) * 100;
            
            trinomial_times(i, j) = avg_trinomial_time;
            bs_times(i, j) = avg_bs_time;
            percentages(i, j) = percentage;
            
            fprintf('Trinomial: %.1f μs, BS: %.1f μs, Diff: %.2f%%\n', ...
                    avg_trinomial_time, avg_bs_time, percentage);
        end
        fprintf('\n');
    end
    
    % Display the final table
    display_final_table(N_values, barrier_levels, trinomial_times, percentages);
    
    % Display computational statistics
    display_statistics(trinomial_times, bs_times);
    
    fprintf('\nTable 5.7 generation completed.\n');
end

function display_final_table(N_values, barrier_levels, trinomial_times, percentages)
    fprintf('\n\n');
    fprintf('==================================================================================\n');
    fprintf('                            TABLE 5.7: COMPUTATIONAL TIMES\n');
    fprintf('==================================================================================\n\n');
    
    fprintf('Description:\n');
    fprintf('------------\n');
    fprintf('• Trinomial computation times in microseconds (μs)\n');
    fprintf('• Percentage difference in parentheses: ((Trinomial_Time - BS_Time) / BS_Time) * 100\n');
    fprintf('• Positive percentage: Trinomial takes longer than Black-Scholes\n');
    fprintf('• Negative percentage: Black-Scholes takes longer than Trinomial\n');
    fprintf('• Based on 1000 runs for each combination\n');
    fprintf('• Computer: 2.3GHz Intel Core i7-4712MQ, 8GB 1600MHz RAM\n\n');
    
    % Header
    fprintf('%-6s', 'N');
    for j = 1:length(barrier_levels)
        fprintf(' & %-15s', sprintf('B=%d', barrier_levels(j)));
    end
    fprintf(' \\\\\n');
    fprintf('%s\n', repmat('-', 1, 100));
    
    % Data rows
    for i = 1:length(N_values)
        fprintf('%-6d', N_values(i));
        for j = 1:length(barrier_levels)
            fprintf(' & %-6.1fμs \\\\ ', trinomial_times(i, j));
            if percentages(i, j) >= 0
                fprintf('(%-6.2f%%)', percentages(i, j));
            else
                fprintf('(%-6.2f%%)', percentages(i, j));
            end
        end
        fprintf(' \\\\\n');
    end
end

function display_statistics(trinomial_times, bs_times)
    fprintf('\n\nCOMPUTATIONAL TIME STATISTICS:\n');
    fprintf('=============================\n');
    fprintf('Trinomial Model:\n');
    fprintf('  Minimum time: %.2f μs\n', min(trinomial_times(:)));
    fprintf('  Maximum time: %.2f μs\n', max(trinomial_times(:)));
    fprintf('  Average time: %.2f μs\n', mean(trinomial_times(:)));
    fprintf('  Standard deviation: %.2f μs\n', std(trinomial_times(:)));
    
    fprintf('\nBlack-Scholes Model:\n');
    fprintf('  Minimum time: %.2f μs\n', min(bs_times(:)));
    fprintf('  Maximum time: %.2f μs\n', max(bs_times(:)));
    fprintf('  Average time: %.2f μs\n', mean(bs_times(:)));
    fprintf('  Standard deviation: %.2f μs\n', std(bs_times(:)));
    
    fprintf('\nSpeed Comparison:\n');
    avg_trinomial = mean(trinomial_times(:));
    avg_bs = mean(bs_times(:));
    if avg_trinomial > avg_bs
        fprintf('  On average, trinomial model is %.1fx slower than Black-Scholes\n', avg_trinomial/avg_bs);
    else
        fprintf('  On average, Black-Scholes is %.1fx slower than trinomial model\n', avg_bs/avg_trinomial);
    end
end

% Function to analyze timing variance as mentioned in the paper
function analyze_timing_variance()
    fprintf('\n\nANALYZING TIMING VARIANCE (as mentioned in paper):\n');
    fprintf('==============================================\n');
    
    S0 = 100; K = 70; r = 0.05; sigma = 0.2; T = 30/365; p = 1/6; q = 0;
    B = 85; N = 50;
    
    num_runs = 1000;
    trinomial_times = zeros(num_runs, 1);
    bs_times = zeros(num_runs, 1);
    
    fprintf('Running %d iterations for variance analysis...\n', num_runs);
    
    for k = 1:num_runs
        % Trinomial time
        start_time = tic;
        BarrierOptionDOCTMP(T, S0, K, r, sigma, p, N, B);
        trinomial_times(k) = toc(start_time) * 1e6;
        
        % BS time
        start_time = tic;
        BSDownOutCall(S0, T, K, r, sigma, q, B);
        bs_times(k) = toc(start_time) * 1e6;
    end
    
    fprintf('Trinomial timing variance: %.4f μs²\n', var(trinomial_times));
    fprintf('Black-Scholes timing variance: %.4f μs²\n', var(bs_times));
    fprintf('Trinomial timing std dev: %.4f μs\n', std(trinomial_times));
    fprintf('Black-Scholes timing std dev: %.4f μs\n', std(bs_times));
    
    % Verify the paper's claim about variance
    if max([var(trinomial_times), var(bs_times)]) <= 0.1
        fprintf('✓ Variance is at most 0.1 μs (matches paper claim)\n');
    else
        fprintf('✗ Variance exceeds 0.1 μs\n');
    end
end

% Main execution
fprintf('TABLE 5.7 COMPUTATIONAL TIME ANALYSIS\n');
fprintf('=====================================\n\n');
    
% Generate the main table
[trinomial_times, percentages, bs_times] = generate_table_5_7();
    
% Analyze timing variance as mentioned in the paper
analyze_timing_variance();
    
fprintf('\nAll computations completed successfully.\n');