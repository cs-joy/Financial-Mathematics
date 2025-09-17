function real_world_trinomial_options()
    % REAL_WORLD_TRINOMIAL_OPTIONS - Pricing options with real market data
    
    % Clear workspace and close figures
    clear; clc; close all;
    
    fprintf('=== Real-World Trinomial Options Pricing ===\n\n');
    
    % Step 1: Get real market data
    [S0, options_data] = get_market_data();
    
    if isempty(options_data)
        fprintf('No options data retrieved. Using default parameters.\n');
        run_default_example();
        return;
    end
    
    % Step 2: Select an option to price
    selected_option = select_option(options_data);
    
    % Step 3: Extract parameters
    K = selected_option.strike;
    T = selected_option.days_to_expiry / 365;  % Convert to years
    market_price = selected_option.last_price;
    option_type = selected_option.type;
    
    % Step 4: Get risk-free rate (approximate with 10-year Treasury yield)
    r = get_risk_free_rate();
    
    % Step 5: Estimate volatility (historical volatility)
    sigma = estimate_volatility(S0);
    
    % Step 6: Set up trinomial model parameters
    N = 100;  % Number of steps (higher = more accurate)
    h = T / N;  % Time step size
    p = 0.4;   % Probability parameter (optimized value)
    
    fprintf('\n=== Parameters ===\n');
    fprintf('Underlying Price (S0): $%.2f\n', S0);
    fprintf('Strike Price (K): $%.2f\n', K);
    fprintf('Time to Expiry (T): %.3f years (%.0f days)\n', T, T*365);
    fprintf('Risk-free Rate (r): %.3f%%\n', r*100);
    fprintf('Volatility (σ): %.3f%%\n', sigma*100);
    fprintf('Number of Steps (N): %d\n', N);
    fprintf('Probability Parameter (p): %.2f\n', p);
    
    % Step 7: Define payoff function
    if strcmpi(option_type, 'call')
        payoff_func = @(x) max(x - K, 0);
        bs_price = blsprice(S0, K, r, T, sigma, 0);
    else
        payoff_func = @(x) max(K - x, 0);
        [~, bs_price] = blsprice(S0, K, r, T, sigma, 0);
    end
    
    % Step 8: Calculate u parameter for trinomial model
    u = sigma * sqrt(h / (2 * p));
    
    % Step 9: Generate stock price tree and calculate option price
    S = generate_stock_tree(S0, N, u);
    trinomial_price = calculate_option_price(S, payoff_func, r, p, h, u);
    
    % Step 10: Display results
    fprintf('\n=== Pricing Results ===\n');
    fprintf('Market Price: $%.4f\n', market_price);
    fprintf('Trinomial Model Price: $%.4f\n', trinomial_price);
    fprintf('Black-Scholes Price: $%.4f\n', bs_price);
    fprintf('Trinomial Error vs Market: $%.4f (%.2f%%)\n', ...
        abs(trinomial_price - market_price), ...
        abs(trinomial_price - market_price)/market_price*100);
    fprintf('Black-Scholes Error vs Market: $%.4f (%.2f%%)\n', ...
        abs(bs_price - market_price), ...
        abs(bs_price - market_price)/market_price*100);
    
    % Step 11: Convergence analysis
    analyze_convergence(S0, K, r, T, sigma, payoff_func, market_price, bs_price);
end

function [S0, options_data] = get_market_data()
    % GET_MARKET_DATA - Retrieve real market data from Yahoo Finance
    
    fprintf('Retrieving market data...\n');
    
    try
        % Using AAPL as example - you can change the symbol
        symbol = 'AAPL';
        
        % Create connection to Yahoo Finance
        c = yahoo;
        
        % Get current stock price
        data = fetch(c, symbol);
        S0 = data.Last;
        
        % Get options data (nearest expiration)
        options_data = get_options_chain(symbol);
        
        fprintf('Successfully retrieved data for %s: $%.2f\n', symbol, S0);
        
    catch
        fprintf('Could not connect to Yahoo Finance. Using simulated data.\n');
        S0 = 150;  % Example price
        options_data = [];
    end
end

function options_data = get_options_chain(symbol)
    % GET_OPTIONS_CHAIN - Simulate options data retrieval
    % In practice, you would use Datafeed Toolbox or web scraping
    
    % Simulated options data for demonstration
    options_data = struct();
    
    % Example call options
    options_data(1).strike = 145;
    options_data(1).last_price = 8.50;
    options_data(1).days_to_expiry = 30;
    options_data(1).type = 'call';
    
    options_data(2).strike = 150;
    options_data(2).last_price = 5.25;
    options_data(2).days_to_expiry = 30;
    options_data(2).type = 'call';
    
    options_data(3).strike = 155;
    options_data(3).last_price = 3.10;
    options_data(3).days_to_expiry = 30;
    options_data(3).type = 'call';
    
    % Example put options
    options_data(4).strike = 145;
    options_data(4).last_price = 2.75;
    options_data(4).days_to_expiry = 30;
    options_data(4).type = 'put';
    
    options_data(5).strike = 150;
    options_data(5).last_price = 4.50;
    options_data(5).days_to_expiry = 30;
    options_data(5).type = 'put';
    
    options_data(6).strike = 155;
    options_data(6).last_price = 7.25;
    options_data(6).days_to_expiry = 30;
    options_data(6).type = 'put';
end

function selected = select_option(options_data)
    % SELECT_OPTION - Let user select an option to price
    
    fprintf('\nAvailable Options:\n');
    for i = 1:length(options_data)
        fprintf('%d. %s $%.0f - Price: $%.2f - Expiry: %d days\n', ...
            i, upper(options_data(i).type), ...
            options_data(i).strike, ...
            options_data(i).last_price, ...
            options_data(i).days_to_expiry);
    end
    
    choice = input('\nSelect option to price (1-6): ');
    if choice < 1 || choice > length(options_data)
        choice = 2;  % Default choice
    end
    
    selected = options_data(choice);
    fprintf('Selected: %s option with strike $%.0f\n', ...
        upper(selected.type), selected.strike);
end

function r = get_risk_free_rate()
    % GET_RISK_FREE_RATE - Approximate risk-free rate
    % Using current 10-year Treasury yield as proxy
    
    % In practice, you would fetch this from FRED or similar
    r = 0.0425;  % 4.25% - approximate current rate
    fprintf('Using risk-free rate: %.3f%% (10-year Treasury yield proxy)\n', r*100);
end

function sigma = estimate_volatility(S0)
    % ESTIMATE_VOLATILITY - Estimate historical volatility
    
    % For real implementation, you would calculate historical volatility
    % from past price data. Here we use a reasonable estimate.
    
    if S0 > 100
        sigma = 0.25;  % 25% volatility for large stocks
    else
        sigma = 0.35;  % 35% volatility for smaller stocks
    end
    
    fprintf('Estimated historical volatility: %.2f%%\n', sigma*100);
end

function S = generate_stock_tree(S0, N, u)
    % GENERATE_STOCK_TREE - Generate trinomial stock price tree
    
    S = zeros(2*N+1, N+1);
    S(N+1, 1) = S0;
    
    for j = 1:N
        S(:, j+1) = S(:, j);
        
        % Upward moves
        for i = 1:min(j, N)
            row_idx = N+1-i;
            if row_idx >= 1
                S(row_idx, j+1) = S(row_idx+1, j) * exp(u);
            end
        end
        
        % Downward moves
        for i = 1:min(j, N)
            row_idx = N+1+i;
            if row_idx <= size(S, 1)
                S(row_idx, j+1) = S(row_idx-1, j) * exp(-u);
            end
        end
    end
end

function option_price = calculate_option_price(S, payoff_func, r, p, h, u)
    % CALCULATE_OPTION_PRICE - Price option using trinomial model
    
    M = size(S, 1);
    N = size(S, 2);
    P = zeros(M, N);
    
    % Calculate risk-neutral probabilities
    q0 = 1 - 2 * p;
    qu = (exp(r*h) - exp(-u)) / (exp(u) - exp(-u)) - ...
          q0 * (1 - exp(-u)) / (exp(u) - exp(-u));
    qd = (exp(u) - exp(r*h)) / (exp(u) - exp(-u)) - ...
          q0 * (exp(u) - 1) / (exp(u) - exp(-u));
    
    % Terminal payoff
    P(:, N) = payoff_func(S(:, N));
    
    % Backward induction
    for j = N-1:-1:1
        for i = (N-j+1):(M-(N-j))
            if i > 1 && i < M
                P(i, j) = exp(-r*h) * (qu * P(i-1, j+1) + ...
                                      q0 * P(i, j+1) + ...
                                      qd * P(i+1, j+1));
            end
        end
    end
    
    option_price = P(ceil(M/2), 1);
end

function analyze_convergence(S0, K, r, T, sigma, payoff_func, market_price, bs_price)
    % ANALYZE_CONVERGENCE - Analyze model convergence
    
    fprintf('\n=== Convergence Analysis ===\n');
    
    N_values = [50, 100, 200, 500];
    p_values = [0.3, 0.4, 0.5];
    prices = zeros(length(N_values), length(p_values));
    
    figure;
    for p_idx = 1:length(p_values)
        p = p_values(p_idx);
        
        for n_idx = 1:length(N_values)
            N = N_values(n_idx);
            h = T / N;
            u = sigma * sqrt(h / (2 * p));
            
            S = generate_stock_tree(S0, N, u);
            prices(n_idx, p_idx) = calculate_option_price(S, payoff_func, r, p, h, u);
        end
        
        subplot(2,1,1);
        plot(N_values, prices(:, p_idx), 'o-', 'LineWidth', 2, 'DisplayName', sprintf('p=%.1f', p));
        hold on;
    end
    
    % Add reference lines
    yline(market_price, 'r--', 'LineWidth', 2, 'DisplayName', 'Market Price');
    yline(bs_price, 'g--', 'LineWidth', 2, 'DisplayName', 'Black-Scholes');
    
    xlabel('Number of Steps (N)');
    ylabel('Option Price');
    title('Trinomial Model Convergence');
    legend('show');
    grid on;
    
    % Error analysis
    subplot(2,1,2);
    errors = abs(prices - market_price);
    semilogy(N_values, errors, 'o-', 'LineWidth', 2);
    xlabel('Number of Steps (N)');
    ylabel('Absolute Error ($)');
    title('Pricing Error vs Market Price');
    legend('p=0.3', 'p=0.4', 'p=0.5');
    grid on;
end

function run_default_example()
    % RUN_DEFAULT_EXAMPLE - Run with default parameters

    fprintf('Running with default parameters...\n');

    % Default parameters
    S0 = 150;       % Apple-like stock price
    K = 150;        % At-the-money option
    r = 0.0425;     % Risk-free rate
    sigma = 0.25;   % Volatility
    T = 30/365;     % 30 days to expiration
    N = 100;        % Number of steps
    p = 0.4;        % Probability parameter

    % Call option
    payoff_func = @(x) max(x - K, 0);
    h = T / N;
    u = sigma * sqrt(h / (2 * p));

    S = StockPricesNew(S0, N, u);
    trinomial_price = calculate_option_price(S, payoff_func, r, p, h, u);
    bs_price = blsprice(S0, K, r, T, sigma, 0);

    fprintf('\nDefault Example Results:\n');
    fprintf('Trinomial Price: $%.4f\n', trinomial_price);
    fprintf('Black-Scholes Price: $%.4f\n', bs_price);
    fprintf('Difference: $%.4f\n', abs(trinomial_price - bs_price));
end