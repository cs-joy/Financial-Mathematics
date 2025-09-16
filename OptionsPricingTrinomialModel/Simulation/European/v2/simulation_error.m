%Appendix D: Trinomial model converges to Geometric Brownian Motion(GBM), 
%in this case at leading order in h, the values of u become u =sigma*sqrt(h/(2*p(i)))
%Also the number of steps N and  the different values of probability p have been
%considered. We have function StockPricesnew as a matrix for pricing of a stock which is calculated by Trinomial model.
%Also we have function Untitled as a matrix for options pricing calculated by Trinomial model.
%We have Black-Scholes price for options by builtin Matlab`blsprice`.
% Finally we choose to find the Error value by the differences of trinomial
% options price and Black -Scholes options price to show the smoothness of
% the convergence of Trinomial to Blacke-Scholes model compare to Binomial
% model. Note that Trinomial model becomes binomial model when it only
% consideres p=0.5. 
N=50;
T=1/12;
h=T/N;
S0=10;
k=10;
r=0.01;
sigma=0.02;
p=0.05:0.01:0.5;%p=0.1:0.1:0.5;
for i = 1:numel(p)
  syms x;
  g=x-k; % call option, for put option we use g = k - x;
  u=sigma*sqrt(h/(2*p(i)));
  S=StockPricesNew(S0,N,u); 
  P=OptionPricesNew(S,g,r,p(i),h,u);
  Call=blsprice(S0,k,r,T,sigma);
  Error(i)=abs(Call-P(N+1,1));
end
plot(p,Error,'b');hold on
plot([0.05;0.5],[0.0001160 0.0001160],'--')
xlabel('Parameter p')
ylabel('Error')
