% Parameters for Figure 4.2 simulation
S0 = 10;        % Initial stock price
K = 10;         % Strike price
r = 0.01;       % Risk-free interest rate
sigma = 0.5;    % Volatility
T = 10/252;     % Time to maturity (10 days)
p_trinomial = 0.4; % Probability for trinomial model

% Range of N values to test
N_values = 10:5:200;

% Initialize arrays to store prices
trinomial_prices = zeros(size(N_values));
binomial_prices = zeros(size(N_values));

% Calculate prices for different N values
for i = 1:length(N_values)
    N = N_values(i);
    
    % For trinomial model (p = 0.4)
    h = T / N;
    u = sigma * sqrt(h / (2 * p_trinomial));
    S_trinomial = StockPricesnew(S0, N, u);
    A_trinomial = AmericanPut(S_trinomial, K, r, N, p_trinomial, h, u);
    trinomial_prices(i) = A_trinomial(N+1, 1);
    
    % For binomial model (special case of trinomial with p = 0.5)
    p_binomial = 0.5;
    u_binomial = sigma * sqrt(h / (2 * p_binomial));
    S_binomial = StockPricesnew(S0, N, u_binomial);
    A_binomial = AmericanPut(S_binomial, K, r, N, p_binomial, h, u_binomial);
    binomial_prices(i) = A_binomial(N+1, 1);
end

% Create the convergence plot (Figure 4.2)
figure;
plot(N_values, trinomial_prices);
hold on;
plot(N_values, binomial_prices);
hold off;

% Add labels and title
xlabel('Number of Steps (N)');
ylabel('American Put Option Price');
title('Convergence of Trinomial and Binomial Models for American Put Options');
legend('Trinomial Model (p=0.4)', 'Binomial Model (p=0.5)', 'Location', 'best');
grid on;

% Set appropriate axis limits
xlim([min(N_values), max(N_values)]);
ylim([min([trinomial_prices, binomial_prices])*0.95, max([trinomial_prices, binomial_prices])*1.05]);

% Add text annotation with parameters
text_params = sprintf('S_0 = %d, K = %d, r = %.3f, \\sigma = %.1f, T = %.3f years', ...
                     S0, K, r, sigma, T);
annotation('textbox', [0.15, 0.15, 0.7, 0.1], 'String', text_params, ...
           'FitBoxToText', 'on', 'BackgroundColor', 'white', 'EdgeColor', 'none');

% Display final prices for comparison
fprintf('Final trinomial price (N=%d): %.4f\n', N_values(end), trinomial_prices(end));
fprintf('Final binomial price (N=%d): %.4f\n', N_values(end), binomial_prices(end));