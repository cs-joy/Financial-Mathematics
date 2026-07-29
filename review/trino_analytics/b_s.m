function price = b_s(S, K, r, sigma, T, option_type)
    % Black-Scholes formula
    d1 = (log(S/K) + (r + sigma^2/2)*T) / (sigma*sqrt(T));
    d2 = d1 - sigma*sqrt(T);
    
    if strcmpi(option_type, 'call')
        price = S*normcdf(d1) - K*exp(-r*T)*normcdf(d2);
    elseif strcmpi(option_type, 'put')
        price = K*exp(-r*T)*normcdf(-d2) - S*normcdf(-d1);
    else
        error('option_type must be either "call" or "put"');
    end
end