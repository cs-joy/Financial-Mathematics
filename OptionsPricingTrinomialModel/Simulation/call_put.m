% Main script for trinomial model option pricing
function trinomial_option_pricing()
    % Parameters
    N = 50;          % Number of steps
    T = 1/12;        % Time to expiration (1 month)
    h = T/N;         % Time step size
    S0 = 10;         % Initial stock price
    K = 10;          % Strike price
    r = 0.01;        % Risk-free rate
    sigma = 0.02;    % Volatility
    
    % Define payoff functions for call and put
    call_payoff = @(x) max(x - K, 0);
    put_payoff = @(x) max(K - x, 0);
    
    % Probability range to test
    p_values = 0.05:0.01:0.5;
    
    % Initialize arrays for results
    call_prices = zeros(size(p_values));
    put_prices = zeros(size(p_values));
    bs_call = zeros(size(p_values));
    bs_put = zeros(size(p_values));
    errors_call = zeros(size(p_values));
    errors_put = zeros(size(p_values));
    
    % Calculate Black-Scholes prices (constant for all p)
    [bs_call_price, bs_put_price] = blsprice(S0, K, r, T, sigma);
    
    for i = 1:length(p_values)
        p = p_values(i);
        
        % Calculate u parameter
        u = sigma * sqrt(h / (2 * p));
        
        % Generate stock price tree
        S = StockPricesNew(S0, N, u);
        
        % Calculate option prices
        call_price = OptionPricesNew(S, call_payoff, r, p, h, u);
        put_price = OptionPricesNew(S, put_payoff, r, p, h, u);
        
        % Store results
        call_prices(i) = call_price;
        put_prices(i) = put_price;
        bs_call(i) = bs_call_price;
        bs_put(i) = bs_put_price;
        errors_call(i) = abs(call_price - bs_call_price);
        errors_put(i) = abs(put_price - bs_put_price);
    end
    
    % Display results
    fprintf('Trinomial Model Option Pricing Results:\n');
    fprintf('S0 = %.2f, K = %.2f, r = %.3f, sigma = %.3f, T = %.3f\n\n', S0, K, r, sigma, T);
    
    fprintf('Black-Scholes Prices:\n');
    fprintf('Call: %.6f, Put: %.6f\n\n', bs_call_price, bs_put_price);
    
    fprintf('Trinomial Prices for different p values:\n');
    fprintf(' p\t\tCall\t\tPut\t\tCall Error\tPut Error\n');
    fprintf('------------------------------------------------------------\n');
    for i = 1:length(p_values)
        fprintf('%.2f\t%.6f\t%.6f\t%.6f\t%.6f\n', ...
                p_values(i), call_prices(i), put_prices(i), ...
                errors_call(i), errors_put(i));
    end
    
    % Plot results
    figure;
    subplot(2,1,1);
    plot(p_values, call_prices);
    hold on;
    plot(p_values, bs_call);
    xlabel('Probability p');
    ylabel('Call Option Price');
    legend('Trinomial', 'Black-Scholes');
    title('Call Option Price vs Probability p');
    grid on;
    
    subplot(2,1,2);
    plot(p_values, put_prices);
    hold on;
    plot(p_values, bs_put);
    xlabel('Probability p');
    ylabel('Put Option Price');
    legend('Trinomial', 'Black-Scholes');
    title('Put Option Price vs Probability p');
    grid on;
    
    figure;
    subplot(2,1,1);
    plot(p_values, errors_call);
    xlabel('Probability p');
    ylabel('Call Option Error');
    title('Call Option Pricing Error (vs Black-Scholes)');
    grid on;
    
    subplot(2,1,2);
    plot(p_values, errors_put);
    xlabel('Probability p');
    ylabel('Put Option Error');
    title('Put Option Pricing Error (vs Black-Scholes)');
    grid on;
end

% Stock price tree generation
function S = StockPricesNew(S0, N, u)
    S = zeros(2*N+1, N+1);
    S(N+1, 1) = S0;
    
    for j = 1:N
        % Copy previous column
        S(:, j+1) = S(:, j);
        
        % Fill upward moves
        for i = 1:N
            if N+1-i >= 1
                S(N+1-i, j+1) = S(N+2-i, j) * exp(u);
            end
        end
        
        % Fill downward moves
        for i = 1:N
            if N+1+i <= size(S, 1)
                S(N+1+i, j+1) = S(N+i, j) * exp(-u);
            end
        end
    end
end

% Option pricing using trinomial model
function option_price = OptionPricesNew(S, payoff_func, r, p, h, u)
    M = size(S, 1);
    N = size(S, 2);
    
    P = zeros(M, N);
    
    % Calculate risk-neutral probabilities
    q0 = 1 - 2 * p;
    qu = (exp(r*h) - exp(-u)) / (exp(u) - exp(-u)) - ...
          q0 * (1 - exp(-u)) / (exp(u) - exp(-u));
    qd = (exp(u) - exp(r*h)) / (exp(u) - exp(-u)) - ...
          q0 * (exp(u) - 1) / (exp(u) - exp(-u));
    
    % Terminal payoff
    terminal_prices = S(:, N);
    P(:, N) = payoff_func(terminal_prices);
    
    % Backward induction
    for j = N-1:-1:1
        for i = (N-j+1):(M-(N-j))
            if i > 1 && i < M
                P(i, j) = exp(-r*h) * (qu * P(i-1, j+1) + ...
                                      q0 * P(i, j+1) + ...
                                      qd * P(i+1, j+1));
            end
        end
    end
    
    % The option price is at the root of the tree
    option_price = P(ceil(M/2), 1);
end