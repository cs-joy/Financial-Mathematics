%Appendix G: Matlab function for implementing the convergence of the
%trinomial price to the Black-Scholes price of perpetual American Put.
clear all
close all
clc
K = 10;
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
    AA=AmericanPut(S,K,r,t,p,h,u);
    A(t)=AA(t+1,1);
end
%% calculate american perpetual put price
q = 0; % yield dividens - for our expriement
perpetual_price = AmericanPerpetualPut(S0, K, r, sigma, q);

plot(T,A);
hold on;
plot([1;200],[perpetual_price;perpetual_price],'--');
xlabel('Time to maturity');
ylabel('Options price');
legend('Trinomial price','American perputal put price', 'Location', 'best');

