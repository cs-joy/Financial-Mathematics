function [price, convergence, errors, time] = trinomial_model(S0, K, r, sigma, T, N, option_type)
    % Implementation of Boyle's trinomial model
    % Parameters:
    % S0 - initial stock price
    % K - strike price
    % r - risk-free rate
    % sigma - volatility
    % T - time to maturity (years)
    % N - number of time steps
    % option_type - 'call' or 'put'
    
    tic; % Start timer
    dt = T / N;
    u = exp(sigma * sqrt(3 * dt));
    d = 1 / u;
    
    % Risk-neutral probabilities
    pu = sqrt(dt/(12*sigma^2)) * (r - sigma^2/2) + 1/6;
    pd = -sqrt(dt/(12*sigma^2)) * (r - sigma^2/2) + 1/6;
    pm = 2/3;


    % Initialize asset prices at maturity
    S = zeros(2*N+1, 1);
    S(N+1) = S0;
    for j = 1:N
        S(N+1+j) = S(N+j) * u;
        S(N+1-j) = S(N+2-j) * d;
    end
    
    %
    if strcmpi(option_type, 'call')
        V = max(0, S-K);
    else
        V = max(0, K-S);
    end

    % Initialize option values at maturity
    %V = max(0, (option_type == 'call') * (S - K) + (option_type == 'put') * (K - S));

    % Backward induction
    for n = N-1:-1:0
        for j = 1:2*n+1
            k = j + (N - n);
            V(k) = exp(-r*dt) * (pu*V(k+1) + pm*V(k) + pd*V(k-1));
            % American option exercise check
            if strcmpi(option_type, 'call')
                exercise_value = max(0, S(k)-K);
            else
                exercise_value = max(0, K-S(k));
            end
            %exercise_value = (option_type == 'call') * (S(k) - K) + (option_type == 'put') * (K - S(k));
            V(k) = max(V(k), exercise_value);
        end
    end
    
    price = V(N+1);
    time = toc;

    % Calculate convergence and errors (will be populated in the comparison function)
    convergence = [];
    errors = [];
end