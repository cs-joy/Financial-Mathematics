% Example parameters
S = 100;        % Current stock price
K = 100;        % Strike price
r = 0.05;       % Risk-free rate
sigma = 0.2;    % Volatility
T = 1;          % Time to maturity
option_type = 'call'; % 'call' or 'put'

% Run the analysis
trinomial_convergence_analysis(S, K, r, sigma, T, option_type);