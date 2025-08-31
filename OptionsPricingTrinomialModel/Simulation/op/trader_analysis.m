function trader_analysis()
    % Analyze multiple strikes
    strikes = [110, 125, 130, 135, 140, 145, 150, 155, 160];
    implied_vols = [1.75, 1.50, 1.37, 1.31, 1.62, 1.54, 0.16, 1.14, 1.25];
    ask_prices = [0.01, 0.01, 0.01, 0.01, 0.20, 0.21, 0.61, 0.05, 0.21];
    
    S0 = 218;
    r = 0.043;
    T = 7/365; % 7 days to expiration
    N = 100;
    
    fprintf('Strike | Model Price | Market Ask | IV %% | Status\n');
    fprintf('-------|-------------|------------|------|--------\n');
    
    for i = 1:length(strikes)
        h = T/N;
        u = implied_vols(i) * sqrt(3*h);
        p = 1/6;
        
        S_tree = StockPricesnew(S0, N, u);
        put_price = AmericanPut(S_tree, strikes(i), r, N, p, h, u);
        model_price = put_price(N+1, 1);
        
        status = '';
        if model_price > ask_prices(i) * 1.1
            status = 'UNDERVALUED';
        elseif model_price < ask_prices(i) * 0.9
            status = 'OVERVALUED';
        else
            status = 'FAIR VALUE';
        end
        
        fprintf('$%3d   | $%8.4f   | $%8.4f  | %3.0f%% | %s\n', ...
                strikes(i), model_price, ask_prices(i), implied_vols(i)*100, status);
    end
end