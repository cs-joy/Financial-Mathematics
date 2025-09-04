% Parameters from Table 5.4
Floc = 0;       % Local floor
Cloc = 0.08;    % Local cap
Fglob = 0.16;   % Global floor
Cglob = Inf;    % Global cap (no cap)
T = 5;          % Total time
m = 5;          % Number of reset periods
r = 0.03;       % Risk-free rate
p = 1/6;        % For trinomial model

% Volatilities and N values to test
sigma_values = [0.1, 0.2, 0.5];
N_values = [100, 200, 300];

% Preallocate results tables
trinomial_results = cell(length(N_values), length(sigma_values));
binomial_results = cell(length(N_values), length(sigma_values));
trinomial_times = zeros(length(N_values), length(sigma_values));
binomial_times = zeros(length(N_values), length(sigma_values));

% Calculate prices and times
for sigma_idx = 1:length(sigma_values)
    sigma = sigma_values(sigma_idx);
    
    for N_idx = 1:length(N_values)
        N = N_values(N_idx);
        
        % Trinomial model (p = 1/6)
        tic;
        trinomial_price = CliquetPriceTrinomial(Floc, Cloc, Fglob, Cglob, T, m, N, sigma, r, p);
        trinomial_time = toc;
        
        % Binomial model (p = 0.5)
        tic;
        binomial_price = CliquetPriceTrinomial(Floc, Cloc, Fglob, Cglob, T, m, N, sigma, r, 0.5);
        binomial_time = toc;
        
        % Store results
        trinomial_results{N_idx, sigma_idx} = sprintf('%.5f (%.1f s)', trinomial_price, trinomial_time);
        binomial_results{N_idx, sigma_idx} = sprintf('%.5f (%.1f s)', binomial_price, binomial_time);
        trinomial_times(N_idx, sigma_idx) = trinomial_time;
        binomial_times(N_idx, sigma_idx) = binomial_time;
        
        fprintf('σ=%.1f, N=%d: Trinomial=%.5f (%.1fs), Binomial=%.5f (%.1fs)\n', ...
                sigma, N, trinomial_price, trinomial_time, binomial_price, binomial_time);
    end
end

% Display results in table format
fprintf('\n=== TABLE 5.4: CLIQUET OPTION PRICES AND COMPUTATIONAL TIMES ===\n\n');

% Header
fprintf('%-8s', 'N');
for sigma_idx = 1:length(sigma_values)
    fprintf('%-25s %-25s', sprintf('σ=%.1f BP', sigma_values(sigma_idx)), sprintf('σ=%.1f TP', sigma_values(sigma_idx)));
end
fprintf('\n');

% Separator line
fprintf('%s', repmat('-', 8 + 50*length(sigma_values), 1));
fprintf('\n');

% Data rows
for N_idx = 1:length(N_values)
    fprintf('%-8d', N_values(N_idx));
    for sigma_idx = 1:length(sigma_values)
        fprintf('%-25s %-25s', binomial_results{N_idx, sigma_idx}, trinomial_results{N_idx, sigma_idx});
    end
    fprintf('\n');
end

% Additional analysis
fprintf('\n=== COMPUTATIONAL TIME ANALYSIS ===\n');
fprintf('Trinomial/Binomial time ratios:\n');
for sigma_idx = 1:length(sigma_values)
    fprintf('σ=%.1f: ', sigma_values(sigma_idx));
    for N_idx = 1:length(N_values)
        ratio = trinomial_times(N_idx, sigma_idx) / binomial_times(N_idx, sigma_idx);
        fprintf('N=%d: %.1fx  ', N_values(N_idx), ratio);
    end
    fprintf('\n');
end

% Create a bar chart comparing computational times
figure;
subplot(1, 2, 1);
bar(trinomial_times);
set(gca, 'XTickLabel', N_values);
xlabel('Number of Steps (N)');
ylabel('Computational Time (s)');
title('Trinomial Model Computational Times');
legend(arrayfun(@(x) sprintf('σ=%.1f', x), sigma_values, 'UniformOutput', false));
grid on;

subplot(1, 2, 2);
bar(binomial_times);
set(gca, 'XTickLabel', N_values);
xlabel('Number of Steps (N)');
ylabel('Computational Time (s)');
title('Binomial Model Computational Times');
legend(arrayfun(@(x) sprintf('σ=%.1f', x), sigma_values, 'UniformOutput', false));
grid on;

% Helper functions (must be in the same file or separate files)
