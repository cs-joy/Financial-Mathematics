function trinomial_convergence_analysis(S, K, r, sigma, T, option_type)
    % Validate inputs
    if nargin < 6
        error('All 6 parameters are required: S, K, r, sigma, T, option_type');
    end
    if S <= 0 || K <= 0 || T <= 0
        error('S, K, and T must be positive values');
    end
    if ~ismember(lower(option_type), {'call', 'put'})
        error('option_type must be either "call" or "put"');
    end
    
    % Get Black-Scholes price as benchmark
    bs_price = black_scholes(S, K, r, sigma, T, option_type);
    
    % Test different numbers of steps (geometrically spaced)
    min_steps = 10;
    max_steps = 500;
    step_trials = round(logspace(log10(min_steps), log10(max_steps), 15)');
    n_trials = length(step_trials);
    
    % Initialize results storage
    prices = zeros(n_trials, 1);
    errors = zeros(n_trials, 1);
    times = zeros(n_trials, 1);
    rates = zeros(n_trials, 1);
    rates(1) = NaN;
    
    % Run all trials
    for i = 1:n_trials
        N = step_trials(i);
        t_start = tic;
        prices(i) = boyle_trinomial(S, K, r, sigma, T, N, option_type);
        times(i) = toc(t_start);
        errors(i) = abs(prices(i) - bs_price);
        
        % Calculate convergence rate (skip first point)
        if i > 1
            rates(i) = log(errors(i-1)/errors(i)) / log(step_trials(i)/step_trials(i-1));
        end
    end
    
    % Create figure with three subplots
    figure('Position', [100, 100, 1200, 900]);
    
    % Plot 1: Error Convergence
    subplot(2,2,1);
    loglog(step_trials, errors, 'b-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
    hold on;
    loglog(step_trials, 10*bs_price./(step_trials.^2), 'r--', 'LineWidth', 1.5);
    xlabel('Number of Steps (N)');
    ylabel('Absolute Error');
    title('Error Convergence');
    legend('Trinomial Error', 'O(N^{-2}) Reference', 'Location', 'NorthEast');
    grid on;
    
    % Plot 2: Convergence Rate
    subplot(2,2,2);
    semilogx(step_trials, rates, 'g-s', 'LineWidth', 1.5, 'MarkerFaceColor', 'g');
    hold on;
    
    ylimits=ylim;
    line([min(xlim) max(xlim)], [2 2], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    ylim(ylimits);
    
    %yline(2, 'r--', 'LineWidth', 1.5); % Theoretical rate
    xlabel('Number of Steps (N)');
    ylabel('Convergence Rate');
    title('Empirical Convergence Rate');
    ylim([0 3]);
    grid on;
    
    % Plot 3: Execution Time
    subplot(2,2,3);
    loglog(step_trials, times*1000, 'm-d', 'LineWidth', 1.5, 'MarkerFaceColor', 'm');
    hold on;
    loglog(step_trials, 0.1*step_trials, 'k--', 'LineWidth', 1.5);
    xlabel('Number of Steps (N)');
    ylabel('Execution Time (ms)');
    title('Computational Cost');
    legend('Actual Time', 'O(N) Reference', 'Location', 'NorthWest');
    grid on;
    
    % Plot 4: Error vs Time
    subplot(2,2,4);
    loglog(times*1000, errors, 'k-p', 'LineWidth', 1.5, 'MarkerFaceColor', 'k');
    xlabel('Execution Time (ms)');
    ylabel('Absolute Error');
    title('Error vs Computational Cost');
    grid on;
    
    % Display summary table
    fprintf('\nTrinomial Model Convergence Analysis\n');
    fprintf('Option Type: %s\n', upper(option_type));
    fprintf('Parameters: S=%.1f, K=%.1f, r=%.2f, ?=%.2f, T=%.1f\n', S, K, r, sigma, T);
    fprintf('Black-Scholes Price: %.6f\n\n', bs_price);
    
    fprintf('%8s %12s %12s %12s %15s\n', ...
            'Steps', 'Price', 'Error', 'Time(ms)', 'Conv Rate');
    for i = 1:n_trials
        fprintf('%8d %12.6f %12.6f %12.2f %15.2f\n', ...
                step_trials(i), prices(i), errors(i), times(i)*1000, rates(i));
    end
end

function price = boyle_trinomial(S, K, r, sigma, T, N, option_type)
    dt = T / N;
    dx = sigma * sqrt(3 * dt);
    u = exp(dx);
    d = 1/u;
    
    % Risk-neutral probabilities
    nu = r - 0.5 * sigma^2;
    pu = 0.5 * ((sigma^2 * dt + nu^2 * dt^2) / dx^2 + nu * dt / dx);
    pd = 0.5 * ((sigma^2 * dt + nu^2 * dt^2) / dx^2 - nu * dt / dx);
    pm = 1 - pu - pd;
    
    % Initialize asset prices at maturity
    ST = S * u.^(N:-1:-N)';
    
    % Initialize option values at maturity
    if strcmpi(option_type, 'call')
        V = max(ST - K, 0);
    else % put
        V = max(K - ST, 0);
    end
    
    % Backward induction
    discount = exp(-r * dt);
    for step = N-1:-1:0
        V = discount * (pu * V(1:end-2) + pm * V(2:end-1) + pd * V(3:end));
    end
    
    price = V(1);
end

function price = black_scholes(S, K, r, sigma, T, option_type)
    d1 = (log(S/K) + (r + sigma^2/2)*T) / (sigma*sqrt(T));
    d2 = d1 - sigma*sqrt(T);
    
    if strcmpi(option_type, 'call')
        price = S*normcdf(d1) - K*exp(-r*T)*normcdf(d2);
    else % put
        price = K*exp(-r*T)*normcdf(-d2) - S*normcdf(-d1);
    end
end