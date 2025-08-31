%% Yahoo Finance - APPL
% way to find out necessary parameters value from the real-world market
% scenario

% Strike price (K)
% from the data we let,$150 as Striker price, you can look at
% option_image/yahoo_finance_AAPL_data.png
K = 150;

% Risk-Free Rate (r)
% Source: US Treasury yields (match option expiration)
% Current 1-year Treasury yield: ~4.3% (as of 2025)
% Formula: r = 4.3/100 ~0.043
r = 0.043;

% Time to Expiration (T)
% From contract: Expiration September 5, 2025
% Current date: Assume August 29, 2025
expiration_date = datetime('2025-09-05');
current_date = datetime('2025-08-29');
T = days(expiration_date - current_date) / 365; % 7 days = ~0.0192 years
%disp(T);


% Volatility (σ) - MOST CRITICAL PARAMETER
% there are two way to calculate volatility:
%%%%
% Option 1: Use Implied Volatility from Table
sigma = 1.6719; % From(option_image/yahoo_finance_AAPL_data.png) the table for $150 strike: 167.19% implied volality
%%%%
% Option 2: Calculate historical volatility
% Using 30-day historical volatility
%
historical_prices = [218, 220, 215, 217, 219, 216, 218, 220, 219, 217]; % example
returns = price2ret(historical_prices);
sigma = std(returns) * sqrt(252); % annualized volatility


% Dividend Yield (q) - FOR AAPL
% AAPL dividend information
dividend_yield = 0.0053; % 0.53% annual dividend yield
next_dividend_date = datetime('2025-11-07');
dividend_amount = 0.24; % $0.24 per share