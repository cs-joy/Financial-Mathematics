function plot_cliquet_comparison()
    % Parameters for the cliquet option
    F_l = 0;          % Local floor
    C_l = 0.08;       % Local cap
    F_g = 0.16;       % Global floor
    C_g = Inf;        % Global cap (no cap)
    T = 5;            % Total maturity time (years)
    m = 5;            % Number of reset periods
    sigma = 0.2;      % Volatility
    r = 0.03;         % Risk-free rate
    S0 = 100;         % Initial stock price (assumed)
    
    % Range of steps per reset period to test
    N_values = 10:10:200;
    
    % Preallocate arrays for prices
    trinomial_prices = zeros(size(N_values));
    binomial_prices = zeros(size(N_values));
    
    % Calculate prices for each N
    for i = 1:length(N_values)
        N = N_values(i);
        
        % Calculate trinomial price (p_u = p_d = 1/6)
        p_val = 1/6; % p parameter for trinomial model
        
        trinomial_prices(i) = CliquetPriceTrinomial(F_l, C_l, F_g, C_g, T, m, N, sigma, r, p_val);
        
        % Calculate binomial price (special case of trinomial with p = 1/2)
        % For binomial model, we use p = 0.5 (which makes q0 = 0)
        binomial_prices(i) = CliquetPriceTrinomial(F_l, C_l, F_g, C_g, T, m, N, sigma, r, 0.5);
    end
    
    % Reference price from Monte Carlo simulation
    reference_price = 0.174;
    
    % Create the plot
    figure;
    hold on;
    grid on;
    
    % Plot trinomial prices
    plot(N_values, trinomial_prices, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Trinomial Model');
    
    % Plot binomial prices
    plot(N_values, binomial_prices, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Binomial Model');
    
    % Plot reference line
    yline(reference_price, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Reference Price (0.174)');
    
    % Customize the plot
    xlabel('Number of Steps per Reset Period (N)');
    ylabel('Cliquet Option Price');
    title('Comparison of Trinomial and Binomial Model Prices for Cliquet Option');
    legend('Location', 'best');
    
    % Set appropriate axis limits
    y_min = min([trinomial_prices, binomial_prices, reference_price]) * 0.95;
    y_max = max([trinomial_prices, binomial_prices, reference_price]) * 1.05;
    ylim([y_min, y_max]);
    
    hold off;
end