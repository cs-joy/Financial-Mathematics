%Appendix F: Matlab function for the binomial and the trinomial price of American put
%options converge to the same value as N->infinity.The convergence of the
%trinomial price should be faster.

alpha=0.01;
k = 10;
r = 0.01;
N = 1:100;
T = 1/12;
sigma = 0.02;
S0 = 10;
for p = [0.4 0.5]
for n = N
    h = T/n;
    u = sigma*sqrt(h/2/p);
    S = StockPricesnew(S0,n,u);
    AA = AmericanPut(S,k,r,n,p,h,u);
    A(n)= AA(n+1,1);
    
end
plot(N,A);hold on
end
