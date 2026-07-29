function compare_models()
    % Parameters
    S0 = 100; % Initial stock price
    K = 100; % Strike price
    r = 0.05; % Risk-free rate
    sigma = 0.2; % Volatility
    T = 1; % Time to maturity (years)
    option_type = 'call'; % 'call' or 'put'
    
    %max_steps = 500; % Maximum number of steps for convergence analysis

    % Get Black-Scholes price (benchmark)
    bs_price = black_scholes(S0, K, r, sigma, T, option_type);
    fprintf('Black-Scholes Price: %.4f\n', bs_price);

    % Test different step sizes for convergence analysis
    step_sizes = [10, 20, 50, 100, 200, 500];
    %step_sizes = 10:10:max_steps;
    n_tests = length(step_sizes);
    trinomial_prices = zeros(n_tests, 1);
    errors = zeros(n_tests, 1);
    times = zeros(n_tests, 1);
    
    fprintf('Running convergence analysis...\n');
    fprintf('Black-Scholes Price: %.4f\n\n', bs_price);
    fprintf('%-10s %-12s %-10s %-12s\n', 'Steps', 'Price', 'Error', 'Time (s)');
    
    for i = 1:n_tests
        N = step_sizes(i);
        [trinomial_prices(i), ~, errors(i), times(i)] = trinomial_model(S0, K, r, sigma, T, N, option_type);
        errors(i) = abs(trinomial_prices(i) - bs_price);
        fprintf('%-10d %-12.4f %-10.4f %-12.4f\n', N, trinomial_prices(i), errors(i), times(i));
    end
    
    % Calculate convergence rate
    if length(step_sizes) >= 3
        log_errors = log(errors(end-2:end));
        log_steps = log(1./step_sizes(end-2:end))';
        X = [ones(length(log_steps),1), log_steps'];
        b = X \ log_errors;
        convergence_rate = -b(2);
    else
        convergence_rate = NaN;
    end

    % Plot convergence
    figure;
    loglog(step_sizes, errors, '-o');
    xlabel('Number of Steps');
    ylabel('Absolute Error');
    title('Convergence of Trinomial Model');
    grid on;

    % Display analytics
    fprintf('\nModel Analytics:\n');
    fprintf('Convergence Rate: %.4f (log(error) vs log(1/N))\n', convergence_rate);
    fprintf('Final Error Margin: %.6f\n', errors(end));
    fprintf('Average Execution Time: %.4f seconds\n', mean(times));

    % Compare execution times
    tic;
    black_scholes(S0, K, r, sigma, T, option_type);
    bs_time = toc;
    fprintf('Black-Scholes Execution Time: %.6f seconds\n', bs_time);
end