% Test parameters
S = 100; % Current stock price
K = 100; % Strike price
r = 0.05; % Risk-free rate
sigma = 0.2; % Volatility
T = 1; % Time to maturity (1 year)
N = 200; % Number of time steps
option_type = 'call'; % Option type

% Calculate prices
[trinomial_price, bs_price] = boyle_trinomial_compare(S, K, r, sigma, T, N, option_type);

% Display results
fprintf('Trinomial Model Price: %.4f\n', trinomial_price);
fprintf('Black-Scholes Price: %.4f\n', bs_price);
fprintf('Difference: %.4f\n', abs(trinomial_price - bs_price));