function trinomial_convergence_study(S, K, r, sigma, T, option_type)
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
    
    % Test different numbers of steps
    step_trials = [10, 20, 50, 100, 200, 500, 1000];
    n_trials = length(step_trials);
    
    % Initialize results storage
    prices = zeros(n_trials, 1);
    errors = zeros(n_trials, 1);
    times = zeros(n_trials, 1);
    
    fprintf('\nConvergence Study: %s Option (S=%.1f, K=%.1f, r=%.2f, ?=%.2f, T=%.1f)\n', ...
            upper(option_type), S, K, r, sigma, T);
    fprintf('Black-Scholes Price: %.6f\n\n', bs_price);
    fprintf('%8s %12s %12s %12s %15s\n', ...
            'Steps', 'Price', 'Error', 'Time(s)', 'Convergence Rate');
    
    for i = 1:n_trials
        N = step_trials(i);
        
        % Time the trinomial calculation
        tic;
        prices(i) = boyle_trinomial(S, K, r, sigma, T, N, option_type);
        times(i) = toc;
        
        % Calculate error
        errors(i) = abs(prices(i) - bs_price);
        
        % Calculate convergence rate (when possible)
        if i > 1
            rate = log(errors(i-1)/errors(i)) / log(step_trials(i)/step_trials(i-1));
        else
            rate = NaN;
        end
        
        fprintf('%8d %12.6f %12.6f %12.4f %15.2f\n', ...
                N, prices(i), errors(i), times(i), rate);
    end
    
    % Plot convergence
    figure;
    loglog(step_trials, errors, '-o', 'LineWidth', 2);
    hold on;
    loglog(step_trials, 1./step_trials, '--', 'LineWidth', 1.5); % Reference line
    xlabel('Number of Steps');
    ylabel('Absolute Error');
    title(sprintf('Convergence of Trinomial Model (%s Option)', upper(option_type)));
    legend('Trinomial Error', 'O(1/N) Reference', 'Location', 'NorthEast');
    grid on;
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