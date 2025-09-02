% Parameters from Figure 5.1
Floc = 0;       % Local floor
Cloc = 0.08;    % Local cap
Fglob = 0.16;   % Global floor
Cglob = Inf;    % Global cap (no cap)
T = 5;          % Total time
m = 5;          % Number of reset periods
sigma = 0.2;    % Volatility
r = 0.03;       % Risk-free rate
p = 1/6;        % For trinomial model (binomial uses p = 0.5)

% Range of steps per reset period
N_list = 10:10:200;  % Steps per reset period

% Reference price from Monte Carlo (as mentioned in the paper)
reference_price = 0.174;

% Preallocate arrays
trinomial_prices = zeros(size(N_list));
binomial_prices = zeros(size(N_list));
comp_time_trinomial = zeros(size(N_list));
comp_time_binomial = zeros(size(N_list));

% Loop through different numbers of steps
for i = 1:length(N_list)
    N = N_list(i);
    
    % Calculate trinomial price
    tic;
    trinomial_prices(i) = CliquetPriceTrinomial(Floc, Cloc, Fglob, Cglob, T, m, N, sigma, r, p);
    comp_time_trinomial(i) = toc;
    
    % Calculate binomial price (special case with p = 0.5, q0 = 0)
    tic;
    binomial_prices(i) = CliquetPriceTrinomial(Floc, Cloc, Fglob, Cglob, T, m, N, sigma, r, 0.5);
    comp_time_binomial(i) = toc;
    
    fprintf('N = %d: Trinomial = %.6f (%.2f s), Binomial = %.6f (%.2f s)\n', ...
            N, trinomial_prices(i), comp_time_trinomial(i), binomial_prices(i), comp_time_binomial(i));
end

% Create the figure
figure;
hold on;
plot(N_list, trinomial_prices, 'b-', 'LineWidth', 2, 'DisplayName', 'Trinomial');
plot(N_list, binomial_prices, 'r--', 'LineWidth', 2, 'DisplayName', 'Binomial');
yline(reference_price, 'k-', 'LineWidth', 2, 'DisplayName', 'Reference (0.174)');

xlabel('Number of steps per reset period (N)');
ylabel('Cliquet option price');
title('Comparison of Trinomial and Binomial Model Prices for Cliquet Option');
legend('show', 'Location', 'best');
grid on;

% Display computational times
figure;
semilogy(N_list, comp_time_trinomial, 'b-', 'LineWidth', 2, 'DisplayName', 'Trinomial');
hold on;
semilogy(N_list, comp_time_binomial, 'r--', 'LineWidth', 2, 'DisplayName', 'Binomial');
xlabel('Number of steps per reset period (N)');
ylabel('Computational time (seconds)');
title('Computational Time Comparison');
legend('show', 'Location', 'northwest');
grid on;