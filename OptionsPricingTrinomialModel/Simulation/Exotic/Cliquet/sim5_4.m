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
N_values = [10, 20, 30];  % Reduced for testing - increase later

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
        try
            trinomial_price = CliquetPriceTrinomial(Floc, Cloc, Fglob, Cglob, T, m, N, sigma, r, p);
            trinomial_time = toc;
        catch
            trinomial_price = NaN;
            trinomial_time = toc;
            warning('Trinomial calculation failed for σ=%.1f, N=%d', sigma, N);
        end
        
        % Binomial model (p = 0.5)
        tic;
        try
            binomial_price = CliquetPriceTrinomial(Floc, Cloc, Fglob, Cglob, T, m, N, sigma, r, 0.5);
            binomial_time = toc;
        catch
            binomial_price = NaN;
            binomial_time = toc;
            warning('Binomial calculation failed for σ=%.1f, N=%d', sigma, N);
        end
        
        % Store results
        if ~isnan(trinomial_price)
            trinomial_results{N_idx, sigma_idx} = sprintf('%.5f (%.1f s)', trinomial_price, trinomial_time);
        else
            trinomial_results{N_idx, sigma_idx} = 'NaN';
        end
        
        if ~isnan(binomial_price)
            binomial_results{N_idx, sigma_idx} = sprintf('%.5f (%.1f s)', binomial_price, binomial_time);
        else
            binomial_results{N_idx, sigma_idx} = 'NaN';
        end
        
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