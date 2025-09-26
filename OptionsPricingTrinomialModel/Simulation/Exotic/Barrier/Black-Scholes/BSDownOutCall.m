% BSDownOutCall(S0,T,K,r,sigma,q,B)
% Computes the theoretical Black-Scholes price of barrier options
% on a European down and out call
% S0 current stock price
% T is the time to maturity, T=1 is one year
% K is the strikeprice of the underlying European call
% r>0 is the intrest rate of the bond
% Sigma is the volatility of the underlying stock
% q is dividend
% B is the barrier
function Cdo=BSDownOutCall(S0,T,K,r,sigma,q,B)
Lb=(r-q+(sigma^2)/2)/(sigma^2);
x1=log(S0/B)/(sigma*sqrt(T))+Lb*sigma*sqrt(T);
y1=log(B/S0)/(sigma*sqrt(T))+Lb*sigma*sqrt(T);
Cdo=S0*normcdf(x1)*exp(-q*T)-K*exp(-r*T)*normcdf(x1-sigma*sqrt(T))...
-S0*exp(-q*T)*(B/S0)^(2*Lb)*normcdf(y1)+K*exp(-r*T)*...
(B/S0)^(2*Lb-2)*normcdf(y1-sigma*sqrt(T));
end
