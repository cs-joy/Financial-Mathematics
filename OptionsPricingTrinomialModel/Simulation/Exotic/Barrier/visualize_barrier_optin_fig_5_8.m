function visualize_barrier_option_comparison_5_8_fig()
    % Main function to visualize barrier option pricing comparison
    
    % Parameters for the barrier option
    S0 = 100;           % Current stock price
    K = 70;             % Strike price
    r = 0.05;           % Risk-free rate
    sigma = 0.2;        % Volatility
    T = 30/365;         % Time to maturity (30 days)
    B = 85:3:97;        % Barrier level
    p = 0.3;            % Probability for trinomial tree (0 < p <= 0.5)
    q = 0;              % Dividend yield
    
    % Number of time steps to test
    N_values = 0:1:500;
    
    fprintf('Running trinomial simulations for multiple barrier levels...\n');
    
    % Create figure
    figure('Position', [100, 100, 1000, 700]);
    hold on;
    
    % Colors for different barrier levels
    colors = lines(length(B));
    
    % Calculate and plot for each barrier level
    for b_idx = 1:length(B)
        barrier = B(b_idx);
        
        % Preallocate arrays for results
        trinomial_prices = zeros(size(N_values));
        errors = zeros(size(N_values));
        
        % Calculate Black-Scholes price (closed form solution)
        bs_price = BSDownOutCall(S0, T, K, r, sigma, q, barrier);
        
        % Calculate trinomial prices for different numbers of time steps
        for i = 1:length(N_values)
            N = N_values(i);
            if N == 0
                trinomial_prices(i) = 0;
            else
                % Calculate trinomial price
                trinomial_price = BarrierOptionDOCTMP(T, S0, K, r, sigma, p, N, barrier);
                trinomial_prices(i) = trinomial_price;
            end
            % Calculate error (difference from BS price)
            errors(i) = trinomial_prices(i) - bs_price;
        end
        
        % Plot trinomial prices
        plot(N_values, trinomial_prices, '--', 'Color', colors(b_idx, :), ...
              'DisplayName', sprintf('Trinomial price (B=%.1f)', barrier));
        
        % Plot closed form solution as horizontal line
        plot([min(N_values), max(N_values)], [bs_price, bs_price], ...
             'Color', colors(b_idx, :), ...
             'DisplayName', sprintf('Closed form (B=%.1f)', barrier));
        
        fprintf('Completed barrier level B=%.1f, BS Price: %.4f, TM Price: %.4f\n', barrier, bs_price, trinomial_prices(i));
    end
    
    % Customize the plot to match the attached picture style
    xlabel('Number of Time Steps (N)');
    ylabel('Down-and-Out (DO) Call Option Price');
    title('Down-and-Out Call Option Price Comparison: Trinomial vs Closed Form');
    legend('show', 'Location', 'best');
    grid off;
    
    % Set axis limits to match the style in the picture
    %xlim([0, 50]);
    %ylim([0, 35]);
    
    % Add some statistics for the last barrier level
    fprintf('\nFinal Barrier Level (B=%.1f) Statistics:\n', B(end));
    fprintf('Black-Scholes Price: %.4f\n', bs_price);
    fprintf('Final Trinomial Price: %.4f\n', trinomial_prices(end));
    fprintf('Final Error: %.6f\n', errors(end));
end


% Run the visualization
visualize_barrier_option_comparison_5_8_fig();