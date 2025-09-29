function [percentage_errors] = generate_table_5_8()
    % Main function to generate Table 5.8 with percentage errors
    % due to maximum barrier approximation errors
    
    % Parameters from the problem
    S0 = 100;           % Current stock price
    K = 70;             % Strike price
    r = 0.05;           % Risk-free rate
    sigma = 0.2;        % Volatility
    T = 30/365;         % Time to maturity
    p = 1/6;            % Probability for trinomial tree
    q = 0;              % Dividend yield
    
    % Barrier levels and iteration counts
    barrier_levels = [85, 88, 91, 94, 97];
    N_values = [10, 20, 30, 40, 50];
    
    fprintf('Computing percentage errors due to barrier approximation...\n');
    
    % Preallocate results
    percentage_errors = zeros(length(N_values), length(barrier_levels));
    
    % Calculate percentage errors for each combination
    for i = 1:length(N_values)
        N = N_values(i);
        fprintf('Processing N = %d...\n', N);
        
        for j = 1:length(barrier_levels)
            B = barrier_levels(j);
            
            % Calculate trinomial price
            trinomial_price = BarrierOptionDOCTMP(T, S0, K, r, sigma, p, N, B);
            
            % Calculate Black-Scholes price (theoretical)
            bs_price = BSDownOutCall(S0, T, K, r, sigma, q, B);
            
            % Calculate relative error/ percentage error
            % The relative error expresses the absolute error as a proportion 
            % of the Black-Scholes price, often converted to a percentage. 
            % This is useful for understanding the magnitude of the error in 
            % relation to the true value (assuming Black-Scholes is the benchmark).
            if bs_price > 0
                percentage_error = abs(trinomial_price - bs_price) / bs_price * 100;
            else
                percentage_error = 0;
            end
            
            percentage_errors(i, j) = percentage_error;
        end
    end
    
    % Display the table
    display_table(N_values, barrier_levels, percentage_errors);
    
    fprintf('\nComputation completed.\n');
end

function display_table(N_values, barrier_levels, percentage_errors)
    fprintf('\n');
    fprintf('Table 5.8: Theoretical Trinomial Price Percentage Error\n');
    fprintf('======================================================\n\n');
    
    % Header
    fprintf('%-4s', 'N');
    for j = 1:length(barrier_levels)
        fprintf(' & B=%-4d', barrier_levels(j));
    end
    fprintf(' \\\\\n');
    
    fprintf('%s\n', repmat('-', 1, 60));
    
    % Data rows
    for i = 1:length(N_values)
        fprintf('%-4d', N_values(i));
        for j = 1:length(barrier_levels)
            fprintf(' & %-8.3f%%', percentage_errors(i, j));
        end
        fprintf(' \\\\\n');
    end
end


generate_table_5_8();