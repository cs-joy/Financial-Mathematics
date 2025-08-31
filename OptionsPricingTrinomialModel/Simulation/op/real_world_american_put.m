function real_world_american_put()
    % Real-world parameters for AAPL $150 Put
    S0 = 232.03;           % Current AAPL price
    K = 150;            % Strike price
    r = 0.043;          % 1-year Treasury yield
    expiration_date = datetime('2025-09-05');
    current_date = datetime('2025-08-29');
    T = days(expiration_date - current_date) / 365; % 7 days = 0.0192 years
    
    % Use implied volatility from your table
    sigma = 1.6719;       % 167.19% implied vol for $150 strike
    
    % Dividend parameters (for completeness)
    q = 0.0053;         % Dividend yield
    next_div_date = datetime('2025-11-07'); % After expiration
    % No dividend adjustment needed since expiration before next dividend
    
    % Model parameters
    N = 100;            % Number of steps
    h = T / N;          % Time step
    u = sigma * sqrt(3 * h); % Price change factor
    p = 1/6;            % Probability
    
    fprintf('=== REAL-WORLD AAPL AMERICAN PUT CALCULATION ===\n');
    fprintf('Stock: AAPL @ $%.2f\n', S0);
    fprintf('Strike: $%.2f\n', K);
    fprintf('Time to expiration: %.4f years (%d days)\n', T, days(expiration_date - current_date));
    fprintf('Risk-free rate: %.2f%%\n', r*100);
    fprintf('Implied volatility: %.2f%%\n', sigma*100);
    fprintf('\n');
    
    % Generate stock tree
    S_tree = StockPricesnew(S0, N, u);
    
    % Calculate American put price
    put_price = AmericanPut(S_tree, K, r, N, p, h, u);
    model_price = put_price(N+1, 1);
    
    fprintf('Model Price: $%.4f\n', model_price);
    
    % Compare with market
    market_bid = 0.00;   % Bid - From the data table (option_image/yahoo_finance_AAPL_data.png)
    market_ask = 0.61;   % Ask - From the data table (option_image/yahoo_finance_AAPL_data.png)
    market_mid = (market_bid + market_ask) / 2;
    
    fprintf('Market Price: Bid $%.2f, Ask $%.2f\n', market_bid, market_ask);
    fprintf('Market Midpoint: $%.4f\n', market_mid);
    
    % Analysis
    if model_price > market_mid
        fprintf('✅ Model suggests PUT MAY BE UNDERVALUED\n');
    elseif model_price < market_mid
        fprintf('⚠️  Model suggests PUT MAY BE OVERVALUED\n');
    else
        fprintf('⚖️  Model matches market\n');
    end
end