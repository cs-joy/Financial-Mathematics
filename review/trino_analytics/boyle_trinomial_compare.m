function [trinomial_price, bs_price] = boyle_trinomial_compare(S, K, r, sigma, T, N, option_type)
    % S: current stock price
    % K: strike price
    % r: risk-free rate
    % sigma: volatility
    % T: time to maturity (in years)
    % N: number of time steps
    % option_type: 'call' or 'put'
    
    % Calculate parameters for Boyle's trinomial model
    dt = T / N;
    u = exp(sigma * sqrt(3 * dt));
    d = 1 / u;
    
    % Risk-neutral probabilities
    disc = exp(r * dt);
    m = exp(r * dt / 2);
    s = exp(sigma * sqrt(dt / 2));
    
    pu_num = (disc * s - 1) * (m^2) - (m - 1) * (s^2);
    pu_den = (s^2 - 1) * (m^2 - 1);
    pu = (pu_num / pu_den);
    
    pd_num = (disc * s - 1) * (m^2) - (s^2 - m) * (1);
    pd_den = (s^2 - 1) * (m^2 - 1);
    pd = (pd_num / pd_den);
    
    pm = 1 - pu - pd;
    
    % Check if probabilities are valid
    if pu < 0 || pd < 0 || pm < 0
        error('Negative probabilities detected. Try increasing number of steps.');
    end
    
    % Initialize asset prices at maturity
    ST = zeros(2*N+1, 1);
    ST(1) = S * (u^N);
    
    for i = 2:2*N+1
        ST(i) = ST(i-1) * d;
    end
    
    % Initialize option values at maturity
    if strcmpi(option_type, 'call')
        V = max(ST - K, 0);
    elseif strcmpi(option_type, 'put')
        V = max(K - ST, 0);
    else
        error('option_type must be either "call" or "put"');
    end
    
    % Backward induction through the tree
    for step = N-1:-1:0
        for i = 1:(2*step+1)
            up_idx = i;
            mid_idx = i+1;
            down_idx = i+2;
            
            % Discounted expected value
            V(i) = exp(-r * dt) * (pu * V(up_idx) + pm * V(mid_idx) + pd * V(down_idx));
        end
    end
    
    trinomial_price = V(1);
    
    % Calculate Black-Scholes price for comparison
    bs_price = b_s(S, K, r, sigma, T, option_type);
end

