% Simulation for Table 5.5: CoC Option Prices and Computational Times
clear; clc;

% Parameters
S0 = 500;
K1 = 300;
K2 = 150;
T1 = 5/12;
T2 = 30/12;
r = 0.05;
p = 0.3;

% Volatility values to test
sigma_values = [0.1, 0.2, 0.5];
N_values = [100, 200, 300];

% Preallocate results table
num_sigma = length(sigma_values);
num_N = length(N_values);

% Initialize results arrays
theoretical_prices = zeros(num_sigma, num_N);
trinomial_prices = zeros(num_sigma, num_N);
comp_time_theoretical = zeros(num_sigma, num_N);
comp_time_trinomial = zeros(num_sigma, num_N);

fprintf('=== CoC Option Pricing Simulation for Table 5.5 ===\n');
fprintf('S0=%.0f, K1=%.0f, K2=%.0f, T1=%.3f, T2=%.3f, r=%.3f, p=%.1f\n\n', ...
        S0, K1, K2, T1, T2, r, p);

% Warm-up runs to avoid initial overhead
fprintf('Running warm-up calculations...\n');
% geske_coe_price(S0, K1, K2, T1, T2, r, 0.2);
EUCompound_BS(S0, r, 0.2, T1, T2, K1, K2);
EUCompound_Tri(S0, T1, T2, 50, K1, K2, p, r, 0.2);

% Main simulation loop
for sigma_idx = 1:num_sigma
    sigma = sigma_values(sigma_idx);
    fprintf('\n=== Sigma = %.1f ===\n', sigma);
    
    for N_idx = 1:num_N
        N = N_values(N_idx);
        fprintf('N = %d: ', N);
        
        % Calculate theoretical price and time
        tic;
        theoretical_price = EUCompound_BS(S0, r, sigma, T1, T2, K1, K2);
        time_theoretical = toc; %in seconds %toc * 1000; % Convert to milliseconds
        
        % Calculate trinomial price and time
        tic;
        trinomial_price = EUCompound_Tri(S0, T1, T2, N, K1, K2, p, r, sigma);
        time_trinomial = toc; %in seconds %toc * 1000; % Convert to milliseconds
        
        % Store results
        theoretical_prices(sigma_idx, N_idx) = theoretical_price;
        trinomial_prices(sigma_idx, N_idx) = trinomial_price;
        comp_time_theoretical(sigma_idx, N_idx) = time_theoretical;
        comp_time_trinomial(sigma_idx, N_idx) = time_trinomial;
        
        fprintf('TP=%.4f (%.3f s), TMP=%.4f (%.3f s)\n', ...
                theoretical_price, time_theoretical, trinomial_price, time_trinomial);
    end
end

% Theoretical prices (TP) and Trinomial model prices (TMP) approximation of
% Coc options and computational times in relation to `sigma` and `N`.
fprintf('\n\n=== Table 5.5 ===\n');
fprintf('N\t\t');
for sigma_idx = 1:num_sigma
    fprintf('σ=%.1f\t\t\t', sigma_values(sigma_idx));
end
fprintf('\n');
fprintf('\t\tTP\t\tTMP\t\tTP\t\tTMP\t\tTP\t\tTMP\n');

for N_idx = 1:num_N
    N = N_values(N_idx);
    fprintf('%d\t\t', N);
    
    for sigma_idx = 1:num_sigma
        fprintf('%.4f\t%.4f\t', theoretical_prices(sigma_idx, N_idx), trinomial_prices(sigma_idx, N_idx));
    end
    fprintf('\n\t\t');
    
    for sigma_idx = 1:num_sigma
        fprintf('(%.3f s)\t(%.3f s)\t', comp_time_theoretical(sigma_idx, N_idx), comp_time_trinomial(sigma_idx, N_idx));
    end
    fprintf('\n');
end

% Save results to CSV file for further analysis
results_table = table();
results_table.N = N_values';
for sigma_idx = 1:num_sigma
    sigma = sigma_values(sigma_idx);
    results_table.(sprintf('TP_sigma_%.1f', sigma)) = theoretical_prices(sigma_idx, :)';
    results_table.(sprintf('TMP_sigma_%.1f', sigma)) = trinomial_prices(sigma_idx, :)';
    results_table.(sprintf('Time_TP_sigma_%.1f s', sigma)) = comp_time_theoretical(sigma_idx, :)';
    results_table.(sprintf('Time_TMP_sigma_%.1f s', sigma)) = comp_time_trinomial(sigma_idx, :)';
end

writetable(results_table, 'Exotic/Compound/output/coc_pricing_results.csv');
fprintf('\nResults saved to Exotic/Compound/output/coc_pricing_results.csv\n');

% Create a visualization of the results
figure('Position', [100, 100, 1200, 800]);
subplot(2, 1, 1);

% Plot prices
colors = ['r', 'g', 'b'];
markers = ['o', 's', '^'];
for sigma_idx = 1:num_sigma
    sigma = sigma_values(sigma_idx);
    plot(N_values, theoretical_prices(sigma_idx, :), ...
         [colors(sigma_idx) '--'], 'LineWidth', 1.5, 'DisplayName', sprintf('TP (σ=%.1f)', sigma));
    hold on;
    plot(N_values, trinomial_prices(sigma_idx, :), ...
         [colors(sigma_idx) '-o'], 'LineWidth', 1.5, 'MarkerSize', 6, ...
         'DisplayName', sprintf('TMP (σ=%.1f)', sigma));
end
xlabel('Number of steps N');
ylabel('Option price');
title('CoC Option Prices: Theoretical vs Trinomial Model');
legend('Location', 'best');
grid on;

subplot(2, 1, 2);
% Plot computation times
for sigma_idx = 1:num_sigma
    sigma = sigma_values(sigma_idx);
    semilogy(N_values, comp_time_theoretical(sigma_idx, :), ...
             [colors(sigma_idx) '--'], 'LineWidth', 1.5, 'DisplayName', sprintf('TP Time (σ=%.1f)', sigma));
    hold on;
    semilogy(N_values, comp_time_trinomial(sigma_idx, :), ...
             [colors(sigma_idx) '-o'], 'LineWidth', 1.5, 'MarkerSize', 6, ...
             'DisplayName', sprintf('TMP Time (σ=%.1f)', sigma));
end
xlabel('Number of steps N');
ylabel('Computation time (s, log scale)');
title('Computation Times: Theoretical vs Trinomial Model');
legend('Location', 'best');
grid on;

saveas(gcf, 'Exotic/Compound/output/coc_pricing_comparison.png');
saveas(gcf, 'Exotic/Compound/output/coc_pricing_comparison.svg');