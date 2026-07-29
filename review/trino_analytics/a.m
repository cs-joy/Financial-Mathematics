function [trinomial_price, bs_price] = a(S, K, r, sigma, T, N, option_type)
    % Validate inputs
    if nargin < 7
        error('All 7 parameters are required: S, K, r, sigma, T, N, option_type');
    end
    if S <= 0 || K <= 0 || T <= 0 || N <= 0
        error('S, K, T, and N must be positive values');
    end
    if ~ismember(lower(option_type), {'call', 'put'})
        error('option_type must be either "call" or "put"');
    end
    
    % Calculate parameters for Boyle's trinomial model
    dt = T / N;
    dx = sigma * sqrt(3 * dt);
    u = exp(dx);
    d = 1/u;
    
    % Risk-neutral probabilities (simplified and more robust calculation)
    nu = r - 0.5 * sigma^2;
    pu = 0.5 * ((sigma^2 * dt + nu^2 * dt^2) / dx^2 + nu * dt / dx);
    pd = 0.5 * ((sigma^2 * dt + nu^2 * dt^2) / dx^2 - nu * dt / dx);
    pm = 1 - pu - pd;
    
    % Validate probabilities
    if pu < 0 || pd < 0 || pm < 0
        warning('Negative probabilities detected. Increasing number of steps.');
        % Recursively try with more steps
        [trinomial_price, bs_price] = boyle_trinomial_compare(S, K, r, sigma, T, N*2, option_type);
        return;
    end
    
    % Initialize asset prices at maturity
    ST = S * u.^(N:-1:-N)';
    
    % Initialize option values at maturity
    if strcmpi(option_type, 'call')
        V = max(ST - K, 0);
    else % put
        V = max(K - ST, 0);
    end
    
    % Backward induction through the tree
    discount = exp(-r * dt);
    for step = N-1:-1:0
        % Vectorized calculation for better performance
        V = discount * (pu * V(1:end-2) + pm * V(2:end-1) + pd * V(3:end));
    end
    
    trinomial_price = V(1);
    
    % Calculate Black-Scholes price for comparison
    bs_price = black_schole(S, K, r, sigma, T, option_type);
end

function price = black_schole(S, K, r, sigma, T, option_type)
    d1 = (log(S/K) + (r + sigma^2/2)*T) / (sigma*sqrt(T));
    d2 = d1 - sigma*sqrt(T);
    
    if strcmpi(option_type, 'call')
        price = S*normcdf(d1) - K*exp(-r*T)*normcdf(d2);
    else % put
        price = K*exp(-r*T)*normcdf(-d2) - S*normcdf(-d1);
    end
end