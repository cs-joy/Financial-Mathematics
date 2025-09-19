% AMERICANPERPETUALPUT Calculates the price of an American perpetual put option
%
% Inputs:
%   S     - Current stock price
%   K     - Strike price
%   r     - Risk-free interest rate
%   sigma - Volatility
%   q     - Dividend yield (set to 0 if no dividends)
%
% Output:
%   price - Price of the American perpetual put option

function price = AmericanPerpetualPut(S, K, r, sigma, q)

    % h2 parameter
    term1 = (r - q) / sigma^2;
    term2 = (term1 - 0.5)^2 + (2*r) / sigma^2;
    h2 = 0.5 - term1 - sqrt(term2);
    fprintf('h2: %.4f', h2);
    
    %% calculate the perpetual put price
    if h2 == 1
        % Handle special case where h2 = 1 (though unlikely in practice)
        price = K * (S/K)^0; % This would be K, but let's use limit
        warning('h2 = 1, using limit calculation');
    else
        price = (K / (1 - h2)) * (((h2 - 1) / h2) * (S / K))^h2;
    end
end