function [option_data, stock_price] = get_yahoo_data(symbol)
    % Get option chain data from Yahoo Finance
    url = ['https://query1.finance.yahoo.com/v7/finance/options/' symbol];
    
    try
        % Read data from Yahoo Finance API
        data = webread(url);
        
        % Extract current stock price
        stock_price = data.optionChain.result(1).quote.regularMarketPrice;
        
        % Extract put options data
        options = data.optionChain.result(1).options;
        if ~isempty(options)
            puts = options(1).puts;
            
            % Create structured output
            option_data = struct();
            for i = 1:min(10, length(puts)) % Get first 10 puts
                option_data(i).strike = puts(i).strike;
                option_data(i).last_price = puts(i).lastPrice;
                option_data(i).bid = puts(i).bid;
                option_data(i).ask = puts(i).ask;
                option_data(i).volume = puts(i).volume;
                option_data(i).open_interest = puts(i).openInterest;
                option_data(i).expiration = datetime(puts(i).expiration*1000, 'ConvertFrom', 'posixtime');
                option_data(i).implied_vol = puts(i).impliedVolatility;
                option_data(i).days_to_expire = days(option_data(i).expiration - datetime('today'));
            end
            
            fprintf('Successfully fetched data for %s\n', symbol);
            fprintf('Current stock price: $%.2f\n', stock_price);
            
        else
            option_data = [];
            fprintf('No option data found for %s\n', symbol);
        end
        
    catch ME
        fprintf('Error fetching data: %s\n', ME.message);
        option_data = [];
        stock_price = [];
    end
end

disp(get_yahoo_data('AAPL'));