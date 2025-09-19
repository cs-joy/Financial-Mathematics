% Parameters
S0 = 10;       % Initial stock price
K = 10;        % Strike price
r = 0.01;       % Risk-free interest rate
T = 10/252;          % Time to maturity (years)
N = 100;        % Number of steps
sigma = 0.5;    % Volatility

% Calculate trinomial model parameters
h = T / N;      % Time step size
u = sigma * sqrt(h / (2 * p));  % Up factor
p = 0.4;        % Probability of up/down movement (symmetric trinomial)

% Generate stock price tree
S = StockPricesnew(S0, N, u);

% Calculate American put option price
american_put_price = AmericanPut(S, K, r, N, p, h, u);

% Display results
fprintf('American Put Option Price: %.4f\n', american_put_price(N+1, 1));
fprintf('Initial Stock Price: %.2f\n', S0);
fprintf('Strike Price: %.2f\n', K);
fprintf('Risk-free Rate: %.2f%%\n', r*100);
fprintf('Volatility: %.2f%%\n', sigma*100);
fprintf('Time to Maturity: %.2f years\n', T);
fprintf('Number of Steps: %d\n', N);