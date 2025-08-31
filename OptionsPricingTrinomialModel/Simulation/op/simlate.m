%% Parameters
S0 = 100;           % Current stock price
K = 105;            % Strike price
r = 0.05;           % Risk-free rate (5%)
T = 0.5;            % Time to expiration (6 months)
N = 100;            % Number of steps
sigma = 0.2;        % Volatility (20%)

%% Calculate trinomial model parameters
h = T/N;            %% Time step
u = sigma * sqrt(3*h); %% Price change factor
p = 1/6;            %% Probability of up/down movement (symmetric trinomial)

%% Generate trinomial stock price tree
S_tree = StockPricesnew(S0, N, u);

%% Calculate American put option price
american_put_price = AmericanPut(S_tree, K, r, N, p, h, u);

%% The option price is at the root node (center of first column)
option_price = american_put_price(N+1, 1);

fprintf('American Put Option Price: $%.4f\n', option_price);
fprintf('Parameters used:\n');
fprintf('  Stock Price: $%.2f\n', S0);
fprintf('  Strike Price: $%.2f\n', K);
fprintf('  Risk-free rate: %.2f%%\n', r*100);
fprintf('  Time to expiration: %.1f years\n', T);
fprintf('  Volatility: %.2f%%\n', sigma*100);