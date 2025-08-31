%Appendix G: Matlab function for implementing the convergence of the
%trinomial price to the Black-Scholes price of perpetual American Put.
clear all
close all
clc

k = 10;
r = 0.01;
T= 1:200;
p = 0.4;
sigma = 0.3;
S0 = 10;
N=T;
for t=T   
    h = T/N;
    u = sigma*sqrt(h/2/p);
    S=StockPricesnew(S0,t,u);
    AA=AmericanPut(S,k,r,t,p,h,u);
    A(t)=AA(t+1,1);
 end
plot(T,A)
hold on
plot([1;200],[5.6229;5.6229],'--')
xlabel('Time to maturity T')
ylabel('Options Price')
legend('Trinomial Model', 'American Perpetual Put', 'Location', 'southeast');








