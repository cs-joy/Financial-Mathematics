function price = b(S, K, r, sigma, T, option_type)
    d1 = (log(S/K) + (r + sigma^2/2)*T) / (sigma*sqrt(T));
    d2 = d1 - sigma*sqrt(T);
    
    if strcmpi(option_type, 'call')
        price = S*normcdf(d1) - K*exp(-r*T)*normcdf(d2);
    else % put
        price = K*exp(-r*T)*normcdf(-d2) - S*normcdf(-d1);
    end
end