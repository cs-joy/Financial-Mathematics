function price = geske_coe_price(S0, K1, K2, T1, T2, r, sigma)
    % Solve for S* (critical stock price at T1)
    fun = @(S) black_scholes_call(S, K2, T2 - T1, r, sigma) - K1;
    S_star = fzero(fun, S0);  % Use S0 as initial guess

    % Calculate parameters
    d1 = (log(S0/K2) + (r + sigma^2/2)*T2) / (sigma*sqrt(T2));
    d2 = d1 - sigma*sqrt(T2);
    d1_star = (log(S0/S_star) + (r + sigma^2/2)*T1) / (sigma*sqrt(T1));
    d2_star = d1_star - sigma*sqrt(T1);
    rho = sqrt(T1/T2);

    % Bivariate normal cumulative distribution
    term1 = S0 * normcdf2(d1_star, d1, rho);
    term2 = K2 * exp(-r*T2) * normcdf2(d2_star, d2, rho);
    term3 = K1 * exp(-r*T1) * normcdf(d2_star);

    price = term1 - term2 - term3;
end

function c = black_scholes_call(S, K, T, r, sigma)
    d1 = (log(S/K) + (r + sigma^2/2)*T) / (sigma*sqrt(T));
    d2 = d1 - sigma*sqrt(T);
    c = S * normcdf(d1) - K * exp(-r*T) * normcdf(d2);
end

function p = normcdf2(x, y, rho)
    % Bivariate normal CDF with correlation rho
    p = mvncdf([x, y], [0, 0], [1, rho; rho, 1]);
end