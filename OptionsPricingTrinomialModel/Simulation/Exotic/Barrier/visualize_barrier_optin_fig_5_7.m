function visualize_barrier_option_comparison()
    % Main function to visualize barrier option pricing comparison
    
    % Parameters for the barrier option
    S0 = 100;           % Current stock price
    K = 95;             % Strike price
    r = 0.05;           % Risk-free rate
    sigma = 0.2;        % Volatility
    T = 30/365;         % Time to maturity (1 year)
    B = 97.5;           % Barrier level
    p = 0.3;            % Probability for trinomial tree (0 < p <= 0.5)
    q = 0;              % Dividend yield
    
    % Number of time steps to test
    N_values = 0:1:1000;
    
    % Preallocate arrays for results
    trinomial_prices = zeros(size(N_values));
    bs_prices = zeros(size(N_values));
    errors = zeros(size(N_values));
    
    % Calculate Black-Scholes price (closed form solution)
    bs_price = BSDownOutCall(S0, T, K, r, sigma, q, B);
    
    fprintf('Black-Scholes Down-and-Out Call Price: %.4f\n', bs_price);
    fprintf('Running trinomial simulations...\n');
    
    % Calculate trinomial prices for different numbers of time steps
    for i = 1:length(N_values)
        N = N_values(i);
        
        % Calculate trinomial price
        trinomial_price = BarrierOptionDOCTMP(T, S0, K, r, sigma, p, N, B);
        trinomial_prices(i) = trinomial_price;
        
        % Calculate error (difference from BS price)
        errors(i) = trinomial_price - bs_price;
        
        if mod(i, 10) == 0
            fprintf('Completed %d/%d simulations\n', i, length(N_values));
        end
    end
    
    % Create the visualization
    create_plot(N_values, trinomial_prices, bs_prices, errors, bs_price);
end

function create_plot(N_values, trinomial_prices, bs_prices, errors, bs_price)
    % Create the comparison plot
    
    figure('Position', [100, 100, 1200, 800]);
    
    % Main plot for prices
    plot(N_values, trinomial_prices,'DisplayName', 'Trinomial price');
    hold on;
    plot(N_values, ones(size(N_values)) * bs_price, 'DisplayName', 'Closed form solution');
    plot(N_values, errors, 'DisplayName', 'Barrier approximation error');
    
    xlabel('Number of Time Steps (N)');
    ylabel('Down-and-Out (DO) Call Option Price');
    title('Down-and-Out Call Option Price Comparison: Trinomial vs Closed Form');
    legend('show', 'Location', 'best');
    grid off;
    
    % % Error plot
    % subplot(2,1,2);
    % plot(N_values, errors);
    % xlabel('Number of Time Steps (N)');
    % ylabel('Pricing Error');
    % title('Barrier Approximation Error (Trinomial - Closed Form)');
    % grid on;
    
    % Add some statistics
    fprintf('\nError Statistics:\n');
    fprintf('Mean Error: %.6f\n', mean(errors));
    fprintf('Std of Error: %.6f\n', std(errors));
    fprintf('Max Error: %.6f\n', max(abs(errors)));
end

% Run the visualization
visualize_barrier_option_comparison();