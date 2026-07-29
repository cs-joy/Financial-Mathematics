function price = black_scholes(S0, K, T, r, sigma, option_type)
    % Black-Scholes Option Pricing Model
    d1 = (log(S0/K) + (r + 0.5*sigma^2)*T) / (sigma*sqrt(T));
    d2 = d1 - sigma*sqrt(T);
    
    switch lower(option_type)
        case 'call'
            price = S0*normcdf(d1) - K*exp(-r*T)*normcdf(d2);
        case 'put'
            price = K*exp(-r*T)*normcdf(-d2) - S0*normcdf(-d1);
        otherwise
            error('Invalid option type. Use "call" or "put".');
    end
end