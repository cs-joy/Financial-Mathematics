function crr_binomial_model()
    % Clear workspace and close figures
    clear all;
    close all;
    clc;
    
    % Input parameters
    S0 = 100; % Initial stock price
    K = 100; % Strike price
    T = 1; % Time to maturity (years)
    r = 0.05; % Risk-free rate
    sigma = 0.2; % Volatility
    option_type = 'call'; % 'call' or 'put'
    max_steps = 500; % Maximum number of steps for convergence analysis
    
    % Benchmark Black-Scholes price
    bs_price = black_scholes(S0, K, T, r, sigma, option_type);
    fprintf('Black-Scholes Price: %.4f\n', bs_price);
    
    % Initialize arrays for analysis
    steps = 10:10:max_steps;
    prices = zeros(size(steps));
    errors = zeros(size(steps));
    times = zeros(size(steps));

    % Convergence analysis
    for i = 1:length(steps)
        n = steps(i);
        tic;
        prices(i) = crr_binomial(S0, K, T, r, sigma, n, option_type);
        times(i) = toc;
        errors(i) = abs(prices(i) - bs_price);
    end
    
    % Display final results
    fprintf('\nCRR Binomial Model Performance:\n');
    fprintf('Final Price (n=%d): %.4f\n', max_steps, prices(end));
    fprintf('Final Error: %.6f\n', errors(end));
    fprintf('Final Execution Time: %.6f seconds\n', times(end));
    
    % Plot convergence
    figure;
    
    subplot(3,1,1);
    plot(steps, prices, 'b-', 'LineWidth', 1.5);
    hold on;
    y1 = ylim;
    line([min(steps) max(steps)], [bs_price bs_price], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    ylim(y1);
    
    title('Price Convergence');
    xlabel('Number of Steps');
    ylabel('Option Price');
    legend('CRR Price', 'Black-Scholes', 'Location', 'best');
    grid on;
    
    subplot(3,1,2);
    plot(steps, errors, 'k-', 'LineWidth', 1.5);
    title('Error Convergence');
    xlabel('Number of Steps');
    ylabel('Absolute Error');
    grid on;
    
    subplot(3,1,3);
    plot(steps, times, 'm-', 'LineWidth', 1.5);
    title('Execution Time');
    xlabel('Number of Steps');
    ylabel('Time (seconds)');
    grid on;

    % Calculate convergence rate (slope of log-log error plot)
    log_steps = log(steps(10:end)');
    log_errors = log(errors(10:end)');
    X = [ones(length(log_steps),1), log_steps];
    b = X\log_errors;
    convergence_rate = -b(2);
    fprintf('\nConvergence Rate: %.4f (approximate order of convergence)\n', convergence_rate);
end