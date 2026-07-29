function price = crr_binomial(S0, K, T, r, sigma, n, option_type)
    % CRR Binomial Option Pricing Model
    % Calculate parameters
    dt = T/n; % Time step
    u = exp(sigma*sqrt(dt)); % Up factor
    d = 1/u; % Down factor
    p = (exp(r*dt) - d)/(u - d); % Risk-neutral probability
    df = exp(-r*dt); % Discount factor

    % Initialize stock price tree
    stock_tree = zeros(n+1, n+1);
    stock_tree(1,1) = S0;

    for i = 2:n+1
        stock_tree(1:i-1,i) = stock_tree(1:i-1,i-1)*u;
        stock_tree(i,i) = stock_tree(i-1,i-1)*d;
    end
    
    % Initialize option value tree at maturity
    option_tree = zeros(size(stock_tree));
    switch lower(option_type)
        case 'call'
            option_tree(:,end) = max(stock_tree(:,end) - K, 0);
        case 'put'
            option_tree(:,end) = max(K - stock_tree(:,end), 0);
        otherwise
            error('Invalid option type. Use "call" or "put".');
    end
    
    % Backward induction
    for j = n:-1:1
        for i = 1:j
            option_tree(i,j) = df*(p*option_tree(i,j+1) + (1-p)*option_tree(i+1,j+1));
        end
    end
    price = option_tree(1,1);
end