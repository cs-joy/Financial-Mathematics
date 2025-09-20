
S0=10.0;
K=10.0;
r = 0.0425;
q = 0;
sigma = 0.25;

p=0.4;

T = 1:200;   % large T to approximate perpetual
N = T;   % number of steps (use 500 for speed, but 1000 is better)


perpetual_price = AmericanPerpetualPut(S0, K, r, sigma, q);
fprintf("pertual_price: %.6f\n", perpetual_price);

for t=T
    h = T/N;
    fprintf("h= %.2f\n", h);
    u = sigma*sqrt(h/(2*p)); %% ??
    S=StockPrices(S0,t,u);
    AA=AmericanPut(S,K,r,t,p,h,u);
    A(t)=AA(t+1,1);
end
fprintf('Approximate perpetual put price using trinomial tree: %.6f\n', A(N));
% h = T/N;
% 
% u = sigma*sqrt(h/(2*p));

% S=StockPrices(S0,N,u);
% AA=AmericanPut(S,K,r,N,p,h,u);
% A(N)=AA(N+1,1);
% trino_price = A(N);
% fprintf("trino price: {%.4f}", trino_price);


% % Build stock price tree
% S_tree = StockPrices(S0, N, u);
% 
% 
% % Call AmericanPut
% option_price = AmericanPut(S_tree, K, r, N, p, h, u);
% 
% fprintf('Approximate perpetual put price using trinomial tree: %.6f\n', option_price(200));